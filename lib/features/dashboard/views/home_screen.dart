import 'package:attendence_tracking_app/core/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../routes/route_helper.dart';
import '../../leave_management/views/my_leaves_screen.dart';
import '../../leave_management/views/apply_leave_screen.dart';
import '../../leave_management/views/manager_leave_dashboard.dart';
import '../../shift_management/views/shift_management_screen.dart';
import '../../payslip/views/payslip_history_screen.dart';
import '../../attendance/views/attendance_history_screen.dart';
import '../../notification/views/notification_screen.dart';
import '../../notification/controllers/notification_controller.dart';
import '../../../core/controllers/app_controller.dart';
import '../controllers/dashboard_controller.dart';
import 'upcoming_birthdays_screen.dart';
import 'package:intl/intl.dart';
import '../../role_permissions/views/role_list_screen.dart';
import '../../employee/management/views/employee_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();
    final dashboardController = Get.isRegistered<DashboardController>()
        ? Get.find<DashboardController>()
        : Get.put(DashboardController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            if (appController.userRole.value != 'admin') {
              await dashboardController.fetchEmployeeDashboard();
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──
                const _HomeHeader(),
                const SizedBox(height: 24),

              Obx(() {
                final isAdmin = appController.userRole.value == 'admin';

                if (isAdmin) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Today's Summary Card ──
                      const _TodaySummaryCard(),
                      const SizedBox(height: 24),

                      // ── Current Shift Card ──
                      const _CurrentShiftCard(),
                      const SizedBox(height: 24),

                      // ── Quick Actions ──
                      const AppText(
                        'Quick Actions',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      const SizedBox(height: 16),
                      const _QuickActionsGrid(),
                      const SizedBox(height: 24),

                      // ── Recent Activities ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const AppText(
                            'Recent Activities',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const AppText(
                              'View all >',
                              fontSize: 12,
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const _RecentActivitiesList(),
                      const SizedBox(height: 20),
                    ],
                  );
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── EMPLOYEE SCREEN SECTION ──────────────────────────────────
                      const AppText(
                        'Employee Perspective',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textColorPrimary,
                      ),
                      const SizedBox(height: 16),

                      const EmployeeShiftAttendanceCard(),
                      const SizedBox(height: 24),

                      const _TodayBirthdayCard(),
                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const AppText("Today's Summary", fontSize: 15, fontWeight: FontWeight.w700),
                          TextButton(onPressed: () {}, child: const AppText('View all >', fontSize: 12, color: AppColors.primaryColor)),
                        ],
                      ),
                      const _TodayWorkSummary(),
                      const SizedBox(height: 24),

                      const AppText("Quick Actions", fontSize: 15, fontWeight: FontWeight.w700),
                      const SizedBox(height: 16),
                      const _EmployeeQuickActions(),
                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const AppText("Recent Announcements", fontSize: 15, fontWeight: FontWeight.w700),
                          TextButton(onPressed: () {}, child: const AppText('View all >', fontSize: 12, color: AppColors.primaryColor)),
                        ],
                      ),
                      const _AnnouncementsCard(),
                      const SizedBox(height: 30),
                    ],
                  );
                }
              }),
            ],
          ),
        ),
      ),
    ),
  );
}
}

