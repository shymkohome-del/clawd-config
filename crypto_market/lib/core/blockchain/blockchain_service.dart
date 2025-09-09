import 'dart:convert';
import 'package:crypto_market/core/config/environment_config.dart';
import 'package:crypto_market/core/logger/logger.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Real blockchain service for ICP canister interactions
class BlockchainService {
  final Dio _dio;
  final Logger _logger;

  BlockchainService({required Dio dio, required Logger logger})
    : _dio = dio,
      _logger = logger;

  /// Get base canister URL based on network configuration
  String get _baseUrl => CanisterConfig.baseUrl;

  /// Generic canister call method
  Future<Map<String, dynamic>> _callCanister({
    required String canisterId,
    required String method,
    Map<String, dynamic>? args,
    bool isQuery = false,
  }) async {
    try {
      final requestType = isQuery ? 'query' : 'call';
      final url = '$_baseUrl/api/v2/canister/$canisterId/$requestType';

      _logger.logDebug(
        'Calling canister: $canisterId.$method (requestType: $requestType)',
        tag: 'BlockchainService',
      );

      final response = await _dio.post(
        url,
        data: {'method_name': method, 'arg': _encodeArgs(args)},
        options: Options(
          headers: {'Content-Type': 'application/cbor'},
          responseType: ResponseType.bytes,
        ),
      );

      if (response.statusCode == 200) {
        final result = _decodeCBORResponse(response.data);
        _logger.logDebug(
          'Canister call successful: $method',
          tag: 'BlockchainService',
        );
        return result;
      } else {
        throw Exception('Canister call failed: ${response.statusCode}');
      }
    } catch (e) {
      _logger.logError(
        'Canister call failed: $method',
        error: e,
        tag: 'BlockchainService',
      );
      rethrow;
    }
  }

  /// Encode arguments for canister calls
  Uint8List _encodeArgs(Map<String, dynamic>? args) {
    if (args == null) return Uint8List(0);
    // Simplified CBOR encoding - in production, use proper Candid encoding
    return Uint8List.fromList(utf8.encode(jsonEncode(args)));
  }

