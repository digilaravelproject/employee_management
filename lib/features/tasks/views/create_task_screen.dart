import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../projects/controllers/projects_controller.dart';
import '../controllers/tasks_controller.dart';
import 'assign_task_screen.dart';

class CreateTaskScreen extends StatelessWidget {
  const CreateTaskScreen({super.key});

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

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TasksController>();
    final projController = Get.find<ProjectsController>();

    final priorityOptions = ['Low', 'Medium', 'High'];
    final statusOptions = ['Pending', 'In Progress', 'Review', 'Completed'];

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
              'Create Task',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textColorPrimary,
            ),
            AppText(
              'Add a new task',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textColorHint,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => controller.saveTask(),
            child: const AppText(
              'Save',
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Form Card
            Container(
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
                  // Task Title
                  Row(
                    children: [
                      const AppText('Task Title', fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
                      const SizedBox(width: 2),
                      const AppText('*', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.errorColor),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: controller.titleController,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                      hintText: 'Enter task title',
                      hintStyle: const TextStyle(color: AppColors.textColorHint, fontSize: 13),
                      filled: true,
                      fillColor: AppColors.slate50,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Row(
                    children: [
                      const AppText('Description', fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
                      const SizedBox(width: 2),
                      const AppText('*', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.errorColor),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: controller.descriptionController,
                    maxLines: 4,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                      hintText: 'Enter task description',
                      hintStyle: const TextStyle(color: AppColors.textColorHint, fontSize: 13),
                      filled: true,
                      fillColor: AppColors.slate50,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Assign To
                  Row(
                    children: [
                      const AppText('Assign To', fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
                      const SizedBox(width: 2),
                      const AppText('*', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.errorColor),
                    ],
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () => Get.to(() => const AssignTaskScreen()),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.slate50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderColor),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Obx(() {
                              final currentAssignees = controller.tempAssignees;
                              if (currentAssignees.isEmpty) {
                                return const AppText(
                                  'Select employee',
                                  fontSize: 13,
                                  color: AppColors.textColorHint,
                                  fontWeight: FontWeight.w500,
                                );
                              }

                              return Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: currentAssignees.map((emp) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLight,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.2)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CircleAvatar(
                                          radius: 8,
                                          backgroundImage: NetworkImage(emp.avatarUrl),
                                        ),
                                        const SizedBox(width: 6),
                                        AppText(emp.name, fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              );
                            }),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textColorHint, size: 14),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Project Selection
                  const AppText('Project', fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.slate50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderColor),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: Obx(() {
                        final currentProj = controller.selectedProjectName.value;
                        final allProjs = projController.projects.map((p) => p.name).toList();
                        if (!allProjs.contains('None')) allProjs.insert(0, 'None');

                        return DropdownButton<String>(
                          value: currentProj == 'None' || allProjs.contains(currentProj) ? currentProj : 'None',
                          isExpanded: true,
                          dropdownColor: Colors.white,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textColorHint),
                          items: allProjs.map((name) {
                            return DropdownMenuItem<String>(
                              value: name,
                              child: AppText(
                                name == 'None' ? 'Select project' : name,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: name == 'None' ? AppColors.textColorHint : AppColors.textColorPrimary,
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) controller.selectedProjectName.value = val;
                          },
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Priority and Deadline Row
                  Row(
                    children: [
                      // Priority Dropdown
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const AppText('Priority', fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
                                const SizedBox(width: 2),
                                const AppText('*', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.errorColor),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: AppColors.slate50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.borderColor),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: Obx(() {
                                  final pVal = controller.selectedPriority.value;

                                  return DropdownButton<String>(
                                    value: pVal,
                                    isExpanded: true,
                                    dropdownColor: Colors.white,
                                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textColorHint),
                                    items: priorityOptions.map((p) {
                                      return DropdownMenuItem<String>(
                                        value: p,
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 6,
                                              height: 6,
                                              decoration: BoxDecoration(shape: BoxShape.circle, color: _getPriorityColor(p)),
                                            ),
                                            const SizedBox(width: 6),
                                            AppText(p, fontSize: 12, fontWeight: FontWeight.bold),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) controller.selectedPriority.value = val;
                                    },
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Deadline DatePicker
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const AppText('Deadline', fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
                                const SizedBox(width: 2),
                                const AppText('*', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.errorColor),
                              ],
                            ),
                            const SizedBox(height: 6),
                            GestureDetector(
                              onTap: () async {
                                final current = controller.selectedDeadline.value;
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: current,
                                  firstDate: DateTime.now().subtract(const Duration(days: 30)),
                                  lastDate: DateTime.now().add(const Duration(days: 365)),
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: const ColorScheme.light(
                                          primary: AppColors.primaryColor,
                                          onPrimary: Colors.white,
                                          onSurface: AppColors.textColorPrimary,
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (picked != null) {
                                  controller.selectedDeadline.value = picked;
                                }
                              },
                              child: Container(
                                height: 48,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.slate50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.borderColor),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Iconsax.calendar, color: AppColors.textColorHint, size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Obx(() {
                                        return AppText(
                                          _formatDate(controller.selectedDeadline.value),
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textColorPrimary,
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Status Selector
                  const AppText('Status', fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.slate50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderColor),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: Obx(() {
                        final currentStatus = controller.selectedStatus.value;

                        return DropdownButton<String>(
                          value: currentStatus,
                          isExpanded: true,
                          dropdownColor: Colors.white,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textColorHint),
                          items: statusOptions.map((st) {
                            return DropdownMenuItem<String>(
                              value: st,
                              child: AppText(st, fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) controller.selectedStatus.value = val;
                          },
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Attachments drag & drop / Mock listing card
                  const AppText('Attachments', fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () {
                      _showMockAttachmentDialog(context, controller);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.slate50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderColor, style: BorderStyle.solid),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              color: AppColors.primaryLight,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Iconsax.document_upload, size: 24, color: AppColors.primaryColor),
                          ),
                          const SizedBox(height: 10),
                          const AppText(
                            'Click to add mock files here',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColorPrimary,
                          ),
                          const SizedBox(height: 4),
                          const AppText(
                            'Support PDF, PNG, JPG files',
                            fontSize: 10,
                            color: AppColors.textColorHint,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Obx(() {
                    final files = controller.tempAttachments;
                    if (files.isEmpty) return const SizedBox.shrink();

                    return Column(
                      children: files.map((filename) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.slate100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Iconsax.document_text5, color: AppColors.textColorHint, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: AppText(
                                  filename,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textColorPrimary,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 16, color: AppColors.errorColor),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () => controller.tempAttachments.remove(filename),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          top: false,
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => controller.saveTask(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const AppText('Create Task', fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  void _showMockAttachmentDialog(BuildContext context, TasksController controller) {
    final nameInputController = TextEditingController();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const AppText('Add Mock Attachment', fontSize: 15, fontWeight: FontWeight.bold),
        content: TextField(
          controller: nameInputController,
          style: const TextStyle(fontSize: 12),
          decoration: InputDecoration(
            hintText: 'e.g. wireframes_v2.png',
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
              final filename = nameInputController.text;
              controller.addMockAttachment(filename);
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
}
