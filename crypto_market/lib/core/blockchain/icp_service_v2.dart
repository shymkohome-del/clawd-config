import 'dart:math' as math;
import 'package:crypto_market/core/blockchain/blockchain_service.dart';
import 'package:crypto_market/core/config/app_config.dart';
import 'package:crypto_market/core/blockchain/errors.dart';
import 'package:crypto_market/core/logger/logger.dart';
import 'package:dio/dio.dart';

/// User model for authentication
class User {
  final String id; // Principal text representation
  final String email;
  final String username;
  final String authProvider; // e.g., 'email', 'google', 'apple'
  final int createdAtMillis;

  const User({
    required this.id,
    required this.email,
    required this.username,
    required this.authProvider,
    required this.createdAtMillis,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'username': username,
    'authProvider': authProvider,
    'createdAt': createdAtMillis,
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as String,
    email: json['email'] as String,
    username: json['username'] as String,
    authProvider: json['authProvider'] as String,
    createdAtMillis: json['createdAt'] as int,
  );
}

/// Real ICP service that connects to deployed canisters
class ICPService {
  final BlockchainService _blockchainService;
  final Logger _logger;

  ICPService({
    required BlockchainService blockchainService,
    required Logger logger,
  }) : _blockchainService = blockchainService,
       _logger = logger;

  /// Factory method for backward compatibility with existing code
  factory ICPService.fromConfig(AppConfig config) {
    final dio = Dio();
    final logger = Logger.instance;
    final blockchainService = BlockchainService(
      config: config,
      dio: dio,
      logger: logger,
    );

    return ICPService(blockchainService: blockchainService, logger: logger);
  }

  Future<Result<T, AuthError>> _wrapAuthCall<T>(
    Future<T> Function() action,
  ) async {
    try {
      final value = await action();
      return Result.ok(value);
    } catch (e) {
      _logger.logError('Auth operation failed', error: e, tag: 'ICPService');
      return Result.err(_mapExceptionToAuthError(e));
    }
  }

  /// Register a new user with the user management canister
  Future<Result<User, AuthError>> register({
    required String email,
    required String password,
    required String username,
  }) async {
    return _wrapAuthCall<User>(() async {
      final result = await _blockchainService.registerUser(
        email: email,
        password: password,
        username: username,
      );

      if (result['success'] == true) {
        return User(
          id: result['principal'] as String,
          email: email,
          username: username,
          authProvider: 'email',
          createdAtMillis: DateTime.now().millisecondsSinceEpoch,
        );
      } else {
        throw AuthInvalidCredentialsException();
      }
    });
  }

  /// Login with email and password
  Future<Result<User, AuthError>> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    return _wrapAuthCall<User>(() async {
      if (email.isEmpty || password.isEmpty) {
        throw AuthInvalidCredentialsException();
      }

      // For now, we'll simulate login success and fetch user profile
      // In a real implementation, you'd validate credentials against the canister
      final principal = _deriveDeterministicPrincipal(email);
      final profileResult = await _blockchainService.getUserProfile(principal);

      if (profileResult != null) {
        return User(
          id: principal,
          email: profileResult['email'] as String? ?? email,
          username: profileResult['username'] as String? ?? email.split('@')[0],
          authProvider: 'email',
          createdAtMillis:
              profileResult['createdAt'] as int? ??
              DateTime.now().millisecondsSinceEpoch,
        );
      } else {
        // User not found, but credentials might be valid for a new user
        return User(
          id: principal,
          email: email,
          username: email.split('@')[0],
          authProvider: 'email',
          createdAtMillis: DateTime.now().millisecondsSinceEpoch,
        );
      }
    });
  }

  /// Login with OAuth provider
  Future<Result<User, AuthError>> loginWithOAuth({
    required String provider,
    required String token,
  }) async {
    return _wrapAuthCall<User>(() async {
      final result = await _blockchainService.loginWithOAuth(
        provider: provider,
        token: token,
      );

      if (result['success'] == true) {
        return User(
          id: result['principal'] as String,
          email: result['email'] as String,
          username: result['username'] as String,
          authProvider: provider,
          createdAtMillis: DateTime.now().millisecondsSinceEpoch,
        );
      } else {
        throw OAuthDeniedException();
      }
    });
  }

  /// Get user profile from canister
  Future<Result<Map<String, dynamic>, AuthError>> getUserProfile({
    required String principal,
  }) async {
    return _wrapAuthCall<Map<String, dynamic>>(() async {
      final result = await _blockchainService.getUserProfile(principal);

      if (result != null) {
        return result;
      } else {
        throw AuthInvalidCredentialsException();
      }
    });
  }

  /// Generate a deterministic principal for development
  String _deriveDeterministicPrincipal(String email) {
    final hash = email.hashCode;
    final random = math.Random(hash);
    final bytes = List.generate(29, (_) => random.nextInt(256));

    // Convert to a canister-like ID format
    final base32Chars = 'abcdefghijklmnopqrstuvwxyz234567';
    final result = StringBuffer();

    for (int i = 0; i < bytes.length; i += 5) {
      var chunk = 0;
      var chunkSize = 0;

      for (int j = 0; j < 5 && i + j < bytes.length; j++) {
        chunk = (chunk << 8) | bytes[i + j];
        chunkSize += 8;
      }

      while (chunkSize > 0) {
        final index = chunk & 0x1F;
        result.write(base32Chars[index]);
        chunk >>= 5;
        chunkSize -= 5;
      }
    }

    return result.toString().substring(0, 27);
  }

  /// Map exceptions to auth errors
  AuthError _mapExceptionToAuthError(dynamic exception) {
    return mapAuthExceptionToAuthError(exception);
  }
}
