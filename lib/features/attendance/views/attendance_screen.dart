import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/attendance_controller.dart';
import '../models/admin_attendance_model.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<AttendanceController>()
        ? Get.find<AttendanceController>()
        : Get.put(AttendanceController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.fetchAttendance,
          child: Column(
            children: [
              // ── Header (with calendar picker button) ──
              _AttendanceHeader(controller: controller),

              Expanded(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),

                      // 1. ── Date Selection Strip (Forward/Backward + Today + Strip) ──
                      _DateSelectionStrip(controller: controller),
                      const SizedBox(height: 16),

                      // 2. ── Compact & Manageable Summary Section (BELOW Date Filter) ──
                      _CompactSummarySection(controller: controller),
                      const SizedBox(height: 20),

                      // 3. ── Tabs (All, Present, Absent, On Leave with live count) ──
                      _AttendanceTabs(controller: controller),
                      const SizedBox(height: 16),

                      // 4. ── Search Bar (Sort removed as requested) ──
                      _SearchRow(controller: controller),
                      const SizedBox(height: 16),

                      // 5. ── Employee Attendance List (Real API data, 3rd icon removed) ──
                      _EmployeeList(controller: controller),

                      const SizedBox(height: 100), // Space for floating bottom nav
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── HEADER ──────────────────────────────────────────────────────────────────
class _AttendanceHeader extends StatelessWidget {
  final AttendanceController controller;
  const _AttendanceHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText('Attendance', fontSize: 20, fontWeight: FontWeight.w800),
                AppText('Track and manage employee attendance', fontSize: 12, color: AppColors.textColorSecondary),
              ],
            ),
          ),
          InkWell(
            onTap: () => controller.selectDateFromPicker(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.slate200),
              ),
              child: const Icon(Iconsax.calendar_1, size: 20, color: AppColors.textColorPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

// ── DATE SELECTION STRIP ──────────────────────────────────────────────────────
class _DateSelectionStrip extends StatelessWidget {
  final AttendanceController controller;
  const _DateSelectionStrip({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedDate = controller.selectedDate.value;
      final selectedDateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
      final dateCards = controller.attendanceData.value?.dateCards ?? [];
      final now = DateTime.now();
      final isTodayOrFuture = !selectedDate.isBefore(DateTime(now.year, now.month, now.day));

      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Backward Button
              InkWell(
                onTap: controller.previousDay,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.slate200),
                  ),
                  child: const Icon(Icons.chevron_left_rounded, color: AppColors.textColorSecondary, size: 20),
                ),
              ),

              // Date Title (Clickable to pick date)
              InkWell(
                onTap: () => controller.selectDateFromPicker(context),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Iconsax.calendar_1, size: 16, color: AppColors.primaryColor),
                      const SizedBox(width: 8),
                      AppText(
                        DateFormat('dd MMM yyyy, EEE').format(selectedDate),
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ],
                  ),
                ),
              ),

              // Forward Button (Disabled if already today or future)
              InkWell(
                onTap: isTodayOrFuture ? null : controller.nextDay,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isTodayOrFuture ? AppColors.slate100 : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.slate200),
                  ),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: isTodayOrFuture ? AppColors.slate300 : AppColors.textColorSecondary,
                    size: 20,
                  ),
                ),
              ),

              // Today Button
              InkWell(
                onTap: controller.selectToday,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const AppText('Today', color: AppColors.primaryColor, fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Horizontal Date Cards
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: dateCards.isNotEmpty
                  ? dateCards.map((card) {
                      final isSelected = card.date == selectedDateStr;
                      DateTime? cardParsedDate;
                      try {
                        cardParsedDate = DateTime.parse(card.date);
                      } catch (_) {}
                      final isCardFuture = cardParsedDate != null &&
                          DateTime(cardParsedDate.year, cardParsedDate.month, cardParsedDate.day)
                              .isAfter(DateTime(now.year, now.month, now.day));

                      String dayNum = '';
                      if (cardParsedDate != null) {
                        dayNum = DateFormat('dd').format(cardParsedDate);
                      } else {
                        dayNum = card.date.split('-').last;
                      }

                      return GestureDetector(
                        onTap: isCardFuture
                            ? null
                            : () {
                                if (cardParsedDate != null) {
                                  controller.changeDate(cardParsedDate);
                                }
                              },
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          width: 58,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryColor
                                : (isCardFuture ? AppColors.slate50 : Colors.white),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryColor
                                  : (isCardFuture ? AppColors.slate100 : AppColors.slate200),
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.primaryColor.withValues(alpha: 0.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    )
                                  ]
                                : null,
                          ),
                          child: Column(
                            children: [
                              AppText(
                                dayNum,
                                color: isSelected ? Colors.white : AppColors.textColorPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                              const SizedBox(height: 2),
                              AppText(
                                card.day,
                                color: isSelected ? Colors.white70 : AppColors.textColorSecondary,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white.withValues(alpha: 0.2)
                                      : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: AppText(
                                  '${card.attendanceCount}',
                                  color: isSelected ? Colors.white : AppColors.textColorSecondary,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList()
                  : List.generate(7, (index) {
                      final dayDate = selectedDate.subtract(Duration(days: 3 - index));
                      final isSelected = index == 3;
                      final dayNum = DateFormat('dd').format(dayDate);
                      final dayName = DateFormat('EEE').format(dayDate);

                      return GestureDetector(
                        onTap: () => controller.changeDate(dayDate),
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          width: 58,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primaryColor : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? AppColors.primaryColor : AppColors.slate200,
                            ),
                          ),
                          child: Column(
                            children: [
                              AppText(
                                dayNum,
                                color: isSelected ? Colors.white : AppColors.textColorPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                              const SizedBox(height: 2),
                              AppText(
                                dayName,
                                color: isSelected ? Colors.white70 : AppColors.textColorSecondary,
                                fontSize: 10,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
            ),
          ),
        ],
      );
    });
  }
}

// ── COMPACT & MANAGEABLE SUMMARY SECTION (BELOW DATE FILTER) ──────────────────
class _CompactSummarySection extends StatelessWidget {
  final AttendanceController controller;
  const _CompactSummarySection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final summary = controller.attendanceData.value?.summary;
      final total = summary?.totalEmployees ?? 0;
      final present = summary?.present ?? 0;
      final absent = summary?.absent ?? 0;
      final onLeave = summary?.onLeave ?? 0;
      final presentPct = summary?.presentPercentage ?? 0;
      final absentPct = summary?.absentPercentage ?? 0;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.slate200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            _SummaryStatItem(
              label: 'Total',
              value: '$total',
              subLabel: null,
              color: AppColors.primaryColor,
              icon: Iconsax.people,
            ),
            _vDivider(),
            _SummaryStatItem(
              label: 'Present',
              value: '$present',
              subLabel: '$presentPct%',
              color: const Color(0xFF10B981),
              icon: Iconsax.tick_circle,
            ),
            _vDivider(),
            _SummaryStatItem(
              label: 'Absent',
              value: '$absent',
              subLabel: '$absentPct%',
              color: const Color(0xFFEF4444),
              icon: Iconsax.close_circle,
            ),
            _vDivider(),
            _SummaryStatItem(
              label: 'On Leave',
              value: '$onLeave',
              subLabel: null,
              color: const Color(0xFFF59E0B),
              icon: Iconsax.clock,
            ),
          ],
        ),
      );
    });
  }

  Widget _vDivider() {
    return Container(
      height: 30,
      width: 1,
      color: AppColors.slate200,
      margin: const EdgeInsets.symmetric(horizontal: 2),
    );
  }
}

