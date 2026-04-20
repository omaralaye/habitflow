import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Levels of logging for the application.
enum LogLevel { info, warning, error, action }

/// A centralized logging service that handles errors, warnings, and key user actions.
class LoggerService {
  static final LoggerService _instance = LoggerService._internal();

  factory LoggerService() => _instance;

  LoggerService._internal();

  /// Logs an informational message.
  void info(String message, {String? tag, Map<String, dynamic>? data}) {
    _log(LogLevel.info, message, tag: tag, data: data);
  }

  /// Logs a warning message.
  void warning(String message, {String? tag, Object? error, StackTrace? stackTrace, Map<String, dynamic>? data}) {
    _log(LogLevel.warning, message, tag: tag, error: error, stackTrace: stackTrace, data: data);
  }

  /// Logs an error message.
  void error(String message, {String? tag, Object? error, StackTrace? stackTrace, Map<String, dynamic>? data}) {
    _log(LogLevel.error, message, tag: tag, error: error, stackTrace: stackTrace, data: data);
  }

  /// Logs a key user action.
  void action(String message, {String? tag, Map<String, dynamic>? data}) {
    _log(LogLevel.action, message, tag: tag, data: data);
  }

  void _log(LogLevel level, String message, {String? tag, Object? error, StackTrace? stackTrace, Map<String, dynamic>? data}) {
    final timestamp = DateTime.now().toIso8601String();
    final levelName = level.name.toUpperCase();
    final tagPart = tag != null ? '[$tag] ' : '';
    final dataPart = data != null ? ' | Data: $data' : '';

    final fullLogMessage = '[$timestamp] $levelName: $tagPart$message$dataPart';

    if (kDebugMode) {
      // In debug mode, we also print to the console for immediate visibility.
      debugPrint(fullLogMessage);
      if (error != null) debugPrint('Error: $error');
      if (stackTrace != null) debugPrint('StackTrace: $stackTrace');
    }

    // Use developer.log for integration with Flutter DevTools and native logging systems.
    developer.log(
      message,
      time: DateTime.now(),
      level: _getDeveloperLevel(level),
      name: tag ?? 'APP',
      error: error,
      stackTrace: stackTrace,
    );
  }

  int _getDeveloperLevel(LogLevel level) {
    switch (level) {
      case LogLevel.info:
        return 800; // INFO level in developer.log
      case LogLevel.warning:
        return 900; // WARNING level
      case LogLevel.error:
        return 1000; // SEVERE level
      case LogLevel.action:
        return 800; // INFO level
    }
  }
}
