import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../role_permissions/views/role_list_screen.dart';
import '../../departments/views/department_list_screen.dart';
import '../../projects/views/project_list_screen.dart';
import '../../tasks/views/tasks_list_screen.dart';
import '../../assets/views/assets_list_screen.dart';
import '../../holidays/views/holiday_calendar_screen.dart';
import '../../performance/views/performance_dashboard_screen.dart';
import '../../company_profile/views/company_profile_view_screen.dart';
import '../../leads/views/leads_dashboard_shell.dart';
import '../../payroll/views/salary_employee_list_screen.dart';
import '../../clients/views/client_list_screen.dart';
import '../../hr/views/hr_portal_dashboard.dart';
import '../../compliance/views/compliance_dashboard_screen.dart';
import '../../hr/views/announcements_screen.dart';
import '../../followup/views/followup_dashboard_screen.dart';
import '../../reports/views/reports_dashboard_screen.dart';
import '../../security/views/security_dashboard_screen.dart';
import '../../chat/views/chat_list_screen.dart';
import '../../documents/views/documents_dashboard_screen.dart';


class AllModulesScreen extends StatelessWidget {
  const AllModulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header (Title & Customise Button) ──
              const _AllModulesHeader(),
              const SizedBox(height: 20),

              // ── Premium Good Morning Banner ──
              const _GoodMorningBanner(),
              const SizedBox(height: 24),

              // ── 24 Modules Grid ──
              const _ModulesGrid(),
              const SizedBox(height: 28),

