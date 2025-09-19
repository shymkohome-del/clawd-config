import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:crypto_market/core/blockchain/errors.dart';
import 'package:crypto_market/core/blockchain/icp_service.dart';
import 'package:crypto_market/core/auth/auth_error_handler.dart';
import 'package:crypto_market/features/auth/providers/auth_service_provider.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required AuthService authService,
    required GlobalKey<NavigatorState> navigatorKey,
  }) : _authService = authService,
       _errorHandler = AuthErrorHandler(navigatorKey: navigatorKey),
       super(AuthState.initial());

  final AuthService _authService;
  final AuthErrorHandler _errorHandler;

  Future<void> register({
    required String email,
    required String password,
    required String username,
  }) async {
    if (state is AuthSubmitting) return;
    emit(AuthState.submitting());
    final result = await _authService.register(
      email: email,
      password: password,
      username: username,
    );
    if (result.isOk) {
      emit(AuthState.success(result.ok));
    } else {
      _errorHandler.handleAuthError(result.err);
      emit(AuthState.failure(result.err));
    }
  }

  Future<void> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    if (state is AuthSubmitting) return;
    emit(AuthState.submitting());
    final result = await _authService.loginWithEmailPassword(
      email: email,
      password: password,
    );
    if (result.isOk) {
      emit(AuthState.success(result.ok));
    } else {
      _errorHandler.handleAuthError(result.err);
      emit(AuthState.failure(result.err));
    }
  }

  Future<void> loginWithOAuth({
    required String provider,
    required String token,
  }) async {
    if (state is AuthSubmitting) return;
    emit(AuthState.submitting());
    final result = await _authService.loginWithOAuth(
      provider: provider,
      token: token,
    );
    if (result.isOk) {
      emit(AuthState.success(result.ok));
    } else {
      _errorHandler.handleAuthError(result.err);
      emit(AuthState.failure(result.err));
    }
  }

  Future<void> signInWithGoogle() async {
    if (state is AuthSubmitting) return;
    emit(AuthState.submitting());
    final result = await _authService.signInWithGoogle();
    if (result.isOk) {
      emit(AuthState.success(result.ok));
    } else {
      _errorHandler.handleAuthError(result.err);
      emit(AuthState.failure(result.err));
    }
  }

  Future<void> signInWithFacebook() async {
    if (state is AuthSubmitting) return;
    emit(AuthState.submitting());
    final result = await _authService.signInWithFacebook();
    if (result.isOk) {
      emit(AuthState.success(result.ok));
    } else {
      _errorHandler.handleAuthError(result.err);
      emit(AuthState.failure(result.err));
    }
  }

  Future<void> signInWithApple() async {
    if (state is AuthSubmitting) return;
    emit(AuthState.submitting());
    final result = await _authService.signInWithApple();
    if (result.isOk) {
      emit(AuthState.success(result.ok));
    } else {
      _errorHandler.handleAuthError(result.err);
      emit(AuthState.failure(result.err));
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    emit(AuthState.initial());
  }

  Future<void> checkSession() async {
    final isAuthenticated = await _authService.isAuthenticated();
    if (isAuthenticated) {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        emit(AuthState.success(user));
      } else {
        emit(AuthState.initial());
      }
    } else {
      emit(AuthState.initial());
    }
  }

  void reset() {
    emit(AuthState.initial());
  }
}
