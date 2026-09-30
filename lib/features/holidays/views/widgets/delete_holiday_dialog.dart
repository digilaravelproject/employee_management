import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text.dart';
import '../../controllers/holidays_controller.dart';
import '../../models/holiday_model.dart';

void showDeleteHolidayDialog({
  required BuildContext context,
  required Holiday holiday,
  required HolidaysController controller,
  VoidCallback? onDeleted,
}) {
  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Soft red warning icon container
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFECACA), width: 1.5),
              ),
              child: const Icon(
                Iconsax.trash,
                color: Color(0xFFDC2626),
                size: 30,
              ),
            ),
            const SizedBox(height: 18),

            // Title
            const AppText(
              'Delete Holiday?',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textColorPrimary,
            ),
            const SizedBox(height: 8),

            // Subtitle
            const AppText(
              'Are you sure you want to delete this holiday? This action will permanently remove it from the system.',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textColorSecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),

            // Target Holiday Card preview
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppText(
                          holiday.date.day.toString().padLeft(2, '0'),
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryColor,
                        ),
                        AppText(
                          [
                            'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                            'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
                          ][holiday.date.month - 1],
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textColorHint,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          holiday.name,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColorPrimary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: holiday.type.contains('National')
                                    ? const Color(0xFFECFDF5)
                                    : const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: AppText(
                                holiday.type,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: holiday.type.contains('National')
                                    ? const Color(0xFF059669)
                                    : const Color(0xFF2563EB),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: AppText(
                                holiday.location,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textColorHint,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // Action Buttons Row
            Row(
              children: [
                // Cancel
                Expanded(
                  child: Obx(() {
                    final isDeleting = controller.isDeleting.value;
                    return OutlinedButton(
                      onPressed: isDeleting ? null : () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const AppText(
                        'Cancel',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColorSecondary,
                      ),
                    );
                  }),
                ),
                const SizedBox(width: 12),

                // Delete
                Expanded(
                  child: Obx(() {
                    final isDeleting = controller.isDeleting.value;
                    return ElevatedButton(
                      onPressed: isDeleting
                          ? null
                          : () async {
                              final success = await controller.deleteHoliday(holiday.id);
                              if (success) {
                                Get.back(); // Close dialog
                                onDeleted?.call();
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isDeleting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Iconsax.trash, size: 16, color: Colors.white),
                                SizedBox(width: 6),
                                AppText(
                                  'Delete',
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                    );
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
    barrierDismissible: true,
  );
}
