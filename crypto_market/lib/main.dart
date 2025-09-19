import 'package:flutter/material.dart';
import 'package:crypto_market/l10n/app_localizations.dart';
import 'package:crypto_market/core/config/app_config.dart';
import 'package:crypto_market/core/blockchain/icp_service.dart';
import 'package:crypto_market/features/auth/providers/auth_service_provider.dart';
import 'package:crypto_market/features/market/providers/market_service_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crypto_market/features/auth/cubit/auth_cubit.dart';
import 'package:crypto_market/features/auth/cubit/profile_cubit.dart';
import 'package:crypto_market/features/auth/providers/user_service_provider.dart';
import 'package:crypto_market/core/i18n/locale_controller.dart';
import 'package:crypto_market/core/routing/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final config = AppConfig.load();
    final icpService = ICPService.fromConfig(config);
    runApp(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<AuthService>(
            create: (_) => AuthServiceProvider(icpService),
          ),
          RepositoryProvider<MarketServiceProvider>(
            create: (_) => MarketServiceProvider(icpService),
          ),
          RepositoryProvider<UserServiceProvider>(
            create: (_) => UserServiceProvider(icpService),
          ),
          RepositoryProvider<LocaleController>(
            create: (_) => LocaleController(),
          ),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<AuthCubit>(
              create: (context) => AuthCubit(
                authService: RepositoryProvider.of<AuthService>(context),
                navigatorKey: GlobalKey<NavigatorState>(),
              )..checkSession(), // Check for existing session on app start
            ),
            BlocProvider<ProfileCubit>(
              create: (context) => ProfileCubit(
                RepositoryProvider.of<UserServiceProvider>(context),
              ),
            ),
          ],
          child: const MyApp(),
        ),
      ),
    );
  } on AppConfigValidationError catch (_) {
    // For testing purposes, create a minimal config to test navigation
    final testConfig = AppConfig.tryLoad(
      defines: {
        'OAUTH_GOOGLE_CLIENT_ID': 'test_client_id',
        'OAUTH_GOOGLE_CLIENT_SECRET': 'test_client_secret',
        'OAUTH_APPLE_TEAM_ID': 'test_team_id',
        'OAUTH_APPLE_KEY_ID': 'test_key_id',
        'IPFS_NODE_URL': 'https://ipfs.io',
        'IPFS_GATEWAY_URL': 'https://ipfs.io',
        'CANISTER_ID_MARKETPLACE': 'test_marketplace_id',
        'CANISTER_ID_USER_MANAGEMENT': 'test_user_management_id',
        'CANISTER_ID_ATOMIC_SWAP': 'test_atomic_swap_id',
        'CANISTER_ID_PRICE_ORACLE': 'test_price_oracle_id',
      },
    );
    final icpService = ICPService.fromConfig(testConfig);
    runApp(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<AuthService>(
            create: (_) => AuthServiceProvider(icpService),
          ),
          RepositoryProvider<MarketServiceProvider>(
            create: (_) => MarketServiceProvider(icpService),
          ),
          RepositoryProvider<UserServiceProvider>(
            create: (_) => UserServiceProvider(icpService),
          ),
          RepositoryProvider<LocaleController>(
            create: (_) => LocaleController(),
          ),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<AuthCubit>(
              create: (context) => AuthCubit(
                authService: RepositoryProvider.of<AuthService>(context),
                navigatorKey: GlobalKey<NavigatorState>(),
              ),
            ),
            BlocProvider<ProfileCubit>(
              create: (context) => ProfileCubit(
                RepositoryProvider.of<UserServiceProvider>(context),
              ),
            ),
          ],
          child: const MyApp(),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeController = RepositoryProvider.of<LocaleController>(context);
    return ValueListenableBuilder<Locale?>(
      valueListenable: localeController.listenable,
      builder: (context, locale, _) {
        return MaterialApp.router(
          routerConfig: AppRouter.router,
          locale: locale,
          onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          ),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        );
      },
    );
  }
}

class ConfigErrorApp extends StatelessWidget {
  const ConfigErrorApp({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).configErrorTitle),
        ),
        body: Center(child: Text(message)),
      ),
    );
  }
}
