import 'package:crypto_market/core/blockchain/icp_service.dart';
import 'package:crypto_market/core/blockchain/errors.dart';
import 'package:crypto_market/features/auth/cubit/auth_cubit.dart';
import 'package:crypto_market/features/auth/providers/auth_service_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:crypto_market/l10n/app_localizations.dart';

class MockAuthService extends Mock implements AuthService {}

class MockICPService extends Mock implements ICPService {}

class TestAppWrapper extends StatelessWidget {
  final Widget child;
  final AuthService? mockAuthService;
  final bool includeRouter;
  final String? initialLocation;

  const TestAppWrapper({
    super.key,
    required this.child,
    this.mockAuthService,
    this.includeRouter = true,
    this.initialLocation = '/',
  });

  static GoRouter createTestRouter({
    String initialLocation = '/',
    required Widget Function(BuildContext, GoRouterState) homeBuilder,
    Widget Function(BuildContext, GoRouterState)? loginBuilder,
    Widget Function(BuildContext, GoRouterState)? registerBuilder,
  }) {
    return GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(path: '/', name: 'home', builder: homeBuilder),
        if (loginBuilder != null)
          GoRoute(path: '/login', name: 'login', builder: loginBuilder),
        if (registerBuilder != null)
          GoRoute(
            path: '/register',
            name: 'register',
            builder: registerBuilder,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final AuthService authService =
        mockAuthService ?? _createDefaultMockAuthService();

    Widget app = MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthService>(create: (context) => authService),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(
            create: (context) => AuthCubit(authService: authService),
          ),
        ],
        child: child,
      ),
    );

    if (includeRouter) {
      final router = createTestRouter(
        initialLocation: initialLocation ?? '/',
        homeBuilder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Home')),
          body: const Center(child: Text('Home')),
        ),
        loginBuilder: (context, state) => child,
        registerBuilder: (context, state) => child,
      );

      app = MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('lv')],
      );
    } else {
      app = MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('lv')],
        home: app,
      );
    }

    return app;
  }

  static AuthService _createDefaultMockAuthService() {
    final mockService = MockAuthService();

    // Setup default successful behaviors
    when(
      () => mockService.loginWithEmailPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer(
      (_) async => const Result.ok(
        User(
          id: 'test-user-id',
          email: 'test@example.com',
          username: 'testuser',
          authProvider: 'email',
          createdAtMillis: 1234567890,
        ),
      ),
    );

    when(
      () => mockService.register(
        email: any(named: 'email'),
        password: any(named: 'password'),
        username: any(named: 'username'),
      ),
    ).thenAnswer(
      (_) async => const Result.ok(
        User(
          id: 'test-user-id',
          email: 'test@example.com',
          username: 'testuser',
          authProvider: 'email',
          createdAtMillis: 1234567890,
        ),
      ),
    );

    when(
      () => mockService.loginWithOAuth(
        provider: any(named: 'provider'),
        token: any(named: 'token'),
      ),
    ).thenAnswer(
      (_) async => const Result.ok(
        User(
          id: 'test-user-id-oauth',
          email: 'test@gmail.com',
          username: 'testuser',
          authProvider: 'google',
          createdAtMillis: 1234567890,
        ),
      ),
    );

    when(() => mockService.logout()).thenAnswer((_) async {});

    when(() => mockService.getCurrentUser()).thenAnswer((_) async => null);

    return mockService;
  }
}
