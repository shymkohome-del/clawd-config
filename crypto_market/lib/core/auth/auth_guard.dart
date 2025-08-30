import '../logger/logger.dart';
import '../error/domain_errors.dart';

/// Principal information for authenticated users
class Principal {
  final String id;
  final String email;
  final DateTime? sessionExpiry;
  final List<String> roles;
  final Map<String, dynamic> metadata;

  const Principal({
    required this.id,
    required this.email,
    this.sessionExpiry,
    this.roles = const [],
    this.metadata = const {},
  });

  /// Check if the principal has a specific role
  bool hasRole(String role) => roles.contains(role);

  /// Check if the principal has any of the specified roles
  bool hasAnyRole(List<String> requiredRoles) =>
      requiredRoles.any((role) => roles.contains(role));

  /// Check if the principal has all of the specified roles
  bool hasAllRoles(List<String> requiredRoles) =>
      requiredRoles.every((role) => roles.contains(role));

  /// Check if the session is still valid
  bool get isSessionValid {
    if (sessionExpiry == null) return true;
    return DateTime.now().isBefore(sessionExpiry!);
  }

  /// Convert to JSON for storage/transmission
  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'sessionExpiry': sessionExpiry?.toIso8601String(),
    'roles': roles,
    'metadata': metadata,
  };

  /// Create from JSON
  factory Principal.fromJson(Map<String, dynamic> json) => Principal(
    id: json['id'] as String,
    email: json['email'] as String,
    sessionExpiry: json['sessionExpiry'] != null
        ? DateTime.parse(json['sessionExpiry'] as String)
        : null,
    roles: List<String>.from(json['roles'] ?? []),
    metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
  );

  @override
  String toString() => 'Principal(id: $id, email: $email, roles: $roles)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Principal &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email;

  @override
  int get hashCode => id.hashCode ^ email.hashCode;
}

/// Authentication state management
abstract class AuthState {
  static Principal? _currentPrincipal;
  static DateTime? _lastAuthCheck;

  /// Get the current authenticated principal
  static Principal? get currentPrincipal => _currentPrincipal;

  /// Check if there is an authenticated user
  static bool get isAuthenticated =>
      _currentPrincipal != null && _currentPrincipal!.isSessionValid;

  /// Set the current principal (used by auth providers)
  static void setPrincipal(Principal? principal) {
    logger.logDebug(
      'Setting principal: ${principal?.id ?? 'null'}',
      tag: 'AuthState',
    );
    _currentPrincipal = principal;
    _lastAuthCheck = DateTime.now();
  }

  /// Clear the current principal (logout)
  static void clearPrincipal() {
    logger.logDebug('Clearing principal', tag: 'AuthState');
    _currentPrincipal = null;
    _lastAuthCheck = null;
  }

  /// Get time of last authentication check
  static DateTime? get lastAuthCheck => _lastAuthCheck;
}

/// Rate limiting utilities
class RateLimiter {
  static final Map<String, List<DateTime>> _requestHistory = {};

  /// Check if the principal can make a request for the given operation
  static bool checkLimit(
    String principalId,
    String operation, {
    int maxRequests = 10,
    Duration timeWindow = const Duration(minutes: 1),
  }) {
    final key = '$principalId:$operation';
    final now = DateTime.now();

    // Get or create request history for this key
    _requestHistory[key] ??= [];
    final history = _requestHistory[key]!;

    // Remove old entries outside the time window
    history.removeWhere((timestamp) => now.difference(timestamp) > timeWindow);

    // Check if we're at the limit
    if (history.length >= maxRequests) {
      logger.logWarn(
        'Rate limit exceeded for $principalId on $operation',
        tag: 'RateLimiter',
      );
      return false;
    }

    // Record this request
    history.add(now);

    logger.logDebug(
      'Rate limit check passed for $principalId on $operation (${history.length}/$maxRequests)',
      tag: 'RateLimiter',
    );
    return true;
  }

  /// Reset rate limits for a principal (admin function)
  static void resetLimits(String principalId) {
    final keysToRemove = _requestHistory.keys
        .where((key) => key.startsWith('$principalId:'))
        .toList();

    for (final key in keysToRemove) {
      _requestHistory.remove(key);
    }

    logger.logDebug(
      'Rate limits reset for principal: $principalId',
      tag: 'RateLimiter',
    );
  }

  /// Clear all rate limiting data (for testing/maintenance)
  static void clearAll() {
    _requestHistory.clear();
    logger.logDebug('All rate limits cleared', tag: 'RateLimiter');
  }
}

/// Security policy configuration
class SecurityPolicy {
  /// Authentication session timeout
  static const Duration sessionTimeout = Duration(hours: 8);

