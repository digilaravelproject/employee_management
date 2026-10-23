import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../controllers/employee_flow_controller.dart';
import '../models/employee_flow_models.dart';
import '../widgets/employee_flow_widgets.dart';
import 'employee_task_details_screen.dart';
import 'employee_request_handover_screen.dart';

/// Screen 4: My Tasks
/// Matches Mockup 4 from user reference:
/// - Header: "My Tasks"
/// - Filter Chips: All (8), In Progress (4), Completed (3), Pending (1)
/// - Task Cards:
///   - Icon container
///   - Title & Module category
///   - Status Badge (In Progress, Completed, Pending)
///   - Due Date (Due: 18 Sep 2025)
///   - Hours allocated vs spent (6h / 8h) with RED alert if time exceeded!
///   - Quick Start / Pause / Stop controls
///   - Handover action
class EmployeeTasksListScreen extends StatelessWidget {
  final bool showBackButton;
  final EmployeeFlowProject? project;

  const EmployeeTasksListScreen({
    super.key,
    this.showBackButton = true,
    this.project,
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
        title: Text(
          project != null ? '${project!.code} - Tasks' : 'My Tasks',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: EmployeeFlowTheme.textDark,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Filter Chips Horizontal Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Obx(() {
              final total = project != null
                  ? controller.getProjectTotalTasksCount(project!.id)
                  : controller.totalTasksCount;
              final inProgress = project != null
                  ? controller.getProjectInProgressTasksCount(project!.id)
                  : controller.inProgressTasksCount;
              final completed = project != null
                  ? controller.getProjectCompletedTasksCount(project!.id)
                  : controller.completedTasksCount;
              final pending = project != null
                  ? controller.getProjectPendingTasksCount(project!.id)
                  : controller.pendingTasksCount;

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildFilterChip(
                      label: 'All ($total)',
                      value: 'All',
                      current: controller.taskFilter.value,
                      onTap: () => controller.taskFilter.value = 'All',
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: 'In Progress ($inProgress)',
                      value: 'In Progress',
                      current: controller.taskFilter.value,
                      onTap: () => controller.taskFilter.value = 'In Progress',
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: 'Completed ($completed)',
                      value: 'Completed',
                      current: controller.taskFilter.value,
                      onTap: () => controller.taskFilter.value = 'Completed',
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: 'Pending ($pending)',
                      value: 'Pending',
                      current: controller.taskFilter.value,
                      onTap: () => controller.taskFilter.value = 'Pending',
                    ),
                  ],
                ),
              );
            }),
          ),

          // Tasks List
          Expanded(
            child: Obx(() {
              final tasks = project != null
                  ? controller.getFilteredTasksForProject(project!.id)
                  : controller.filteredTasks;

              if (tasks.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Iconsax.task, size: 48, color: EmployeeFlowTheme.textHint),
                      const SizedBox(height: 12),
                      const Text(
                        'No tasks in this category',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: EmployeeFlowTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Select another filter to view assigned tasks.',
                        style: TextStyle(fontSize: 13, color: EmployeeFlowTheme.textMuted),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                physics: const BouncingScrollPhysics(),
                itemCount: tasks.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return _buildTaskCard(context, task, controller);
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

  Widget _buildTaskCard(
    BuildContext context,
    EmployeeFlowTask task,
    EmployeeFlowController controller,
  ) {
    final isRunning = task.isRunning && !task.isPaused;
    final isPaused = task.isRunning && task.isPaused;
    final isExceeded = task.isTimeExceeded;

    // Card Icon & background based on category
    IconData iconData = Iconsax.code;
    Color iconColor = EmployeeFlowTheme.primaryBlue;
    Color iconBg = EmployeeFlowTheme.infoBg;

    if (task.moduleTitle.toLowerCase().contains('design')) {
      iconData = Iconsax.brush_1;
      iconColor = const Color(0xFF9333EA);
      iconBg = const Color(0xFFF3E8FF);
    } else if (task.moduleTitle.toLowerCase().contains('auth')) {
      iconData = Iconsax.shield_tick;
      iconColor = EmployeeFlowTheme.successGreen;
      iconBg = EmployeeFlowTheme.successBg;
    } else if (task.moduleTitle.toLowerCase().contains('payment') ||
        task.moduleTitle.toLowerCase().contains('checkout')) {
      iconData = Iconsax.shopping_bag;
      iconColor = const Color(0xFFEA580C);
      iconBg = const Color(0xFFFFEDD5);
    }

    return EmployeeFlowCard(
      onTap: () => Get.to(() => EmployeeTaskDetailsScreen(task: task)),
      padding: const EdgeInsets.all(16),
      borderColor: isExceeded
          ? EmployeeFlowTheme.dangerRed.withValues(alpha: 0.5)
          : (isRunning ? EmployeeFlowTheme.primaryBlue.withValues(alpha: 0.5) : EmployeeFlowTheme.cardBorder),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(iconData, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              // Title & Module
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: EmployeeFlowTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      task.moduleTitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: EmployeeFlowTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              // Status Badge
              EmployeeFlowStatusBadge(status: task.status),
            ],
          ),

          const SizedBox(height: 12),

          // Due Date & Hours Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Iconsax.calendar_1, size: 14, color: EmployeeFlowTheme.textHint),
                  const SizedBox(width: 4),
                  Text(
                    'Due: ${task.dueDate}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: EmployeeFlowTheme.textMuted,
                    ),
                  ),
                ],
              ),
              // Hours (e.g. 6h / 8h, or RED if exceeded)
              Row(
                children: [
                  if (isExceeded) ...[
                    const Icon(Icons.warning_amber_rounded, size: 14, color: EmployeeFlowTheme.dangerRed),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    task.formattedRatio,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isExceeded ? EmployeeFlowTheme.dangerRed : EmployeeFlowTheme.textDark,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Progress Bar (RED if exceeded)
          EmployeeFlowProgressBar(
            progress: task.progress,
            isExceeded: isExceeded,
            activeColor: isExceeded
                ? EmployeeFlowTheme.dangerRed
                : (task.status == 'Completed' ? EmployeeFlowTheme.successGreen : EmployeeFlowTheme.primaryBlue),
            height: 5,
          ),

          const SizedBox(height: 12),

          // Action Toolbar: Timer Controls & Handover
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Handover Button
              InkWell(
                onTap: () => Get.to(() => EmployeeRequestHandoverScreen(task: task)),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: EmployeeFlowTheme.surfaceSlate,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: EmployeeFlowTheme.cardBorder),
                  ),
                  child: Row(
                    children: const [
                      Icon(Iconsax.repeat, size: 14, color: EmployeeFlowTheme.primaryBlue),
                      SizedBox(width: 6),
                      Text(
                        'Handover',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: EmployeeFlowTheme.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Timer Controls: Start / Pause / Stop
              if (task.status != 'Completed')
                Row(
                  children: [
                    if (!task.isRunning)
                      // START BUTTON
                      ElevatedButton.icon(
                        icon: const Icon(Icons.play_arrow_rounded, size: 16),
                        label: const Text('Start Work'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: EmployeeFlowTheme.primaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => controller.startTaskTimer(task),
                      )
                    else ...[
                      // PAUSE / RESUME BUTTON
                      OutlinedButton.icon(
                        icon: Icon(
                          isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                          size: 15,
                        ),
                        label: Text(isPaused ? 'Resume' : 'Pause (Break)'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isPaused ? EmployeeFlowTheme.primaryBlue : EmployeeFlowTheme.warningOrange,
                          side: BorderSide(
                            color: isPaused ? EmployeeFlowTheme.primaryBlue : EmployeeFlowTheme.warningOrange,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          if (isPaused) {
                            controller.resumeTaskTimer();
                          } else {
                            _showBreakDialog(context, controller);
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      // STOP / COMPLETE BUTTON
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: EmployeeFlowTheme.successGreen,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => controller.stopTaskTimer(markCompleted: true),
                        child: const Text(
                          'Done',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ],
                )
              else
                Row(
                  children: const [
                    Icon(Icons.check_circle_rounded, size: 16, color: EmployeeFlowTheme.successGreen),
                    SizedBox(width: 4),
                    Text(
                      'Completed',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: EmployeeFlowTheme.successGreen,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showBreakDialog(BuildContext context, EmployeeFlowController controller) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pause Work - Select Break Reason',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: EmployeeFlowTheme.textDark,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.coffee, color: Colors.brown),
                  title: const Text('Tea / Coffee Break'),
                  onTap: () {
                    Get.back();
                    controller.pauseTaskTimer(reason: 'Tea / Coffee Break');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.lunch_dining, color: Colors.orange),
                  title: const Text('Lunch Break'),
                  onTap: () {
                    Get.back();
                    controller.pauseTaskTimer(reason: 'Lunch Break');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.groups, color: EmployeeFlowTheme.primaryBlue),
                  title: const Text('Internal Meeting / Sync'),
                  onTap: () {
                    Get.back();
                    controller.pauseTaskTimer(reason: 'Internal Meeting');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.more_horiz, color: EmployeeFlowTheme.textMuted),
                  title: const Text('Other Break / Call'),
                  onTap: () {
                    Get.back();
                    controller.pauseTaskTimer(reason: 'Personal / Other Break');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
