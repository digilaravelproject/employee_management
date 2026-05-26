import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/tasks_controller.dart';
import '../models/task_model.dart';

class TaskDetailsScreen extends StatefulWidget {
  const TaskDetailsScreen({super.key});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  final controller = Get.find<TasksController>();
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
        return AppColors.successColor.withValues(alpha: 0.1);
      case 'in progress':
        return AppColors.primaryColor.withValues(alpha: 0.1);
      case 'review':
        return AppColors.indigo500.withValues(alpha: 0.1);
      case 'pending':
      default:
        return AppColors.slate100;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppColors.successColor;
      case 'in progress':
        return AppColors.primaryColor;
      case 'review':
        return AppColors.indigo500;
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
          IconButton(
            icon: const Icon(Iconsax.edit, color: AppColors.textColorSecondary, size: 20),
            onPressed: () {
              Get.snackbar(
                'Edit Task',
                'Task editing feature is coming soon!',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColors.primaryColor,
                colorText: Colors.white,
              );
            },
          ),
          IconButton(
            icon: const Icon(Iconsax.trash, color: AppColors.errorColor, size: 20),
            onPressed: () {
              final current = controller.selectedTask.value;
              if (current != null) {
                _showDeleteConfirm(context, current.id);
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        final task = controller.selectedTask.value;
        if (task == null) {
          return const Center(
            child: AppText('No Task Selected', fontSize: 14, fontWeight: FontWeight.bold),
          );
        }

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Task Heading Card
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
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getStatusBgColor(task.status),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: AppText(
                                  task.status,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: _getStatusTextColor(task.status),
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
                          _buildCreatorRow(task),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Custom Segmented Tabs (normally unselected/slate, selected blue box with white text)
                    _buildSubTabs(task),
                    const SizedBox(height: 14),

                    // Active Tab Render
                    Obx(() {
                      switch (selectedTabIdx.value) {
                        case 0:
                          return _buildOverviewTab(task);
                        case 1:
                          return _buildCommentsTab(task);
                        case 2:
                          return _buildUpdatesTab(task);
                        case 3:
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
              if (selectedTabIdx.value == 1) {
                return _buildCommentInputBar();
              }
              return const SizedBox.shrink();
            }),
          ],
        );
      }),
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
        if (task.assignees.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Iconsax.message, size: 14, color: AppColors.primaryColor),
          ),
      ],
    );
  }

  Widget _buildPriorityMetaRow(String priority) {
    return Row(
      children: [
        const Icon(Iconsax.flag, size: 16, color: AppColors.textColorHint),
        const SizedBox(width: 12),
        const SizedBox(
          width: 80,
          child: AppText('Priority', fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textColorSecondary),
        ),
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getPriorityColor(priority),
              ),
            ),
            const SizedBox(width: 6),
            AppText(
              priority,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: _getPriorityColor(priority),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCreatorRow(TaskModel task) {
    // Creator dummy John Smith (Manager)
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

  Widget _buildSubTabs(TaskModel task) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Obx(() {
        final currentIdx = selectedTabIdx.value;
        final tabs = [
          'Overview',
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
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: AppColors.primaryColor.withValues(alpha: 0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ] : null,
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

  Widget _buildOverviewTab(TaskModel task) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Description Segment
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppText('Description', fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
              const SizedBox(height: 8),
              AppText(
                task.description,
                fontSize: 12,
                color: AppColors.textColorSecondary,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Sub Tasks Checklist Section
        Container(
          width: double.infinity,
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
                  const AppText('Sub Tasks', fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
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
              Icon(Iconsax.messages_1, size: 30, color: AppColors.textColorHint),
              SizedBox(height: 10),
              AppText('No Comments Yet', fontSize: 13, fontWeight: FontWeight.bold),
              SizedBox(height: 4),
              AppText('Be the first to share comments on this task.', fontSize: 10, color: AppColors.textColorHint),
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
              const Icon(Iconsax.message_text, size: 16, color: AppColors.primaryColor),
              const SizedBox(width: 8),
              AppText('${task.comments.length} Comments', fontSize: 13, fontWeight: FontWeight.bold),
            ],
          ),
          const SizedBox(height: 14),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: task.comments.length,
            separatorBuilder: (context, idx) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final comment = task.comments[index];
              final isManager = comment.userRole.toLowerCase() == 'manager';

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage(comment.user.avatarUrl),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            AppText(comment.user.name, fontSize: 12, fontWeight: FontWeight.bold),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isManager ? AppColors.indigo500.withValues(alpha: 0.1) : AppColors.slate100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: AppText(
                                comment.userRole,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: isManager ? AppColors.indigo500 : AppColors.textColorSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        AppText(
                          _formatDateTime(comment.timestamp),
                          fontSize: 9,
                          color: AppColors.textColorHint,
                          fontWeight: FontWeight.w500,
                        ),
                        const SizedBox(height: 6),
                        AppText(
                          comment.text,
                          fontSize: 12,
                          color: AppColors.textColorPrimary,
                        ),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () {
                            commentInputController.text = '@${comment.user.name} ';
                          },
                          child: const AppText(
                            'Reply',
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUpdatesTab(TaskModel task) {
    if (task.statusUpdates.isEmpty) {
      return const Center(child: AppText('No updates logged yet.'));
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
              const Icon(Iconsax.status, size: 16, color: AppColors.primaryColor),
              const SizedBox(width: 8),
              const AppText('Task Timeline Updates', fontSize: 13, fontWeight: FontWeight.bold),
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
                    // Timeline connector column
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
                                    : update.status.toLowerCase() == 'review'
                                        ? Icons.rate_review_rounded
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

                    // Update details
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
