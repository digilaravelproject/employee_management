import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../widgets/app_text.dart';

class CustomSnackbar1 {
  /// Generic method so all snackbar styles are consistent
  static void _show({
    required String title,
    required String message,
    required Color backgroundColor,
    required IconData icon,
    Color? textColor,
  }) {
    // Auto-adjust text color for readability
    final Color effectiveTextColor =
        textColor ?? (backgroundColor.computeLuminance() > 0.5 ? Colors.black : Colors.white);

    // Using a more stable check to prevent LateInitializationError
    try {
      if (Get.isSnackbarOpen) {
        // Only attempt to close if we are certain it's initialized
        Get.closeCurrentSnackbar();
      }
    } catch (e) {
      debugPrint('Snackbar close error: $e');
    }

    Get.snackbar(
      title,
      message,
      backgroundColor: backgroundColor,
      colorText: effectiveTextColor,
      margin: const EdgeInsets.all(12),
      borderRadius: 10,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      icon: Icon(icon, color: effectiveTextColor),
      shouldIconPulse: false,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  static void showSuccess(String message, {String title = 'Success'}) {
    _show(
      title: title,
      message: message,
      backgroundColor: AppColors.successColor,
      icon: Iconsax.tick_circle,
    );
  }

  static void showError(String message, {String title = 'Error'}) {
    final msgLower = message.toLowerCase();
    final isNetIssue = msgLower.contains('something went wrong') ||
        msgLower.contains('socket') ||
        msgLower.contains('host lookup') ||
        msgLower.contains('network') ||
        msgLower.contains('connection') ||
        msgLower.contains('timeout') ||
        msgLower.contains('timed out') ||
        msgLower.contains('offline') ||
        msgLower.contains('unreachable');

    final effectiveTitle = isNetIssue ? 'No Internet Connection' : title;
    final effectiveMessage = isNetIssue
        ? 'Please check your internet connection and turn on Wi-Fi or Mobile Data.'
        : message;

    _show(
      title: effectiveTitle,
      message: effectiveMessage,
      backgroundColor: AppColors.errorColor,
      icon: isNetIssue ? Icons.wifi_off_rounded : Iconsax.danger,
    );
  }

  static void showInfo(String message, {String title = 'Info'}) {
    _show(
      title: title,
      message: message,
      backgroundColor: AppColors.infoColor,
      icon: Iconsax.info_circle,
    );
  }

  static void showWarning(String message, {String title = 'Warning'}) {
    _show(
      title: title,
      message: message,
      backgroundColor: AppColors.warningColor,
      icon: Iconsax.warning_2,
    );
  }
}






class CustomSnackbar {
  static final GlobalKey<ScaffoldMessengerState> messengerKey = GlobalKey<ScaffoldMessengerState>();

  static void _show({
    required String title,
    required String message,
    required Color backgroundColor,
    required IconData icon,
    Color? textColor,
  }) {
    final String cleanTitle = AppText.cleanText(title);
    final String cleanMessage = AppText.cleanText(message);

    final Color effectiveTextColor =
        textColor ??
            (backgroundColor.computeLuminance() > 0.5
                ? Colors.black
                : Colors.white);

    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(icon, color: effectiveTextColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(cleanTitle.toUpperCase(), fontSize: 12, fontWeight: FontWeight.bold, color: effectiveTextColor),
                AppText(cleanMessage, fontSize: 13, color: effectiveTextColor),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 3),
    );

    if (messengerKey.currentState != null) {
      messengerKey.currentState?.hideCurrentSnackBar();
      messengerKey.currentState?.showSnackBar(snackBar);
    } else {
      Get.snackbar(
        cleanTitle,
        cleanMessage,
        backgroundColor: backgroundColor,
        colorText: effectiveTextColor,
        icon: Icon(icon, color: effectiveTextColor, size: 24),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
      );
    }
  }

  static void showSuccess(String message, {String title = 'Success'}) {
    _show(
      title: title,
      message: message,
      backgroundColor: AppColors.successColor,
      icon: Icons.check_circle_rounded,
    );
  }

  static void showError(String message, {String title = 'Error'}) {
    final msgLower = message.toLowerCase();
    final isNetIssue = msgLower.contains('something went wrong') ||
        msgLower.contains('socket') ||
        msgLower.contains('host lookup') ||
        msgLower.contains('network') ||
        msgLower.contains('connection') ||
        msgLower.contains('timeout') ||
        msgLower.contains('timed out') ||
        msgLower.contains('offline') ||
        msgLower.contains('unreachable');

    final effectiveTitle = isNetIssue ? 'No Internet Connection' : title;
    final effectiveMessage = isNetIssue
        ? 'Please check your internet connection and turn on Wi-Fi or Mobile Data.'
        : message;

    _show(
      title: effectiveTitle,
      message: effectiveMessage,
      backgroundColor: AppColors.errorColor,
      icon: isNetIssue ? Icons.wifi_off_rounded : Icons.error_rounded,
    );
  }

  static void showInfo(String message, {String title = 'Info'}) {
    _show(
      title: title,
      message: message,
      backgroundColor: AppColors.infoColor,
      icon: Icons.info_rounded,
    );
  }

  static void showWarning(String message, {String title = 'Warning'}) {
    _show(
      title: title,
      message: message,
      backgroundColor: AppColors.warningColor,
      icon: Icons.warning_rounded,
    );
  }
}


