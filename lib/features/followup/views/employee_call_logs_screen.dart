import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/followup_controller.dart';
import '../models/followup_model.dart';

class EmployeeCallLogsScreen extends StatelessWidget {
  const EmployeeCallLogsScreen({super.key});

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
          'Call Logs',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textColorPrimary,
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Search & Filters Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                // Search Input Field
                TextField(
                  onChanged: (val) => controller.searchCallQuery.value = val,
                  decoration: InputDecoration(
                    hintText: 'Search call logs...',
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

                // Chips Filters Bar
                _buildChipsBar(controller),
              ],
            ),
          ),

          // Calls Timeline list
          Expanded(
            child: Obx(() {
              // default: show only Rahul Sharma's logs for Employee View
              final allLogs = controller.filteredCallLogs;
              final employeeLogs = allLogs.where((c) => c.employeeName == 'Rahul Sharma').toList();

              if (employeeLogs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Iconsax.call, size: 48, color: AppColors.textColorHint.withValues(alpha: 0.3)),
                      const SizedBox(height: 12),
                      const AppText('No matching call logs recorded.', fontSize: 12, color: AppColors.textColorHint),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                physics: const BouncingScrollPhysics(),
                itemCount: employeeLogs.length,
                itemBuilder: (context, index) {
                  final log = employeeLogs[index];
                  return _buildCallLogCard(log);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildChipsBar(FollowupController controller) {
    final List<String> chips = ['All', 'Outgoing', 'Incoming', 'Missed'];
    return Obx(() {
      final selected = controller.selectedCallFilter.value;
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
              onTap: () => controller.selectedCallFilter.value = filter,
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryColor : AppColors.slate50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.primaryColor : AppColors.slate200,
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

  Widget _buildCallLogCard(CallLog log) {
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
          // Tinted Circle Avatar representing status
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(typeIcon, color: typeColor, size: 18),
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
                      child: AppText(
                        log.type,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: typeColor,
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
