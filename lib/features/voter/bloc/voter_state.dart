import '../models/voter_model.dart';

abstract class VoterState {}

class VoterInitial extends VoterState {}

class VoterLoading extends VoterState {}

class VoterSuccess extends VoterState {}

class VoterCountLoaded extends VoterState {
  final int count;

  VoterCountLoaded(this.count);
}

class VoterListLoaded extends VoterState {
  final List<VoterModel> voters;

  VoterListLoaded(this.voters);
}

class VoterError extends VoterState {
  final String message;

  VoterError(this.message);
}
