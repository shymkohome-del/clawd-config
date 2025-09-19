import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crypto_market/features/auth/screens/login_screen.dart';
import 'package:crypto_market/features/auth/screens/register_screen.dart';
import 'package:crypto_market/features/auth/providers/user_service_provider.dart';
import 'package:crypto_market/features/market/cubit/create_listing_cubit.dart';
import 'package:crypto_market/features/market/cubit/listing_detail_cubit.dart';
import 'package:crypto_market/features/market/cubit/search_listings_cubit.dart';
import 'package:crypto_market/features/market/providers/market_service_provider.dart';
import 'package:crypto_market/features/market/screens/create_listing_screen.dart';
import 'package:crypto_market/features/market/screens/listing_detail_screen.dart';
import 'package:crypto_market/features/market/screens/search_screen.dart';
import 'package:crypto_market/features/market/screens/buy_listing_screen.dart';
import 'package:crypto_market/features/market/models/listing.dart';
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
      GoRoute(
        path: '/listing/:id',
        name: 'listing-detail',
        builder: (context, state) => ProtectedRoute(
          child: BlocProvider(
            create: (context) => ListingDetailCubit(
              marketService: context.read<MarketServiceProvider>(),
              userService: context.read<UserServiceProvider>(),
            ),
            child: ListingDetailScreen(listingId: state.pathParameters['id']!),
          ),
        ),
      ),
      GoRoute(
        path: '/buy/:listingId',
        name: 'buy-listing',
        builder: (context, state) {
          // For now, we'll pass the listing data through the route
          // In a real app, you might want to fetch the listing data here
          final listingId = state.pathParameters['listingId']!;
          return ProtectedRoute(
            child: BuyListingScreen(
              listing: Listing(
                id: listingId,
                seller: 'mock-seller',
                title: 'Mock Listing',
                description: 'Mock description',
                priceUSD: 100,
                cryptoType: 'BTC',
                images: [],
                category: 'Electronics',
                condition: ListingCondition.newCondition,
                location: 'Mock Location',
                shippingOptions: ['shipping'],
                status: ListingStatus.active,
                createdAt: DateTime.now().millisecondsSinceEpoch,
                updatedAt: DateTime.now().millisecondsSinceEpoch,
              ),
            ),
          );
        },
      ),
    ],
  );
}
