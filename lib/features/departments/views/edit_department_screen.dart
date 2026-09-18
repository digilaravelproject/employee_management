import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/departments_controller.dart';

class EditDepartmentScreen extends StatelessWidget {
  const EditDepartmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DepartmentsController>();

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
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textColorPrimary, size: 18),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              'Edit Department',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textColorPrimary,
            ),
            AppText(
              'Update department information',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textColorHint,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              final deptId = controller.selectedApiDepartment.value?.id.toString() ??
                  controller.selectedDepartment.value?.id;
              if (deptId != null) {
                _showDeleteConfirmation(context, controller, deptId);
              }
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: AppText(
                'Delete',
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Basic Info Card ──
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Department Name', true),
                        const SizedBox(height: 8),
                        TextField(
                          controller: controller.nameController,
                          style: const TextStyle(fontSize: 13, color: AppColors.textColorPrimary),
                          decoration: InputDecoration(
                            hintText: 'Enter department name',
                            hintStyle: const TextStyle(color: AppColors.textColorHint, fontSize: 13),
                            filled: true,
                            fillColor: AppColors.slate50,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        _buildLabel('Description', false),
                        const SizedBox(height: 8),
                        TextField(
                          controller: controller.descriptionController,
                          maxLines: 3,
                          style: const TextStyle(fontSize: 13, color: AppColors.textColorPrimary),
                          decoration: InputDecoration(
                            hintText: 'Enter department description',
                            hintStyle: const TextStyle(color: AppColors.textColorHint, fontSize: 13),
                            filled: true,
                            fillColor: AppColors.slate50,
                            contentPadding: const EdgeInsets.all(16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        _buildLabel('Status', false),
                        const SizedBox(height: 8),
                        Obx(() {
                          final isActive = controller.formStatus.value.toLowerCase() == 'active';
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.slate50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isActive ? Iconsax.tick_circle : Iconsax.close_circle,
                                  size: 18,
                                  color: isActive ? const Color(0xFF10B981) : AppColors.textColorHint,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: AppText(
                                    isActive ? 'Active' : 'Inactive',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isActive ? const Color(0xFF10B981) : AppColors.textColorHint,
                                  ),
                                ),
                                Switch(
                                  value: isActive,
                                  activeThumbColor: const Color(0xFF10B981),
                                  onChanged: (val) {
                                    controller.formStatus.value = val ? 'Active' : 'Inactive';
                                  },
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Department Head Card ──
                  _buildLabel('Department Head', false),
                  const SizedBox(height: 8),
                  Obx(() {
                    final head = controller.selectedHead.value;
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            if (head != null) ...[
                              head.avatar != null && head.avatar!.isNotEmpty
                                  ? CircleAvatar(
                                      radius: 20,
                                      backgroundImage: NetworkImage(head.avatar!),
                                    )
                                  : CircleAvatar(
                                      radius: 20,
                                      backgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
                                      child: AppText(
                                        head.name.isNotEmpty ? head.name[0].toUpperCase() : 'H',
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppText(head.name, fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
                                    const SizedBox(height: 2),
                                    AppText(head.email, fontSize: 10, color: AppColors.textColorHint),
                                    if (head.designation != null && head.designation!.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      AppText(head.designation!, fontSize: 10, color: AppColors.primaryColor, fontWeight: FontWeight.w600),
                                    ],
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close_rounded, color: AppColors.textColorSecondary, size: 20),
                                onPressed: () => controller.unassignHead(),
                              ),
                            ] else ...[
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.slate50,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Iconsax.profile_add, color: AppColors.textColorHint, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: InkWell(
                                  onTap: () => _showHeadSelectionSheet(context, controller),
                                  child: const Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      AppText('Select Department Head', fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
                                      SizedBox(height: 2),
                                      AppText('Choose the employee to lead this department', fontSize: 10, color: AppColors.textColorHint),
                                    ],
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textColorHint, size: 14),
                                onPressed: () => _showHeadSelectionSheet(context, controller),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 20),

                  // ── Assigned Employees Section ──
                  Obx(() {
                    final emps = controller.selectedEmployees;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildLabel('Assigned Employees (${emps.length})', false),
                        GestureDetector(
                          onTap: () => _showEmployeesSelectionSheet(context, controller),
                          child: const Row(
                            children: [
                              Icon(Iconsax.add, size: 14, color: AppColors.primaryColor),
                              SizedBox(width: 4),
                              AppText('Add Employees', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 8),

                  Obx(() {
                    final employeesList = controller.selectedEmployees;
                    if (employeesList.isEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFF1F5F9)),
                        ),
                        child: const Center(
                          child: AppText(
                            'No employees assigned to this department',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textColorHint,
                          ),
                        ),
                      );
                    }

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: employeesList.length,
                        separatorBuilder: (context, index) => const Divider(height: 20, color: Color(0xFFF1F5F9)),
                        itemBuilder: (context, index) {
                          final emp = employeesList[index];
                          return Row(
                            children: [
                              emp.avatar != null && emp.avatar!.isNotEmpty
                                  ? CircleAvatar(
                                      radius: 18,
                                      backgroundImage: NetworkImage(emp.avatar!),
                                    )
                                  : CircleAvatar(
                                      radius: 18,
                                      backgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
                                      child: AppText(
                                        emp.name.isNotEmpty ? emp.name[0].toUpperCase() : '?',
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppText(emp.name, fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
                                    const SizedBox(height: 2),
                                    AppText(emp.email, fontSize: 10, color: AppColors.textColorHint),
                                    if (emp.designation != null && emp.designation!.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      AppText(emp.designation!, fontSize: 9, color: AppColors.primaryColor),
                                    ],
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Iconsax.minus_cirlce, color: Colors.redAccent, size: 20),
                                onPressed: () => controller.removeEmployee(emp),
                              ),
                            ],
                          );
                        },
                      ),
                    );
                  }),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),

          // ── Bottom Update Button ──
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: Obx(() {
                  final isSaving = controller.isSaving.value;
                  return ElevatedButton(
                    onPressed: isSaving ? null : () => controller.updateDepartment(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      disabledBackgroundColor: AppColors.primaryColor.withValues(alpha: 0.6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const AppText(
                            'Update Department',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, bool isRequired) {
    return Row(
      children: [
        AppText(text, fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
        if (isRequired)
          const AppText(' *', fontSize: 13, fontWeight: FontWeight.bold, color: Colors.red),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context, DepartmentsController controller, String id) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const AppText('Delete Department', fontSize: 16, fontWeight: FontWeight.bold),
        content: const AppText('Are you sure you want to delete this department? This action is permanent.', fontSize: 13),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const AppText('Cancel', color: AppColors.textColorSecondary, fontWeight: FontWeight.w600),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteDepartment(id);
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

  // Show bottom sheet to choose Department Head
  void _showHeadSelectionSheet(BuildContext context, DepartmentsController controller) {
    final available = controller.availableEmployees;

    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.65,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: const BoxDecoration(color: Color(0xFFCBD5E1), borderRadius: BorderRadius.all(Radius.circular(10))),
              ),
            ),
            const SizedBox(height: 18),
            const AppText('Select Department Head', fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
            const SizedBox(height: 4),
            const AppText('Choose the employee to lead this department', fontSize: 11, color: AppColors.textColorHint),
            const SizedBox(height: 14),
            Expanded(
              child: ListView.separated(
                itemCount: available.length,
                physics: const BouncingScrollPhysics(),
                separatorBuilder: (context, index) => const Divider(height: 20, color: Color(0xFFF1F5F9)),
                itemBuilder: (context, index) {
                  final user = available[index];
                  return Obx(() {
                    final isSelected = controller.selectedHead.value?.id == user.id;
                    return InkWell(
                      onTap: () {
                        controller.assignHead(user);
                        Get.back();
                      },
                      child: Row(
                        children: [
                          user.avatar != null && user.avatar!.isNotEmpty
                              ? CircleAvatar(
                                  radius: 20,
                                  backgroundImage: NetworkImage(user.avatar!),
                                )
                              : CircleAvatar(
                                  radius: 20,
                                  backgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
                                  child: AppText(
                                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(user.name, fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
                                const SizedBox(height: 2),
                                AppText(user.email, fontSize: 10, color: AppColors.textColorHint),
                                if (user.designation != null && user.designation!.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  AppText(user.designation!, fontSize: 9, color: AppColors.primaryColor),
                                ],
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle_rounded, color: AppColors.primaryColor, size: 22)
                          else
                            const Icon(Icons.radio_button_off_rounded, color: AppColors.slate300, size: 22),
                        ],
                      ),
                    );
                  });
                },
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  // Show bottom sheet to multi-select employees
  void _showEmployeesSelectionSheet(BuildContext context, DepartmentsController controller) {
    final available = controller.availableEmployees;

    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.65,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: const BoxDecoration(color: Color(0xFFCBD5E1), borderRadius: BorderRadius.all(Radius.circular(10))),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText('Select Employees', fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
                    SizedBox(height: 2),
                    AppText('Assign employees to this department', fontSize: 11, color: AppColors.textColorHint),
                  ],
                ),
                TextButton(
                  onPressed: () => Get.back(),
                  child: const AppText('Done', fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Expanded(
              child: ListView.separated(
                itemCount: available.length,
                physics: const BouncingScrollPhysics(),
                separatorBuilder: (context, index) => const Divider(height: 20, color: Color(0xFFF1F5F9)),
                itemBuilder: (context, index) {
                  final user = available[index];
                  return Obx(() {
                    final isSelected = controller.selectedEmployees.any((e) => e.id == user.id);
                    return InkWell(
                      onTap: () => controller.toggleEmployeeSelection(user),
                      child: Row(
                        children: [
                          user.avatar != null && user.avatar!.isNotEmpty
                              ? CircleAvatar(
                                  radius: 20,
                                  backgroundImage: NetworkImage(user.avatar!),
                                )
                              : CircleAvatar(
                                  radius: 20,
                                  backgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
                                  child: AppText(
                                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(user.name, fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
                                const SizedBox(height: 2),
                                AppText(user.email, fontSize: 10, color: AppColors.textColorHint),
                                if (user.designation != null && user.designation!.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  AppText(user.designation!, fontSize: 9, color: AppColors.primaryColor),
                                ],
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_box_rounded, color: AppColors.primaryColor, size: 22)
                          else
                            const Icon(Icons.check_box_outline_blank_rounded, color: AppColors.slate300, size: 22),
                        ],
                      ),
                    );
                  });
                },
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
