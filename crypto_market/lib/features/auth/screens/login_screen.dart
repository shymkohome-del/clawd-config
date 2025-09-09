import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:crypto_market/core/blockchain/errors.dart' as be;
import 'package:crypto_market/core/error/domain_errors.dart'
    as de
    show AuthError, NetworkError;
import 'package:crypto_market/core/logger/logger.dart';
import 'package:crypto_market/features/auth/cubit/auth_cubit.dart';
import 'package:crypto_market/l10n/app_localizations.dart';
import 'package:crypto_market/shared/widgets/error_dialog.dart';
import 'package:crypto_market/shared/widgets/success_snackbar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final l10n = AppLocalizations.of(context);
    if (value == null || value.isEmpty) {
      return l10n.emailRequired;
    }
    if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(value)) {
      return l10n.emailInvalid;
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final l10n = AppLocalizations.of(context);
    if (value == null || value.isEmpty) {
      return l10n.passwordRequired;
    }
    if (value.length < 8) {
      return l10n.passwordMinLength;
    }
    return null;
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() == true) {
      logger.logDebug(
        'Login pressed for ${_emailController.text.trim()}',
        tag: 'LoginScreen',
      );
      context.read<AuthCubit>().loginWithEmailPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }
  }

  void _handleOAuth(String provider) {
    // In a real implementation, this would integrate with OAuth providers
    // For demo purposes, we'll simulate with a mock token
    logger.logDebug('OAuth login pressed for $provider', tag: 'LoginScreen');
    final mockToken =
        '${provider}_mock_token_${DateTime.now().millisecondsSinceEpoch}';
    context.read<AuthCubit>().loginWithOAuth(
      provider: provider,
      token: mockToken,
    );
  }

  Future<void> _showErrorFor(be.AuthError error) async {
    switch (error) {
      case be.AuthError.network:
        await ErrorDialogHelper.showNetworkError(
          context,
          de.NetworkError.requestFailed(),
        );
        return;
      case be.AuthError.invalidCredentials:
        // Keep legacy text expected by tests for this specific case
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.errorInvalidCredentials)));
        return;
      case be.AuthError.oauthDenied:
        await ErrorDialogHelper.showAuthError(
          context,
          de.AuthError.loginFailed('OAuth sign-in denied'),
        );
        return;
      case be.AuthError.unknown:
        await ErrorDialogHelper.showAuthError(
          context,
          de.AuthError.loginFailed(),
        );
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.loginTitle), centerTitle: true),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            logger.logInfo('User authenticated', tag: 'LoginScreen');
            // Optional visual confirmation in dev UX
            SuccessSnackbar.showAuthSuccess(context);
            context.go('/home');
          } else if (state is AuthFailure) {
            logger.logWarn('Login failed: ${state.error}', tag: 'LoginScreen');
            // Show appropriate error dialog based on failure type
            unawaited(_showErrorFor(state.error));
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Email field
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: l10n.emailLabel,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Password field
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: l10n.passwordLabel,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: _validatePassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleLogin(),
                ),
                const SizedBox(height: 24),

                // Login button
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    final isLoading = state is AuthSubmitting;
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _handleLogin,
                        child: isLoading
                            ? const CircularProgressIndicator()
                            : Text(l10n.loginTitle),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Divider
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('OR'),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 16),

                // OAuth buttons
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _handleOAuth('google'),
                    icon: const Icon(Icons.g_mobiledata),
                    label: Text(l10n.continueWithGoogle),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _handleOAuth('apple'),
                    icon: const Icon(Icons.apple),
                    label: Text(l10n.continueWithApple),
                  ),
                ),
                const SizedBox(height: 24),

                // Register link
                TextButton(
                  onPressed: () => context.go('/register'),
                  child: Text(l10n.goToRegister),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
