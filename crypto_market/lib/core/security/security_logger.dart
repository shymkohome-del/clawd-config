import '../../core/logger/logger.dart';

/// Security event types for logging
enum SecurityEventType {
  authenticationAttempt,
  authenticationSuccess,
  authenticationFailure,
  authorizationSuccess,
  authorizationFailure,
  validationFailure,
  rateLimitViolation,
  suspiciousActivity,
  sessionExpiration,
  passwordChange,
  accountLocking,
  policyViolation,
  privilegeEscalation,
  dataAccess,
  gdprRequest,
}

/// Security event data structure
class SecurityEvent {
  final SecurityEventType type;
  final String operation;
  final String? principalId;
  final String? userEmail;
  final Map<String, dynamic> metadata;
  final DateTime timestamp;
  final String? error;
  final String? stackTrace;
  final String? ipAddress;
  final String? userAgent;

  const SecurityEvent({
    required this.type,
    required this.operation,
    this.principalId,
    this.userEmail,
    this.metadata = const {},
    required this.timestamp,
    this.error,
    this.stackTrace,
    this.ipAddress,
    this.userAgent,
  });

  /// Create authentication attempt event
  factory SecurityEvent.authAttempt({
    required String email,
    required String operation,
    String? ipAddress,
    Map<String, dynamic>? metadata,
  }) => SecurityEvent(
    type: SecurityEventType.authenticationAttempt,
    operation: operation,
    userEmail: email,
    timestamp: DateTime.now(),
    ipAddress: ipAddress,
    metadata: metadata ?? {},
  );

  /// Create authentication success event
  factory SecurityEvent.authSuccess({
    required String principalId,
    required String email,
    required String operation,
    String? ipAddress,
    Map<String, dynamic>? metadata,
  }) => SecurityEvent(
    type: SecurityEventType.authenticationSuccess,
    operation: operation,
    principalId: principalId,
    userEmail: email,
    timestamp: DateTime.now(),
    ipAddress: ipAddress,
    metadata: metadata ?? {},
  );

  /// Create authentication failure event
  factory SecurityEvent.authFailure({
    required String email,
    required String operation,
    required String error,
    String? ipAddress,
    Map<String, dynamic>? metadata,
  }) => SecurityEvent(
    type: SecurityEventType.authenticationFailure,
    operation: operation,
    userEmail: email,
    timestamp: DateTime.now(),
    error: error,
    ipAddress: ipAddress,
    metadata: metadata ?? {},
  );

  /// Create authorization failure event
  factory SecurityEvent.authzFailure({
    required String principalId,
    required String operation,
    required String error,
    List<String>? requiredRoles,
    List<String>? userRoles,
    Map<String, dynamic>? metadata,
  }) => SecurityEvent(
    type: SecurityEventType.authorizationFailure,
    operation: operation,
    principalId: principalId,
    timestamp: DateTime.now(),
    error: error,
    metadata: {
      ...metadata ?? {},
      if (requiredRoles != null) 'requiredRoles': requiredRoles,
      if (userRoles != null) 'userRoles': userRoles,
    },
  );

  /// Create validation failure event
  factory SecurityEvent.validationFailure({
    required String operation,
    required List<String> errors,
    String? principalId,
    String? field,
    Map<String, dynamic>? metadata,
  }) => SecurityEvent(
    type: SecurityEventType.validationFailure,
    operation: operation,
    principalId: principalId,
    timestamp: DateTime.now(),
    error: errors.join(', '),
    metadata: {
      ...metadata ?? {},
      'validationErrors': errors,
      if (field != null) 'field': field,
    },
  );

  /// Create rate limit violation event
  factory SecurityEvent.rateLimitViolation({
    required String principalId,
    required String operation,
    required int currentCount,
    required int limit,
    required Duration timeWindow,
    String? ipAddress,
    Map<String, dynamic>? metadata,
  }) => SecurityEvent(
    type: SecurityEventType.rateLimitViolation,
    operation: operation,
    principalId: principalId,
    timestamp: DateTime.now(),
    ipAddress: ipAddress,
    error:
        'Rate limit exceeded: $currentCount/$limit in ${timeWindow.inMinutes}min',
    metadata: {
      ...metadata ?? {},
      'currentCount': currentCount,
      'limit': limit,
      'timeWindowMinutes': timeWindow.inMinutes,
    },
  );

