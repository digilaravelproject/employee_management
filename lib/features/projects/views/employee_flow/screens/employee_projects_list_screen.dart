import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../controllers/employee_flow_controller.dart';
import '../models/employee_flow_models.dart';
import '../widgets/employee_flow_widgets.dart';
import 'employee_project_details_screen.dart';

/// Screen 2: My Projects
/// Matches Mockup 2 from user reference:
/// - Header: "My Projects"
/// - Search Input: "Search projects..."
/// - Filter Chips: Active (2), On Hold (1), Completed (0)
/// - Project Cards: Icon, Code, Status, Progress %, Bar, Due Date & Days Left
class EmployeeProjectsListScreen extends StatelessWidget {
  final bool showBackButton;

  const EmployeeProjectsListScreen({
    super.key,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final controller = EmployeeFlowController.to;

    return Scaffold(
      backgroundColor: EmployeeFlowTheme.surfaceSlate,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: EmployeeFlowTheme.textDark),
                onPressed: () => Get.back(),
              )
            : null,
        title: const Text(
          'My Projects',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: EmployeeFlowTheme.textDark,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Top Search & Filter Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              children: [
                // Search Input
                Container(
                  decoration: BoxDecoration(
                    color: EmployeeFlowTheme.surfaceSlate,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: EmployeeFlowTheme.cardBorder),
                  ),
                  child: TextField(
                    controller: controller.projectSearchController,
                    onChanged: (val) => controller.projectSearchQuery.value = val,
                    style: const TextStyle(fontSize: 14, color: EmployeeFlowTheme.textDark),
                    decoration: InputDecoration(
                      hintText: 'Search projects...',
                      hintStyle: const TextStyle(fontSize: 14, color: EmployeeFlowTheme.textHint),
                      prefixIcon: const Icon(Iconsax.search_normal, color: EmployeeFlowTheme.textHint, size: 18),
                      suffixIcon: Obx(() => controller.projectSearchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18, color: EmployeeFlowTheme.textHint),
                              onPressed: () {
                                controller.projectSearchController.clear();
                                controller.projectSearchQuery.value = '';
                              },
                            )
                          : const SizedBox.shrink()),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Filter Tabs (Active, On Hold, Completed)
                Obx(() {
                  final activeCount = controller.projects.where((p) => p.status == 'Active').length;
                  final onHoldCount = controller.projects.where((p) => p.status == 'On Hold').length;
                  final completedCount = controller.projects.where((p) => p.status == 'Completed').length;

                  return Row(
                    children: [
                      _buildFilterChip(
                        label: 'Active ($activeCount)',
                        value: 'Active',
                        current: controller.projectFilter.value,
                        onTap: () => controller.projectFilter.value = 'Active',
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'On Hold ($onHoldCount)',
                        value: 'On Hold',
                        current: controller.projectFilter.value,
                        onTap: () => controller.projectFilter.value = 'On Hold',
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'Completed ($completedCount)',
                        value: 'Completed',
                        current: controller.projectFilter.value,
                        onTap: () => controller.projectFilter.value = 'Completed',
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),

          // Projects List
          Expanded(
            child: Obx(() {
              final projects = controller.filteredProjects;

              if (projects.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Iconsax.folder_cross, size: 48, color: EmployeeFlowTheme.textHint),
                      const SizedBox(height: 12),
                      const Text(
                        'No projects found',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: EmployeeFlowTheme.textDark),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Try adjusting your search or filter tab.',
                        style: TextStyle(fontSize: 13, color: EmployeeFlowTheme.textMuted),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                physics: const BouncingScrollPhysics(),
                itemCount: projects.length,
                separatorBuilder: (context, index) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final project = projects[index];
                  return _buildProjectCard(context, project, controller);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required String value,
    required String current,
    required VoidCallback onTap,
  }) {
    final isSelected = current == value;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? EmployeeFlowTheme.primaryBlue : EmployeeFlowTheme.surfaceSlate,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? EmployeeFlowTheme.primaryBlue : EmployeeFlowTheme.cardBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : EmployeeFlowTheme.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildProjectCard(
    BuildContext context,
    EmployeeFlowProject project,
    EmployeeFlowController controller,
  ) {
    final percent = (project.progress * 100).toInt();

    return EmployeeFlowCard(
      onTap: () {
        controller.selectedProject.value = project;
        Get.to(() => EmployeeProjectDetailsScreen(project: project));
      },
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Project Icon
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: project.themeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  project.icon,
                  color: project.themeColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: EmployeeFlowTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      project.code,
                      style: const TextStyle(
                        fontSize: 12,
                        color: EmployeeFlowTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              EmployeeFlowStatusBadge(status: project.status),
            ],
          ),
          const SizedBox(height: 14),
          // Percentage Text
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox.shrink(),
              Text(
                '$percent%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: project.status == 'On Hold'
                      ? EmployeeFlowTheme.warningOrange
                      : EmployeeFlowTheme.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Progress Bar
          EmployeeFlowProgressBar(
            progress: project.progress,
            activeColor: project.status == 'On Hold'
                ? EmployeeFlowTheme.warningOrange
                : EmployeeFlowTheme.primaryBlue,
            height: 6,
          ),
          const SizedBox(height: 12),
          // Due Date & Days Left
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Due: ${project.deadline}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: EmployeeFlowTheme.textMuted,
                ),
              ),
              Text(
                '${project.daysLeft} days left',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: EmployeeFlowTheme.primaryBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
