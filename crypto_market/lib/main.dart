import 'package:flutter/material.dart';
import 'package:crypto_market/l10n/app_localizations.dart';
import 'package:crypto_market/core/config/app_config.dart';
import 'package:crypto_market/core/blockchain/icp_service.dart';
import 'package:crypto_market/features/auth/providers/auth_service_provider.dart';
import 'package:crypto_market/features/market/providers/market_service_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crypto_market/features/auth/screens/register_screen.dart'
    as auth_ui;
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
          RepositoryProvider<LocaleController>(
            create: (_) => LocaleController(),
          ),
        ],
        child: const MyApp(),
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
          initialRoute: '/login',
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

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).loginTitle),
        actions: [
          PopupMenuButton<Locale?>(
            icon: const Icon(Icons.language),
            onSelected: (locale) => RepositoryProvider.of<LocaleController>(
              context,
            ).setLocale(locale),
            itemBuilder: (context) => [
              PopupMenuItem<Locale?>(
                value: const Locale('en'),
                child: Text(AppLocalizations.of(context).languageEnglish),
              ),
              PopupMenuItem<Locale?>(
                value: const Locale('lv'),
                child: Text(AppLocalizations.of(context).languageLatvian),
              ),
              PopupMenuItem<Locale?>(
                value: null,
                child: Text(AppLocalizations.of(context).languageSystem),
              ),
            ],
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Login Screen (placeholder)'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              child: Text(AppLocalizations.of(context).goToRegister),
            ),
          ],
        ),
      ),
    );
  }
}

// Register screen moved to features/auth/screens/register_screen.dart

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    String? principal;
    if (args is User) {
      principal = args.id.isNotEmpty ? args.id : null;
    }
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).homeTitle)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Home Screen (placeholder)'),
            if (principal != null) ...[
              const SizedBox(height: 12),
              Text('Principal: $principal'),
            ],
          ],
        ),
      ),
    );
  }
}
