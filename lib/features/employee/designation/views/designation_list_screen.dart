import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../routes/route_helper.dart';
import '../controllers/designation_controller.dart';
import '../models/designation_model.dart';
import '../../management/controllers/employee_controller.dart';
import '../../management/models/employee_model.dart';
import 'add_designation_screen.dart';
import '../../../../core/utils/custom_snackbar.dart';

class DesignationListScreen extends StatelessWidget {
  const DesignationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DesignationController>();
    final employeeController = Get.put(EmployeeController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const AppText('Designations', fontSize: 18, fontWeight: FontWeight.w700),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // ── Search Bar ──
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              height: 50,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: controller.searchDesignation,
                      decoration: const InputDecoration(
                        hintText: 'Search designation...',
                        prefixIcon: Icon(Iconsax.search_normal, size: 18, color: AppColors.textColorHint),
                        hintStyle: TextStyle(fontSize: 14, color: AppColors.textColorHint),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── List ──
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.filteredDesignations.isEmpty) {
                return const Center(child: AppText('No designations found', color: AppColors.textColorSecondary));
              }
              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: controller.filteredDesignations.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final designation = controller.filteredDesignations[index];

                  // Count currently assigned employees
                  final assignedCount = employeeController.employees
                      .where((e) => e.designation.toLowerCase() == designation.name.toLowerCase())
                      .length;

                  // Define levels styling
                  Color levelColor;
                  switch (designation.hierarchyLevel) {
                    case 'Junior':
                      levelColor = const Color(0xFF10B981); // Emerald
                      break;
                    case 'Senior':
                      levelColor = const Color(0xFF3B82F6); // Blue
                      break;
                    case 'Manager':
                      levelColor = const Color(0xFF8B5CF6); // Purple
                      break;
                    default:
                      levelColor = AppColors.primaryColor;
                  }

                  return Container(
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
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => _showDesignationDetailsSheet(context, designation, employeeController),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: levelColor.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(Iconsax.user_tag, color: levelColor, size: 24),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: AppText(
                                            designation.name,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.textColorPrimary,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: levelColor.withValues(alpha: 0.08),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: AppText(
                                            designation.hierarchyLevel,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                            color: levelColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Iconsax.profile_2user, size: 14, color: AppColors.textColorHint),
                                        const SizedBox(width: 6),
                                        AppText(
                                          '$assignedCount assigned employee(s)',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textColorSecondary,
                                        ),
                                      ],
                                    ),
                                    if (designation.skills.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 4,
                                        children: [
                                          ...designation.skills.take(3).map((s) => Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: AppColors.slate100,
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: AppText(
                                                  s,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.textColorSecondary,
                                                ),
                                              )),
                                          if (designation.skills.length > 3)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: AppColors.slate100,
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: AppText(
                                                '+${designation.skills.length - 3}',
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.textColorSecondary,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(width: 4),
                              PopupMenuButton<String>(
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.more_vert_rounded, color: AppColors.textColorHint, size: 20),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                elevation: 4,
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    Get.to(() => AddDesignationScreen(designation: designation));
                                  } else if (value == 'delete') {
                                    _showDeleteConfirmation(context, controller, designation, assignedCount);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Iconsax.edit_2, size: 16, color: AppColors.primaryColor),
                                        SizedBox(width: 10),
                                        AppText('Edit', fontSize: 13, fontWeight: FontWeight.w600),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Iconsax.trash, size: 16, color: AppColors.errorColor),
                                        SizedBox(width: 10),
                                        AppText('Delete', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.errorColor),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            })
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(RouteHelper.getAddDesignationRoute()),
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
      ),
    );
  }

  // ── DESIGNATION DETAILS BOTTOM SHEET ──
  void _showDesignationDetailsSheet(BuildContext context, DesignationModel shortDesignation, EmployeeController employeeController) {
    final controller = Get.find<DesignationController>();

    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: FutureBuilder<DesignationModel?>(
          future: controller.fetchDesignationDetails(shortDesignation.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final designation = snapshot.data ?? shortDesignation;

            Color levelColor;
            switch (designation.hierarchyLevel.toLowerCase()) {
              case 'junior':
                levelColor = const Color(0xFF10B981);
                break;
              case 'senior':
                levelColor = const Color(0xFF3B82F6);
                break;
              case 'manager':
                levelColor = const Color(0xFF8B5CF6);
                break;
              default:
                levelColor = AppColors.primaryColor;
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            designation.name,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textColorPrimary,
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: levelColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: AppText(
                              '${designation.hierarchyLevel.toUpperCase()} Level',
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: levelColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Iconsax.edit_2, color: AppColors.primaryColor, size: 20),
                          tooltip: 'Edit Designation',
                          onPressed: () {
                            Get.back();
                            Get.to(() => AddDesignationScreen(designation: designation));
                          },
                        ),
                        IconButton(
                          icon: const Icon(Iconsax.trash, color: AppColors.errorColor, size: 20),
                          tooltip: 'Delete Designation',
                          onPressed: () {
                            Get.back();
                            final assignedCount = designation.employees?.length ?? 0;
                            _showDeleteConfirmation(context, controller, designation, assignedCount);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: AppColors.textColorSecondary),
                          onPressed: () => Get.back(),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                if (designation.skills.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const AppText(
                    'Skills',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColorPrimary,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: designation.skills.map((skill) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.primaryColor.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: AppText(
                          skill,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                ],
                const SizedBox(height: 20),

                // Assigned list title & button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const AppText(
                      'Assigned Employees',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColorPrimary,
                    ),
                    GestureDetector(
                      onTap: () => _showEmployeeSelectionSheet(context, designation, employeeController),
                      child: const Row(
                        children: [
                          Icon(Iconsax.user_add, size: 14, color: AppColors.primaryColor),
                          SizedBox(width: 4),
                          AppText(
                            'Assign Employee',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Assigned list
                Expanded(
                  child: StatefulBuilder(builder: (context, setState) {
                    final assigned = designation.employees ?? [];

                    if (assigned.isEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.slate50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.slate100),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Iconsax.profile_delete, size: 40, color: AppColors.textColorHint.withValues(alpha: 0.5)),
                            const SizedBox(height: 8),
                            const AppText(
                              'No employees assigned to this designation',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textColorSecondary,
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: assigned.length,
                      separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      itemBuilder: (context, index) {
                        final emp = assigned[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              emp.avatar != null
                                  ? CircleAvatar(
                                      radius: 18,
                                      backgroundImage: NetworkImage(emp.avatar!),
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
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppText(emp.name, fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
                                    AppText(emp.email, fontSize: 10, color: AppColors.textColorHint),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: AppText(
                                  emp.status,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Iconsax.trash, color: AppColors.errorColor, size: 20),
                                tooltip: 'Remove Employee',
                                onPressed: () {
                                  _showRemoveEmployeeConfirmation(
                                    context,
                                    controller,
                                    designation.id,
                                    emp.id.toString(),
                                    emp.name,
                                    () {
                                      setState(() {
                                        designation.employees!.removeAt(index);
                                      });
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }),
                ),
              ],
            );
          },
        ),
      ),
      isScrollControlled: true,
    );
  }

  // ── ASSIGN EMPLOYEES TO DESIGNATION SHEET ──
  void _showEmployeeSelectionSheet(BuildContext context, DesignationModel designation, EmployeeController employeeController) {
    final selectedEmployees = <String>[].obs;

    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const AppText(
                  'Select Employees',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textColorPrimary,
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textColorSecondary),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const SizedBox(height: 6),
            AppText(
              'Assign employees to ${designation.name}.',
              fontSize: 12,
              color: AppColors.textColorHint,
            ),
            const SizedBox(height: 20),

            // Employee List (only those not assigned to this designation)
            Expanded(
              child: Obx(() {
                final available = employeeController.employees
                    .where((e) => e.designation.toLowerCase() != designation.name.toLowerCase())
                    .toList();

                if (available.isEmpty) {
                  return const Center(
                    child: AppText(
                      'All employees are already assigned to this designation',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColorSecondary,
                    ),
                  );
                }

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: available.length,
                  itemBuilder: (context, index) {
                    final emp = available[index];
                    return Obx(() {
                      final isSelected = selectedEmployees.contains(emp.id);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primaryLight : AppColors.slate50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? AppColors.primaryColor.withValues(alpha: 0.3) : AppColors.slate100,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            emp.profilePic != null
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
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText(emp.name, fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
                                  AppText(
                                    emp.designation.isEmpty ? 'No designation' : emp.designation,
                                    fontSize: 10,
                                    color: AppColors.textColorHint,
                                  ),
                                ],
                              ),
                            ),
                            Checkbox(
                              value: isSelected,
                              activeColor: AppColors.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              onChanged: (val) {
                                if (isSelected) {
                                  selectedEmployees.remove(emp.id);
                                } else {
                                  selectedEmployees.add(emp.id);
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 16),

            // Confirm Button
            Obx(() {
              final showButton = employeeController.employees
                  .any((e) => e.designation.toLowerCase() != designation.name.toLowerCase());
              if (!showButton) return const SizedBox();
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    for (final empId in selectedEmployees) {
                      final empIndex = employeeController.employees.indexWhere((e) => e.id == empId);
                      if (empIndex != -1) {
                        final currentEmp = employeeController.employees[empIndex];
                        final updatedEmp = EmployeeModel(
                          id: currentEmp.id,
                          employeeId: currentEmp.employeeId,
                          name: currentEmp.name,
                          mobile: currentEmp.mobile,
                          email: currentEmp.email,
                          designation: designation.name, // Set new designation
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
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const AppText('Assign Selected', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              );
            }),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    DesignationController controller,
    DesignationModel designation,
    int assignedCount,
  ) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.errorColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Iconsax.trash, color: AppColors.errorColor, size: 20),
            ),
            const SizedBox(width: 10),
            const AppText('Delete Designation', fontSize: 16, fontWeight: FontWeight.bold),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              'Are you sure you want to delete "${designation.name}"?',
              fontSize: 14,
              color: AppColors.textColorPrimary,
            ),
            if (assignedCount > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AppText(
                        '$assignedCount employee(s) currently assigned will have their designation unassigned.',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF92400E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const AppText('Cancel', color: AppColors.textColorSecondary, fontWeight: FontWeight.w600),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              final success = await controller.deleteDesignation(designation.id);
              if (success) {
                CustomSnackbar.showSuccess('Designation deleted successfully');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const AppText('Delete', color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _showRemoveEmployeeConfirmation(
    BuildContext context,
    DesignationController controller,
    String designationId,
    String employeeId,
    String employeeName,
    VoidCallback onSuccess,
  ) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.errorColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Iconsax.trash, color: AppColors.errorColor, size: 20),
            ),
            const SizedBox(width: 10),
            const AppText('Remove Employee', fontSize: 16, fontWeight: FontWeight.bold),
          ],
        ),
        content: AppText(
          'Are you sure you want to remove "$employeeName" from this designation?',
          fontSize: 14,
          color: AppColors.textColorPrimary,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const AppText('Cancel', color: AppColors.textColorSecondary, fontWeight: FontWeight.w600),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              final success = await controller.removeEmployeeFromDesignation(designationId, employeeId);
              if (success) {
                CustomSnackbar.showSuccess('Employee removed successfully');
                onSuccess();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const AppText('Remove', color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
