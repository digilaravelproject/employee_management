import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/attendance_history_controller.dart';

class AttendanceDayDetailsScreen extends StatelessWidget {
  const AttendanceDayDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AttendanceHistoryController>();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textColorPrimary, size: 18),
          onPressed: () => Get.back(),
        ),
        title: const AppText(
          'Attendance Details',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textColorPrimary,
        ),
        centerTitle: false,
      ),
      body: Obx(() {
        final record = controller.selectedRecord.value;
        if (record == null) {
          return const Center(
            child: AppText(
              'No day selected or record not found.',
              color: AppColors.textColorSecondary,
            ),
          );
        }

        final dateTitleStr = DateFormat('dd MMMM yyyy').format(record.date);
        final dayOfWeekStr = DateFormat('EEEE').format(record.date);

        // Status visual definitions
        Color statusColor;
        Color statusLightBg;
        IconData statusIcon;
        
        switch (record.status) {
          case 'Present':
            statusColor = AppColors.successColor;
            statusLightBg = const Color(0xFFEAFAF1);
            statusIcon = Icons.check_circle;
            break;
          case 'Half Day':
            statusColor = AppColors.warningColor;
            statusLightBg = const Color(0xFFFEF9EC);
            statusIcon = Icons.star_half;
            break;
          case 'Absent':
            statusColor = AppColors.errorColor;
            statusLightBg = const Color(0xFFFDF2F2);
            statusIcon = Icons.cancel;
            break;
          case 'Leave':
            statusColor = AppColors.indigo500;
            statusLightBg = const Color(0xFFEEF2FF);
            statusIcon = Icons.beach_access;
            break;
          default:
            statusColor = AppColors.textColorSecondary;
            statusLightBg = AppColors.slate100;
            statusIcon = Icons.info;
        }

        return SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                
                // Top Status Badge & Big Circular Icon (Screen 3)
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: statusLightBg,
                        ),
                      ),
                      Container(
                        width: 66,
                        height: 66,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: statusColor.withOpacity(0.2),
                        ),
                      ),
                      Icon(
                        statusIcon,
                        color: statusColor,
                        size: 48,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Date and Day
                AppText(
                  dateTitleStr,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textColorPrimary,
                ),
                const SizedBox(height: 4),
                AppText(
                  dayOfWeekStr,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColorSecondary,
                ),
                const SizedBox(height: 24),

                // Table Symmetrical Grid Card
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withOpacity(0.01),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildGridRow(
                        context,
                        leftCell: _GridCell(
                          label: 'Check In',
                          value: record.checkIn,
                          icon: Iconsax.login,
                          iconColor: AppColors.successColor,
                        ),
                        rightCell: _GridCell(
                          label: 'Check Out',
                          value: record.checkOut,
                          icon: Iconsax.logout,
                          iconColor: AppColors.errorColor,
                        ),
                      ),
                      const Divider(height: 1, color: AppColors.borderColor),
                      _buildGridRow(
                        context,
                        leftCell: _GridCell(
                          label: 'Working Hours',
                          value: record.workingHours,
                          icon: Iconsax.clock,
                          iconColor: AppColors.primaryColor,
                        ),
                        rightCell: _GridCell(
                          label: 'Break Time',
                          value: record.breakTime,
                          icon: Iconsax.coffee,
                          iconColor: AppColors.warningColor,
                        ),
                      ),
                      const Divider(height: 1, color: AppColors.borderColor),
                      _buildGridRow(
                        context,
                        leftCell: _GridCell(
                          label: 'Status',
                          value: record.status,
                          icon: Iconsax.info_circle,
                          iconColor: statusColor,
                          useBadge: true,
                          badgeBgColor: statusLightBg,
                          badgeTextColor: statusColor,
                        ),
                        rightCell: _GridCell(
                          label: 'Location',
                          value: record.location,
                          icon: Iconsax.location,
                          iconColor: AppColors.indigo500,
                        ),
                      ),
                      const Divider(height: 1, color: AppColors.borderColor),
                      _buildGridRow(
                        context,
                        leftCell: _GridCell(
                          label: 'Late By',
                          value: record.lateBy,
                          icon: Iconsax.timer,
                          iconColor: AppColors.textColorHint,
                        ),
                        rightCell: _GridCell(
                          label: 'Early Leave',
                          value: record.earlyLeave,
                          icon: Iconsax.timer_1,
                          iconColor: AppColors.textColorHint,
                        ),
                      ),
                      const Divider(height: 1, color: AppColors.borderColor),
                      _buildFullWidthRow(
                        label: 'Remarks',
                        value: record.remarks,
                        icon: Iconsax.document_text,
                        iconColor: AppColors.primaryColor,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Info Banner Alert (Screen 3 blue details alert)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primaryColor.withOpacity(0.15)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Iconsax.info_circle,
                        color: AppColors.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppText(
                          'Working hours includes break time.',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildGridRow(
    BuildContext context, {
    required Widget leftCell,
    required Widget rightCell,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: leftCell),
          Container(width: 1, color: AppColors.borderColor),
          Expanded(child: rightCell),
        ],
      ),
    );
  }

  Widget _buildFullWidthRow({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  label,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textColorSecondary,
                ),
                const SizedBox(height: 2),
                AppText(
                  value,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColorPrimary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GridCell extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final bool useBadge;
  final Color? badgeBgColor;
  final Color? badgeTextColor;

  const _GridCell({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.useBadge = false,
    this.badgeBgColor,
    this.badgeTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  label,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textColorSecondary,
                ),
                const SizedBox(height: 4),
                if (useBadge && badgeBgColor != null && badgeTextColor != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: badgeBgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: AppText(
                      value,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: badgeTextColor,
                    ),
                  )
                else
                  AppText(
                    value,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColorPrimary,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
