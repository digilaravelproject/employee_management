import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/departments_controller.dart';

class AddDepartmentScreen extends StatelessWidget {
  const AddDepartmentScreen({super.key});

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
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textColorPrimary, size: 20),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              'Add Department',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textColorPrimary,
            ),
            AppText(
              'Create a new department',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textColorHint,
            ),
          ],
        ),
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
                  // ── Form Card ──
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
                        _buildLabel('Description', false, isOptional: true),
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                 /* // ── Department Head Card ──
                  _buildLabel('Department Head', true),
                  const SizedBox(height: 8),
                  Obx(() {
                    final head = controller.selectedHead.value;
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _showHeadSelectionSheet(context, controller),
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                if (head != null) ...[
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundImage: NetworkImage(head.avatarUrl),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        AppText(head.name, fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
                                        const SizedBox(height: 2),
                                        AppText(head.email, fontSize: 10, color: AppColors.textColorHint),
                                      ],
                                    ),
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
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        AppText('Select Department Head', fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
                                        SizedBox(height: 2),
                                        AppText('Choose the head for this department', fontSize: 10, color: AppColors.textColorHint),
                                      ],
                                    ),
                                  ),
                                ],
                                const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textColorHint, size: 14),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 20),

                  // ── Add Employees Section ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildLabel('Add Employees', false),
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
                  ),
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
                            'No employees added yet',
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
                              CircleAvatar(
                                radius: 18,
                                backgroundImage: NetworkImage(emp.avatarUrl),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppText(emp.name, fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
                                    const SizedBox(height: 2),
                                    AppText(emp.email, fontSize: 10, color: AppColors.textColorHint),
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
                  const SizedBox(height: 30),*/
                ],
              ),
            ),
          ),

          // ── Bottom Action Button ──
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => controller.saveDepartment(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const AppText(
                    'Save Department',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, bool isRequired, {bool isOptional = false}) {
    return Row(
      children: [
        AppText(text, fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
        if (isRequired)
          const AppText(' *', fontSize: 13, fontWeight: FontWeight.bold, color: Colors.red),
        if (isOptional)
          const AppText(' (Optional)', fontSize: 11, color: AppColors.textColorHint),
      ],
    );
  }

  // Show bottom sheet to choose Department Head
  void _showHeadSelectionSheet(BuildContext context, DepartmentsController controller) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                itemCount: controller.allEmployees.length,
                physics: const BouncingScrollPhysics(),
                separatorBuilder: (context, index) => const Divider(height: 20, color: Color(0xFFF1F5F9)),
                itemBuilder: (context, index) {
                  final user = controller.allEmployees[index];
                  return Obx(() {
                    final isSelected = controller.selectedHead.value == user;
                    return InkWell(
                      onTap: () {
                        controller.assignHead(user);
                        Get.back();
                      },
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: NetworkImage(user.avatarUrl),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(user.name, fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
                                const SizedBox(height: 2),
                                AppText(user.email, fontSize: 10, color: AppColors.textColorHint),
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
    );
  }

  // Show bottom sheet to multi-select employees
  void _showEmployeesSelectionSheet(BuildContext context, DepartmentsController controller) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                    AppText('Assign multiple employees to this department', fontSize: 11, color: AppColors.textColorHint),
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
                itemCount: controller.allEmployees.length,
                physics: const BouncingScrollPhysics(),
                separatorBuilder: (context, index) => const Divider(height: 20, color: Color(0xFFF1F5F9)),
                itemBuilder: (context, index) {
                  final user = controller.allEmployees[index];
                  return Obx(() {
                    final isSelected = controller.selectedEmployees.contains(user);
                    return InkWell(
                      onTap: () => controller.toggleEmployeeSelection(user),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: NetworkImage(user.avatarUrl),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(user.name, fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
                                const SizedBox(height: 2),
                                AppText(user.email, fontSize: 10, color: AppColors.textColorHint),
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
    );
  }
}
