import 'package:bloc/bloc.dart';
import 'package:crypto_market/core/blockchain/errors.dart';
import 'package:crypto_market/core/blockchain/icp_service.dart';
import 'package:crypto_market/core/logger/logger.dart';
import 'package:crypto_market/features/auth/providers/auth_service_provider.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required AuthService authService})
    : _authService = authService,
      super(AuthState.initial());

  final AuthService _authService;

  Future<void> register({
    required String email,
    required String password,
    required String username,
  }) async {
    if (state is AuthSubmitting) return;
    logger.logDebug('Registering user $email', tag: 'AuthCubit');
    emit(AuthState.submitting());
    final result = await _authService.register(
      email: email,
      password: password,
      username: username,
    );
    if (result.isOk) {
      logger.logDebug(
        'Registration success for ${result.ok.email}',
        tag: 'AuthCubit',
      );
      emit(AuthState.success(result.ok));
    } else {
      logger.logWarn('Registration failed: ${result.err}', tag: 'AuthCubit');
      emit(AuthState.failure(result.err));
    }
  }

  Future<void> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    if (state is AuthSubmitting) return;
    logger.logDebug('Login attempt for $email', tag: 'AuthCubit');
    emit(AuthState.submitting());
    final result = await _authService.loginWithEmailPassword(
      email: email,
      password: password,
    );
    if (result.isOk) {
      logger.logInfo('Login success for ${result.ok.email}', tag: 'AuthCubit');
      emit(AuthState.success(result.ok));
    } else {
      logger.logWarn('Login failed: ${result.err}', tag: 'AuthCubit');
      emit(AuthState.failure(result.err));
    }
  }

  Future<void> loginWithOAuth({
    required String provider,
    required String token,
  }) async {
    if (state is AuthSubmitting) return;
    logger.logDebug('OAuth login attempt for $provider', tag: 'AuthCubit');
    emit(AuthState.submitting());
    final result = await _authService.loginWithOAuth(
      provider: provider,
      token: token,
    );
    if (result.isOk) {
      logger.logInfo(
        'OAuth login success for ${result.ok.email}',
        tag: 'AuthCubit',
      );
      emit(AuthState.success(result.ok));
    } else {
      logger.logWarn('OAuth login failed: ${result.err}', tag: 'AuthCubit');
      emit(AuthState.failure(result.err));
    }
  }

  Future<void> logout() async {
    logger.logInfo('Logout initiated', tag: 'AuthCubit');
    await _authService.logout();
    emit(AuthState.initial());
  }

  Future<void> checkSession() async {
    logger.logDebug('Checking session', tag: 'AuthCubit');
    final user = await _authService.getCurrentUser();
    if (user != null) {
      logger.logDebug('Session active for ${user.email}', tag: 'AuthCubit');
      emit(AuthState.success(user));
    } else {
      logger.logDebug('No active session', tag: 'AuthCubit');
      emit(AuthState.initial());
    }
  }

  void reset() {
    emit(AuthState.initial());
  }
}
