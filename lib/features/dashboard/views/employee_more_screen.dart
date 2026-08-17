import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../tasks/views/tasks_list_screen.dart';
import '../../projects/views/project_list_screen.dart';
import '../../chat/views/chat_list_screen.dart';
import '../../company_profile/views/company_profile_view_screen.dart';

// Employee specific screens
import '../../payroll/views/employee_my_salary_screen.dart';
import '../../tasks/views/employee_projects_for_update_screen.dart';
import '../../compliance/views/compliance_dashboard_screen.dart';
import '../../assets/views/employee_my_assets_screen.dart';

class EmployeeMoreScreen extends StatelessWidget {
  const EmployeeMoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const AppText('More', fontSize: 18, fontWeight: FontWeight.w700),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText(
              'My Work',
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            const SizedBox(height: 16),
            _MoreMenuItem(
              icon: Iconsax.task_square,
              title: 'My Tasks',
              subtitle: 'View and update your daily tasks',
              iconColor: Colors.blue,
              onTap: () {
                Get.to(() => const TasksListScreen());
              },
            ),
            _MoreMenuItem(
              icon: Iconsax.folder_open,
              title: 'Projects',
              subtitle: 'View assigned projects',
              iconColor: Colors.purple,
              onTap: () {
                Get.to(() => const ProjectListScreen());
              },
            ),
            _MoreMenuItem(
              icon: Iconsax.edit_2,
              title: 'Daily Update',
              subtitle: 'Submit your end of day status',
              iconColor: Colors.orange,
              onTap: () {
                Get.to(() => const EmployeeProjectsForUpdateScreen());
              },
            ),

            const SizedBox(height: 24),
            const AppText(
              'Finance & Communication',
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            const SizedBox(height: 16),
            _MoreMenuItem(
              icon: Iconsax.wallet_money,
              title: 'Salary / Payroll',
              subtitle: 'View payslips and salary details',
              iconColor: Colors.green,
              onTap: () {
                Get.to(() => const EmployeeMySalaryScreen());
              },
            ),
            _MoreMenuItem(
              icon: Iconsax.message,
              title: 'Chat',
              subtitle: 'Communicate with team and HR',
              iconColor: Colors.teal,
              onTap: () {
                Get.to(() => const ChatListScreen());
              },
            ),

            const SizedBox(height: 24),
            const AppText(
              'Company & Resources',
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            const SizedBox(height: 16),
            _MoreMenuItem(
              icon: Iconsax.document_text,
              title: 'Policies',
              subtitle: 'View company rules and guidelines',
              iconColor: Colors.indigo,
              onTap: () {
                Get.to(() => const ComplianceDashboardScreen());
              },
            ),
            _MoreMenuItem(
              icon: Iconsax.monitor,
              title: 'My Assets',
              subtitle: 'Assets assigned to you',
              iconColor: Colors.pink,
              onTap: () {
                Get.to(() => const EmployeeMyAssetsScreen());
              },
            ),
            _MoreMenuItem(
              icon: Iconsax.building,
              title: 'Company Profile',
              subtitle: 'About the organization',
              iconColor: Colors.blueGrey,
              onTap: () {
                Get.to(() => const CompanyProfileViewScreen());
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MoreMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final VoidCallback onTap;

  const _MoreMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(title, fontSize: 15, fontWeight: FontWeight.w700),
                  const SizedBox(height: 4),
                  AppText(subtitle, fontSize: 12, color: AppColors.textColorSecondary),
                ],
              ),
            ),
            const Icon(Iconsax.arrow_right_3, size: 18, color: AppColors.slate200),
          ],
        ),
      ),
    );
  }
}
