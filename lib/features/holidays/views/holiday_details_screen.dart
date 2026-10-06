import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../models/holiday_model.dart';
import '../controllers/holidays_controller.dart';
import 'add_holiday_screen.dart';
import 'widgets/delete_holiday_dialog.dart';

class HolidayDetailsScreen extends StatefulWidget {
  final String? holidayId;
  const HolidayDetailsScreen({super.key, this.holidayId});

  @override
  State<HolidayDetailsScreen> createState() => _HolidayDetailsScreenState();
}

class _HolidayDetailsScreenState extends State<HolidayDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Get.isRegistered<HolidaysController>()
          ? Get.find<HolidaysController>()
          : Get.put(HolidaysController());
      final targetId = widget.holidayId ?? controller.selectedHoliday.value?.id;
      if (targetId != null && targetId.isNotEmpty) {
        controller.fetchHolidayDetails(targetId);
      }
    });
  }

  String formatFullDate(DateTime date) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    final weekday = weekdays[date.weekday - 1];
    final monthName = months[date.month - 1];
    return '$weekday, ${date.day.toString().padLeft(2, '0')} $monthName ${date.year}';
  }

  String formatDateShort(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  String formatDateTimeString(String? isoString) {
    if (isoString == null || isoString.isEmpty) return 'N/A';
    try {
      final dt = DateTime.parse(isoString).toLocal();
      return '${formatDateShort(dt)} at ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return isoString;
    }
  }

  Color getBadgeColor(String type) {
    if (type.contains('National')) {
      return AppColors.successColor.withValues(alpha: 0.1);
    }
    if (type.contains('Optional')) {
      return AppColors.warningColor.withValues(alpha: 0.1);
    }
    return AppColors.primaryColor.withValues(alpha: 0.1);
  }

  Color getBadgeTextColor(String type) {
    if (type.contains('National')) return AppColors.successColor;
    if (type.contains('Optional')) return AppColors.warningColor;
    return AppColors.primaryColor;
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<HolidaysController>()
        ? Get.find<HolidaysController>()
        : Get.put(HolidaysController());

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
        child: Column(
          children: [
            // Top Linear Progress Bar when fetching fresh API details
            Obx(() {
              if (controller.isLoadingDetails.value &&
                  controller.selectedHoliday.value != null) {
                return const LinearProgressIndicator(
                  minHeight: 2.5,
                  backgroundColor: Colors.transparent,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                );
              }
              return const SizedBox.shrink();
            }),

            Expanded(
              child: Obx(() {
                final holiday = controller.selectedHoliday.value;
                final details = controller.holidayDetails.value;

                if (holiday == null && controller.isLoadingDetails.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ),
                  );
                }

                if (holiday == null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Iconsax.info_circle,
                            size: 48, color: AppColors.textColorHint),
                        const SizedBox(height: 12),
                        const AppText('Holiday not found',
                            fontSize: 16, fontWeight: FontWeight.bold),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => Get.back(),
                          child: const Text('Go Back'),
                        ),
                      ],
                    ),
                  );
                }

                final currentId = widget.holidayId ?? holiday.id;

                return RefreshIndicator(
                  onRefresh: () => controller.fetchHolidayDetails(currentId),
                  color: AppColors.primaryColor,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
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
                                  color: AppColors.primaryLight,
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
                              const SizedBox(height: 10),

                              // Badges Row: Type & Repeat Status
                              Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 8,
                                runSpacing: 6,
                                children: [
                                  // Holiday Type Tag
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 5),
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

                                  // Repeat Every Year Tag
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: holiday.repeatEveryYear
                                          ? AppColors.primaryLight
                                          : AppColors.slate100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Iconsax.repeat,
                                          size: 11,
                                          color: holiday.repeatEveryYear
                                              ? AppColors.primaryColor
                                              : AppColors.textColorHint,
                                        ),
                                        const SizedBox(width: 4),
                                        AppText(
                                          holiday.repeatEveryYear
                                              ? 'Repeats Yearly'
                                              : 'One-time',
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: holiday.repeatEveryYear
                                              ? AppColors.primaryColor
                                              : AppColors.textColorHint,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 24),
                              const Divider(
                                  height: 1, color: AppColors.slate100),
                              const SizedBox(height: 20),

                              // Metadata Rows
                              _buildDetailRow(
                                Iconsax.calendar,
                                formatFullDate(holiday.date),
                                subtitle: details?.dayName != null
                                    ? 'Day: ${details!.dayName}'
                                    : null,
                              ),
                              const SizedBox(height: 14),
                              _buildDetailRow(
                                Iconsax.location,
                                holiday.location,
                                subtitle: 'Applicable Location',
                              ),
                              const SizedBox(height: 14),
                              _buildDetailRow(
                                Iconsax.clock,
                                'Created: ${formatDateTimeString(details?.createdAt)}',
                                subtitle: details?.updatedAt != null &&
                                        details!.updatedAt != details.createdAt
                                    ? 'Updated: ${formatDateTimeString(details.updatedAt)}'
                                    : null,
                              ),
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
                              Row(
                                children: [
                                  Icon(Iconsax.note_text,
                                      size: 18, color: AppColors.primaryColor),
                                  const SizedBox(width: 8),
                                  const AppText(
                                    'Description',
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textColorPrimary,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
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
                            onPressed: () => _showDeleteConfirmationDialog(
                                context, holiday),
                            icon: const Icon(Iconsax.trash,
                                size: 18, color: AppColors.errorColor),
                            label: const AppText(
                              'Delete Holiday',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.errorColor,
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(
                                color: AppColors.errorColor
                                    .withValues(alpha: 0.2),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              backgroundColor: AppColors.errorColor
                                  .withValues(alpha: 0.05),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // Row Metadata Renderer
  Widget _buildDetailRow(IconData icon, String text, {String? subtitle}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 18, color: AppColors.textColorHint),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                text,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textColorPrimary,
              ),
              if (subtitle != null && subtitle.isNotEmpty) ...[
                const SizedBox(height: 2),
                AppText(
                  subtitle,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textColorHint,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // Delete Holiday Confirmation Dialog
  void _showDeleteConfirmationDialog(BuildContext context, Holiday holiday) {
    final controller = Get.isRegistered<HolidaysController>()
        ? Get.find<HolidaysController>()
        : Get.put(HolidaysController());
    showDeleteHolidayDialog(
      context: context,
      holiday: holiday,
      controller: controller,
      onDeleted: () {
        Get.back(); // Pop the details screen back to list
      },
    );
  }
}
