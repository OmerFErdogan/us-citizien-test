import 'package:flutter/material.dart';
import '../../utils/exceptions/app_exceptions.dart';

/// Generic error widget that can be used throughout the app
class ErrorDisplayWidget extends StatelessWidget {
  final AppException exception;
  final VoidCallback? onRetry;
  final String? customMessage;
  final bool showDetails;

  const ErrorDisplayWidget({
    Key? key,
    required this.exception,
    this.onRetry,
    this.customMessage,
    this.showDetails = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getErrorIcon(),
              size: 64,
              color: _getErrorColor(),
            ),
            const SizedBox(height: 16),
            Text(
              customMessage ?? exception.message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (showDetails && exception.code != null) ...[
              const SizedBox(height: 8),
              Text(
                'Error Code: ${exception.code}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getErrorIcon() {
    switch (exception.runtimeType) {
      case NetworkException:
        return Icons.wifi_off;
      case DataException:
        return Icons.error_outline;
      case StorageException:
        return Icons.storage;
      case ServiceException:
        return Icons.settings;
      case ValidationException:
        return Icons.warning;
      case MonetizationException:
        return Icons.payment;
      case LocalizationException:
        return Icons.language;
      default:
        return Icons.error;
    }
  }

  Color _getErrorColor() {
    switch (exception.runtimeType) {
      case NetworkException:
        return Colors.orange;
      case DataException:
        return Colors.red;
      case StorageException:
        return Colors.purple;
      case ValidationException:
        return Colors.amber;
      default:
        return Colors.red;
    }
  }
}

/// Loading state with error handling
class LoadingWithErrorWidget extends StatelessWidget {
  final Future future;
  final Widget Function(BuildContext context, dynamic data) builder;
  final Widget Function(BuildContext context, AppException error)? errorBuilder;
  final Widget? loadingWidget;
  final VoidCallback? onRetry;

  const LoadingWithErrorWidget({
    Key? key,
    required this.future,
    required this.builder,
    this.errorBuilder,
    this.loadingWidget,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingWidget ?? 
            const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          final error = snapshot.error;
          AppException appException;
          
          if (error is AppException) {
            appException = error;
          } else {
            appException = UnknownException(
              message: 'An unexpected error occurred',
              originalError: error,
            );
          }

          if (errorBuilder != null) {
            return errorBuilder!(context, appException);
          }

          return ErrorDisplayWidget(
            exception: appException,
            onRetry: onRetry,
            showDetails: true,
          );
        }

        if (snapshot.hasData) {
          return builder(context, snapshot.data);
        }

        return const Center(child: Text('No data available'));
      },
    );
  }
}

/// Error boundary widget for catching widget errors
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(BuildContext context, Object error, StackTrace? stackTrace)? errorBuilder;

  const ErrorBoundary({
    Key? key,
    required this.child,
    this.errorBuilder,
  }) : super(key: key);

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(context, _error!, _stackTrace);
      }

      return ErrorDisplayWidget(
        exception: UnknownException(
          message: 'Widget error occurred',
          originalError: _error,
        ),
        onRetry: () => setState(() {
          _error = null;
          _stackTrace = null;
        }),
        showDetails: true,
      );
    }

    return widget.child;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reset error state when dependencies change
    _error = null;
    _stackTrace = null;
  }

  // This would catch errors in a real error boundary implementation
  // Flutter doesn't have built-in error boundaries like React
  // But you can implement custom error handling here
}

/// Network status widget
class NetworkStatusWidget extends StatelessWidget {
  final Widget child;
  final bool isOnline;

  const NetworkStatusWidget({
    Key? key,
    required this.child,
    required this.isOnline,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!isOnline)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            color: Colors.red,
            child: const Text(
              'No internet connection',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          ),
        Expanded(child: child),
      ],
    );
  }
}
