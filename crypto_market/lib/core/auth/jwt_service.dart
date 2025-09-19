import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto_market/core/logger/logger.dart';

/// Simple JWT decoder function
Map<String, dynamic> jwtDecode(String token) {
  final parts = token.split('.');
  if (parts.length != 3) {
    throw FormatException('Invalid token format');
  }

  final payload = parts[1];
  final normalized = base64.normalize(payload);
  final decoded = utf8.decode(base64.decode(normalized));
  return json.decode(decoded) as Map<String, dynamic>;
}

/// JWT token payload structure
class JWTPayload {
  final String sub; // Subject (user ID)
  final String email;
  final String? username;
  final String? authProvider;
  final List<String> roles;
  final DateTime issuedAt;
  final DateTime expiresAt;
  final String? principalId;

  const JWTPayload({
    required this.sub,
    required this.email,
    this.username,
    this.authProvider,
    this.roles = const [],
    required this.issuedAt,
    required this.expiresAt,
    this.principalId,
  });

  factory JWTPayload.fromMap(Map<String, dynamic> map) {
    return JWTPayload(
      sub: map['sub'] as String,
      email: map['email'] as String,
      username: map['username'] as String?,
      authProvider: map['authProvider'] as String?,
      roles: List<String>.from(map['roles'] ?? []),
      issuedAt: DateTime.fromMillisecondsSinceEpoch(map['iat'] * 1000),
      expiresAt: DateTime.fromMillisecondsSinceEpoch(map['exp'] * 1000),
      principalId: map['principalId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sub': sub,
      'email': email,
      'username': username,
      'authProvider': authProvider,
      'roles': roles,
      'iat': issuedAt.millisecondsSinceEpoch ~/ 1000,
      'exp': expiresAt.millisecondsSinceEpoch ~/ 1000,
      'principalId': principalId,
    };
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isNearExpiry =>
      DateTime.now().add(const Duration(minutes: 15)).isAfter(expiresAt);
}

/// JWT service for token generation and validation
class JWTService {
  final FlutterSecureStorage _secureStorage;
  final String _secretKey;
  final Duration _tokenExpiry;

  JWTService({
    FlutterSecureStorage? secureStorage,
    String? secretKey,
    Duration? tokenExpiry,
  }) : _secureStorage =
           secureStorage ??
           const FlutterSecureStorage(
             aOptions: AndroidOptions(encryptedSharedPreferences: true),
           ),
       _secretKey = secretKey ?? 'your-secret-key-change-in-production',
       _tokenExpiry = tokenExpiry ?? const Duration(hours: 8);

  /// Generate a JWT token for a user
  String generateToken({
    required String userId,
    required String email,
    String? username,
    String? authProvider,
    List<String> roles = const [],
    String? principalId,
  }) {
    final now = DateTime.now();
    final expiryTime = now.add(_tokenExpiry);

    final payload = JWTPayload(
      sub: userId,
      email: email,
      username: username,
      authProvider: authProvider,
      roles: roles,
      issuedAt: now,
      expiresAt: expiryTime,
      principalId: principalId,
    );

    return _encodeToken(payload);
  }

  /// Validate and decode a JWT token
  Result<JWTPayload, String> validateToken(String token) {
    try {
      // Decode token
      final decoded = jwtDecode(token);

      // Check if token is expired
      if (_isTokenExpired(decoded)) {
        return Result.err('Token expired');
      }

      // Verify signature
      if (!_verifySignature(token)) {
        return Result.err('Invalid token signature');
      }

      final payload = JWTPayload.fromMap(decoded);

      // Double check expiration
      if (payload.isExpired) {
        return Result.err('Token expired');
      }

      return Result.ok(payload);
    } catch (e) {
      Logger.instance.logError('Token validation failed', error: e);
      return Result.err('Invalid token: ${e.toString()}');
    }
  }

  /// Store JWT token securely
  Future<void> storeToken(String token) async {
    try {
      await _secureStorage.write(key: 'jwt_token', value: token);
      Logger.instance.logDebug('JWT token stored securely', tag: 'JWTService');
    } catch (e) {
      Logger.instance.logError('Failed to store JWT token', error: e);
      throw Exception('Failed to store authentication token');
    }
  }

  /// Retrieve stored JWT token
  Future<String?> getToken() async {
    try {
      final token = await _secureStorage.read(key: 'jwt_token');
      if (token != null) {
        Logger.instance.logDebug(
          'JWT token retrieved from storage',
          tag: 'JWTService',
        );
      }
      return token;
    } catch (e) {
      Logger.instance.logError('Failed to retrieve JWT token', error: e);
      return null;
    }
  }

  /// Delete stored JWT token
  Future<void> deleteToken() async {
    try {
      await _secureStorage.delete(key: 'jwt_token');
      Logger.instance.logDebug(
        'JWT token deleted from storage',
        tag: 'JWTService',
      );
    } catch (e) {
      Logger.instance.logError('Failed to delete JWT token', error: e);
    }
  }

  /// Refresh JWT token
  Future<String?> refreshToken() async {
    try {
      final currentToken = await getToken();
      if (currentToken == null) {
        return null;
      }

      final result = validateToken(currentToken);
      if (result.isErr) {
        return null;
      }

      final payload = result.ok;

      // Only refresh if token is near expiry
      if (!payload.isNearExpiry) {
        return currentToken;
      }

      // Generate new token with same payload
      final newToken = generateToken(
        userId: payload.sub,
        email: payload.email,
        username: payload.username,
        authProvider: payload.authProvider,
        roles: payload.roles,
        principalId: payload.principalId,
      );

      // Store new token
      await storeToken(newToken);

      Logger.instance.logDebug(
        'JWT token refreshed successfully',
        tag: 'JWTService',
      );
      return newToken;
    } catch (e) {
      Logger.instance.logError('Failed to refresh JWT token', error: e);
      return null;
    }
  }

  /// Get current user info from stored token
  Future<JWTPayload?> getCurrentUser() async {
    try {
      final token = await getToken();
      if (token == null) {
        return null;
      }

      final result = validateToken(token);
      if (result.isErr) {
        await deleteToken(); // Clear invalid token
        return null;
      }

      return result.ok;
    } catch (e) {
      Logger.instance.logError('Failed to get current user', error: e);
      return null;
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final user = await getCurrentUser();
    return user != null && !user.isExpired;
  }

  /// Simple HMAC-SHA256 encoding (for demo purposes)
  String _encodeToken(JWTPayload payload) {
    // In production, use a proper JWT library like 'jose'
    final header = base64Url.encode(
      utf8.encode(jsonEncode({'alg': 'HS256', 'typ': 'JWT'})),
    );

    final payloadJson = base64Url.encode(
      utf8.encode(jsonEncode(payload.toMap())),
    );

    final signature = _createSignature('$header.$payloadJson');

    return '$header.$payloadJson.$signature';
  }

  /// Create HMAC-SHA256 signature
  String _createSignature(String data) {
    final key = utf8.encode(_secretKey);
    final bytes = utf8.encode(data);
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(bytes);
    return base64Url.encode(digest.bytes);
  }

  /// Verify token signature
  bool _verifySignature(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return false;
      }

      final header = parts[0];
      final payload = parts[1];
      final signature = parts[2];

      final expectedSignature = _createSignature('$header.$payload');
      return signature == expectedSignature;
    } catch (e) {
      return false;
    }
  }

  /// Check if token is expired from decoded payload
  bool _isTokenExpired(Map<String, dynamic> decoded) {
    final exp = decoded['exp'] as int?;
    if (exp == null) return true;

    final expirationTime = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    return DateTime.now().isAfter(expirationTime);
  }
}

/// Simple Result type for JWT operations
class Result<T, E> {
  final T? _ok;
  final E? _err;

  const Result._(this._ok, this._err);

  const Result.ok(T value) : this._(value, null);
  const Result.err(E error) : this._(null, error);

  bool get isOk => _err == null;
  bool get isErr => _ok == null;

  T get ok => _ok as T;
  E get err => _err as E;
}