class _SummaryStatItem extends StatelessWidget {
  final String label;
  final String value;
  final String? subLabel;
  final Color color;
  final IconData icon;

  const _SummaryStatItem({
    required this.label,
    required this.value,
    this.subLabel,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColorSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              if (subLabel != null) ...[
                const SizedBox(width: 2),
                Text(
                  subLabel!,
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    color: color.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ── ATTENDANCE TABS ──────────────────────────────────────────────────────────
class _AttendanceTabs extends StatelessWidget {
  final AttendanceController controller;
  const _AttendanceTabs({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final summary = controller.attendanceData.value?.summary;
      final total = summary?.totalEmployees ?? 0;
      final present = summary?.present ?? 0;
      final absent = summary?.absent ?? 0;
      final onLeave = summary?.onLeave ?? 0;

      final tabs = [
        'All ($total)',
        'Present ($present)',
        'Absent ($absent)',
        'On Leave ($onLeave)',
      ];

      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(tabs.length, (index) {
              final isSelected = controller.selectedTab.value == index;
              return GestureDetector(
                onTap: () => controller.changeTab(index),
                child: Column(
                  children: [
                    AppText(
                      tabs[index],
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? AppColors.primaryColor : AppColors.textColorSecondary,
                    ),
                    const SizedBox(height: 8),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 2.5,
                      width: isSelected ? 70 : 0,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          const Divider(height: 1, color: AppColors.slate200),
        ],
      );
    });
  }
}

// ── SEARCH BAR (NO SORT BUTTON) ──────────────────────────────────────────────
class _SearchRow extends StatelessWidget {
  final AttendanceController controller;
  const _SearchRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.slate200),
      ),
      child: TextField(
        controller: controller.searchController,
        onChanged: controller.onSearchChanged,
        style: const TextStyle(fontSize: 13, color: AppColors.textColorPrimary),
        decoration: InputDecoration(
          hintText: 'Search employee by name...',
          hintStyle: const TextStyle(fontSize: 13, color: AppColors.textColorHint),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          prefixIcon: const Icon(Iconsax.search_normal_1, size: 18, color: AppColors.textColorHint),
          suffixIcon: Obx(() {
            if (controller.searchQuery.value.isNotEmpty) {
              return IconButton(
                icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textColorHint),
                onPressed: controller.clearSearch,
              );
            }
            return const SizedBox.shrink();
          }),
        ),
      ),
    );
  }
}

// ── EMPLOYEE LIST ─────────────────────────────────────────────────────────────
class _EmployeeList extends StatelessWidget {
  final AttendanceController controller;
  const _EmployeeList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.attendanceData.value == null) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      if (controller.errorMessage.value.isNotEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 30),
          child: Center(
            child: Column(
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.red, size: 40),
                const SizedBox(height: 10),
                AppText(controller.errorMessage.value, fontSize: 13, color: Colors.red),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: controller.fetchAttendance,
                  child: const AppText('Retry', color: AppColors.primaryColor, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        );
      }

      final employees = controller.attendanceData.value?.employees ?? [];

      if (employees.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.slate200.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Iconsax.user_remove, size: 36, color: AppColors.textColorHint),
                ),
                const SizedBox(height: 12),
                const AppText(
                  'No attendance records found',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textColorPrimary,
                ),
                const SizedBox(height: 4),
                const AppText(
                  'No employee attendance matches this date or filter.',
                  fontSize: 11,
                  color: AppColors.textColorSecondary,
                ),
              ],
            ),
          ),
        );
      }

      final totalEmployees = controller.attendanceData.value?.summary?.totalEmployees ?? employees.length;

      return Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: employees.length,
            itemBuilder: (context, index) {
              return _EmployeeCard(item: employees[index]);
            },
          ),
          const SizedBox(height: 12),
          Center(
            child: AppText(
              'Showing 1 to ${employees.length} of $totalEmployees employees',
              fontSize: 11,
              color: AppColors.textColorHint,
            ),
          ),
        ],
      );
    });
  }
}

