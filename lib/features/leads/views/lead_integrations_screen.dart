import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/lead_integrations_controller.dart';
import '../models/lead_integration_model.dart';
import 'lead_connect_bottom_sheet.dart';

class LeadIntegrationsScreen extends StatefulWidget {
  const LeadIntegrationsScreen({super.key});

  @override
  State<LeadIntegrationsScreen> createState() => _LeadIntegrationsScreenState();
}

class _LeadIntegrationsScreenState extends State<LeadIntegrationsScreen> {
  late final LeadIntegrationsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = LeadIntegrationsController.to;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B), size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              'Lead Integrations',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
            AppText(
              'Facebook & Google OAuth Connections',
              fontSize: 11,
              color: AppColors.textColorSecondary,
            ),
          ],
        ),
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () async {
            _controller.loadIntegrations();
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            children: [
              // Hero Summary Card
              _buildTopHeroSummary(),
              const SizedBox(height: 20),

              // Title Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AppText(
                    'Ad Platforms',
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.sensors_rounded, color: Color(0xFF059669), size: 13),
                        const SizedBox(width: 4),
                        AppText(
                          '${_controller.totalConnectedCount} Connected',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF047857),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Integration Cards
              ..._controller.integrations.map((item) => _buildPlatformCard(item)),

              const SizedBox(height: 12),

              // Setup Guide
              _buildSetupGuideCard(),

              const SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTopHeroSummary() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Iconsax.link_21, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      'Sales Lead Stream Gateway',
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                    SizedBox(height: 2),
                    AppText(
                      'OAuth credential bridge for inbound ad leads',
                      fontSize: 11,
                      color: Color(0xFF94A3B8),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.fiber_manual_record, color: Color(0xFF10B981), size: 10),
                    SizedBox(width: 5),
                    AppText(
                      'OAuth Bridge',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF34D399),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Two Primary Quick Badges: Meta & Google
          Row(
            children: [
              Expanded(
                child: _buildChannelStatusChip(
                  label: 'Facebook Ads',
                  icon: Icons.facebook,
                  iconColor: const Color(0xFF1877F2),
                  isConnected: _controller.isMetaConnected,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildChannelStatusChip(
                  label: 'Google Ads',
                  icon: Icons.campaign_rounded,
                  iconColor: const Color(0xFFEA4335),
                  isConnected: _controller.isGoogleConnected,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChannelStatusChip({
    required String label,
    required IconData icon,
    required Color iconColor,
    required bool isConnected,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isConnected
              ? const Color(0xFF10B981).withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  label,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isConnected ? const Color(0xFF34D399) : const Color(0xFFF59E0B),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    AppText(
                      isConnected ? 'Connected' : 'Not Connected',
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      color: isConnected ? const Color(0xFF34D399) : const Color(0xFFFBBF24),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformCard(LeadIntegrationItem item) {
    final isMeta = item.id == 'facebook_ads';
    final brandColor = isMeta ? const Color(0xFF1877F2) : const Color(0xFFEA4335);
    final brandLightColor = isMeta ? const Color(0xFFEFF6FF) : const Color(0xFFFEF2F2);
    final brandIcon = isMeta ? Icons.facebook : Icons.campaign_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: item.isConnected
              ? brandColor.withValues(alpha: 0.25)
              : const Color(0xFFE2E8F0),
          width: item.isConnected ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: item.isConnected
                ? brandColor.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.02),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: brandLightColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: brandColor.withValues(alpha: 0.2)),
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
                          Expanded(
                            child: AppText(
                              item.name,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          _buildConnectionBadge(item.isConnected),
                        ],
                      ),
                      const SizedBox(height: 3),
                      AppText(
                        item.statusMessage,
                        fontSize: 11.5,
                        color: item.isConnected ? const Color(0xFF059669) : AppColors.textColorSecondary,
                        fontWeight: item.isConnected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // OAuth Credential details preview
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                _buildFieldPreview(
                  title: 'Client ID',
                  value: item.clientId.isNotEmpty ? item.clientId : 'Not configured',
                ),
                const SizedBox(height: 8),
                _buildFieldPreview(
                  title: 'Client Secret',
                  value: item.clientSecret.isNotEmpty
                      ? (item.clientSecret.length > 8
                          ? '${item.clientSecret.substring(0, 4)}••••••••${item.clientSecret.substring(item.clientSecret.length - 4)}'
                          : '••••••••')
                      : 'Not configured',
                ),
                const SizedBox(height: 8),
                _buildFieldPreview(
                  title: 'Redirect URI',
                  value: item.redirectUri.isNotEmpty ? item.redirectUri : 'Not configured',
                  onCopy: item.redirectUri.isNotEmpty
                      ? () {
                          Clipboard.setData(ClipboardData(text: item.redirectUri));
                          Get.snackbar(
                            'Copied 📋',
                            'redirect_uri copied to clipboard.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: const Color(0xFF1E293B),
                            colorText: Colors.white,
                            duration: const Duration(seconds: 2),
                          );
                        }
                      : null,
                ),
                const SizedBox(height: 8),
                _buildFieldPreview(
                  title: 'State',
                  value: item.state.isNotEmpty ? item.state : 'Not configured',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Footer Action Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFFAFAFA),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
              border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
            ),
            child: Row(
              children: [
                if (item.isConnected) ...[
                  OutlinedButton(
                    onPressed: () => _controller.disconnectChannel(item.id),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFEF4444)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const AppText(
                      'Disconnect',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () => LeadConnectBottomSheet.show(context, channelId: item.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.edit_note_rounded, size: 15, color: Colors.white),
                    label: const AppText(
                      'Edit Credentials',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ] else ...[
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () => LeadConnectBottomSheet.show(context, channelId: item.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Iconsax.link, size: 14, color: Colors.white),
                    label: AppText(
                      'Connect ${item.shortName}',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldPreview({
    required String title,
    required String value,
    VoidCallback? onCopy,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 95,
          child: AppText(
            title,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF334155),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
              fontFamily: 'monospace',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (onCopy != null) ...[
          const SizedBox(width: 6),
          InkWell(
            onTap: onCopy,
            child: const Icon(Iconsax.copy, size: 13, color: AppColors.primaryColor),
          ),
        ],
      ],
    );
  }

  Widget _buildConnectionBadge(bool isConnected) {
    if (isConnected) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFECFDF5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFA7F3D0)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.fiber_manual_record, color: Color(0xFF10B981), size: 8),
            SizedBox(width: 4),
            AppText(
              'Connected',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF047857),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFCBD5E1)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.fiber_manual_record, color: Color(0xFF94A3B8), size: 8),
            SizedBox(width: 4),
            AppText(
              'Not Connected',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildSetupGuideCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.info_circle, color: AppColors.primaryColor, size: 18),
              SizedBox(width: 8),
              AppText(
                'OAuth Configuration Instructions',
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ],
          ),
          SizedBox(height: 8),
          AppText(
            'Enter your registered App Client ID and Secret with the callback redirect URI. After saving, inbound leads from ad campaigns will automatically stream into CRM.',
            fontSize: 11,
            color: AppColors.textColorSecondary,
            height: 1.4,
          ),
        ],
      ),
    );
  }
}