// ── HEADER ──────────────────────────────────────────────────────────────────
class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    final notifController = Get.put(NotificationController());
    final appController = Get.find<AppController>();
    final dashboardController = Get.isRegistered<DashboardController>()
        ? Get.find<DashboardController>()
        : Get.put(DashboardController());

    return Obx(() {
      final isAdmin = appController.userRole.value == 'admin';
      final empData = dashboardController.employeeDashboardData.value;

      final greeting = isAdmin
          ? 'Good Morning, Manager 👋'
          : (empData?.greeting ?? 'Good Morning 👋');

      final subtitle = isAdmin
          ? 'ABC Solutions Pvt. Ltd.'
          : ((empData?.employee?.designation != null && empData?.employee?.department != null)
              ? '${empData!.employee!.designation} • ${empData.employee!.department}'
              : (empData?.employee?.designation ?? empData?.employee?.department ?? 'ABC Solutions Pvt. Ltd.'));

      final avatarUrl = isAdmin
          ? 'https://i.pravatar.cc/150?u=manager'
          : (empData?.employee?.avatar ?? '');

      return Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  greeting,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
                const SizedBox(height: 4),
                AppText(
                  subtitle,
                  fontSize: 13,
                  color: AppColors.textColorSecondary,
                ),
              ],
            ),
          ),
          Obx(() {
            final count = notifController.unreadCount;
            return InkWell(
              onTap: () => Get.to(() => const NotificationScreen()),
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: AppColors.slate200),
                    ),
                    child: const Icon(Iconsax.notification, size: 20),
                  ),
                  if (count > 0)
                    Positioned(
                      right: 2,
                      top: 2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$count',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
          const SizedBox(width: 12),
          InkWell(
            onTap: () {
              if (Get.isRegistered<DashboardController>()) {
                Get.find<DashboardController>().changeIndex(3);
              }
            },
            borderRadius: BorderRadius.circular(22),
            child: () {
              final hasValidAvatar = avatarUrl.isNotEmpty && Uri.tryParse(avatarUrl)?.isAbsolute == true;
              return CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.slate200,
                backgroundImage: hasValidAvatar ? NetworkImage(avatarUrl) : null,
                onBackgroundImageError: hasValidAvatar ? (error, stackTrace) {} : null,
                child: !hasValidAvatar
                    ? const Icon(Icons.person, color: AppColors.textColorSecondary, size: 22)
                    : null,
              );
            }(),
          ),
        ],
      );
    });
  }
}

// ── TODAY SUMMARY CARD ────────────────────────────────────────────────────────
class _TodaySummaryCard extends StatelessWidget {
  const _TodaySummaryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Iconsax.calendar_1, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  const AppText(
                    "Today's Summary",
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
              const AppText(
                '20 May 2025, Tue',
                color: Colors.white70,
                fontSize: 11,
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatItem(icon: Iconsax.people, label: 'Total Employees', value: '128', iconColor: Color(0xFF3B82F6), bgColor: Colors.white),
              _StatItem(icon: Iconsax.tick_circle, label: 'Present', value: '96', subValue: '75.00%', iconColor: Colors.green, bgColor: Colors.white),
              _StatItem(icon: Iconsax.close_circle, label: 'Absent', value: '24', subValue: '18.75%', iconColor: Colors.red, bgColor: Colors.white),
              _StatItem(icon: Iconsax.calendar_remove, label: 'On Leave', value: '8', subValue: '6.25%', iconColor: Colors.orange, bgColor: Colors.white),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? subValue;
  final Color iconColor;
  final Color bgColor;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    this.subValue,
    required this.iconColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(height: 10),
        AppText(value, color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
        const SizedBox(height: 2),
        AppText(label, color: Colors.white.withValues(alpha: 0.8), fontSize: 9, textAlign: TextAlign.center),
        if (subValue != null) ...[
          const SizedBox(height: 2),
          AppText(subValue!, color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600),
        ],
      ],
    );
  }
}

// ── CURRENT SHIFT CARD ────────────────────────────────────────────────────────
class _CurrentShiftCard extends StatelessWidget {
  const _CurrentShiftCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Iconsax.timer, color: AppColors.primaryColor, size: 18),
                  ),
                  const SizedBox(width: 10),
                  const AppText('Current Shift', fontWeight: FontWeight.w700),
                ],
              ),
              const AppText('View all', color: AppColors.primaryColor, fontSize: 12, fontWeight: FontWeight.w600),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const AppText('General Shift', color: AppColors.primaryColor, fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    CircleAvatar(radius: 3, backgroundColor: Colors.green),
                    SizedBox(width: 6),
                    AppText('Ongoing', color: Colors.green, fontSize: 12, fontWeight: FontWeight.w600),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const AppText('09:00 AM – 06:00 PM', fontSize: 20, fontWeight: FontWeight.w800),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ShiftDetail(
                  icon: Iconsax.clock,
                  label: 'Check-in Window',
                  value: '08:30 AM - 10:30 AM',
                ),
              ),
              Expanded(
                child: _ShiftDetail(
                  icon: Iconsax.clock,
                  label: 'Check-out Window',
                  value: '05:30 PM - 07:30 PM',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShiftDetail extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ShiftDetail({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primaryColor),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(label, fontSize: 10, color: AppColors.textColorSecondary),
              AppText(value, fontSize: 10, fontWeight: FontWeight.w700),
            ],
          ),
        ),
      ],
    );
  }
}