  /// Rate limiting configuration
  static const Map<String, RateLimit> rateLimits = {
    'auth.login': RateLimit(maxRequests: 5, timeWindow: Duration(minutes: 1)),
    'auth.register': RateLimit(
      maxRequests: 3,
      timeWindow: Duration(minutes: 5),
    ),
    'auth.password_reset': RateLimit(
      maxRequests: 3,
      timeWindow: Duration(hours: 1),
    ),
    'listing.create': RateLimit(
      maxRequests: 10,
      timeWindow: Duration(minutes: 1),
    ),
    'listing.search': RateLimit(
      maxRequests: 30,
      timeWindow: Duration(minutes: 1),
    ),
    'profile.update': RateLimit(
      maxRequests: 3,
      timeWindow: Duration(minutes: 1),
    ),
    'transaction.create': RateLimit(
      maxRequests: 5,
      timeWindow: Duration(minutes: 1),
    ),
  };

  /// Check if an operation requires authentication
  static bool requiresAuth(String operation) {
    const unauthenticatedOperations = [
      'auth.login',
      'auth.register',
      'listing.search',
      'listing.view',
    ];
    return !unauthenticatedOperations.contains(operation);
  }

  /// Get rate limit for an operation
  static RateLimit? getRateLimit(String operation) => rateLimits[operation];
}

/// Rate limit configuration
class RateLimit {
  final int maxRequests;
  final Duration timeWindow;

  const RateLimit({required this.maxRequests, required this.timeWindow});
}

/// Auth guard utilities for protecting operations and routes
class AuthGuard {
  /// Check if current user is authenticated
  static bool isAuthenticated() {
    final authenticated = AuthState.isAuthenticated;

    logger.logDebug('Authentication check: $authenticated', tag: 'AuthGuard');

    return authenticated;
  }

  /// Require authentication, throw error if not authenticated
  static void requireAuth({String? operation}) {
    if (!isAuthenticated()) {
      logger.logWarn(
        'Authentication required for operation: ${operation ?? 'unknown'}',
        tag: 'AuthGuard',
      );
      throw AuthError.sessionExpired('Authentication required. Please log in.');
    }

    logger.logDebug(
      'Authentication requirement satisfied for: ${operation ?? 'operation'}',
      tag: 'AuthGuard',
    );
  }

  /// Check if current user has required role
  static bool hasRole(String requiredRole) {
    final principal = AuthState.currentPrincipal;
    if (principal == null) return false;

    final hasRole = principal.hasRole(requiredRole);

    logger.logDebug(
      'Role check for $requiredRole: $hasRole (user roles: ${principal.roles})',
      tag: 'AuthGuard',
    );

    return hasRole;
  }

  /// Require specific role, throw error if not authorized
  static void requireRole(String requiredRole, {String? operation}) {
    requireAuth(operation: operation);

    if (!hasRole(requiredRole)) {
      logger.logWarn(
        'Authorization failed: Required role $requiredRole for operation: ${operation ?? 'unknown'}',
        tag: 'AuthGuard',
      );
      throw AuthError.insufficientPrivileges(
        'You do not have permission to perform this action. Required role: $requiredRole',
      );
    }

    logger.logDebug(
      'Role requirement satisfied for $requiredRole',
      tag: 'AuthGuard',
    );
  }

  /// Check if current user has any of the required roles
  static bool hasAnyRole(List<String> requiredRoles) {
    final principal = AuthState.currentPrincipal;
    if (principal == null) return false;

    final hasRole = principal.hasAnyRole(requiredRoles);

    logger.logDebug(
      'Any role check for $requiredRoles: $hasRole (user roles: ${principal.roles})',
      tag: 'AuthGuard',
    );

    return hasRole;
  }

  /// Require any of the specified roles
  static void requireAnyRole(List<String> requiredRoles, {String? operation}) {
    requireAuth(operation: operation);

    if (!hasAnyRole(requiredRoles)) {
      logger.logWarn(
        'Authorization failed: Required any of roles $requiredRoles for operation: ${operation ?? 'unknown'}',
        tag: 'AuthGuard',
      );
      throw AuthError.insufficientPrivileges(
        'You do not have permission to perform this action. Required roles: ${requiredRoles.join(' or ')}',
      );
    }

    logger.logDebug(
      'Any role requirement satisfied for $requiredRoles',
      tag: 'AuthGuard',
    );
  }

