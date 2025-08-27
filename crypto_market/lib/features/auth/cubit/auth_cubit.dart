import 'package:bloc/bloc.dart';
import 'package:crypto_market/core/blockchain/errors.dart';
import 'package:crypto_market/core/blockchain/icp_service.dart';
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
    emit(AuthState.submitting());
    final result = await _authService.register(
      email: email,
      password: password,
      username: username,
    );
    if (result.isOk) {
      emit(AuthState.success(result.ok));
    } else {
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
      emit(AuthState.failure(result.err));
    }
  }

  void reset() {
    emit(AuthState.initial());
  }
}