  /// Decode CBOR response from canister
  Map<String, dynamic> _decodeCBORResponse(Uint8List data) {
    // Simplified CBOR decoding - in production, use proper Candid decoding
    final jsonString = utf8.decode(data);
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  // User Management Canister Methods

  Future<Map<String, dynamic>> registerUser({
    required String email,
    required String password,
    required String username,
  }) async {
    return await _callCanister(
      canisterId: CanisterConfig.getCanisterId('user_management'),
      method: 'register',
      args: {'email': email, 'password': password, 'username': username},
    );
  }

  Future<Map<String, dynamic>> loginWithOAuth({
    required String provider,
    required String token,
  }) async {
    final oauthProvider = switch (provider) {
      'google' => {'#google': null},
      'apple' => {'#apple': null},
      'github' => {'#github': null},
      'facebook' => {'#facebook': null},
      _ => throw ArgumentError('Unsupported OAuth provider: $provider'),
    };

    return await _callCanister(
      canisterId: CanisterConfig.getCanisterId('user_management'),
      method: 'loginWithOAuth',
      args: {'provider': oauthProvider, 'token': token},
    );
  }

  Future<Map<String, dynamic>?> getUserProfile(String principalId) async {
    try {
      final result = await _callCanister(
        canisterId: CanisterConfig.getCanisterId('user_management'),
        method: 'getUserProfile',
        args: {'user': principalId},
        isQuery: true,
      );
      return result;
    } catch (e) {
      _logger.logWarn(
        'Failed to get user profile: $principalId',
        error: e,
        tag: 'BlockchainService',
      );
      return null;
    }
  }

  // Marketplace Canister Methods

  Future<Map<String, dynamic>> createListing({
    required String title,
    required String description,
    required String cryptoAsset,
    required int amount,
    required int priceInUsd,
    required List<String> paymentMethods,
  }) async {
    return await _callCanister(
      canisterId: CanisterConfig.getCanisterId('marketplace'),
      method: 'createListing',
      args: {
        'title': title,
        'description': description,
        'cryptoAsset': cryptoAsset,
        'amount': amount,
        'priceInUsd': priceInUsd,
        'paymentMethods': paymentMethods,
      },
    );
  }

  Future<Map<String, dynamic>?> getListing(String listingId) async {
    try {
      return await _callCanister(
        canisterId: CanisterConfig.getCanisterId('marketplace'),
        method: 'getListing',
        args: {'listingId': listingId},
        isQuery: true,
      );
    } catch (e) {
      _logger.logWarn(
        'Failed to get listing: $listingId',
        error: e,
        tag: 'BlockchainService',
      );
      return null;
    }
  }

  Future<Map<String, dynamic>> updateListing({
    required String listingId,
    String? title,
    String? description,
    int? amount,
    int? priceInUsd,
    List<String>? paymentMethods,
    bool? isActive,
  }) async {
    final updateArgs = <String, dynamic>{};
    if (title != null) updateArgs['title'] = [title];
    if (description != null) updateArgs['description'] = [description];
    if (amount != null) updateArgs['amount'] = [amount];
    if (priceInUsd != null) updateArgs['priceInUsd'] = [priceInUsd];
    if (paymentMethods != null) updateArgs['paymentMethods'] = [paymentMethods];
    if (isActive != null) updateArgs['isActive'] = [isActive];

    return await _callCanister(
      canisterId: CanisterConfig.getCanisterId('marketplace'),
      method: 'updateListing',
      args: {'listingId': listingId, 'req': updateArgs},
    );
  }

  Future<Map<String, dynamic>> searchListings({
    String? cryptoAsset,
    int? minAmount,
    int? maxAmount,
    int? minPrice,
    int? maxPrice,
    String? paymentMethod,
    int offset = 0,
    int limit = 20,
  }) async {
    final filters = <String, dynamic>{};
    if (cryptoAsset != null) filters['cryptoAsset'] = [cryptoAsset];
    if (minAmount != null) filters['minAmount'] = [minAmount];
    if (maxAmount != null) filters['maxAmount'] = [maxAmount];
    if (minPrice != null) filters['minPrice'] = [minPrice];
    if (maxPrice != null) filters['maxPrice'] = [maxPrice];
    if (paymentMethod != null) filters['paymentMethod'] = [paymentMethod];

    return await _callCanister(
      canisterId: CanisterConfig.getCanisterId('marketplace'),
      method: 'searchListings',
      args: {'filters': filters, 'offset': offset, 'limit': limit},
      isQuery: true,
    );
  }

  Future<List<Map<String, dynamic>>> getUserListings(String principalId) async {
    try {
      final result = await _callCanister(
        canisterId: CanisterConfig.getCanisterId('marketplace'),
        method: 'getUserListings',
        args: {'user': principalId},
        isQuery: true,
      );
      return List<Map<String, dynamic>>.from(result['listings'] ?? []);
    } catch (e) {
      _logger.logWarn(
        'Failed to get user listings: $principalId',
        error: e,
        tag: 'BlockchainService',
      );
      return [];
    }
  }

  // Atomic Swap Canister Methods

  Future<Map<String, dynamic>> initiateSwap({
    required String seller,
    required String listingId,
    required String cryptoAsset,
    required int amount,
    required int priceInUsd,
    required int lockTimeHours,
  }) async {
    return await _callCanister(
      canisterId: CanisterConfig.getCanisterId('atomic_swap'),
      method: 'initiateSwap',
      args: {
        'seller': seller,
        'listingId': listingId,
        'cryptoAsset': cryptoAsset,
        'amount': amount,
        'priceInUsd': priceInUsd,
        'lockTimeHours': lockTimeHours,
      },
    );
  }

  Future<Map<String, dynamic>> lockFunds({
    required String swapId,
    required int buyerDepositAmount,
    required int sellerDepositAmount,
  }) async {
    return await _callCanister(
      canisterId: CanisterConfig.getCanisterId('atomic_swap'),
      method: 'lockFunds',
      args: {
        'swapId': swapId,
        'buyerDepositAmount': buyerDepositAmount,
        'sellerDepositAmount': sellerDepositAmount,
      },
    );
  }

  Future<Map<String, dynamic>> completeSwap({
    required String swapId,
    required Uint8List secret,
  }) async {
    return await _callCanister(
      canisterId: CanisterConfig.getCanisterId('atomic_swap'),
      method: 'completeSwap',
      args: {'swapId': swapId, 'secret': secret},
    );
  }

  Future<Map<String, dynamic>?> getSwap(String swapId) async {
    try {
      return await _callCanister(
        canisterId: CanisterConfig.getCanisterId('atomic_swap'),
        method: 'getSwap',
        args: {'swapId': swapId},
        isQuery: true,
      );
    } catch (e) {
      _logger.logWarn(
        'Failed to get swap: $swapId',
        error: e,
        tag: 'BlockchainService',
      );
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getUserSwaps(String principalId) async {
    try {
      final result = await _callCanister(
        canisterId: CanisterConfig.getCanisterId('atomic_swap'),
        method: 'getUserSwaps',
        args: {'user': principalId},
        isQuery: true,
      );
      return List<Map<String, dynamic>>.from(result['swaps'] ?? []);
    } catch (e) {
      _logger.logWarn(
        'Failed to get user swaps: $principalId',
        error: e,
        tag: 'BlockchainService',
      );
      return [];
    }
  }

  // Price Oracle Canister Methods

  Future<Map<String, dynamic>?> getPrice(String symbol) async {
    try {
      return await _callCanister(
        canisterId: CanisterConfig.getCanisterId('price_oracle'),
        method: 'getPrice',
        args: {'symbol': symbol},
        isQuery: true,
      );
    } catch (e) {
      _logger.logWarn(
        'Failed to get price: $symbol',
        error: e,
        tag: 'BlockchainService',
      );
      return null;
    }
  }

  Future<Map<String, dynamic>?> convertCurrency({
    required String fromSymbol,
    required String toSymbol,
    required int amount,
  }) async {
    try {
      return await _callCanister(
        canisterId: CanisterConfig.getCanisterId('price_oracle'),
        method: 'convertCurrency',
        args: {
          'fromSymbol': fromSymbol,
          'toSymbol': toSymbol,
          'amount': amount,
        },
        isQuery: true,
      );
    } catch (e) {
      _logger.logWarn(
        'Failed to convert currency: $fromSymbol to $toSymbol',
        error: e,
        tag: 'BlockchainService',
      );
      return null;
    }
  }

  Future<List<String>> getSupportedCurrencies() async {
    try {
      final result = await _callCanister(
        canisterId: CanisterConfig.getCanisterId('price_oracle'),
        method: 'getSupportedCurrencies',
        isQuery: true,
      );
      return List<String>.from(result['currencies'] ?? []);
    } catch (e) {
      _logger.logWarn(
        'Failed to get supported currencies',
        error: e,
        tag: 'BlockchainService',
      );
      return [];
    }
  }

  Future<Map<String, Map<String, dynamic>>> getAllPrices() async {
    try {
      final result = await _callCanister(
        canisterId: CanisterConfig.getCanisterId('price_oracle'),
        method: 'getAllPrices',
        isQuery: true,
      );

      final prices = <String, Map<String, dynamic>>{};
      if (result['prices'] != null) {
        for (final entry in (result['prices'] as List<dynamic>)) {
          final pair = entry as List<dynamic>;
          final symbol = pair[0] as String;
          final data = Map<String, dynamic>.from(pair[1] as Map);
          prices[symbol] = data;
        }
      }
      return prices;
    } catch (e) {
      _logger.logWarn(
        'Failed to get all prices',
        error: e,
        tag: 'BlockchainService',
      );
      return {};
    }
  }

  // Utility methods for generating test data in development
  Future<void> initializePriceOracle() async {
    if (kDebugMode) {
      try {
        await _callCanister(
          canisterId: CanisterConfig.getCanisterId('price_oracle'),
          method: 'initializeWithMockPrices',
        );
        _logger.logInfo(
          'Price oracle initialized with mock data',
          tag: 'BlockchainService',
        );
      } catch (e) {
        _logger.logWarn(
          'Failed to initialize price oracle',
          error: e,
          tag: 'BlockchainService',
        );
      }
    }
  }
}
