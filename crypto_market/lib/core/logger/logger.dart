import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Log levels for the application
enum LogLevel {
  debug('DEBUG'),
  info('INFO'),
  warn('WARN'),
  error('ERROR');

  const LogLevel(this.label);
  final String label;

  int get priority {
    switch (this) {
      case LogLevel.debug:
        return 0;
      case LogLevel.info:
        return 1;
      case LogLevel.warn:
        return 2;
      case LogLevel.error:
        return 3;
    }
  }
}

/// Main logger utility for the application
/// Provides consistent logging across frontend and canister calls
class Logger {
  static Logger? _instance;
  static Logger get instance => _instance ??= Logger._();

  Logger._();

  LogLevel _minLevel = LogLevel.debug;
  bool _fileLoggingEnabled = false;
  String? _debugLogPath;

  /// Initialize the logger with optional file logging for dev builds
  Future<void> initialize({
    LogLevel minLevel = LogLevel.debug,
    bool enableFileLogging = false,
  }) async {
    _minLevel = minLevel;
    _fileLoggingEnabled = enableFileLogging && kDebugMode;

    if (_fileLoggingEnabled) {
      try {
        // Honor debug log path from core-config (.ai/debug-log.md)
        final Directory appDir = await getApplicationDocumentsDirectory();
        _debugLogPath = '${appDir.parent.path}/.ai/debug-log.md';

        // Ensure the .ai directory exists
        final debugDir = Directory('${appDir.parent.path}/.ai');
        if (!await debugDir.exists()) {
          await debugDir.create(recursive: true);
        }

        // Initialize debug log file if it doesn't exist
        final debugFile = File(_debugLogPath!);
        if (!await debugFile.exists()) {
          await debugFile.writeAsString('# Debug Log\n\n');
        }
      } catch (e) {
        // If file logging fails, continue with console-only logging
        _fileLoggingEnabled = false;
        developer.log(
          'Failed to initialize file logging: $e',
          name: 'Logger',
          level: LogLevel.warn.priority,
        );
      }
    }
  }

  /// Log debug message
  void logDebug(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.debug,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log info message
  void logInfo(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.info,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log warning message
  void logWarn(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.warn,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log error message
  void logError(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.error,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  void _log(
    LogLevel level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (level.priority < _minLevel.priority) {
      return;
    }

    final String timestamp = DateTime.now().toIso8601String();
    final String logTag = tag ?? 'App';
    final String fullMessage =
        '[$timestamp] [${level.label}] [$logTag] $message';

    // Log to console using dart:developer for better integration with Flutter DevTools
    developer.log(
      message,
      name: logTag,
      level: level.priority * 100, // Scale for dart:developer levels
      error: error,
      stackTrace: stackTrace,
    );

    // Log to file if enabled (dev builds only)
    if (_fileLoggingEnabled && _debugLogPath != null) {
      _logToFile(fullMessage, error, stackTrace);
    }
  }

  Future<void> _logToFile(
    String message,
    Object? error,
    StackTrace? stackTrace,
  ) async {
    try {
      final file = File(_debugLogPath!);
      final StringBuffer buffer = StringBuffer();

      buffer.writeln('## ${DateTime.now().toIso8601String()}');
      buffer.writeln(message);

      if (error != null) {
        buffer.writeln('**Error:** $error');
      }

      if (stackTrace != null) {
        buffer.writeln('**Stack Trace:**');
        buffer.writeln('```');
        buffer.writeln(stackTrace.toString());
        buffer.writeln('```');
      }

      buffer.writeln('');

      // Append to file
      await file.writeAsString(buffer.toString(), mode: FileMode.append);
    } catch (e) {
      // If file writing fails, log to console only
      developer.log(
        'Failed to write to debug log file: $e',
        name: 'Logger',
        level: LogLevel.error.priority,
      );
    }
  }

  /// Clear the debug log file
  Future<void> clearDebugLog() async {
    if (_debugLogPath != null) {
      try {
        final file = File(_debugLogPath!);
        await file.writeAsString('# Debug Log\n\n');
      } catch (e) {
        logError('Failed to clear debug log: $e', tag: 'Logger');
      }
    }
  }
}

/// Global logger instance for easy access
final Logger logger = Logger.instance;
