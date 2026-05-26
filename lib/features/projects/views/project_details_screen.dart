import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../role_permissions/models/role_permission_models.dart';
import '../controllers/projects_controller.dart';
import '../models/project_model.dart';
import 'create_project_screen.dart';

class ProjectDetailsScreen extends StatelessWidget {
  const ProjectDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProjectsController>();

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
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              'Project Details',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textColorPrimary,
            ),
            AppText(
              'Track progress and allocations',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textColorHint,
            ),
          ],
        ),
        actions: [
          Obx(() {
            final project = controller.selectedProject.value;
            if (project == null) return const SizedBox();
            return PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded, color: AppColors.textColorHint),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onSelected: (val) {
                if (val == 'edit') {
                  controller.populateForm(project);
                  Get.to(() => const CreateProjectScreen(isEditMode: true));
                } else if (val == 'delete') {
                  _showDeleteConfirm(context, controller, project.id);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Iconsax.edit, size: 16, color: AppColors.textColorSecondary),
                      SizedBox(width: 8),
                      AppText('Edit Project', fontSize: 13, fontWeight: FontWeight.w500),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Iconsax.trash, size: 16, color: Colors.redAccent),
                      SizedBox(width: 8),
                      AppText('Delete', fontSize: 13, fontWeight: FontWeight.w500, color: Colors.redAccent),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
      body: Obx(() {
        final p = controller.selectedProject.value;
        if (p == null) {
          return const Center(child: AppText('No project details found'));
        }

        final progress = p.progressPercentage;

        return Column(
          children: [
            // ── Header Summary Card ──
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.slate200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.01),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Iconsax.folder_open, color: AppColors.primaryColor, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(p.name, fontSize: 16, fontWeight: FontWeight.bold),
                              AppText(p.category, fontSize: 11, color: AppColors.textColorHint),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.successColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const AppText(
                            'In Progress',
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: AppColors.successColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Divider(height: 1, color: AppColors.slate100),
                    const SizedBox(height: 14),

                    // Metrics: Start Date, End Date, Progress %
                    Row(
                      children: [
                        _buildMetricCol('Start Date', _formatDate(p.startDate)),
                        _buildVerticalDivider(),
                        _buildMetricCol('End Date', _formatDate(p.endDate)),
                        _buildVerticalDivider(),
                        Expanded(
                          child: Column(
                            children: [
                              AppText('${(progress * 100).toInt()}%', fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                              const SizedBox(height: 4),
                              const AppText('Progress', fontSize: 10, color: AppColors.textColorHint),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Tab Selection Bar ──
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
              child: SizedBox(
                height: 40,
                child: Obx(() {
                  final currentIdx = controller.selectedDetailsTabIdx.value;
                  final tabs = [
                    {'label': 'Overview', 'icon': Iconsax.category},
                    {'label': 'Tasks', 'icon': Iconsax.task_square},
                    {'label': 'Team', 'icon': Iconsax.people},
                    {'label': 'Files', 'icon': Iconsax.document_text},
                    {'label': 'Timeline', 'icon': Iconsax.calendar},
                  ];

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: tabs.length,
                    itemBuilder: (context, idx) {
                      final isSelected = currentIdx == idx;
                      final tab = tabs[idx];
                      final String label = tab['label'] as String;
                      final IconData icon = tab['icon'] as IconData;

                      return GestureDetector(
                        onTap: () => controller.selectedDetailsTabIdx.value = idx,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
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
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                icon,
                                size: 14,
                                color: isSelected ? Colors.white : AppColors.textColorSecondary,
                              ),
                              const SizedBox(width: 6),
                              AppText(
                                label,
                                fontSize: 11,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                color: isSelected ? Colors.white : AppColors.textColorSecondary,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ),

            // ── Tab Views ──
            Expanded(
              child: Obx(() {
                final idx = controller.selectedDetailsTabIdx.value;
                switch (idx) {
                  case 0:
                    return _OverviewTab(project: p);
                  case 1:
                    return _TasksTab(project: p);
                  case 2:
                    return _TeamTab(project: p);
                  case 3:
                    return _FilesTab(project: p);
                  case 4:
                    return _TimelineTab(project: p);
                  default:
                    return _OverviewTab(project: p);
                }
              }),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildMetricCol(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          AppText(value, fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
          const SizedBox(height: 4),
          AppText(label, fontSize: 10, color: AppColors.textColorHint),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(width: 1, height: 28, color: const Color(0xFFE2E8F0));
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _showDeleteConfirm(BuildContext context, ProjectsController controller, String id) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const AppText('Delete Project', fontSize: 16, fontWeight: FontWeight.bold),
        content: const AppText('Are you sure you want to delete this project permanently? All tasks and attachments will be lost.', fontSize: 13),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const AppText('Cancel', color: AppColors.textColorSecondary, fontWeight: FontWeight.w600),
          ),
          ElevatedButton(
            onPressed: () {
              controller.deleteProject(id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const AppText('Delete', color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// ── OVERVIEW TAB ─────────────────────────────────────────────────────────────
class _OverviewTab extends StatelessWidget {
  final Project project;
  const _OverviewTab({required this.project});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProjectsController>();
    final done = project.tasks.where((t) => t.status == 'Done').length;
    final inProgress = project.tasks.where((t) => t.status == 'In Progress').length;
    final pending = project.tasks.where((t) => t.status == 'To Do' || t.status == 'Review').length;
    final total = project.tasks.length;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project Description
          const AppText('Description', fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.slate200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.01),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  project.description,
                  fontSize: 12,
                  color: AppColors.textColorSecondary,
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {},
                  child: const AppText(
                    'Show more',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Team members row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AppText('Team Members', fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
            ],
          ),
          const SizedBox(height: 10),
          _buildTeamStack(context, controller, project),
          const SizedBox(height: 24),

          // Project Status timeline track (Not Started -> In Progress -> Completed)
          const AppText('Project Status Track', fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.slate200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.01),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildStatusTimelineNode(
                  'Not Started',
                  project.status == 'In Progress' || project.status == 'Completed',
                  project.status == 'Not Started',
                ),
                _buildStatusTimelineLine(project.status == 'In Progress' || project.status == 'Completed'),
                _buildStatusTimelineNode(
                  'In Progress',
                  project.status == 'Completed',
                  project.status == 'In Progress',
                ),
                _buildStatusTimelineLine(project.status == 'Completed'),
                _buildStatusTimelineNode(
                  'Completed',
                  project.status == 'Completed',
                  project.status == 'Completed',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Tasks Analytics Donut representation
          const AppText('Tasks Overview', fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.slate200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.01),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Mock chart representation
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 90,
                      height: 90,
                      child: CircularProgressIndicator(
                        value: total > 0 ? done / total : 0.0,
                        strokeWidth: 8,
                        backgroundColor: AppColors.slate100,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.successColor),
                      ),
                    ),
                    SizedBox(
                      width: 70,
                      height: 70,
                      child: CircularProgressIndicator(
                        value: total > 0 ? inProgress / total : 0.0,
                        strokeWidth: 6,
                        backgroundColor: Colors.transparent,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppText('$total', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
                        const AppText('Tasks', fontSize: 8, color: AppColors.textColorHint, fontWeight: FontWeight.bold),
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBulletMetric('Completed', done, AppColors.successColor, total),
                      const SizedBox(height: 10),
                      _buildBulletMetric('In Progress', inProgress, AppColors.primaryColor, total),
                      const SizedBox(height: 10),
                      _buildBulletMetric('Pending', pending, AppColors.warningColor, total),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamStack(BuildContext context, ProjectsController controller, Project project) {
    const maxVisible = 5;
    final members = project.teamMembers;
    final displayCount = members.length > maxVisible ? maxVisible : members.length;
    final remaining = members.length - displayCount;

    return Row(
      children: [
        if (members.isEmpty)
          const AppText('No team members', fontSize: 12, color: AppColors.textColorHint)
        else
          SizedBox(
            height: 36,
            width: (displayCount * 26.0) + (remaining > 0 ? 36.0 : 10.0),
            child: Stack(
              children: [
                for (int i = 0; i < displayCount; i++)
                  Positioned(
                    left: i * 22.0,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 16,
                        backgroundImage: NetworkImage(members[i].avatarUrl),
                      ),
                    ),
                  ),
                if (remaining > 0)
                  Positioned(
                    left: displayCount * 22.0,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.slate100,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.slate300,
                        child: AppText(
                          '+$remaining',
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColorSecondary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => _showAddMemberSheet(context, controller, project),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Iconsax.user_add, size: 14, color: AppColors.primaryColor),
                SizedBox(width: 6),
                AppText(
                  'Add Member',
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusTimelineNode(String label, bool isDone, bool isActive) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive 
                ? AppColors.primaryColor.withValues(alpha: 0.12) 
                : (isDone ? AppColors.successColor.withValues(alpha: 0.08) : Colors.transparent),
          ),
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive 
                  ? AppColors.primaryColor 
                  : (isDone ? AppColors.successColor : Colors.white),
              border: Border.all(
                color: isActive 
                    ? AppColors.primaryColor 
                    : (isDone ? AppColors.successColor : AppColors.slate200),
                width: 2,
              ),
              boxShadow: isActive ? [
                BoxShadow(
                  color: AppColors.primaryColor.withValues(alpha: 0.25),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                )
              ] : null,
            ),
            child: Icon(
              isDone ? Icons.check : Icons.circle,
              color: isDone ? Colors.white : (isActive ? Colors.white : AppColors.slate300),
              size: 10,
            ),
          ),
        ),
        const SizedBox(height: 6),
        AppText(
          label,
          fontSize: 10,
          fontWeight: (isActive || isDone) ? FontWeight.bold : FontWeight.w600,
          color: isActive 
              ? AppColors.primaryColor 
              : (isDone ? AppColors.successColor : AppColors.slate500),
        ),
      ],
    );
  }

  Widget _buildStatusTimelineLine(bool isDone) {
    return Expanded(
      child: Container(
        height: 3,
        decoration: BoxDecoration(
          color: isDone ? AppColors.successColor : AppColors.slate200,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildBulletMetric(String label, int count, Color color, int total) {
    final pct = total > 0 ? ((count / total) * 100).toInt() : 0;
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: AppText(
            label,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textColorSecondary,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(6),
          ),
          child: AppText(
            '$count ($pct%)',
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  void _showAddMemberSheet(BuildContext context, ProjectsController controller, Project p) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: const BoxDecoration(color: AppColors.slate300, borderRadius: BorderRadius.all(Radius.circular(10))),
              ),
            ),
            const SizedBox(height: 18),
            const AppText('Add Team Members', fontSize: 15, fontWeight: FontWeight.bold),
            const SizedBox(height: 14),
            Expanded(
              child: ListView.builder(
                itemCount: controller.allEmployees.length,
                itemBuilder: (context, idx) {
                  final emp = controller.allEmployees[idx];
                  final isAssigned = p.teamMembers.contains(emp);
                  return ListTile(
                    leading: CircleAvatar(backgroundImage: NetworkImage(emp.avatarUrl)),
                    title: AppText(emp.name, fontSize: 13, fontWeight: FontWeight.bold),
                    subtitle: AppText(emp.email, fontSize: 10, color: AppColors.textColorHint),
                    trailing: isAssigned
                        ? const Icon(Icons.check_circle, color: AppColors.primaryColor)
                        : IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: AppColors.primaryColor),
                            onPressed: () {
                              controller.assignMembersToProject([emp]);
                              Get.back();
                            },
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── TASKS TAB ────────────────────────────────────────────────────────────────
class _TasksTab extends StatelessWidget {
  final Project project;
  const _TasksTab({required this.project});

  Color _getCategoryColor(String cat) {
    switch (cat.toLowerCase()) {
      case 'design':
        return AppColors.indigo500; // Violet/Indigo
      case 'development':
      case 'dev':
        return AppColors.primaryColor; // Blue
      case 'testing':
      case 'test':
        return AppColors.successColor; // Emerald
      default:
        return AppColors.slate500; // Slate
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProjectsController>();
    final taskTabs = ['All', 'To Do', 'In Progress', 'Done'];
    final selectedSubTab = 'All'.obs;

    return Column(
      children: [
        // Sub-filter tabs inside tasks list
        Container(
          color: Colors.white,
          height: 52,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: taskTabs.length,
            itemBuilder: (context, index) {
              final subTab = taskTabs[index];
              return Obx(() {
                final isSelected = selectedSubTab.value == subTab;
                return GestureDetector(
                  onTap: () => selectedSubTab.value = subTab,
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
                      subTab,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.textColorSecondary,
                    ),
                  ),
                );
              });
            },
          ),
        ),

        // Task Items list
        Expanded(
          child: Obx(() {
            final filter = selectedSubTab.value;
            final tList = project.tasks.where((t) {
              if (filter == 'All') return true;
              return t.status == filter;
            }).toList();

            if (tList.isEmpty) {
              return const Center(child: AppText('No tasks in this category', fontSize: 12, color: AppColors.textColorHint));
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: tList.length,
              separatorBuilder: (context, idx) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final task = tList[index];
                final isDone = task.status == 'Done';
                final categoryColor = _getCategoryColor(task.category);

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.slate200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.01),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Custom premium Checkbox click changes state
                      GestureDetector(
                        onTap: () {
                          if (isDone) {
                            controller.changeTaskStatus(task.id, 'In Progress');
                          } else {
                            controller.changeTaskStatus(task.id, 'Done');
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDone ? AppColors.primaryColor : Colors.white,
                            border: Border.all(
                              color: isDone ? AppColors.primaryColor : AppColors.slate300,
                              width: 2,
                            ),
                            boxShadow: isDone ? [
                              BoxShadow(
                                color: AppColors.primaryColor.withValues(alpha: 0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ] : null,
                          ),
                          child: isDone
                              ? const Icon(Icons.check, size: 14, color: Colors.white)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              task.title,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isDone ? AppColors.textColorHint : AppColors.textColorPrimary,
                              decoration: isDone ? TextDecoration.lineThrough : null,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: categoryColor.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: AppText(
                                    task.category, 
                                    fontSize: 9, 
                                    fontWeight: FontWeight.bold, 
                                    color: categoryColor,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Icon(Iconsax.calendar, size: 12, color: AppColors.textColorHint),
                                const SizedBox(width: 4),
                                AppText('Due ${task.dueDate.day}/${task.dueDate.month}', fontSize: 10, color: AppColors.textColorHint),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (task.assignee != null)
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.slate100, width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 14,
                            backgroundImage: NetworkImage(task.assignee!.avatarUrl),
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          }),
        ),

        // "+ Add Task" capsule action button
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: SafeArea(
            top: false,
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => _showAddTaskSheet(context, controller, project),
                icon: const Icon(Iconsax.add, size: 16, color: Colors.white),
                label: const AppText('Add Task', fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor, // Premium Blue
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showAddTaskSheet(BuildContext context, ProjectsController controller, Project p) {
    final titleField = TextEditingController();
    final RxString cat = 'Design'.obs;
    final Rxn<AppUser> assignee = Rxn<AppUser>();
    if (p.teamMembers.isNotEmpty) assignee.value = p.teamMembers.first;

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: const BoxDecoration(color: AppColors.slate300, borderRadius: BorderRadius.all(Radius.circular(10))),
                ),
              ),
              const SizedBox(height: 18),
              const AppText('Assign New Task', fontSize: 15, fontWeight: FontWeight.bold),
              const SizedBox(height: 14),
              TextField(
                controller: titleField,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Enter task title',
                  hintStyle: const TextStyle(color: AppColors.textColorHint, fontSize: 13),
                  filled: true,
                  fillColor: AppColors.slate50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 14),

              // Category row
              const AppText('Category', fontSize: 12, fontWeight: FontWeight.bold),
              const SizedBox(height: 6),
              Row(
                children: ['Design', 'Development', 'Testing'].map((c) {
                  return Obx(() {
                    final selected = cat.value == c;
                    return GestureDetector(
                      onTap: () => cat.value = c,
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.primaryColor : AppColors.slate100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: AppText(c, fontSize: 11, fontWeight: FontWeight.bold, color: selected ? Colors.white : AppColors.textColorSecondary),
                      ),
                    );
                  });
                }).toList(),
              ),
              const SizedBox(height: 14),

              // Assignee drop-down
              const AppText('Assign Employee', fontSize: 12, fontWeight: FontWeight.bold),
              const SizedBox(height: 6),
              Obx(() {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: AppColors.slate50, borderRadius: BorderRadius.circular(10)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<AppUser>(
                      value: assignee.value,
                      isExpanded: true,
                      dropdownColor: Colors.white,
                      items: p.teamMembers.map((m) {
                        return DropdownMenuItem<AppUser>(
                          value: m,
                          child: AppText(m.name, fontSize: 12),
                        );
                      }).toList(),
                      onChanged: (val) => assignee.value = val,
                    ),
                  ),
                );
              }),
              const SizedBox(height: 20),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    if (titleField.text.trim().isEmpty) return;
                    controller.addTaskToProject(
                      titleField.text.trim(),
                      cat.value,
                      assignee.value,
                      DateTime.now().add(const Duration(days: 7)),
                    );
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor, elevation: 0),
                  child: const AppText('Assign Task', color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── TEAM ROSTER TAB ──────────────────────────────────────────────────────────
class _TeamTab extends StatelessWidget {
  final Project project;
  const _TeamTab({required this.project});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProjectsController>();

    if (project.teamMembers.isEmpty) {
      return const Center(
        child: AppText('No team members assigned', fontSize: 12, color: AppColors.textColorHint),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: project.teamMembers.length,
      separatorBuilder: (context, idx) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final emp = project.teamMembers[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.slate200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.01),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryLight, width: 3),
                ),
                child: CircleAvatar(
                  radius: 22,
                  backgroundImage: NetworkImage(emp.avatarUrl),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(emp.name, fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Iconsax.sms, size: 12, color: AppColors.textColorHint),
                        const SizedBox(width: 6),
                        Expanded(
                          child: AppText(
                            emp.email,
                            fontSize: 10,
                            color: AppColors.textColorHint,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Get.snackbar('Message', 'Opening chat with ${emp.name}', snackPosition: SnackPosition.BOTTOM);
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Iconsax.sms, color: AppColors.primaryColor, size: 16),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => controller.removeMember(emp),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.errorColorAccent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.close_rounded, color: AppColors.errorColor, size: 16),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── FILES TAB ────────────────────────────────────────────────────────────────
class _FilesTab extends StatelessWidget {
  final Project project;
  const _FilesTab({required this.project});

  @override
  Widget build(BuildContext context) {
    if (project.files.isEmpty) {
      return const Center(child: AppText('No attached documents found', fontSize: 12, color: AppColors.textColorHint));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: project.files.length,
      separatorBuilder: (context, idx) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final file = project.files[index];

        Color accentColor;
        Color bgColor;
        IconData fileIcon;

        switch (file.type.toUpperCase()) {
          case 'PDF':
            accentColor = AppColors.errorColor; // Crimson Red
            bgColor = AppColors.errorColorAccent;
            fileIcon = Iconsax.document_text;
            break;
          case 'FIG':
          case 'FIGMA':
            accentColor = AppColors.indigo500; // Violet/Purple
            bgColor = AppColors.indigo500.withValues(alpha: 0.1);
            fileIcon = Iconsax.bezier;
            break;
          case 'PNG':
          case 'JPG':
          case 'JPEG':
          case 'IMAGE':
            accentColor = AppColors.infoColor; // Azure/Blue
            bgColor = AppColors.infoColor.withValues(alpha: 0.1);
            fileIcon = Iconsax.image;
            break;
          default:
            accentColor = AppColors.slate500; // Slate Grey
            bgColor = AppColors.slate100;
            fileIcon = Iconsax.document;
        }

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.slate200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.01),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(fileIcon, color: accentColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(file.name, fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.slate100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: AppText(
                            file.type.toUpperCase(),
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColorSecondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        AppText(
                          '${file.sizeMb} MB',
                          fontSize: 10,
                          color: AppColors.textColorHint,
                          fontWeight: FontWeight.w500,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Get.snackbar('Downloading', 'Saved ${file.name} to device storage', snackPosition: SnackPosition.BOTTOM);
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Iconsax.import, color: AppColors.primaryColor, size: 18),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── TIMELINE TAB ─────────────────────────────────────────────────────────────
class _TimelineTab extends StatelessWidget {
  final Project project;
  const _TimelineTab({required this.project});

  @override
  Widget build(BuildContext context) {
    if (project.timeline.isEmpty) {
      return const Center(child: AppText('No milestones established', fontSize: 12, color: AppColors.textColorHint));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: project.timeline.length,
      itemBuilder: (context, index) {
        final event = project.timeline[index];
        final isLast = index == project.timeline.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vertical timeline dot and line connectors
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: event.isCompleted 
                        ? AppColors.successColor.withValues(alpha: 0.15) 
                        : AppColors.slate100,
                  ),
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: event.isCompleted ? AppColors.successColor : Colors.white,
                      border: Border.all(
                        color: event.isCompleted ? AppColors.successColor : AppColors.slate300,
                        width: 2,
                      ),
                    ),
                    child: event.isCompleted
                        ? const Icon(Icons.check, size: 10, color: Colors.white)
                        : null,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 60,
                    decoration: BoxDecoration(
                      color: event.isCompleted ? AppColors.successColor : AppColors.slate200,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),

            // Text descriptions in modern cards
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.slate200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.01),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: AppText(
                            event.title,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: event.isCompleted ? AppColors.textColorPrimary : AppColors.textColorSecondary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: event.isCompleted 
                                ? AppColors.successColor.withValues(alpha: 0.08)
                                : AppColors.slate100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: AppText(
                            event.isCompleted ? 'Completed' : 'Pending',
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: event.isCompleted 
                                ? AppColors.successColor 
                                : AppColors.slate500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    AppText(
                      event.subtitle,
                      fontSize: 11,
                      color: AppColors.textColorHint,
                      fontWeight: FontWeight.w500,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
