import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:crypto_market/core/logger/logger.dart';
import 'package:crypto_market/core/error/simple_result.dart';

/// IPFS service for storing payment proofs and other files
class IpfsService {
  final String _ipfsGateway;
  final String _ipfsApi;

  IpfsService({String? ipfsGateway, String? ipfsApi})
    : _ipfsGateway = ipfsGateway ?? 'https://ipfs.io/ipfs/',
      _ipfsApi = ipfsApi ?? 'https://api.pinata.cloud/pinning/pinFileToIPFS';

  /// Upload file to IPFS
  Future<Result<String, IpfsError>> uploadFile({
    required File file,
    String? fileName,
    Map<String, String>? metadata,
  }) async {
    try {
      Logger.instance.logDebug(
        'Uploading file to IPFS: ${fileName ?? file.path}',
        tag: 'IpfsService',
      );

      // Read file bytes
      final bytes = await file.readAsBytes();
      return uploadBytes(
        bytes: bytes,
        fileName: fileName ?? file.path.split('/').last,
        metadata: metadata,
      );
    } catch (error, stackTrace) {
      Logger.instance.logError(
        'Failed to upload file to IPFS',
        tag: 'IpfsService',
        error: error,
        stackTrace: stackTrace,
      );

      return Result.err(IpfsError.uploadFailed);
    }
  }

  /// Upload bytes to IPFS
  Future<Result<String, IpfsError>> uploadBytes({
    required Uint8List bytes,
    required String fileName,
    Map<String, String>? metadata,
  }) async {
    try {
      Logger.instance.logDebug(
        'Uploading bytes to IPFS: $fileName (${bytes.length} bytes)',
        tag: 'IpfsService',
      );

      // Validate file size (max 10MB for payment proofs)
      if (bytes.length > 10 * 1024 * 1024) {
        Logger.instance.logWarn(
          'File too large: ${bytes.length} bytes',
          tag: 'IpfsService',
        );
        return Result.err(IpfsError.fileTooLarge);
      }

      // Create multipart request
      final request = http.MultipartRequest('POST', Uri.parse(_ipfsApi));

      // Add file
      request.files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: fileName),
      );

      // Add metadata if provided
      if (metadata != null) {
        request.fields['pinataMetadata'] = metadata.toString();
      }

      // Add Pinata options (optional - requires API key)
      request.fields['pinataOptions'] = '{"cidVersion": 1}';

      // Send request
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final jsonResponse = _parseJsonResponse(responseBody);