  /// Create suspicious activity event
  factory SecurityEvent.suspiciousActivity({
    required String operation,
    required String description,
    String? principalId,
    String? ipAddress,
    Map<String, dynamic>? metadata,
  }) => SecurityEvent(
    type: SecurityEventType.suspiciousActivity,
    operation: operation,
    principalId: principalId,
    timestamp: DateTime.now(),
    ipAddress: ipAddress,
    error: description,
    metadata: metadata ?? {},
  );

  /// Create session expiration event
  factory SecurityEvent.sessionExpired({
    required String principalId,
    required DateTime expirationTime,
    Map<String, dynamic>? metadata,
  }) => SecurityEvent(
    type: SecurityEventType.sessionExpiration,
    operation: 'session.expired',
    principalId: principalId,
    timestamp: DateTime.now(),
    metadata: {
      ...metadata ?? {},
      'expirationTime': expirationTime.toIso8601String(),
    },
  );

  /// Create GDPR request event
  factory SecurityEvent.gdprRequest({
    required String principalId,
    required String requestType,
    String? email,
    Map<String, dynamic>? metadata,
  }) => SecurityEvent(
    type: SecurityEventType.gdprRequest,
    operation: 'gdpr.$requestType',
    principalId: principalId,
    userEmail: email,
    timestamp: DateTime.now(),
    metadata: {...metadata ?? {}, 'requestType': requestType},
  );

  /// Convert to JSON for logging
  Map<String, dynamic> toJson() => {
    'type': type.name,
    'operation': operation,
    if (principalId != null) 'principalId': principalId,
    if (userEmail != null) 'userEmail': userEmail,
    'timestamp': timestamp.toIso8601String(),
    if (error != null) 'error': error,
    if (stackTrace != null) 'stackTrace': stackTrace,
    if (ipAddress != null) 'ipAddress': ipAddress,
    if (userAgent != null) 'userAgent': userAgent,
    'metadata': metadata,
  };

  /// Convert to formatted log string
  String toLogString() {
    final buffer = StringBuffer();
    buffer.writeln('SECURITY EVENT: ${type.name}');
    buffer.writeln('Operation: $operation');
    buffer.writeln('Timestamp: ${timestamp.toIso8601String()}');

    if (principalId != null) buffer.writeln('Principal ID: $principalId');
    if (userEmail != null) buffer.writeln('User Email: $userEmail');
    if (ipAddress != null) buffer.writeln('IP Address: $ipAddress');
    if (error != null) buffer.writeln('Error: $error');

    if (metadata.isNotEmpty) {
      buffer.writeln('Metadata:');
      metadata.forEach((key, value) {
        buffer.writeln('  $key: $value');
      });
    }

    if (stackTrace != null) {
      buffer.writeln('Stack Trace:');
      buffer.writeln(stackTrace);
    }

    return buffer.toString();
  }

  @override
  String toString() => 'SecurityEvent(${type.name}: $operation)';
}

/// Security logger for handling security-specific events
class SecurityLogger {
  static SecurityLogger? _instance;
  static SecurityLogger get instance => _instance ??= SecurityLogger._();

  SecurityLogger._();

  bool _isEnabled = true;
  final List<SecurityEvent> _eventBuffer = [];

  /// Initialize security logging
  void initialize({bool enabled = true}) {
    _isEnabled = enabled;
    logger.logDebug(
      'Security logger initialized: enabled=$enabled',
      tag: 'SecurityLogger',
    );
  }

