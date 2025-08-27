import 'package:flutter/material.dart';
import 'package:crypto_market/l10n/app_localizations.dart';
import 'package:crypto_market/core/config/app_config.dart';
import 'package:crypto_market/core/blockchain/icp_service.dart';
import 'package:crypto_market/features/auth/providers/auth_service_provider.dart';
import 'package:crypto_market/features/market/providers/market_service_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crypto_market/features/auth/screens/register_screen.dart'
    as auth_ui;
import 'package:crypto_market/features/auth/screens/login_screen.dart';
import 'package:crypto_market/features/auth/cubit/auth_cubit.dart';
import 'package:crypto_market/features/auth/cubit/profile_cubit.dart';
import 'package:crypto_market/features/auth/providers/user_service_provider.dart';
import 'package:crypto_market/core/i18n/locale_controller.dart';

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
        return MaterialApp(
          locale: locale,
          onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          ),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              if (state is AuthSuccess) {
                return HomeScreen(user: state.user);
              }
              return const LoginScreen();
            },
          ),
          routes: {
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const auth_ui.RegisterScreen(),
            '/home': (context) => const HomeScreen(),
          },
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

class HomeScreen extends StatelessWidget {
  final User? user;

  const HomeScreen({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthCubit>().logout();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(l10n.homeTitle),
            if (user != null) ...[
              const SizedBox(height: 16),
              Text('${l10n.email}: ${user!.email}'),
              Text('${l10n.username}: ${user!.username}'),
              if (user!.id.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Principal: ${user!.id}'),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
