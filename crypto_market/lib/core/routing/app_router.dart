import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crypto_market/features/auth/screens/login_screen.dart';
import 'package:crypto_market/features/auth/screens/register_screen.dart';
import 'package:crypto_market/features/market/cubit/create_listing_cubit.dart';
import 'package:crypto_market/features/market/cubit/search_listings_cubit.dart';
import 'package:crypto_market/features/market/providers/market_service_provider.dart';
import 'package:crypto_market/features/market/screens/create_listing_screen.dart';
import 'package:crypto_market/features/market/screens/search_screen.dart';
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
        builder: (context, state) => ProtectedRoute(
          child: BlocProvider(
            create: (context) => SearchListingsCubit(
              marketService: context.read<MarketServiceProvider>(),
            )..search(),
            child: const SearchScreen(),
          ),
        ),
      ),
      GoRoute(
        path: '/create-listing',
        name: 'create-listing',
        builder: (context, state) => ProtectedRoute(
          child: BlocProvider(
            create: (context) => CreateListingCubit(
              marketService: context.read<MarketServiceProvider>(),
            ),
            child: const CreateListingScreen(),
          ),
        ),
      ),
    ],
  );
}