// ── QUICK ACTIONS GRID ────────────────────────────────────────────────────────
class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid();

  @override
  Widget build(BuildContext context) {
    final actions = [
      {
        'icon': Iconsax.buildings,
        'label': 'Department',
        'color': const Color(0xFF6366F1), // Indigo
        'onTap': () => Get.toNamed('/department-list'),
      },
      {
        'icon': Iconsax.shield_security,
        'label': 'Role',
        'color': const Color(0xFF8B5CF6), // Purple
        'onTap': () => Get.to(() => const RoleListScreen()),
      },
      {
        'icon': Iconsax.user_tag,
        'label': 'Designation',
        'color': const Color(0xFF3B82F6), // Blue
        'onTap': () => Get.toNamed(RouteHelper.getDesignationListRoute()),
      },
      {
        'icon': Iconsax.clock,
        'label': 'Shift',
        'color': const Color(0xFF10B981), // Emerald
        'onTap': () => Get.to(() => const ShiftManagementScreen()),
      },
      {
        'icon': Iconsax.profile_2user,
        'label': 'Employee',
        'color': const Color(0xFFF59E0B), // Amber
        'onTap': () => Get.to(() => const EmployeeListScreen()),
      },
      {
        'icon': Iconsax.airplane, 
        'label': 'Leave Management', 
        'color': Colors.purple,
        'onTap': () => Get.to(() => const ManagerLeaveDashboard()),
      },
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 16,
      children: actions.map((item) {
        return GestureDetector(
          onTap: item['onTap'] as VoidCallback?,
          child: SizedBox(
            width: (MediaQuery.of(context).size.width - 64) / 3,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (item['color'] as Color).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(item['icon'] as IconData, color: item['color'] as Color, size: 24),
                ),
                const SizedBox(height: 8),
                AppText(item['label'] as String, fontSize: 10, textAlign: TextAlign.center, fontWeight: FontWeight.w600),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── RECENT ACTIVITIES LIST ────────────────────────────────────────────────────
class _RecentActivitiesList extends StatelessWidget {
  const _RecentActivitiesList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _ActivityItem(
          icon: Iconsax.tick_circle,
          iconColor: Colors.green,
          title: 'Rohit Sharma checked in',
          subtitle: 'General Shift • 09:02 AM',
          status: 'Present',
          statusColor: Colors.green,
        ),
        _ActivityItem(
          icon: Iconsax.document_text,
          iconColor: Colors.orange,
          title: 'Anjali Mehta applied for leave',
          subtitle: '21 May 2025 • Casual Leave',
          status: 'Pending',
          statusColor: Colors.orange,
        ),
        _ActivityItem(
          icon: Iconsax.document_download,
          iconColor: AppColors.primaryColor,
          title: 'Monthly attendance report generated',
          subtitle: 'May 2025 • 128 Employees',
          btnText: 'View Report',
        ),
      ],
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String? status;
  final Color? statusColor;
  final String? btnText;

  const _ActivityItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.status,
    this.statusColor,
    this.btnText,
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(title, fontSize: 13, fontWeight: FontWeight.w700),
                const SizedBox(height: 4),
                AppText(subtitle, fontSize: 11, color: AppColors.textColorSecondary),
              ],
            ),
          ),
          if (status != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor!.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: AppText(status!, fontSize: 10, color: statusColor!, fontWeight: FontWeight.w800),
            ),
          if (btnText != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: AppText(btnText!, fontSize: 10, color: AppColors.primaryColor, fontWeight: FontWeight.w800),
            ),
        ],
      ),
    );
  }
}






