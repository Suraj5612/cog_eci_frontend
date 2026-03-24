import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/storage_service.dart';
import '../models/user_model.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../repository/auth_repository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;

  AuthBloc(this.repository) : super(AuthInitial()) {
    on<LoginRequested>(_onLogin);
    on<CheckAuthStatus>(_onCheckAuth);
    on<FetchProfile>(_onFetchProfile);
  }

  Future<void> _onLogin(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      final res = await repository.login(
        username: event.username,
        password: event.password,
      );

      if (res['success']) {
        final token = res['data']['token'];

        await StorageService.saveToken(token);

        emit(AuthAuthenticated());
      } else {
        emit(AuthError(res['message']));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onCheckAuth(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    final token = await StorageService.getToken();

    if (token != null) {
      emit(AuthAuthenticated());
    } else {
      emit(AuthInitial());
    }
  }

  Future<void> _onFetchProfile(
    FetchProfile event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final UserModel user = await repository.getProfile();

      emit(AuthUserLoaded(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
