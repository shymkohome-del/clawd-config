# **Frontend Architecture**

## **Flutter App Structure**

```
crypto_marketplace/
├── lib/
│   ├── core/                    # Core services
│   │   ├── blockchain/          # ICP integration
│   │   │   ├── icp_service.dart
│   │   │   ├── canister_client.dart
│   │   │   └── auth_service.dart
│   │   ├── wallet/              # Wallet management
│   │   │   ├── wallet_service.dart
│   │   │   └── crypto_service.dart
│   │   ├── models/              # Data models
│   │   │   ├── user.dart
│   │   │   ├── listing.dart
│   │   │   └── atomic_swap.dart
│   │   └── utils/               # Utilities
│   │       ├── formatters.dart
│   │       ├── validators.dart
│   │       └── constants.dart
│   ├── features/                # Feature modules
│   │   ├── auth/               # Authentication
│   │   │   ├── screens/
│   │   │   │   ├── login_screen.dart
│   │   │   │   ├── register_screen.dart
│   │   │   │   └── profile_screen.dart
│   │   │   ├── widgets/
│   │   │   │   ├── auth_form.dart
│   │   │   │   └── profile_header.dart
│   │   │   └── providers/
│   │   │       └── auth_provider.dart
│   │   ├── marketplace/        # Marketplace
│   │   │   ├── screens/
│   │   │   │   ├── home_screen.dart
│   │   │   │   ├── listing_detail_screen.dart
│   │   │   │   └── create_listing_screen.dart
│   │   │   ├── widgets/
│   │   │   │   ├── listing_card.dart
│   │   │   │   ├── search_bar.dart
│   │   │   │   └── filter_chip.dart
│   │   │   └── providers/
│   │   │       └── marketplace_provider.dart
│   │   ├── trading/           # Trading/Atomic Swaps
│   │   │   ├── screens/
│   │   │   │   ├── swap_screen.dart
│   │   │   │   ├── swap_detail_screen.dart
│   │   │   │   └── dispute_screen.dart
│   │   │   ├── widgets/
│   │   │   │   ├── swap_progress.dart
│   │   │   │   └── secret_input.dart
│   │   │   └── providers/
│   │   │       └── trading_provider.dart
│   │   └── messaging/          # Messaging
│   │       ├── screens/
│   │       │   ├── chat_screen.dart
│   │       │   └── conversation_list_screen.dart
│   │       ├── widgets/
│   │       │   ├── message_bubble.dart
│   │       │   └── chat_input.dart
│   │       └── providers/
│   │           └── messaging_provider.dart
│   ├── shared/                  # Shared components
│   │   ├── widgets/             # Reusable UI
│   │   │   ├── loading_overlay.dart
│   │   │   ├── error_dialog.dart
│   │   │   └── success_snackbar.dart
│   │   ├── theme/               # App theme
│   │   │   ├── app_theme.dart
│   │   │   └── colors.dart
│   │   └── localization/        # Internationalization
│   │       └── app_localizations.dart
│   └── main.dart               # App entry point
├── assets/                      # App assets
│   ├── images/
│   ├── icons/
│   └── fonts/
├── android/                     # Android build configuration
├── ios/                         # iOS build configuration
├── pubspec.yaml                 # Dependencies
└── README.md
```

## **State Management Architecture**

**State Structure:**
```dart
// Global app state
class AppState {
  final User? currentUser;
  final bool isLoading;
  final String? error;
  final ThemeMode themeMode;
  final Locale locale;
  
  const AppState({
    this.currentUser,
    this.isLoading = false,
    this.error,
    this.themeMode = ThemeMode.system,
    this.locale = const Locale('en'),
  });
  
  AppState copyWith({
    User? currentUser,
    bool? isLoading,
    String? error,
    ThemeMode? themeMode,
    Locale? locale,
  }) {
    return AppState(
      currentUser: currentUser ?? this.currentUser,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
    );
  }
}

// Authentication state
class AuthState {
  final User? user;
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;
  
  const AuthState({
    this.user,
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
  });
  
  AuthState copyWith({
    User? user,
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
```

**State Management Patterns:**
- **Bloc/Cubit**: Event/state management with unidirectional data flow
- **RepositoryProvider**: Dependency injection via flutter_bloc
- **BlocProvider/BlocBuilder/BlocListener**: UI integration patterns
- **Cubit**: Lightweight state containers for simple flows

## **Routing Architecture**