// ── EMPLOYEE VIEW WIDGETS ───────────────────────────────────────────────────

class _EmployeeShiftCard extends StatelessWidget {
  const _EmployeeShiftCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const AppText('Current Shift', color: Colors.white, fontSize: 13),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                        ),
                        child: const AppText('• Ongoing', color: Colors.green, fontSize: 10, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const AppText('09:00 AM – 06:00 PM', color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                  const SizedBox(height: 8),
                  const AppText('General Shift', color: Colors.white70, fontSize: 12),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  children: [
                    AppText('May', color: AppColors.textColorSecondary, fontSize: 10),
                    AppText('20', color: AppColors.textColorPrimary, fontSize: 20, fontWeight: FontWeight.w800),
                    AppText('Tue', color: AppColors.textColorSecondary, fontSize: 10),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AttendanceActionCard extends StatelessWidget {
  const _AttendanceActionCard();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.slate200),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(child: _ActionStat(label: 'Check-in', time: '08:55 AM', status: 'Completed', statusColor: Colors.green)),
                  Container(height: 40, width: 1, color: AppColors.slate200),
                  const Expanded(child: _ActionStat(label: 'Check-out', time: '--:-- --', status: 'Pending', statusColor: Colors.orange)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppText('Mark Attendance', color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
              SizedBox(width: 12),
              Icon(Iconsax.finger_scan, color: Colors.white, size: 22),
            ],
          ),
        ),
      ],
    );
  }
}



class EmployeeShiftAttendanceCard extends StatelessWidget {
  const EmployeeShiftAttendanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardController = Get.isRegistered<DashboardController>()
        ? Get.find<DashboardController>()
        : Get.put(DashboardController());

