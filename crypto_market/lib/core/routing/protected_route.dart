import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crypto_market/features/auth/cubit/auth_cubit.dart';
import 'package:crypto_market/features/auth/screens/login_screen.dart';

/// A widget that protects routes by redirecting unauthenticated users to login
class ProtectedRoute extends StatelessWidget {
  const ProtectedRoute({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        // Show loading spinner while submitting auth request
        if (state is AuthSubmitting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Redirect to login if not authenticated
        if (state is! AuthSuccess) {
          return const LoginScreen();
        }

        // User is authenticated, show the protected content
        return child;
      },
    );
  }
}
