import 'package:flutter_test/flutter_test.dart';
import 'package:crypto_market/core/logger/logger.dart';

void main() {
  group('Logger', () {
    late Logger logger;

    setUp(() {
      logger = Logger.instance;
    });

    test('should initialize with default settings', () async {
      await logger.initialize();

      // Logger should initialize without throwing
      expect(logger, isNotNull);
    });

    test('should log debug messages', () {
      // This test verifies the logger API works
      expect(() {
        logger.logDebug('Debug message', tag: 'Test');
      }, returnsNormally);
    });

    test('should log info messages', () {
      expect(() {
        logger.logInfo('Info message', tag: 'Test');
      }, returnsNormally);
    });

    test('should log warning messages', () {
      expect(() {
        logger.logWarn('Warning message', tag: 'Test');
      }, returnsNormally);
    });

    test('should log error messages', () {
      expect(() {
        logger.logError('Error message', tag: 'Test');
      }, returnsNormally);
    });

    test('should log errors with exception and stack trace', () {
      final exception = Exception('Test exception');
      final stackTrace = StackTrace.current;

      expect(() {
        logger.logError(
          'Error with exception',
          tag: 'Test',
          error: exception,
          stackTrace: stackTrace,
        );
      }, returnsNormally);
    });
  });

  group('LogLevel', () {
    test('should have correct priority order', () {
      expect(LogLevel.debug.priority, lessThan(LogLevel.info.priority));
      expect(LogLevel.info.priority, lessThan(LogLevel.warn.priority));
      expect(LogLevel.warn.priority, lessThan(LogLevel.error.priority));
    });

    test('should have correct labels', () {
      expect(LogLevel.debug.label, equals('DEBUG'));
      expect(LogLevel.info.label, equals('INFO'));
      expect(LogLevel.warn.label, equals('WARN'));
      expect(LogLevel.error.label, equals('ERROR'));
    });
  });
}
