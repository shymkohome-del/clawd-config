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
  } on AppConfigValidationError catch (e) {
    runApp(ConfigErrorApp(message: 'Missing required config: ${e.missingKey}'));
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
      home: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).configErrorTitle),
        ),
        body: Center(child: Text(message)),
      ),
    );
  }
}