**Route Organization:**
```dart
// App routes
final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
      routes: [
        GoRoute(
          path: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: 'register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: 'profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: 'listing/:id',
          builder: (context, state) => ListingDetailScreen(
            listingId: int.parse(state.pathParameters['id']!),
          ),
        ),
        GoRoute(
          path: 'create-listing',
          builder: (context, state) => const CreateListingScreen(),
        ),
        GoRoute(
          path: 'swap/:id',
          builder: (context, state) => SwapDetailScreen(
            swapId: int.parse(state.pathParameters['id']!),
          ),
        ),
        GoRoute(
          path: 'chat/:userId',
          builder: (context, state) => ChatScreen(
            userId: state.pathParameters['userId']!,
          ),
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => const ErrorScreen(),
);
```

**Protected Route Pattern:**
```dart
class ProtectedRoute extends StatelessWidget {
  final Widget child;
  
  const ProtectedRoute({required this.child, super.key});
  
  @override
  Widget build(BuildContext context) {
    final authState = context.select((AuthCubit c) => c.state);
    
    if (authState.isLoading) {
      return const LoadingScreen();
    }
    
    if (!authState.isAuthenticated) {
      return const LoginScreen();
    }
    
    return child;
  }
}
```

## **Frontend Services Layer**

**ICP Client Setup:**
```dart
class ICPService {
  late final HttpClient _httpClient;
  late final AuthProvider _authProvider;
  
  // Canister clients
  late final Actor _marketplaceActor;
  late final Actor _userManagementActor;
  late final Actor _atomicSwapActor;
  late final Actor _priceOracleActor;
  
  ICPService(this._authProvider) {
    _httpClient = HttpClient();
    _initializeActors();
  }
  
  Future<void> _initializeActors() async {
    final canisterIds = await _loadCanisterIds();
    
    // Initialize marketplace actor
    _marketplaceActor = Actor(
      canisterId: canisterIds['marketplace']!,
      interfaceFactory: marketplaceFactory,
    );
    
    // Initialize other actors...
  }
  
  Future<Map<String, String>> _loadCanisterIds() async {
    // Load canister IDs from local config or ICP network
    return {
      'marketplace': 'rrkah-fqaaa-aaaaa-aaaaq-cai',
      'user_management': 'ryjl3-tyaaa-aaaaa-aaaba-cai',
      'atomic_swap': 'r7inp-6aaaa-aaaaa-aaabq-cai',
      'price_oracle': 'rkp4c-7iaaa-aaaaa-aaaca-cai',
    };
  }
}
```

**Service Example:**
```dart
class MarketplaceService {
  final ICPService _icpService;
  final Ref _ref;
  
  MarketplaceService(this._icpService, this._ref);
  
  Future<Listing> createListing({
    required String title,
    required String description,
    required BigInt priceUSD,
    required String cryptoType,
    required List<String> images,
    required String category,
    required String condition,
    required String location,
    required List<String> shippingOptions,
  }) async {
    try {
      final result = await _icpService.marketplaceActor.createListing(
        title,
        description,
        priceUSD,
        cryptoType,
        images,
        category,
        condition,
        location,
        shippingOptions,
      );
      
      if (result.err != null) {
        throw Exception(result.err);
      }
      
      return _mapListingFromResponse(result.ok);
    } catch (e) {
      throw Exception('Failed to create listing: $e');
    }
  }
  
  Future<List<Listing>> getListings({
    String? query,
    String? category,
    BigInt? minPrice,
    BigInt? maxPrice,
    int? limit,
  }) async {
    try {
      final result = await _icpService.marketplaceActor.getListings(
        query,
        category,
        minPrice,
        maxPrice,
        limit,
      );
      
      return result.map(_mapListingFromResponse).toList();
    } catch (e) {
      throw Exception('Failed to get listings: $e');
    }
  }
  
  Listing _mapListingFromResponse(Map<String, dynamic> response) {
    return Listing(
      id: response['id'],
      seller: Principal.fromText(response['seller']),
      title: response['title'],
      description: response['description'],
      priceUSD: response['priceUSD'],
      cryptoType: response['cryptoType'],
      images: List<String>.from(response['images']),
      category: response['category'],
      condition: response['condition'],
      location: response['location'],
      shippingOptions: List<String>.from(response['shippingOptions']),
      status: response['status'],
      createdAt: response['createdAt'],
      updatedAt: response['updatedAt'],
    );
  }
}
```
