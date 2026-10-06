import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/projects_controller.dart';
import '../models/project_model.dart';
import 'create_project_screen.dart';
import 'project_details_screen.dart';
import '../../../core/services/permission/permission_service.dart';
import '../../../core/services/permission/permission_constant.dart';

class ProjectListScreen extends StatelessWidget {
  const ProjectListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Put controller in memory
    final controller = Get.put(ProjectsController());

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
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textColorPrimary, size: 20),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText(
              'Projects',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textColorPrimary,
            ),
            Obx(() => AppText(
              controller.totalProjectsCount.value > 0
                  ? '${controller.totalProjectsCount.value} Total Projects'
                  : 'Manage all projects',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textColorHint,
            )),
          ],
        ),
        actions: [
          Obx(() {
            final canCreateProject =
                PermissionService.to.isAllowed(PermissionConstant.createProject);
            if (!canCreateProject) return const SizedBox.shrink();

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: ElevatedButton.icon(
                onPressed: () {
                  controller.clearForm();
                  Get.to(() => const CreateProjectScreen(isEditMode: false));
                },
                icon: const Icon(Iconsax.add, size: 14, color: Colors.white),
                label: const AppText(
                  'New Project',
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
      body: Column(
        children: [
          // ── Search & Filter Section ──
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.searchController,
                    onChanged: (value) => controller.searchQuery.value = value,
                    decoration: InputDecoration(
                      hintText: 'Search projects...',
                      hintStyle: const TextStyle(color: AppColors.textColorHint, fontSize: 13),
                      prefixIcon: const Icon(Iconsax.search_normal, color: AppColors.textColorHint, size: 18),
                      suffixIcon: Obx(() {
                        if (controller.isSearchingProjects.value) {
                          return const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                              ),
                            ),
                          );
                        }
                        if (controller.searchQuery.value.isNotEmpty) {
                          return IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textColorHint),
                            onPressed: () {
                              controller.searchController.clear();
                              controller.searchQuery.value = '';
                            },
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                      filled: true,
                      fillColor: AppColors.slate50,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Horizontal Filter Tabs ──
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            height: 52,
            child: Obx(() {
              final selectedTab = controller.selectedTab.value;
              final tabs = ['All', 'In Progress', 'Completed', 'On Hold', 'Not Started'];
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: tabs.length,
                itemBuilder: (context, index) {
                  final tab = tabs[index];
                  final isSelected = selectedTab == tab;
                  return GestureDetector(
                    onTap: () => controller.selectedTab.value = tab,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryColor : AppColors.slate100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.primaryColor : AppColors.slate200,
                          width: 1.0,
                        ),
                        boxShadow: isSelected ? [
                          BoxShadow(
                            color: AppColors.primaryColor.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ] : null,
                      ),
                      child: AppText(
                        tab,
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.textColorSecondary,
                      ),
                    ),
                  );
                },
              );
            }),
          ),
          const SizedBox(height: 12),

          // ── Projects Feed List ──
          Expanded(
            child: Obx(() {
              if (controller.isLoadingProjects.value && controller.projects.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                  ),
                );
              }

              if (controller.projectErrorMessage.isNotEmpty && controller.projects.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Iconsax.info_circle, size: 52, color: AppColors.errorColor),
                        const SizedBox(height: 12),
                        const AppText('Failed to load projects', fontSize: 16, fontWeight: FontWeight.bold),
                        const SizedBox(height: 6),
                        AppText(
                          controller.projectErrorMessage.value,
                          fontSize: 12,
                          color: AppColors.textColorHint,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => controller.fetchProjects(isRefresh: true),
                          icon: const Icon(Icons.refresh, size: 16, color: Colors.white),
                          label: const AppText('Retry', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final list = controller.filteredProjects;
              if (list.isEmpty) {
                return RefreshIndicator(
                  onRefresh: () => controller.fetchProjects(isRefresh: true),
                  color: AppColors.primaryColor,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Iconsax.folder_open, size: 60, color: AppColors.textColorHint.withValues(alpha: 0.3)),
                            const SizedBox(height: 16),
                            const AppText('No Projects Found', fontSize: 16, fontWeight: FontWeight.bold),
                            const SizedBox(height: 4),
                            const AppText('Try creating one or modifying your filters', fontSize: 12, color: AppColors.textColorHint),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }

              final hasMore = controller.currentPage.value < controller.lastPage.value;
              final itemCount = list.length + (controller.isLoadingMoreProjects.value || hasMore ? 1 : 0);

              return RefreshIndicator(
                onRefresh: () => controller.fetchProjects(isRefresh: true),
                color: AppColors.primaryColor,
                child: ListView.builder(
                  controller: controller.scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  itemCount: itemCount,
                  itemBuilder: (context, index) {
                    if (index >= list.length) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: controller.isLoadingMoreProjects.value
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryColor),
                                )
                              : const SizedBox.shrink(),
                        ),
                      );
                    }
                    final p = list[index];
                    return _ProjectCard(project: p);
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

class _ProjectCard extends StatelessWidget {
  final Project project;
  const _ProjectCard({required this.project});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProjectsController>();
    final themeColor = _getThemeColor(project.category);
    final statusColor = _getStatusColor(project.status);
    final progress = project.progressPercentage;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.slate200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            controller.selectedProject.value = project;
            controller.selectedDetailsTabIdx.value = 0;
            controller.fetchProjectDetails(project.id);
            Get.to(() => ProjectDetailsScreen(projectId: project.id));
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row (Category icon circle, Name, Status badge)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: themeColor.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getCategoryIcon(project.category),
                        color: themeColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            project.name,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColorPrimary,
                          ),
                          const SizedBox(height: 2),
                          AppText(
                            project.category,
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
                        color: statusColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: AppText(
                        project.status,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Members list overlap on Left, due date and progress on Right
                Row(
                  children: [
                    // Stacked Overlapping User Avatars
                    Expanded(
                      child: SizedBox(
                        height: 32,
                        child: Stack(
                          children: [
                            for (int i = 0; i < (project.teamMembers.length > 4 ? 4 : project.teamMembers.length); i++)
                              Positioned(
                                left: i * 20.0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                  child: CircleAvatar(
                                    radius: 12,
                                    backgroundColor: AppColors.slate200,
                                    backgroundImage: project.teamMembers[i].avatarUrl.isNotEmpty
                                        ? NetworkImage(project.teamMembers[i].avatarUrl)
                                        : null,
                                    onBackgroundImageError: (error, stackTrace) {},
                                    child: project.teamMembers[i].avatarUrl.isEmpty
                                        ? Text(
                                            project.teamMembers[i].name.isNotEmpty
                                                ? project.teamMembers[i].name[0].toUpperCase()
                                                : '?',
                                            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textColorSecondary),
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                            if (project.teamMembers.length > 4 || (project.membersCount != null && project.membersCount! > project.teamMembers.length))
                              Positioned(
                                left: (project.teamMembers.length > 4 ? 4 : project.teamMembers.length) * 20.0,
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: AppColors.slate100,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                  alignment: Alignment.center,
                                  child: AppText(
                                    '+${(project.membersCount ?? project.teamMembers.length) - (project.teamMembers.length > 4 ? 4 : project.teamMembers.length)}',
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textColorSecondary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    // Calendar and end date tag
                    Row(
                      children: [
                        const Icon(Iconsax.calendar, size: 14, color: AppColors.textColorHint),
                        const SizedBox(width: 4),
                        AppText(
                          _formatDate(project.endDate),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColorSecondary,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Progress Bar and text percentage
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
                    const SizedBox(width: 12),
                    AppText(
                      '${(progress * 100).toInt()}%',
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
        return AppColors.indigo500; // Violet/Indigo
      case 'mobile development':
        return AppColors.primaryColor; // Blue
      case 'software integration':
        return AppColors.warningColor; // Amber
      case 'digital marketing':
        return AppColors.successColor; // Emerald
      default:
        return AppColors.slate700;
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
        return Iconsax.category;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return AppColors.successColor; // Green
      case 'In Progress':
        return AppColors.primaryColor; // Blue
      case 'On Hold':
        return AppColors.warningColor; // Amber
      case 'Not Started':
        return AppColors.slate500; // Slate
      default:
        return AppColors.primaryColor;
    }
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
