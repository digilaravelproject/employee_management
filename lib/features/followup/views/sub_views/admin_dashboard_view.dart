import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text.dart';
import '../../controllers/followup_controller.dart';
import '../admin_call_logs_screen.dart';
import '../admin_meetings_screen.dart';
import '../admin_reminders_screen.dart';

class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FollowupController>();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Symmetrical Overview (This Month) Board ──
          _buildMonthOverviewBoard(),
          const SizedBox(height: 20),

          // ── Team Operations Quick Navigation Decks ──
          const AppText(
            'Team Operations Monitor',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textColorPrimary,
          ),
          const SizedBox(height: 10),
          _buildOperationsDecks(context),
          const SizedBox(height: 24),

          // ── Employee Performance Leaderboard ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AppText(
                'Employee Performance',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textColorPrimary,
              ),
              TextButton(
                onPressed: () {
                  Get.snackbar('Leaderboard', 'You are already viewing the active sales team analytics.');
                },
                child: const AppText('View All', fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
              ),
            ],
          ),
          const SizedBox(height: 4),
          _buildPerformanceLeaderboard(controller),
        ],
      ),
    );
  }

  Widget _buildMonthOverviewBoard() {
    final List<Map<String, dynamic>> overview = [
      {'value': '320', 'label': 'Total Calls', 'color': AppColors.primaryColor},
      {'value': '85', 'label': 'Total Meetings', 'color': Colors.green},
      {'value': '45', 'label': 'Pending Rem.', 'color': Colors.orange},
      {'value': '210', 'label': 'Total Notes', 'color': Colors.purple},
    ];

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AppText(
                'Overview (This Month)',
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textColorPrimary,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const AppText('SaaS CRM Logs', fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: overview.map((item) {
              final color = item['color'] as Color;
              return Expanded(
                child: Column(
                  children: [
                    AppText(
                      item['value'] as String,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: color,
                    ),
                    const SizedBox(height: 4),
                    AppText(
                      item['label'] as String,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColorSecondary,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildOperationsDecks(BuildContext context) {
    final List<Map<String, dynamic>> items = [
      {
        'title': 'Team Call Logs',
        'desc': 'Audit team phone calls & filter logs by sales rep.',
        'icon': Iconsax.call,
        'color': AppColors.primaryColor,
        'onTap': () => Get.to(() => const AdminCallLogsScreen()),
      },
      {
        'title': 'Team Meetings',
        'desc': 'Track all scheduled meetings & coordinates with client.',
        'icon': Iconsax.people,
        'color': Colors.green,
        'onTap': () => Get.to(() => const AdminMeetingsScreen()),
      },
      {
        'title': 'Team Reminders',
        'desc': 'Audit pending and completed task reminders of the team.',
        'icon': Iconsax.notification,
        'color': Colors.orange,
        'onTap': () => Get.to(() => const AdminRemindersScreen()),
      },
    ];

    return Column(
      children: items.map((item) {
        final color = item['color'] as Color;
        final icon = item['icon'] as IconData;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.slate200),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: item['onTap'] as VoidCallback?,
              borderRadius: BorderRadius.circular(22),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: color, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            item['title'] as String,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColorPrimary,
                          ),
                          const SizedBox(height: 2),
                          AppText(
                            item['desc'] as String,
                            fontSize: 10,
                            color: AppColors.textColorSecondary,
                          ),
                        ],
                      ),
                    ),
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

  Widget _buildPerformanceLeaderboard(FollowupController controller) {
    final List<Map<String, dynamic>> performance = [
      {'name': 'Rahul Sharma', 'calls': '72', 'meets': '18', 'rems': '9', 'avatar': '👨‍💼'},
      {'name': 'Neha Kapoor', 'calls': '58', 'meets': '15', 'rems': '7', 'avatar': '👩‍💼'},
      {'name': 'Vikash Yadav', 'calls': '45', 'meets': '12', 'rems': '6', 'avatar': '👨‍💻'},
      {'name': 'Amit Singh', 'calls': '38', 'meets': '10', 'rems': '5', 'avatar': '👨‍🎓'},
    ];

    return Column(
      children: performance.map((rep) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.slate200),
          ),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.slate100,
                ),
                child: Center(
                  child: Text(
                    rep['avatar'] as String,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      rep['name'] as String,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColorPrimary,
                    ),
                    const SizedBox(height: 4),
                    // Performance counts details row
                    Row(
                      children: [
                        _buildCountLabel('Calls', rep['calls'] as String, AppColors.primaryColor),
                        _buildBullet(),
                        _buildCountLabel('Meets', rep['meets'] as String, Colors.green),
                        _buildBullet(),
                        _buildCountLabel('Reminders', rep['rems'] as String, Colors.orange),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBullet() {
    return Container(
      width: 3,
      height: 3,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: const BoxDecoration(
        color: AppColors.textColorHint,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildCountLabel(String label, String value, Color color) {
    return Row(
      children: [
        AppText('$label: ', fontSize: 10, color: AppColors.textColorSecondary),
        AppText(value, fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ],
    );
  }
}
