import 'package:flutter_test/flutter_test.dart';
import 'package:crypto_market/core/security/security_logger.dart';

void main() {
  group('SecurityEvent', () {
    test('should create authentication attempt event', () {
      final event = SecurityEvent.authAttempt(
        email: 'test@example.com',
        operation: 'login',
        ipAddress: '192.168.1.1',
        metadata: {'userAgent': 'test-agent'},
      );

      expect(event.type, equals(SecurityEventType.authenticationAttempt));
      expect(event.operation, equals('login'));
      expect(event.userEmail, equals('test@example.com'));
      expect(event.ipAddress, equals('192.168.1.1'));
      expect(event.metadata['userAgent'], equals('test-agent'));
      expect(event.timestamp, isA<DateTime>());
    });

    test('should create authentication success event', () {
      final event = SecurityEvent.authSuccess(
        principalId: 'user123',
        email: 'test@example.com',
        operation: 'login',
      );

      expect(event.type, equals(SecurityEventType.authenticationSuccess));
      expect(event.principalId, equals('user123'));
      expect(event.userEmail, equals('test@example.com'));
      expect(event.operation, equals('login'));
    });

    test('should create authentication failure event', () {
      final event = SecurityEvent.authFailure(
        email: 'test@example.com',
        operation: 'login',
        error: 'Invalid credentials',
      );

      expect(event.type, equals(SecurityEventType.authenticationFailure));
      expect(event.userEmail, equals('test@example.com'));
      expect(event.error, equals('Invalid credentials'));
    });

    test('should create authorization failure event', () {
      final event = SecurityEvent.authzFailure(
        principalId: 'user123',
        operation: 'admin.access',
        error: 'Insufficient privileges',
        requiredRoles: ['admin'],
        userRoles: ['user'],
      );

      expect(event.type, equals(SecurityEventType.authorizationFailure));
      expect(event.principalId, equals('user123'));
      expect(event.error, equals('Insufficient privileges'));
      expect(event.metadata['requiredRoles'], equals(['admin']));
      expect(event.metadata['userRoles'], equals(['user']));
    });

    test('should create validation failure event', () {
      final event = SecurityEvent.validationFailure(
        operation: 'registration',
        errors: ['Email invalid', 'Password too weak'],
        field: 'email',
      );

      expect(event.type, equals(SecurityEventType.validationFailure));
      expect(event.operation, equals('registration'));
      expect(event.error, equals('Email invalid, Password too weak'));
      expect(
        event.metadata['validationErrors'],
        equals(['Email invalid', 'Password too weak']),
      );
      expect(event.metadata['field'], equals('email'));
    });

    test('should create rate limit violation event', () {
      final event = SecurityEvent.rateLimitViolation(
        principalId: 'user123',
        operation: 'login',
        currentCount: 6,
        limit: 5,
        timeWindow: const Duration(minutes: 1),
      );

      expect(event.type, equals(SecurityEventType.rateLimitViolation));
      expect(event.principalId, equals('user123'));
      expect(event.error, contains('Rate limit exceeded: 6/5 in 1min'));
      expect(event.metadata['currentCount'], equals(6));
      expect(event.metadata['limit'], equals(5));
      expect(event.metadata['timeWindowMinutes'], equals(1));
    });

    test('should create suspicious activity event', () {
      final event = SecurityEvent.suspiciousActivity(
        operation: 'data.access',
        description: 'Unusual access pattern detected',
        principalId: 'user123',
      );

      expect(event.type, equals(SecurityEventType.suspiciousActivity));
      expect(event.operation, equals('data.access'));
      expect(event.error, equals('Unusual access pattern detected'));
      expect(event.principalId, equals('user123'));
    });

    test('should create session expiration event', () {
      final expirationTime = DateTime.now().add(const Duration(hours: 1));
      final event = SecurityEvent.sessionExpired(
        principalId: 'user123',
        expirationTime: expirationTime,
      );

      expect(event.type, equals(SecurityEventType.sessionExpiration));
      expect(event.operation, equals('session.expired'));
      expect(event.principalId, equals('user123'));
      expect(
        event.metadata['expirationTime'],
        equals(expirationTime.toIso8601String()),
      );
    });

    test('should create GDPR request event', () {
      final event = SecurityEvent.gdprRequest(
        principalId: 'user123',
        requestType: 'data_export',
        email: 'test@example.com',
      );

      expect(event.type, equals(SecurityEventType.gdprRequest));
      expect(event.operation, equals('gdpr.data_export'));
      expect(event.principalId, equals('user123'));
      expect(event.userEmail, equals('test@example.com'));
      expect(event.metadata['requestType'], equals('data_export'));
    });

    test('should convert to JSON correctly', () {
      final event = SecurityEvent.authSuccess(
        principalId: 'user123',
        email: 'test@example.com',
        operation: 'login',
        metadata: {'source': 'mobile'},
      );

      final json = event.toJson();

      expect(json['type'], equals('authenticationSuccess'));
      expect(json['operation'], equals('login'));
      expect(json['principalId'], equals('user123'));
      expect(json['userEmail'], equals('test@example.com'));
      expect(json['timestamp'], isA<String>());
      final metadata = json['metadata'] as Map<String, dynamic>;
      expect(metadata['source'], equals('mobile'));
    });

    test('should convert to log string correctly', () {
      final event = SecurityEvent.authFailure(
        email: 'test@example.com',
        operation: 'login',
        error: 'Invalid credentials',
        metadata: {'attempts': 3},
      );

      final logString = event.toLogString();

      expect(logString, contains('SECURITY EVENT: authenticationFailure'));
      expect(logString, contains('Operation: login'));
      expect(logString, contains('User Email: test@example.com'));
      expect(logString, contains('Error: Invalid credentials'));
      expect(logString, contains('attempts: 3'));
    });
  });

  group('SecurityLogger', () {
    late SecurityLogger securityLogger;

    setUp(() {
      securityLogger = SecurityLogger.instance;
      securityLogger.initialize(enabled: true);
      securityLogger.clearEvents();
    });

    test('should initialize with correct settings', () {
      expect(securityLogger.isEnabled, isTrue);

      securityLogger.initialize(enabled: false);
      expect(securityLogger.isEnabled, isFalse);
    });

    test('should log authentication events', () {
      securityLogger.logAuthAttempt(
        email: 'test@example.com',
        operation: 'login',
      );

      final events = securityLogger.getRecentEvents();
      expect(events.length, equals(1));
      expect(
        events.first.type,
        equals(SecurityEventType.authenticationAttempt),
      );
    });

    test('should log authentication success', () {
      securityLogger.logAuthSuccess(
        principalId: 'user123',
        email: 'test@example.com',
        operation: 'login',
      );

      final events = securityLogger.getRecentEvents();
      expect(events.length, equals(1));
      expect(
        events.first.type,
        equals(SecurityEventType.authenticationSuccess),
      );
    });

    test('should log authentication failure', () {
      securityLogger.logAuthFailure(
        email: 'test@example.com',
        operation: 'login',
        error: 'Invalid password',
      );

      final events = securityLogger.getRecentEvents();
      expect(events.length, equals(1));
      expect(
        events.first.type,
        equals(SecurityEventType.authenticationFailure),
      );
    });

    test('should log authorization failure', () {
      securityLogger.logAuthzFailure(
        principalId: 'user123',
        operation: 'admin.access',
        error: 'Insufficient privileges',
        requiredRoles: ['admin'],
        userRoles: ['user'],
      );

      final events = securityLogger.getRecentEvents();
      expect(events.length, equals(1));
      expect(events.first.type, equals(SecurityEventType.authorizationFailure));
    });

    test('should log validation failures', () {
      securityLogger.logValidationFailure(
        operation: 'registration',
        errors: ['Email invalid'],
        field: 'email',
      );

      final events = securityLogger.getRecentEvents();
      expect(events.length, equals(1));
      expect(events.first.type, equals(SecurityEventType.validationFailure));
    });

    test('should log rate limit violations', () {
      securityLogger.logRateLimitViolation(
        principalId: 'user123',
        operation: 'login',
        currentCount: 6,
        limit: 5,
        timeWindow: const Duration(minutes: 1),
      );

      final events = securityLogger.getRecentEvents();
      expect(events.length, equals(1));
      expect(events.first.type, equals(SecurityEventType.rateLimitViolation));
    });

    test('should log suspicious activity', () {
      securityLogger.logSuspiciousActivity(
        operation: 'data.access',
        description: 'Unusual pattern',
        principalId: 'user123',
      );

      final events = securityLogger.getRecentEvents();
      expect(events.length, equals(1));
      expect(events.first.type, equals(SecurityEventType.suspiciousActivity));
    });

    test('should log session expiration', () {
      final expirationTime = DateTime.now().add(const Duration(hours: 1));
      securityLogger.logSessionExpired(
        principalId: 'user123',
        expirationTime: expirationTime,
      );

      final events = securityLogger.getRecentEvents();
      expect(events.length, equals(1));
      expect(events.first.type, equals(SecurityEventType.sessionExpiration));
    });

    test('should log GDPR requests', () {
      securityLogger.logGdprRequest(
        principalId: 'user123',
        requestType: 'data_export',
        email: 'test@example.com',
      );

      final events = securityLogger.getRecentEvents();
      expect(events.length, equals(1));
      expect(events.first.type, equals(SecurityEventType.gdprRequest));
    });

    test('should filter events by type', () {
      securityLogger.logAuthAttempt(
        email: 'test@example.com',
        operation: 'login',
      );
      securityLogger.logAuthFailure(
        email: 'test@example.com',
        operation: 'login',
        error: 'fail',
      );
      securityLogger.logValidationFailure(operation: 'test', errors: ['error']);

      final authEvents = securityLogger.getRecentEvents(
        type: SecurityEventType.authenticationAttempt,
      );
      expect(authEvents.length, equals(1));
      expect(
        authEvents.first.type,
        equals(SecurityEventType.authenticationAttempt),
      );
    });

    test('should filter events by operation', () {
      securityLogger.logAuthAttempt(
        email: 'test@example.com',
        operation: 'login',
      );
      securityLogger.logAuthAttempt(
        email: 'test@example.com',
        operation: 'register',
      );

      final loginEvents = securityLogger.getRecentEvents(operation: 'login');
      expect(loginEvents.length, equals(1));
      expect(loginEvents.first.operation, equals('login'));
    });

    test('should limit returned events', () {
      for (int i = 0; i < 10; i++) {
        securityLogger.logAuthAttempt(
          email: 'test$i@example.com',
          operation: 'login',
        );
      }

      final limitedEvents = securityLogger.getRecentEvents(limit: 5);
      expect(limitedEvents.length, equals(5));
    });

    test('should analyze security patterns', () {
      // Create multiple auth failures
      for (int i = 0; i < 6; i++) {
        securityLogger.logAuthFailure(
          email: 'same@example.com',
          operation: 'login',
          error: 'Invalid credentials',
        );
      }

      final patterns = securityLogger.analyzeSecurityPatterns();
      expect(patterns.isNotEmpty, isTrue);
      expect(patterns.first, contains('Repeated authentication failures'));
    });

    test('should provide event statistics', () {
      securityLogger.logAuthAttempt(
        email: 'test@example.com',
        operation: 'login',
      );
      securityLogger.logAuthFailure(
        email: 'test@example.com',
        operation: 'login',
        error: 'fail',
      );
      securityLogger.logAuthFailure(
        email: 'test2@example.com',
        operation: 'login',
        error: 'fail',
      );

      final stats = securityLogger.getEventStats();
      expect(stats['authenticationAttempt'], equals(1));
      expect(stats['authenticationFailure'], equals(2));
    });

    test('should maintain buffer size limit', () {
      // Add more events than buffer limit
      for (int i = 0; i < 1200; i++) {
        securityLogger.logAuthAttempt(
          email: 'test$i@example.com',
          operation: 'login',
        );
      }

      final events = securityLogger.getRecentEvents();
      expect(events.length, lessThanOrEqualTo(1000));
    });

    test('should enable/disable logging', () {
      securityLogger.setEnabled(false);
      expect(securityLogger.isEnabled, isFalse);

      securityLogger.logAuthAttempt(
        email: 'test@example.com',
        operation: 'login',
      );
      expect(securityLogger.getRecentEvents().length, equals(0));

      securityLogger.setEnabled(true);
      securityLogger.logAuthAttempt(
        email: 'test@example.com',
        operation: 'login',
      );
      expect(securityLogger.getRecentEvents().length, equals(1));
    });

    test('should clear events', () {
      securityLogger.logAuthAttempt(
        email: 'test@example.com',
        operation: 'login',
      );
      expect(securityLogger.getRecentEvents().length, equals(1));

      securityLogger.clearEvents();
      expect(securityLogger.getRecentEvents().length, equals(0));
    });
  });

  group('SecurityEventType', () {
    test('should have all expected event types', () {
      final types = SecurityEventType.values;

      expect(types, contains(SecurityEventType.authenticationAttempt));
      expect(types, contains(SecurityEventType.authenticationSuccess));
      expect(types, contains(SecurityEventType.authenticationFailure));
      expect(types, contains(SecurityEventType.authorizationSuccess));
      expect(types, contains(SecurityEventType.authorizationFailure));
      expect(types, contains(SecurityEventType.validationFailure));
      expect(types, contains(SecurityEventType.rateLimitViolation));
      expect(types, contains(SecurityEventType.suspiciousActivity));
      expect(types, contains(SecurityEventType.sessionExpiration));
      expect(types, contains(SecurityEventType.passwordChange));
      expect(types, contains(SecurityEventType.accountLocking));
      expect(types, contains(SecurityEventType.policyViolation));
      expect(types, contains(SecurityEventType.privilegeEscalation));
      expect(types, contains(SecurityEventType.dataAccess));
      expect(types, contains(SecurityEventType.gdprRequest));
    });
  });
}
