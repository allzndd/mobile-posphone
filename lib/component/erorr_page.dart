import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme_provider.dart';

class ErrorPage extends StatelessWidget {
  final int? statusCode;
  final String? errorMessage;
  final String? errorTitle;
  final VoidCallback? onRetry;
  final VoidCallback? onGoBack;

  const ErrorPage({
    super.key,
    this.statusCode,
    this.errorMessage,
    this.errorTitle,
    this.onRetry,
    this.onGoBack,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    final errorInfo = _getErrorInfo(statusCode);

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 24 : 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Error Icon with Animation
                _buildErrorIcon(errorInfo, themeProvider, isMobile),

                SizedBox(height: isMobile ? 24 : 32),

                // Status Code
                if (statusCode != null)
                  Text(
                    '$statusCode',
                    style: TextStyle(
                      fontSize: isMobile ? 72 : 96,
                      fontWeight: FontWeight.bold,
                      color: errorInfo['color'],
                      height: 1,
                    ),
                  ),

                SizedBox(height: isMobile ? 12 : 16),

                // Error Title
                Text(
                  errorTitle ?? errorInfo['title'],
                  style: TextStyle(
                    fontSize: isMobile ? 24 : 32,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: isMobile ? 12 : 16),

                // Error Message
                Container(
                  constraints: BoxConstraints(maxWidth: isMobile ? 300 : 500),
                  child: Text(
                    errorMessage ?? errorInfo['message'],
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 16,
                      color: themeProvider.textSecondary,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                SizedBox(height: isMobile ? 32 : 48),

                // Action Buttons
                _buildActionButtons(themeProvider, isMobile, context),

                SizedBox(height: isMobile ? 24 : 32),

                // Additional Info
                _buildAdditionalInfo(errorInfo, themeProvider, isMobile),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorIcon(
    Map<String, dynamic> errorInfo,
    ThemeProvider themeProvider,
    bool isMobile,
  ) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: isMobile ? 120 : 150,
            height: isMobile ? 120 : 150,
            decoration: BoxDecoration(
              color: errorInfo['color'].withOpacity(0.1),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: errorInfo['color'].withOpacity(0.2),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              errorInfo['icon'],
              size: isMobile ? 60 : 75,
              color: errorInfo['color'],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(
    ThemeProvider themeProvider,
    bool isMobile,
    BuildContext context,
  ) {
    return Wrap(
      spacing: isMobile ? 12 : 16,
      runSpacing: isMobile ? 12 : 16,
      alignment: WrapAlignment.center,
      children: [
        if (onRetry != null)
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 20),
            label: Text(isMobile ? 'Retry' : 'Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: themeProvider.primaryMain,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 24 : 32,
                vertical: isMobile ? 14 : 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
          ),
        if (onGoBack != null)
          OutlinedButton.icon(
            onPressed: onGoBack,
            icon: const Icon(Icons.arrow_back, size: 20),
            label: Text(isMobile ? 'Back' : 'Go Back'),
            style: OutlinedButton.styleFrom(
              foregroundColor: themeProvider.primaryMain,
              side: BorderSide(color: themeProvider.primaryMain),
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 24 : 32,
                vertical: isMobile ? 14 : 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          )
        else
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, size: 20),
            label: Text(isMobile ? 'Back' : 'Go Back'),
            style: OutlinedButton.styleFrom(
              foregroundColor: themeProvider.primaryMain,
              side: BorderSide(color: themeProvider.primaryMain),
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 24 : 32,
                vertical: isMobile ? 14 : 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAdditionalInfo(
    Map<String, dynamic> errorInfo,
    ThemeProvider themeProvider,
    bool isMobile,
  ) {
    if (errorInfo['tips'] == null) return const SizedBox.shrink();

    return Container(
      constraints: BoxConstraints(maxWidth: isMobile ? 300 : 500),
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: themeProvider.borderColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: isMobile ? 18 : 20,
                color: themeProvider.warningMain,
              ),
              const SizedBox(width: 8),
              Text(
                'Tips',
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(
            (errorInfo['tips'] as List).length,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 6, right: 8),
                    decoration: BoxDecoration(
                      color: themeProvider.primaryMain,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      errorInfo['tips'][index],
                      style: TextStyle(
                        fontSize: isMobile ? 13 : 14,
                        color: themeProvider.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getErrorInfo(int? code) {
    switch (code) {
      case 400:
        return {
          'title': 'Bad Request',
          'message':
              'The request could not be understood by the server. Please check your input.',
          'icon': Icons.error_outline,
          'color': const Color(0xFFF59E0B), // Orange
          'tips': [
            'Check if all required fields are filled correctly',
            'Verify that the data format is correct',
          ],
        };
      case 401:
        return {
          'title': 'Unauthorized',
          'message':
              'You need to be authenticated to access this resource. Please login again.',
          'icon': Icons.lock_outline,
          'color': const Color(0xFFEF4444), // Red
          'tips': [
            'Try logging out and logging back in',
            'Check if your session has expired',
          ],
        };
      case 403:
        return {
          'title': 'Forbidden',
          'message':
              'You don\'t have permission to access this resource.',
          'icon': Icons.block,
          'color': const Color(0xFFDC2626), // Dark Red
          'tips': [
            'Contact your administrator for access',
            'Verify your user role and permissions',
          ],
        };
      case 404:
        return {
          'title': 'Not Found',
          'message':
              'The page or resource you are looking for could not be found.',
          'icon': Icons.search_off,
          'color': const Color(0xFF6366F1), // Indigo
          'tips': [
            'Check if the URL is correct',
            'The resource may have been moved or deleted',
          ],
        };
      case 405:
        return {
          'title': 'Method Not Allowed',
          'message':
              'The HTTP method used is not supported for this resource.',
          'icon': Icons.not_interested,
          'color': const Color(0xFFF97316), // Orange
          'tips': [
            'This is likely a technical issue',
            'Please contact support if the problem persists',
          ],
        };
      case 408:
        return {
          'title': 'Request Timeout',
          'message':
              'The server timed out waiting for the request.',
          'icon': Icons.timer_off,
          'color': const Color(0xFFEAB308), // Yellow
          'tips': [
            'Check your internet connection',
            'Try again in a few moments',
          ],
        };
      case 422:
        return {
          'title': 'Unprocessable Entity',
          'message':
              'The request was well-formed but contains semantic errors.',
          'icon': Icons.warning_amber,
          'color': const Color(0xFFFBBF24), // Yellow
          'tips': [
            'Check validation errors in the form',
            'Ensure all data meets requirements',
          ],
        };
      case 429:
        return {
          'title': 'Too Many Requests',
          'message':
              'You have sent too many requests in a given amount of time.',
          'icon': Icons.speed,
          'color': const Color(0xFFD97706), // Amber
          'tips': [
            'Please wait a moment before trying again',
            'Avoid making too many requests quickly',
          ],
        };
      case 500:
        return {
          'title': 'Internal Server Error',
          'message':
              'Something went wrong on our end. We\'re working to fix it.',
          'icon': Icons.error,
          'color': const Color(0xFFEF4444), // Red
          'tips': [
            'Try refreshing the page',
            'Contact support if the issue persists',
            'Our team has been notified',
          ],
        };
      case 502:
        return {
          'title': 'Bad Gateway',
          'message':
              'The server received an invalid response. Please try again.',
          'icon': Icons.cloud_off,
          'color': const Color(0xFF8B5CF6), // Purple
          'tips': [
            'This is usually temporary',
            'Try again in a few moments',
          ],
        };
      case 503:
        return {
          'title': 'Service Unavailable',
          'message':
              'The server is temporarily unavailable. Please try again later.',
          'icon': Icons.construction,
          'color': const Color(0xFF0EA5E9), // Sky Blue
          'tips': [
            'The service may be under maintenance',
            'Please check back in a few minutes',
          ],
        };
      case 504:
        return {
          'title': 'Gateway Timeout',
          'message':
              'The server took too long to respond. Please try again.',
          'icon': Icons.hourglass_empty,
          'color': const Color(0xFF6B7280), // Gray
          'tips': [
            'Check your internet connection',
            'The server may be experiencing high load',
          ],
        };
      default:
        return {
          'title': 'Something Went Wrong',
          'message':
              'An unexpected error occurred. Please try again or contact support.',
          'icon': Icons.help_outline,
          'color': const Color(0xFF9CA3AF), // Gray
          'tips': [
            'Try refreshing the page',
            'Check your internet connection',
            'Contact support if the problem continues',
          ],
        };
    }
  }

  // Static helper methods for easy usage
  static void show(
    BuildContext context, {
    int? statusCode,
    String? errorMessage,
    String? errorTitle,
    VoidCallback? onRetry,
    VoidCallback? onGoBack,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ErrorPage(
          statusCode: statusCode,
          errorMessage: errorMessage,
          errorTitle: errorTitle,
          onRetry: onRetry,
          onGoBack: onGoBack,
        ),
      ),
    );
  }

  static Widget widget({
    int? statusCode,
    String? errorMessage,
    String? errorTitle,
    VoidCallback? onRetry,
    VoidCallback? onGoBack,
  }) {
    return ErrorPage(
      statusCode: statusCode,
      errorMessage: errorMessage,
      errorTitle: errorTitle,
      onRetry: onRetry,
      onGoBack: onGoBack,
    );
  }
}
