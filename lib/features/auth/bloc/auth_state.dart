import 'package:equatable/equatable.dart';

import '../models/user_model.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthUserLoaded extends AuthState {
  final UserModel user;

  AuthUserLoaded(this.user);

  @override
  List<Object?> get props => [user];
}
