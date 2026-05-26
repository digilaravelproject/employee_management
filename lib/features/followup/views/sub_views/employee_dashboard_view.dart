import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text.dart';
import '../../controllers/followup_controller.dart';
import '../employee_call_logs_screen.dart';
import '../employee_meetings_screen.dart';
import '../employee_reminders_screen.dart';
import '../employee_notes_screen.dart';

class EmployeeDashboardView extends StatelessWidget {
  const EmployeeDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FollowupController>();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Employee Welcoming Profile Card ──
          _buildProfileCard(),
          const SizedBox(height: 16),

          // ── Symmetrical Statistics Deck ──
          _buildStatsDeck(context, controller),
          const SizedBox(height: 20),

          // ── Upcoming Reminders Timeline ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AppText(
                'Upcoming Reminders',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textColorPrimary,
              ),
              TextButton(
                onPressed: () => Get.to(() => const EmployeeRemindersScreen()),
                child: const AppText('View All', fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
              ),
            ],
          ),
          const SizedBox(height: 4),
          _buildRemindersList(controller),
          const SizedBox(height: 20),

          // ── Today's Activities Timeline ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AppText(
                'Today\'s Activities',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textColorPrimary,
              ),
              TextButton(
                onPressed: () => Get.to(() => const EmployeeNotesScreen()),
                child: const AppText('View All', fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
              ),
            ],
          ),
          const SizedBox(height: 4),
          _buildActivitiesTimeline(controller),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor.withValues(alpha: 0.05),
            AppColors.indigo500.withValues(alpha: 0.12),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.1)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -15,
            child: Icon(
              Iconsax.user,
              size: 110,
              color: AppColors.primaryColor.withValues(alpha: 0.08),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Row(
              children: [
                // User Avatar Circle
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.2), width: 2),
                  ),
                  child: const Center(
                    child: Text(
                      '👨‍💼',
                      style: TextStyle(fontSize: 26),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Labels
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          AppText('Welcome back,', fontSize: 12, color: AppColors.textColorSecondary),
                          SizedBox(width: 4),
                          Text('👋', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                      SizedBox(height: 2),
                      AppText(
                        'Rahul Sharma',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColorPrimary,
                      ),
                      SizedBox(height: 2),
                      AppText(
                        'Sales Executive',
                        fontSize: 11,
                        color: AppColors.textColorSecondary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsDeck(BuildContext context, FollowupController controller) {
    return Obx(() {
      final totalCalls = controller.callLogs.where((c) => c.employeeName == 'Rahul Sharma').length;
      final totalMeets = controller.meetings.where((m) => m.employeeName == 'Rahul Sharma').length;
      final pendingRem = controller.reminders.where((r) => r.employeeName == 'Rahul Sharma' && !r.isCompleted).length;
      final totalNotes = controller.notes.where((n) => n.employeeName == 'Rahul Sharma').length;

      final List<Map<String, dynamic>> stats = [
        {
          'value': '$totalCalls',
          'label': 'Call Logs',
          'sub': 'Today',
          'color': AppColors.primaryColor,
          'onTap': () => Get.to(() => const EmployeeCallLogsScreen()),
        },
        {
          'value': '$totalMeets',
          'label': 'Meetings',
          'sub': 'This Week',
          'color': Colors.green,
          'onTap': () => Get.to(() => const EmployeeMeetingsScreen()),
        },
        {
          'value': '$pendingRem',
          'label': 'Reminders',
          'sub': 'Pending',
          'color': Colors.orange,
          'onTap': () => Get.to(() => const EmployeeRemindersScreen()),
        },
        {
          'value': '$totalNotes',
          'label': 'Notes',
          'sub': 'This Month',
          'color': Colors.purple,
          'onTap': () => Get.to(() => const EmployeeNotesScreen()),
        },
      ];

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 8,
          childAspectRatio: 0.72,
        ),
        itemCount: stats.length,
        itemBuilder: (context, index) {
          final item = stats[index];
          final color = item['color'] as Color;

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.slate200),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: item['onTap'] as VoidCallback?,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppText(
                        item['value'] as String,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: color,
                      ),
                      const SizedBox(height: 6),
                      AppText(
                        item['label'] as String,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColorPrimary,
                      ),
                      const SizedBox(height: 2),
                      AppText(
                        item['sub'] as String,
                        fontSize: 9,
                        color: AppColors.textColorSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildRemindersList(FollowupController controller) {
    return Obx(() {
      final list = controller.reminders.where((r) => r.employeeName == 'Rahul Sharma' && !r.isCompleted).take(3).toList();
      if (list.isEmpty) {
        return _buildEmptyState('No pending reminders scheduled.');
      }

      return Column(
        children: list.map((rem) {
          final color = _getReminderColor(rem.category);
          final icon = _getReminderIcon(rem.category);
          final dateStr = DateFormat('dd MMM, hh:mm a').format(rem.dateTime);

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.slate200),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        rem.title,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColorPrimary,
                      ),
                      const SizedBox(height: 2),
                      AppText(
                        'Scheduled: $dateStr',
                        fontSize: 10,
                        color: AppColors.textColorSecondary,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Iconsax.tick_circle, color: AppColors.textColorHint, size: 20),
                  onPressed: () => controller.toggleReminder(rem.id),
                ),
              ],
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _buildActivitiesTimeline(FollowupController controller) {
    return Obx(() {
      final list = controller.notes.where((n) => n.employeeName == 'Rahul Sharma').take(2).toList();
      if (list.isEmpty) {
        return _buildEmptyState('No activity notes logged today.');
      }

      return Column(
        children: list.map((note) {
          final dateStr = DateFormat('dd MMM, hh:mm a').format(note.dateTime);
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.slate200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText(
                      note.clientName,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                    AppText(
                      dateStr,
                      fontSize: 10,
                      color: AppColors.textColorHint,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                AppText(
                  '${note.title}: ${note.note}',
                  fontSize: 11,
                  color: AppColors.textColorSecondary,
                ),
              ],
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _buildEmptyState(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Center(
        child: AppText(text, fontSize: 11, color: AppColors.textColorHint),
      ),
    );
  }

  Color _getReminderColor(String category) {
    switch (category) {
      case 'Call':
        return AppColors.primaryColor;
      case 'Meeting':
        return Colors.green;
      case 'Task':
        return Colors.orange;
      case 'Follow-up':
      default:
        return Colors.purple;
    }
  }

  IconData _getReminderIcon(String category) {
    switch (category) {
      case 'Call':
        return Iconsax.call;
      case 'Meeting':
        return Iconsax.people;
      case 'Task':
        return Iconsax.task_square;
      case 'Follow-up':
      default:
        return Iconsax.award;
    }
  }
}
