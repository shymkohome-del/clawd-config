import 'package:flutter/material.dart';
import 'package:crypto_market/core/config/app_config.dart';
import 'package:crypto_market/core/blockchain/icp_service.dart';
import 'package:crypto_market/features/auth/providers/auth_service_provider.dart';
import 'package:crypto_market/features/market/providers/market_service_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final config = AppConfig.load();
    final icpService = ICPService.fromConfig(config);
    AuthServiceProvider.icpService = icpService;
    MarketServiceProvider.icpService = icpService;
    runApp(const MyApp());
  } on AppConfigValidationError catch (e) {
    runApp(ConfigErrorApp(message: 'Missing required config: ${e.missingKey}'));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crypto Market',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
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
        appBar: AppBar(title: const Text('Configuration Error')), 
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
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Login Screen (placeholder)'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              child: const Text('Go to Register'),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Register Screen (placeholder)'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/home'),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: const Center(child: Text('Home Screen (placeholder)')),
    );
  }
}
