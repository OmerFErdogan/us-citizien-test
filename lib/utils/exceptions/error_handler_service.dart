import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../exceptions/app_exceptions.dart';

/// Error types for different handling strategies
enum ErrorSeverity {
  low,      // Just log, show small snackbar
  medium,   // Show dialog, allow retry
  high,     // Show dialog, might require app restart
  critical, // Force app restart or close
}

/// Error report model
class ErrorReport {
  final AppException exception;
  final StackTrace? stackTrace;
  final DateTime timestamp;
  final ErrorSeverity severity;
  final Map<String, dynamic>? context;

  ErrorReport({
    required this.exception,
    this.stackTrace,
    required this.timestamp,
    required this.severity,
    this.context,
  });

  Map<String, dynamic> toJson() => {
    'message': exception.message,
    'code': exception.code,
    'severity': severity.name,
    'timestamp': timestamp.toIso8601String(),
    'context': context,
    'stackTrace': stackTrace?.toString(),
  };
}

/// Global error handler service
class ErrorHandlerService {
  static final ErrorHandlerService _instance = ErrorHandlerService._internal();
  factory ErrorHandlerService() => _instance;
  ErrorHandlerService._internal();

  final StreamController<ErrorReport> _errorStreamController = 
      StreamController<ErrorReport>.broadcast();
  
  Stream<ErrorReport> get errorStream => _errorStreamController.stream;

  /// Handle errors with appropriate strategy
  Future<void> handleError({
    required AppException exception,
    StackTrace? stackTrace,
    ErrorSeverity severity = ErrorSeverity.medium,
    Map<String, dynamic>? context,
    BuildContext? buildContext,
  }) async {
    final errorReport = ErrorReport(
      exception: exception,
      stackTrace: stackTrace,
      timestamp: DateTime.now(),
      severity: severity,
      context: context,
    );

    // Log error
    _logError(errorReport);

    // Send to error stream for widgets to listen
    _errorStreamController.add(errorReport);

    // Show appropriate UI feedback
    if (buildContext != null && buildContext.mounted) {
      await _showErrorUI(buildContext, errorReport);
    }

    // Report to analytics (in production)
    if (kReleaseMode) {
      await _reportToAnalytics(errorReport);
    }
  }

  /// Log error with detailed information
  void _logError(ErrorReport report) {
    final timestamp = report.timestamp.toIso8601String();
    final severity = report.severity.name.toUpperCase();
    
    debugPrint('🚨 [$severity] $timestamp: ${report.exception.message}');
    
    if (report.exception.code != null) {
      debugPrint('   Code: ${report.exception.code}');
    }
    
    if (report.context != null) {
      debugPrint('   Context: ${report.context}');
    }
    
    if (report.stackTrace != null && kDebugMode) {
      debugPrint('   Stack Trace:\n${report.stackTrace}');
    }
  }

  /// Show appropriate UI feedback based on error severity
  Future<void> _showErrorUI(BuildContext context, ErrorReport report) async {
    switch (report.severity) {
      case ErrorSeverity.low:
        _showSnackBar(context, report);
        break;
      case ErrorSeverity.medium:
        await _showErrorDialog(context, report);
        break;
      case ErrorSeverity.high:
        await _showCriticalErrorDialog(context, report);
        break;
      case ErrorSeverity.critical:
        await _showFatalErrorDialog(context, report);
        break;
    }
  }

  /// Show simple snackbar for low severity errors
  void _showSnackBar(BuildContext context, ErrorReport report) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(report.exception.message),
        backgroundColor: Colors.orange,
        action: SnackBarAction(
          label: 'Dismiss',
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  /// Show error dialog for medium severity errors
  Future<void> _showErrorDialog(BuildContext context, ErrorReport report) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: const Icon(Icons.error_outline, color: Colors.red),
          title: const Text('Error'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(report.exception.message),
                if (report.exception.code != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Error Code: ${report.exception.code}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
            if (_canRetry(report.exception))
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _retry(context, report);
                },
                child: const Text('Retry'),
              ),
          ],
        );
      },
    );
  }

  /// Show critical error dialog
  Future<void> _showCriticalErrorDialog(BuildContext context, ErrorReport report) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: const Icon(Icons.warning, color: Colors.red),
          title: const Text('Critical Error'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(report.exception.message),
              const SizedBox(height: 16),
              const Text(
                'The app may not function properly. Please restart the application.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Continue'),
            ),
            TextButton(
              onPressed: () => _restartApp(),
              child: const Text('Restart App'),
            ),
          ],
        );
      },
    );
  }

  /// Show fatal error dialog
  Future<void> _showFatalErrorDialog(BuildContext context, ErrorReport report) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: const Icon(Icons.error, color: Colors.red),
          title: const Text('Fatal Error'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(report.exception.message),
              const SizedBox(height: 16),
              const Text(
                'The application cannot continue and will be closed.',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => _closeApp(),
              child: const Text('Close App'),
            ),
          ],
        );
      },
    );
  }

  /// Check if error is retryable
  bool _canRetry(AppException exception) {
    return exception is NetworkException || 
           exception is DataException ||
           exception is ServiceException;
  }

  /// Retry logic for retryable errors
  void _retry(BuildContext context, ErrorReport report) {
    // This would trigger a retry mechanism
    // Implementation depends on the specific error type
    debugPrint('🔄 Retrying operation for: ${report.exception.message}');
  }

  /// Restart app logic
  void _restartApp() {
    // In a real app, you might use packages like restart_app
    debugPrint('🔄 Restarting application...');
    exit(0);
  }

  /// Close app logic
  void _closeApp() {
    debugPrint('❌ Closing application...');
    exit(1);
  }

  /// Report to analytics (Firebase Crashlytics, etc.)
  Future<void> _reportToAnalytics(ErrorReport report) async {
    try {
      // In production, report to Firebase Crashlytics or similar
      debugPrint('📊 Reporting error to analytics: ${report.exception.message}');
      
      // Example implementation:
      // await FirebaseCrashlytics.instance.recordError(
      //   report.exception,
      //   report.stackTrace,
      //   fatal: report.severity == ErrorSeverity.critical,
      // );
    } catch (e) {
      debugPrint('Failed to report error to analytics: $e');
    }
  }

  /// Convert common exceptions to AppExceptions
  static AppException convertException(dynamic error, [StackTrace? stackTrace]) {
    if (error is AppException) return error;

    if (error is SocketException) {
      return NetworkException(
        message: 'No internet connection. Please check your network settings.',
        code: 'NETWORK_ERROR',
        originalError: error,
      );
    }

    if (error is TimeoutException) {
      return NetworkException(
        message: 'Request timed out. Please try again.',
        code: 'TIMEOUT_ERROR',
        originalError: error,
      );
    }

    if (error is FormatException) {
      return DataException(
        message: 'Invalid data format received.',
        code: 'FORMAT_ERROR',
        originalError: error,
      );
    }

    // Default to unknown exception
    return UnknownException(
      message: 'An unexpected error occurred: ${error.toString()}',
      code: 'UNKNOWN_ERROR',
      originalError: error,
    );
  }

  /// Dispose resources
  void dispose() {
    _errorStreamController.close();
  }
}