  /// Log a security event
  void logEvent(SecurityEvent event) {
    if (!_isEnabled) return;

    // Add to buffer (for potential analysis)
    _eventBuffer.add(event);

    // Keep buffer size manageable (last 1000 events)
    if (_eventBuffer.length > 1000) {
      _eventBuffer.removeAt(0);
    }

    // Log based on event severity
    switch (event.type) {
      case SecurityEventType.authenticationFailure:
      case SecurityEventType.authorizationFailure:
      case SecurityEventType.rateLimitViolation:
      case SecurityEventType.suspiciousActivity:
      case SecurityEventType.policyViolation:
      case SecurityEventType.privilegeEscalation:
        logger.logError(
          event.toLogString(),
          tag: 'Security',
          error: event.error,
        );
        break;

      case SecurityEventType.validationFailure:
      case SecurityEventType.sessionExpiration:
      case SecurityEventType.accountLocking:
        logger.logWarn(event.toLogString(), tag: 'Security');
        break;

      case SecurityEventType.authenticationSuccess:
      case SecurityEventType.authorizationSuccess:
      case SecurityEventType.passwordChange:
      case SecurityEventType.gdprRequest:
        logger.logInfo(event.toLogString(), tag: 'Security');
        break;

      case SecurityEventType.authenticationAttempt:
      case SecurityEventType.dataAccess:
        logger.logDebug(event.toLogString(), tag: 'Security');
        break;
    }
  }

  /// Log authentication attempt
  void logAuthAttempt({
    required String email,
    required String operation,
    String? ipAddress,
    Map<String, dynamic>? metadata,
  }) {
    logEvent(
      SecurityEvent.authAttempt(
        email: email,
        operation: operation,
        ipAddress: ipAddress,
        metadata: metadata,
      ),
    );
  }

  /// Log authentication success
  void logAuthSuccess({
    required String principalId,
    required String email,
    required String operation,
    String? ipAddress,
    Map<String, dynamic>? metadata,
  }) {
    logEvent(
      SecurityEvent.authSuccess(
        principalId: principalId,
        email: email,
        operation: operation,
        ipAddress: ipAddress,
        metadata: metadata,
      ),
    );
  }

  /// Log authentication failure
  void logAuthFailure({
    required String email,
    required String operation,
    required String error,
    String? ipAddress,
    Map<String, dynamic>? metadata,
  }) {
    logEvent(
      SecurityEvent.authFailure(
        email: email,
        operation: operation,
        error: error,
        ipAddress: ipAddress,
        metadata: metadata,
      ),
    );
  }

  /// Log authorization failure
  void logAuthzFailure({
    required String principalId,
    required String operation,
    required String error,
    List<String>? requiredRoles,
    List<String>? userRoles,
    Map<String, dynamic>? metadata,
  }) {
    logEvent(
      SecurityEvent.authzFailure(
        principalId: principalId,
        operation: operation,
        error: error,
        requiredRoles: requiredRoles,
        userRoles: userRoles,
        metadata: metadata,
      ),
    );
  }

  /// Log validation failure
  void logValidationFailure({
    required String operation,
    required List<String> errors,
    String? principalId,
    String? field,
    Map<String, dynamic>? metadata,
  }) {
    logEvent(
      SecurityEvent.validationFailure(
        operation: operation,
        errors: errors,
        principalId: principalId,
        field: field,
        metadata: metadata,
      ),
    );
  }

  /// Log rate limit violation
  void logRateLimitViolation({
    required String principalId,
    required String operation,
    required int currentCount,
    required int limit,
    required Duration timeWindow,
    String? ipAddress,
    Map<String, dynamic>? metadata,
  }) {
    logEvent(
      SecurityEvent.rateLimitViolation(
        principalId: principalId,
        operation: operation,
        currentCount: currentCount,
        limit: limit,
        timeWindow: timeWindow,
        ipAddress: ipAddress,
        metadata: metadata,
      ),
    );
  }

  /// Log suspicious activity
  void logSuspiciousActivity({
    required String operation,
    required String description,
    String? principalId,
    String? ipAddress,
    Map<String, dynamic>? metadata,
  }) {
    logEvent(
      SecurityEvent.suspiciousActivity(
        operation: operation,
        description: description,
        principalId: principalId,
        ipAddress: ipAddress,
        metadata: metadata,
      ),
    );
  }

