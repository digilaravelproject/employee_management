import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/controllers/app_controller.dart';
import '../controllers/projects_controller.dart';
import '../models/project_model.dart';
import 'create_project_screen.dart';
import 'project_details_screen.dart';

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
            AppText(
              'Manage all projects',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textColorHint,
            ),
          ],
        ),
        actions: [
          Obx(() {
            final appController = Get.isRegistered<AppController>() ? Get.find<AppController>() : null;
            final isEmployee = appController?.userRole.value.toLowerCase() == 'employee';
            if (isEmployee) return const SizedBox.shrink();

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
                    onChanged: (value) => controller.searchQuery.value = value,
                    decoration: InputDecoration(
                      hintText: 'Search projects...',
                      hintStyle: const TextStyle(color: AppColors.textColorHint, fontSize: 13),
                      prefixIcon: const Icon(Iconsax.search_normal, color: AppColors.textColorHint, size: 18),
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
              final list = controller.filteredProjects;
              if (list.isEmpty) {
                return Center(
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
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                physics: const BouncingScrollPhysics(),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final p = list[index];
                  return _ProjectCard(project: p);
                },
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
            Get.to(() => const ProjectDetailsScreen());
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
                                    backgroundImage: NetworkImage(project.teamMembers[i].avatarUrl),
                                  ),
                                ),
                              ),
                            if (project.teamMembers.length > 4)
                              Positioned(
                                left: 4 * 20.0,
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
                                    '+${project.teamMembers.length - 4}',
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
