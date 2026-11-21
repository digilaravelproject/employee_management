import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../utils/custom_snackbar.dart';

class NetworkSettingsHelper {
  static const MethodChannel _channel = MethodChannel('app.channel.settings');

  /// Opens Wi-Fi Settings Intent on Android, or app settings on other platforms
  static Future<bool> openWifiSettings() async {
    try {
      if (GetPlatform.isAndroid) {
        final res = await _channel.invokeMethod<bool>('openWifiSettings');
        if (res == true) return true;
      }
    } catch (_) {}
    return openSettings();
  }

  /// Opens Mobile Data Settings Intent on Android, or app settings on other platforms
  static Future<bool> openDataSettings() async {
    try {
      if (GetPlatform.isAndroid) {
        final res = await _channel.invokeMethod<bool>('openDataSettings');
        if (res == true) return true;
      }
    } catch (_) {}
    return openSettings();
  }

  /// Opens General Wireless / Network Settings Intent
  static Future<bool> openSettings() async {
    try {
      if (GetPlatform.isAndroid) {
        final res = await _channel.invokeMethod<bool>('openSettings');
        if (res == true) return true;
      } else if (GetPlatform.isIOS) {
        return await openAppSettings();
      }
    } catch (_) {}

    try {
      return await openAppSettings();
    } catch (_) {
      CustomSnackbar.showError(
        'Please turn on Wi-Fi or Mobile Data in your device settings.',
        title: 'Settings',
      );
      return false;
    }
  }
}
