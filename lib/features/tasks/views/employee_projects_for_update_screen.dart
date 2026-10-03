import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../projects/controllers/projects_controller.dart';
import 'employee_daily_update_screen.dart';

class EmployeeProjectsForUpdateScreen extends StatelessWidget {
  const EmployeeProjectsForUpdateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final projController = Get.isRegistered<ProjectsController>()
        ? Get.find<ProjectsController>()
        : Get.put(ProjectsController());

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
        child: Obx(() {
          if (projController.isLoadingProjects.value && projController.projects.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryColor));
          }

          final list = projController.projects;
          if (list.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Iconsax.folder_open, size: 36, color: AppColors.primaryColor),
                    ),
                    const SizedBox(height: 14),
                    const AppText(
                      'No Projects Available',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColorPrimary,
                    ),
                    const SizedBox(height: 6),
                    const AppText(
                      'There are currently no active projects found.',
                      fontSize: 12,
                      color: AppColors.textColorSecondary,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => projController.fetchProjects(isRefresh: true),
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const AppText('Refresh', color: Colors.white, fontSize: 13),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.primaryColor,
            onRefresh: () => projController.fetchProjects(isRefresh: true),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final project = list[index];
                return InkWell(
                  onTap: () {
                    Get.to(() => EmployeeDailyUpdateScreen(projectTitle: project.name));
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
                                project.name,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textColorPrimary,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  AppText(
                                    project.status,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryColor,
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.circle, size: 4, color: AppColors.textColorHint),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: AppText(
                                      project.category,
                                      fontSize: 11,
                                      color: AppColors.textColorSecondary,
                                      maxLines: 1,
                                    ),
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
          );
        }),
      ),
    );
  }
}
