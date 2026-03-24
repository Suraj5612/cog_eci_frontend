import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());

      // temporary fake delay (replace with API later)
      await Future.delayed(const Duration(seconds: 1));

      emit(AuthAuthenticated());
    });
  }
}