              // ── Stay on Track Banner ──
              const _StayOnTrackBanner(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ── ALL MODULES HEADER ──────────────────────────────────────────────────────
class _AllModulesHeader extends StatelessWidget {
  const _AllModulesHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const AppText(
          'All Modules',
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: Color(0xFF1E293B),
        ),

        // Customise Button
        GestureDetector(
          onTap: () {
            // Optional: Implement module customisation action
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEEF2FF)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Row(
              children: [
                Icon(
                  Iconsax.setting_4,
                  size: 14,
                  color: Color(0xFF4F46E5),
                ),
                SizedBox(width: 6),
                AppText(
                  'Customise',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4F46E5),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}


// ── GOOD MORNING GRADIENT BANNER ────────────────────────────────────────────
class _GoodMorningBanner extends StatelessWidget {
  const _GoodMorningBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF4F46E5), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Background subtle glowing shapes & grid pattern
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),

          // High-fidelity Glassmorphic Mockup Illustration on the Right
          const Positioned(
            right: 15,
            top: 25,
            child: _GlassmorphicPlatformIllustration(),
          ),

          // Main Banner Content
          Padding(
            padding: const EdgeInsets.all(22.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    AppText(
                      'Good Morning, Admin',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFEF08A), // Warm yellow highlight
                    ),
                    SizedBox(width: 5),
                    Text(
                      '👋',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const SizedBox(
                  width: 200,
                  child: Text(
                    'Everything you need,\nin one smart platform',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Statistics bottom row
                const Row(
                  children: [
                    _BannerStat(
                      icon: Iconsax.profile_2user,
                      value: '128',
                      label: 'Employees',
                    ),
                    _VerticalDivider(),
                    _BannerStat(
                      icon: Iconsax.calendar_tick,
                      value: '26',
                      label: 'Present Today',
                    ),
                    _VerticalDivider(),
                    _BannerStat(
                      icon: Iconsax.briefcase,
                      value: '12',
                      label: 'Pending Tasks',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _BannerStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 14,
                ),
              ),
              const SizedBox(width: 6),
              AppText(
                value,
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 4),
          AppText(
            label,
            fontSize: 9,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: Colors.white.withValues(alpha: 0.2),
    );
  }
}

// ── GLASSMORPHIC PLATFORM ILLUSTRATION ────────────────────────────────────────
class _GlassmorphicPlatformIllustration extends StatelessWidget {
  const _GlassmorphicPlatformIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      height: 95,
      child: Stack(
        children: [
          // Background Panel
          Positioned(
            left: 5,
            top: 5,
            child: Container(
              width: 110,
              height: 75,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.18),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Mini Pie Chart Indicator
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.6),
                            width: 3.5,
                          ),
                        ),
                        child: Center(
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFEF08A),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Mock lines
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 5,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              height: 4,
                              width: 25,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Bottom bar representation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 12,
                        width: 8,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Container(
                        height: 20,
                        width: 8,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Container(
                        height: 16,
                        width: 8,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Overlapping card in bottom right corner
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        height: 12,
                        width: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4F46E5),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                      Container(
                        height: 24,
                        width: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                      Container(
                        height: 18,
                        width: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}



// ── MODULES GRID ─────────────────────────────────────────────────────────────
class _ModulesGrid extends StatelessWidget {
  const _ModulesGrid();

  @override
  Widget build(BuildContext context) {
    final List<_ModuleItem> modules = [
      const _ModuleItem(
        label: 'Role',
        icon: Iconsax.element_4,
        color: Color(0xFF6366F1), // Indigo
      ),
      const _ModuleItem(
        label: 'Department',
        icon: Iconsax.element_4,
        color: Color(0xFF6366F1), // Indigo
      ),
      const _ModuleItem(
        label: 'Projects',
        icon: Iconsax.folder_open,
        color: Color(0xFF2563EB), // Deep Blue
      ),
      const _ModuleItem(
        label: 'Tasks',
        icon: Iconsax.task_square,
        color: Color(0xFFF97316), // Orange
      ),
      const _ModuleItem(
        label: 'Assets',
        icon: Iconsax.monitor,
        color: Color(0xFFF97316), // Orange
      ),
      const _ModuleItem(
        label: 'Company Profile',
        icon: Iconsax.profile_2user,
        color: Color(0xFF3B82F6), // Blue
      ),
      // const _ModuleItem(
      //   label: 'Attendance',
      //   icon: Iconsax.calendar_tick,
      //   color: Color(0xFF10B981), // Emerald
      // ),
      // const _ModuleItem(
      //   label: 'Leaves',
      //   icon: Iconsax.sun_1,
      //   color: Color(0xFFF97316), // Orange
      // ),
      const _ModuleItem(
        label: 'Payroll / Salary',
        icon: Iconsax.wallet,
        color: Color(0xFF10B981), // Emerald
      ),
      // const _ModuleItem(
      //   label: 'Shifts & Roster',
      //   icon: Iconsax.clock,
      //   color: Color(0xFF8B5CF6), // Purple
      // ),

      const _ModuleItem(
        label: 'Clients',
        icon: Iconsax.people,
        color: Color(0xFF7C3AED), // Dark Purple
      ),
      const _ModuleItem(
        label: 'Leads',
        icon: Iconsax.filter,
        color: Color(0xFFF59E0B), // Amber
      ),
      const _ModuleItem(
        label: 'Hr ',
        icon: Iconsax.briefcase,
        color: Color(0xFF10B981), // Emerald
      ),
      const _ModuleItem(
        label: 'Follow-ups',
        icon: Iconsax.call,
        color: Color(0xFF3B82F6), // Blue
      ),
      const _ModuleItem(
        label: 'Chat',
        icon: Iconsax.message_text,
        color: Color(0xFF0EA5E9), // Sky
      ),
      // const _ModuleItem(
      //   label: 'Announcements',
      //   icon: Iconsax.volume_high,
      //   color: Color(0xFF8B5CF6), // Purple
      // ),
      const _ModuleItem(
        label: 'Documents',
        icon: Iconsax.document_text,
        color: Color(0xFF10B981), // Emerald
      ),
      const _ModuleItem(
        label: 'Reports',
        icon: Iconsax.graph,
        color: Color(0xFFEF4444), // Red
      ),
      const _ModuleItem(
        label: 'security',
        icon: Iconsax.shield,
        color: Color(0xFF3B82F6), // Blue
      ),

      const _ModuleItem(
        label: 'Policies',
        icon: Iconsax.document_text,
        color: Color(0xFF6366F1), // Indigo
      ),
      const _ModuleItem(
        label: 'Calendar',
        icon: Iconsax.calendar,
        color: Color(0xFFF43F5E), // Rose
      ),
      const _ModuleItem(
        label: 'Performance',
        icon: Iconsax.graph,
        color: Color(0xFF6366F1), // Indigo
      ),
      // const _ModuleItem(
      //   label: 'Settings',
      //   icon: Iconsax.setting,
      //   color: Color(0xFF64748B), // Slate Grey
      // ),
      // const _ModuleItem(
      //   label: 'Roles & Permissions',
      //   icon: Iconsax.shield,
      //   color: Color(0xFF2563EB), // Deep Blue
      // ),
      // const _ModuleItem(
      //   label: 'More',
      //   icon: Iconsax.element_equal,
      //   color: Color(0xFF6366F1), // Indigo
      // ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 14,
        childAspectRatio: 0.76,
      ),
      itemCount: modules.length,
      itemBuilder: (context, index) {
        final item = modules[index];
        return _ModuleCard(item: item);
      },
    );
  }
}

class _ModuleItem {
  final String label;
  final IconData icon;
  final Color color;

  const _ModuleItem({
    required this.label,
    required this.icon,
    required this.color,
  });
}

class _ModuleCard extends StatelessWidget {
  final _ModuleItem item;

  const _ModuleCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: item.color.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (item.label == 'Roles & Permissions' || item.label == 'Role') {
              Get.to(() => const RoleListScreen());
            } else if (item.label == 'Department') {
              Get.to(() => const DepartmentListScreen());
            } else if (item.label == 'Projects') {
              Get.to(() => const ProjectListScreen());
            } else if (item.label == 'Tasks') {
              Get.to(() => const TasksListScreen());
            } else if (item.label == 'Assets') {
              Get.to(() => const AssetsListScreen());
            } else if (item.label == 'Calendar') {
              Get.to(() => const HolidayCalendarScreen());
            } else if (item.label == 'Performance') {
              Get.to(() => const PerformanceDashboardScreen());
            } else if (item.label == 'Company Profile') {
              Get.to(() => const CompanyProfileViewScreen());
            } else if (item.label == 'Leads') {
              Get.to(() => const LeadsDashboardShell());
            } else if (item.label == 'Clients') {
              Get.to(() => const ClientListScreen());
            } else if (item.label == 'Payroll / Salary') {
              Get.to(() => const SalaryEmployeeListScreen());
            } else if (item.label.trim() == 'Hr') {
              Get.to(() => const HrPortalDashboard());
            } else if (item.label == 'Policies') {
              Get.to(() => const ComplianceDashboardScreen());
            } else if (item.label == 'Announcements') {
              Get.to(() => const AnnouncementsScreen());
            } else if (item.label == 'Follow-ups') {
              Get.to(() => const FollowupDashboardScreen());
            } else if (item.label == 'Reports') {
              Get.to(() => const ReportsDashboardScreen());
            } else if (item.label == 'security') {
              Get.to(() => const SecurityDashboardScreen());
            } else if (item.label == 'Chat') {
              Get.to(() => const ChatListScreen());
            } else if (item.label == 'Documents') {
              Get.to(() => const DocumentsDashboardScreen());
            } else {
              Get.snackbar(
                item.label,
                '${item.label} module is coming soon!',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColors.primaryColor,
                colorText: Colors.white,
              );
            }
          },
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon wrapper with soft tinted backing
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    item.icon,
                    color: item.color,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 10),
                // Label
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      item.label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                        height: 1.25,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── STAY ON TRACK BANNER ────────────────────────────────────────────────────
class _StayOnTrackBanner extends StatelessWidget {
  const _StayOnTrackBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3FF), // Soft light-purple pastel
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFEDE9FE)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: Archery Target & Trophy Custom Graphics
          const SizedBox(
            width: 70,
            height: 70,
            child: _ThreeDIllustrationGraphics(),
          ),
          const SizedBox(width: 12),

          // Center: Title, Subtitle and Pill Button
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    AppText(
                      'Stay on Track!',
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                    SizedBox(width: 4),
                    Text(
                      '🎯',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const AppText(
                  'You have 12 pending tasks\nand 3 leave requests\nawaiting approval.',
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                ),
                const SizedBox(height: 10),

                // Pill Button
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F46E5), // Indigo Purple
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4F46E5).withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const AppText(
                    'View Pending',
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Right: Column with two mini-cards
          const Column(
            children: [
              _MiniPendingCard(
                iconColor: Color(0xFF8B5CF6),
                bgColor: Color(0xFFF3E8FF),
                value: '12',
                label: 'Pending Tasks',
              ),
              SizedBox(height: 8),
              _MiniPendingCard(
                iconColor: Color(0xFF10B981),
                bgColor: Color(0xFFD1FAE5),
                value: '3',
                label: 'Leave Requests',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniPendingCard extends StatelessWidget {
  final Color iconColor;
  final Color bgColor;
  final String value;
  final String label;

  const _MiniPendingCard({
    required this.iconColor,
    required this.bgColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Iconsax.sun_1,
                  color: iconColor,
                  size: 10,
                ),
              ),
              const SizedBox(width: 6),
              AppText(
                value,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1E293B),
              ),
            ],
          ),
          const SizedBox(height: 2),
          AppText(
            label,
            fontSize: 7.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF94A3B8),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── CUSTOM GRAPHICS PAINT FOR 3D ARCHERY TARGET & TROPHY ────────────────────
class _ThreeDIllustrationGraphics extends StatelessWidget {
  const _ThreeDIllustrationGraphics();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Concentric circles representing Archery Target in 3D perspective
        Positioned(
          left: 15,
          bottom: 2,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFC7D2FE), width: 3),
              color: Colors.white,
            ),
            child: Center(
              child: Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Color(0xFF818CF8),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4F46E5),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Arrow passing through
        Positioned(
          left: 2,
          bottom: 30,
          child: Transform.rotate(
            angle: -0.6,
            child: Container(
              width: 50,
              height: 2.5,
              color: const Color(0xFFEF4444),
            ),
          ),
        ),

        // Golden Trophy
        Positioned(
          left: 0,
          top: 0,
          child: Stack(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFFFBBF24), // Gold Yellow
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.award,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              Positioned(
                bottom: -1,
                left: 10,
                child: Container(
                  width: 12,
                  height: 4,
                  color: const Color(0xFFD97706), // Dark Gold base
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
