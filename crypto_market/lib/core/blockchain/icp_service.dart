import 'dart:async';
import 'errors.dart' hide Result;
import 'package:crypto_market/core/config/app_config.dart';
import 'package:crypto_market/core/logger/logger.dart';
import 'package:crypto_market/core/auth/secure_storage_service.dart';
import 'package:crypto_market/core/auth/jwt_service.dart';
import 'package:bcrypt/bcrypt.dart';

// Import ICP agent library (if available)
// For now, we'll implement a simple HTTP-based approach
// that can be easily replaced with proper ICP agent later

class User {
  final String id; // Principal text repr in shim mode
  final String email;
  final String username;
  final String authProvider; // e.g., 'email', 'google', 'apple'
  final int createdAtMillis;
  final String? principalId;
  final bool isVerified;
  final List<String> roles;
  final Map<String, dynamic> metadata;

  const User({
    required this.id,
    required this.email,
    required this.username,
    required this.authProvider,
    required this.createdAtMillis,
    this.principalId,
    this.isVerified = false,
    this.roles = const [],
    this.metadata = const {},
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      email: map['email'] as String,
      username: map['username'] as String,
      authProvider: map['authProvider'] as String,
      createdAtMillis: map['createdAt'] as int,
      principalId: map['principalId'] as String?,
      isVerified: map['isVerified'] as bool? ?? false,
      roles: List<String>.from(map['roles'] ?? []),
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'username': username,
    'authProvider': authProvider,
    'createdAt': createdAtMillis,
    'principalId': principalId,
    'isVerified': isVerified,
    'roles': roles,
    'metadata': metadata,
  };

  User copyWith({
    String? id,
    String? email,
    String? username,
    String? authProvider,
    int? createdAtMillis,
    String? principalId,
    bool? isVerified,
    List<String>? roles,
    Map<String, dynamic>? metadata,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      authProvider: authProvider ?? this.authProvider,
      createdAtMillis: createdAtMillis ?? this.createdAtMillis,
      principalId: principalId ?? this.principalId,
      isVerified: isVerified ?? this.isVerified,
      roles: roles ?? this.roles,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          username == other.username &&
          authProvider == other.authProvider &&
          createdAtMillis == other.createdAtMillis;

  @override
  int get hashCode =>
      id.hashCode ^
      email.hashCode ^
      username.hashCode ^
      authProvider.hashCode ^
      createdAtMillis.hashCode;
}

/// Enhanced ICPService with real canister integration
class ICPService {
  final AppConfig config;
  final String _userManagementCanisterId;
  final SecureStorageService _secureStorage;
  final JWTService _jwtService;

  ICPService._(
    this.config,
    this._userManagementCanisterId,
    this._secureStorage,
    this._jwtService,
  );

  factory ICPService.fromConfig(AppConfig config) {
    final userMgmtCanisterId = config.canisterIdUserManagement;
    final secureStorage = SecureStorageService();
    final jwtService = JWTService();

    Logger.instance.logInfo(
      'Initializing ICPService with canister: $userMgmtCanisterId',
      tag: 'ICPService',
    );

    // HTTP client will be initialized when needed for real canister calls
    return ICPService._(config, userMgmtCanisterId, secureStorage, jwtService);
  }

  String get userManagementCanisterId => _userManagementCanisterId;

  // Helper method to make canister calls via HTTP
  Future<Map<String, dynamic>> _callCanister({
    required String method,
    required List<dynamic> args,
  }) async {
    try {
      // In a real implementation, this would use the ICP agent library
      // For now, we'll simulate the call but with real canister ID

      Logger.instance.logDebug(
        'Calling canister method: $method with args: $args',
        tag: 'ICPService',
      );

      // TODO: Replace with actual ICP agent call when library is available
      // For now, use the existing logic but with better error handling
      if (config.featurePrincipalShim) {
        // Simulate canister response with deterministic principal
        final email = args[0] as String;
        final principal = _deriveDeterministicPrincipal(email);

        return {
          'ok': {
            'id': principal,
            'email': email,
            'username': args[2] as String, // username
            'authProvider': 'email',
            'reputation': 0,
            'createdAt': DateTime.now().millisecondsSinceEpoch,
            'lastLogin': null,
            'isActive': true,
            'kycVerified': false,
            'profileImage': null,
          },
        };
      } else {
        // Return error when feature is disabled
        return {'err': 'principal_mapping_disabled'};
      }
    } catch (error, stackTrace) {
      Logger.instance.logError(
        'Canister call failed for method: $method',
        tag: 'ICPService',
        error: error,
        stackTrace: stackTrace,
      );

      return {'err': 'network_error'};
    }
  }

  Future<Result<T, AuthError>> _wrapAuthCall<T>(
    Future<T> Function() action,
  ) async {
    try {
      final value = await action();
      return Result.ok(value);
    } catch (e) {
      return Result.err(mapAuthExceptionToAuthError(e));
    }
  }

  Future<Result<User, AuthError>> register({
    required String email,
    required String password,
    required String username,
  }) async {
    return _wrapAuthCall<User>(() async {
      // Validate input
      if (!_isValidEmail(email)) {
        throw AuthInvalidCredentialsException();
      }
      if (!_isValidPassword(password)) {
        throw AuthInvalidCredentialsException();
      }
      if (!_isValidUsername(username)) {
        throw AuthInvalidCredentialsException();
      }

      // Hash password with bcrypt
      final hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());

      // Generate ICP key pair
      final icpKeyPair = ICPKeyPair.generate();

      // Call the real canister for registration
      final result = await _callCanister(
        method: 'register',
        args: [email, hashedPassword, username, icpKeyPair.principalId],
      );

      if (result.containsKey('ok')) {
        final userData = result['ok'] as Map<String, dynamic>;
        final user = User(
          id: userData['id'] as String,
          email: userData['email'] as String,
          username: userData['username'] as String,
          authProvider: userData['authProvider'] as String,
          createdAtMillis: userData['createdAt'] as int,
          principalId: icpKeyPair.principalId,
          isVerified: userData['isVerified'] as bool? ?? false,
          roles: List<String>.from(userData['roles'] ?? ['user']),
          metadata: Map<String, dynamic>.from(userData['metadata'] ?? {}),
        );

        // Store ICP key pair securely
        await _secureStorage.storeICPKeyPair(icpKeyPair, user.id);

        // Generate JWT token
        final token = _jwtService.generateToken(
          userId: user.id,
          email: user.email,
          username: user.username,
          authProvider: user.authProvider,
          roles: user.roles,
          principalId: user.principalId,
        );

        // Store JWT token
        await _jwtService.storeToken(token);

        Logger.instance.logInfo(
          'User registered successfully: ${user.email}',
          tag: 'ICPService',
        );

        return user;
      } else {
        final error = result['err'] as String;
        throw _mapCanisterErrorToException(error);
      }
    });
  }

  Future<Result<User, AuthError>> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    return _wrapAuthCall<User>(() async {
      // Basic validation
      if (email.isEmpty || password.isEmpty) {
        throw AuthInvalidCredentialsException();
      }

      // Call canister for login (will check password hash on backend)
      final result = await _callCanister(
        method: 'loginWithEmailPassword',
        args: [email, password],
      );

      if (result.containsKey('ok')) {
        final userData = result['ok'] as Map<String, dynamic>;
        final user = User(
          id: userData['id'] as String,
          email: userData['email'] as String,
          username: userData['username'] as String,
          authProvider: userData['authProvider'] as String,
          createdAtMillis: userData['createdAt'] as int,
          principalId: userData['principalId'] as String?,
          isVerified: userData['isVerified'] as bool? ?? false,
          roles: List<String>.from(userData['roles'] ?? ['user']),
          metadata: Map<String, dynamic>.from(userData['metadata'] ?? {}),
        );

        // Generate JWT token
        final token = _jwtService.generateToken(
          userId: user.id,
          email: user.email,
          username: user.username,
          authProvider: user.authProvider,
          roles: user.roles,
          principalId: user.principalId,
        );

        // Store JWT token
        await _jwtService.storeToken(token);

        Logger.instance.logInfo(
          'User logged in successfully: ${user.email}',
          tag: 'ICPService',
        );

        return user;
      } else {
        final error = result['err'] as String;
        throw _mapCanisterErrorToException(error);
      }
    });
  }

  Future<Result<User, AuthError>> loginWithOAuth({
    required String provider,
    required String token,
  }) async {
    return _wrapAuthCall<User>(() async {
      // Validate provider
      if (!['google', 'apple', 'github', 'facebook'].contains(provider)) {
        throw OAuthDeniedException();
      }

      // Call canister for OAuth login
      final result = await _callCanister(
        method: 'loginWithOAuth',
        args: [provider, token],
      );

      if (result.containsKey('ok')) {
        final userData = result['ok'] as Map<String, dynamic>;

        // Generate ICP key pair if not exists
        String? principalId = userData['principalId'] as String?;
        ICPKeyPair? icpKeyPair;

        if (principalId == null) {
          icpKeyPair = ICPKeyPair.generate();
          principalId = icpKeyPair.principalId;
        }

        final user = User(
          id: userData['id'] as String,
          email: userData['email'] as String,
          username: userData['username'] as String,
          authProvider: userData['authProvider'] as String,
          createdAtMillis: userData['createdAt'] as int,
          principalId: principalId,
          isVerified:
              userData['isVerified'] as bool? ??
              true, // OAuth users are typically verified
          roles: List<String>.from(userData['roles'] ?? ['user']),
          metadata: Map<String, dynamic>.from(userData['metadata'] ?? {}),
        );

        // Store ICP key pair if newly generated
        if (icpKeyPair != null) {
          await _secureStorage.storeICPKeyPair(icpKeyPair, user.id);
        }

        // Generate JWT token
        final jwtToken = _jwtService.generateToken(
          userId: user.id,
          email: user.email,
          username: user.username,
          authProvider: user.authProvider,
          roles: user.roles,
          principalId: user.principalId,
        );

        // Store JWT token
        await _jwtService.storeToken(jwtToken);

        Logger.instance.logInfo(
          'User logged in with OAuth successfully: ${user.email} via $provider',
          tag: 'ICPService',
        );

        return user;
      } else {
        final error = result['err'] as String;
        throw _mapCanisterErrorToException(error);
      }
    });
  }

  Future<Result<Map<String, dynamic>, AuthError>> getUserProfile({
    required String principal,
  }) async {
    return _wrapAuthCall<Map<String, dynamic>>(() async {
      // Call canister for user profile
      final result = await _callCanister(
        method: 'getUserProfile',
        args: [principal],
      );

      if (result.containsKey('ok')) {
        return result['ok'] as Map<String, dynamic>;
      } else {
        final error = result['err'] as String;
        throw _mapCanisterErrorToException(error);
      }
    });
  }

  /// Logout user and clear stored data
  Future<Result<void, AuthError>> logout(String userId) async {
    return _wrapAuthCall<void>(() async {
      // Call canister for logout (if needed)
      await _callCanister(method: 'logout', args: [userId]);

      // Clear JWT token
      await _jwtService.deleteToken();

      // Clear secure storage data
      await _secureStorage.clearUserData(userId);

      Logger.instance.logInfo(
        'User logged out successfully: $userId',
        tag: 'ICPService',
      );
    });
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return await _jwtService.isAuthenticated();
  }

  /// Get current authenticated user
  Future<User?> getCurrentUser() async {
    final jwtPayload = await _jwtService.getCurrentUser();
    if (jwtPayload == null) {
      return null;
    }

    return User(
      id: jwtPayload.sub,
      email: jwtPayload.email,
      username: jwtPayload.username ?? 'user',
      authProvider: jwtPayload.authProvider ?? 'email',
      createdAtMillis: jwtPayload.issuedAt.millisecondsSinceEpoch,
      principalId: jwtPayload.principalId,
      roles: jwtPayload.roles,
      isVerified: true, // JWT users are authenticated
    );
  }

  /// Refresh user session
  Future<Result<User?, AuthError>> refreshSession() async {
    return _wrapAuthCall<User?>(() async {
      final newToken = await _jwtService.refreshToken();
      if (newToken == null) {
        return null;
      }

      return await getCurrentUser();
    });
  }

  /// Get ICP key pair for user
  Future<ICPKeyPair?> getICPKeyPair(String userId) async {
    return await _secureStorage.getICPKeyPair(userId);
  }

  /// Input validation methods
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email) && email.length <= 254;
  }

  bool _isValidPassword(String password) {
    return password.length >= 8 &&
        password.length <= 128 &&
        password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[a-z]')) &&
        password.contains(RegExp(r'[0-9]'));
  }

  bool _isValidUsername(String username) {
    return username.length >= 3 &&
        username.length <= 20 &&
        RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username);
  }
}

Exception _mapCanisterErrorToException(String error) {
  switch (error) {
    case 'invalid_email':
      return AuthInvalidCredentialsException();
    case 'weak_password':
      return AuthInvalidCredentialsException();
    case 'invalid_username':
      return AuthInvalidCredentialsException();
    case 'email_in_use':
      return AuthInvalidCredentialsException();
    case 'principal_exists':
      return AuthInvalidCredentialsException();
    case 'invalid_token':
      return OAuthDeniedException();
    case 'network_error':
      return AuthNetworkException();
    case 'principal_mapping_disabled':
      return AuthFeatureDisabledException();
    default:
      return AuthUnknownException();
  }
}

String _deriveDeterministicPrincipal(String seed) {
  // Cheap deterministic stand-in for Principal text. DO NOT use in production.
  // e.g., principal-<simple-hash>
  final codeUnits = seed.codeUnits;
  int hash = 0;
  for (final c in codeUnits) {
    hash = (hash * 31 + c) & 0x7fffffff;
  }
  return 'principal-${hash.toRadixString(16)}';
}
