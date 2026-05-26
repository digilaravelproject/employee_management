import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../services/network/network_info.dart';
import '../constants/app_text_constants.dart';

class NoInternetScreen extends StatefulWidget {
  const NoInternetScreen({Key? key}) : super(key: key);

  @override
  State<NoInternetScreen> createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends State<NoInternetScreen> {
  bool _isChecking = false;

  Future<void> _checkConnection() async {
    setState(() => _isChecking = true);

    final isConnected = await NetworkInfo.checkConnectivity();

    setState(() => _isChecking = false);

    if (isConnected) {
      Get.back(); // close the screen
      Get.snackbar(
        AppTextConstants.connected.tr,
        AppTextConstants.connectionRestored.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.successColor,
        colorText: AppColors.white,
        duration: const Duration(seconds: 2),
      );
    } else {
      Get.snackbar(
        AppTextConstants.noInternetConnection.tr,
        AppTextConstants.stillNoInternet.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorColor,
        colorText: AppColors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

  void _openSettings() async {
    try {
      const platform = MethodChannel('app.channel.settings');
      if (GetPlatform.isAndroid) {
        await platform.invokeMethod('openWifiSettings');
      } else if (GetPlatform.isIOS) {
        await platform.invokeMethod('openSettings');
      }
    } catch (e) {
      debugPrint('Error opening settings: $e');
      Get.snackbar(AppTextConstants.error.tr, AppTextConstants.unableToOpenSettings.tr,
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🔴 Wifi Off Icon
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.errorColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.wifi_off_rounded,
                    size: 80,
                    color: AppColors.errorColor,
                  ),
                ),

                const SizedBox(height: 24),

                // 📝 Title
                Text(
                   AppTextConstants.noInternetConnection.tr,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // 💬 Description
                Text(
                  AppTextConstants.checkConnectionMessage.tr,
                  style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // 🔁 Retry Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isChecking ? null : _checkConnection,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isChecking
                        ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.white),
                      ),
                    )
                        : Text(
                       AppTextConstants.retry.tr,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ⚙️ Open Settings
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _openSettings,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: theme.primaryColor),
                      ),
                    ),
                    child: Text(
                       AppTextConstants.openSettings.tr,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
