import 'package:flutter_bloc/flutter_bloc.dart';
import 'voter_event.dart';
import 'voter_repository.dart';
import 'voter_state.dart';

class VoterBloc extends Bloc<VoterEvent, VoterState> {
  final VoterRepository repository;

  VoterBloc(this.repository) : super(VoterInitial()) {
    on<SaveVoter>(_saveVoter);
    on<FetchVoterCount>(_fetchCount);
    on<FetchAllVoters>((event, emit) async {
      emit(VoterLoading());

      try {
        final voters = await repository.getAllVoters();
        emit(VoterListLoaded(voters));
      } catch (e) {
        emit(VoterError(e.toString()));
      }
    });
  }

  Future<void> _saveVoter(SaveVoter event, Emitter<VoterState> emit) async {
    emit(VoterLoading());

    try {
      await repository.saveVoter(event.data);

      emit(VoterSuccess());
    } catch (e) {
      emit(VoterError(e.toString()));
    }
  }

  Future<void> _fetchCount(
    FetchVoterCount event,
    Emitter<VoterState> emit,
  ) async {
    emit(VoterLoading());

    try {
      final response = await repository.getVoterCount();
      emit(VoterCountLoaded(response));
    } catch (e) {
      emit(VoterError(e.toString()));
    }
  }
}
