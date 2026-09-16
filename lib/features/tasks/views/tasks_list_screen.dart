import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/controllers/app_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/tasks_controller.dart';
import '../models/task_model.dart';
import 'create_task_screen.dart';
import 'task_details_screen.dart';

class TasksListScreen extends StatelessWidget {
  const TasksListScreen({super.key});

  Color _getPriorityColor(String prio) {
    switch (prio.toLowerCase()) {
      case 'high':
        return AppColors.errorColor;
      case 'medium':
        return AppColors.warningColor;
      case 'low':
        return AppColors.successColor;
      default:
        return AppColors.slate500;
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'done':
        return AppColors.successColor.withValues(alpha: 0.1);
      case 'in progress':
      case 'inprogress':
        return AppColors.primaryColor.withValues(alpha: 0.1);
      case 'testing':
      case 'review':
        return const Color(0xFF6366F1).withValues(alpha: 0.1); // Indigo
      case 'to do':
      case 'pending':
      default:
        return AppColors.slate100;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'done':
        return AppColors.successColor;
      case 'in progress':
      case 'inprogress':
        return AppColors.primaryColor;
      case 'testing':
      case 'review':
        return const Color(0xFF6366F1);
      case 'to do':
      case 'pending':
      default:
        return AppColors.slate500;
    }
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TasksController());
    final appController = Get.find<AppController>();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
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
        title: Obx(() {
          final role = appController.userRole.value.toLowerCase();
          final isEmployee = role == 'employee';
          final title = isEmployee ? 'My Tasks' : 'Tasks';
          String subtitle = 'Manage and track all tasks';
          if (role == 'admin') {
            subtitle = 'Admin Project & Task Oversight';
          } else if (role == 'manager') {
            subtitle = 'Team Workflow & Time Tracking';
          } else {
            subtitle = 'Your daily assigned tasks & work sessions';
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                title,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textColorPrimary,
              ),
              AppText(
                subtitle,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textColorHint,
              ),
            ],
          );
        }),
        actions: [
          // Role Switcher Pill
          Obx(() {
            final role = appController.userRole.value;
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: AppColors.slate100,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.slate200),
              ),
              child: PopupMenuButton<String>(
                tooltip: 'Switch Role View',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      role == 'admin'
                          ? Icons.admin_panel_settings_rounded
                          : role == 'manager'
                              ? Icons.manage_accounts_rounded
                              : Icons.person_rounded,
                      size: 14,
                      color: AppColors.primaryColor,
                    ),
                    const SizedBox(width: 4),
                    AppText(
                      role.capitalizeFirst ?? role,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                    const Icon(Icons.arrow_drop_down, size: 16, color: AppColors.textColorSecondary),
                  ],
                ),
                onSelected: (val) {
                  appController.setRole(val);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'admin',
                    child: Row(
                      children: [
                        Icon(Icons.admin_panel_settings_rounded, size: 16, color: Colors.purple),
                        SizedBox(width: 8),
                        AppText('Admin View (Create / Edit / Delete)', fontSize: 12),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'manager',
                    child: Row(
                      children: [
                        Icon(Icons.manage_accounts_rounded, size: 16, color: Colors.blue),
                        SizedBox(width: 8),
                        AppText('Manager View (Time Tracking & Review)', fontSize: 12),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'employee',
                    child: Row(
                      children: [
                        Icon(Icons.person_rounded, size: 16, color: Colors.teal),
                        SizedBox(width: 8),
                        AppText('Employee View (Live Timer & Tasks)', fontSize: 12),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          // ── KPI Summary Cards ──
          _buildKpiBar(controller, appController),

          // ── Search Section ──
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.slate100,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: TextField(
                      onChanged: (val) => controller.searchQuery.value = val,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Iconsax.search_normal_1, color: AppColors.textColorHint, size: 18),
                        hintText: appController.userRole.value.toLowerCase() == 'employee'
                            ? 'Search my tasks, projects...'
                            : 'Search tasks, projects, team...',
                        hintStyle: const TextStyle(color: AppColors.textColorHint, fontSize: 13),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Filter Sub-Tabs (Pills) ──
          Container(
            color: Colors.white,
            height: 48,
            padding: const EdgeInsets.only(bottom: 10),
            child: Obx(() {
              final currentFilter = controller.selectedFilter.value;
              final role = appController.userRole.value.toLowerCase();
              final isEmployee = role == 'employee';
              final filterOptions = isEmployee
                  ? ['All', 'To Do', 'In Progress', 'Testing', 'Completed']
                  : ['All', 'To Do', 'In Progress', 'Testing', 'Completed', 'Team Tracking'];

              if (!filterOptions.contains(currentFilter)) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  controller.selectedFilter.value = 'All';
                });
              }

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filterOptions.length,
                itemBuilder: (context, idx) {
                  final opt = filterOptions[idx];
                  final isSelected = currentFilter == opt;

                  return GestureDetector(
                    onTap: () => controller.selectedFilter.value = opt,
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
                          width: 1.2,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primaryColor.withValues(alpha: 0.15),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      child: AppText(
                        opt,
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.textColorSecondary,
                      ),
                    ),
                  );
                },
              );
            }),
          ),
          const Divider(height: 1, color: AppColors.dividerColor),

          // ── Content Feed: Tasks List OR Manager Team Tracking Overview ──
          Expanded(
            child: Obx(() {
              // Connect liveTicker to trigger rebuilds on timer ticks
              controller.liveTicker.value;

              final currentFilter = controller.selectedFilter.value;
              final isEmployee = appController.userRole.value.toLowerCase() == 'employee';

              if (!isEmployee && currentFilter == 'Team Tracking') {
                return _buildTeamTrackingView(context, controller);
              }

              final tList = controller.filteredTasks;
              if (tList.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Iconsax.task_square, size: 36, color: AppColors.primaryColor),
                      ),
                      const SizedBox(height: 12),
                      const AppText('No Tasks Found', fontSize: 14, fontWeight: FontWeight.bold),
                      const SizedBox(height: 4),
                      AppText(
                        isEmployee
                            ? 'No tasks assigned to you under this status.'
                            : 'Tasks for this filter will appear here.',
                        fontSize: 11,
                        color: AppColors.textColorHint,
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: tList.length,
                separatorBuilder: (context, idx) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final task = tList[index];
                  final prioColor = _getPriorityColor(task.priority);
                  final isAdmin = appController.userRole.value.toLowerCase() == 'admin';

                  return GestureDetector(
                    onTap: () {
                      controller.selectTask(task);
                      Get.to(() => const TaskDetailsScreen());
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: task.isTimerRunning ? AppColors.primaryColor : AppColors.slate200,
                          width: task.isTimerRunning ? 1.5 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: task.isTimerRunning
                                ? AppColors.primaryColor.withValues(alpha: 0.06)
                                : Colors.black.withValues(alpha: 0.01),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header line (Category/Title + Status badge + Trailing menu)
                          Row(
                            children: [
                              // Decorative category dot
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: prioColor,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: AppText(
                                  task.title,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textColorPrimary,
                                ),
                              ),

                              // Status Badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: _getStatusBgColor(task.normalizedStatus),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (task.isTimerRunning) ...[
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.primaryColor,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                    ],
                                    AppText(
                                      task.normalizedStatus,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: _getStatusTextColor(task.normalizedStatus),
                                    ),
                                  ],
                                ),
                              ),

                              // Popup Menu (Admin edit/delete & status update)
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert_rounded, color: AppColors.textColorHint, size: 18),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: EdgeInsets.zero,
                                onSelected: (val) {
                                  if (val == 'edit') {
                                    controller.populateTaskForm(task);
                                    Get.to(() => CreateTaskScreen(isEditMode: true, taskId: task.id));
                                  } else if (val == 'delete') {
                                    _showDeleteConfirm(context, controller, task.id);
                                  } else if (val == 'status') {
                                    controller.selectTask(task);
                                    _showStatusUpdateDialog(context, controller, task);
                                  }
                                },
                                itemBuilder: (context) => [
                                  if (isAdmin)
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Iconsax.edit, size: 14, color: AppColors.textColorSecondary),
                                          SizedBox(width: 8),
                                          AppText('Edit Task', fontSize: 12, fontWeight: FontWeight.w500),
                                        ],
                                      ),
                                    ),
                                  const PopupMenuItem(
                                    value: 'status',
                                    child: Row(
                                      children: [
                                        Icon(Iconsax.status, size: 14, color: AppColors.textColorSecondary),
                                        SizedBox(width: 8),
                                        AppText('Update Status', fontSize: 12, fontWeight: FontWeight.w500),
                                      ],
                                    ),
                                  ),
                                  if (isAdmin)
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(Iconsax.trash, size: 14, color: AppColors.errorColor),
                                          SizedBox(width: 8),
                                          AppText('Delete Task', fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.errorColor),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          // Description
                          AppText(
                            task.description,
                            fontSize: 11,
                            color: AppColors.textColorSecondary,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),

                          // Live Timer / Tracked Time Pill + Quick action bar
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: task.isTimerRunning
                                  ? AppColors.primaryLight
                                  : AppColors.slate50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Iconsax.clock,
                                  size: 14,
                                  color: task.isTimerRunning ? AppColors.primaryColor : AppColors.textColorHint,
                                ),
                                const SizedBox(width: 6),
                                AppText(
                                  task.isTimerRunning
                                      ? 'Active: ${task.formattedActiveTime}'
                                      : 'Tracked: ${task.formattedHumanTime}',
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: task.isTimerRunning ? AppColors.primaryColor : AppColors.textColorSecondary,
                                ),
                                const Spacer(),

                                // Quick Start / Pause buttons on card
                                if (task.normalizedStatus == TaskModel.statusToDo)
                                  GestureDetector(
                                    onTap: () => controller.startTaskTimer(task.id),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryColor,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.play_arrow_rounded, color: Colors.white, size: 14),
                                          SizedBox(width: 2),
                                          AppText('Start', fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                                        ],
                                      ),
                                    ),
                                  )
                                else if (task.normalizedStatus == TaskModel.statusInProgress)
                                  GestureDetector(
                                    onTap: () {
                                      if (task.isTimerRunning) {
                                        controller.pauseTaskTimer(task.id);
                                      } else {
                                        controller.startTaskTimer(task.id);
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: task.isTimerRunning ? const Color(0xFFF59E0B) : AppColors.primaryColor,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            task.isTimerRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                            color: Colors.white,
                                            size: 14,
                                          ),
                                          const SizedBox(width: 2),
                                          AppText(
                                            task.isTimerRunning ? 'Pause' : 'Resume',
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                else if (task.normalizedStatus == TaskModel.statusTesting)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const AppText('Under Review', fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6366F1)),
                                  )
                                else if (task.normalizedStatus == TaskModel.statusCompleted)
                                  const Icon(Icons.check_circle_rounded, size: 18, color: AppColors.successColor),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Divider(height: 1, color: AppColors.slate200),
                          const SizedBox(height: 10),

                          // Assignee + Date + Priority Badge Footer
                          Row(
                            children: [
                              if (task.assignees.isNotEmpty) ...[
                                CircleAvatar(
                                  radius: 11,
                                  backgroundImage: NetworkImage(task.assignees.first.avatarUrl),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: AppText(
                                    task.assignees.first.name,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textColorPrimary,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ] else ...[
                                const Expanded(
                                  child: AppText(
                                    'Unassigned',
                                    fontSize: 11,
                                    color: AppColors.textColorHint,
                                  ),
                                ),
                              ],
                              const Icon(Iconsax.calendar_1, size: 12, color: AppColors.textColorHint),
                              const SizedBox(width: 4),
                              AppText(
                                _formatDate(task.deadline),
                                fontSize: 10,
                                color: AppColors.textColorHint,
                                fontWeight: FontWeight.w500,
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: prioColor.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: AppText(
                                  task.priority,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: prioColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),

      // ── Floating / Bottom New Task button for Admin & Manager ──
      bottomNavigationBar: Obx(() {
        final role = appController.userRole.value.toLowerCase();
        if (role == 'employee') {
          // Employee doesn't need creation button pinned
          return const SizedBox.shrink();
        }

        return Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: SafeArea(
            top: false,
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  controller.clearCreationForm();
                  Get.to(() => const CreateTaskScreen());
                },
                icon: const Icon(Iconsax.add, size: 18, color: Colors.white),
                label: const AppText('Create New Task', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white, height: 1.1),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  // ── KPI Summary Bar at top ──
  Widget _buildKpiBar(TasksController controller, AppController appController) {
    return Obx(() {
      final role = appController.userRole.value.toLowerCase();
      final all = controller.tasks;

      if (role == 'manager') {
        // Manager metrics
        return Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              _buildKpiCard('Total Team Time', controller.formattedTotalTeamTime, Iconsax.clock, AppColors.primaryColor),
              const SizedBox(width: 8),
              _buildKpiCard('Live Timers', '${controller.activeRunningTasks.length}', Iconsax.play_cricle, Colors.amber.shade700),
              const SizedBox(width: 8),
              _buildKpiCard('In Testing', '${controller.testingTasks.length}', Iconsax.verify, const Color(0xFF6366F1)),
            ],
          ),
        );
      } else if (role == 'employee') {
        // Employee metrics
        final myTasks = controller.tasks.where((t) => t.assignees.any((a) => a.name == 'Sarah Johnson')).toList();
        final inProgress = myTasks.where((t) => t.normalizedStatus == TaskModel.statusInProgress).length;
        final completed = myTasks.where((t) => t.normalizedStatus == TaskModel.statusCompleted).length;

        return Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              _buildKpiCard('My Tasks', '${myTasks.length}', Iconsax.task, AppColors.primaryColor),
              const SizedBox(width: 8),
              _buildKpiCard('In Progress', '$inProgress', Iconsax.timer_1, Colors.amber.shade700),
              const SizedBox(width: 8),
              _buildKpiCard('Completed', '$completed', Iconsax.tick_circle, AppColors.successColor),
            ],
          ),
        );
      }

      // Admin metrics
      final inProgCount = all.where((t) => t.normalizedStatus == TaskModel.statusInProgress).length;
      final testingCount = all.where((t) => t.normalizedStatus == TaskModel.statusTesting).length;
      final doneCount = all.where((t) => t.normalizedStatus == TaskModel.statusCompleted).length;

      return Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            _buildKpiCard('Total Tasks', '${all.length}', Iconsax.task_square, AppColors.primaryColor),
            const SizedBox(width: 8),
            _buildKpiCard('In Progress', '$inProgCount', Iconsax.timer_1, Colors.amber.shade700),
            const SizedBox(width: 8),
            _buildKpiCard('In Testing', '$testingCount', Iconsax.verify, const Color(0xFF6366F1)),
            const SizedBox(width: 8),
            _buildKpiCard('Completed', '$doneCount', Iconsax.tick_circle, AppColors.successColor),
          ],
        ),
      );
    });
  }

  Widget _buildKpiCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppText(value, fontSize: 13, fontWeight: FontWeight.bold, color: color),
                  AppText(label, fontSize: 9, color: AppColors.textColorSecondary, maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Dedicated Manager Team Tracking View ──
  Widget _buildTeamTrackingView(BuildContext context, TasksController controller) {
    final timeMap = controller.employeeTimeSpentMap;
    final testingList = controller.testingTasks;
    final activeRunning = controller.activeRunningTasks;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Live Active Timers Section
          if (activeRunning.isNotEmpty) ...[
            const Row(
              children: [
                Icon(Icons.fiber_manual_record, color: Colors.green, size: 12),
                SizedBox(width: 6),
                AppText('Live Active Timers (Working Right Now)', fontSize: 13, fontWeight: FontWeight.bold),
              ],
            ),
            const SizedBox(height: 8),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activeRunning.length,
              separatorBuilder: (_, index) => const SizedBox(height: 8),
              itemBuilder: (context, idx) {
                final task = activeRunning[idx];
                final assignee = task.assignees.isNotEmpty ? task.assignees.first.name : 'Unknown';

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.timer_outlined, color: AppColors.primaryColor, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(task.title, fontSize: 12, fontWeight: FontWeight.bold),
                            AppText('$assignee • Active timer', fontSize: 10, color: AppColors.textColorSecondary),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: AppText(
                          task.formattedActiveTime,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],

          // Testing / QA Review Queue
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Iconsax.verify, color: Color(0xFF6366F1), size: 16),
                  const SizedBox(width: 6),
                  AppText('Testing / QA Queue (${testingList.length})', fontSize: 13, fontWeight: FontWeight.bold),
                ],
              ),
              if (testingList.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const AppText('Needs Review', fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF6366F1)),
                ),
            ],
          ),
          const SizedBox(height: 8),

          if (testingList.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: const Center(
                child: AppText('No tasks currently awaiting testing review.', fontSize: 11, color: AppColors.textColorHint),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: testingList.length,
              separatorBuilder: (_, index) => const SizedBox(height: 10),
              itemBuilder: (context, idx) {
                final task = testingList[idx];
                final assignee = task.assignees.isNotEmpty ? task.assignees.first.name : 'Employee';

                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFC7D2FE)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: AppText(task.title, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: AppText(task.formattedHumanTime, fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      AppText('Submitted by $assignee', fontSize: 10, color: AppColors.textColorSecondary),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 38,
                              child: OutlinedButton(
                                onPressed: () => controller.sendBackToInProgress(task.id, reason: 'Changes requested by manager'),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFFF59E0B)),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const AppText('Request Changes', fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFF59E0B), height: 1.1),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: SizedBox(
                              height: 38,
                              child: ElevatedButton(
                                onPressed: () => controller.approveAndCompleteTask(task.id),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.successColor,
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  elevation: 0,
                                ),
                                child: const AppText('Approve & Complete', fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white, height: 1.1),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          const SizedBox(height: 20),

          // Employee Timesheet Breakdown
          const Row(
            children: [
              Icon(Iconsax.profile_2user, color: AppColors.primaryColor, size: 16),
              SizedBox(width: 6),
              AppText('Team Member Time Breakdown', fontSize: 13, fontWeight: FontWeight.bold),
            ],
          ),
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: Column(
              children: timeMap.entries.map((entry) {
                final hours = entry.value ~/ 3600;
                final minutes = (entry.value % 3600) ~/ 60;
                final timeStr = hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';
                final fraction = controller.totalTeamTrackedSeconds > 0
                    ? (entry.value / controller.totalTeamTrackedSeconds).clamp(0.0, 1.0)
                    : 0.0;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AppText(entry.key, fontSize: 12, fontWeight: FontWeight.bold),
                          AppText(timeStr, fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: fraction,
                          backgroundColor: AppColors.slate100,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, TasksController controller, String id) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const AppText('Delete Task', fontSize: 15, fontWeight: FontWeight.bold),
        content: const AppText('Are you sure you want to delete this task permanently?', fontSize: 13),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const AppText('Cancel', color: AppColors.textColorSecondary, fontWeight: FontWeight.w600),
          ),
          ElevatedButton(
            onPressed: () => controller.deleteTask(id),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const AppText('Delete', color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _showStatusUpdateDialog(BuildContext context, TasksController controller, TaskModel task) {
    final statusOptions = [
      TaskModel.statusToDo,
      TaskModel.statusInProgress,
      TaskModel.statusTesting,
      TaskModel.statusCompleted,
    ];
    final selected = task.normalizedStatus.obs;
    final logTextController = TextEditingController();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const AppText('Update Task Status', fontSize: 15, fontWeight: FontWeight.bold),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...statusOptions.map((st) {
              return Obx(() {
                final isSel = selected.value == st;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: AppText(st, fontSize: 13, fontWeight: isSel ? FontWeight.bold : FontWeight.normal),
                  leading: Radio<String>(
                    value: st,
                    groupValue: selected.value,
                    activeColor: AppColors.primaryColor,
                    onChanged: (val) {
                      if (val != null) selected.value = val;
                    },
                  ),
                  onTap: () => selected.value = st,
                );
              });
            }),
            const SizedBox(height: 10),
            const AppText('Progress Note (Optional)', fontSize: 11, fontWeight: FontWeight.bold),
            const SizedBox(height: 6),
            TextField(
              controller: logTextController,
              maxLines: 2,
              style: const TextStyle(fontSize: 12),
              decoration: InputDecoration(
                hintText: 'e.g. Work started / testing passed...',
                hintStyle: const TextStyle(color: AppColors.textColorHint, fontSize: 11),
                filled: true,
                fillColor: AppColors.slate50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const AppText('Cancel', color: AppColors.textColorSecondary, fontWeight: FontWeight.w600),
          ),
          ElevatedButton(
            onPressed: () {
              controller.updateTaskStatus(selected.value, logTextController.text);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const AppText('Update', color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
