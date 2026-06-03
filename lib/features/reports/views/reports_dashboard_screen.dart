import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/admin_reports_controller.dart';
import 'reports_employees_list_screen.dart';

class ReportsDashboardScreen extends StatelessWidget {
  const ReportsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Register controller if not registered
    Get.put(AdminReportsController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
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
                size: 18,
              ),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        title: const AppText(
          'Reports Dashboard (Admin)',
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Color(0xFF1E293B),
        ),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Iconsax.notification, color: Color(0xFF1E293B)),
        //     onPressed: () {},
        //   ),
        // ],
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── OVERVIEW (THIS MONTH) ──
              const AppText(
                'Overview (This Month)',
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF475569),
              ),
              const SizedBox(height: 12),
              
              // Overview Cards Grid
              const Row(
                children: [
                  Expanded(
                    child: _OverviewStatCard(
                      value: '25',
                      label: 'Total Employees',
                      color: Color(0xFF3B82F6), // Blue
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _OverviewStatCard(
                      value: '22',
                      label: 'Present Today',
                      color: Color(0xFF10B981), // Emerald
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Row(
                children: [
                  Expanded(
                    child: _OverviewStatCard(
                      value: '3',
                      label: 'On Leave',
                      color: Color(0xFFEF4444), // Red
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _OverviewStatCard(
                      value: '₹12.5L',
                      label: 'Total Payroll',
                      color: Color(0xFF8B5CF6), // Purple
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── REPORTS DIRECTORY ──
              const AppText(
                'Reports Directory',
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF475569),
              ),
              const SizedBox(height: 12),

              _ReportCategoryTile(
                title: 'Attendance Reports',
                subtitle: 'View attendance summaries and status',
                icon: Iconsax.calendar_tick,
                color: const Color(0xFF10B981),
                onTap: () => Get.to(() => const ReportsEmployeesListScreen(initialTab: 'Attendance')),
              ),
              const SizedBox(height: 12),

              _ReportCategoryTile(
                title: 'Payroll Reports',
                subtitle: 'View payroll & salary detailed breakdown',
                icon: Iconsax.wallet,
                color: const Color(0xFF8B5CF6),
                onTap: () => Get.to(() => const ReportsEmployeesListScreen(initialTab: 'Payroll')),
              ),
              const SizedBox(height: 12),

              _ReportCategoryTile(
                title: 'Leave Reports',
                subtitle: 'View leave history & balance balances',
                icon: Iconsax.sun_1,
                color: const Color(0xFFF97316),
                onTap: () => Get.to(() => const ReportsEmployeesListScreen(initialTab: 'Leave')),
              ),
              const SizedBox(height: 12),

              _ReportCategoryTile(
                title: 'Sales Reports',
                subtitle: 'View sales & leads conversion performance',
                icon: Iconsax.filter,
                color: const Color(0xFF3B82F6),
                onTap: () => Get.to(() => const ReportsEmployeesListScreen(initialTab: 'Sales')),
              ),
              const SizedBox(height: 12),

              _ReportCategoryTile(
                title: 'Task / Project Reports',
                subtitle: 'View active task allocations & milestones',
                icon: Iconsax.task_square,
                color: const Color(0xFFEF4444),
                onTap: () => Get.to(() => const ReportsEmployeesListScreen(initialTab: 'Tasks')),
              ),
              const SizedBox(height: 12),

              _ReportCategoryTile(
                title: 'Export Reports',
                subtitle: 'Export data files in PDF / Excel sheets',
                icon: Iconsax.document_download,
                color: const Color(0xFF64748B),
                onTap: () {
                  Get.snackbar(
                    'Export Engine',
                    'Preparing PDF/Excel exporter configuration...',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: const Color(0xFF1E293B),
                    colorText: Colors.white,
                  );
                },
              ),
              const SizedBox(height: 24),

              // ── QUICK ANALYTICS ──
              const AppText(
                'Quick Analytics',
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF475569),
              ),
              const SizedBox(height: 12),

              const Row(
                children: [
                  Expanded(
                    child: _AnalyticsCard(
                      label: 'Top Performer',
                      name: 'Rahul Sharma',
                      value: '₹1,80,000',
                      color: Color(0xFF10B981),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _AnalyticsCard(
                      label: 'Most Sales',
                      name: 'Neha Kapoor',
                      value: '₹2,50,000',
                      color: Color(0xFF3B82F6),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _AnalyticsCard(
                      label: 'Most Leaves',
                      name: 'Vikas Yadav',
                      value: '6 Leaves',
                      color: Color(0xFFF97316),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverviewStatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _OverviewStatCard({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEEF2FF)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            value,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: color,
          ),
          const SizedBox(height: 4),
          AppText(
            label,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF94A3B8),
          ),
        ],
      ),
    );
  }
}

class _ReportCategoryTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ReportCategoryTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEEF2FF)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        title,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1E293B),
                      ),
                      const SizedBox(height: 3),
                      AppText(
                        subtitle,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF94A3B8),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Color(0xFFCBD5E1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  final String label;
  final String name;
  final String value;
  final Color color;

  const _AnalyticsCard({
    required this.label,
    required this.name,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEF2FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 8),
          AppText(
            name,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1E293B),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          AppText(
            value,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ],
      ),
    );
  }
}
