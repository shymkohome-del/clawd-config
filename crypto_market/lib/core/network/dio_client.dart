import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:crypto_market/core/config/app_constants.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  static DioClient get instance => _instance;

  final Dio _dio;
  final Logger _logger = Logger();

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
          _logger.i('Request: ${options.method} ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.i(
            'Response: ${response.statusCode} ${response.statusMessage}',
          );
          return handler.next(response);
        },
        onError: (error, handler) {
          _logger.e('Error: ${error.message}');
          return handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;
}
