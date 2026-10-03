import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/team_leave_calendar_controller.dart';
import '../models/admin_leave_model.dart';
import 'leave_approval_screen.dart';

class TeamLeaveCalendarScreen extends StatelessWidget {
  const TeamLeaveCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<TeamLeaveCalendarController>()
        ? Get.find<TeamLeaveCalendarController>()
        : Get.put(TeamLeaveCalendarController());

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textColorPrimary, size: 20),
                onPressed: () => Get.back(),
              )
            : null,
        title: const AppText(
          'Leave Calendar',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textColorPrimary,
        ),
        centerTitle: false,
       /* actions: [
          // Jump to Today button
          IconButton(
            tooltip: 'Go to Today',
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Iconsax.calendar_tick, color: AppColors.primaryColor, size: 18),
            ),
            onPressed: () {
              final now = DateTime.now();
              controller.changeMonth(now.year, now.month);
              controller.selectDate(now);
            },
          ),
          // Refresh Button
          IconButton(
            tooltip: 'Refresh Calendar',
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textColorSecondary, size: 22),
            onPressed: () => controller.fetchLeavesForMonth(isRefresh: true),
          ),
          const SizedBox(width: 6),
        ],*/
      ),
      body: Obx(() {
        return RefreshIndicator(
          onRefresh: () => controller.fetchLeavesForMonth(isRefresh: true),
          color: AppColors.primaryColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Calendar Navigation & Status Filter Card
                _buildTopNavigationCard(context, controller),

                const SizedBox(height: 12),

                // Calendar Grid Container
                _buildCalendarCard(context, controller),

                const SizedBox(height: 16),

                // Selected Date Leaves Header & List
                _buildSelectedDateSection(context, controller),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ── Top Navigation & Filter Bar ─────────────────────────────────
  Widget _buildTopNavigationCard(BuildContext context, TeamLeaveCalendarController controller) {
    final curMonth = controller.selectedMonth.value;
    final formattedMonthYear = DateFormat('MMMM yyyy').format(curMonth);

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          // Month navigation bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textColorPrimary, size: 18),
                onPressed: controller.isLoading.value ? null : controller.previousMonth,
              ),
              GestureDetector(
                onTap: () => _showMonthPickerBottomSheet(context, controller),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.slate100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.slate200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Iconsax.calendar_1, size: 18, color: AppColors.primaryColor),
                      const SizedBox(width: 8),
                      AppText(
                        formattedMonthYear,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColorPrimary,
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.keyboard_arrow_down, size: 18, color: AppColors.textColorSecondary),
                    ],
                  ),
                ),
              ),
              Builder(
                builder: (context) {
                  final now = DateTime.now();
                  final isCurrentMonth = curMonth.year == now.year && curMonth.month == now.month;
                  final isForwardDisabled = controller.isLoading.value || isCurrentMonth;
                  return IconButton(
                    icon: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: isForwardDisabled ? AppColors.slate300 : AppColors.textColorPrimary,
                      size: 18,
                    ),
                    onPressed: isForwardDisabled ? null : controller.nextMonth,
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Status Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildStatusFilterChip(controller, 'all', 'All', controller.counts.value?.all),
                const SizedBox(width: 8),
                _buildStatusFilterChip(controller, 'approved', 'Approved', controller.counts.value?.approved, Colors.green),
                const SizedBox(width: 8),
                _buildStatusFilterChip(controller, 'pending', 'Pending', controller.counts.value?.pending, Colors.orange),
                const SizedBox(width: 8),
                _buildStatusFilterChip(controller, 'rejected', 'Rejected', controller.counts.value?.rejected, Colors.red),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilterChip(
    TeamLeaveCalendarController controller,
    String key,
    String label,
    int? count, [
    Color? accentColor,
  ]) {
    final isSelected = controller.selectedStatusFilter.value == key;
    final color = accentColor ?? AppColors.primaryColor;

    return InkWell(
      onTap: () => controller.changeStatusFilter(key),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : AppColors.slate100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : AppColors.slate200,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (accentColor != null) ...[
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
            ],
            AppText(
              label,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? color : AppColors.textColorPrimary,
            ),
            if (count != null && count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected ? color : AppColors.slate300,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : AppColors.textColorPrimary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Calendar Card & Grid ────────────────────────────────────────
  Widget _buildCalendarCard(BuildContext context, TeamLeaveCalendarController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Weekday Header
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            child: Row(
              children: [
                _buildWeekdayHeader('Sun', isWeekend: true),
                _buildWeekdayHeader('Mon'),
                _buildWeekdayHeader('Tue'),
                _buildWeekdayHeader('Wed'),
                _buildWeekdayHeader('Thu'),
                _buildWeekdayHeader('Fri'),
                _buildWeekdayHeader('Sat'),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.slate100),

          // Calendar Grid
          if (controller.isLoading.value && !controller.isRefreshing.value)
            const SizedBox(
              height: 260,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primaryColor, strokeWidth: 2.5),
              ),
            )
          else
            _buildCalendarDaysGrid(context, controller),

          // Calendar Legend
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem(Colors.green, 'Approved'),
                _buildLegendItem(Colors.orange, 'Pending'),
                _buildLegendItem(Colors.red, 'Rejected'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeader(String label, {bool isWeekend = false}) {
    return Expanded(
      child: Center(
        child: AppText(
          label,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isWeekend ? Colors.red.shade400 : AppColors.textColorSecondary,
        ),
      ),
    );
  }

  Widget _buildCalendarDaysGrid(BuildContext context, TeamLeaveCalendarController controller) {
    final curMonth = controller.selectedMonth.value;
    final int daysInMonth = DateTime(curMonth.year, curMonth.month + 1, 0).day;
    final int firstWeekday = DateTime(curMonth.year, curMonth.month, 1).weekday; // 1 = Mon, 7 = Sun
    final int firstDayOffset = firstWeekday == 7 ? 0 : firstWeekday;

    final int totalCells = (daysInMonth + firstDayOffset) > 35 ? 42 : 35;
    final leavesMap = controller.leavesByDayInCurrentMonth;
    final now = DateTime.now();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: totalCells,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 0.88,
      ),
      itemBuilder: (context, index) {
        final dayNumber = index - firstDayOffset + 1;
        final bool isCurrentMonth = dayNumber > 0 && dayNumber <= daysInMonth;

        if (!isCurrentMonth) {
          int displayPrevOrNext = 0;
          if (dayNumber <= 0) {
            final prevDays = DateTime(curMonth.year, curMonth.month, 0).day;
            displayPrevOrNext = prevDays + dayNumber;
          } else {
            displayPrevOrNext = dayNumber - daysInMonth;
          }
          return Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.slate100, width: 0.5),
              color: AppColors.slate50.withValues(alpha: 0.5),
            ),
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              '$displayPrevOrNext',
              style: const TextStyle(fontSize: 12, color: AppColors.slate300),
            ),
          );
        }

        final cellDate = DateTime(curMonth.year, curMonth.month, dayNumber);
        final bool isToday = cellDate.year == now.year && cellDate.month == now.month && cellDate.day == now.day;
        final bool isSelected = cellDate.year == controller.selectedDate.value.year &&
            cellDate.month == controller.selectedDate.value.month &&
            cellDate.day == controller.selectedDate.value.day;

        final isSunday = index % 7 == 0;
        final dayLeaves = leavesMap[dayNumber] ?? [];

        return InkWell(
          onTap: () => controller.selectDate(cellDate),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? AppColors.primaryColor : AppColors.slate100,
                width: isSelected ? 1.5 : 0.5,
              ),
              color: isSelected
                  ? AppColors.primaryLight.withValues(alpha: 0.6)
                  : (isToday ? AppColors.slate50 : Colors.white),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Day number badge
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: isToday
                        ? AppColors.primaryColor
                        : (isSelected ? AppColors.primaryColor.withValues(alpha: 0.2) : Colors.transparent),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$dayNumber',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: (isToday || isSelected) ? FontWeight.bold : FontWeight.w500,
                      color: isToday
                          ? Colors.white
                          : (isSelected
                              ? AppColors.primaryColor
                              : (isSunday ? Colors.red.shade400 : AppColors.textColorPrimary)),
                    ),
                  ),
                ),
                const SizedBox(height: 2),

                // Employee Leave Indicators on this day
                if (dayLeaves.isNotEmpty)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // First employee badge
                        _buildDayLeaveTag(dayLeaves[0], controller),
                        // Second employee badge or "+X more"
                        if (dayLeaves.length == 2)
                          _buildDayLeaveTag(dayLeaves[1], controller)
                        else if (dayLeaves.length > 2)
                          Container(
                            margin: const EdgeInsets.only(top: 1),
                            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.slate200,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '+${dayLeaves.length - 1} more',
                              style: const TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColorSecondary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDayLeaveTag(AdminLeaveItemModel leave, TeamLeaveCalendarController controller) {
    final color = controller.getStatusColor(leave.status);
    final empFirstName = leave.employee.name.split(' ').first;

    return Container(
      margin: const EdgeInsets.only(top: 1.5),
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 4.5,
            height: 4.5,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 2),
          Flexible(
            child: Text(
              empFirstName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        AppText(label, fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textColorSecondary),
      ],
    );
  }

  // ── Selected Date Leaves Section (Below Calendar) ───────────────
  Widget _buildSelectedDateSection(BuildContext context, TeamLeaveCalendarController controller) {
    final selectedDate = controller.selectedDate.value;
    final formattedDate = DateFormat('EEEE, dd MMMM yyyy').format(selectedDate);
    final selectedLeaves = controller.leavesForSelectedDate;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with date & count
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppText(
                    'Employees on Leave',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColorPrimary,
                  ),
                  const SizedBox(height: 2),
                  AppText(
                    formattedDate,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textColorSecondary,
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: selectedLeaves.isEmpty ? AppColors.slate100 : AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selectedLeaves.isEmpty ? AppColors.slate200 : AppColors.primaryColor.withValues(alpha: 0.3),
                  ),
                ),
                child: AppText(
                  selectedLeaves.isEmpty
                      ? 'No Leaves'
                      : '${selectedLeaves.length} ${selectedLeaves.length == 1 ? 'Employee' : 'Employees'}',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: selectedLeaves.isEmpty ? AppColors.slate500 : AppColors.primaryColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Error Message
          if (controller.errorMessage.value.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppText(
                      controller.errorMessage.value,
                      fontSize: 13,
                      color: Colors.red.shade700,
                    ),
                  ),
                  TextButton(
                    onPressed: () => controller.fetchLeavesForMonth(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          // Empty State
          else if (selectedLeaves.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.slate200),
              ),
              child: Column(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Iconsax.user_tick, color: Colors.green, size: 26),
                  ),
                  const SizedBox(height: 12),
                  const AppText(
                    'No Employees Off Today',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColorPrimary,
                  ),
                  const SizedBox(height: 4),
                  AppText(
                    'All employees are scheduled and available on ${DateFormat('dd MMM').format(selectedDate)}.',
                    fontSize: 12,
                    color: AppColors.textColorSecondary,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          // List of Leaves on Selected Date
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: selectedLeaves.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _buildEmployeeLeaveCard(context, selectedLeaves[index], controller);
              },
            ),
        ],
      ),
    );
  }

  // ── Employee Detailed Leave Card ────────────────────────────────
  Widget _buildEmployeeLeaveCard(
    BuildContext context,
    AdminLeaveItemModel leave,
    TeamLeaveCalendarController controller,
  ) {
    final statusColor = controller.getStatusColor(leave.status);
    final avatarUrl = leave.employee.fullAvatarUrl;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header: Avatar, Name, Designation, Status Badge
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar with fallback
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 48,
                    height: 48,
                    color: AppColors.primaryLight,
                    child: avatarUrl != null && avatarUrl.isNotEmpty
                        ? Image.network(
                            avatarUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => _buildAvatarFallback(leave.employee.name),
                          )
                        : _buildAvatarFallback(leave.employee.name),
                  ),
                ),
                const SizedBox(width: 12),

                // Name, Emp ID, Designation
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: AppText(
                              leave.employee.name,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColorPrimary,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (leave.employee.employeeId.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: AppColors.slate100,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.slate200),
                              ),
                              child: Text(
                                leave.employee.employeeId,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.slate600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Iconsax.briefcase, size: 13, color: AppColors.slate400),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${leave.employee.designation} • ${leave.employee.department}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textColorSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        leave.status,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1, color: AppColors.slate100),

          // Details Row: Leave Type, Duration, Dates
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                // Leave Type chip
                _buildInfoPill(
                  Iconsax.calendar_tick,
                  leave.leaveType,
                  color: AppColors.primaryColor,
                ),
                // Duration & Session chip
                _buildInfoPill(
                  Iconsax.clock,
                  '${leave.duration} (${leave.sessionType})',
                  color: AppColors.slate700,
                ),
                // Date span chip
                _buildInfoPill(
                  Iconsax.calendar_1,
                  leave.formattedDates,
                  color: AppColors.slate700,
                ),
              ],
            ),
          ),

          // Leave Reason Box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.slate50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.slate200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Iconsax.note_text, size: 14, color: AppColors.primaryColor),
                      SizedBox(width: 6),
                      Text(
                        'Reason for Leave:',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.slate600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    leave.reason.isNotEmpty ? leave.reason : 'No reason provided by employee.',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textColorPrimary,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Additional Contact & Address Details (if available)
          if ((leave.contactDuringLeave != null && leave.contactDuringLeave!.isNotEmpty) ||
              (leave.addressDuringLeave != null && leave.addressDuringLeave!.isNotEmpty))
            Padding(
              padding: const EdgeInsets.only(left: 14, right: 14, top: 8),
              child: Column(
                children: [
                  if (leave.contactDuringLeave != null && leave.contactDuringLeave!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          const Icon(Iconsax.call, size: 13, color: AppColors.slate400),
                          const SizedBox(width: 6),
                          Text(
                            'Contact during leave: ${leave.contactDuringLeave}',
                            style: const TextStyle(fontSize: 11.5, color: AppColors.textColorSecondary),
                          ),
                        ],
                      ),
                    ),
                  if (leave.addressDuringLeave != null && leave.addressDuringLeave!.isNotEmpty)
                    Row(
                      children: [
                        const Icon(Iconsax.location, size: 13, color: AppColors.slate400),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Address: ${leave.addressDuringLeave}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11.5, color: AppColors.textColorSecondary),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

          const SizedBox(height: 10),

          // Footer Action: View Full Leave Details / Review
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () {
                    Get.to(() => LeaveApprovalScreen(leaveId: leave.id));
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.2)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'View & Review Request',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.primaryColor),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildAvatarFallback(String name) {
    String initials = 'EM';
    final parts = name.trim().split(' ');
    if (parts.isNotEmpty && parts[0].isNotEmpty) {
      initials = parts[0][0];
      if (parts.length > 1 && parts[1].isNotEmpty) {
        initials += parts[1][0];
      }
    }
    return Center(
      child: Text(
        initials.toUpperCase(),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryColor,
        ),
      ),
    );
  }

  Widget _buildInfoPill(IconData icon, String text, {required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.slate100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ── Month Picker Bottom Sheet ───────────────────────────────────
  void _showMonthPickerBottomSheet(BuildContext context, TeamLeaveCalendarController controller) {
    final List<String> months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    int tempYear = controller.selectedMonth.value.year;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.only(top: 12, bottom: 24),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.65,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag Handle
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.slate300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Header with Year switch
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios_rounded, size: 16),
                              onPressed: () {
                                setSheetState(() {
                                  tempYear--;
                                });
                              },
                            ),
                            AppText(
                              '$tempYear',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColorPrimary,
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 16,
                                color: tempYear >= DateTime.now().year
                                    ? AppColors.slate300
                                    : AppColors.textColorPrimary,
                              ),
                              onPressed: tempYear >= DateTime.now().year
                                  ? null
                                  : () {
                                      setSheetState(() {
                                        tempYear++;
                                      });
                                    },
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: AppColors.textColorSecondary),
                          onPressed: () => Get.back(),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: AppColors.slate200),

                  // Grid of 12 Months
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 2.2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: 12,
                      itemBuilder: (context, index) {
                        final monthNum = index + 1;
                        final now = DateTime.now();
                        final isFutureMonth = tempYear > now.year ||
                            (tempYear == now.year && monthNum > now.month);
                        final isSelected = controller.selectedMonth.value.year == tempYear &&
                            controller.selectedMonth.value.month == monthNum;

                        return InkWell(
                          onTap: isFutureMonth
                              ? null
                              : () {
                                  controller.changeMonth(tempYear, monthNum);
                                  Get.back();
                                },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isFutureMonth
                                  ? AppColors.slate50
                                  : (isSelected ? AppColors.primaryColor : AppColors.slate100),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isFutureMonth
                                    ? AppColors.slate200.withValues(alpha: 0.5)
                                    : (isSelected ? AppColors.primaryColor : AppColors.slate200),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              months[index],
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isFutureMonth
                                    ? AppColors.slate300
                                    : (isSelected ? Colors.white : AppColors.textColorPrimary),
                              ),
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
