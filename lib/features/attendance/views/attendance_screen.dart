import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/attendance_controller.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AttendanceController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            const _AttendanceHeader(),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),

                    // ── Stat Cards Row ──
                    const _StatCardsRow(),
                    const SizedBox(height: 24),

                    // ── Date Selection Strip ──
                    _DateSelectionStrip(controller: controller),
                    const SizedBox(height: 24),

                    // ── Tabs ──
                    _AttendanceTabs(controller: controller),
                    const SizedBox(height: 20),

                    // ── Search and Sort ──
                    const _SearchSortRow(),
                    const SizedBox(height: 16),

                    // ── Employee List ──
                    const _EmployeeList(),

                    const SizedBox(height: 20),
                    const Center(
                      child: AppText(
                        'Showing 1 to 7 of 128 employees',
                        fontSize: 11,
                        color: AppColors.textColorHint,
                      ),
                    ),
                    const SizedBox(height: 100), // Space for floating bottom nav
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── HEADER ──────────────────────────────────────────────────────────────────
class _AttendanceHeader extends StatelessWidget {
  const _AttendanceHeader();

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
          const _HeaderIcon(icon: Iconsax.calendar_1),
        ],
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  final IconData icon;
  const _HeaderIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Icon(icon, size: 20, color: AppColors.textColorPrimary),
    );
  }
}

// ── STAT CARDS ROW ────────────────────────────────────────────────────────────
class _StatCardsRow extends StatelessWidget {
  const _StatCardsRow();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: const [
          _StatCard(
            icon: Iconsax.people,
            value: '128',
            label: 'Total Employees',
            subLabel: 'All Departments',
            color: Color(0xFF0EA5E9),
          ),
          SizedBox(width: 12),
          _StatCard(
            icon: Iconsax.tick_circle,
            value: '96',
            label: 'Present',
            subLabel: '75.00%',
            color: Color(0xFF10B981),
          ),
          SizedBox(width: 12),
          _StatCard(
            icon: Iconsax.close_circle,
            value: '24',
            label: 'Absent',
            subLabel: '18.75%',
            color: Color(0xFFEF4444),
          ),
          SizedBox(width: 12),
          _StatCard(
            icon: Iconsax.clock,
            value: '8',
            label: 'On Leave',
            subLabel: '6.25%',
            color: Color(0xFFF59E0B),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final String subLabel;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.subLabel,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 12),
          AppText(value, fontSize: 18, fontWeight: FontWeight.w800),
          AppText(label, fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textColorPrimary),
          const SizedBox(height: 2),
          AppText(subLabel, fontSize: 9, color: AppColors.textColorSecondary),
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
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(Icons.chevron_left_rounded, color: AppColors.textColorSecondary),
            Row(
              children: [
                const Icon(Iconsax.calendar_1, size: 16, color: AppColors.textColorPrimary),
                const SizedBox(width: 8),
                const AppText('20 May 2025, Tue', fontWeight: FontWeight.w700),
              ],
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textColorSecondary),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const AppText('Today', color: AppColors.primaryColor, fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: List.generate(7, (index) {
              final day = 16 + index;
              final names = ['Fri', 'Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu'];
              final counts = ['102', '86', '–', '110', '128', '–', '–'];
              final isSelected = day == 20;

              return Container(
                margin: const EdgeInsets.only(right: 12),
                width: 55,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryColor : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isSelected ? AppColors.primaryColor : AppColors.slate200),
                ),
                child: Column(
                  children: [
                    AppText(day.toString(), color: isSelected ? Colors.white : AppColors.textColorPrimary, fontSize: 13, fontWeight: FontWeight.w800),
                    AppText(names[index], color: isSelected ? Colors.white70 : AppColors.textColorSecondary, fontSize: 10),
                    const SizedBox(height: 4),
                    AppText(counts[index], color: isSelected ? Colors.white : AppColors.textColorSecondary, fontSize: 10, fontWeight: FontWeight.w600),
                  ],
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 12),
        const Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.chevron_left_rounded, size: 14, color: AppColors.slate300),
              SizedBox(width: 4),
              AppText('Swipe to view more days', fontSize: 10, color: AppColors.textColorHint),
              SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded, size: 14, color: AppColors.slate300),
            ],
          ),
        ),
      ],
    );
  }
}

// ── ATTENDANCE TABS ──────────────────────────────────────────────────────────
class _AttendanceTabs extends StatelessWidget {
  final AttendanceController controller;
  const _AttendanceTabs({required this.controller});

  @override
  Widget build(BuildContext context) {
    final tabs = ['All (128)', 'Present (96)', 'Absent (24)', 'On Leave (8)'];
    return Obx(
      () => Column(
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
                      width: isSelected ? 80 : 0,
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
      ),
    );
  }
}

