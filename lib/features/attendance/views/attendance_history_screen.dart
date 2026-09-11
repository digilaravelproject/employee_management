import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/attendance_history_controller.dart';
import 'attendance_day_details_screen.dart';

class AttendanceHistoryScreen extends StatelessWidget {
  final bool showBackButton;
  final String? employeeName;
  final String? employeeId;
  final String? employeeDesignation;

  const AttendanceHistoryScreen({
    super.key,
    this.showBackButton = true,
    this.employeeName,
    this.employeeId,
    this.employeeDesignation,
  });

  @override
  Widget build(BuildContext context) {
    // Put or find the controller
    final controller = Get.put(AttendanceHistoryController());

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: showBackButton 
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textColorPrimary, size: 18),
                onPressed: () => Get.back(),
              )
            : null,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText(
              employeeName != null ? "$employeeName's Attendance" : 'Attendance History',
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textColorPrimary,
            ),
            if (employeeId != null)
              AppText(
                '$employeeId${employeeDesignation != null ? ' • $employeeDesignation' : ''}',
                fontSize: 11,
                color: AppColors.textColorSecondary,
              ),
          ],
        ),
        centerTitle: false,
        actions: [
          // Month Selector in AppBar
          Obx(() {
            final monthText = DateFormat('MMMM yyyy').format(controller.selectedMonth.value);
            return TextButton.icon(
              onPressed: () => _showMonthPicker(context, controller),
              icon: const Icon(Iconsax.calendar_1, size: 16, color: AppColors.primaryColor),
              label: Row(
                children: [
                  AppText(
                    monthText,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryColor,
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.primaryColor),
                ],
              ),
            );
          }),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (employeeName != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Iconsax.user_tick, color: Color(0xFF16A34A), size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              employeeName!,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF15803D),
                            ),
                            AppText(
                              'Individual attendance breakdown & monthly summary for administrator view',
                              fontSize: 11,
                              color: const Color(0xFF166534),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Stats overview Grid
              const _StatsOverviewGrid(),
              const SizedBox(height: 16),

              // Monthly Summary Card with linear progress
              const _MonthlySummaryCard(),
              const SizedBox(height: 20),

              // Calendar Card
              const _CalendarSectionCard(),
              const SizedBox(height: 20),

              // Recent records
              const _RecentRecordsHeader(),
              const SizedBox(height: 10),
              const _RecentRecordsList(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // Month Picker Bottom Sheet
  void _showMonthPicker(BuildContext context, AttendanceHistoryController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        int localSelectedYear = controller.selectedMonth.value.year;

        return StatefulBuilder(
          builder: (context, setBottomSheetState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const AppText(
                        'Select Month & Year',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textColorPrimary,
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, size: 20, color: AppColors.textColorSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(color: AppColors.dividerColor),
                  const SizedBox(height: 12),
                  
                  // Year Selection Label
                  const AppText(
                    'Select Year',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColorSecondary,
                  ),
                  const SizedBox(height: 8),

                  // Horizontal list of years
                  Row(
                    children: [2023, 2024, 2025, 2026].map((year) {
                      final isSelectedYear = localSelectedYear == year;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: InkWell(
                          onTap: () {
                            setBottomSheetState(() {
                              localSelectedYear = year;
                            });
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelectedYear ? AppColors.primaryColor : AppColors.slate100,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelectedYear ? AppColors.primaryColor : AppColors.borderColor,
                              ),
                            ),
                            child: AppText(
                              year.toString(),
                              fontSize: 12,
                              fontWeight: isSelectedYear ? FontWeight.w600 : FontWeight.w500,
                              color: isSelectedYear ? AppColors.white : AppColors.textColorPrimary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Month Selection Label
                  const AppText(
                    'Select Month',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColorSecondary,
                  ),
                  const SizedBox(height: 8),

                  // Months Grid
                  SizedBox(
                    height: 200,
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 1.6,
                      ),
                      itemCount: 12,
                      itemBuilder: (context, index) {
                        final monthVal = index + 1;
                        final targetDate = DateTime(localSelectedYear, monthVal, 1);
                        final monthName = DateFormat('MMM').format(targetDate);
                        
                        final isSelected = controller.selectedMonth.value.month == monthVal &&
                            controller.selectedMonth.value.year == localSelectedYear;
                        
                        return InkWell(
                          onTap: () {
                            controller.changeMonth(targetDate);
                            Navigator.pop(context);
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primaryColor : AppColors.slate100,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected ? AppColors.primaryColor : AppColors.borderColor,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: AppText(
                              monthName,
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected ? AppColors.white : AppColors.textColorPrimary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ── STATS OVERVIEW GRID ──────────────────────────────────────────────────────
class _StatsOverviewGrid extends StatelessWidget {
  const _StatsOverviewGrid();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AttendanceHistoryController>();

    return Obx(() {
      final present = controller.presentDaysCount;
      final halfDay = controller.halfDayCount;
      final absent = controller.absentCount;
      final leave = controller.leaveCount;

      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        childAspectRatio: 1.0,
        children: [
          _StatCard(
            label: 'Present',
            value: present.toString(),
            color: AppColors.successColor,
            bgColor: const Color(0xFFEAFAF1),
            icon: Icons.check_circle_outline,
          ),
          _StatCard(
            label: 'Half Day',
            value: halfDay.toString(),
            color: AppColors.warningColor,
            bgColor: const Color(0xFFFEF9EC),
            icon: Icons.star_half_outlined,
          ),
          _StatCard(
            label: 'Absent',
            value: absent.toString(),
            color: AppColors.errorColor,
            bgColor: const Color(0xFFFDF2F2),
            icon: Icons.cancel_outlined,
          ),
          _StatCard(
            label: 'Leave',
            value: leave.toString(),
            color: AppColors.indigo500,
            bgColor: const Color(0xFFEEF2FF),
            icon: Icons.beach_access_outlined,
          ),
        ],
      );
    });
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color bgColor;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.bgColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.15), width: 1),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 4),
          AppText(
            value,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: color,
          ),
          const SizedBox(height: 2),
          AppText(
            label,
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: AppColors.textColorSecondary,
            align: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── MONTHLY SUMMARY CARD ──────────────────────────────────────────────────────
class _MonthlySummaryCard extends StatelessWidget {
  const _MonthlySummaryCard();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AttendanceHistoryController>();

    return Obx(() {
      final percentage = controller.attendancePercentage;
      final workingDays = controller.workingDaysCount;
      final presentDays = controller.presentDaysCount;

      return Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderColor),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText(
              'Monthly Summary',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textColorSecondary,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          AppText(
                            '$percentage%',
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryColor,
                          ),
                          const SizedBox(width: 4),
                          const AppText(
                            'Attendance',
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textColorSecondary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.event, size: 12, color: AppColors.textColorHint),
                          const SizedBox(width: 4),
                          AppText(
                            'Working Days: ',
                            fontSize: 11,
                            color: AppColors.textColorSecondary,
                          ),
                          AppText(
                            '$workingDays',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColorPrimary,
                          ),
                          const SizedBox(width: 12),
                          const Icon(Icons.check_circle_outline, size: 12, color: AppColors.textColorHint),
                          const SizedBox(width: 4),
                          AppText(
                            'Present: ',
                            fontSize: 11,
                            color: AppColors.textColorSecondary,
                          ),
                          AppText(
                            '$presentDays',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColorPrimary,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Circular Progress Indicator representing attendance percentage
                SizedBox(
                  height: 48,
                  width: 48,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: AppColors.slate100,
                        color: AppColors.primaryColor,
                        strokeWidth: 5,
                      ),
                      Center(
                        child: Icon(
                          Icons.trending_up,
                          color: AppColors.primaryColor,
                          size: 18,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage / 100,
                backgroundColor: AppColors.slate100,
                color: AppColors.primaryColor,
                minHeight: 6,
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ── CALENDAR CARD ─────────────────────────────────────────────────────────────
class _CalendarSectionCard extends StatelessWidget {
  const _CalendarSectionCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Weekday Labels Row
          const _WeekdayLabelsRow(),
          const SizedBox(height: 10),

          // Calendar Grid
          const _CalendarGrid(),
          const SizedBox(height: 16),

          // Legend Bar
          const _CalendarLegend(),
        ],
      ),
    );
  }
}

class _WeekdayLabelsRow extends StatelessWidget {
  const _WeekdayLabelsRow();

  @override
  Widget build(BuildContext context) {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekdays.map((day) {
        final isWeekend = day == 'Sat' || day == 'Sun';
        return Expanded(
          child: Center(
            child: AppText(
              day,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isWeekend ? AppColors.textColorHint : AppColors.textColorSecondary,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid();

  List<DateTime> _getCalendarDays(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final prevMonthPadding = firstDay.weekday - 1;
    final List<DateTime> days = [];
    
    // Previous month padding days
    final prevMonthDaysCount = DateTime(month.year, month.month, 0).day;
    for (int i = prevMonthDaysCount - prevMonthPadding + 1; i <= prevMonthDaysCount; i++) {
      days.add(DateTime(month.year, month.month - 1, i));
    }
    
    // Active month days
    final activeMonthDaysCount = DateTime(month.year, month.month + 1, 0).day;
    for (int i = 1; i <= activeMonthDaysCount; i++) {
      days.add(DateTime(month.year, month.month, i));
    }
    
    // Next month padding days to fill grid (multiple of 7, e.g. 35 or 42)
    final totalSlots = (days.length <= 35) ? 35 : 42;
    final nextMonthPadding = totalSlots - days.length;
    for (int i = 1; i <= nextMonthPadding; i++) {
      days.add(DateTime(month.year, month.month + 1, i));
    }
    
    return days;
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AttendanceHistoryController>();

    return Obx(() {
      final activeMonth = controller.selectedMonth.value;
      final days = _getCalendarDays(activeMonth);
      final selectedRecord = controller.selectedRecord.value;

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: days.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
          childAspectRatio: 1.0,
        ),
        itemBuilder: (context, index) {
          final date = days[index];
          final isCurrentMonth = date.month == activeMonth.month && date.year == activeMonth.year;
          final record = controller.getRecordForDate(date);
          
          final isSelected = selectedRecord != null &&
              selectedRecord.date.day == date.day &&
              selectedRecord.date.month == date.month &&
              selectedRecord.date.year == date.year;

          // Status determinations
          Color? statusBgColor;
          Color statusTextColor = AppColors.textColorPrimary;
          
          if (record != null && isCurrentMonth) {
            switch (record.status) {
              case 'Present':
                statusBgColor = AppColors.successColor;
                statusTextColor = AppColors.white;
                break;
              case 'Half Day':
                statusBgColor = AppColors.warningColor;
                statusTextColor = AppColors.white;
                break;
              case 'Absent':
                statusBgColor = AppColors.errorColor;
                statusTextColor = AppColors.white;
                break;
              case 'Leave':
                statusBgColor = AppColors.indigo500;
                statusTextColor = AppColors.white;
                break;
              case 'Weekend':
                statusBgColor = AppColors.slate100;
                statusTextColor = AppColors.textColorSecondary.withOpacity(0.7);
                break;
              default:
                statusBgColor = Colors.transparent;
                statusTextColor = AppColors.textColorPrimary;
            }
          } else {
            // Out of month or no record
            statusBgColor = Colors.transparent;
            statusTextColor = AppColors.textColorHint.withOpacity(0.5);
          }

          return InkWell(
            onTap: () {
              if (isCurrentMonth && record != null) {
                controller.selectedRecord.value = record;
                _showDayDetailsBottomSheet(context, controller);
              }
            },
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: statusBgColor,
                border: isSelected
                    ? Border.all(color: AppColors.primaryColor, width: 2)
                    : null,
              ),
              alignment: Alignment.center,
              child: AppText(
                date.day.toString(),
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : (isCurrentMonth ? FontWeight.w600 : FontWeight.w400),
                color: statusTextColor,
              ),
            ),
          );
        },
      );
    });
  }

  // Tapped Day Bottom Sheet (Screen 2)
  void _showDayDetailsBottomSheet(BuildContext context, AttendanceHistoryController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Obx(() {
          final record = controller.selectedRecord.value;
          if (record == null) {
            return const Padding(
              padding: EdgeInsets.all(20.0),
              child: Center(child: AppText('No details available.')),
            );
          }

          final dateStr = DateFormat('EEEE, d MMM yyyy').format(record.date);
          
          Color badgeBg;
          Color badgeText;
          switch (record.status) {
            case 'Present':
              badgeBg = const Color(0xFFEAFAF1);
              badgeText = AppColors.successColor;
              break;
            case 'Half Day':
              badgeBg = const Color(0xFFFEF9EC);
              badgeText = AppColors.warningColor;
              break;
            case 'Absent':
              badgeBg = const Color(0xFFFDF2F2);
              badgeText = AppColors.errorColor;
              break;
            case 'Leave':
              badgeBg = const Color(0xFFEEF2FF);
              badgeText = AppColors.indigo500;
              break;
            default:
              badgeBg = AppColors.slate100;
              badgeText = AppColors.textColorSecondary;
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.borderColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Top Title & Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: AppText(
                          dateStr,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textColorPrimary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: AppText(
                          record.status,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: badgeText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppColors.dividerColor),
                  const SizedBox(height: 16),

                  // Checkout and Stats Rows
                  Row(
                    children: [
                      Expanded(
                        child: _QuickDetailCell(
                          title: 'Check In',
                          value: record.checkIn,
                          icon: Iconsax.login,
                          iconColor: AppColors.successColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickDetailCell(
                          title: 'Check Out',
                          value: record.checkOut,
                          icon: Iconsax.logout,
                          iconColor: AppColors.errorColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickDetailCell(
                          title: 'Working Hours',
                          value: record.workingHours,
                          icon: Iconsax.clock,
                          iconColor: AppColors.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickDetailCell(
                          title: 'Break Time',
                          value: record.breakTime,
                          icon: Iconsax.coffee,
                          iconColor: AppColors.warningColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  
                  // Primary View Details Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        // Dismiss the bottom sheet
                        Navigator.pop(context);
                        // Navigate to full details page
                        Get.to(() => const AttendanceDayDetailsScreen());
                      },
                      child: const AppText(
                        'View Details',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }
}

class _QuickDetailCell extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _QuickDetailCell({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.slate50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderColor.withOpacity(0.6)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppText(
                  title,
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
          )
        ],
      ),
    );
  }
}

class _CalendarLegend extends StatelessWidget {
  const _CalendarLegend();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 6,
      alignment: WrapAlignment.center,
      children: [
        _LegendItem(color: AppColors.successColor, label: 'Present'),
        _LegendItem(color: AppColors.warningColor, label: 'Half Day'),
        _LegendItem(color: AppColors.errorColor, label: 'Absent'),
        _LegendItem(color: AppColors.indigo500, label: 'Leave'),
        _LegendItem(color: AppColors.slate200, label: 'Weekend'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        AppText(
          label,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.textColorSecondary,
        ),
      ],
    );
  }
}

// ── RECENT RECORDS HEADER ──────────────────────────────────────────────────────
class _RecentRecordsHeader extends StatelessWidget {
  const _RecentRecordsHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(
            'Recent Records',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textColorPrimary,
          ),
          AppText(
            'Check In/Out',
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textColorSecondary,
          ),
        ],
      ),
    );
  }
}

// ── RECENT RECORDS LIST ────────────────────────────────────────────────────────
class _RecentRecordsList extends StatelessWidget {
  const _RecentRecordsList();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AttendanceHistoryController>();

    return Obx(() {
      // Show list of the records for selected month, sorted descending (newest first)
      final records = controller.activeMonthRecords
          .where((r) => r.status != 'Weekend')
          .toList();
      records.sort((a, b) => b.date.compareTo(a.date));

      if (records.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: AppText(
              'No records for this month',
              color: AppColors.textColorHint,
              fontSize: 13,
            ),
          ),
        );
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: records.length > 5 ? 5 : records.length, // Show up to 5 recent
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final record = records[index];
          final dateDayStr = DateFormat('dd').format(record.date);
          final dateWeekStr = DateFormat('EEE').format(record.date);

          Color statusColor;
          Color statusBg;
          switch (record.status) {
            case 'Present':
              statusColor = AppColors.successColor;
              statusBg = const Color(0xFFEAFAF1);
              break;
            case 'Half Day':
              statusColor = AppColors.warningColor;
              statusBg = const Color(0xFFFEF9EC);
              break;
            case 'Absent':
              statusColor = AppColors.errorColor;
              statusBg = const Color(0xFFFDF2F2);
              break;
            case 'Leave':
              statusColor = AppColors.indigo500;
              statusBg = const Color(0xFFEEF2FF);
              break;
            default:
              statusColor = AppColors.textColorSecondary;
              statusBg = AppColors.slate100;
          }

          return InkWell(
            onTap: () {
              controller.selectedRecord.value = record;
              Get.to(() => const AttendanceDayDetailsScreen());
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderColor),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  // Left Date Column
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.slate50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderColor.withOpacity(0.6)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppText(
                          dateDayStr,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textColorPrimary,
                        ),
                        AppText(
                          dateWeekStr,
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColorSecondary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Middle Check In/Out Times
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.arrow_downward, size: 10, color: AppColors.successColor),
                            const SizedBox(width: 2),
                            AppText(
                              record.checkIn,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textColorPrimary,
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_upward, size: 10, color: AppColors.errorColor),
                            const SizedBox(width: 2),
                            AppText(
                              record.checkOut,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textColorPrimary,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Iconsax.clock, size: 10, color: AppColors.textColorHint),
                            const SizedBox(width: 4),
                            AppText(
                              'Hrs: ${record.workingHours}',
                              fontSize: 10,
                              color: AppColors.textColorSecondary,
                            ),
                            if (record.status == 'Half Day') ...[
                              const SizedBox(width: 8),
                              Container(
                                width: 3,
                                height: 3,
                                decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.textColorHint),
                              ),
                              const SizedBox(width: 8),
                              const AppText(
                                'Half Day',
                                fontSize: 10,
                                color: AppColors.warningColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ]
                          ],
                        )
                      ],
                    ),
                  ),

                  // Status Badge on Right
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: AppText(
                      record.status,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}
