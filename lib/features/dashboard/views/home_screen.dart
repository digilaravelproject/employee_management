import 'package:dgm360/core/widgets/app_button.dart';
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
import '../../payroll/bindings/salary_history_binding.dart';
import '../../payroll/views/employee_my_salary_screen.dart';
import '../../attendance/views/attendance_history_screen.dart';
import '../../notification/controllers/notification_controller.dart';
import '../../../core/controllers/app_controller.dart';
import '../controllers/dashboard_controller.dart';
import 'upcoming_birthdays_screen.dart';
import 'package:intl/intl.dart';
import '../../employee/management/views/employee_list_screen.dart';
import '../../attendance/views/attendance_screen.dart';
import '../../attendance/controllers/attendance_controller.dart';
import '../../role_permissions/views/role_list_screen.dart';
import '../../shift_management/views/shift_details_screen.dart';
import '../../shift_management/models/shift_model.dart';
import '../models/admin_dashboard_model.dart';
import '../models/employee_dashboard_model.dart';
import '../../../core/services/permission/permission_service.dart';
import '../../../core/services/permission/permission_constant.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/storage/shared_prefs.dart';
import '../../profile/controllers/profile_controller.dart';

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
            // Also refresh profile so updated avatar immediately reflects on home screen
            try {
              if (Get.isRegistered<ProfileController>()) {
                await Get.find<ProfileController>().fetchProfile();
              } else {
                final pc = Get.put(ProfileController());
                await pc.fetchProfile();
              }
            } catch (_) {}

            if (appController.userRole.value == 'admin') {
              await dashboardController.fetchAdminDashboard();
            } else {
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
                  return const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Today's Summary Card ──
                      _TodaySummaryCard(),
                      SizedBox(height: 24),

                      // ── Current Shift Card ──
                      _CurrentShiftCard(),
                      SizedBox(height: 24),

                      // ── Quick Actions ──
                      AppText(
                        'Quick Actions',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      SizedBox(height: 16),
                      _QuickActionsGrid(),
                      SizedBox(height: 24),
                    ],
                  );
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── EMPLOYEE SCREEN SECTION ──────────────────────────────────
                      // const AppText(
                      //   'Employee Perspective',
                      //   fontSize: 16,
                      //   fontWeight: FontWeight.w700,
                      //   color: AppColors.textColorPrimary,
                      // ),
                      // const SizedBox(height: 16),

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
    final notifController = Get.isRegistered<NotificationController>()
        ? Get.find<NotificationController>()
        : Get.put(NotificationController());
    final appController = Get.find<AppController>();
    final dashboardController = Get.isRegistered<DashboardController>()
        ? Get.find<DashboardController>()
        : Get.put(DashboardController());

    return Obx(() {
      final isAdmin = appController.userRole.value == 'admin';
      final adminData = dashboardController.adminDashboardData.value;
      final empData = dashboardController.employeeDashboardData.value;

      final greeting = isAdmin
          ? (adminData?.greeting ?? 'Good Evening, Administrator')
          : (empData?.greeting ?? 'Good Morning 👋');

      final subtitle = isAdmin
          ? (adminData?.companyName ?? 'Employee Management')
          : ((empData?.employee?.designation != null && empData?.employee?.department != null)
              ? '${empData!.employee!.designation} • ${empData.employee!.department}'
              : (empData?.employee?.designation ?? empData?.employee?.department ?? 'ABC Solutions Pvt. Ltd.'));

      // Dynamically resolve avatar from ProfileController or local storage
      final profileController = Get.isRegistered<ProfileController>()
          ? Get.find<ProfileController>()
          : null;
      final storedUser = SharedPrefs.getUserData();
      final profileAvatar = profileController?.currentUser.value?.avatar ?? storedUser?.avatar;

      String rawAvatar = '';
      if (profileAvatar != null && profileAvatar.trim().isNotEmpty) {
        rawAvatar = profileAvatar.trim();
      } else if (!isAdmin && empData?.employee?.avatar != null && empData!.employee!.avatar!.trim().isNotEmpty) {
        rawAvatar = empData.employee!.avatar!.trim();
      } else if (isAdmin) {
        rawAvatar = storedUser?.avatar?.trim() ?? '';
      }

      String avatarUrl = '';
      if (rawAvatar.isNotEmpty) {
        if (rawAvatar.startsWith('http')) {
          avatarUrl = rawAvatar
              .replaceFirst('http://127.0.0.1:8000', AppConstants.baseUrl)
              .replaceFirst('http://localhost:8000', AppConstants.baseUrl);
        } else {
          final clean = rawAvatar.startsWith('/') ? rawAvatar : '/$rawAvatar';
          avatarUrl = '${AppConstants.baseUrl}$clean';
        }
      }

      final unreadCount = isAdmin
          ? (adminData?.unreadNotifications ?? notifController.unreadCount)
          : notifController.unreadCount;

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
          InkWell(
            onTap: () => Get.toNamed(RouteHelper.getNotificationsRoute()),
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
                if (unreadCount > 0)
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
                        '$unreadCount',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
          ),
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

  void _navigateToAttendanceTab(int tabIndex) {
    final attendanceController = Get.isRegistered<AttendanceController>()
        ? Get.find<AttendanceController>()
        : Get.put(AttendanceController());
    attendanceController.changeTab(tabIndex);

    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().changeIndex(1);
    } else {
      Get.to(() => AttendanceScreen(initialTab: tabIndex));
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboardController = Get.isRegistered<DashboardController>()
        ? Get.find<DashboardController>()
        : Get.put(DashboardController());

    return Obx(() {
      final adminData = dashboardController.adminDashboardData.value;
      final summary = adminData?.todaysSummary;

      String dateDisplay = 'Today';
      if (adminData?.date != null && adminData!.date!.isNotEmpty) {
        try {
          final dt = DateTime.parse(adminData.date!);
          final formatted = DateFormat('dd MMM yyyy').format(dt);
          dateDisplay = adminData.day != null && adminData.day!.isNotEmpty
              ? '$formatted, ${adminData.day}'
              : formatted;
        } catch (_) {
          dateDisplay = '${adminData.date}, ${adminData.day ?? ''}';
        }
      }

      final total = summary?.totalEmployees ?? 0;
      final present = summary?.present ?? 0;
      final absent = summary?.absent ?? 0;
      final onLeave = summary?.onLeave ?? 0;
      final presentPct = summary?.presentPercentage ?? 0;
      final absentPct = summary?.absentPercentage ?? 0;
      final onLeavePct = summary?.onLeavePercentage ?? 0;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryGradientLight, AppColors.primaryGradientDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGradientLight.withValues(alpha: 0.3),
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
                AppText(
                  dateDisplay,
                  color: Colors.white70,
                  fontSize: 11,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatItem(
                  icon: Iconsax.people,
                  label: 'Total Employees',
                  value: '$total',
                  iconColor: AppColors.primaryColor,
                  bgColor: Colors.white,
                  onTap: () => Get.to(() => const EmployeeListScreen()),
                ),
                _StatItem(
                  icon: Iconsax.tick_circle,
                  label: 'Present',
                  value: '$present',
                  subValue: '$presentPct%',
                  iconColor: Colors.green,
                  bgColor: Colors.white,
                  onTap: () => _navigateToAttendanceTab(1),
                ),
                _StatItem(
                  icon: Iconsax.close_circle,
                  label: 'Absent',
                  value: '$absent',
                  subValue: '$absentPct%',
                  iconColor: Colors.red,
                  bgColor: Colors.white,
                  onTap: () => _navigateToAttendanceTab(2),
                ),
                _StatItem(
                  icon: Iconsax.calendar_remove,
                  label: 'On Leave',
                  value: '$onLeave',
                  subValue: '$onLeavePct%',
                  iconColor: Colors.orange,
                  bgColor: Colors.white,
                  onTap: () => _navigateToAttendanceTab(3),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? subValue;
  final Color iconColor;
  final Color bgColor;
  final VoidCallback? onTap;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    this.subValue,
    required this.iconColor,
    required this.bgColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Column(
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
        ),
      ),
    );
  }
}

// ── CURRENT SHIFT CARD ────────────────────────────────────────────────────────
class _CurrentShiftCard extends StatelessWidget {
  const _CurrentShiftCard();

  void _openShiftDetails(AdminCurrentShift? currentShift) {
    if (currentShift != null && currentShift.id != null) {
      Get.to(() => ShiftDetailsScreen(
        shift: ShiftModel(
          id: currentShift.id.toString(),
          name: currentShift.name ?? 'Current Shift',
          code: currentShift.code ?? '',
          type: 'Fixed Shift',
          isActive: true,
          startTime: currentShift.startTime ?? '',
          endTime: currentShift.endTime ?? '',
          workingHours: '9h 00m',
        ),
      ));
    } else {
      Get.to(() => const ShiftManagementScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboardController = Get.isRegistered<DashboardController>()
        ? Get.find<DashboardController>()
        : Get.put(DashboardController());

    return Obx(() {
      final currentShift = dashboardController.adminDashboardData.value?.currentShift;
      final shiftName = currentShift?.name ?? 'No Ongoing Shift';
      final shiftStatus = currentShift?.status ?? 'Ongoing';
      final startTime = currentShift?.startTime ?? '';
      final endTime = currentShift?.endTime ?? '';
      final shiftTiming = (startTime.isNotEmpty && endTime.isNotEmpty)
          ? '$startTime – $endTime'
          : (startTime.isNotEmpty ? startTime : 'N/A');

      final checkInWindow = (currentShift?.checkInWindow?.from != null && currentShift?.checkInWindow?.to != null)
          ? '${currentShift!.checkInWindow!.from} - ${currentShift.checkInWindow!.to}'
          : 'N/A';

      final checkOutWindow = (currentShift?.checkOutWindow?.from != null && currentShift?.checkOutWindow?.to != null)
          ? '${currentShift!.checkOutWindow!.from} - ${currentShift.checkOutWindow!.to}'
          : 'N/A';

      return InkWell(
        onTap: () => _openShiftDetails(currentShift),
        borderRadius: BorderRadius.circular(24),
        child: Container(
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
                  InkWell(
                    onTap: () => _openShiftDetails(currentShift),
                    child: const AppText('View all', color: AppColors.primaryColor, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
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
                    child: AppText(shiftName, color: AppColors.primaryColor, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(radius: 3, backgroundColor: Colors.green),
                        const SizedBox(width: 6),
                        AppText(shiftStatus, color: Colors.green, fontSize: 12, fontWeight: FontWeight.w600),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AppText(shiftTiming, fontSize: 20, fontWeight: FontWeight.w800),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _ShiftDetail(
                      icon: Iconsax.clock,
                      label: 'Check-in Window',
                      value: checkInWindow,
                    ),
                  ),
                  Expanded(
                    child: _ShiftDetail(
                      icon: Iconsax.clock,
                      label: 'Check-out Window',
                      value: checkOutWindow,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
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
        'color': AppColors.primaryColor, // Indigo
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
        'color': AppColors.primaryColor, // Blue
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

    return Obx(() {
      final p = PermissionService.to;
      final isAdmin = p.isAdmin.value;

      final filteredActions = actions.where((item) {
        if (isAdmin) return true;
        final label = item['label'] as String;
        switch (label) {
          case 'Department':
            return p.isAllowed(PermissionConstant.viewDepartments,
                moduleSlug: PermissionConstant.moduleDepartmentsDesignations);
          case 'Role':
            return p.isAllowed(PermissionConstant.viewRolesList,
                moduleSlug: PermissionConstant.moduleRolesPermissionsRbac);
          case 'Designation':
            return p.isAllowed(PermissionConstant.viewDesignations,
                moduleSlug: PermissionConstant.moduleDepartmentsDesignations);
          case 'Shift':
            return p.isAllowed(PermissionConstant.viewDepartments,
                moduleSlug: PermissionConstant.moduleDepartmentsDesignations);
          case 'Employee':
            return p.isAllowed(PermissionConstant.viewEmployeeDirectory,
                moduleSlug: PermissionConstant.moduleEmployeeManagement);
          case 'Leave Management':
            return p.isAllowed(PermissionConstant.viewLeaveDashboard,
                    moduleSlug: PermissionConstant.moduleLeaveManagement) ||
                p.isAllowed(PermissionConstant.allEmployeesRequests,
                    moduleSlug: PermissionConstant.moduleLeaveManagement);
          default:
            return true;
        }
      }).toList();

      if (filteredActions.isEmpty) return const SizedBox.shrink();

      return Wrap(
        spacing: 12,
        runSpacing: 16,
        children: filteredActions.map((item) {
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
                    child: Icon(item['icon'] as IconData,
                        color: item['color'] as Color, size: 24),
                  ),
                  const SizedBox(height: 8),
                  AppText(item['label'] as String,
                      fontSize: 10,
                      textAlign: TextAlign.center,
                      fontWeight: FontWeight.w600),
                ],
              ),
            ),
          );
        }).toList(),
      );
    });
  }
}







// ── EMPLOYEE VIEW WIDGETS ───────────────────────────────────────────────────





class EmployeeShiftAttendanceCard extends StatelessWidget {
  const EmployeeShiftAttendanceCard({super.key});

  void _openShiftDetails(DashboardCurrentShift? shift) {
    if (shift == null || shift.id == null) return;
    Get.to(
      () => ShiftDetailsScreen(
        shift: ShiftModel(
          id: shift.id.toString(),
          name: shift.name ?? 'Current Shift',
          code: shift.code ?? '',
          type: 'Fixed Shift',
          isActive: true,
          startTime: shift.startTime ?? '',
          endTime: shift.endTime ?? '',
          workingHours: '9h 00m',
        ),
      ),
    );
  }

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
              color: AppColors.primaryGradientLight.withValues(alpha: 0.18),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            InkWell(
              onTap: () => _openShiftDetails(currentShift),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 70),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryGradientLight, AppColors.primaryGradientDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
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
                              const SizedBox(width: 6),
                              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 12),
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
                    ),
                    const SizedBox(width: 8),
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
                              onTap: isCheckedIn ||
                                      (!PermissionService.to.isAdmin.value &&
                                          !PermissionService.to.isAllowed(
                                              PermissionConstant.checkInCheckOut,
                                              moduleSlug: PermissionConstant
                                                  .moduleAttendanceRegularization))
                                  ? null
                                  : () => _showCheckInBottomSheet(
                                        context,
                                        dashboardController,
                                        shiftName: shiftName,
                                        shiftTiming: shiftTiming,
                                      ),
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
                              onTap: (isCheckedIn &&
                                      !isCheckedOut &&
                                      (PermissionService.to.isAdmin.value ||
                                          PermissionService.to.isAllowed(
                                              PermissionConstant.checkInCheckOut,
                                              moduleSlug: PermissionConstant
                                                  .moduleAttendanceRegularization)))
                                  ? () => _showCheckOutBottomSheet(
                                        context,
                                        dashboardController,
                                        shiftName: shiftName,
                                        shiftTiming: shiftTiming,
                                      )
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (PermissionService.to.isAdmin.value ||
                        PermissionService.to.isAllowed(
                            PermissionConstant.checkInCheckOut,
                            moduleSlug: PermissionConstant
                                .moduleAttendanceRegularization)) ...[
                      const SizedBox(height: 18),
                      Builder(
                        builder: (context) {
                          final isCheckingIn = dashboardController.isCheckingIn.value;
                          final isCheckingOut = dashboardController.isCheckingOut.value;
                          final isLoading = isCheckingIn || isCheckingOut;

                          return AppButton(
                            text: isCheckedOut
                                ? 'Attendance Completed'
                                : (isCheckedIn ? 'Clock Out' : 'Check In'),
                            isLoading: isLoading,
                            height: 50,
                            borderRadius: 16,
                            color: isCheckedOut
                                ? AppColors.slate400
                                : (isCheckedIn ? const Color(0xFFEF4444) : AppColors.primaryColor),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            icon: isLoading
                                ? null
                                : Icon(
                                    isCheckedIn ? Iconsax.logout : Iconsax.finger_scan,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                            onPressed: isLoading || isCheckedOut
                                ? null
                                : () {
                                    if (!isCheckedIn) {
                                      _showCheckInBottomSheet(
                                        context,
                                        dashboardController,
                                        shiftName: shiftName,
                                        shiftTiming: shiftTiming,
                                      );
                                    } else {
                                      _showCheckOutBottomSheet(
                                        context,
                                        dashboardController,
                                        shiftName: shiftName,
                                        shiftTiming: shiftTiming,
                                      );
                                    }
                                  },
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  void _showCheckInBottomSheet(
    BuildContext context,
    DashboardController controller, {
    required String shiftName,
    required String shiftTiming,
  }) {
    final notesController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.slate200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Iconsax.location,
                          color: AppColors.primaryColor,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              'Attendance Check-In',
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                            SizedBox(height: 3),
                            AppText(
                              'Real-time GPS coordinates will be captured',
                              fontSize: 12,
                              color: AppColors.textColorSecondary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Shift & GPS Badge card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.slate200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Iconsax.clock, size: 16, color: AppColors.primaryColor),
                            const SizedBox(width: 8),
                            Expanded(
                              child: AppText(
                                '$shiftName ($shiftTiming)',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textColorPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Iconsax.gps, size: 16, color: Color(0xFF10B981)),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: AppText(
                                'Current GPS latitude & longitude will be captured',
                                fontSize: 12,
                                color: Color(0xFF047857),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  const AppText(
                    'Notes (Optional)',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColorPrimary,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: notesController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'e.g. Checked in from the Pune office',
                      hintStyle: const TextStyle(
                        color: AppColors.textColorHint,
                        fontSize: 13,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.slate200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.slate200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primaryColor),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(bottomSheetContext).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            side: const BorderSide(color: AppColors.slate300),
                          ),
                          child: const AppText(
                            'Cancel',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColorSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Obx(() {
                          final isCheckingIn = controller.isCheckingIn.value;
                          return AppButton(
                            text: 'Confirm Check-In',
                            isLoading: isCheckingIn,
                            height: 48,
                            borderRadius: 14,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryColor,
                            onPressed: isCheckingIn
                                ? null
                                : () async {
                                    final success = await controller.checkIn(
                                      notes: notesController.text,
                                    );
                                    if (success && Get.isBottomSheetOpen == true) {
                                      Get.back();
                                    }
                                  },
                          );
                        }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCheckOutBottomSheet(
    BuildContext context,
    DashboardController controller, {
    required String shiftName,
    required String shiftTiming,
  }) {
    final notesController = TextEditingController(text: 'Work completed');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.slate200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Iconsax.logout,
                          color: Color(0xFFEF4444),
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              'Clock Out / Check-Out',
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                            SizedBox(height: 3),
                            AppText(
                              'Real-time GPS coordinates will be captured',
                              fontSize: 12,
                              color: AppColors.textColorSecondary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Shift & GPS Badge card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.slate200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Iconsax.clock, size: 16, color: AppColors.primaryColor),
                            const SizedBox(width: 8),
                            Expanded(
                              child: AppText(
                                '$shiftName ($shiftTiming)',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textColorPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Iconsax.gps, size: 16, color: Color(0xFF10B981)),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: AppText(
                                'Current GPS latitude & longitude will be captured',
                                fontSize: 12,
                                color: Color(0xFF047857),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  const AppText(
                    'Notes',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColorPrimary,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: notesController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'e.g. Work completed',
                      hintStyle: const TextStyle(
                        color: AppColors.textColorHint,
                        fontSize: 13,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.slate200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.slate200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFEF4444)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(bottomSheetContext).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            side: const BorderSide(color: AppColors.slate300),
                          ),
                          child: const AppText(
                            'Cancel',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColorSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Obx(() {
                          final isCheckingOut = controller.isCheckingOut.value;
                          return AppButton(
                            text: 'Confirm Clock-Out',
                            isLoading: isCheckingOut,
                            height: 48,
                            borderRadius: 14,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFEF4444),
                            onPressed: isCheckingOut
                                ? null
                                : () async {
                                    final success = await controller.checkOut(
                                      notes: notesController.text,
                                    );
                                    if (success && Get.isBottomSheetOpen == true) {
                                      Get.back();
                                    }
                                  },
                          );
                        }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CheckItem extends StatelessWidget {
  final String title;
  final String time;
  final String status;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _CheckItem({
    required this.title,
    required this.time,
    required this.status,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
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
      ),
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
        return GestureDetector(
          onTap: () => Get.to(() => const UpcomingBirthdaysScreen()),
          child: Container(
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
          ),
        );
      }

      final firstBday = birthdays.first;
      return GestureDetector(
        onTap: () => Get.to(() => const UpcomingBirthdaysScreen()),
        child: Container(
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
            _SummaryItem(icon: Iconsax.clock, label: 'Working Hours', value: workingHours, color: AppColors.primaryColor),
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
      {'icon': Iconsax.wallet, 'label': 'Payslip', 'color': Colors.orange, 'onTap': () => Get.to(() => const EmployeeMySalaryScreen(), binding: SalaryHistoryBinding())},
    ];

    return Obx(() {
      final filteredActions = actions.where((item) {
        if (PermissionService.to.isAdmin.value) return true;
        final label = item['label'] as String;
        switch (label) {
          case 'Apply Leave':
            return PermissionService.to.isAllowed(PermissionConstant.applyForLeave, moduleSlug: PermissionConstant.moduleLeaveManagement);
          case 'My Leaves':
            return PermissionService.to.isAllowed(PermissionConstant.viewLeaveBalance, moduleSlug: PermissionConstant.moduleLeaveManagement) ||
                PermissionService.to.isAllowed(PermissionConstant.viewLeaveDashboard, moduleSlug: PermissionConstant.moduleLeaveManagement);
          case 'Attendance History':
            return PermissionService.to.isAllowed(PermissionConstant.viewAttendanceHistory, moduleSlug: PermissionConstant.moduleAttendanceRegularization);
          case 'Payslip':
            return PermissionService.to.isAllowed(PermissionConstant.viewMySalary, moduleSlug: PermissionConstant.modulePayrollSalary) ||
                PermissionService.to.isAllowed(PermissionConstant.downloadPayslip, moduleSlug: PermissionConstant.modulePayrollSalary);
          default:
            return true;
        }
      }).toList();

      if (filteredActions.isEmpty) return const SizedBox.shrink();

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: filteredActions.map((item) {
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
    });
  }
}


