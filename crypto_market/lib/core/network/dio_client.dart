import 'package:dio/dio.dart';
import 'package:crypto_market/core/config/app_constants.dart';
import 'package:crypto_market/core/logger/logger.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  static DioClient get instance => _instance;

  final Dio _dio;
  final Logger _logger = Logger.instance;

  DioClient._internal()
    : _dio = Dio(
        BaseOptions(
          baseUrl: AppConstants.baseUrl,
          connectTimeout: Duration(milliseconds: AppConstants.connectTimeout),
          receiveTimeout: Duration(milliseconds: AppConstants.receiveTimeout),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      ) {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _logger.logInfo(
            'Request: ${options.method} ${options.path}',
            tag: 'DioClient',
          );
          return handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.logInfo(
            'Response: ${response.statusCode} ${response.statusMessage}',
            tag: 'DioClient',
          );
          return handler.next(response);
        },
        onError: (error, handler) {
          _logger.logError(
            'Error: ${error.message}',
            tag: 'DioClient',
            error: error,
            stackTrace: error.stackTrace,
          );
          return handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;
}
