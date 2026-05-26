import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_bottom_sheet_dropdown.dart';
import '../controllers/followup_controller.dart';
import '../models/followup_model.dart';

class AdminCallLogsScreen extends StatelessWidget {
  const AdminCallLogsScreen({super.key});

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
          'Team Call Logs',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textColorPrimary,
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Filter Deck Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                // Search Input Field
                TextField(
                  onChanged: (val) => controller.searchAdminCallQuery.value = val,
                  decoration: InputDecoration(
                    hintText: 'Search by client...',
                    hintStyle: const TextStyle(color: AppColors.textColorHint, fontSize: 13),
                    prefixIcon: const Icon(Iconsax.search_normal, color: AppColors.textColorHint, size: 18),
                    filled: true,
                    fillColor: AppColors.slate50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),

                // Double dropdown filters deck
                Row(
                  children: [
                    Expanded(
                      child: Obx(() {
                        final month = controller.adminSelectedMonth.value;
                        return CustomBottomSheetDropdown(
                          label: 'Month',
                          selectedValue: month,
                          items: controller.months,
                          onChanged: (val) => controller.adminSelectedMonth.value = val,
                        );
                      }),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Obx(() {
                        final emp = controller.adminSelectedEmployee.value;
                        return CustomBottomSheetDropdown(
                          label: 'Representative',
                          selectedValue: emp,
                          items: controller.employees,
                          onChanged: (val) => controller.adminSelectedEmployee.value = val,
                        );
                      }),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Logs Timeline Feed
          Expanded(
            child: Obx(() {
              final list = controller.adminFilteredCallLogs;

              if (list.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Iconsax.call, size: 48, color: AppColors.textColorHint.withValues(alpha: 0.3)),
                      const SizedBox(height: 12),
                      const AppText('No team call logs found matching filters.', fontSize: 12, color: AppColors.textColorHint),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                physics: const BouncingScrollPhysics(),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final log = list[index];
                  return _buildTeamCallCard(log);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamCallCard(CallLog log) {
    Color typeColor = Colors.green;
    IconData typeIcon = Icons.call_made_rounded;

    if (log.type == 'Incoming') {
      typeColor = AppColors.primaryColor;
      typeIcon = Icons.call_received_rounded;
    } else if (log.type == 'Missed') {
      typeColor = AppColors.errorColor;
      typeIcon = Icons.call_missed_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Row(
        children: [
          // Circle Initials representing Employee
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: typeColor.withValues(alpha: 0.08),
            ),
            child: Center(
              child: AppText(
                log.employeeName.isNotEmpty
                    ? log.employeeName.split(' ').map((e) => e[0]).take(2).join().toUpperCase()
                    : 'RE',
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: typeColor,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Details text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText(
                      log.clientName,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColorPrimary,
                    ),
                    AppText(
                      log.timeStr,
                      fontSize: 10,
                      color: AppColors.textColorHint,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                AppText(
                  'Representative: ${log.employeeName}',
                  fontSize: 11,
                  color: AppColors.textColorSecondary,
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: typeColor.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: typeColor.withValues(alpha: 0.15)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(typeIcon, color: typeColor, size: 10),
                          const SizedBox(width: 4),
                          AppText(
                            log.type,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: typeColor,
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Iconsax.clock, color: AppColors.textColorSecondary, size: 12),
                        const SizedBox(width: 4),
                        AppText(
                          log.durationStr,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColorSecondary,
                        ),
                      ],
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
}
