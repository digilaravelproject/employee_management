import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_bottom_sheet_dropdown.dart';
import '../controllers/followup_controller.dart';
import '../models/followup_model.dart';

class AdminRemindersScreen extends StatefulWidget {
  const AdminRemindersScreen({super.key});

  @override
  State<AdminRemindersScreen> createState() => _AdminRemindersScreenState();
}

class _AdminRemindersScreenState extends State<AdminRemindersScreen> {
  final FollowupController controller = Get.find<FollowupController>();

  // Dropdown filter variables
  final _selectedEmployee = 'All Employees'.obs;
  final _selectedCategory = 'All'.obs;

  final List<String> categories = ['All', 'Call', 'Meeting', 'Task', 'Follow-up'];

  @override
  Widget build(BuildContext context) {
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
          'Team Reminders',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textColorPrimary,
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // ── Double Dropdowns Filters Deck Header ──
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Obx(() {
                    final emp = _selectedEmployee.value;
                    return CustomBottomSheetDropdown(
                      label: 'Representative',
                      selectedValue: emp,
                      items: controller.employees,
                      onChanged: (val) {
                        _selectedEmployee.value = val;
                      },
                    );
                  }),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(() {
                    final cat = _selectedCategory.value;
                    return CustomBottomSheetDropdown(
                      label: 'Category',
                      selectedValue: cat,
                      items: categories,
                      onChanged: (val) {
                        _selectedCategory.value = val;
                      },
                    );
                  }),
                ),
              ],
            ),
          ),

          // ── Reminders Timeline lists ──
          Expanded(
            child: Obx(() {
              final allRems = controller.reminders;
              final selectedEmp = _selectedEmployee.value;
              final selectedCat = _selectedCategory.value;

              // Filter by employee, category
              final teamRems = allRems.where((r) {
                final matchEmp = selectedEmp == 'All Employees' || r.employeeName == selectedEmp;
                final matchCat = selectedCat == 'All' || r.category == selectedCat;
                return matchEmp && matchCat;
              }).toList();

              if (teamRems.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Iconsax.notification, size: 48, color: AppColors.textColorHint.withValues(alpha: 0.3)),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: AppText(
                          'No reminders found matching the active filters.',
                          fontSize: 12,
                          color: AppColors.textColorHint,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Group into Pending and Completed
              final pendingRems = teamRems.where((r) => !r.isCompleted).toList();
              final completedRems = teamRems.where((r) => r.isCompleted).toList();

              return ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  if (pendingRems.isNotEmpty) ...[
                    _buildSectionHeader('Pending Reminders (${pendingRems.length})'),
                    ...pendingRems.map((rem) => _buildReminderCard(rem)),
                    const SizedBox(height: 16),
                  ],
                  if (completedRems.isNotEmpty) ...[
                    _buildSectionHeader('Completed Reminders (${completedRems.length})'),
                    ...completedRems.map((rem) => _buildReminderCard(rem)),
                  ],
                ],
              );
            }),
          ),
        ],
      ),
    );
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

  Widget _buildReminderCard(FollowupReminder rem) {
    final color = _getReminderColor(rem.category);
    final icon = _getReminderIcon(rem.category);
    final fullDateStr = DateFormat('dd MMM yyyy, hh:mm a').format(rem.dateTime);

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
                AppText(
                  'Assigned to: ${rem.employeeName}',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColorSecondary,
                ),
                const SizedBox(height: 6),
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
                      fullDateStr,
                      fontSize: 10,
                      color: AppColors.textColorHint,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Symmetrical checkbox for Admin to check/uncheck reminders or toggle status
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