// ── EMPLOYEE CARD (THIRD ICON REMOVED) ─────────────────────────────────────────
class _EmployeeCard extends StatelessWidget {
  final AdminAttendanceEmployeeItem item;

  const _EmployeeCard({required this.item});

  String _formatAvatarUrl(String? avatar) {
    if (avatar == null || avatar.isEmpty) return '';
    if (avatar.contains('127.0.0.1:8000') || avatar.contains('localhost:8000')) {
      return avatar
          .replaceFirst('http://127.0.0.1:8000', AppConstants.baseUrl)
          .replaceFirst('http://localhost:8000', AppConstants.baseUrl);
    }
    return avatar;
  }

  @override
  Widget build(BuildContext context) {
    final emp = item.employee;
    final name = emp?.name ?? 'Employee';
    final empId = emp?.employeeId ?? '';
    final designation = emp?.designation ?? '';
    final department = emp?.department ?? '';

    String subtitle = '';
    if (empId.isNotEmpty && designation.isNotEmpty) {
      subtitle = '$empId • $designation';
    } else if (empId.isNotEmpty) {
      subtitle = empId;
    } else if (designation.isNotEmpty) {
      subtitle = designation;
    }
    if (department.isNotEmpty) {
      subtitle = subtitle.isEmpty ? department : '$subtitle ($department)';
    }

    final status = item.status;
    Color statusColor;
    switch (status.toLowerCase()) {
      case 'present':
        statusColor = const Color(0xFF10B981);
        break;
      case 'absent':
        statusColor = const Color(0xFFEF4444);
        break;
      case 'on leave':
      case 'leave':
        statusColor = const Color(0xFFF59E0B);
        break;
      case 'half day':
        statusColor = const Color(0xFF8B5CF6);
        break;
      default:
        statusColor = AppColors.primaryColor;
    }

    final avatarUrl = _formatAvatarUrl(emp?.avatar);
    final hasValidAvatar = avatarUrl.isNotEmpty && Uri.tryParse(avatarUrl)?.isAbsolute == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: statusColor.withValues(alpha: 0.1),
                backgroundImage: hasValidAvatar ? NetworkImage(avatarUrl) : null,
                onBackgroundImageError: hasValidAvatar ? (_, _) {} : null,
                child: !hasValidAvatar
                    ? Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'E',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(name, fontSize: 13, fontWeight: FontWeight.w700),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      AppText(
                        subtitle,
                        fontSize: 11,
                        color: AppColors.textColorSecondary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: AppText(
                  status,
                  fontSize: 10,
                  color: statusColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
              // Third icon (more_vert) removed as requested!
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _DetailItem(
                    label: 'Check-in',
                    value: item.checkIn != null && item.checkIn!.isNotEmpty ? item.checkIn! : '–',
                    valueColor: item.checkIn != null && item.checkIn!.isNotEmpty
                        ? const Color(0xFF10B981)
                        : AppColors.textColorHint,
                  ),
                ),
                Expanded(
                  child: _DetailItem(
                    label: 'Check-out',
                    value: item.checkOut != null && item.checkOut!.isNotEmpty ? item.checkOut! : '–',
                    valueColor: item.checkOut != null && item.checkOut!.isNotEmpty
                        ? AppColors.primaryColor
                        : AppColors.textColorHint,
                  ),
                ),
                Expanded(
                  child: _DetailItem(
                    label: 'Working Hours',
                    value: item.workingHours.isNotEmpty ? item.workingHours : '00h 00m',
                    valueColor: AppColors.textColorPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailItem({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(label, fontSize: 9, color: AppColors.textColorHint),
        const SizedBox(height: 2),
        AppText(
          value,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: valueColor ?? AppColors.textColorPrimary,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
