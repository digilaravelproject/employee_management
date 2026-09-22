import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/app_input_field.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/utils/custom_snackbar.dart';
import '../controllers/designation_controller.dart';
import '../models/designation_model.dart';
import '../../management/controllers/employee_controller.dart';


class AddDesignationScreen extends StatefulWidget {
  final DesignationModel? designation;
  const AddDesignationScreen({super.key, this.designation});

  @override
  State<AddDesignationScreen> createState() => _AddDesignationScreenState();
}

class _AddDesignationScreenState extends State<AddDesignationScreen> {
  late final DesignationController designationController;
  late final EmployeeController employeeController;

  final nameController = TextEditingController();
  final skillController = TextEditingController();
  String selectedHierarchy = 'Junior'; // Default
  final RxList<String> skills = <String>[].obs;
  final RxList<String> selectedEmployeeIds = <String>[].obs;

  DesignationModel? _designation;
  bool get isEditing => _designation != null;

  @override
  void initState() {
    super.initState();
    designationController = Get.isRegistered<DesignationController>()
        ? Get.find<DesignationController>()
        : Get.put(DesignationController());
    employeeController = Get.isRegistered<EmployeeController>()
        ? Get.find<EmployeeController>()
        : Get.put(EmployeeController());

    if (employeeController.employees.isEmpty) {
      employeeController.fetchEmployees(showLoader: false);
    }

    _designation = widget.designation ?? (Get.arguments is DesignationModel ? Get.arguments as DesignationModel : null);
    if (_designation != null) {
      nameController.text = _designation!.name;
      selectedHierarchy = _designation!.hierarchyLevel;
      skills.assignAll(_designation!.skills);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    skillController.dispose();
    super.dispose();
  }

  void _addSkill() {
    final skill = skillController.text.trim();
    if (skill.isEmpty) return;
    if (skills.any((s) => s.toLowerCase() == skill.toLowerCase())) {
      CustomSnackbar.showError('Skill "$skill" is already added');
      return;
    }
    skills.add(skill);
    skillController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: AppText(
          isEditing ? 'Edit Designation' : 'Add Designation',
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
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
            const SizedBox(height: 24),

            // ── Skills Section ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const AppText(
                  'Skills',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textColorPrimary,
                ),
                Obx(() => skills.isNotEmpty
                    ? AppText(
                        '${skills.length} added',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor,
                      )
                    : const SizedBox.shrink()),
              ],
            ),
            const SizedBox(height: 8),

            // Skill input with Add button on side
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppInputField(
                    hint: 'Type a skill (e.g. Flutter, Dart)',
                    controller: skillController,
                    icon: Iconsax.award,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _addSkill(),
                  ),
                ),
                const SizedBox(width: 10),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _addSkill,
                    borderRadius: BorderRadius.circular(16),
                    child: Ink(
                      height: 52,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryColor.withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_rounded, color: Colors.white, size: 20),
                          SizedBox(width: 4),
                          AppText(
                            'Add',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Skill chips displayed below
            Obx(() {
              if (skills.isEmpty) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: skills.map((skill) {
                    return Container(
                      padding: const EdgeInsets.only(left: 12, right: 8, top: 6, bottom: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primaryColor.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppText(
                            skill,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryColor,
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => skills.remove(skill),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                size: 14,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              );
            }),
            const SizedBox(height: 36),

            // ── Save / Update Button ──
            Obx(() => AppButton(
              text: isEditing ? 'Update Designation' : 'Save Designation',
              isLoading: designationController.isSaving.value,
              onPressed: () async {
                final designationName = nameController.text.trim();
                if (designationName.isEmpty) {
                  CustomSnackbar.showError('Please enter designation name');
                  return;
                }

                bool success = false;
                if (isEditing) {
                  success = await designationController.updateDesignation(
                    _designation!.id,
                    designationName,
                    selectedHierarchy,
                    skills: skills.toList(),
                  );
                  if (success) {
                    CustomSnackbar.showSuccess('Designation updated successfully');
                  }
                } else {
                  // Save designation in controller
                  success = await designationController.addDesignation(
                    designationName,
                    selectedHierarchy,
                    skills: skills.toList(),
                  );
                  if (success) {
                    CustomSnackbar.showSuccess('Designation added successfully');
                  }
                }

                if (success) {
                  // Update selected employees with the designation if any selected
                  for (final empId in selectedEmployeeIds) {
                    final empIndex = employeeController.employees.indexWhere((e) => e.id == empId);
                    if (empIndex != -1) {
                      final currentEmp = employeeController.employees[empIndex];
                      final updatedEmp = currentEmp.copyWith(
                        designation: designationName,
                      );
                      employeeController.updateEmployee(updatedEmp);
                    }
                  }

                  Get.back();
                }
              },
            )),
          ],
        ),
      ),
    );
  }
}
