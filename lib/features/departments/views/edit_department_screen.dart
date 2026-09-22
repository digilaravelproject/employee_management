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
                        InkWell(
                          onTap: () => _showEmployeesSelectionSheet(context, controller),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: [
                                Icon(Iconsax.user_add, size: 14, color: AppColors.primaryColor),
                                SizedBox(width: 6),
                                AppText('Add Employees', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 10),

                  Obx(() {
                    final employeesList = controller.selectedEmployees;
                    final deptId = controller.selectedApiDepartment.value?.id.toString() ??
                        controller.selectedDepartment.value?.id;

                    if (employeesList.isEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFF1F5F9)),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.slate50,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Iconsax.profile_2user, size: 28, color: AppColors.textColorHint),
                            ),
                            const SizedBox(height: 12),
                            const AppText(
                              'No employees assigned yet',
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColorPrimary,
                            ),
                            const SizedBox(height: 4),
                            const AppText(
                              'Add employees to manage tasks and roles under this department.',
                              fontSize: 11,
                              textAlign: TextAlign.center,
                              color: AppColors.textColorHint,
                            ),
                            const SizedBox(height: 14),
                            ElevatedButton.icon(
                              onPressed: () => _showEmployeesSelectionSheet(context, controller),
                              icon: const Icon(Iconsax.add, size: 16, color: Colors.white),
                              label: const AppText('Add Employees', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              ),
                            ),
                          ],
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
                          final isHead = controller.selectedHead.value?.id == emp.id;

                          return Row(
                            children: [
                              emp.avatar != null && emp.avatar!.isNotEmpty
                                  ? CircleAvatar(
                                      radius: 20,
                                      backgroundImage: NetworkImage(emp.avatar!),
                                    )
                                  : CircleAvatar(
                                      radius: 20,
                                      backgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
                                      child: AppText(
                                        emp.name.isNotEmpty ? emp.name[0].toUpperCase() : '?',
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: AppText(
                                            emp.name,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textColorPrimary,
                                          ),
                                        ),
                                        if (isHead) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: const AppText(
                                              'HEAD',
                                              fontSize: 8,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFF6366F1),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    AppText(emp.email, fontSize: 10, color: AppColors.textColorHint),
                                    if (emp.designation != null && emp.designation!.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      AppText(
                                        emp.designation!,
                                        fontSize: 10,
                                        color: AppColors.primaryColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Iconsax.trash, color: Colors.redAccent, size: 18),
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.all(6),
                                onPressed: () {
                                  if (deptId != null && controller.repository != null) {
                                    _showRemoveEmployeeConfirmation(
                                      context,
                                      controller,
                                      deptId,
                                      emp.id.toString(),
                                      emp.name,
                                    );
                                  } else {
                                    controller.removeEmployee(emp);
                                  }
                                },
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

  void _showRemoveEmployeeConfirmation(
    BuildContext context,
    DepartmentsController controller,
    String departmentId,
    String employeeId,
    String employeeName,
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
              child: const Icon(Iconsax.trash, color: AppColors.errorColor, size: 18),
            ),
            const SizedBox(width: 10),
            const AppText('Remove Employee', fontSize: 15, fontWeight: FontWeight.bold),
          ],
        ),
        content: AppText(
          'Are you sure you want to remove "$employeeName" from this department?',
          fontSize: 13,
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
              await controller.removeEmployeeFromDepartmentApi(departmentId, employeeId);
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

  // Show bottom sheet to choose Department Head
  void _showHeadSelectionSheet(BuildContext context, DepartmentsController controller) {
    final available = controller.availableEmployees;
    final searchFilter = ''.obs;

    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
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
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText('Select Department Head', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
                    SizedBox(height: 2),
                    AppText('Choose the leader for this department', fontSize: 11, color: AppColors.textColorHint),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textColorHint),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              onChanged: (val) => searchFilter.value = val.trim().toLowerCase(),
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search employee by name, role...',
                hintStyle: const TextStyle(fontSize: 12, color: AppColors.textColorHint),
                prefixIcon: const Icon(Iconsax.search_normal, size: 16, color: AppColors.textColorHint),
                filled: true,
                fillColor: AppColors.slate50,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Obx(() {
                final query = searchFilter.value;
                final filtered = query.isEmpty
                    ? available
                    : available.where((e) {
                        return e.name.toLowerCase().contains(query) ||
                            e.email.toLowerCase().contains(query) ||
                            (e.designation != null && e.designation!.toLowerCase().contains(query));
                      }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: AppText('No matching employees found', fontSize: 12, color: AppColors.textColorHint),
                  );
                }

                return ListView.separated(
                  itemCount: filtered.length,
                  physics: const BouncingScrollPhysics(),
                  separatorBuilder: (context, index) => const Divider(height: 16, color: Color(0xFFF1F5F9)),
                  itemBuilder: (context, index) {
                    final user = filtered[index];
                    final isSelected = controller.selectedHead.value?.id == user.id;

                    return InkWell(
                      onTap: () {
                        controller.assignHead(user);
                        Get.back();
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
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
                                    AppText(user.designation!, fontSize: 9, color: AppColors.primaryColor, fontWeight: FontWeight.w600),
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
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  // Show bottom sheet to multi-select and add employees via API
  void _showEmployeesSelectionSheet(BuildContext context, DepartmentsController controller) {
    final available = controller.availableEmployees;
    final deptId = controller.selectedApiDepartment.value?.id.toString() ??
        controller.selectedDepartment.value?.id;

    // Track IDs selected in this sheet modal
    final RxList<int> selectedIds = <int>[].obs;
    final RxString searchFilter = ''.obs;

    // Pre-populate with currently assigned employees
    for (final emp in controller.selectedEmployees) {
      if (!selectedIds.contains(emp.id)) {
        selectedIds.add(emp.id);
      }
    }

    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Top Header & Drag handle
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const AppText(
                            'Add Employees',
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColorPrimary,
                          ),
                          const SizedBox(height: 2),
                          Obx(() => AppText(
                                '${selectedIds.length} of ${available.length} employees selected',
                                fontSize: 11,
                                color: AppColors.textColorHint,
                              )),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textColorHint),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Search Bar
                  TextField(
                    onChanged: (val) => searchFilter.value = val.trim().toLowerCase(),
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Search by name, designation, email...',
                      hintStyle: const TextStyle(fontSize: 12, color: AppColors.textColorHint),
                      prefixIcon: const Icon(Iconsax.search_normal, size: 16, color: AppColors.textColorHint),
                      filled: true,
                      fillColor: AppColors.slate50,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Quick Actions Row
                  Obx(() {
                    final query = searchFilter.value;
                    final filtered = query.isEmpty
                        ? available
                        : available.where((e) {
                            return e.name.toLowerCase().contains(query) ||
                                e.email.toLowerCase().contains(query) ||
                                (e.designation != null && e.designation!.toLowerCase().contains(query)) ||
                                (e.employeeId != null && e.employeeId!.toLowerCase().contains(query));
                          }).toList();

                    final allFilteredSelected = filtered.isNotEmpty &&
                        filtered.every((e) => selectedIds.contains(e.id));

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AppText(
                          '${filtered.length} Employees Available',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColorSecondary,
                        ),
                        InkWell(
                          onTap: () {
                            if (allFilteredSelected) {
                              for (final e in filtered) {
                                selectedIds.remove(e.id);
                              }
                            } else {
                              for (final e in filtered) {
                                if (!selectedIds.contains(e.id)) {
                                  selectedIds.add(e.id);
                                }
                              }
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            child: AppText(
                              allFilteredSelected ? 'Deselect All' : 'Select All',
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),

            const Divider(height: 1, color: Color(0xFFF1F5F9)),

            // Employee List
            Expanded(
              child: Obx(() {
                final query = searchFilter.value;
                final filtered = query.isEmpty
                    ? available
                    : available.where((e) {
                        return e.name.toLowerCase().contains(query) ||
                            e.email.toLowerCase().contains(query) ||
                            (e.designation != null && e.designation!.toLowerCase().contains(query)) ||
                            (e.employeeId != null && e.employeeId!.toLowerCase().contains(query));
                      }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Iconsax.search_status, size: 40, color: AppColors.textColorHint.withValues(alpha: 0.4)),
                        const SizedBox(height: 10),
                        const AppText('No matching employees found', fontSize: 13, color: AppColors.textColorSecondary),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: filtered.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  physics: const BouncingScrollPhysics(),
                  separatorBuilder: (context, index) => const Divider(height: 12, color: Color(0xFFF8FAFC)),
                  itemBuilder: (context, index) {
                    final user = filtered[index];

                    return Obx(() {
                      final isSelected = selectedIds.contains(user.id);
                      final isAlreadyAssigned = controller.selectedEmployees.any((e) => e.id == user.id);

                      return InkWell(
                        onTap: () {
                          if (selectedIds.contains(user.id)) {
                            selectedIds.remove(user.id);
                          } else {
                            selectedIds.add(user.id);
                          }
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryColor.withValues(alpha: 0.08)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryColor
                                  : const Color(0xFFE2E8F0),
                              width: isSelected ? 1.5 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Avatar
                              user.avatar != null && user.avatar!.isNotEmpty
                                  ? CircleAvatar(
                                      radius: 20,
                                      backgroundImage: NetworkImage(user.avatar!),
                                    )
                                  : CircleAvatar(
                                      radius: 20,
                                      backgroundColor: AppColors.primaryColor.withValues(alpha: 0.12),
                                      child: AppText(
                                        user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                              const SizedBox(width: 12),
                              // Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: AppText(
                                            user.name,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textColorPrimary,
                                          ),
                                        ),
                                        if (isAlreadyAssigned) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF10B981).withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: const AppText(
                                              'Assigned',
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF10B981),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    AppText(user.email, fontSize: 10, color: AppColors.textColorHint),
                                    Row(
                                      children: [
                                        if (user.designation != null && user.designation!.isNotEmpty) ...[
                                          AppText(
                                            user.designation!,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primaryColor,
                                          ),
                                        ],
                                        if (user.employeeId != null && user.employeeId!.isNotEmpty) ...[
                                          if (user.designation != null && user.designation!.isNotEmpty)
                                            const AppText(' • ', fontSize: 9, color: AppColors.textColorHint),
                                          AppText(
                                            user.employeeId!,
                                            fontSize: 9,
                                            color: AppColors.textColorHint,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Checkbox
                              Icon(
                                isSelected ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                                color: isSelected ? AppColors.primaryColor : const Color(0xFF94A3B8),
                                size: 26,
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

            // Bottom Action Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Obx(() {
                  final isAdding = controller.isAddingEmployees.value;
                  final count = selectedIds.length;

                  return SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: (count == 0 || isAdding)
                          ? null
                          : () async {
                              final selectedMembers = available
                                  .where((e) => selectedIds.contains(e.id))
                                  .toList();

                              if (deptId != null && controller.repository != null) {
                                // Hit API: POST /api/admin/departments/{id}/employees with {"employee_ids": [...]}
                                final newIdsToAdd = selectedIds.toList();
                                final success = await controller.addEmployeesToDepartment(deptId, newIdsToAdd);
                                if (success) {
                                  Get.back();
                                }
                              } else {
                                // Local selection for create flow
                                controller.selectedEmployees.assignAll(selectedMembers);
                                Get.back();
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        disabledBackgroundColor: AppColors.primaryColor.withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: isAdding
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : AppText(
                              deptId != null
                                  ? (count > 0 ? 'Add ($count) Employees to Department' : 'Select Employees to Add')
                                  : (count > 0 ? 'Done ($count Selected)' : 'Select Employees'),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}

