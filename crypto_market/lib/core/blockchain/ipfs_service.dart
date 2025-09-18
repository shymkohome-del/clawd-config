import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:crypto_market/core/logger/logger.dart';

/// Service for uploading images to IPFS
class IPFSService {
  final Dio _dio;
  final Logger _logger;

  IPFSService({required Dio dio, required Logger logger})
    : _dio = dio,
      _logger = logger;

  /// Upload a single image to IPFS
  Future<String> uploadImage(File imageFile) async {
    try {
      _logger.logDebug(
        'Uploading image to IPFS: ${imageFile.path}',
        tag: 'IPFSService',
      );

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      final response = await _dio.post(
        'https://ipfs.infura.io:5001/api/v0/add',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Basic ${_getInfuraAuth()}',
          },
        ),
      );

      if (response.statusCode == 200) {
        final hash = response.data['Hash'];
        _logger.logDebug(
          'Image uploaded to IPFS with hash: $hash',
          tag: 'IPFSService',
        );
        return hash;
      } else {
        throw Exception('IPFS upload failed: ${response.statusCode}');
      }
    } catch (e) {
      _logger.logError(
        'Failed to upload image to IPFS: ${imageFile.path}',
        tag: 'IPFSService',
        error: e,
      );
      rethrow;
    }
  }

  /// Upload multiple images to IPFS
  Future<List<String>> uploadImages(List<File> imageFiles) async {
    final hashes = <String>[];

    for (final imageFile in imageFiles) {
      try {
        final hash = await uploadImage(imageFile);
        hashes.add(hash);
      } catch (e) {
        _logger.logError(
          'Failed to upload image: ${imageFile.path}',
          tag: 'IPFSService',
          error: e,
        );
        // Continue with other images even if one fails
      }
    }

    return hashes;
  }

  /// Get Infura authentication header
  String _getInfuraAuth() {
    // In production, these should be stored securely in environment variables
    final projectId = const String.fromEnvironment('INFURA_PROJECT_ID', defaultValue: '');
    final projectSecret = const String.fromEnvironment('INFURA_PROJECT_SECRET', defaultValue: '');

    if (projectId.isEmpty || projectSecret.isEmpty) {
      throw Exception('IPFS credentials not configured. Please set INFURA_PROJECT_ID and INFURA_PROJECT_SECRET environment variables.');
    }

    return base64Encode(
      Uint8List.fromList('$projectId:$projectSecret'.codeUnits),
    );
  }

  /// Get IPFS gateway URL for a hash
  String getGatewayUrl(String hash) {
    return 'https://ipfs.io/ipfs/$hash';
  }
}