        if (jsonResponse['IpfsHash'] != null) {
          final ipfsHash = jsonResponse['IpfsHash'] as String;

          Logger.instance.logDebug(
            'File uploaded to IPFS successfully: $ipfsHash',
            tag: 'IpfsService',
          );

          return Result.ok(ipfsHash);
        } else {
          Logger.instance.logError(
            'Invalid IPFS response: $responseBody',
            tag: 'IpfsService',
          );
          return Result.err(IpfsError.invalidResponse);
        }
      } else {
        Logger.instance.logError(
          'IPFS upload failed with status: ${response.statusCode}',
          tag: 'IpfsService',
        );
        return Result.err(IpfsError.uploadFailed);
      }
    } catch (error, stackTrace) {
      Logger.instance.logError(
        'Failed to upload bytes to IPFS',
        tag: 'IpfsService',
        error: error,
        stackTrace: stackTrace,
      );

      return Result.err(IpfsError.uploadFailed);
    }
  }

  /// Upload payment proof image to IPFS
  Future<Result<String, IpfsError>> uploadPaymentProof({
    required File imageFile,
    required String swapId,
    required String paymentMethodId,
    required String userId,
  }) async {
    try {
      Logger.instance.logDebug(
        'Uploading payment proof for swap: $swapId',
        tag: 'IpfsService',
      );

      // Compress image before upload (optional - would require image processing library)
      final bytes = await imageFile.readAsBytes();

      // Add metadata for payment proof
      final metadata = {
        'type': 'payment_proof',
        'swapId': swapId,
        'paymentMethodId': paymentMethodId,
        'userId': userId,
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        'contentType': 'image/jpeg',
      };

      return await uploadBytes(
        bytes: bytes,
        fileName:
            'payment_proof_${swapId}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        metadata: metadata,
      );
    } catch (error, stackTrace) {
      Logger.instance.logError(
        'Failed to upload payment proof to IPFS',
        tag: 'IpfsService',
        error: error,
        stackTrace: stackTrace,
      );

      return Result.err(IpfsError.uploadFailed);
    }
  }

  /// Get file from IPFS by hash
  Future<Result<Uint8List, IpfsError>> getFile(String ipfsHash) async {
    try {
      Logger.instance.logDebug(
        'Getting file from IPFS: $ipfsHash',
        tag: 'IpfsService',
      );

      final url = '$_ipfsGateway$ipfsHash';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        Logger.instance.logDebug(
          'File retrieved from IPFS successfully: $ipfsHash',
          tag: 'IpfsService',
        );

        return Result.ok(response.bodyBytes);
      } else {
        Logger.instance.logError(
          'Failed to get file from IPFS: ${response.statusCode}',
          tag: 'IpfsService',
        );
        return Result.err(IpfsError.downloadFailed);
      }
    } catch (error, stackTrace) {
      Logger.instance.logError(
        'Failed to get file from IPFS',
        tag: 'IpfsService',
        error: error,
        stackTrace: stackTrace,
      );

      return Result.err(IpfsError.downloadFailed);
    }
  }

  /// Get file URL from IPFS hash
  String getFileUrl(String ipfsHash) {
    return '$_ipfsGateway$ipfsHash';
  }

  /// Check if file exists on IPFS
  Future<Result<bool, IpfsError>> fileExists(String ipfsHash) async {
    try {
      Logger.instance.logDebug(
        'Checking if file exists on IPFS: $ipfsHash',
        tag: 'IpfsService',
      );

      final url = '$_ipfsGateway$ipfsHash';
      final response = await http.head(Uri.parse(url));

      final exists = response.statusCode == 200;

      Logger.instance.logDebug(
        'File exists on IPFS: $exists',
        tag: 'IpfsService',
      );

      return Result.ok(exists);
    } catch (error, stackTrace) {
      Logger.instance.logError(
        'Failed to check file existence on IPFS',
        tag: 'IpfsService',
        error: error,
        stackTrace: stackTrace,
      );

      return Result.err(IpfsError.networkError);
    }
  }

  /// Parse JSON response safely
  Map<String, dynamic> _parseJsonResponse(String responseBody) {
    try {
      return responseBody.isNotEmpty
          ? json.decode(responseBody) as Map<String, dynamic>
          : {};
    } catch (error) {
      Logger.instance.logError(
        'Failed to parse JSON response: $responseBody',
        tag: 'IpfsService',
        error: error,
      );
      return {};
    }
  }

  /// Get IPFS service status
  Future<Result<bool, IpfsError>> getServiceStatus() async {
    try {
      Logger.instance.logDebug(
        'Checking IPFS service status',
        tag: 'IpfsService',
      );

      // Check if gateway is accessible
      final response = await http
          .get(Uri.parse(_ipfsGateway))
          .timeout(const Duration(seconds: 10));

      final isOnline = response.statusCode == 200;

      Logger.instance.logDebug(
        'IPFS service status: ${isOnline ? 'online' : 'offline'}',
        tag: 'IpfsService',
      );

      return Result.ok(isOnline);
    } catch (error) {
      Logger.instance.logError(
        'IPFS service is offline',
        tag: 'IpfsService',
        error: error,
      );

      return Result.err(IpfsError.serviceOffline);
    }
  }

  /// Get localized error message
  String getErrorMessage(IpfsError error, String locale) {
    switch (error) {
      case IpfsError.uploadFailed:
        return locale == 'lv' ? 'Augšupielāde neizdevās' : 'Upload failed';
      case IpfsError.downloadFailed:
        return locale == 'lv' ? 'Lejupielāde neizdevās' : 'Download failed';
      case IpfsError.fileTooLarge:
        return locale == 'lv' ? 'Fails ir pārāk liels' : 'File too large';
      case IpfsError.invalidHash:
        return locale == 'lv' ? 'Nederīgs IPFS hash' : 'Invalid IPFS hash';
      case IpfsError.invalidResponse:
        return locale == 'lv'
            ? 'Nederīga atbilde no servera'
            : 'Invalid server response';
      case IpfsError.networkError:
        return locale == 'lv' ? 'Tīkla kļūda' : 'Network error';
      case IpfsError.serviceOffline:
        return locale == 'lv'
            ? 'IPFS pakalpojums nav pieejams'
            : 'IPFS service unavailable';
      case IpfsError.unauthorized:
        return locale == 'lv' ? 'Piekļuve liegta' : 'Unauthorized access';
    }
  }
}

/// IPFS service errors
enum IpfsError {
  uploadFailed,
  downloadFailed,
  fileTooLarge,
  invalidHash,
  invalidResponse,
  networkError,
  serviceOffline,
  unauthorized,
}
