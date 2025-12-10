import 'package:flutter/foundation.dart';

/// Centralized logging service for the app
/// Replace all print() statements with this logger
class AppLogger {
  static const String _appTag = '[FreeJobAlert]';

  /// Log informational messages
  static void info(String message, [String? tag]) {
    if (kDebugMode) {
      final logTag = tag ?? _appTag;
      debugPrint('$logTag ℹ️ $message');
    }
  }

  /// Log warning messages
  static void warning(String message, [String? tag]) {
    if (kDebugMode) {
      final logTag = tag ?? _appTag;
      debugPrint('$logTag ⚠️ $message');
    }
  }

  /// Log error messages with optional error object and stack trace
  static void error(String message, [Object? error, StackTrace? stackTrace, String? tag]) {
    if (kDebugMode) {
      final logTag = tag ?? _appTag;
      debugPrint('$logTag ❌ ERROR: $message');
      if (error != null) {
        debugPrint('$logTag ❌ Error details: $error');
      }
      if (stackTrace != null) {
        debugPrint('$logTag ❌ Stack trace:\n$stackTrace');
      }
    }

    // In production, send to crash reporting service
    // Example: FirebaseCrashlytics.instance.recordError(error, stackTrace, reason: message);
  }

  /// Log success messages
  static void success(String message, [String? tag]) {
    if (kDebugMode) {
      final logTag = tag ?? _appTag;
      debugPrint('$logTag ✅ $message');
    }
  }

  /// Log debug messages (only in debug mode)
  static void debug(String message, [String? tag]) {
    if (kDebugMode) {
      final logTag = tag ?? _appTag;
      debugPrint('$logTag 🔍 DEBUG: $message');
    }
  }

  /// Log API calls
  static void api(String endpoint, {String? method, Map<String, dynamic>? params}) {
    if (kDebugMode) {
      final msg = StringBuffer('API ${method ?? 'CALL'}: $endpoint');
      if (params != null && params.isNotEmpty) {
        msg.write(' | Params: $params');
      }
      debugPrint('$_appTag 🌐 $msg');
    }
  }

  /// Log navigation events
  static void navigation(String from, String to) {
    if (kDebugMode) {
      debugPrint('$_appTag 🧭 Navigation: $from → $to');
    }
  }

  /// Log ad events
  static void ad(String event, [String? adType]) {
    if (kDebugMode) {
      final type = adType != null ? '[$adType]' : '';
      debugPrint('$_appTag 📢 Ad $type: $event');
    }
  }

  /// Log Firebase events
  static void firebase(String event, [Map<String, dynamic>? params]) {
    if (kDebugMode) {
      final msg = StringBuffer('Firebase: $event');
      if (params != null && params.isNotEmpty) {
        msg.write(' | $params');
      }
      debugPrint('$_appTag 🔥 $msg');
    }
  }
}
