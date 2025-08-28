import 'package:flutter_test/flutter_test.dart';
import 'package:crypto_market/core/auth/auth_guard.dart';
import 'package:crypto_market/core/error/domain_errors.dart';

void main() {
  group('Principal', () {
    test('should create principal with correct properties', () {
      final principal = Principal(
        id: 'user123',
        email: 'test@example.com',
        roles: ['user', 'premium'],
        metadata: {'plan': 'premium'},
      );

      expect(principal.id, equals('user123'));
      expect(principal.email, equals('test@example.com'));
      expect(principal.roles, equals(['user', 'premium']));
      expect(principal.metadata['plan'], equals('premium'));
    });

    test('should check roles correctly', () {
      final principal = Principal(
        id: 'user123',
        email: 'test@example.com',
        roles: ['user', 'moderator'],
      );

      expect(principal.hasRole('user'), isTrue);
      expect(principal.hasRole('admin'), isFalse);
      expect(principal.hasAnyRole(['user', 'admin']), isTrue);
      expect(principal.hasAnyRole(['admin', 'superuser']), isFalse);
      expect(principal.hasAllRoles(['user', 'moderator']), isTrue);
      expect(principal.hasAllRoles(['user', 'admin']), isFalse);
    });

    test('should validate session expiry', () {
      final futureExpiry = DateTime.now().add(Duration(hours: 1));
      final pastExpiry = DateTime.now().subtract(Duration(hours: 1));

      final validPrincipal = Principal(
        id: 'user123',
        email: 'test@example.com',
        sessionExpiry: futureExpiry,
      );

      final expiredPrincipal = Principal(
        id: 'user123',
        email: 'test@example.com',
        sessionExpiry: pastExpiry,
      );

      final noExpiryPrincipal = Principal(
        id: 'user123',
        email: 'test@example.com',
      );

      expect(validPrincipal.isSessionValid, isTrue);
      expect(expiredPrincipal.isSessionValid, isFalse);
      expect(noExpiryPrincipal.isSessionValid, isTrue);
    });

    test('should serialize to/from JSON', () {
      final original = Principal(
        id: 'user123',
        email: 'test@example.com',
        sessionExpiry: DateTime.parse('2024-01-01T12:00:00Z'),
        roles: ['user', 'premium'],
        metadata: {'plan': 'premium'},
      );

      final json = original.toJson();
      final deserialized = Principal.fromJson(json);

      expect(deserialized.id, equals(original.id));
      expect(deserialized.email, equals(original.email));
      expect(deserialized.sessionExpiry, equals(original.sessionExpiry));
      expect(deserialized.roles, equals(original.roles));
      expect(deserialized.metadata, equals(original.metadata));
    });
  });

  group('AuthState', () {
    setUp(() {
      AuthState.clearPrincipal();
    });

    test('should manage authentication state', () {
      expect(AuthState.isAuthenticated, isFalse);
      expect(AuthState.currentPrincipal, isNull);

      final principal = Principal(id: 'user123', email: 'test@example.com');

      AuthState.setPrincipal(principal);

      expect(AuthState.isAuthenticated, isTrue);
      expect(AuthState.currentPrincipal, equals(principal));
      expect(AuthState.lastAuthCheck, isNotNull);

      AuthState.clearPrincipal();

      expect(AuthState.isAuthenticated, isFalse);
      expect(AuthState.currentPrincipal, isNull);
      expect(AuthState.lastAuthCheck, isNull);
    });

    test('should handle expired sessions', () {
      final expiredPrincipal = Principal(
        id: 'user123',
        email: 'test@example.com',
        sessionExpiry: DateTime.now().subtract(Duration(hours: 1)),
      );

      AuthState.setPrincipal(expiredPrincipal);

      expect(AuthState.isAuthenticated, isFalse);
    });
  });

  group('RateLimiter', () {
    setUp(() {
      RateLimiter.clearAll();
    });

    test('should allow requests within limits', () {
      const principalId = 'user123';
      const operation = 'test.operation';

      // Should allow up to the limit
      for (int i = 0; i < 5; i++) {
        final allowed = RateLimiter.checkLimit(
          principalId,
          operation,
          maxRequests: 5,
          timeWindow: Duration(minutes: 1),
        );
        expect(allowed, isTrue);
      }
    });

    test('should reject requests over limits', () {
      const principalId = 'user123';
      const operation = 'test.operation';

      // Fill up the limit
      for (int i = 0; i < 3; i++) {
        RateLimiter.checkLimit(
          principalId,
          operation,
          maxRequests: 3,
          timeWindow: Duration(minutes: 1),
        );
      }

      // Next request should be rejected
      final allowed = RateLimiter.checkLimit(
        principalId,
        operation,
        maxRequests: 3,
        timeWindow: Duration(minutes: 1),
      );
      expect(allowed, isFalse);
    });

    test('should reset limits for specific principal', () {
      const principalId = 'user123';
      const operation = 'test.operation';

      // Fill up the limit
      for (int i = 0; i < 3; i++) {
        RateLimiter.checkLimit(principalId, operation, maxRequests: 3);
      }

      // Should be at limit
      expect(
        RateLimiter.checkLimit(principalId, operation, maxRequests: 3),
        isFalse,
      );

      // Reset limits
      RateLimiter.resetLimits(principalId);

      // Should be allowed again
      expect(
        RateLimiter.checkLimit(principalId, operation, maxRequests: 3),
        isTrue,
      );
    });
  });

  group('AuthGuard', () {
    setUp(() {
      AuthState.clearPrincipal();
    });

    test('should check authentication correctly', () {
      expect(AuthGuard.isAuthenticated(), isFalse);

      final principal = Principal(id: 'user123', email: 'test@example.com');
      AuthState.setPrincipal(principal);

      expect(AuthGuard.isAuthenticated(), isTrue);
    });

    test('should require authentication', () {
      expect(
        () => AuthGuard.requireAuth(operation: 'test'),
        throwsA(isA<AuthError>()),
      );

      final principal = Principal(id: 'user123', email: 'test@example.com');
      AuthState.setPrincipal(principal);

      expect(() => AuthGuard.requireAuth(operation: 'test'), returnsNormally);
    });

    test('should check roles correctly', () {
      final principal = Principal(
        id: 'user123',
        email: 'test@example.com',
        roles: ['user', 'moderator'],
      );
      AuthState.setPrincipal(principal);

      expect(AuthGuard.hasRole('user'), isTrue);
      expect(AuthGuard.hasRole('admin'), isFalse);
      expect(AuthGuard.hasAnyRole(['user', 'admin']), isTrue);
      expect(AuthGuard.hasAnyRole(['admin', 'superuser']), isFalse);
    });

    test('should require roles', () {
      final principal = Principal(
        id: 'user123',
        email: 'test@example.com',
        roles: ['user'],
      );
      AuthState.setPrincipal(principal);

      expect(() => AuthGuard.requireRole('user'), returnsNormally);
      expect(() => AuthGuard.requireRole('admin'), throwsA(isA<AuthError>()));
      expect(
        () => AuthGuard.requireAnyRole(['user', 'moderator']),
        returnsNormally,
      );
      expect(
        () => AuthGuard.requireAnyRole(['admin', 'superuser']),
        throwsA(isA<AuthError>()),
      );
    });

    test('should check operation permissions', () {
      final principal = Principal(id: 'user123', email: 'test@example.com');
      AuthState.setPrincipal(principal);

      // Operations that don't require auth should pass
      expect(AuthGuard.canPerformOperation('auth.login'), isTrue);
      expect(AuthGuard.canPerformOperation('listing.search'), isTrue);

      // Operations that require auth should pass when authenticated
      expect(AuthGuard.canPerformOperation('listing.create'), isTrue);
      expect(AuthGuard.canPerformOperation('profile.update'), isTrue);
    });

    test('should enforce security policies', () {
      final principal = Principal(id: 'user123', email: 'test@example.com');
      AuthState.setPrincipal(principal);

      // Should allow operations within policy
      expect(() => AuthGuard.enforcePolicy('listing.create'), returnsNormally);

      // Should reject if rate limited (after many attempts)
      // Note: This is a simplified test - full rate limiting would need time manipulation
    });

    test('should detect session near expiry', () {
      final soonToExpirePrincipal = Principal(
        id: 'user123',
        email: 'test@example.com',
        sessionExpiry: DateTime.now().add(Duration(minutes: 10)),
      );
      AuthState.setPrincipal(soonToExpirePrincipal);

      expect(AuthGuard.isSessionNearExpiry(), isTrue);

      final validPrincipal = Principal(
        id: 'user123',
        email: 'test@example.com',
        sessionExpiry: DateTime.now().add(Duration(hours: 2)),
      );
      AuthState.setPrincipal(validPrincipal);

      expect(AuthGuard.isSessionNearExpiry(), isFalse);
    });

    test('should validate and clear expired sessions', () {
      final expiredPrincipal = Principal(
        id: 'user123',
        email: 'test@example.com',
        sessionExpiry: DateTime.now().subtract(Duration(hours: 1)),
      );
      AuthState.setPrincipal(expiredPrincipal);

      expect(() => AuthGuard.validateSession(), throwsA(isA<AuthError>()));
      expect(AuthState.currentPrincipal, isNull);
    });

    test('should get current principal', () {
      expect(() => AuthGuard.getCurrentPrincipal(), throwsA(isA<AuthError>()));

      final principal = Principal(id: 'user123', email: 'test@example.com');
      AuthState.setPrincipal(principal);

      expect(AuthGuard.getCurrentPrincipal(), equals(principal));
    });
  });

  group('SecurityPolicy', () {
    test('should identify operations requiring authentication', () {
      expect(SecurityPolicy.requiresAuth('auth.login'), isFalse);
      expect(SecurityPolicy.requiresAuth('listing.search'), isFalse);
      expect(SecurityPolicy.requiresAuth('listing.create'), isTrue);
      expect(SecurityPolicy.requiresAuth('profile.update'), isTrue);
    });

    test('should provide rate limits for operations', () {
      final authRateLimit = SecurityPolicy.getRateLimit('auth.login');
      expect(authRateLimit?.maxRequests, equals(5));
      expect(authRateLimit?.timeWindow, equals(Duration(minutes: 1)));

      final unknownRateLimit = SecurityPolicy.getRateLimit('unknown.operation');
      expect(unknownRateLimit, isNull);
    });
  });

  group('AuthGuardRoutes Extension', () {
    test('should identify protected routes', () {
      expect('/profile/settings'.requiresAuth, isTrue);
      expect('/dashboard'.requiresAuth, isTrue);
      expect('/create-listing'.requiresAuth, isTrue);
      expect('/login'.requiresAuth, isFalse);
      expect('/register'.requiresAuth, isFalse);
    });

    test('should identify role-based routes', () {
      expect('/admin/users'.requiredRoles, equals(['admin']));
      expect(
        '/moderator/reports'.requiredRoles,
        equals(['moderator', 'admin']),
      );
      expect('/profile'.requiredRoles, isNull);
    });
  });

  group('ServiceSecurity Mixin', () {
    late TestService testService;

    setUp(() {
      testService = TestService();
      AuthState.clearPrincipal();
      RateLimiter.clearAll();
    });

    test('should execute protected operations when authorized', () async {
      final principal = Principal(
        id: 'user123',
        email: 'test@example.com',
        roles: ['user'],
      );
      AuthState.setPrincipal(principal);

      final result = await testService.performProtectedOperation();
      expect(result, equals('success'));
    });

    test('should reject protected operations when not authenticated', () async {
      expect(
        () => testService.performProtectedOperation(),
        throwsA(isA<AuthError>()),
      );
    });

    test('should check role requirements', () async {
      final principal = Principal(
        id: 'user123',
        email: 'test@example.com',
        roles: ['user'],
      );
      AuthState.setPrincipal(principal);

      // Should work with correct role
      expect(() => testService.performRoleBasedOperation(), returnsNormally);

      // Should fail with insufficient role
      expect(
        () => testService.performAdminOperation(),
        throwsA(isA<AuthError>()),
      );
    });
  });
}

// Test service implementing ServiceSecurity mixin
class TestService with ServiceSecurity {
  Future<String> performProtectedOperation() async {
    return executeProtected('test.operation', () async {
      return 'success';
    });
  }

  Future<String> performRoleBasedOperation() async {
    return executeProtected(
      'test.role.operation',
      () async => 'success',
      requiredRole: 'user',
    );
  }

  Future<String> performAdminOperation() async {
    return executeProtected(
      'test.admin.operation',
      () async => 'success',
      requiredRole: 'admin',
    );
  }
}
