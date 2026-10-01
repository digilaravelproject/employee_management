import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/employee_assigned_projects_controller.dart';
import '../controllers/projects_controller.dart';
import '../models/employee_assigned_project_model.dart';
import 'project_details_screen.dart';

class EmployeeAssignedProjectsScreen extends StatelessWidget {
  const EmployeeAssignedProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<EmployeeAssignedProjectsController>()
        ? Get.find<EmployeeAssignedProjectsController>()
        : Get.put(EmployeeAssignedProjectsController());

    final filterTabs = [
      {'label': 'All', 'value': 'all'},
      {'label': 'In Progress', 'value': 'In Progress'},
      {'label': 'Not Started', 'value': 'Not Started'},
      {'label': 'Completed', 'value': 'Completed'},
      {'label': 'On Hold', 'value': 'On Hold'},
    ];

    return Scaffold(
      backgroundColor: AppColors.slate50,
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
                size: 20,
              ),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText(
              'My Projects',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textColorPrimary,
            ),
            Obx(() => AppText(
                  controller.totalProjects.value > 0
                      ? '${controller.totalProjects.value} Assigned Projects'
                      : 'Assigned Projects',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textColorHint,
                )),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.refresh, color: AppColors.textColorPrimary, size: 20),
            tooltip: 'Refresh',
            onPressed: () => controller.fetchAssignedProjects(isRefresh: true),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // ── Search & Filter Tabs ──
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              children: [
                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.slate100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.slate200),
                  ),
                  child: TextField(
                    controller: controller.searchController,
                    onChanged: (val) => controller.searchQuery.value = val,
                    style: const TextStyle(fontSize: 13, color: AppColors.textColorPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search assigned projects...',
                      hintStyle: const TextStyle(fontSize: 13, color: AppColors.textColorHint),
                      prefixIcon: const Icon(Iconsax.search_normal_1, color: AppColors.textColorHint, size: 18),
                      suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textColorHint),
                              onPressed: controller.clearSearch,
                            )
                          : const SizedBox.shrink()),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Horizontal Status Filter Pills
                SizedBox(
                  height: 34,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: filterTabs.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final tab = filterTabs[index];
                      final label = tab['label']!;
                      final value = tab['value']!;

                      return Obx(() {
                        final isSelected = controller.selectedStatus.value.toLowerCase() == value.toLowerCase();
                        return GestureDetector(
                          onTap: () => controller.changeStatusFilter(value),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primaryColor : AppColors.slate100,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? AppColors.primaryColor : AppColors.slate200,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: AppText(
                              label,
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? Colors.white : AppColors.textColorSecondary,
                            ),
                          ),
                        );
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // ── Main Projects List ──
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryColor),
                );
              }

              if (controller.errorMessage.value.isNotEmpty && controller.assignedProjects.isEmpty) {
                return RefreshIndicator(
                  onRefresh: () => controller.fetchAssignedProjects(isRefresh: true),
                  color: AppColors.primaryColor,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Iconsax.danger, size: 50, color: AppColors.errorColor),
                            const SizedBox(height: 14),
                            AppText(
                              controller.errorMessage.value,
                              fontSize: 13,
                              color: AppColors.textColorSecondary,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () => controller.fetchAssignedProjects(isRefresh: true),
                              icon: const Icon(Iconsax.refresh, size: 16, color: Colors.white),
                              label: const AppText('Retry', color: Colors.white, fontSize: 13),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (controller.assignedProjects.isEmpty) {
                return RefreshIndicator(
                  onRefresh: () => controller.fetchAssignedProjects(isRefresh: true),
                  color: AppColors.primaryColor,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Iconsax.folder_open, size: 64, color: AppColors.textColorHint.withValues(alpha: 0.3)),
                            const SizedBox(height: 16),
                            const AppText(
                              'No Assigned Projects',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColorPrimary,
                            ),
                            const SizedBox(height: 4),
                            AppText(
                              controller.selectedStatus.value.toLowerCase() != 'all'
                                  ? 'No projects matching "${controller.selectedStatus.value}" status'
                                  : 'You do not have any projects assigned to you yet',
                              fontSize: 12,
                              color: AppColors.textColorHint,
                              textAlign: TextAlign.center,
                            ),
                            if (controller.selectedStatus.value.toLowerCase() != 'all' ||
                                controller.searchQuery.value.isNotEmpty) ...[
                              const SizedBox(height: 14),
                              TextButton.icon(
                                onPressed: () {
                                  controller.clearSearch();
                                  controller.changeStatusFilter('all');
                                },
                                icon: const Icon(Icons.clear_all, size: 16),
                                label: const AppText('Reset Filters', fontSize: 12),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }

              final itemCount = controller.assignedProjects.length +
                  (controller.isLoadingMore.value ? 1 : 0);

              return RefreshIndicator(
                onRefresh: () => controller.fetchAssignedProjects(isRefresh: true),
                color: AppColors.primaryColor,
                child: ListView.builder(
                  controller: controller.scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  itemCount: itemCount,
                  itemBuilder: (context, index) {
                    if (index >= controller.assignedProjects.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                      );
                    }

                    final item = controller.assignedProjects[index];
                    return _EmployeeAssignedProjectCard(projectItem: item);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _EmployeeAssignedProjectCard extends StatelessWidget {
  final EmployeeAssignedProjectItem projectItem;

  const _EmployeeAssignedProjectCard({required this.projectItem});

  @override
  Widget build(BuildContext context) {
    final themeColor = _getThemeColor(projectItem.category);
    final statusColor = _getStatusColor(projectItem.status);
    final progress = (projectItem.progress.toDouble() / 100.0).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.slate200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            // Set up ProjectsController to inspect full details
            final projectsController = Get.isRegistered<ProjectsController>()
                ? Get.find<ProjectsController>()
                : Get.put(ProjectsController());

            projectsController.selectedProject.value = projectItem.toProject();
            projectsController.selectedDetailsTabIdx.value = 0;
            projectsController.fetchProjectDetails(projectItem.id);

            Get.to(() => ProjectDetailsScreen(projectId: projectItem.id.toString()));
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Category Icon, Name & Category, Status Badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: themeColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getCategoryIcon(projectItem.category),
                        color: themeColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            projectItem.name,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColorPrimary,
                          ),
                          const SizedBox(height: 2),
                          AppText(
                            projectItem.category.isNotEmpty ? projectItem.category : 'General',
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textColorHint,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: AppText(
                        projectItem.status,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),

                // Description (if available)
                if (projectItem.description.trim().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  AppText(
                    projectItem.description,
                    fontSize: 12,
                    color: AppColors.textColorSecondary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const SizedBox(height: 14),

                // Team avatars, files & Date range
                Row(
                  children: [
                    // Stacked Team Avatars
                    if (projectItem.team.isNotEmpty)
                      _buildTeamAvatarStack(projectItem),

                    // Files badge
                    if (projectItem.filesCount > 0) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.slate100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(Iconsax.document_text, size: 12, color: AppColors.textColorSecondary),
                            const SizedBox(width: 4),
                            AppText(
                              '${projectItem.filesCount}',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textColorSecondary,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],

                    const Spacer(),

                    // End date / Date range
                    Row(
                      children: [
                        const Icon(Iconsax.calendar, size: 13, color: AppColors.textColorHint),
                        const SizedBox(width: 4),
                        AppText(
                          projectItem.endDate.isNotEmpty
                              ? projectItem.endDate
                              : (projectItem.startDate.isNotEmpty ? projectItem.startDate : 'N/A'),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColorSecondary,
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Progress Bar and Percentage
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: AppColors.slate100,
                          valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    AppText(
                      '${projectItem.progress}%',
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textColorPrimary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getThemeColor(String category) {
    switch (category.toLowerCase()) {
      case 'web development':
        return AppColors.indigo500;
      case 'mobile development':
        return AppColors.primaryColor;
      case 'software integration':
        return AppColors.warningColor;
      case 'digital marketing':
        return AppColors.successColor;
      default:
        return AppColors.primaryColor;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'web development':
        return Iconsax.global;
      case 'mobile development':
        return Iconsax.mobile;
      case 'software integration':
        return Iconsax.code;
      case 'digital marketing':
        return Iconsax.volume_high;
      default:
        return Iconsax.folder_2;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppColors.successColor;
      case 'in progress':
        return AppColors.primaryColor;
      case 'on hold':
        return AppColors.warningColor;
      case 'not started':
        return AppColors.slate500;
      default:
        return AppColors.primaryColor;
    }
  }

  Widget _buildTeamAvatarStack(EmployeeAssignedProjectItem item) {
    if (item.team.isEmpty) return const SizedBox.shrink();

    final visibleCount = item.team.length > 3 ? 3 : item.team.length;
    final hasOverflow = item.team.length > 3 || item.membersCount > item.team.length;
    final totalSlots = visibleCount + (hasOverflow ? 1 : 0);
    final stackWidth = (totalSlots > 0 ? (totalSlots - 1) * 18.0 + 26.0 : 26.0);

    return Container(
      margin: const EdgeInsets.only(right: 8),
      width: stackWidth,
      height: 28,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (int i = 0; i < visibleCount; i++)
            Positioned(
              left: i * 18.0,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: AppColors.slate200,
                  backgroundImage: item.team[i].avatar.isNotEmpty
                      ? NetworkImage(item.team[i].avatar)
                      : null,
                  onBackgroundImageError: (_, _) {},
                  child: item.team[i].avatar.isEmpty
                      ? Text(
                          item.team[i].name.isNotEmpty
                              ? item.team[i].name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColorSecondary,
                          ),
                        )
                      : null,
                ),
              ),
            ),
          if (hasOverflow)
            Positioned(
              left: visibleCount * 18.0,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.slate100,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                alignment: Alignment.center,
                child: AppText(
                  '+${((item.membersCount > 0 ? item.membersCount : item.team.length) - visibleCount).clamp(1, 999)}',
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColorSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