    return Obx(() {
      final empData = dashboardController.employeeDashboardData.value;
      final currentShift = empData?.currentShift;
      final attendance = empData?.attendance;

      final shiftName = currentShift?.name ?? 'General Shift';
      final shiftTiming = (currentShift?.startTime != null && currentShift?.endTime != null)
          ? '${currentShift!.startTime} - ${currentShift.endTime}'
          : '10:00 AM - 07:00 PM';
      final isOngoing = currentShift?.isOngoing ?? false;

      // Date parsing
      DateTime now = DateTime.now();
      if (empData?.date != null) {
        final parsed = DateTime.tryParse(empData!.date!);
        if (parsed != null) now = parsed;
      }
      final monthStr = DateFormat('MMM').format(now);
      final dayNum = DateFormat('dd').format(now);
      final weekdayStr = empData?.day != null && empData!.day!.isNotEmpty
          ? (empData.day!.length > 3 ? empData.day!.substring(0, 3) : empData.day!)
          : DateFormat('EEE').format(now);

      final checkInTime = attendance?.checkIn ?? '--:-- --';
      final isCheckedIn = attendance?.checkIn != null && attendance!.checkIn!.isNotEmpty;
      final checkInStatus = isCheckedIn ? 'Completed' : (attendance?.status ?? 'Not Marked');
      final checkInColor = isCheckedIn ? const Color(0xFF22C55E) : const Color(0xFFF97316);

      final checkOutTime = attendance?.checkOut ?? '--:-- --';
      final isCheckedOut = attendance?.checkOut != null && attendance!.checkOut!.isNotEmpty;
      final checkOutStatus = isCheckedOut ? 'Completed' : 'Pending';
      final checkOutColor = isCheckedOut ? const Color(0xFF22C55E) : const Color(0xFFF97316);

      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withValues(alpha: 0.12),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 70),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const AppText(
                            'Current Shift',
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isOngoing
                                  ? const Color(0xFF10B981)
                                  : Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: AppText(
                              isOngoing ? '• Ongoing' : '• Scheduled',
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      AppText(
                        shiftTiming,
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                      const SizedBox(height: 8),
                      AppText(
                        shiftName,
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      children: [
                        AppText(
                          monthStr,
                          color: AppColors.primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        const SizedBox(height: 4),
                        AppText(
                          dayNum,
                          color: AppColors.textColorPrimary,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                        ),
                        AppText(
                          weekdayStr,
                          color: AppColors.textColorPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Transform.translate(
              offset: const Offset(0, -50),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _CheckItem(
                              title: 'Check-in',
                              time: checkInTime,
                              status: checkInStatus,
                              icon: isCheckedIn ? Iconsax.tick_circle : Iconsax.clock,
                              color: checkInColor,
                            ),
                          ),

                          Container(
                            height: 62,
                            width: 1,
                            color: AppColors.slate200,
                          ),

                          Expanded(
                            child: _CheckItem(
                              title: 'Check-out',
                              time: checkOutTime,
                              status: checkOutStatus,
                              icon: isCheckedOut ? Iconsax.tick_circle : Iconsax.clock,
                              color: checkOutColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    AppButton(
                      text: isCheckedOut
                          ? 'Attendance Completed'
                          : (isCheckedIn ? 'Check Out' : 'Mark Attendance'),
                      height: 50,
                      borderRadius: 16,
                      color: AppColors.primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      icon: const Icon(
                        Iconsax.finger_scan,
                        color: Colors.white,
                        size: 22,
                      ),
                      onPressed: () {
                        if (Get.isRegistered<DashboardController>()) {
                          Get.find<DashboardController>().changeIndex(1);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _CheckItem extends StatelessWidget {
  final String title;
  final String time;
  final String status;
  final IconData icon;
  final Color color;

  const _CheckItem({
    required this.title,
    required this.time,
    required this.status,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppText(
          title,
          color: AppColors.textColorSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 7),
            AppText(
              time,
              color: AppColors.textColorPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: AppText(
            status,
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _ActionStat extends StatelessWidget {
  final String label;
  final String time;
  final String status;
  final Color statusColor;

  const _ActionStat({required this.label, required this.time, required this.status, required this.statusColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppText(label, fontSize: 11, color: AppColors.textColorSecondary),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_rounded, color: statusColor, size: 18),
            const SizedBox(width: 8),
            AppText(time, fontSize: 16, fontWeight: FontWeight.w800),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: AppText(status, color: statusColor, fontSize: 10, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _TodayBirthdayCard extends StatelessWidget {
  const _TodayBirthdayCard();

  @override
  Widget build(BuildContext context) {
    final dashboardController = Get.isRegistered<DashboardController>()
        ? Get.find<DashboardController>()
        : Get.put(DashboardController());

    return Obx(() {
      final birthdays = dashboardController.employeeDashboardData.value?.todaysBirthdays ?? [];

      if (birthdays.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.slate200),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      AppText("Today's Birthday", fontSize: 14, fontWeight: FontWeight.w700),
                      SizedBox(width: 6),
                      AppText('🎂', fontSize: 14),
                    ],
                  ),
                  TextButton(
                    onPressed: () => Get.to(() => const UpcomingBirthdaysScreen()),
                    child: const AppText('View all >', fontSize: 12, color: AppColors.primaryColor),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Iconsax.cake, color: AppColors.primaryColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText('No birthdays today', fontSize: 13, fontWeight: FontWeight.w600),
                        AppText('Check upcoming birthdays for the team', fontSize: 11, color: AppColors.textColorSecondary),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }

      final firstBday = birthdays.first;
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.slate200),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    AppText("Today's Birthday", fontSize: 14, fontWeight: FontWeight.w700),
                    SizedBox(width: 6),
                    AppText('🎂', fontSize: 14),
                  ],
                ),
                TextButton(
                  onPressed: () => Get.to(() => const UpcomingBirthdaysScreen()),
                  child: const AppText('View all >', fontSize: 12, color: AppColors.primaryColor),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                () {
                  final hasBdayAvatar = firstBday.avatar != null &&
                      firstBday.avatar!.isNotEmpty &&
                      Uri.tryParse(firstBday.avatar!)?.isAbsolute == true;
                  return CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.slate200,
                    backgroundImage: hasBdayAvatar ? NetworkImage(firstBday.avatar!) : null,
                    onBackgroundImageError: hasBdayAvatar ? (error, stackTrace) {} : null,
                    child: !hasBdayAvatar
                        ? const Icon(Icons.person, color: AppColors.textColorSecondary, size: 20)
                        : null,
                  );
                }(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(firstBday.name ?? 'Team Member', fontSize: 14, fontWeight: FontWeight.w700),
                      AppText(firstBday.designation ?? 'Colleague', fontSize: 11, color: AppColors.textColorSecondary),
                    ],
                  ),
                ),
                const Icon(Iconsax.gift, color: Colors.red, size: 24),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _TodayWorkSummary extends StatelessWidget {
  const _TodayWorkSummary();

  @override
  Widget build(BuildContext context) {
    final dashboardController = Get.isRegistered<DashboardController>()
        ? Get.find<DashboardController>()
        : Get.put(DashboardController());

    return Obx(() {
      final summary = dashboardController.employeeDashboardData.value?.todaysSummary;
      final workingHours = summary?.workingHours ?? '00h 00m';
      final breakHours = summary?.breakHours ?? '00h 00m';
      final overtime = summary?.overtime ?? '00h 00m';
      final status = summary?.status ?? 'Not Marked';

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            _SummaryItem(icon: Iconsax.clock, label: 'Working Hours', value: workingHours, color: const Color(0xFF3B82F6)),
            const SizedBox(width: 12),
            _SummaryItem(icon: Iconsax.coffee, label: 'Break Hours', value: breakHours, color: Colors.orange),
            const SizedBox(width: 12),
            _SummaryItem(icon: Iconsax.timer_1, label: 'Overtime', value: overtime, color: Colors.purple),
            const SizedBox(width: 12),
            _SummaryItem(icon: Iconsax.tick_circle, label: 'Status', value: status, color: Colors.green),
          ],
        ),
      );
    });
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryItem({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 12),
          AppText(label, fontSize: 9, color: AppColors.textColorSecondary),
          const SizedBox(height: 4),
          AppText(value, fontSize: 13, fontWeight: FontWeight.w800),
        ],
      ),
    );
  }
}



class _EmployeeQuickActions extends StatelessWidget {
  const _EmployeeQuickActions();

  @override
  Widget build(BuildContext context) {
    final actions = [
      {'icon': Iconsax.document_text, 'label': 'Apply Leave', 'color': Colors.green, 'onTap': () => Get.to(() => const ApplyLeaveScreen())},
      {'icon': Iconsax.note_text, 'label': 'My Leaves', 'color': Colors.purple, 'onTap': () => Get.to(() => const MyLeavesScreen())},
      {'icon': Iconsax.calendar_tick, 'label': 'Attendance History', 'color': AppColors.primaryColor, 'onTap': () =>Get.to(() => const AttendanceHistoryScreen())},
      {'icon': Iconsax.wallet, 'label': 'Payslip', 'color': Colors.orange, 'onTap': () => Get.to(() => const PayslipHistoryScreen())},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: actions.map((item) {
        return Expanded(
          child: GestureDetector(
            onTap: item['onTap'] as VoidCallback?,
            behavior: HitTestBehavior.opaque,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (item['color'] as Color).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(item['icon'] as IconData, color: item['color'] as Color, size: 24),
                ),
                const SizedBox(height: 8),
                AppText(item['label'] as String, fontSize: 10, textAlign: TextAlign.center, fontWeight: FontWeight.w600),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _AnnouncementsCard extends StatelessWidget {
  const _AnnouncementsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.withValues(alpha: 0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Iconsax.notification_bing, color: Colors.green, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppText('Office Closed on 25 May', fontSize: 14, fontWeight: FontWeight.w700),
                const SizedBox(height: 4),
                const AppText(
                  'The office will remain closed on 25 May 2025 on account of public holiday.',
                  fontSize: 11,
                  color: AppColors.textColorSecondary,
                ),
                const SizedBox(height: 12),
                const AppText('2h ago', fontSize: 10, color: AppColors.textColorHint),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
