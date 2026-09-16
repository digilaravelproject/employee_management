import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/controllers/app_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/tasks_controller.dart';
import '../models/task_model.dart';
import 'create_task_screen.dart';

class TaskDetailsScreen extends StatefulWidget {
  const TaskDetailsScreen({super.key});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  final controller = Get.find<TasksController>();
  final appController = Get.find<AppController>();
  final RxInt selectedTabIdx = 0.obs;
  final commentInputController = TextEditingController();

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

  String _formatDateTime(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final hour = date.hour > 12 ? date.hour - 12 : date.hour == 0 ? 12 : date.hour;
    final ampm = date.hour >= 12 ? 'PM' : 'AM';
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.day} ${months[date.month - 1]} ${date.year}, $hour:$minute $ampm';
  }

  @override
  Widget build(BuildContext context) {
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
        title: const AppText(
          'Task Details',
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.textColorPrimary,
        ),
        actions: [
          // Quick Role Switcher Pill for easy review
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
          const SizedBox(width: 8),

          // Admin Edit & Delete actions
          Obx(() {
            final task = controller.selectedTask.value;
            final isAdmin = appController.userRole.value.toLowerCase() == 'admin';
            if (task == null || !isAdmin) return const SizedBox.shrink();

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Edit Task',
                  icon: const Icon(Iconsax.edit, color: AppColors.textColorSecondary, size: 20),
                  onPressed: () {
                    controller.populateTaskForm(task);
                    Get.to(() => CreateTaskScreen(isEditMode: true, taskId: task.id));
                  },
                ),
                IconButton(
                  tooltip: 'Delete Task',
                  icon: const Icon(Iconsax.trash, color: AppColors.errorColor, size: 20),
                  onPressed: () => _showDeleteConfirm(context, task.id),
                ),
                const SizedBox(width: 4),
              ],
            );
          }),
        ],
      ),
      body: Obx(() {
        // Observe live ticker for ticking timers
        controller.liveTicker.value;
        final task = controller.selectedTask.value;
        if (task == null) {
          return const Center(
            child: AppText('No Task Selected', fontSize: 14, fontWeight: FontWeight.bold),
          );
        }

        final currentRole = appController.userRole.value.toLowerCase();
        final isAdmin = currentRole == 'admin';
        final isManager = currentRole == 'manager';
        final isEmployee = currentRole == 'employee';

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Interactive Workflow Pipeline Stepper
                    _buildWorkflowStepper(task),
                    const SizedBox(height: 14),

                    // 2. Role-Based Dynamic Control Card
                    if (isEmployee)
                      _buildEmployeeTimerCard(task)
                    else if (isManager)
                      _buildManagerReviewCard(task)
                    else if (isAdmin)
                      _buildAdminOversightCard(task),

                    const SizedBox(height: 16),

                    // 3. Task Heading Card & Metadata
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.borderColor),
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
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _getPriorityColor(task.priority),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: AppText(
                                  task.title,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textColorPrimary,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: _getStatusBgColor(task.normalizedStatus),
                                  borderRadius: BorderRadius.circular(8),
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
                                      const SizedBox(width: 5),
                                    ],
                                    AppText(
                                      task.normalizedStatus,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: _getStatusTextColor(task.normalizedStatus),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          AppText(
                            task.description,
                            fontSize: 12,
                            color: AppColors.textColorSecondary,
                          ),
                          const SizedBox(height: 16),
                          const Divider(height: 1, color: AppColors.dividerColor),
                          const SizedBox(height: 16),

                          // Metadata List
                          _buildMetaRow(Iconsax.briefcase, 'Project', task.project?.name ?? 'None'),
                          const SizedBox(height: 12),
                          _buildAssigneeRow(task),
                          const SizedBox(height: 12),
                          _buildMetaRow(Iconsax.calendar_1, 'Deadline', _formatDate(task.deadline)),
                          const SizedBox(height: 12),
                          _buildPriorityMetaRow(task.priority),
                          const SizedBox(height: 12),
                          _buildTimeTrackedRow(task),
                          const SizedBox(height: 12),
                          _buildCreatorRow(task),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // 4. Custom Sub Tabs
                    _buildSubTabs(task),
                    const SizedBox(height: 14),

                    // 5. Active Tab Render
                    Obx(() {
                      switch (selectedTabIdx.value) {
                        case 0:
                          return _buildOverviewTab(task);
                        case 1:
                          return _buildTimeLogsTab(task);
                        case 2:
                          return _buildCommentsTab(task);
                        case 3:
                          return _buildUpdatesTab(task);
                        case 4:
                          return _buildFilesTab(task);
                        default:
                          return const SizedBox.shrink();
                      }
                    }),
                  ],
                ),
              ),
            ),

            // If comments tab is active, show the bottom comment input bar
            Obx(() {
              if (selectedTabIdx.value == 2) {
                return _buildCommentInputBar();
              }
              return const SizedBox.shrink();
            }),
          ],
        );
      }),
    );
  }

  // ── Workflow Stepper (To Do -> In Progress -> Testing -> Completed) ──
  Widget _buildWorkflowStepper(TaskModel task) {
    final stages = [
      {'key': TaskModel.statusToDo, 'title': 'To Do', 'icon': Iconsax.clipboard_text},
      {'key': TaskModel.statusInProgress, 'title': 'In Progress', 'icon': Iconsax.play_cricle},
      {'key': TaskModel.statusTesting, 'title': 'Testing', 'icon': Iconsax.verify},
      {'key': TaskModel.statusCompleted, 'title': 'Completed', 'icon': Iconsax.tick_circle},
    ];

    final currentIdx = stages.indexWhere((s) => s['key'] == task.normalizedStatus);
    final activeIndex = currentIdx == -1 ? 0 : currentIdx;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AppText(
                'Workflow Lifecycle',
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.textColorHint,
              ),
              AppText(
                'Step ${activeIndex + 1} of 4',
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(stages.length * 2 - 1, (index) {
              if (index.isOdd) {
                // Connecting line
                final stepBefore = index ~/ 2;
                final isPassed = stepBefore < activeIndex;
                return Expanded(
                  child: Container(
                    height: 2.5,
                    color: isPassed ? AppColors.primaryColor : AppColors.slate200,
                  ),
                );
              }

              final stepIdx = index ~/ 2;
              final stage = stages[stepIdx];
              final isCurrent = stepIdx == activeIndex;
              final isPassed = stepIdx < activeIndex;

              Color circleBg;
              Color circleBorder;
              Color iconColor;

              if (isCurrent) {
                circleBg = _getStatusTextColor(stage['key'] as String);
                circleBorder = circleBg;
                iconColor = Colors.white;
              } else if (isPassed) {
                circleBg = AppColors.primaryLight;
                circleBorder = AppColors.primaryColor;
                iconColor = AppColors.primaryColor;
              } else {
                circleBg = AppColors.slate50;
                circleBorder = AppColors.slate300;
                iconColor = AppColors.textColorHint;
              }

              return GestureDetector(
                onTap: () {
                  _showChangeStatusConfirmation(context, stage['key'] as String);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: circleBg,
                        shape: BoxShape.circle,
                        border: Border.all(color: circleBorder, width: 1.5),
                        boxShadow: isCurrent
                            ? [
                                BoxShadow(
                                  color: circleBorder.withValues(alpha: 0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      child: Icon(stage['icon'] as IconData, size: 14, color: iconColor),
                    ),
                    const SizedBox(height: 4),
                    AppText(
                      stage['title'] as String,
                      fontSize: 10,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                      color: isCurrent ? AppColors.textColorPrimary : AppColors.textColorHint,
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── Employee Live Timer & Action Card ──
  Widget _buildEmployeeTimerCard(TaskModel task) {
    final isRunning = task.isTimerRunning;
    final isToDo = task.normalizedStatus == TaskModel.statusToDo;
    final isInProgress = task.normalizedStatus == TaskModel.statusInProgress;
    final isTesting = task.normalizedStatus == TaskModel.statusTesting;
    final isCompleted = task.normalizedStatus == TaskModel.statusCompleted;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isRunning
            ? const Color(0xFFEFF6FF) // light blue
            : isTesting
                ? const Color(0xFFEEF2FF) // light indigo
                : isCompleted
                    ? const Color(0xFFECFDF5) // light emerald
                    : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isRunning
              ? AppColors.primaryColor
              : isTesting
                  ? const Color(0xFF6366F1)
                  : isCompleted
                      ? AppColors.successColor
                      : AppColors.borderColor,
          width: isRunning || isTesting || isCompleted ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isRunning
                      ? AppColors.primaryColor
                      : isTesting
                          ? const Color(0xFF6366F1)
                          : isCompleted
                              ? AppColors.successColor
                              : AppColors.slate200,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isRunning
                      ? Icons.timer_outlined
                      : isTesting
                          ? Iconsax.verify
                          : isCompleted
                              ? Iconsax.tick_circle
                              : Icons.play_arrow_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      isRunning
                          ? 'Timer Running'
                          : isInProgress
                              ? 'Timer Paused'
                              : isTesting
                                  ? 'Task in Testing'
                                  : isCompleted
                                      ? 'Task Completed'
                                      : 'Ready to Start',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColorPrimary,
                    ),
                    AppText(
                      isRunning
                          ? 'Live tracking active session'
                          : isInProgress
                              ? 'Paused • Ready to resume or submit'
                              : isTesting
                                  ? 'Awaiting QA / Manager approval'
                                  : isCompleted
                                      ? 'Great job! Work has been verified'
                                      : 'Tap below to commence task',
                      fontSize: 11,
                      color: AppColors.textColorSecondary,
                    ),
                  ],
                ),
              ),
              // Live Digital Timer readout
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.slate200),
                ),
                child: AppText(
                  task.formattedActiveTime,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isRunning ? AppColors.primaryColor : AppColors.textColorPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Action Buttons based on status
          if (isToDo) ...[
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => controller.startTaskTimer(task.id),
                icon: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 22),
                label: const AppText('Start Task & Timer', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white, height: 1.1),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
          ] else if (isInProgress) ...[
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (isRunning) {
                          controller.pauseTaskTimer(task.id);
                        } else {
                          controller.startTaskTimer(task.id);
                        }
                      },
                      icon: Icon(
                        isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      label: AppText(
                        isRunning ? 'Pause Timer' : 'Resume Timer',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.1,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isRunning ? const Color(0xFFF59E0B) : AppColors.primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: () => _showSubmitTestingDialog(context, task.id),
                      icon: const Icon(Iconsax.verify, color: Colors.white, size: 16),
                      label: const AppText('Send to Testing', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white, height: 1.1),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1), // Indigo
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else if (isTesting) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  const Icon(Iconsax.verify, color: Color(0xFF6366F1), size: 20),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText('In Testing / Review', fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4338CA)),
                        AppText('Submitted for manager QA review. Waiting for approval.', fontSize: 10, color: AppColors.textColorSecondary),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 36,
                    child: OutlinedButton(
                      onPressed: () => controller.sendBackToInProgress(task.id),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const AppText('Resume Work', fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryColor, height: 1.1),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (isCompleted) ...[
            Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: AppColors.successColor, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: AppText(
                    'Total time recorded: ${task.formattedHumanTime}',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.successColor,
                  ),
                ),
                TextButton(
                  onPressed: () => controller.sendBackToInProgress(task.id, reason: 'Reopened by user'),
                  child: const AppText('Reopen', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ── Manager Review & Team Oversight Card ──
  Widget _buildManagerReviewCard(TaskModel task) {
    final isTesting = task.normalizedStatus == TaskModel.statusTesting;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isTesting ? const Color(0xFFEEF2FF) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isTesting ? const Color(0xFF6366F1) : AppColors.borderColor,
          width: isTesting ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isTesting ? const Color(0xFF6366F1) : AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isTesting ? Iconsax.verify : Iconsax.timer_1,
                  size: 18,
                  color: isTesting ? Colors.white : AppColors.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      isTesting ? 'Awaiting Manager Testing Review' : 'Manager Time & Progress Overview',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColorPrimary,
                    ),
                    AppText(
                      '${task.timeLogs.length} session(s) logged • Total: ${task.formattedHumanTime}',
                      fontSize: 11,
                      color: AppColors.textColorSecondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          if (isTesting) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFC7D2FE)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Color(0xFF6366F1)),
                  SizedBox(width: 8),
                  Expanded(
                    child: AppText(
                      'Employee has finished work and submitted this task for QA / Testing verification.',
                      fontSize: 11,
                      color: AppColors.textColorPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton.icon(
                      onPressed: () => _showRequestChangesDialog(context, task.id),
                      icon: const Icon(Icons.close_rounded, size: 16, color: Color(0xFFF59E0B)),
                      label: const AppText('Request Changes', fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFF59E0B), height: 1.1),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFF59E0B)),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: () => controller.approveAndCompleteTask(task.id),
                      icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 16),
                      label: const AppText('Approve & Complete', fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white, height: 1.1),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.successColor,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText(
                  'Current Phase: ${task.normalizedStatus}',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _getStatusTextColor(task.normalizedStatus),
                ),
                TextButton.icon(
                  onPressed: () => _showManualStatusChangeDialog(context, task),
                  icon: const Icon(Icons.edit, size: 14, color: AppColors.primaryColor),
                  label: const AppText('Change Status', fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ── Admin Oversight Card ──
  Widget _buildAdminOversightCard(TaskModel task) {
    final isTesting = task.normalizedStatus == TaskModel.statusTesting;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF5FF), // light purple
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE9D5FF), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFF9333EA),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.admin_panel_settings_rounded, size: 18, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      'Admin Control Mode',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColorPrimary,
                    ),
                    AppText(
                      'Full management privileges: Edit, Delete, Reassign, and Monitor.',
                      fontSize: 11,
                      color: AppColors.textColorSecondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    controller.populateTaskForm(task);
                    Get.to(() => CreateTaskScreen(isEditMode: true, taskId: task.id));
                  },
                  icon: const Icon(Iconsax.edit, size: 16, color: Color(0xFF9333EA)),
                  label: const AppText('Edit Task', fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF9333EA)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF9333EA)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showDeleteConfirm(context, task.id),
                  icon: const Icon(Iconsax.trash, size: 16, color: AppColors.errorColor),
                  label: const AppText('Delete Task', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.errorColor),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.errorColor),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
          if (isTesting) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: OutlinedButton.icon(
                      onPressed: () => _showRequestChangesDialog(context, task.id),
                      icon: const Icon(Icons.close_rounded, size: 16, color: Color(0xFFF59E0B)),
                      label: const AppText('Request Changes', fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFF59E0B), height: 1.1),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFF59E0B)),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: ElevatedButton.icon(
                      onPressed: () => controller.approveAndCompleteTask(task.id),
                      icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 16),
                      label: const AppText('Approve & Complete', fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white, height: 1.1),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.successColor,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ── Time Tracked Row in Metadata ──
  Widget _buildTimeTrackedRow(TaskModel task) {
    return Row(
      children: [
        const Icon(Iconsax.clock, size: 16, color: AppColors.textColorHint),
        const SizedBox(width: 12),
        const SizedBox(
          width: 80,
          child: AppText('Time Logged', fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textColorSecondary),
        ),
        Expanded(
          child: Row(
            children: [
              AppText(
                task.formattedHumanTime,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: task.isTimerRunning ? AppColors.primaryColor : AppColors.textColorPrimary,
              ),
              if (task.isTimerRunning) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const AppText(
                    'Tracking Live',
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetaRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textColorHint),
        const SizedBox(width: 12),
        SizedBox(
          width: 80,
          child: AppText(label, fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textColorSecondary),
        ),
        Expanded(
          child: AppText(value, fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
        ),
      ],
    );
  }

  Widget _buildPriorityMetaRow(String priority) {
    final color = _getPriorityColor(priority);

    return Row(
      children: [
        const Icon(Iconsax.flag, size: 16, color: AppColors.textColorHint),
        const SizedBox(width: 12),
        const SizedBox(
          width: 80,
          child: AppText('Priority', fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textColorSecondary),
        ),
        Expanded(
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              ),
              const SizedBox(width: 6),
              AppText(priority, fontSize: 12, fontWeight: FontWeight.bold, color: color),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAssigneeRow(TaskModel task) {
    return Row(
      children: [
        const Icon(Iconsax.user, size: 16, color: AppColors.textColorHint),
        const SizedBox(width: 12),
        const SizedBox(
          width: 80,
          child: AppText('Assigned To', fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textColorSecondary),
        ),
        Expanded(
          child: task.assignees.isNotEmpty
              ? Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundImage: NetworkImage(task.assignees.first.avatarUrl),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AppText(
                        task.assignees.first.name,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColorPrimary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                )
              : const AppText('Unassigned', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textColorHint),
        ),
      ],
    );
  }

  Widget _buildCreatorRow(TaskModel task) {
    const creatorName = 'John Smith';
    const creatorAvatar = 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150';

    return Row(
      children: [
        const Icon(Iconsax.profile_add, size: 16, color: AppColors.textColorHint),
        const SizedBox(width: 12),
        const SizedBox(
          width: 80,
          child: AppText('Created By', fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textColorSecondary),
        ),
        Expanded(
          child: Row(
            children: [
              const CircleAvatar(
                radius: 12,
                backgroundImage: NetworkImage(creatorAvatar),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppText(creatorName, fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
                    const SizedBox(height: 1),
                    AppText(
                      task.statusUpdates.isNotEmpty
                          ? _formatDateTime(task.statusUpdates.first.timestamp)
                          : '10 Apr 2024, 10:30 AM',
                      fontSize: 9,
                      color: AppColors.textColorHint,
                      fontWeight: FontWeight.w500,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Sub Tabs Bar ──
  Widget _buildSubTabs(TaskModel task) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Obx(() {
        final currentIdx = selectedTabIdx.value;
        final tabs = [
          'Overview',
          'Time Logs (${task.timeLogs.length})',
          'Comments (${task.comments.length})',
          'Updates (${task.statusUpdates.length})',
          'Files (${task.attachments.length})',
        ];

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: tabs.length,
          itemBuilder: (context, idx) {
            final isSelected = currentIdx == idx;
            final label = tabs[idx];

            return GestureDetector(
              onTap: () => selectedTabIdx.value = idx,
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
                  label,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textColorSecondary,
                ),
              ),
            );
          },
        );
      }),
    );
  }

  // ── Tab 0: Overview ──
  Widget _buildOverviewTab(TaskModel task) {
    final completedSubTasks = task.subTasks.where((st) => st.isCompleted).length;
    final totalSubTasks = task.subTasks.length;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Iconsax.task, size: 16, color: AppColors.primaryColor),
                      const SizedBox(width: 8),
                      AppText(
                        'Sub Tasks ($completedSubTasks/$totalSubTasks)',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                  if (appController.userRole.value.toLowerCase() != 'employee')
                    GestureDetector(
                      onTap: () => _showAddSubTaskDialog(context),
                      child: const Row(
                        children: [
                          Icon(Iconsax.add, size: 14, color: AppColors.primaryColor),
                          SizedBox(width: 4),
                          AppText('Add Sub Task', fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              if (task.subTasks.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: AppText(
                      'No subtasks allocated yet.',
                      fontSize: 11,
                      color: AppColors.textColorHint,
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: task.subTasks.length,
                  separatorBuilder: (context, idx) => const Divider(height: 1, color: AppColors.dividerColor),
                  itemBuilder: (context, index) {
                    final sub = task.subTasks[index];

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => controller.toggleSubTask(sub.id),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: sub.isCompleted ? AppColors.primaryColor : Colors.transparent,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                  color: sub.isCompleted ? AppColors.primaryColor : AppColors.slate300,
                                  width: 1.5,
                                ),
                              ),
                              child: sub.isCompleted
                                  ? const Icon(
                                      Icons.check_rounded,
                                      color: Colors.white,
                                      size: 12,
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppText(
                              sub.title,
                              fontSize: 12,
                              fontWeight: sub.isCompleted ? FontWeight.bold : FontWeight.w500,
                              color: sub.isCompleted ? AppColors.textColorHint : AppColors.textColorPrimary,
                              decoration: sub.isCompleted ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          if (sub.date != null)
                            AppText(
                              _formatDate(sub.date!),
                              fontSize: 10,
                              color: AppColors.textColorHint,
                              fontWeight: FontWeight.w500,
                            )
                          else
                            const AppText(
                              '--',
                              fontSize: 10,
                              color: AppColors.textColorHint,
                            ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Tab 1: Time Logs (NEW) ──
  Widget _buildTimeLogsTab(TaskModel task) {
    if (task.timeLogs.isEmpty && !task.isTimerRunning) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Iconsax.clock, size: 30, color: AppColors.primaryColor),
            ),
            const SizedBox(height: 12),
            const AppText('No Time Logged Yet', fontSize: 14, fontWeight: FontWeight.bold),
            const SizedBox(height: 4),
            const AppText(
              'Tap "Start Task & Timer" to track time on this task in real-time.',
              fontSize: 11,
              color: AppColors.textColorHint,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Summary Header Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  const AppText('Total Tracked', fontSize: 10, color: AppColors.textColorSecondary),
                  const SizedBox(height: 2),
                  AppText(task.formattedHumanTime, fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                ],
              ),
              Container(width: 1, height: 28, color: AppColors.slate300),
              Column(
                children: [
                  const AppText('Total Sessions', fontSize: 10, color: AppColors.textColorSecondary),
                  const SizedBox(height: 2),
                  AppText('${task.timeLogs.length}', fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
                ],
              ),
              Container(width: 1, height: 28, color: AppColors.slate300),
              Column(
                children: [
                  const AppText('Current State', fontSize: 10, color: AppColors.textColorSecondary),
                  const SizedBox(height: 2),
                  AppText(
                    task.isTimerRunning ? 'Active' : 'Idle',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: task.isTimerRunning ? AppColors.successColor : AppColors.textColorHint,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // List of sessions
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: task.timeLogs.length,
          separatorBuilder: (context, idx) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            // Newest logs first
            final log = task.timeLogs.reversed.toList()[index];

            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage(log.user.avatarUrl),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AppText(log.user.name, fontSize: 12, fontWeight: FontWeight.bold),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: AppText(
                                log.formattedDuration,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        AppText(
                          _formatDateTime(log.startTime),
                          fontSize: 10,
                          color: AppColors.textColorHint,
                        ),
                        if (log.note.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          AppText(
                            log.note,
                            fontSize: 11,
                            color: AppColors.textColorSecondary,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // ── Tab 2: Comments ──
  Widget _buildCommentsTab(TaskModel task) {
    if (task.comments.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Iconsax.message_text, size: 30, color: AppColors.textColorHint),
              SizedBox(height: 10),
              AppText('No Comments Yet', fontSize: 13, fontWeight: FontWeight.bold),
              SizedBox(height: 4),
              AppText('Start the conversation by adding a comment below.', fontSize: 10, color: AppColors.textColorHint),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: task.comments.length,
        separatorBuilder: (context, idx) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final comment = task.comments[index];
          final isManager = comment.userRole.toLowerCase() == 'manager';

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 14,
                backgroundImage: NetworkImage(comment.user.avatarUrl),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        AppText(
                          comment.user.name,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColorPrimary,
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isManager ? AppColors.primaryLight : AppColors.slate100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: AppText(
                            comment.userRole,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: isManager ? AppColors.primaryColor : AppColors.textColorHint,
                          ),
                        ),
                        const Spacer(),
                        AppText(
                          _formatDateTime(comment.timestamp),
                          fontSize: 9,
                          color: AppColors.textColorHint,
                          fontWeight: FontWeight.w500,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    AppText(
                      comment.text,
                      fontSize: 11,
                      color: AppColors.textColorSecondary,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Tab 3: Updates / Audit Timeline ──
  Widget _buildUpdatesTab(TaskModel task) {
    if (task.statusUpdates.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Iconsax.activity, size: 30, color: AppColors.textColorHint),
              SizedBox(height: 10),
              AppText('No Status Logs', fontSize: 13, fontWeight: FontWeight.bold),
              SizedBox(height: 4),
              AppText('Task status transition records will appear here.', fontSize: 10, color: AppColors.textColorHint),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Iconsax.activity, size: 16, color: AppColors.primaryColor),
              const SizedBox(width: 8),
              AppText('Audit Timeline (${task.statusUpdates.length})', fontSize: 13, fontWeight: FontWeight.bold),
            ],
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: task.statusUpdates.length,
            itemBuilder: (context, index) {
              final update = task.statusUpdates[index];
              final isLast = index == task.statusUpdates.length - 1;

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _getStatusTextColor(update.status).withValues(alpha: 0.1),
                          ),
                          child: Icon(
                            update.status.toLowerCase() == 'completed'
                                ? Icons.check_circle_rounded
                                : update.status.toLowerCase() == 'in progress'
                                    ? Icons.play_circle_fill_rounded
                                    : update.status.toLowerCase() == 'testing'
                                        ? Iconsax.verify
                                        : Icons.hourglass_top_rounded,
                            size: 14,
                            color: _getStatusTextColor(update.status),
                          ),
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 1.5,
                              color: AppColors.borderColor,
                              margin: const EdgeInsets.symmetric(vertical: 4),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                AppText(
                                  update.title,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textColorPrimary,
                                ),
                                const Spacer(),
                                AppText(
                                  _formatDateTime(update.timestamp),
                                  fontSize: 9,
                                  color: AppColors.textColorHint,
                                  fontWeight: FontWeight.w500,
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                const Icon(Iconsax.user, size: 10, color: AppColors.textColorHint),
                                const SizedBox(width: 4),
                                AppText(
                                  update.user.name,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textColorSecondary,
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            AppText(
                              update.description,
                              fontSize: 11,
                              color: AppColors.textColorSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Tab 4: Files ──
  Widget _buildFilesTab(TaskModel task) {
    if (task.attachments.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Iconsax.document_text, size: 30, color: AppColors.textColorHint),
              SizedBox(height: 10),
              AppText('No Files Shared', fontSize: 13, fontWeight: FontWeight.bold),
              SizedBox(height: 4),
              AppText('No document attachments are bound to this task.', fontSize: 10, color: AppColors.textColorHint),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Iconsax.folder_open, size: 16, color: AppColors.primaryColor),
              const SizedBox(width: 8),
              AppText('${task.attachments.length} Attachments', fontSize: 13, fontWeight: FontWeight.bold),
            ],
          ),
          const SizedBox(height: 14),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: task.attachments.length,
            separatorBuilder: (context, idx) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final filename = task.attachments[index];
              final ext = filename.split('.').last.toUpperCase();

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.slate50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: ext == 'PDF' ? AppColors.errorColor.withValues(alpha: 0.1) : AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        ext == 'PDF' ? Iconsax.document_text : Iconsax.image,
                        color: ext == 'PDF' ? AppColors.errorColor : AppColors.primaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            filename,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColorPrimary,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          AppText(
                            '$ext File • 2.4 MB',
                            fontSize: 10,
                            color: AppColors.textColorHint,
                            fontWeight: FontWeight.w500,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Iconsax.document_download, color: AppColors.textColorSecondary, size: 18),
                      onPressed: () {
                        Get.snackbar(
                          'Downloading File',
                          'Initiated download for $filename...',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: AppColors.successColor,
                          colorText: Colors.white,
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInputBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.borderColor)),
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 10,
        bottom: MediaQuery.of(context).viewInsets.bottom + 10,
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.slate100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: commentInputController,
                  style: const TextStyle(fontSize: 12),
                  decoration: const InputDecoration(
                    hintText: 'Add a comment...',
                    hintStyle: TextStyle(color: AppColors.textColorHint, fontSize: 12),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              height: 40,
              width: 40,
              decoration: const BoxDecoration(
                color: AppColors.primaryColor,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send_rounded, color: Colors.white, size: 16),
                onPressed: () {
                  final text = commentInputController.text;
                  if (text.trim().isNotEmpty) {
                    controller.addComment(text);
                    commentInputController.clear();
                    FocusScope.of(context).unfocus();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Dialogs & Prompts ──
  void _showSubmitTestingDialog(BuildContext context, String taskId) {
    final noteController = TextEditingController();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Iconsax.verify, color: Color(0xFF6366F1), size: 20),
            SizedBox(width: 8),
            AppText('Submit for Testing', fontSize: 15, fontWeight: FontWeight.bold),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText(
              'This will pause any running timer, record your work session, and move the task status to Testing for review.',
              fontSize: 12,
              color: AppColors.textColorSecondary,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              maxLines: 2,
              style: const TextStyle(fontSize: 12),
              decoration: InputDecoration(
                hintText: 'Testing note / changes summary (optional)...',
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
              Get.back();
              controller.moveToTesting(taskId, note: noteController.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const AppText('Submit', color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _showRequestChangesDialog(BuildContext context, String taskId) {
    final reasonController = TextEditingController();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const AppText('Request Changes', fontSize: 15, fontWeight: FontWeight.bold),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppText(
              'Specify why this task needs additional work before it can be approved:',
              fontSize: 12,
              color: AppColors.textColorSecondary,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: reasonController,
              maxLines: 2,
              style: const TextStyle(fontSize: 12),
              decoration: InputDecoration(
                hintText: 'e.g. Edge case test failed, please fix...',
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
            child: const AppText('Cancel', color: AppColors.textColorSecondary),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.sendBackToInProgress(taskId, reason: reasonController.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const AppText('Reopen to In Progress', color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _showChangeStatusConfirmation(BuildContext context, String newStatus) {
    final current = controller.selectedTask.value;
    if (current == null || current.normalizedStatus == newStatus) return;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: AppText('Move to $newStatus?', fontSize: 15, fontWeight: FontWeight.bold),
        content: AppText(
          'Are you sure you want to transition this task from "${current.normalizedStatus}" to "$newStatus"?',
          fontSize: 12,
          color: AppColors.textColorSecondary,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const AppText('Cancel', color: AppColors.textColorSecondary),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.updateTaskStatus(newStatus, 'Manually changed status to $newStatus');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const AppText('Confirm', color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _showManualStatusChangeDialog(BuildContext context, TaskModel task) {
    final options = [TaskModel.statusToDo, TaskModel.statusInProgress, TaskModel.statusTesting, TaskModel.statusCompleted];
    final selected = task.normalizedStatus.obs;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const AppText('Update Task Status', fontSize: 15, fontWeight: FontWeight.bold),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((opt) {
            return Obx(() {
              final isSel = selected.value == opt;
              return ListTile(
                title: AppText(opt, fontSize: 13, fontWeight: isSel ? FontWeight.bold : FontWeight.normal),
                leading: Radio<String>(
                  value: opt,
                  groupValue: selected.value,
                  onChanged: (val) {
                    if (val != null) selected.value = val;
                  },
                ),
                onTap: () => selected.value = opt,
              );
            });
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const AppText('Cancel', color: AppColors.textColorSecondary),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.updateTaskStatus(selected.value, 'Manager status update');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const AppText('Save', color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _showAddSubTaskDialog(BuildContext context) {
    final subTaskTextController = TextEditingController();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const AppText('Add Sub Task', fontSize: 15, fontWeight: FontWeight.bold),
        content: TextField(
          controller: subTaskTextController,
          style: const TextStyle(fontSize: 12),
          decoration: InputDecoration(
            hintText: 'e.g. Design responsive dashboard views',
            hintStyle: const TextStyle(color: AppColors.textColorHint, fontSize: 12),
            filled: true,
            fillColor: AppColors.slate50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const AppText('Cancel', color: AppColors.textColorSecondary, fontWeight: FontWeight.w600),
          ),
          ElevatedButton(
            onPressed: () {
              controller.addSubTask(subTaskTextController.text);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const AppText('Add', color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, String id) {
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
}
