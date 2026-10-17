import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/lead_integrations_controller.dart';
import '../models/lead_integration_model.dart';

class LeadConnectBottomSheet {
  /// Open OAuth Connection BottomSheet for a specific channel ('facebook_ads' or 'google_ads')
  static void show(BuildContext context, {String channelId = 'facebook_ads'}) {
    final controller = LeadIntegrationsController.to;
    final item = controller.getChannel(channelId) ??
        LeadIntegrationItem(
          id: channelId,
          name: channelId == 'google_ads' ? 'Google Ads' : 'Facebook (Meta) Ads',
          shortName: channelId == 'google_ads' ? 'Google' : 'Facebook',
          type: channelId == 'google_ads' ? 'google' : 'meta',
        );

    final clientIdCtrl = TextEditingController(
      text: item.clientId.isNotEmpty
          ? item.clientId
          : (channelId == 'facebook_ads' ? '1456126426464024' : '4819021184-apps.googleusercontent.com'),
    );

    final clientSecretCtrl = TextEditingController(
      text: item.clientSecret.isNotEmpty
          ? item.clientSecret
          : (channelId == 'facebook_ads' ? 'e538d100399d1ce84fe5fd48659fbc6f' : 'GOCSPX-e538d100399d1ce84fe5'),
    );

    final redirectUriCtrl = TextEditingController(
      text: item.redirectUri.isNotEmpty ? item.redirectUri : 'https://oauth.pstmn.io/v1/callback',
    );

    final stateCtrl = TextEditingController(
      text: item.state.isNotEmpty
          ? item.state
          : (channelId == 'facebook_ads' ? 'fbtest123' : 'googletest123'),
    );

    final isMeta = channelId == 'facebook_ads';
    final brandColor = isMeta ? const Color(0xFF1877F2) : const Color(0xFFEA4335);
    final brandIcon = isMeta ? Icons.facebook : Icons.campaign_rounded;
    final brandTitle = isMeta ? 'Facebook (Meta) Ads' : 'Google Ads';

    final RxBool obscureSecret = true.obs;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Sheet Header
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: brandColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(brandIcon, color: brandColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            AppText(
                              brandTitle,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                            ),
                            const SizedBox(width: 8),
                            _buildStatusBadge(item.isConnected),
                          ],
                        ),
                        const SizedBox(height: 2),
                        const AppText(
                          'OAuth Credentials for Sales Lead Sync',
                          fontSize: 11.5,
                          color: AppColors.textColorSecondary,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B), size: 20),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const Divider(color: Color(0xFFE2E8F0), height: 1),
              const SizedBox(height: 16),

              // 1. Client ID
              _buildField(
                fieldName: 'Client ID',
                controller: clientIdCtrl,
                icon: Iconsax.user_tag,
                hintText: 'e.g. 1456126426464024',
              ),
              const SizedBox(height: 14),

              // 2. Client Secret
              Obx(() => _buildField(
                    fieldName: 'Client Secret',
                    controller: clientSecretCtrl,
                    icon: Iconsax.key,
                    obscureText: obscureSecret.value,
                    hintText: 'e.g. e538d100399d1ce84fe5fd48659fbc6f',
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureSecret.value ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        size: 18,
                        color: const Color(0xFF64748B),
                      ),
                      onPressed: () => obscureSecret.toggle(),
                    ),
                  )),
              const SizedBox(height: 14),

              // 3. Redirect URI
              _buildField(
                fieldName: 'Redirect URI',
                controller: redirectUriCtrl,
                icon: Iconsax.link_21,
                hintText: 'https://oauth.pstmn.io/v1/callback',
                suffixIcon: IconButton(
                  icon: const Icon(Iconsax.copy, size: 16, color: AppColors.primaryColor),
                  tooltip: 'Copy redirect_uri',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: redirectUriCtrl.text));
                    Get.snackbar(
                      'Copied to Clipboard 📋',
                      'redirect_uri copied successfully.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: const Color(0xFF1E293B),
                      colorText: Colors.white,
                      duration: const Duration(seconds: 2),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),

              // 4. State
              _buildField(
                fieldName: 'State',
                controller: stateCtrl,
                icon: Iconsax.shield_tick,
                hintText: 'e.g. fbtest123',
              ),
              const SizedBox(height: 22),

              // Action Buttons
              Row(
                children: [
                  if (item.isConnected) ...[
                    Expanded(
                      flex: 1,
                      child: OutlinedButton(
                        onPressed: () {
                          Get.back();
                          controller.disconnectChannel(item.id);
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFEF4444)),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const AppText(
                          'Disconnect',
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (channelId == 'facebook_ads') {
                          final success = await controller.connectFacebook(
                            clientId: clientIdCtrl.text,
                            clientSecret: clientSecretCtrl.text,
                            redirectUri: redirectUriCtrl.text,
                            state: stateCtrl.text,
                          );
                          if (success) {
                            Get.back();
                          }
                        } else {
                          await controller.saveOAuthCredentials(
                            id: item.id,
                            clientId: clientIdCtrl.text,
                            clientSecret: clientSecretCtrl.text,
                            redirectUri: redirectUriCtrl.text,
                            state: stateCtrl.text,
                            markConnected: true,
                          );
                          Get.back();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brandColor,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Obx(() {
                        final isConnecting = controller.isConnecting.value;
                        if (isConnecting && channelId == 'facebook_ads') {
                          return const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              ),
                              SizedBox(width: 8),
                              AppText(
                                'Connecting to Facebook...',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ],
                          );
                        }

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Iconsax.link, size: 16, color: Colors.white),
                            const SizedBox(width: 6),
                            AppText(
                              item.isConnected ? 'Update & Keep Connected' : 'Connect $brandTitle',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  /// Open Platform Selector Sheet (Shows Facebook & Google connected status and tap opens form)
  static void showPlatformSelector(BuildContext context) {
    final controller = LeadIntegrationsController.to;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Obx(() {
          final isMeta = controller.isMetaConnected;
          final isGoogle = controller.isGoogleConnected;

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        'Sales Ad Integrations',
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                      SizedBox(height: 2),
                      AppText(
                        'Connect Facebook & Google to capture sales leads',
                        fontSize: 11.5,
                        color: AppColors.textColorSecondary,
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B), size: 20),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Facebook Ads Item
              _buildSelectorItem(
                title: 'Facebook (Meta) Ads',
                subtitle: isMeta
                    ? 'Connected • Receiving Facebook sales leads'
                    : 'Not Connected • Tap to connect with client_id',
                icon: Icons.facebook,
                color: const Color(0xFF1877F2),
                isConnected: isMeta,
                onTap: () {
                  Get.back();
                  show(context, channelId: 'facebook_ads');
                },
              ),
              const SizedBox(height: 12),

              // Google Ads Item
              _buildSelectorItem(
                title: 'Google Ads',
                subtitle: isGoogle
                    ? 'Connected • Receiving Google Ads sales leads'
                    : 'Not Connected • Tap to connect with client_id',
                icon: Icons.campaign_rounded,
                color: const Color(0xFFEA4335),
                isConnected: isGoogle,
                onTap: () {
                  Get.back();
                  show(context, channelId: 'google_ads');
                },
              ),
              const SizedBox(height: 20),
            ],
          );
        }),
      ),
      isScrollControlled: true,
    );
  }

  static Widget _buildSelectorItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isConnected,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isConnected ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isConnected ? const Color(0xFFBBF7D0) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          AppText(
                            title,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E293B),
                          ),
                          const SizedBox(width: 8),
                          _buildStatusBadge(isConnected),
                        ],
                      ),
                      const SizedBox(height: 3),
                      AppText(
                        subtitle,
                        fontSize: 11,
                        color: isConnected ? const Color(0xFF15803D) : AppColors.textColorSecondary,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF94A3B8)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildField({
    required String fieldName,
    required TextEditingController controller,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          fieldName,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1E293B),
        ),
        const SizedBox(height: 7),
        TextField(
          controller: controller,
          obscureText: obscureText,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            prefixIcon: Icon(icon, size: 18, color: const Color(0xFF64748B)),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  static Widget _buildStatusBadge(bool isConnected) {
    if (isConnected) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
        decoration: BoxDecoration(
          color: const Color(0xFFECFDF5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFA7F3D0)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.fiber_manual_record, color: Color(0xFF10B981), size: 7),
            SizedBox(width: 4),
            AppText(
              'Connected',
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF047857),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFCBD5E1)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.fiber_manual_record, color: Color(0xFF94A3B8), size: 7),
            SizedBox(width: 4),
            AppText(
              'Not Connected',
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B),
            ),
          ],
        ),
      );
    }
  }
}
