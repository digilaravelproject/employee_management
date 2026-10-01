import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../employee/management/models/employee_model.dart';
import '../../projects/controllers/projects_controller.dart';
import '../../projects/models/project_model.dart';
import '../controllers/tasks_controller.dart';
import 'assign_task_screen.dart';

class CreateTaskScreen extends StatefulWidget {
  final bool isEditMode;
  final String? taskId;

  const CreateTaskScreen({
    super.key,
    this.isEditMode = false,
    this.taskId,
  });

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final TasksController controller = Get.find<TasksController>();
  final ProjectsController projController = Get.isRegistered<ProjectsController>()
      ? Get.find<ProjectsController>()
      : Get.put(ProjectsController());

  final List<String> categoryOptions = [
    'UI/UX Design',
    'Web Development',
    'Mobile App Development',
    'Backend & APIs',
    'QA & Testing',
    'Bug Fixing',
    'Database Architecture',
    'DevOps & Cloud',
    'Research & Planning',
    'Custom / Other',
  ];

  final List<String> priorityOptions = ['Low', 'Medium', 'High', 'Urgent', 'Critical'];
  final List<String> statusOptions = ['Pending', 'In Progress', 'Testing', 'Completed'];

  @override
  void initState() {
    super.initState();
    // Load projects if not loaded
    if (projController.projects.isEmpty) {
      projController.fetchProjects(isRefresh: true);
    }
    // Load employees if not loaded
    if (controller.employeesList.isEmpty) {
      if (projController.employeesList.isNotEmpty) {
        controller.employeesList.assignAll(projController.employeesList);
      } else {
        controller.fetchEmployees();
      }
    }

    // In edit mode, ensure form is populated
    if (widget.isEditMode && widget.taskId != null) {
      final task = controller.tasks.firstWhereOrNull((t) => t.id == widget.taskId) ??
          controller.selectedTask.value;
      if (task != null && controller.titleController.text.isEmpty) {
        controller.populateTaskForm(task);
      }
    }

    // Auto-select first project if none selected (create mode only)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.isEditMode && controller.selectedProject.value == null && projController.projects.isNotEmpty) {
        controller.selectedProject.value = projController.projects.first;
        controller.selectedProjectName.value = projController.projects.first.name;
      }
    });
  }

  Color _getPriorityColor(String prio) {
    switch (prio.toLowerCase()) {
      case 'critical':
      case 'urgent':
        return const Color(0xFF991B1B);
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

  String _formatDisplayDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  Future<void> _pickDate({required bool isStartDate}) async {
    final initial = isStartDate ? controller.startDate.value : controller.dueDate.value;
    final firstDate = isStartDate
        ? DateTime.now().subtract(const Duration(days: 365))
        : controller.startDate.value;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(firstDate) ? firstDate : initial,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
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
      if (isStartDate) {
        controller.startDate.value = picked;
        // If due date is earlier than new start date, push it forward
        if (controller.dueDate.value.isBefore(picked)) {
          controller.dueDate.value = picked.add(const Duration(days: 7));
        }
      } else {
        if (picked.isBefore(controller.startDate.value)) {
          Get.snackbar(
            'Validation Warning',
            'Due Date cannot be earlier than Start Date!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.warningColor,
            colorText: Colors.white,
          );
          return;
        }
        controller.dueDate.value = picked;
        controller.selectedDeadline.value = picked;
      }
    }
  }

  Widget _buildPresetChip(
    String label,
    int h,
    int m,
    int currentH,
    int currentM,
    void Function(int, int) onSelect,
  ) {
    final isSelected = currentH == h && currentM == m;
    return GestureDetector(
      onTap: () => onSelect(h, m),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : AppColors.slate50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : AppColors.slate200,
          ),
        ),
        child: AppText(
          label,
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? Colors.white : AppColors.textColorSecondary,
        ),
      ),
    );
  }

  void _showHoursBottomSheet(BuildContext context) {
    int tempH = controller.estimatedHours.value;
    int tempM = controller.estimatedMinutes.value;

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.slate300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Iconsax.clock, color: AppColors.primaryColor, size: 20),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: AppText(
                          'Estimated Duration',
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: AppText(
                          '${tempH.toString().padLeft(2, '0')}h ${tempM.toString().padLeft(2, '0')}m',
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const AppText(
                    'Specify the anticipated duration required to complete this task',
                    fontSize: 11,
                    color: AppColors.textColorHint,
                  ),
                  const SizedBox(height: 20),

                  // Hours and Minutes Steppers
                  Row(
                    children: [
                      // Hours Box
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.slate50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.slate200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const AppText('Hours', fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textColorSecondary),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Material(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(8),
                                      onTap: () {
                                        if (tempH > 0) setSheetState(() => tempH--);
                                      },
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          border: Border.all(color: AppColors.slate200),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.remove, size: 16, color: AppColors.textColorPrimary),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Center(
                                      child: AppText(
                                        '${tempH}h',
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                                  ),
                                  Material(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(8),
                                      onTap: () {
                                        if (tempH < 999) setSheetState(() => tempH++);
                                      },
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          border: Border.all(color: AppColors.slate200),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.add, size: 16, color: AppColors.textColorPrimary),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Minutes Box
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.slate50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.slate200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const AppText('Minutes', fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textColorSecondary),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Material(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(8),
                                      onTap: () {
                                        if (tempM >= 15) {
                                          setSheetState(() => tempM -= 15);
                                        } else if (tempH > 0) {
                                          setSheetState(() {
                                            tempH--;
                                            tempM = 45;
                                          });
                                        } else {
                                          setSheetState(() => tempM = 0);
                                        }
                                      },
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          border: Border.all(color: AppColors.slate200),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.remove, size: 16, color: AppColors.textColorPrimary),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Center(
                                      child: AppText(
                                        '${tempM}m',
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                                  ),
                                  Material(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(8),
                                      onTap: () {
                                        if (tempM + 15 < 60) {
                                          setSheetState(() => tempM += 15);
                                        } else {
                                          setSheetState(() {
                                            tempH++;
                                            tempM = 0;
                                          });
                                        }
                                      },
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          border: Border.all(color: AppColors.slate200),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.add, size: 16, color: AppColors.textColorPrimary),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Quick presets
                  const AppText('Quick Presets', fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textColorSecondary),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildPresetChip('01h 00m', 1, 0, tempH, tempM, (h, m) => setSheetState(() { tempH = h; tempM = m; })),
                      _buildPresetChip('02h 00m', 2, 0, tempH, tempM, (h, m) => setSheetState(() { tempH = h; tempM = m; })),
                      _buildPresetChip('04h 00m', 4, 0, tempH, tempM, (h, m) => setSheetState(() { tempH = h; tempM = m; })),
                      _buildPresetChip('05h 30m', 5, 30, tempH, tempM, (h, m) => setSheetState(() { tempH = h; tempM = m; })),
                      _buildPresetChip('08h 00m', 8, 0, tempH, tempM, (h, m) => setSheetState(() { tempH = h; tempM = m; })),
                      _buildPresetChip('16h 00m', 16, 0, tempH, tempM, (h, m) => setSheetState(() { tempH = h; tempM = m; })),
                      _buildPresetChip('40h 00m', 40, 0, tempH, tempM, (h, m) => setSheetState(() { tempH = h; tempM = m; })),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Apply button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        controller.estimatedHours.value = tempH;
                        controller.estimatedMinutes.value = tempM;
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const AppText('Apply Estimate', color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildFieldLabel(String label, bool isRequired) {
    return Row(
      children: [
        AppText(label, fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
        if (isRequired) ...[
          const SizedBox(width: 4),
          const AppText('*', fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.errorColor),
        ],
      ],
    );
  }

  Widget _buildEmployeeAvatar(dynamic emp) {
    String? pic;
    String name = '';
    if (emp is EmployeeModel) {
      pic = emp.profilePic;
      name = emp.name;
    } else {
      pic = emp.avatarUrl;
      name = emp.name;
    }

    if (pic != null && pic.trim().isNotEmpty) {
      final imgUrl = pic.startsWith('http') ? pic : '${AppConstants.baseUrl}/storage/$pic';
      return CircleAvatar(
        radius: 12,
        backgroundColor: AppColors.slate100,
        backgroundImage: NetworkImage(imgUrl),
        onBackgroundImageError: (exception, stackTrace) {},
        child: name.isNotEmpty
            ? Text(name[0].toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold))
            : null,
      );
    }

    return CircleAvatar(
      radius: 12,
      backgroundColor: AppColors.primaryLight,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'E',
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
      ),
    );
  }

  void _submitForm() {
    if (widget.isEditMode && widget.taskId != null) {
      controller.updateExistingTask(widget.taskId!);
    } else {
      controller.createTaskApi();
    }
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              widget.isEditMode ? 'Edit Task' : 'Create Task',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textColorPrimary,
            ),
            AppText(
              widget.isEditMode ? 'Update task parameters' : 'Fill details & assign to team members',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textColorHint,
            ),
          ],
        ),
        actions: [
          Obx(() {
            final isLoading = controller.isCreatingTask.value || controller.isUpdatingTask.value;
            if (isLoading) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryColor),
                  ),
                ),
              );
            }

            return TextButton(
              onPressed: _submitForm,
              child: AppText(
                widget.isEditMode ? 'Update' : 'Save',
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            );
          }),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Primary Form Card ──
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Task Title
                  _buildFieldLabel('Task Title', true),
                  const SizedBox(height: 6),
                  TextField(
                    controller: controller.titleController,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textColorPrimary),
                    decoration: InputDecoration(
                      hintText: 'e.g. UI/UX Redesign for Mobile App',
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
                  const SizedBox(height: 18),

                  // 2. Description
                  _buildFieldLabel('Description', true),
                  const SizedBox(height: 6),
                  TextField(
                    controller: controller.descriptionController,
                    maxLines: 4,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textColorPrimary),
                    decoration: InputDecoration(
                      hintText: 'Design new interactive screens, dark mode theme, and component library...',
                      hintStyle: const TextStyle(color: AppColors.textColorHint, fontSize: 13),
                      filled: true,
                      fillColor: AppColors.slate50,
                      contentPadding: const EdgeInsets.all(16),
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
                  const SizedBox(height: 18),

                  // 3. Project Selection (Fetched from Projects API)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildFieldLabel('Project', true),
                      Obx(() {
                        if (projController.isLoadingProjects.value) {
                          return const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.primaryColor),
                          );
                        }
                        return GestureDetector(
                          onTap: () => projController.fetchProjects(isRefresh: true),
                          child: const Row(
                            children: [
                              Icon(Icons.refresh_rounded, size: 14, color: AppColors.primaryColor),
                              SizedBox(width: 4),
                              AppText('Refresh', fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.slate50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderColor),
                    ),
                    child: Obx(() {
                      final projectsList = projController.projects;

                      if (projectsList.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const AppText(
                                'No projects available. Click refresh.',
                                fontSize: 13,
                                color: AppColors.textColorHint,
                              ),
                              IconButton(
                                icon: const Icon(Icons.refresh, size: 18, color: AppColors.primaryColor),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () => projController.fetchProjects(isRefresh: true),
                              ),
                            ],
                          ),
                        );
                      }

                      // Find selected Project
                      final selectedProj = controller.selectedProject.value;
                      Project? activeValue;
                      if (selectedProj != null) {
                        activeValue = projectsList.firstWhereOrNull((p) => p.id == selectedProj.id);
                      }
                      activeValue ??= projectsList.first;

                      return DropdownButtonHideUnderline(
                        child: DropdownButton<Project>(
                          value: activeValue,
                          isExpanded: true,
                          dropdownColor: Colors.white,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textColorHint),
                          items: projectsList.map((proj) {
                            return DropdownMenuItem<Project>(
                              value: proj,
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: AppText(
                                      proj.name,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textColorPrimary,
                                      maxLines: 1,
                                    ),
                                  ),
                                  if (proj.category.isNotEmpty)
                                    Container(
                                      margin: const EdgeInsets.only(left: 8),
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.slate100,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: AppText(
                                        proj.category,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textColorSecondary,
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (proj) {
                            if (proj != null) {
                              controller.selectedProject.value = proj;
                              controller.selectedProjectName.value = proj.name;
                              // Auto set category if empty
                              if (controller.selectedCategory.value.isEmpty || controller.selectedCategory.value == 'UI/UX Design') {
                                if (proj.category.isNotEmpty) {
                                  controller.selectedCategory.value = proj.category;
                                }
                              }
                            }
                          },
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 18),

                  // 4. Category
                  _buildFieldLabel('Category', true),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.slate50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderColor),
                    ),
                    child: Obx(() {
                      final currentCat = controller.selectedCategory.value;
                      final isCustom = controller.isCustomCategory.value;

                      return DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: isCustom ? 'Custom / Other' : (categoryOptions.contains(currentCat) ? currentCat : categoryOptions.first),
                          isExpanded: true,
                          dropdownColor: Colors.white,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textColorHint),
                          items: categoryOptions.map((cat) {
                            return DropdownMenuItem<String>(
                              value: cat,
                              child: AppText(
                                cat,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textColorPrimary,
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              if (val == 'Custom / Other') {
                                controller.isCustomCategory.value = true;
                              } else {
                                controller.isCustomCategory.value = false;
                                controller.selectedCategory.value = val;
                              }
                            }
                          },
                        ),
                      );
                    }),
                  ),
                  Obx(() {
                    if (!controller.isCustomCategory.value) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: TextField(
                        controller: controller.customCategoryController,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          hintText: 'Enter custom category name',
                          hintStyle: const TextStyle(color: AppColors.textColorHint, fontSize: 13),
                          filled: true,
                          fillColor: AppColors.slate50,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.5),
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 18),

                  // 5. Priority & Status Row
                  Row(
                    children: [
                      // Priority
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel('Priority', true),
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
                                    value: priorityOptions.contains(pVal) ? pVal : 'Medium',
                                    isExpanded: true,
                                    dropdownColor: Colors.white,
                                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textColorHint),
                                    items: priorityOptions.map((p) {
                                      return DropdownMenuItem<String>(
                                        value: p,
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: _getPriorityColor(p),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
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

                      // Status
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel('Status', true),
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
                                  final sVal = controller.selectedStatus.value;

                                  return DropdownButton<String>(
                                    value: statusOptions.contains(sVal) ? sVal : 'Pending',
                                    isExpanded: true,
                                    dropdownColor: Colors.white,
                                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textColorHint),
                                    items: statusOptions.map((st) {
                                      return DropdownMenuItem<String>(
                                        value: st,
                                        child: AppText(
                                          st,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textColorPrimary,
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) controller.selectedStatus.value = val;
                                    },
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // 6. Start Date & Due Date Row
                  Row(
                    children: [
                      // Start Date
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel('Start Date', true),
                            const SizedBox(height: 6),
                            GestureDetector(
                              onTap: () => _pickDate(isStartDate: true),
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
                                    const Icon(Iconsax.calendar_1, color: AppColors.primaryColor, size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Obx(() {
                                        return AppText(
                                          _formatDisplayDate(controller.startDate.value),
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
                      const SizedBox(width: 14),

                      // Due Date
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel('Due Date', true),
                            SizedBox(height: 6),
                            GestureDetector(
                              onTap: () => _pickDate(isStartDate: false),
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
                                    const Icon(Iconsax.calendar_tick, color: AppColors.errorColor, size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Obx(() {
                                        return AppText(
                                          _formatDisplayDate(controller.dueDate.value),
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
                  const SizedBox(height: 18),

                  // 7. Estimated Hours (e.g. "05h 30m")
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildFieldLabel('Estimated Hours', true),
                      GestureDetector(
                        onTap: () => _showHoursBottomSheet(context),
                        child: const Row(
                          children: [
                            Icon(Iconsax.edit, size: 13, color: AppColors.primaryColor),
                            SizedBox(width: 4),
                            AppText('Customize', fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.slate50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderColor),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _showHoursBottomSheet(context),
                            borderRadius: BorderRadius.circular(8),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Iconsax.timer_1, size: 18, color: AppColors.primaryColor),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Obx(() => AppText(
                                            controller.formattedEstimatedHours,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textColorPrimary,
                                          )),
                                      const SizedBox(height: 2),
                                      const AppText(
                                        'Allocated duration for completion',
                                        fontSize: 10,
                                        color: AppColors.textColorHint,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Quick inline steppers right on the card
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Material(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: () {
                                  if (controller.estimatedHours.value > 0) {
                                    controller.estimatedHours.value--;
                                  }
                                },
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.slate200),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.remove, size: 16, color: AppColors.textColorPrimary),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Material(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: () {
                                  if (controller.estimatedHours.value < 999) {
                                    controller.estimatedHours.value++;
                                  }
                                },
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.slate200),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.add, size: 16, color: AppColors.textColorPrimary),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Quick preset chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildQuickHourChip('01h 00m', 1, 0),
                        const SizedBox(width: 8),
                        _buildQuickHourChip('02h 00m', 2, 0),
                        const SizedBox(width: 8),
                        _buildQuickHourChip('04h 00m', 4, 0),
                        const SizedBox(width: 8),
                        _buildQuickHourChip('05h 30m', 5, 30),
                        const SizedBox(width: 8),
                        _buildQuickHourChip('08h 00m', 8, 0),
                        const SizedBox(width: 8),
                        _buildQuickHourChip('16h 00m', 16, 0),
                        const SizedBox(width: 8),
                        _buildQuickHourChip('40h 00m', 40, 0),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 8. Assign To Employees (Multi-Selection)
                  Obx(() {
                    final selectedCount = controller.selectedEmployees.isNotEmpty
                        ? controller.selectedEmployees.length
                        : controller.tempAssignees.length;

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            _buildFieldLabel('Assign To Employees', true),
                            if (selectedCount > 0) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: AppText(
                                  '$selectedCount selected',
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ],
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            if (controller.employeesList.isEmpty) {
                              controller.fetchEmployees();
                            }
                            Get.to(() => const AssignTaskScreen());
                          },
                          child: const Row(
                            children: [
                              Icon(Iconsax.user_add, size: 14, color: AppColors.primaryColor),
                              SizedBox(width: 4),
                              AppText('Manage Assignees', fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 8),
                  Obx(() {
                    final selectedEmps = controller.selectedEmployees;
                    final tempEmps = controller.tempAssignees;

                    if (selectedEmps.isEmpty && tempEmps.isEmpty) {
                      return InkWell(
                        onTap: () {
                          if (controller.employeesList.isEmpty) {
                            controller.fetchEmployees();
                          }
                          Get.to(() => const AssignTaskScreen());
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.slate50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderColor),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Iconsax.profile_2user, size: 20, color: AppColors.primaryColor),
                              SizedBox(width: 8),
                              AppText(
                                'Select employee(s) to assign',
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryColor,
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    // Multi-assigned employee cards list
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.slate50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              ...selectedEmps.map((emp) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.25)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _buildEmployeeAvatar(emp),
                                      const SizedBox(width: 8),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              AppText(
                                                emp.name,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textColorPrimary,
                                              ),
                                              if (emp.employeeId.isNotEmpty) ...[
                                                const SizedBox(width: 4),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.primaryLight,
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: AppText(
                                                    emp.employeeId,
                                                    fontSize: 8,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.primaryColor,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          if (emp.designation.isNotEmpty)
                                            AppText(
                                              emp.designation,
                                              fontSize: 9,
                                              color: AppColors.textColorSecondary,
                                            ),
                                        ],
                                      ),
                                      const SizedBox(width: 6),
                                      GestureDetector(
                                        onTap: () => controller.toggleEmployeeSelection(emp),
                                        child: const Icon(Icons.close_rounded, size: 14, color: AppColors.errorColor),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: TextButton.icon(
                              onPressed: () => Get.to(() => const AssignTaskScreen()),
                              icon: const Icon(Icons.add, size: 14),
                              label: const Text('Add more assignees'),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primaryColor,
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 18),

                  // 9. Attachments / Real File Uploads
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildFieldLabel('Attachments', false),
                      GestureDetector(
                        onTap: () => controller.pickRealFiles(),
                        child: const Row(
                          children: [
                            Icon(Iconsax.add, size: 14, color: AppColors.primaryColor),
                            SizedBox(width: 4),
                            AppText('Add Files', fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => controller.pickRealFiles(),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.slate50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderColor),
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
                            'Click to upload documents / files',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColorPrimary,
                          ),
                          const SizedBox(height: 4),
                          const AppText(
                            'Supports PDF, PNG, JPG, DOCX, ZIP files (Max 10MB)',
                            fontSize: 10,
                            color: AppColors.textColorHint,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Selected files list
                  Obx(() {
                    final realFiles = controller.attachedRealFiles;
                    if (realFiles.isEmpty) return const SizedBox.shrink();

                    return Column(
                      children: realFiles.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final file = entry.value;
                        final sizeKb = (file.size / 1024).toStringAsFixed(1);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.slate50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.borderColor),
                          ),
                          child: Row(
                            children: [
                              const Icon(Iconsax.document_text5, color: AppColors.primaryColor, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppText(
                                      file.name,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textColorPrimary,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    AppText(
                                      '$sizeKb KB • ${file.extension?.toUpperCase() ?? 'FILE'}',
                                      fontSize: 9,
                                      color: AppColors.textColorHint,
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.errorColor),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () => controller.removeAttachedFile(idx),
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
          child: Obx(() {
            final isLoading = controller.isCreatingTask.value || controller.isUpdatingTask.value;

            return SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  disabledBackgroundColor: AppColors.primaryColor.withValues(alpha: 0.6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : AppText(
                        widget.isEditMode ? 'Update Task' : 'Create Task',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildQuickHourChip(String label, int h, int m) {
    return Obx(() {
      final isSelected = controller.estimatedHours.value == h && controller.estimatedMinutes.value == m;

      return GestureDetector(
        onTap: () {
          controller.estimatedHours.value = h;
          controller.estimatedMinutes.value = m;
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryColor : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.primaryColor : AppColors.borderColor,
            ),
          ),
          child: AppText(
            label,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textColorSecondary,
          ),
        ),
      );
    });
  }
}
