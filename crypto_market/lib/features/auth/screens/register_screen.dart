import 'package:crypto_market/core/blockchain/errors.dart';
import 'package:crypto_market/features/auth/cubit/auth_cubit.dart';
import 'package:crypto_market/features/auth/providers/auth_service_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crypto_market/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, this.authServiceOverride});

  final AuthService? authServiceOverride;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void _onSubmit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      username: _usernameController.text.trim(),
    );
  }

  String _errorToMessage(AuthError error) {
    switch (error) {
      case AuthError.invalidCredentials:
        return AppLocalizations.of(context).errorInvalidCredentials;
      case AuthError.oauthDenied:
        return AppLocalizations.of(context).errorOAuthDenied;
      case AuthError.network:
        return AppLocalizations.of(context).errorNetwork;
      case AuthError.unknown:
        return AppLocalizations.of(context).errorUnknown;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>(
      create: (blocCtx) => AuthCubit(
        authService:
            widget.authServiceOverride ??
            RepositoryProvider.of<AuthService>(blocCtx),
      ),
      child: Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context).registerTitle)),
        body: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) {
              context.go('/home');
            } else if (state is AuthFailure) {
              final message = _errorToMessage(state.error);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(message)));
            }
          },
          builder: (context, state) {
            final isSubmitting = state is AuthSubmitting;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context).emailLabel,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        final v = value?.trim() ?? '';
                        if (v.isEmpty) {
                          return AppLocalizations.of(context).emailRequired;
                        }
                        final emailRegex = RegExp(
                          r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                        );
                        if (!emailRegex.hasMatch(v)) {
                          return AppLocalizations.of(context).emailInvalid;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context).usernameLabel,
                      ),
                      validator: (value) {
                        final v = value?.trim() ?? '';
                        if (v.isEmpty) {
                          return AppLocalizations.of(context).usernameRequired;
                        }
                        if (v.length < 3) {
                          return AppLocalizations.of(context).usernameMinLength;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context).passwordLabel,
                      ),
                      obscureText: true,
                      validator: (value) {
                        final v = value ?? '';
                        if (v.isEmpty) {
                          return AppLocalizations.of(context).passwordRequired;
                        }
                        if (v.length < 8) {
                          return AppLocalizations.of(context).passwordMinLength;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: isSubmitting ? null : () => _onSubmit(context),
                      child: isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(AppLocalizations.of(context).createAccount),
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: isSubmitting
                          ? null
                          : () {
                              context.read<AuthCubit>().loginWithOAuth(
                                provider: 'google',
                                token: 'token-placeholder',
                              );
                            },
                      icon: const Icon(Icons.login),
                      label: Text(
                        AppLocalizations.of(context).continueWithGoogle,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: isSubmitting
                          ? null
                          : () {
                              context.read<AuthCubit>().loginWithOAuth(
                                provider: 'apple',
                                token: 'token-placeholder',
                              );
                            },
                      icon: const Icon(Icons.apple),
                      label: Text(
                        AppLocalizations.of(context).continueWithApple,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
