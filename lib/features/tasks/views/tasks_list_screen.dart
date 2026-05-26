import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/tasks_controller.dart';
import 'create_task_screen.dart';
import 'task_details_screen.dart';

class TasksListScreen extends StatelessWidget {
  const TasksListScreen({super.key});

  Color _getPriorityColor(String prio) {
    switch (prio.toLowerCase()) {
      case 'high':
        return AppColors.errorColor; // Red
      case 'medium':
        return AppColors.warningColor; // Amber/Orange
      case 'low':
        return AppColors.successColor; // Emerald Green
      default:
        return AppColors.slate500; // Slate Grey
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppColors.successColor.withValues(alpha: 0.08); // Light emerald
      case 'in progress':
        return AppColors.primaryColor.withValues(alpha: 0.08); // Light blue
      case 'review':
        return AppColors.indigo500.withValues(alpha: 0.08); // Light purple
      case 'pending':
      default:
        return AppColors.slate100; // Light slate
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

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TasksController());

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
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              'Tasks',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textColorPrimary,
            ),
            AppText(
              'Manage and track all tasks',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textColorHint,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── Search & Create Task Header ──
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.slate100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextField(
                          onChanged: (val) => controller.searchQuery.value = val,
                          style: const TextStyle(fontSize: 13),
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Iconsax.search_normal_1, color: AppColors.textColorHint, size: 18),
                            hintText: 'Search tasks...',
                            hintStyle: TextStyle(color: AppColors.textColorHint, fontSize: 13),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Filter icon button
                    Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: AppColors.slate100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: IconButton(
                        icon: const Icon(Iconsax.filter, color: AppColors.textColorSecondary, size: 18),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Filter Sub-Tabs (Premium SaaS Capsule Pills) ──
          Container(
            color: Colors.white,
            height: 52,
            padding: const EdgeInsets.only(bottom: 12),
            child: Obx(() {
              final currentFilter = controller.selectedFilter.value;
              final filterOptions = ['All', 'My Tasks', 'Assigned', 'Completed'];

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
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryColor : AppColors.slate100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.primaryColor : AppColors.slate200,
                          width: 1.5,
                        ),
                        boxShadow: isSelected ? [
                          BoxShadow(
                            color: AppColors.primaryColor.withValues(alpha: 0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          )
                        ] : null,
                      ),
                      child: AppText(
                        opt,
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

          // ── Tasks Feed list ──
          Expanded(
            child: Obx(() {
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
                        child: const Icon(Iconsax.task_square, size: 40, color: AppColors.primaryColor),
                      ),
                      const SizedBox(height: 14),
                      const AppText('No Tasks Found', fontSize: 14, fontWeight: FontWeight.bold),
                      const SizedBox(height: 6),
                      const AppText('Tasks assigned by manager will appear here.', fontSize: 11, color: AppColors.textColorHint),
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
                          // Header line (Category/Title + Status badge + Trailing menu)
                          Row(
                            children: [
                              // Decorative category color dot
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
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: _getStatusBgColor(task.status),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: AppText(
                                  task.status,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: _getStatusTextColor(task.status),
                                ),
                              ),
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert_rounded, color: AppColors.textColorHint, size: 18),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: EdgeInsets.zero,
                                onSelected: (val) {
                                  if (val == 'delete') {
                                    _showDeleteConfirm(context, controller, task.id);
                                  } else if (val == 'status') {
                                    controller.selectTask(task);
                                    _showStatusUpdateDialog(context, controller);
                                  }
                                },
                                itemBuilder: (context) => [
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
                          AppText(
                            task.description,
                            fontSize: 11,
                            color: AppColors.textColorSecondary,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 14),
                          const Divider(height: 1, color: AppColors.slate200),
                          const SizedBox(height: 12),

                          // Assignee + Date + Priority Badge Footer
                          Row(
                            children: [
                              if (task.assignees.isNotEmpty) ...[
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.slate200, width: 1.5),
                                  ),
                                  child: CircleAvatar(
                                    radius: 12,
                                    backgroundImage: NetworkImage(task.assignees.first.avatarUrl),
                                  ),
                                ),
                                const SizedBox(width: 8),
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
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textColorHint,
                                  ),
                                ),
                              ],
                              const Icon(Iconsax.calendar, size: 12, color: AppColors.textColorHint),
                              const SizedBox(width: 4),
                              AppText(
                                _formatDate(task.deadline),
                                fontSize: 10,
                                color: AppColors.textColorHint,
                                fontWeight: FontWeight.w500,
                              ),
                              const SizedBox(width: 14),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: prioColor.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: AppText(
                                  task.priority,
                                  fontSize: 8,
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
      bottomNavigationBar: Container(
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
              icon: const Icon(Iconsax.add, size: 16, color: Colors.white),
              label: const AppText('Create Task', fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
        ),
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

  void _showStatusUpdateDialog(BuildContext context, TasksController controller) {
    final statusOptions = ['Pending', 'In Progress', 'Review', 'Completed'];
    final RxString selected = (controller.selectedTask.value?.status ?? 'Pending').obs;
    final logTextController = TextEditingController();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const AppText('Update Task Status', fontSize: 15, fontWeight: FontWeight.bold),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText('Select Status', fontSize: 11, fontWeight: FontWeight.bold),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.slate50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: Obx(() {
                  return DropdownButton<String>(
                    value: selected.value,
                    isExpanded: true,
                    dropdownColor: Colors.white,
                    items: statusOptions.map((s) {
                      return DropdownMenuItem<String>(
                        value: s,
                        child: AppText(s, fontSize: 12, fontWeight: FontWeight.bold),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) selected.value = val;
                    },
                  );
                }),
              ),
            ),
            const SizedBox(height: 14),
            const AppText('Progress Note (Optional)', fontSize: 11, fontWeight: FontWeight.bold),
            const SizedBox(height: 6),
            TextField(
              controller: logTextController,
              maxLines: 2,
              style: const TextStyle(fontSize: 12),
              decoration: InputDecoration(
                hintText: 'e.g. Completed initial design setup...',
                hintStyle: const TextStyle(color: AppColors.textColorHint, fontSize: 12),
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
