import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_text_constants.dart';
import '../services/network/network_info.dart';
import '../services/network/network_settings_helper.dart';
import '../theme/app_colors.dart';
import '../utils/custom_snackbar.dart';
import 'app_text.dart';

class NoInternetScreen extends StatefulWidget {
  final VoidCallback? onRetrySuccess;
  final bool canGoBack;

  const NoInternetScreen({
    Key? key,
    this.onRetrySuccess,
    this.canGoBack = true,
  }) : super(key: key);

  @override
  State<NoInternetScreen> createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends State<NoInternetScreen> {
  bool _isChecking = false;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _startConnectivityListener();
  }

  void _startConnectivityListener() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) async {
      final isConnected = results.contains(ConnectivityResult.mobile) ||
          results.contains(ConnectivityResult.wifi) ||
          results.contains(ConnectivityResult.ethernet);

      if (isConnected && mounted) {
        // Quick verification
        final verified = await NetworkInfo.checkConnectivity();
        if (verified && mounted) {
          _handleConnected();
        }
      }
    });
  }

  void _handleConnected() {
    if (Navigator.of(context).canPop()) {
      Get.back();
    }
    CustomSnackbar.showSuccess(
      'Internet connection restored successfully.',
      title: 'Back Online',
    );
    widget.onRetrySuccess?.call();
  }

  Future<void> _checkConnection() async {
    if (_isChecking) return;
    setState(() => _isChecking = true);

    await Future.delayed(const Duration(milliseconds: 600));
    final isConnected = await NetworkInfo.checkConnectivity();

    if (!mounted) return;
    setState(() => _isChecking = false);

    if (isConnected) {
      _handleConnected();
    } else {
      CustomSnackbar.showWarning(
        'Still offline. Please turn on Wi-Fi or Mobile Data in your device settings.',
        title: 'No Connection',
      );
    }
  }

  void _openWifiSettings() async {
    await NetworkSettingsHelper.openWifiSettings();
  }

  void _openDataSettings() async {
    await NetworkSettingsHelper.openDataSettings();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: widget.canGoBack && Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.textColorPrimary,
                  size: 20,
                ),
                onPressed: () => Get.back(),
              )
            : null,
        title: const AppText(
          'Network Status',
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.textColorPrimary,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🔴 Animated Wifi Off Icon Container
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.errorColor.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.errorColor.withValues(alpha: 0.2),
                      width: 2,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.wifi_off_rounded,
                      size: 64,
                      color: AppColors.errorColor,
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // 📝 Clean User-friendly Title
                const AppText(
                  'No Internet Connection',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textColorPrimary,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // 💬 Friendly Description
                AppText(
                  'It looks like you are offline. Please turn on Wi-Fi or Mobile Data to continue using DGM360.',
                  fontSize: 14,
                  height: 1.4,
                  color: Colors.grey[600],
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                // 💡 Quick Network Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _openWifiSettings,
                        icon: const Icon(Icons.wifi_rounded, size: 18),
                        label: const Text(
                          'Wi-Fi Settings',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: theme.primaryColor.withValues(alpha: 0.5)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _openDataSettings,
                        icon: const Icon(Icons.signal_cellular_alt_rounded, size: 18),
                        label: const Text(
                          'Mobile Data',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: theme.primaryColor.withValues(alpha: 0.5)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 🔁 Retry Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isChecking ? null : _checkConnection,
                    icon: _isChecking
                        ? const SizedBox.shrink()
                        : const Icon(Icons.refresh_rounded, size: 20, color: Colors.white),
                    label: _isChecking
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Retry Connection',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      disabledBackgroundColor: theme.primaryColor.withValues(alpha: 0.6),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // ℹ️ Troubleshooting Tips Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.lightbulb_outline_rounded, size: 18, color: Color(0xFF64748B)),
                          SizedBox(width: 8),
                          AppText(
                            'Quick Troubleshooting',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF334155),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildBulletItem('Turn on Wi-Fi or Cellular Data from settings'),
                      _buildBulletItem('Make sure Airplane Mode is turned off'),
                      _buildBulletItem('Check your router or cellular network reception'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBulletItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 5.0, right: 8.0),
            child: Icon(Icons.circle, size: 5, color: Color(0xFF94A3B8)),
          ),
          Expanded(
            child: AppText(
              text,
              fontSize: 12,
              color: const Color(0xFF64748B),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
