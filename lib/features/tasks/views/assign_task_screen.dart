import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../employee/management/models/employee_model.dart';
import '../../projects/controllers/projects_controller.dart';
import '../controllers/tasks_controller.dart';

class AssignTaskScreen extends StatefulWidget {
  const AssignTaskScreen({super.key});

  @override
  State<AssignTaskScreen> createState() => _AssignTaskScreenState();
}

class _AssignTaskScreenState extends State<AssignTaskScreen> {
  final controller = Get.find<TasksController>();
  final projController = Get.isRegistered<ProjectsController>()
      ? Get.find<ProjectsController>()
      : Get.put(ProjectsController());

  @override
  void initState() {
    super.initState();
    // Ensure employees are fetched
    if (controller.employeesList.isEmpty) {
      if (projController.employeesList.isNotEmpty) {
        controller.employeesList.assignAll(projController.employeesList);
      } else {
        controller.fetchEmployees();
      }
    }
  }

  Widget _buildAvatar(EmployeeModel emp) {
    if (emp.profilePic != null && emp.profilePic!.trim().isNotEmpty) {
      final imgUrl = emp.profilePic!.startsWith('http')
          ? emp.profilePic!
          : '${AppConstants.baseUrl}/storage/${emp.profilePic}';
      return CircleAvatar(
        radius: 20,
        backgroundColor: AppColors.slate100,
        backgroundImage: NetworkImage(imgUrl),
        onBackgroundImageError: (exception, stackTrace) {},
        child: emp.name.isNotEmpty
            ? Text(
                emp.name[0].toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryColor, fontSize: 13),
              )
            : null,
      );
    }

    return CircleAvatar(
      radius: 20,
      backgroundColor: AppColors.primaryLight,
      child: Text(
        emp.name.isNotEmpty ? emp.name[0].toUpperCase() : 'E',
        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryColor, fontSize: 13),
      ),
    );
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
            const AppText(
              'Assign Task',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textColorPrimary,
            ),
            Obx(() {
              final count = controller.selectedEmployees.length;
              return AppText(
                count == 0
                    ? 'Select employees to assign'
                    : '$count employee${count > 1 ? 's' : ''} selected',
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: count > 0 ? AppColors.primaryColor : AppColors.textColorHint,
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const AppText(
              'Done',
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search Employee Box
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.slate100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                onChanged: (val) => controller.employeeSearchQuery.value = val,
                style: const TextStyle(fontSize: 13),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Iconsax.search_normal_1, color: AppColors.textColorHint, size: 18),
                  hintText: 'Search by employee name, role or ID...',
                  hintStyle: TextStyle(color: AppColors.textColorHint, fontSize: 13),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          // Selected Employees Chips Strip (Multi-Selection)
          Obx(() {
            final selected = controller.selectedEmployees;
            if (selected.isEmpty) return const SizedBox.shrink();

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: AppColors.slate200, width: 0.8)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Iconsax.profile_2user, size: 14, color: AppColors.primaryColor),
                          const SizedBox(width: 6),
                          AppText(
                            'Selected (${selected.length})',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          controller.selectedEmployees.clear();
                          controller.tempAssignees.clear();
                          controller.selectedEmployees.refresh();
                          controller.tempAssignees.refresh();
                        },
                        child: const AppText(
                          'Clear All',
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.errorColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: selected.map((emp) {
                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 11,
                                backgroundColor: AppColors.primaryColor,
                                child: Text(
                                  emp.name.isNotEmpty ? emp.name[0].toUpperCase() : 'E',
                                  style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AppText(
                                    emp.name,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryColor,
                                  ),
                                  if (emp.employeeId.isNotEmpty)
                                    AppText(
                                      emp.employeeId,
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
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          }),

          // Employees Checklist Feed
          Expanded(
            child: Obx(() {
              if (controller.isLoadingEmployees.value && controller.employeesList.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: AppColors.primaryColor),
                      SizedBox(height: 12),
                      AppText('Loading employees from server...', fontSize: 12, color: AppColors.textColorSecondary),
                    ],
                  ),
                );
              }

              final filteredEmps = controller.filteredEmployeesList;

              if (filteredEmps.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Iconsax.user_remove, size: 40, color: AppColors.textColorHint),
                      const SizedBox(height: 12),
                      const AppText('No Employees Found', fontSize: 14, fontWeight: FontWeight.bold),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () => controller.fetchEmployees(),
                        icon: const Icon(Icons.refresh_rounded, size: 16),
                        label: const Text('Retry Fetching'),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: filteredEmps.length,
                separatorBuilder: (context, idx) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final emp = filteredEmps[index];
                  final role = emp.designation.isNotEmpty ? emp.designation : emp.role;

                  return Obx(() {
                    final isSelected = controller.isEmployeeSelected(emp);

                    return GestureDetector(
                      onTap: () => controller.toggleEmployeeSelection(emp),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primaryLight.withValues(alpha: 0.45) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? AppColors.primaryColor : AppColors.borderColor,
                            width: isSelected ? 1.8 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.primaryColor.withValues(alpha: 0.08),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : null,
                        ),
                        child: Row(
                          children: [
                            // Avatar
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? AppColors.primaryColor : AppColors.borderColor,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: _buildAvatar(emp),
                            ),
                            const SizedBox(width: 14),
                            // Name, Role & ID
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: AppText(
                                          emp.name,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected ? AppColors.primaryColor : AppColors.textColorPrimary,
                                          maxLines: 1,
                                        ),
                                      ),
                                      if (isSelected)
                                        Container(
                                          margin: const EdgeInsets.only(right: 6),
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryColor,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const AppText(
                                            'Selected',
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        )
                                      else if (emp.employeeId.isNotEmpty)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.slate100,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: AppText(
                                            emp.employeeId,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textColorSecondary,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: AppText(
                                          role,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textColorSecondary,
                                          maxLines: 1,
                                        ),
                                      ),
                                      if (emp.department.isNotEmpty)
                                        AppText(
                                          '• ${emp.department}',
                                          fontSize: 10,
                                          color: AppColors.textColorHint,
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Checkbox for Multi-Selection
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(7),
                                color: isSelected ? AppColors.primaryColor : Colors.white,
                                border: Border.all(
                                  color: isSelected ? AppColors.primaryColor : AppColors.slate300,
                                  width: isSelected ? 2 : 1.5,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check_rounded,
                                      color: Colors.white,
                                      size: 16,
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    );
                  });
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
          child: Obx(() {
            final count = controller.selectedEmployees.length.clamp(
              controller.tempAssignees.length,
              9999,
            );

            return SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: AppText(
                  count == 0
                      ? 'Assign to Employees'
                      : count == 1
                          ? 'Assign to 1 Employee'
                          : 'Assign to $count Employees',
                  fontSize: 13,
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
}
