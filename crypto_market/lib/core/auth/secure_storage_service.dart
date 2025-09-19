import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'package:crypto_market/core/logger/logger.dart';

/// ICP key pair storage structure
class ICPKeyPair {
  final String principalId;
  final String privateKey;
  final String publicKey;
  final DateTime createdAt;

  const ICPKeyPair({
    required this.principalId,
    required this.privateKey,
    required this.publicKey,
    required this.createdAt,
  });

  factory ICPKeyPair.generate() {
    // Generate a simple key pair for demo purposes
    // In production, use proper ICP agent library
    final random = Random.secure();
    final seedBytes = List<int>.generate(32, (i) => random.nextInt(256));
    final seed = base64Url.encode(seedBytes);

    // Generate principal ID from seed
    final principalId = _generatePrincipalId(seed);

    // Generate key pair (simplified for demo)
    final privateKey = _generatePrivateKey(seed);
    final publicKey = _generatePublicKey(privateKey);

    return ICPKeyPair(
      principalId: principalId,
      privateKey: privateKey,
      publicKey: publicKey,
      createdAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'principalId': principalId,
      'privateKey': privateKey,
      'publicKey': publicKey,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ICPKeyPair.fromJson(Map<String, dynamic> json) {
    return ICPKeyPair(
      principalId: json['principalId'] as String,
      privateKey: json['privateKey'] as String,
      publicKey: json['publicKey'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  static String _generatePrincipalId(String seed) {
    // Deterministic principal generation from seed
    final bytes = utf8.encode(seed);
    final digest = sha256.convert(bytes);
    return 'principal-${digest.toString().substring(0, 16)}';
  }

  static String _generatePrivateKey(String seed) {
    // Generate private key from seed
    final bytes = utf8.encode(seed);
    final digest = sha256.convert(bytes);
    return 'private-${digest.toString()}';
  }

  static String _generatePublicKey(String privateKey) {
    // Generate public key from private key
    final bytes = utf8.encode(privateKey);
    final digest = sha256.convert(bytes);
    return 'public-${digest.toString()}';
  }
}

/// Secure storage service for ICP keys and sensitive data
class SecureStorageService {
  final FlutterSecureStorage _secureStorage;

  SecureStorageService({FlutterSecureStorage? secureStorage})
    : _secureStorage =
          secureStorage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(
              encryptedSharedPreferences: true,
              resetOnError: true,
            ),
          );

  /// Store ICP key pair securely
  Future<void> storeICPKeyPair(ICPKeyPair keyPair, String userId) async {
    try {
      final key = 'icp_keypair_$userId';
      final value = jsonEncode(keyPair.toJson());

      await _secureStorage.write(key: key, value: value);

      Logger.instance.logInfo(
        'ICP key pair stored securely for user: $userId',
        tag: 'SecureStorageService',
      );
    } catch (e) {
      Logger.instance.logError(
        'Failed to store ICP key pair',
        tag: 'SecureStorageService',
        error: e,
      );
      throw Exception('Failed to store ICP keys securely');
    }
  }

  /// Retrieve ICP key pair
  Future<ICPKeyPair?> getICPKeyPair(String userId) async {
    try {
      final key = 'icp_keypair_$userId';
      final value = await _secureStorage.read(key: key);

      if (value == null) {
        return null;
      }

      final jsonMap = jsonDecode(value) as Map<String, dynamic>;
      final keyPair = ICPKeyPair.fromJson(jsonMap);

      Logger.instance.logDebug(
        'ICP key pair retrieved for user: $userId',
        tag: 'SecureStorageService',
      );

      return keyPair;
    } catch (e) {
      Logger.instance.logError(
        'Failed to retrieve ICP key pair',
        tag: 'SecureStorageService',
        error: e,
      );
      return null;
    }
  }

  /// Delete ICP key pair
  Future<void> deleteICPKeyPair(String userId) async {
    try {
      final key = 'icp_keypair_$userId';
      await _secureStorage.delete(key: key);

      Logger.instance.logInfo(
        'ICP key pair deleted for user: $userId',
        tag: 'SecureStorageService',
      );
    } catch (e) {
      Logger.instance.logError(
        'Failed to delete ICP key pair',
        tag: 'SecureStorageService',
        error: e,
      );
    }
  }

  /// Store encrypted sensitive data
  Future<void> storeEncryptedData(
    String key,
    String data, {
    String? userId,
  }) async {
    try {
      final storageKey = userId != null ? '${userId}_$key' : key;

      // Encrypt data before storing
      final encryptedData = _encryptData(data);
      await _secureStorage.write(key: storageKey, value: encryptedData);

      Logger.instance.logDebug(
        'Encrypted data stored with key: $storageKey',
        tag: 'SecureStorageService',
      );
    } catch (e) {
      Logger.instance.logError(
        'Failed to store encrypted data',
        tag: 'SecureStorageService',
        error: e,
      );
      throw Exception('Failed to store encrypted data');
    }
  }

  /// Retrieve and decrypt sensitive data
  Future<String?> getEncryptedData(String key, {String? userId}) async {
    try {
      final storageKey = userId != null ? '${userId}_$key' : key;
      final encryptedData = await _secureStorage.read(key: storageKey);

      if (encryptedData == null) {
        return null;
      }

      final decryptedData = _decryptData(encryptedData);

      Logger.instance.logDebug(
        'Encrypted data retrieved with key: $storageKey',
        tag: 'SecureStorageService',
      );

      return decryptedData;
    } catch (e) {
      Logger.instance.logError(
        'Failed to retrieve encrypted data',
        tag: 'SecureStorageService',
        error: e,
      );
      return null;
    }
  }

  /// Delete encrypted data
  Future<void> deleteEncryptedData(String key, {String? userId}) async {
    try {
      final storageKey = userId != null ? '${userId}_$key' : key;
      await _secureStorage.delete(key: storageKey);

      Logger.instance.logDebug(
        'Encrypted data deleted with key: $storageKey',
        tag: 'SecureStorageService',
      );
    } catch (e) {
      Logger.instance.logError(
        'Failed to delete encrypted data',
        tag: 'SecureStorageService',
        error: e,
      );
    }
  }

  /// Store session data
  Future<void> storeSessionData(
    Map<String, dynamic> sessionData,
    String userId,
  ) async {
    try {
      final key = 'session_data_$userId';
      final value = jsonEncode(sessionData);

      await _secureStorage.write(key: key, value: value);

      Logger.instance.logDebug(
        'Session data stored for user: $userId',
        tag: 'SecureStorageService',
      );
    } catch (e) {
      Logger.instance.logError(
        'Failed to store session data',
        tag: 'SecureStorageService',
        error: e,
      );
      throw Exception('Failed to store session data');
    }
  }

  /// Retrieve session data
  Future<Map<String, dynamic>?> getSessionData(String userId) async {
    try {
      final key = 'session_data_$userId';
      final value = await _secureStorage.read(key: key);

      if (value == null) {
        return null;
      }

      final sessionData = jsonDecode(value) as Map<String, dynamic>;

      Logger.instance.logDebug(
        'Session data retrieved for user: $userId',
        tag: 'SecureStorageService',
      );

      return sessionData;
    } catch (e) {
      Logger.instance.logError(
        'Failed to retrieve session data',
        tag: 'SecureStorageService',
        error: e,
      );
      return null;
    }
  }

  /// Delete session data
  Future<void> deleteSessionData(String userId) async {
    try {
      final key = 'session_data_$userId';
      await _secureStorage.delete(key: key);

      Logger.instance.logDebug(
        'Session data deleted for user: $userId',
        tag: 'SecureStorageService',
      );
    } catch (e) {
      Logger.instance.logError(
        'Failed to delete session data',
        tag: 'SecureStorageService',
        error: e,
      );
    }
  }

  /// Clear all user data
  Future<void> clearUserData(String userId) async {
    try {
      await deleteICPKeyPair(userId);
      await deleteSessionData(userId);

      // Clear any other user-specific data
      await _secureStorage.delete(key: 'auth_data_$userId');
      await _secureStorage.delete(key: 'user_preferences_$userId');

      Logger.instance.logInfo(
        'All user data cleared for user: $userId',
        tag: 'SecureStorageService',
      );
    } catch (e) {
      Logger.instance.logError(
        'Failed to clear user data',
        tag: 'SecureStorageService',
        error: e,
      );
      throw Exception('Failed to clear user data');
    }
  }

  /// Check if user has stored data
  Future<bool> hasUserData(String userId) async {
    try {
      final keyPair = await getICPKeyPair(userId);
      final sessionData = await getSessionData(userId);

      return keyPair != null || sessionData != null;
    } catch (e) {
      Logger.instance.logError(
        'Failed to check user data',
        tag: 'SecureStorageService',
        error: e,
      );
      return false;
    }
  }

  /// Simple encryption (for demo purposes)
  String _encryptData(String data) {
    // In production, use proper encryption like AES
    final bytes = utf8.encode(data);
    final key = utf8.encode('your-secret-key-32-bytes-long!!');
    // Simple XOR encryption for demo
    final encrypted = List<int>.generate(
      bytes.length,
      (i) => bytes[i] ^ key[i % key.length],
    );
    return base64Url.encode(encrypted);
  }

  /// Simple decryption (for demo purposes)
  String _decryptData(String encryptedData) {
    // In production, use proper decryption like AES
    final encrypted = base64Url.decode(encryptedData);
    final key = utf8.encode('your-secret-key-32-bytes-long!!');

    // Simple XOR decryption for demo
    final decrypted = List<int>.generate(
      encrypted.length,
      (i) => encrypted[i] ^ key[i % key.length],
    );
    return utf8.decode(decrypted);
  }

  /// Get all stored keys (for debugging/maintenance)
  Future<Set<String>> getAllKeys() async {
    try {
      final allKeys = await _secureStorage.readAll();
      Logger.instance.logInfo(
        'Retrieved ${allKeys.length} keys from secure storage',
        tag: 'SecureStorageService',
      );
      return allKeys.keys.toSet();
    } catch (e) {
      Logger.instance.logError(
        'Failed to get all keys from secure storage',
        tag: 'SecureStorageService',
        error: e,
      );
      return {};
    }
  }

  /// Clear all secure storage (for testing/reset)
  Future<void> clearAll() async {
    try {
      final allKeys = await getAllKeys();
      for (final key in allKeys) {
        await _secureStorage.delete(key: key);
      }

      Logger.instance.logInfo(
        'All secure storage cleared (${allKeys.length} keys)',
        tag: 'SecureStorageService',
      );
    } catch (e) {
      Logger.instance.logError(
        'Failed to clear secure storage',
        tag: 'SecureStorageService',
        error: e,
      );
      throw Exception('Failed to clear secure storage');
    }
  }
}
