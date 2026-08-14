import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/app_input_field.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/utils/custom_snackbar.dart';
import '../controllers/designation_controller.dart';
import '../../management/controllers/employee_controller.dart';
import '../../management/models/employee_model.dart';


class AddDesignationScreen extends StatefulWidget {
  const AddDesignationScreen({super.key});

  @override
  State<AddDesignationScreen> createState() => _AddDesignationScreenState();
}

class _AddDesignationScreenState extends State<AddDesignationScreen> {
  final designationController = Get.find<DesignationController>();
  final employeeController = Get.find<EmployeeController>();

  final nameController = TextEditingController();
  String selectedHierarchy = 'Junior'; // Default
  final RxList<String> selectedEmployeeIds = <String>[].obs;

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const AppText('Add Designation', fontSize: 18, fontWeight: FontWeight.w700),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Name Input ──
            const AppText(
              'Designation Name',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textColorPrimary,
            ),
            const SizedBox(height: 8),
            AppInputField(
              hint: 'e.g. Senior Flutter Developer',
              controller: nameController,
              icon: Iconsax.user_tag,
            ),
            const SizedBox(height: 24),

            // ── Hierarchy Level Selection ──
            const AppText(
              'Hierarchy Level',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textColorPrimary,
            ),
            const SizedBox(height: 12),
            Row(
              children: ['Junior', 'Senior', 'Manager'].map((level) {
                final isSelected = selectedHierarchy == level;
                Color activeColor;
                Color inactiveColor = AppColors.slate100;
                
                switch (level) {
                  case 'Junior':
                    activeColor = const Color(0xFF10B981); // Emerald
                    break;
                  case 'Senior':
                    activeColor = const Color(0xFF3B82F6); // Blue
                    break;
                  case 'Manager':
                    activeColor = const Color(0xFF8B5CF6); // Purple
                    break;
                  default:
                    activeColor = AppColors.primaryColor;
                }

                return Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: ChoiceChip(
                    label: AppText(
                      level,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppColors.textColorSecondary,
                    ),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) {
                        setState(() => selectedHierarchy = level);
                      }
                    },
                    selectedColor: activeColor,
                    backgroundColor: inactiveColor,
                    checkmarkColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected ? activeColor : AppColors.slate200,
                        width: 1,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),

            // ── Assign Designation to Employees ──
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Iconsax.user_add, color: AppColors.primaryColor, size: 18),
                ),
                const SizedBox(width: 10),
                const AppText(
                  'Assign to Employees',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textColorPrimary,
                ),
              ],
            ),
            const SizedBox(height: 12),

            Obx(() {
              final employees = employeeController.employees;
              if (employees.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.slate200),
                  ),
                  child: const Center(
                    child: AppText(
                      'No employees available to assign',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColorSecondary,
                    ),
                  ),
                );
              }

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.slate200),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: employees.length,
                  separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  itemBuilder: (context, index) {
                    final emp = employees[index];
                    return Obx(() {
                      final isSelected = selectedEmployeeIds.contains(emp.id);
                      return CheckboxListTile(
                        value: isSelected,
                        activeColor: AppColors.primaryColor,
                        checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        onChanged: (val) {
                          if (val == true) {
                            selectedEmployeeIds.add(emp.id);
                          } else {
                            selectedEmployeeIds.remove(emp.id);
                          }
                        },
                        title: AppText(emp.name, fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
                        subtitle: AppText(
                          emp.designation.isEmpty ? 'No designation yet' : emp.designation,
                          fontSize: 11,
                          color: AppColors.textColorSecondary,
                        ),
                        secondary: emp.profilePic != null
                            ? CircleAvatar(
                                radius: 18,
                                backgroundImage: NetworkImage(emp.profilePic!),
                              )
                            : CircleAvatar(
                                radius: 18,
                                backgroundColor: AppColors.primaryLight,
                                child: AppText(
                                  emp.name.substring(0, 1).toUpperCase(),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                      );
                    });
                  },
                ),
              );
            }),
            const SizedBox(height: 36),

            // ── Save Button ──
            AppButton(
              text: 'Save Designation',
              onPressed: () {
                final designationName = nameController.text.trim();
                if (designationName.isEmpty) {
                  CustomSnackbar.showError('Please enter designation name');
                  return;
                }

                // Save designation in controller
                designationController.addDesignation(designationName, selectedHierarchy);

                // Update selected employees with the new designation
                for (final empId in selectedEmployeeIds) {
                  final empIndex = employeeController.employees.indexWhere((e) => e.id == empId);
                  if (empIndex != -1) {
                    final currentEmp = employeeController.employees[empIndex];
                    final updatedEmp = EmployeeModel(
                      id: currentEmp.id,
                      employeeId: currentEmp.employeeId,
                      name: currentEmp.name,
                      mobile: currentEmp.mobile,
                      email: currentEmp.email,
                      designation: designationName,
                      salary: currentEmp.salary,
                      skills: currentEmp.skills,
                      joiningDate: currentEmp.joiningDate,
                      address: currentEmp.address,
                      emergencyContact: currentEmp.emergencyContact,
                      profilePic: currentEmp.profilePic,
                    );
                    employeeController.updateEmployee(updatedEmp);
                  }
                }

                CustomSnackbar.showSuccess('Designation added & employees assigned successfully');
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }
}
