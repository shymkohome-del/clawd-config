import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crypto_market/features/auth/screens/login_screen.dart';
import 'package:crypto_market/features/auth/screens/register_screen.dart';
import 'package:crypto_market/features/auth/cubit/auth_cubit.dart';
import 'package:crypto_market/core/routing/protected_route.dart';

/// Main application router configuration
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const ProtectedRoute(child: HomeScreen()),
      ),
    ],
  );
}

/// Placeholder HomeScreen for protected route demonstration
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final user = state is AuthSuccess ? state.user : null;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Home'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  context.read<AuthCubit>().logout();
                  context.go('/login');
                },
              ),
            ],
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Welcome to the protected home screen!',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),
                const Text('You are successfully authenticated.'),
                if (user != null) ...[
                  const SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Email: ${user.email}'),
                          Text('Username: ${user.username}'),
                          if (user.id.isNotEmpty) Text('ID: ${user.id}'),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