// ── SEARCH AND SORT ───────────────────────────────────────────────────────────
class _SearchSortRow extends StatelessWidget {
  const _SearchSortRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
             height: 44,
            // padding: const EdgeInsets.symmetric(horizontal: 16),
            // decoration: BoxDecoration(
            //   color: const Color(0xFFF1F5F9),
            //   borderRadius: BorderRadius.circular(12),
            // ),
            child: Row(
              children: const [
                // Icon(Iconsax.search_normal_1, size: 18, color: AppColors.textColorHint),
                // SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search employee...',
                      hintStyle: TextStyle(fontSize: 13, color: AppColors.textColorHint),
                      border: InputBorder.none,
                      prefixIcon:  Icon(Iconsax.search_normal_1, size: 18, color: AppColors.textColorHint),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.slate200),
          ),
          child: Row(
            children: const [
              Icon(Iconsax.sort, size: 18, color: AppColors.textColorPrimary),
              SizedBox(width: 8),
              AppText('Sort', fontSize: 13, fontWeight: FontWeight.w600),
            ],
          ),
        ),
      ],
    );
  }
}

// ── EMPLOYEE LIST ─────────────────────────────────────────────────────────────
class _EmployeeList extends StatelessWidget {
  const _EmployeeList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _EmployeeCard(
          name: 'Rohit Sharma',
          role: 'UI/UX Designer',
          img: 'https://i.pravatar.cc/150?u=rohit',
          status: 'Present',
          statusColor: Color(0xFF10B981),
          checkIn: '09:02 AM',
          checkOut: '06:05 PM',
        ),
        _EmployeeCard(
          name: 'Anjali Mehta',
          role: 'HR Executive',
          img: 'https://i.pravatar.cc/150?u=anjali',
          status: 'Present',
          statusColor: Color(0xFF10B981),
          checkIn: '09:10 AM',
          checkOut: '06:00 PM',
        ),
        _EmployeeCard(
          name: 'Vikram Singh',
          role: 'Sales Manager',
          img: 'https://i.pravatar.cc/150?u=vikram',
          status: 'Present',
          statusColor: Color(0xFF10B981),
          checkIn: '09:00 AM',
          checkOut: '06:15 PM',
        ),
        _EmployeeCard(
          name: 'Neha Gupta',
          role: 'Marketing Executive',
          img: 'https://i.pravatar.cc/150?u=neha',
          status: 'On Leave',
          statusColor: Color(0xFFF59E0B),
          leaveType: 'Casual Leave',
          dayType: 'Full Day',
        ),
        _EmployeeCard(
          name: 'Arjun Patel',
          role: 'Software Developer',
          img: 'https://i.pravatar.cc/150?u=arjun',
          status: 'Absent',
          statusColor: Color(0xFFEF4444),
        ),
        _EmployeeCard(
          name: 'Priya Verma',
          role: 'Operations Executive',
          img: 'https://i.pravatar.cc/150?u=priya',
          status: 'Present',
          statusColor: Color(0xFF10B981),
          checkIn: '08:55 AM',
          checkOut: '06:10 PM',
        ),
        _EmployeeCard(
          name: 'Karan Joshi',
          role: 'QA Engineer',
          img: 'https://i.pravatar.cc/150?u=karan',
          status: 'Present',
          statusColor: Color(0xFF10B981),
          checkIn: '09:05 AM',
          checkOut: '06:00 PM',
        ),
      ],
    );
  }
}

class _EmployeeCard extends StatelessWidget {
  final String name;
  final String role;
  final String img;
  final String status;
  final Color statusColor;
  final String? checkIn;
  final String? checkOut;
  final String? leaveType;
  final String? dayType;

  const _EmployeeCard({
    required this.name,
    required this.role,
    required this.img,
    required this.status,
    required this.statusColor,
    this.checkIn,
    this.checkOut,
    this.leaveType,
    this.dayType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(radius: 20, backgroundImage: NetworkImage(img)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(name, fontSize: 13, fontWeight: FontWeight.w700),
                    AppText(role, fontSize: 10, color: AppColors.textColorSecondary),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: AppText(status, fontSize: 10, color: statusColor, fontWeight: FontWeight.w800),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.more_vert_rounded, size: 18, color: AppColors.textColorHint),
            ],
          ),
          const SizedBox(height: 16),
          if (status == 'Absent')
             Row(
               children: [
                 Expanded(child: _DetailItem(label: 'Check-in', value: '–', valueColor: AppColors.textColorHint)),
                 Expanded(child: _DetailItem(label: 'Check-out', value: '–', valueColor: AppColors.textColorHint)),
               ],
             )
          else if (status == 'On Leave')
            Row(
              children: [
                Expanded(child: _DetailItem(label: 'Leave Type', value: leaveType ?? '')),
                Expanded(child: _DetailItem(label: 'Day', value: dayType ?? '')),
              ],
            )
          else
            Row(
              children: [
                Expanded(child: _DetailItem(label: 'Check-in', value: checkIn ?? '', valueColor: const Color(0xFF10B981))),
                Expanded(child: _DetailItem(label: 'Check-out', value: checkOut ?? '', valueColor: const Color(0xFF10B981))),
              ],
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
        AppText(value, fontSize: 12, fontWeight: FontWeight.w700, color: valueColor ?? AppColors.textColorPrimary),
      ],
    );
  }
}
