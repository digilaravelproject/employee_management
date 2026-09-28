import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/controllers/app_controller.dart';
import '../../role_permissions/models/role_permission_models.dart';
import '../../tasks/controllers/tasks_controller.dart';
import '../../tasks/models/task_model.dart';
import '../../tasks/views/task_details_screen.dart';
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
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textColorPrimary, size: 18),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              'Project Workspace',
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.textColorPrimary,
            ),
            AppText(
              'Jira tracking, modules & timesheets',
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
            final appController = Get.isRegistered<AppController>() ? Get.find<AppController>() : null;
            final isEmployee = appController?.userRole.value.toLowerCase() == 'employee';
            if (isEmployee) return const SizedBox();

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
            // ── Jira-Style Header Summary Card ──
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
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
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
                          child: const Icon(Iconsax.briefcase, color: AppColors.primaryColor, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(p.name, fontSize: 16, fontWeight: FontWeight.bold),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.slate100,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: AppText(p.category, fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textColorSecondary),
                                  ),
                                  const SizedBox(width: 8),
                                  AppText('${p.modules.length} Modules', fontSize: 10, color: AppColors.textColorHint, fontWeight: FontWeight.w500),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.successColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: AppText(
                            p.status,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.successColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Divider(height: 1, color: AppColors.slate100),
                    const SizedBox(height: 12),

                    // Metrics: Total Tasks, Modules, Progress
                    Row(
                      children: [
                        _buildMetricCol('Tasks', '${p.tasks.length}', Iconsax.task),
                        _buildVerticalDivider(),
                        _buildMetricCol('Modules', '${p.modules.length}', Iconsax.hierarchy_2),
                        _buildVerticalDivider(),
                        _buildMetricCol('Team', '${p.teamMembers.length}', Iconsax.people),
                        _buildVerticalDivider(),
                        Expanded(
                          child: Column(
                            children: [
                              AppText('${(progress * 100).toInt()}%', fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                              const SizedBox(height: 4),
                              const AppText('Done', fontSize: 10, color: AppColors.textColorHint),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Clean Jira Tab Selection Bar ──
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: SizedBox(
                height: 40,
                child: Obx(() {
                  final currentIdx = controller.selectedDetailsTabIdx.value;
                  final tabs = [
                    {'label': 'Board & Tasks', 'icon': Iconsax.task_square},
                    {'label': 'Modules', 'icon': Iconsax.hierarchy_2},
                    {'label': 'Timesheet', 'icon': Iconsax.timer_1},
                    {'label': 'Activity', 'icon': Iconsax.clock},
                    {'label': 'Team', 'icon': Iconsax.people},
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
                                blurRadius: 6,
                                offset: const Offset(0, 2),
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
                    return _JiraBoardTab(project: p);
                  case 1:
                    return _ModulesTab(project: p);
                  case 2:
                    return _TimesheetTab(project: p);
                  case 3:
                    return _ProjectActivityTab(project: p);
                  case 4:
                    return _TeamTab(project: p);
                  default:
                    return _JiraBoardTab(project: p);
                }
              }),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildMetricCol(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 13, color: AppColors.textColorSecondary),
              const SizedBox(width: 4),
              AppText(value, fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
            ],
          ),
          const SizedBox(height: 3),
          AppText(label, fontSize: 10, color: AppColors.textColorHint),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(width: 1, height: 24, color: AppColors.slate200);
  }

  void _showDeleteConfirm(BuildContext context, ProjectsController controller, String id) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const AppText('Delete Project', fontSize: 16, fontWeight: FontWeight.bold),
        content: const AppText('Are you sure you want to delete this project permanently? All tasks and timesheet data will be lost.', fontSize: 13),
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

// ─────────────────────────────────────────────────────────────────────────────
// 1. JIRA BOARD & TASKS TAB (With Modules, Sub-modules & Past Work Access)
// ─────────────────────────────────────────────────────────────────────────────
class _JiraBoardTab extends StatelessWidget {
  final Project project;
  const _JiraBoardTab({required this.project});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'done':
      case 'completed':
        return AppColors.successColor;
      case 'in progress':
      case 'inprogress':
        return AppColors.primaryColor;
      case 'testing':
      case 'review':
        return const Color(0xFF6366F1);
      case 'to do':
      default:
        return AppColors.slate500;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProjectsController>();
    final taskTabs = ['All', 'To Do', 'In Progress', 'Testing', 'Done'];
    final selectedSubTab = 'All'.obs;

    return Column(
      children: [
        // Sub-filter tabs inside tasks list
        Container(
          color: Colors.white,
          height: 48,
          padding: const EdgeInsets.symmetric(vertical: 6),
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
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryColor : AppColors.slate100,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? AppColors.primaryColor : AppColors.slate200,
                        width: 1.0,
                      ),
                    ),
                    child: AppText(
                      subTab,
                      fontSize: 11,
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
              if (filter == 'Done') return t.status == 'Done' || t.status == 'Completed';
              if (filter == 'Testing') return t.status == 'Testing' || t.status == 'Review';
              return t.status == filter;
            }).toList();

            if (tList.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Iconsax.task_square, size: 40, color: AppColors.textColorHint.withValues(alpha: 0.4)),
                    const SizedBox(height: 10),
                    const AppText('No tasks in this status filter', fontSize: 13, color: AppColors.textColorHint),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: tList.length,
              separatorBuilder: (context, idx) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final task = tList[index];
                final isDone = task.status == 'Done' || task.status == 'Completed';
                final statusColor = _getStatusColor(task.status);

                return GestureDetector(
                  onTap: () {
                    // Open full Task Details Screen
                    if (Get.isRegistered<TasksController>()) {
                      final tasksCtrl = Get.find<TasksController>();
                      final matched = tasksCtrl.tasks.firstWhereOrNull((t) => t.id == task.id || t.title == task.title);
                      if (matched != null) {
                        tasksCtrl.selectTask(matched);
                        Get.to(() => const TaskDetailsScreen());
                      }
                    }
                  },
                  child: Container(
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
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status toggle circle
                        GestureDetector(
                          onTap: () {
                            if (isDone) {
                              controller.changeTaskStatus(task.id, 'In Progress');
                            } else {
                              controller.changeTaskStatus(task.id, 'Done');
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.only(top: 2),
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDone ? AppColors.successColor : Colors.white,
                              border: Border.all(
                                color: isDone ? AppColors.successColor : AppColors.slate300,
                                width: 1.8,
                              ),
                            ),
                            child: isDone
                                ? const Icon(Icons.check, size: 12, color: Colors.white)
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
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
                              // Module and Sub-module breadcrumbs badge
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Iconsax.hierarchy_2, size: 10, color: AppColors.primaryColor),
                                        const SizedBox(width: 4),
                                        AppText(
                                          task.moduleName.isNotEmpty ? task.moduleName : 'General',
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primaryColor,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: AppText(
                                      task.status,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: statusColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (task.assignee != null)
                          Tooltip(
                            message: 'Assigned to ${task.assignee!.name}',
                            child: CircleAvatar(
                              radius: 13,
                              backgroundImage: NetworkImage(task.assignee!.avatarUrl),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ),

        // "+ Add Task" button (Admin / Manager only)
        Obx(() {
          final appController = Get.isRegistered<AppController>() ? Get.find<AppController>() : null;
          final isEmployee = appController?.userRole.value.toLowerCase() == 'employee';
          if (isEmployee) return const SizedBox.shrink();

          return Container(
            color: Colors.white,
            padding: const EdgeInsets.all(14),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: () => _showAddTaskSheet(context, controller, project),
                  icon: const Icon(Iconsax.add, size: 16, color: Colors.white),
                  label: const AppText('Add Task to Project', fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  void _showAddTaskSheet(BuildContext context, ProjectsController controller, Project p) {
    final titleField = TextEditingController();
    final RxString selectedMod = (p.modules.isNotEmpty ? p.modules.first.name : 'General').obs;
    final RxString selectedSub = 'Default'.obs;
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
              const SizedBox(height: 16),
              const AppText('Assign New Task (Jira Module)', fontSize: 15, fontWeight: FontWeight.bold),
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

              // Module Selector
              const AppText('Module', fontSize: 12, fontWeight: FontWeight.bold),
              const SizedBox(height: 6),
              Obx(() {
                final modNames = p.modules.isNotEmpty ? p.modules.map((m) => m.name).toList() : ['General'];
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: AppColors.slate50, borderRadius: BorderRadius.circular(10)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: modNames.contains(selectedMod.value) ? selectedMod.value : modNames.first,
                      isExpanded: true,
                      dropdownColor: Colors.white,
                      items: modNames.map((m) => DropdownMenuItem(value: m, child: AppText(m, fontSize: 12))).toList(),
                      onChanged: (val) {
                        if (val != null) selectedMod.value = val;
                      },
                    ),
                  ),
                );
              }),
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
                      'Development',
                      assignee.value,
                      DateTime.now().add(const Duration(days: 7)),
                      moduleName: selectedMod.value,
                      subModuleName: selectedSub.value,
                    );
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor, elevation: 0),
                  child: const AppText('Allocate Task', color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. MODULES & SUB-MODULES TAB (Jira Epics / Components Architecture)
// ─────────────────────────────────────────────────────────────────────────────
class _ModulesTab extends StatelessWidget {
  final Project project;
  const _ModulesTab({required this.project});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProjectsController>();
    final modules = project.modules;

    return Column(
      children: [
        Expanded(
          child: modules.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Iconsax.hierarchy_2, size: 44, color: AppColors.textColorHint.withValues(alpha: 0.4)),
                      const SizedBox(height: 10),
                      const AppText('No modules configured yet', fontSize: 13, fontWeight: FontWeight.bold),
                      const SizedBox(height: 4),
                      const AppText('Create modules to organize tasks Jira-style', fontSize: 11, color: AppColors.textColorHint),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: modules.length,
                  separatorBuilder: (context, idx) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final mod = modules[index];
                    final modTasks = project.tasks.where((t) => t.moduleName.toLowerCase().trim() == mod.name.toLowerCase().trim()).toList();
                    final doneTasks = modTasks.where((t) => t.status == 'Done' || t.status == 'Completed').length;
                    final progress = modTasks.isNotEmpty ? (doneTasks / modTasks.length) : 0.0;

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
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
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Iconsax.hierarchy_2, color: AppColors.primaryColor, size: 18),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppText(mod.name, fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
                                    if (mod.description.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      AppText(mod.description, fontSize: 10, color: AppColors.textColorHint),
                                    ],
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.slate100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: AppText(
                                  '${modTasks.length} Tasks',
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Progress line
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 5,
                              backgroundColor: AppColors.slate100,
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.successColor),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Sub-modules tags
                          if (mod.subModules.isNotEmpty) ...[
                            const AppText('Sub-Modules:', fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textColorSecondary),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: mod.subModules.map((sub) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.slate50,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: AppColors.slate200),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.subdirectory_arrow_right_rounded, size: 10, color: AppColors.textColorHint),
                                      const SizedBox(width: 4),
                                      AppText(sub.name, fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.textColorPrimary),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
        ),

        // "+ Add Module" action for Admin
        Obx(() {
          final appController = Get.isRegistered<AppController>() ? Get.find<AppController>() : null;
          final isEmployee = appController?.userRole.value.toLowerCase() == 'employee';
          if (isEmployee) return const SizedBox.shrink();

          return Container(
            color: Colors.white,
            padding: const EdgeInsets.all(14),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: () => _showAddModuleSheet(context, controller),
                  icon: const Icon(Iconsax.add, size: 16, color: Colors.white),
                  label: const AppText('Create New Module', fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  void _showAddModuleSheet(BuildContext context, ProjectsController controller) {
    final nameField = TextEditingController();
    final descField = TextEditingController();
    final subModulesField = TextEditingController();

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
              const SizedBox(height: 16),
              const AppText('Create Jira Module', fontSize: 15, fontWeight: FontWeight.bold),
              const SizedBox(height: 14),
              TextField(
                controller: nameField,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Module Name (e.g. Authentication & Security)',
                  hintStyle: const TextStyle(color: AppColors.textColorHint, fontSize: 12),
                  filled: true,
                  fillColor: AppColors.slate50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descField,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Description',
                  hintStyle: const TextStyle(color: AppColors.textColorHint, fontSize: 12),
                  filled: true,
                  fillColor: AppColors.slate50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: subModulesField,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Sub-modules (comma separated, e.g. Login, Signup, OTP)',
                  hintStyle: const TextStyle(color: AppColors.textColorHint, fontSize: 12),
                  filled: true,
                  fillColor: AppColors.slate50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    if (nameField.text.trim().isEmpty) return;
                    final subList = subModulesField.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
                    controller.addModuleToProject(nameField.text.trim(), descField.text.trim(), subList);
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor, elevation: 0),
                  child: const AppText('Save Module', color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. JIRA TIMESHEET & WORKLOG TAB (Admin & Manager Tracking by Member & Module)
// ─────────────────────────────────────────────────────────────────────────────
class _TimesheetTab extends StatelessWidget {
  final Project project;
  const _TimesheetTab({required this.project});

  String _formatSeconds(int secs) {
    final hours = secs ~/ 3600;
    final mins = (secs % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${mins}m';
    } else {
      return '${mins}m';
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasksController = Get.find<TasksController>();
    final mode = 'Members'.obs; // 'Members' vs 'Modules'

    return Column(
      children: [
        // Mode Switcher Header
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AppText('Jira Timesheet Report', fontSize: 13, fontWeight: FontWeight.bold),
              Obx(() {
                return Container(
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.slate100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: ['Members', 'Modules'].map((m) {
                      final isSelected = mode.value == m;
                      return GestureDetector(
                        onTap: () => mode.value = m,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primaryColor : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: AppText(
                            m,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : AppColors.textColorSecondary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              }),
            ],
          ),
        ),

        // Timesheet Content
        Expanded(
          child: Obx(() {
            // Read ticker for reactive updates
            tasksController.liveTicker.value;

            if (mode.value == 'Members') {
              final memberData = tasksController.getMemberProjectTimesheet(project.id);
              if (memberData.isEmpty) {
                return const Center(child: AppText('No team members in project', fontSize: 12, color: AppColors.textColorHint));
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: memberData.length,
                separatorBuilder: (context, idx) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = memberData[index];
                  final AppUser member = item['member'] as AppUser;
                  final int totalSecs = item['totalSeconds'] as int;
                  final Map<String, int> moduleHours = item['moduleHours'] as Map<String, int>;
                  final List<TaskTimeLog> worklogs = item['worklogs'] as List<TaskTimeLog>;

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
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
                        // Member Header Row
                        Row(
                          children: [
                            CircleAvatar(radius: 20, backgroundImage: NetworkImage(member.avatarUrl)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText(member.name, fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
                                  const SizedBox(height: 2),
                                  AppText(member.email, fontSize: 10, color: AppColors.textColorHint),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Iconsax.clock, size: 12, color: AppColors.primaryColor),
                                  const SizedBox(width: 4),
                                  AppText(
                                    _formatSeconds(totalSecs),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryColor,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1, color: AppColors.slate100),
                        const SizedBox(height: 10),

                        // Module breakdown pills for this member
                        const AppText('Modules Worked:', fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textColorSecondary),
                        const SizedBox(height: 6),
                        if (moduleHours.isEmpty)
                          const AppText('No time logged on modules yet', fontSize: 10, color: AppColors.textColorHint)
                        else
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: moduleHours.entries.map((entry) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.slate50,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.slate200),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    AppText(entry.key, fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.textColorPrimary),
                                    const SizedBox(width: 5),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: AppText(
                                        _formatSeconds(entry.value),
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),

                        // Worklogs history summary
                        if (worklogs.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          const AppText('Recent Work Sessions:', fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textColorSecondary),
                          const SizedBox(height: 6),
                          ...worklogs.take(3).map((log) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.circle, size: 6, color: AppColors.primaryColor),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: AppText(
                                                log.taskTitle.isNotEmpty ? log.taskTitle : 'Work Session',
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textColorPrimary,
                                              ),
                                            ),
                                            AppText(
                                              log.formattedDuration,
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primaryColor,
                                            ),
                                          ],
                                        ),
                                        if (log.note.isNotEmpty)
                                          AppText(
                                            log.note,
                                            fontSize: 9,
                                            color: AppColors.textColorHint,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
                  );
                },
              );
            } else {
              // Modules-wise Timesheet View
              final moduleData = tasksController.getModuleProjectTimesheet(project.id);
              if (moduleData.isEmpty) {
                return const Center(child: AppText('No modules to track', fontSize: 12, color: AppColors.textColorHint));
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: moduleData.length,
                separatorBuilder: (context, idx) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = moduleData[index];
                  final ProjectModule mod = item['module'] as ProjectModule;
                  final int totalSecs = item['totalSeconds'] as int;
                  final int tasksCount = item['tasksCount'] as int;
                  final Map<String, int> contributors = item['contributors'] as Map<String, int>;

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
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
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Iconsax.hierarchy_2, color: AppColors.primaryColor, size: 16),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        AppText(mod.name, fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
                                        AppText('$tasksCount Tasks in Module', fontSize: 10, color: AppColors.textColorHint),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.successColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: AppText(
                                _formatSeconds(totalSecs),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.successColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1, color: AppColors.slate100),
                        const SizedBox(height: 10),

                        const AppText('Member Hours Contributed:', fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textColorSecondary),
                        const SizedBox(height: 6),
                        if (contributors.isEmpty)
                          const AppText('No hours logged for this module yet', fontSize: 10, color: AppColors.textColorHint)
                        else
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: contributors.entries.map((c) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.slate50,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.slate200),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    AppText(c.key, fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.textColorPrimary),
                                    const SizedBox(width: 4),
                                    AppText(_formatSeconds(c.value), fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  );
                },
              );
            }
          }),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 4. PROJECT ACTIVITY & PAST WORK HISTORY TAB (Full Visibility for New Joiners)
// ─────────────────────────────────────────────────────────────────────────────
class _ProjectActivityTab extends StatelessWidget {
  final Project project;
  const _ProjectActivityTab({required this.project});

  @override
  Widget build(BuildContext context) {
    if (project.timeline.isEmpty) {
      return const Center(child: AppText('No past activity recorded', fontSize: 12, color: AppColors.textColorHint));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: project.timeline.length,
      itemBuilder: (context, index) {
        final event = project.timeline[index];
        final isLast = index == project.timeline.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: event.isCompleted ? AppColors.successColor.withValues(alpha: 0.15) : AppColors.slate100,
                  ),
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: event.isCompleted ? AppColors.successColor : Colors.white,
                      border: Border.all(
                        color: event.isCompleted ? AppColors.successColor : AppColors.slate300,
                        width: 2,
                      ),
                    ),
                    child: event.isCompleted ? const Icon(Icons.check, size: 9, color: Colors.white) : null,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 55,
                    decoration: BoxDecoration(
                      color: event.isCompleted ? AppColors.successColor : AppColors.slate200,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.slate200),
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
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: event.isCompleted ? AppColors.textColorPrimary : AppColors.textColorSecondary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: event.isCompleted ? AppColors.successColor.withValues(alpha: 0.08) : AppColors.slate100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: AppText(
                            event.isCompleted ? 'Completed' : 'Pending',
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: event.isCompleted ? AppColors.successColor : AppColors.slate500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    AppText(
                      event.subtitle,
                      fontSize: 10,
                      color: AppColors.textColorHint,
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

// ─────────────────────────────────────────────────────────────────────────────
// 5. TEAM ROSTER TAB (Add members with full past history access)
// ─────────────────────────────────────────────────────────────────────────────
class _TeamTab extends StatelessWidget {
  final Project project;
  const _TeamTab({required this.project});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProjectsController>();

    return Column(
      children: [
        Expanded(
          child: project.teamMembers.isEmpty
              ? const Center(child: AppText('No team members assigned', fontSize: 12, color: AppColors.textColorHint))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: project.teamMembers.length,
                  separatorBuilder: (context, idx) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final emp = project.teamMembers[index];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.slate200),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(radius: 20, backgroundImage: NetworkImage(emp.avatarUrl)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(emp.name, fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
                                const SizedBox(height: 2),
                                AppText(emp.email, fontSize: 10, color: AppColors.textColorHint),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => controller.removeMember(emp),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.errorColorAccent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.close_rounded, color: AppColors.errorColor, size: 14),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),

        // "+ Add Member" Button
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(14),
          child: SafeArea(
            top: false,
            child: SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                onPressed: () => _showAddMemberSheet(context, controller, project),
                icon: const Icon(Iconsax.user_add, size: 16, color: Colors.white),
                label: const AppText('Add Team Member to Project', fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
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
            const SizedBox(height: 16),
            const AppText('Add Team Member', fontSize: 15, fontWeight: FontWeight.bold),
            const SizedBox(height: 4),
            const AppText('New member will get complete access to past tasks and project work history.', fontSize: 11, color: AppColors.textColorHint),
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
