import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/shift_controller.dart';

class ShiftHistoryScreen extends StatelessWidget {
  const ShiftHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ShiftController controller = Get.isRegistered<ShiftController>()
        ? Get.find<ShiftController>()
        : Get.put(ShiftController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textColorPrimary, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const AppText('Shift History', fontSize: 18, fontWeight: FontWeight.bold),
        centerTitle: false,
      ),
      body: Obx(() {
        final logs = controller.historyList;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header & Filter bar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.slate200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppText('All Activity Logs', fontSize: 15, fontWeight: FontWeight.bold),
                        const SizedBox(height: 2),
                        AppText('${logs.length} recorded events', fontSize: 12, color: AppColors.textColorSecondary),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.slate50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.slate200),
                      ),
                      child: const Row(
                        children: [
                          AppText('All Activities', fontSize: 12, fontWeight: FontWeight.bold),
                          SizedBox(width: 4),
                          Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.textColorSecondary),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // History Cards
              ...logs.map((item) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.slate200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: item.actionColor.withValues(alpha: 0.1),
                        child: Icon(
                          item.action == 'Created'
                              ? Iconsax.add_circle
                              : item.action == 'Assigned'
                                  ? Iconsax.user_add
                                  : item.action == 'Deactivated'
                                      ? Iconsax.slash
                                      : Iconsax.edit_2,
                          size: 18,
                          color: item.actionColor,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    AppText(item.userName, fontSize: 13, fontWeight: FontWeight.bold),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: AppColors.slate100,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const AppText('Admin', fontSize: 9, color: AppColors.textColorSecondary),
                                    ),
                                  ],
                                ),
                                AppText(item.date, fontSize: 11, color: AppColors.textColorHint),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: item.actionColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: AppText(
                                    item.action,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: item.actionColor,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: AppText(
                                    item.details,
                                    fontSize: 12,
                                    color: AppColors.textColorPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      }),
    );
  }
}
