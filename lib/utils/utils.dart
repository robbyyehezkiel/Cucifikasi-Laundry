import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

const String adminWelcomeText = 'Welcome to the Admin Home Page!';
const String customerWelcomeText = 'Welcome to the Customer Home Page!';
const String authPageRoute = '/auth';

class Utils {
  BuildContext context;

  Utils(this.context);

  void showSnackbar(String message) {
    _showSnackbar(message);
  }

  void handleError(String errorMessage, dynamic error) {
    final friendlyErrorMessage = 'Failed: $errorMessage';
    UtilsLog.logger.e(friendlyErrorMessage, error: error);
    _showSnackbar(friendlyErrorMessage);
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
    ));
  }
}

class UtilsLog {
  static final Logger _logger = Logger();

  static Logger get logger => _logger;

  void logInfo(String tag, String message) {
    _logger.i('$tag: $message');
  }

  void logDebug(String tag, String message) {
    _logger.d('$tag: $message');
  }

  void logWarning(String tag, String message) {
    _logger.w('$tag: $message');
  }

  void logError(String tag, String message) {
    _logger.e('$tag: $message');
  }
}