  /// Check if a protected operation can be performed
  static bool canPerformOperation(String operation) {
    // Check authentication requirement
    if (SecurityPolicy.requiresAuth(operation) && !isAuthenticated()) {
      return false;
    }

    // Check rate limiting
    final principal = AuthState.currentPrincipal;
    if (principal != null) {
      final rateLimit = SecurityPolicy.getRateLimit(operation);
      if (rateLimit != null) {
        if (!RateLimiter.checkLimit(
          principal.id,
          operation,
          maxRequests: rateLimit.maxRequests,
          timeWindow: rateLimit.timeWindow,
        )) {
          return false;
        }
      }
    }

    logger.logDebug('Operation check passed for: $operation', tag: 'AuthGuard');

    return true;
  }

  /// Enforce security policy for an operation
  static void enforcePolicy(String operation) {
    // Check authentication
    if (SecurityPolicy.requiresAuth(operation)) {
      requireAuth(operation: operation);
    }

    // Check rate limiting
    final principal = AuthState.currentPrincipal;
    if (principal != null) {
      final rateLimit = SecurityPolicy.getRateLimit(operation);
      if (rateLimit != null) {
        if (!RateLimiter.checkLimit(
          principal.id,
          operation,
          maxRequests: rateLimit.maxRequests,
          timeWindow: rateLimit.timeWindow,
        )) {
          logger.logWarn(
            'Rate limit exceeded for operation: $operation',
            tag: 'AuthGuard',
            error: 'Principal: ${principal.id}',
          );
          throw BusinessLogicError.rateLimitExceeded(
            'Rate limit exceeded. Please try again later.',
          );
        }
      }
    }

    logger.logDebug(
      'Security policy enforced for operation: $operation',
      tag: 'AuthGuard',
    );
  }

  /// Get current principal or throw if not authenticated
  static Principal getCurrentPrincipal({String? operation}) {
    requireAuth(operation: operation);
    return AuthState.currentPrincipal!;
  }

  /// Check if session is about to expire (within 15 minutes)
  static bool isSessionNearExpiry() {
    final principal = AuthState.currentPrincipal;
    if (principal?.sessionExpiry == null) return false;

    final timeUntilExpiry = principal!.sessionExpiry!.difference(
      DateTime.now(),
    );
    return timeUntilExpiry <= const Duration(minutes: 15);
  }

  /// Validate session and refresh if needed
  static void validateSession() {
    final principal = AuthState.currentPrincipal;

    if (principal != null && !principal.isSessionValid) {
      logger.logWarn(
        'Session expired for principal: ${principal.id}',
        tag: 'AuthGuard',
      );
      AuthState.clearPrincipal();
      throw AuthError.sessionExpired(
        'Your session has expired. Please log in again.',
      );
    }

    if (isSessionNearExpiry()) {
      logger.logDebug(
        'Session nearing expiry for principal: ${principal?.id}',
        tag: 'AuthGuard',
      );
      // Note: Session refresh would be handled by auth provider
    }
  }
}

/// Service layer security mixin for enforcing auth guards
mixin ServiceSecurity {
  /// Execute a protected operation with security checks
  Future<T> executeProtected<T>(
    String operation,
    Future<T> Function() action, {
    List<String>? requiredRoles,
    String? requiredRole,
  }) async {
    try {
      // Log the operation attempt
      logger.logDebug(
        'Attempting protected operation: $operation',
        tag: 'ServiceSecurity',
      );

      // Enforce security policy
      AuthGuard.enforcePolicy(operation);

      // Check role requirements if specified
      if (requiredRole != null) {
        AuthGuard.requireRole(requiredRole, operation: operation);
      } else if (requiredRoles != null && requiredRoles.isNotEmpty) {
        AuthGuard.requireAnyRole(requiredRoles, operation: operation);
      }

      // Execute the action
      final result = await action();

      // Log successful execution
      logger.logDebug(
        'Protected operation completed successfully: $operation',
        tag: 'ServiceSecurity',
      );

      return result;
    } catch (e, stackTrace) {
      // Log security violation
      logger.logError(
        'Security violation in operation: $operation',
        tag: 'ServiceSecurity',
        error: e,
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }
}

/// Extension methods for adding auth guards to routes
extension AuthGuardRoutes on String {
  /// Check if this route requires authentication
  bool get requiresAuth {
    const protectedRoutes = [
      '/profile',
      '/dashboard',
      '/create-listing',
      '/my-listings',
      '/transactions',
      '/settings',
    ];

    return protectedRoutes.any((route) => startsWith(route));
  }

  /// Get required roles for this route
  List<String>? get requiredRoles {
    const roleBasedRoutes = <String, List<String>>{
      '/admin': ['admin'],
      '/moderator': ['moderator', 'admin'],
    };

    for (final entry in roleBasedRoutes.entries) {
      if (startsWith(entry.key)) {
        return entry.value;
      }
    }

    return null;
  }
}
