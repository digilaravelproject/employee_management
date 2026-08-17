import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import 'employee_daily_update_screen.dart';

class EmployeeProjectsForUpdateScreen extends StatelessWidget {
  const EmployeeProjectsForUpdateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock assigned projects
    final projects = [
      {'title': 'HRMS Revamp', 'status': 'In Progress', 'lastUpdate': 'Yesterday'},
      {'title': 'Attendance App V2', 'status': 'Active', 'lastUpdate': '2 days ago'},
      {'title': 'Internal Dashboard', 'status': 'Planning', 'lastUpdate': 'No updates yet'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textColorPrimary, size: 18),
          onPressed: () => Get.back(),
        ),
        title: const AppText(
          'Select Project for Update',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textColorPrimary,
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: projects.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final project = projects[index];
            return InkWell(
              onTap: () {
                Get.to(() => EmployeeDailyUpdateScreen(projectTitle: project['title']!));
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
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
                        color: AppColors.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Iconsax.folder_open, color: AppColors.primaryColor),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            project['title']!,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textColorPrimary,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              AppText(
                                project['status']!,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryColor,
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.circle, size: 4, color: AppColors.textColorHint),
                              const SizedBox(width: 8),
                              AppText(
                                'Last: ${project['lastUpdate']}',
                                fontSize: 11,
                                color: AppColors.textColorSecondary,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(Iconsax.arrow_right_3, size: 18, color: AppColors.textColorHint),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
