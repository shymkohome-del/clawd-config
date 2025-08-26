part of 'auth_cubit.dart';

abstract class AuthState {
  const AuthState();

  factory AuthState.initial() = AuthInitial;
  factory AuthState.submitting() = AuthSubmitting;
  factory AuthState.success(User user) = AuthSuccess;
  factory AuthState.failure(AuthError error) = AuthFailure;
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthSubmitting extends AuthState {
  const AuthSubmitting();
}

class AuthSuccess extends AuthState {
  const AuthSuccess(this.user);
  final User user;
}

class AuthFailure extends AuthState {
  const AuthFailure(this.error);
  final AuthError error;
}