  /// Log session expiration
  void logSessionExpired({
    required String principalId,
    required DateTime expirationTime,
    Map<String, dynamic>? metadata,
  }) {
    logEvent(
      SecurityEvent.sessionExpired(
        principalId: principalId,
        expirationTime: expirationTime,
        metadata: metadata,
      ),
    );
  }

  /// Log GDPR/CCPA request
  void logGdprRequest({
    required String principalId,
    required String requestType,
    String? email,
    Map<String, dynamic>? metadata,
  }) {
    logEvent(
      SecurityEvent.gdprRequest(
        principalId: principalId,
        requestType: requestType,
        email: email,
        metadata: metadata,
      ),
    );
  }

  /// Get recent security events (for analysis/debugging)
  List<SecurityEvent> getRecentEvents({
    int? limit,
    SecurityEventType? type,
    String? operation,
    Duration? since,
  }) {
    var events = _eventBuffer.toList();

    // Filter by time if specified
    if (since != null) {
      final cutoff = DateTime.now().subtract(since);
      events = events.where((e) => e.timestamp.isAfter(cutoff)).toList();
    }

    // Filter by type if specified
    if (type != null) {
      events = events.where((e) => e.type == type).toList();
    }

    // Filter by operation if specified
    if (operation != null) {
      events = events.where((e) => e.operation == operation).toList();
    }

    // Sort by timestamp (newest first)
    events.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    // Apply limit if specified
    if (limit != null && events.length > limit) {
      events = events.take(limit).toList();
    }

    return events;
  }

  /// Check for security patterns/anomalies (basic implementation)
  List<String> analyzeSecurityPatterns({Duration? timeWindow}) {
    final patterns = <String>[];
    final window = timeWindow ?? const Duration(minutes: 10);
    final cutoff = DateTime.now().subtract(window);
    final recentEvents = _eventBuffer
        .where((e) => e.timestamp.isAfter(cutoff))
        .toList();

    // Check for repeated authentication failures
    final authFailures = recentEvents
        .where((e) => e.type == SecurityEventType.authenticationFailure)
        .toList();

    if (authFailures.length >= 5) {
      final emails = authFailures
          .map((e) => e.userEmail)
          .where((e) => e != null)
          .toSet();
      if (emails.length == 1) {
        patterns.add('Repeated authentication failures for ${emails.first}');
      } else if (emails.length <= 3) {
        patterns.add('Multiple authentication failures from few accounts');
      }
    }

    // Check for rate limit violations
    final rateLimitEvents = recentEvents
        .where((e) => e.type == SecurityEventType.rateLimitViolation)
        .toList();

    if (rateLimitEvents.length >= 3) {
      patterns.add('Multiple rate limit violations detected');
    }

    // Check for suspicious activity
    final suspiciousEvents = recentEvents
        .where((e) => e.type == SecurityEventType.suspiciousActivity)
        .toList();

    if (suspiciousEvents.isNotEmpty) {
      patterns.add(
        '${suspiciousEvents.length} suspicious activity event(s) detected',
      );
    }

    return patterns;
  }

  /// Clear event buffer (for testing/maintenance)
  void clearEvents() {
    _eventBuffer.clear();
    logger.logDebug('Security event buffer cleared', tag: 'SecurityLogger');
  }

  /// Get event statistics
  Map<String, int> getEventStats({Duration? timeWindow}) {
    final window = timeWindow ?? const Duration(hours: 24);
    final cutoff = DateTime.now().subtract(window);
    final recentEvents = _eventBuffer
        .where((e) => e.timestamp.isAfter(cutoff))
        .toList();

    final stats = <String, int>{};

    for (final event in recentEvents) {
      stats[event.type.name] = (stats[event.type.name] ?? 0) + 1;
    }

    return stats;
  }

  /// Enable/disable security logging
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
    logger.logDebug(
      'Security logging ${enabled ? 'enabled' : 'disabled'}',
      tag: 'SecurityLogger',
    );
  }

  /// Check if security logging is enabled
  bool get isEnabled => _isEnabled;
}

/// Global security logger instance
final SecurityLogger securityLogger = SecurityLogger.instance;
