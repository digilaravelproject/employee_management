import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../projects/controllers/projects_controller.dart';
import '../controllers/tasks_controller.dart';

class AssignTaskScreen extends StatefulWidget {
  const AssignTaskScreen({super.key});

  @override
  State<AssignTaskScreen> createState() => _AssignTaskScreenState();
}

class _AssignTaskScreenState extends State<AssignTaskScreen> {
  final controller = Get.find<TasksController>();
  final projController = Get.find<ProjectsController>();
  final RxString employeeQuery = ''.obs;

  String _getEmployeeRole(String name) {
    switch (name) {
      case 'John Smith':
        return 'Manager';
      case 'Sarah Johnson':
        return 'UI/UX Designer';
      case 'Michael Brown':
        return 'Backend Developer';
      case 'David Wilson':
        return 'Project Manager';
      case 'Emily Davis':
        return 'QA Engineer';
      case 'James Anderson':
        return 'DevOps Engineer';
      case 'Alex Johnson':
        return 'Frontend Developer';
      case 'Lisa Anderson':
        return 'Business Analyst';
      case 'Robert Taylor':
        return 'Mobile Developer';
      default:
        return 'Employee';
    }
  }

  @override
  Widget build(BuildContext context) {
    final emps = projController.allEmployees;

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
              'Assign Task',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textColorPrimary,
            ),
            AppText(
              'Select employees to assign',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textColorHint,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const AppText(
              'Next',
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
                onChanged: (val) => employeeQuery.value = val,
                style: const TextStyle(fontSize: 13),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Iconsax.search_normal_1, color: AppColors.textColorHint, size: 18),
                  hintText: 'Search employees...',
                  hintStyle: TextStyle(color: AppColors.textColorHint, fontSize: 13),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          // Employees Checklist Feed
          Expanded(
            child: Obx(() {
              final query = employeeQuery.value.toLowerCase();
              final filteredEmps = emps.where((emp) {
                return emp.name.toLowerCase().contains(query) ||
                    emp.email.toLowerCase().contains(query) ||
                    _getEmployeeRole(emp.name).toLowerCase().contains(query);
              }).toList();

              if (filteredEmps.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Iconsax.user_remove, size: 40, color: AppColors.textColorHint),
                      SizedBox(height: 12),
                      AppText('No Employees Found', fontSize: 14, fontWeight: FontWeight.bold),
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
                  final isSelected = controller.tempAssignees.contains(emp);
                  final role = _getEmployeeRole(emp.name);

                  return GestureDetector(
                    onTap: () => controller.toggleAssigneeSelection(emp),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? AppColors.primaryColor.withValues(alpha: 0.3) : AppColors.borderColor,
                          width: isSelected ? 1.5 : 1,
                        ),
                        boxShadow: isSelected ? [
                          BoxShadow(
                            color: AppColors.primaryColor.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ] : null,
                      ),
                      child: Row(
                        children: [
                          // Avatar
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? AppColors.primaryColor : AppColors.borderColor,
                                width: 1.5,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 20,
                              backgroundImage: NetworkImage(emp.avatarUrl),
                            ),
                          ),
                          const SizedBox(width: 14),
                          // Name & Designation
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(
                                  emp.name,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textColorPrimary,
                                ),
                                const SizedBox(height: 3),
                                AppText(
                                  role,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textColorSecondary,
                                ),
                              ],
                            ),
                          ),
                          // Custom Blue Checkbox
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primaryColor : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isSelected ? AppColors.primaryColor : AppColors.slate300,
                                width: 1.5,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 14,
                                  )
                                : null,
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
          child: Obx(() {
            final count = controller.tempAssignees.length;

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
