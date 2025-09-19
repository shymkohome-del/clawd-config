import 'package:crypto_market/core/blockchain/errors.dart';
import 'package:crypto_market/features/auth/cubit/auth_cubit.dart';
import 'package:crypto_market/features/auth/providers/auth_service_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crypto_market/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreeToTerms = false;
  bool _isLoadingOAuth = false;
  String? _selectedOAuthProvider;

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
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onSubmit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).termsNotAccepted),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    context.read<AuthCubit>().register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      username: _usernameController.text.trim(),
    );
  }

  Future<void> _onOAuthSignIn(BuildContext context, String provider) async {
    if (_isLoadingOAuth) return;

    setState(() {
      _isLoadingOAuth = true;
      _selectedOAuthProvider = provider;
    });

    try {
      switch (provider) {
        case 'google':
          await context.read<AuthCubit>().signInWithGoogle();
          break;
        case 'facebook':
          await context.read<AuthCubit>().signInWithFacebook();
          break;
        case 'apple':
          await context.read<AuthCubit>().signInWithApple();
          break;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppLocalizations.of(context).oauthError}: $provider',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingOAuth = false;
          _selectedOAuthProvider = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>(
      create: (blocCtx) => AuthCubit(
        authService:
            widget.authServiceOverride ??
            RepositoryProvider.of<AuthService>(blocCtx),
        navigatorKey: GlobalKey<NavigatorState>(),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).registerTitle),
          centerTitle: true,
          elevation: 0,
        ),
        body: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) {
              context.go('/home');
            } else if (state is AuthFailure) {
              final message = _errorToMessage(state.error);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            final isSubmitting = state is AuthSubmitting;

            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Text(
                        AppLocalizations.of(context).createAccount,
                        style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        AppLocalizations.of(context).joinCryptoMarket,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 32.h),

                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context).emailLabel,
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
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
                      SizedBox(height: 16.h),

                      // Username Field
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context).usernameLabel,
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                        validator: (value) {
                          final v = value?.trim() ?? '';
                          if (v.isEmpty) {
                            return AppLocalizations.of(
                              context,
                            ).usernameRequired;
                          }
                          if (v.length < 3) {
                            return AppLocalizations.of(
                              context,
                            ).usernameMinLength;
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),

                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context).passwordLabel,
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                        obscureText: !_isPasswordVisible,
                        validator: (value) {
                          final v = value ?? '';
                          if (v.isEmpty) {
                            return AppLocalizations.of(
                              context,
                            ).passwordRequired;
                          }
                          if (v.length < 8) {
                            return AppLocalizations.of(
                              context,
                            ).passwordMinLength;
                          }
                          if (!v.contains(RegExp(r'[A-Z]'))) {
                            return AppLocalizations.of(
                              context,
                            ).passwordUppercase;
                          }
                          if (!v.contains(RegExp(r'[a-z]'))) {
                            return AppLocalizations.of(
                              context,
                            ).passwordLowercase;
                          }
                          if (!v.contains(RegExp(r'[0-9]'))) {
                            return AppLocalizations.of(context).passwordNumber;
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),

                      // Confirm Password Field
                      TextFormField(
                        controller: _confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(
                            context,
                          ).confirmPasswordLabel,
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmPasswordVisible
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
                              setState(() {
                                _isConfirmPasswordVisible =
                                    !_isConfirmPasswordVisible;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                        obscureText: !_isConfirmPasswordVisible,
                        validator: (value) {
                          final v = value ?? '';
                          if (v.isEmpty) {
                            return AppLocalizations.of(
                              context,
                            ).confirmPasswordRequired;
                          }
                          if (v != _passwordController.text) {
                            return AppLocalizations.of(
                              context,
                            ).passwordMismatch;
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),

                      // Terms and Conditions
                      Row(
                        children: [
                          Checkbox(
                            value: _agreeToTerms,
                            onChanged: (value) {
                              setState(() {
                                _agreeToTerms = value ?? false;
                              });
                            },
                          ),
                          Expanded(
                            child: Text(
                              AppLocalizations.of(context).agreeToTerms,
                              style: TextStyle(fontSize: 14.sp),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),

                      // Register Button
                      ElevatedButton(
                        onPressed: isSubmitting
                            ? null
                            : () => _onSubmit(context),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                AppLocalizations.of(context).createAccount,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                      SizedBox(height: 32.h),

                      // OAuth Section
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              thickness: 1,
                              color: Colors.grey[300],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: Text(
                              AppLocalizations.of(context).orContinueWith,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              thickness: 1,
                              color: Colors.grey[300],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),

                      // Google Sign In
                      ElevatedButton.icon(
                        onPressed:
                            _isLoadingOAuth &&
                                _selectedOAuthProvider == 'google'
                            ? null
                            : () => _onOAuthSignIn(context, 'google'),
                        icon:
                            _isLoadingOAuth &&
                                _selectedOAuthProvider == 'google'
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.login, color: Colors.white),
                        label: Text(
                          AppLocalizations.of(context).continueWithGoogle,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),

                      // Apple Sign In
                      ElevatedButton.icon(
                        onPressed:
                            _isLoadingOAuth && _selectedOAuthProvider == 'apple'
                            ? null
                            : () => _onOAuthSignIn(context, 'apple'),
                        icon:
                            _isLoadingOAuth && _selectedOAuthProvider == 'apple'
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.apple, color: Colors.white),
                        label: Text(
                          AppLocalizations.of(context).continueWithApple,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),

                      // Facebook Sign In
                      ElevatedButton.icon(
                        onPressed:
                            _isLoadingOAuth &&
                                _selectedOAuthProvider == 'facebook'
                            ? null
                            : () => _onOAuthSignIn(context, 'facebook'),
                        icon:
                            _isLoadingOAuth &&
                                _selectedOAuthProvider == 'facebook'
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.facebook, color: Colors.white),
                        label: Text(
                          AppLocalizations.of(context).continueWithFacebook,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),

                      // Login Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppLocalizations.of(context).alreadyHaveAccount,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              context.go('/login');
                            },
                            child: Text(
                              AppLocalizations.of(context).login,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
