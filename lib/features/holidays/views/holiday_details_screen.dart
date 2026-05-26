import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../models/holiday_model.dart';
import '../controllers/holidays_controller.dart';
import 'add_holiday_screen.dart';


class HolidayDetailsScreen extends StatelessWidget {
  const HolidayDetailsScreen({super.key});

  String formatFullDate(DateTime date) {
    const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    
    final weekday = weekdays[date.weekday - 1];
    final monthName = months[date.month - 1];
    return '$weekday, ${date.day.toString().padLeft(2, '0')} $monthName ${date.year}';
  }

  String formatDateShort(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  Color getBadgeColor(String type) {
    if (type.contains('National')) return AppColors.successColor.withOpacity(0.1);
    if (type.contains('Optional')) return AppColors.warningColor.withOpacity(0.1);
    return AppColors.primaryColor.withOpacity(0.1);
  }

  Color getBadgeTextColor(String type) {
    if (type.contains('National')) return AppColors.successColor;
    if (type.contains('Optional')) return AppColors.warningColor;
    return AppColors.primaryColor;
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HolidaysController>();

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
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.textColorPrimary,
                size: 20,
              ),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        title: const AppText(
          'Holiday Details',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textColorPrimary,
        ),
        actions: [
          // Edit Pencil Button
          Obx(() {
            final holiday = controller.selectedHoliday.value;
            if (holiday == null) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: IconButton(
                icon: const Icon(
                  Iconsax.edit,
                  color: AppColors.textColorSecondary,
                ),
                onPressed: () {
                  controller.populateForm(holiday);
                  Get.to(() => const AddHolidayScreen());
                },
              ),
            );
          }),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          final holiday = controller.selectedHoliday.value;
          if (holiday == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Main Card Information ──
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.slate100),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Circular calendar icon badge
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryLight, // Soft blue background tint
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Iconsax.calendar_1,
                          color: AppColors.primaryColor,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Holiday Name
                      AppText(
                        holiday.name,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textColorPrimary,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),

                      // Tag type
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: getBadgeColor(holiday.type),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: AppText(
                          holiday.type,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: getBadgeTextColor(holiday.type),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Divider(height: 1, color: AppColors.slate100),
                      const SizedBox(height: 20),

                      // Metadata Rows
                      _buildDetailRow(Iconsax.calendar, formatFullDate(holiday.date)),
                      const SizedBox(height: 14),
                      _buildDetailRow(Iconsax.location, holiday.location),
                      const SizedBox(height: 14),
                      _buildDetailRow(Iconsax.user, 'Added by ${holiday.addedBy}'),
                      const SizedBox(height: 14),
                      _buildDetailRow(Iconsax.clock, 'Added on ${formatDateShort(holiday.addedOn)}'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Description Card ──
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.slate100),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppText(
                        'Description',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColorPrimary,
                      ),
                      const SizedBox(height: 8),
                      AppText(
                        holiday.description.isNotEmpty
                            ? holiday.description
                            : 'No description provided for this holiday.',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textColorSecondary,
                        letterSpacing: 0.1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // ── Delete Button ──
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showDeleteConfirmationDialog(holiday),
                    icon: const Icon(Iconsax.trash, size: 18, color: AppColors.errorColor),
                    label: const AppText(
                      'Delete Holiday',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.errorColor,
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: AppColors.errorColor.withOpacity(0.2)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      backgroundColor: AppColors.errorColor.withOpacity(0.05), // Soft red background tint
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // Row Metadata Renderer
  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textColorHint),
        const SizedBox(width: 12),
        Expanded(
          child: AppText(
            text,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textColorSecondary,
          ),
        ),
      ],
    );
  }

  // Delete Holiday Confirmation Dialog
  void _showDeleteConfirmationDialog(Holiday holiday) {
    final controller = Get.find<HolidaysController>();
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Iconsax.warning_2, color: AppColors.errorColor, size: 26),
            const SizedBox(width: 10),
            const AppText('Delete Holiday?', fontSize: 16, fontWeight: FontWeight.bold),
          ],
        ),
        content: AppText(
          'Are you sure you want to delete "${holiday.name}"? This action cannot be undone.',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textColorSecondary,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const AppText('Cancel', fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorSecondary),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteHoliday(holiday.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const AppText('Delete', fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
