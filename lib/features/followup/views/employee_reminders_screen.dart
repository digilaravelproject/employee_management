import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/followup_controller.dart';
import '../models/followup_model.dart';

class EmployeeRemindersScreen extends StatelessWidget {
  const EmployeeRemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FollowupController>();

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
          'Reminders',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textColorPrimary,
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Filter Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: _buildChipsBar(controller),
          ),

          // Lists sorted by Timeline
          Expanded(
            child: Obx(() {
              final allRems = controller.filteredReminders;
              final employeeRems = allRems.where((r) => r.employeeName == 'Rahul Sharma').toList();

              if (employeeRems.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Iconsax.notification, size: 48, color: AppColors.textColorHint.withValues(alpha: 0.3)),
                      const SizedBox(height: 12),
                      const AppText('No reminders scheduled.', fontSize: 12, color: AppColors.textColorHint),
                    ],
                  ),
                );
              }

              // Group reminders by day
              final todayRems = <FollowupReminder>[];
              final tomorrowRems = <FollowupReminder>[];
              final futureRems = <FollowupReminder>[];

              final now = DateTime.now();
              for (final rem in employeeRems) {
                if (DateUtils.isSameDay(rem.dateTime, now)) {
                  todayRems.add(rem);
                } else if (DateUtils.isSameDay(rem.dateTime, now.add(const Duration(days: 1)))) {
                  tomorrowRems.add(rem);
                } else {
                  futureRems.add(rem);
                }
              }

              return ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  if (todayRems.isNotEmpty) ...[
                    _buildSectionHeader('Today'),
                    ...todayRems.map((rem) => _buildReminderCard(controller, rem)),
                    const SizedBox(height: 16),
                  ],
                  if (tomorrowRems.isNotEmpty) ...[
                    _buildSectionHeader('Tomorrow'),
                    ...tomorrowRems.map((rem) => _buildReminderCard(controller, rem)),
                    const SizedBox(height: 16),
                  ],
                  if (futureRems.isNotEmpty) ...[
                    _buildSectionHeader('Upcoming'),
                    ...futureRems.map((rem) => _buildReminderCard(controller, rem)),
                  ],
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildChipsBar(FollowupController controller) {
    final List<String> chips = ['All', 'Call', 'Meeting', 'Task', 'Follow-up'];
    return Obx(() {
      final selected = controller.selectedReminderFilter.value;
      return SizedBox(
        height: 32,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: chips.length,
          itemBuilder: (context, index) {
            final filter = chips[index];
            final isSelected = selected == filter;

            return GestureDetector(
              onTap: () => controller.selectedReminderFilter.value = filter,
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.indigo500 : AppColors.slate50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.indigo500 : AppColors.slate200,
                  ),
                ),
                child: Center(
                  child: AppText(
                    filter,
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textColorSecondary,
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: AppText(
        title,
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: AppColors.textColorPrimary,
      ),
    );
  }

  Widget _buildReminderCard(FollowupController controller, FollowupReminder rem) {
    final color = _getReminderColor(rem.category);
    final icon = _getReminderIcon(rem.category);
    final dateStr = DateFormat('hh:mm a').format(rem.dateTime);
    final fullDateStr = DateFormat('dd MMMM yyyy, hh:mm a').format(rem.dateTime);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Row(
        children: [
          // Icon Circle
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),

          // Details text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  rem.title,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: rem.isCompleted ? AppColors.textColorHint : AppColors.textColorPrimary,
                  decoration: rem.isCompleted ? TextDecoration.lineThrough : null,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: AppText(
                        rem.category,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Iconsax.clock, color: AppColors.textColorHint, size: 12),
                    const SizedBox(width: 4),
                    AppText(
                      DateUtils.isSameDay(rem.dateTime, DateTime.now()) ? dateStr : fullDateStr,
                      fontSize: 10,
                      color: AppColors.textColorHint,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tick mark action
          IconButton(
            icon: Icon(
              rem.isCompleted ? Iconsax.tick_circle5 : Iconsax.tick_circle,
              color: rem.isCompleted ? Colors.green : AppColors.textColorHint,
              size: 22,
            ),
            onPressed: () => controller.toggleReminder(rem.id),
          ),
        ],
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
