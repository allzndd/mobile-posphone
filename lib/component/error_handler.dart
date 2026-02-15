import 'package:flutter/material.dart';
import 'erorr_page.dart';
import 'maintenance_page.dart';

/// Helper class untuk menangani error dari API response
class ErrorHandler {
  /// Handle HTTP error response dan tampilkan error page yang sesuai
  static void handleApiError(
    BuildContext context, {
    required int statusCode,
    String? errorMessage,
    VoidCallback? onRetry,
    VoidCallback? onGoBack,
  }) {
    // Jika status code 503, tampilkan maintenance page
    if (statusCode == 503) {
      MaintenancePage.show(
        context,
        title: 'Service Under Maintenance',
        message: errorMessage ??
            'The service is temporarily unavailable due to maintenance. Please try again later.',
        onCheckStatus: onRetry,
      );
      return;
    }

    // Untuk error lainnya, tampilkan error page
    ErrorPage.show(
      context,
      statusCode: statusCode,
      errorMessage: errorMessage,
      onRetry: onRetry,
      onGoBack: onGoBack,
    );
  }

  /// Show error dialog (untuk error yang tidak perlu full page)
  static Future<void> showErrorDialog(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onRetry,
  }) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red),
              const SizedBox(width: 8),
              Expanded(child: Text(title)),
            ],
          ),
          content: Text(message),
          actions: [
            if (onRetry != null)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onRetry();
                },
                child: const Text('Retry'),
              ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  /// Show maintenance dialog
  static Future<void> showMaintenanceDialog(
    BuildContext context, {
    String? title,
    String? message,
    VoidCallback? onCheckStatus,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.construction, color: Colors.orange),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title ?? 'System Maintenance'),
              ),
            ],
          ),
          content: Text(
            message ??
                'The system is currently under maintenance. Please try again later.',
          ),
          actions: [
            if (onCheckStatus != null)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onCheckStatus();
                },
                child: const Text('Check Status'),
              ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /// Parse error dari API response dan dapatkan status code + message
  static Map<String, dynamic> parseApiError(dynamic error) {
    // Default values
    int statusCode = 500;
    String message = 'An unexpected error occurred';

    try {
      if (error is Map) {
        // Check for status code
        if (error.containsKey('status_code')) {
          statusCode = error['status_code'] as int;
        } else if (error.containsKey('statusCode')) {
          statusCode = error['statusCode'] as int;
        } else if (error.containsKey('code')) {
          statusCode = error['code'] as int;
        }

        // Check for message
        if (error.containsKey('message')) {
          message = error['message'] as String;
        } else if (error.containsKey('error')) {
          message = error['error'] as String;
        } else if (error.containsKey('msg')) {
          message = error['msg'] as String;
        }
      } else if (error is String) {
        message = error;
      }
    } catch (e) {
      // If parsing fails, use defaults
      debugPrint('Error parsing API error: $e');
    }

    return {
      'statusCode': statusCode,
      'message': message,
    };
  }

  /// Get user-friendly error message based on status code
  static String getErrorMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check your input.';
      case 401:
        return 'You need to login to access this resource.';
      case 403:
        return 'You don\'t have permission to access this resource.';
      case 404:
        return 'The requested resource was not found.';
      case 405:
        return 'Method not allowed.';
      case 408:
        return 'Request timeout. Please try again.';
      case 422:
        return 'Validation error. Please check your input.';
      case 429:
        return 'Too many requests. Please slow down.';
      case 500:
        return 'Internal server error. Please try again later.';
      case 502:
        return 'Bad gateway. Please try again.';
      case 503:
        return 'Service unavailable. Please try again later.';
      case 504:
        return 'Gateway timeout. Please try again.';
      default:
        return 'An unexpected error occurred.';
    }
  }

  /// Check if error is network related
  static bool isNetworkError(dynamic error) {
    if (error is String) {
      final errorLower = error.toLowerCase();
      return errorLower.contains('network') ||
          errorLower.contains('connection') ||
          errorLower.contains('timeout') ||
          errorLower.contains('socket');
    }
    return false;
  }

  /// Check if service is in maintenance mode
  static bool isMaintenanceMode(int statusCode) {
    return statusCode == 503;
  }
}
