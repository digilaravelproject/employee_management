import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/custom_snackbar.dart';
import 'network_info.dart';
import 'network_settings_helper.dart';

class NetworkController extends GetxController {
  static NetworkController get to => Get.find<NetworkController>();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  final RxBool isOffline = false.obs;
  final RxBool isChecking = false.obs;
  bool _hasInitialCheckRun = false;

  @override
  void onInit() {
    super.onInit();
    _initConnectivity();
    _subscription = _connectivity.onConnectivityChanged.listen(_handleConnectivityChanged);
  }

  Future<void> _initConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      final hasConn = _isResultConnected(results);
      isOffline.value = !hasConn;
      _hasInitialCheckRun = true;
    } catch (e) {
      debugPrint('Connectivity init error: $e');
    }
  }

  bool _isResultConnected(List<ConnectivityResult> results) {
    return results.contains(ConnectivityResult.mobile) ||
        results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.ethernet);
  }

  void _handleConnectivityChanged(List<ConnectivityResult> results) {
    final connected = _isResultConnected(results);
    final wasOffline = isOffline.value;

    if (!connected) {
      isOffline.value = true;
      if (_hasInitialCheckRun && !wasOffline) {
        _showOfflineSnackbar();
      }
    } else {
      isOffline.value = false;
      if (wasOffline) {
        if (Get.currentRoute.contains('NoInternetScreen')) {
          Get.back();
        }
        CustomSnackbar.showSuccess(
          'Internet connection restored successfully.',
          title: 'Back Online',
        );
      }
    }
    _hasInitialCheckRun = true;
  }

  void _showOfflineSnackbar() {
    if (!Get.currentRoute.contains('NoInternetScreen')) {
      CustomSnackbar.showWarning(
        'Internet connection lost. Please turn on Wi-Fi or Mobile Data.',
        title: 'Offline',
      );
    }
  }

  Future<bool> checkConnection() async {
    isChecking.value = true;
    final connected = await NetworkInfo.checkConnectivity();
    isOffline.value = !connected;
    isChecking.value = false;
    return connected;
  }

  void openSettings() {
    NetworkSettingsHelper.openWifiSettings();
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
