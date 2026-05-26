import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/hr_controller.dart';
import 'policies_screen.dart';
import 'announcements_screen.dart';
import 'engagement_screen.dart';

class HrPortalDashboard extends StatelessWidget {
  const HrPortalDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure HrController is put/initialized
    Get.put(HrController());

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.slate100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textColorPrimary, size: 18),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        title: const AppText(
          'HR Portal',
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: AppColors.textColorPrimary,
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Premium Welcoming Banner ──
            _buildWelcomeBanner(),
            const SizedBox(height: 24),

            // ── Section Title ──
            const AppText(
              'HR Operations & Tools',
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textColorPrimary,
            ),
            const SizedBox(height: 12),

            // ── Interactive Navigation Cards Grid ──
            _buildNavigationGrid(context),
            const SizedBox(height: 24),

            // ── Recent Activity Brief Card ──
            _buildBriefStatsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeBanner() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF4F46E5), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(
              Iconsax.teacher,
              size: 130,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppText(
                  'Human Resources Management',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFEF08A),
                ),
                const SizedBox(height: 8),
                const AppText(
                  'Manage guidelines, broadcast updates, and engage your teammates.',
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const AppText(
                    'Active Portal',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationGrid(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {
        'title': 'Company Policies',
        'desc': 'View and manage all company guidelines & POSH rules.',
        'icon': Iconsax.document_text,
        'color': AppColors.primaryColor,
        'onTap': () => Get.to(() => const PoliciesScreen()),
      },
      {
        'title': 'Announcements',
        'desc': 'Broadcast and check pinned company-wide updates.',
        'icon': Iconsax.volume_high,
        'color': AppColors.indigo500,
        'onTap': () => Get.to(() => const AnnouncementsScreen()),
      },
      {
        'title': 'Employee Engagement',
        'desc': 'Appreciate peers with Kudos, view surveys, and suggest ideas.',
        'icon': Iconsax.people,
        'color': AppColors.successColor,
        'onTap': () => Get.to(() => const EngagementScreen()),
      },
    ];

    return Column(
      children: menuItems.map((item) {
        final color = item['color'] as Color;
        final icon = item['icon'] as IconData;

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.slate200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.01),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: item['onTap'] as VoidCallback?,
              borderRadius: BorderRadius.circular(22),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Tinted Icon wrapper
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: color, size: 24),
                    ),
                    const SizedBox(width: 16),

                    // Details text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            item['title'] as String,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColorPrimary,
                          ),
                          const SizedBox(height: 4),
                          AppText(
                            item['desc'] as String,
                            fontSize: 11,
                            color: AppColors.textColorSecondary,
                          ),
                        ],
                      ),
                    ),

                    // Chevron action arrow
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppColors.textColorHint,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBriefStatsCard() {
    final controller = Get.find<HrController>();

    return Obx(() {
      final totalPolicies = controller.policies.length;
      final totalAnn = controller.announcements.length;
      final recentEng = controller.recentEngagements.length;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.slate200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText(
              'HR Directory Statistics',
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textColorPrimary,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatColumn('Policies', '$totalPolicies', AppColors.primaryColor),
                _buildDivider(),
                _buildStatColumn('Announcements', '$totalAnn', AppColors.indigo500),
                _buildDivider(),
                _buildStatColumn('Engagement', '$recentEng', AppColors.successColor),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildDivider() {
    return Container(
      height: 24,
      width: 1,
      color: AppColors.slate200,
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          AppText(
            value,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: color,
          ),
          const SizedBox(height: 4),
          AppText(
            label,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textColorSecondary,
          ),
        ],
      ),
    );
  }
}
