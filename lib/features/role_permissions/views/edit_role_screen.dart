import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../departments/controllers/departments_controller.dart';
import '../../employee/designation/controllers/designation_controller.dart';
import '../controllers/role_permissions_controller.dart';
import '../models/role_permission_models.dart';

class EditRoleScreen extends StatefulWidget {
  final Role role;
  const EditRoleScreen({super.key, required this.role});

  @override
  State<EditRoleScreen> createState() => _EditRoleScreenState();
}

class _EditRoleScreenState extends State<EditRoleScreen> {
  final List<String> _fallbackDepartments = [
    'Management',
    'Human Resources',
    'Engineering',
    'Sales & Marketing',
    'Operations',
    'Accounts & Finance',
    'Customer Support',
    'General',
  ];

  final List<String> _fallbackDesignations = [
    'Admin',
    'HR Manager',
    'Project Manager',
    'Team Lead',
    'Senior Flutter Developer',
    'UI/UX Designer',
    'PHP Developer',
    'Sales Executive',
    'Accountant',
    'Intern',
    'Staff',
  ];

  @override
  void initState() {
    super.initState();
    final controller = Get.find<RolePermissionsController>();
    controller.populateForEdit(widget.role);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RolePermissionsController>();

    List<String> departmentOptions = _fallbackDepartments;
    if (Get.isRegistered<DepartmentsController>()) {
      final deptCtrl = Get.find<DepartmentsController>();
      if (deptCtrl.departments.isNotEmpty) {
        final dynamicNames = deptCtrl.departments.map((d) => d.name).toList();
        departmentOptions = {...departmentOptions, ...dynamicNames}.toList();
      }
    }
    if (widget.role.departmentName != null &&
        !departmentOptions.contains(widget.role.departmentName!)) {
      departmentOptions.add(widget.role.departmentName!);
    }

    List<String> designationOptions = _fallbackDesignations;
    if (Get.isRegistered<DesignationController>()) {
      final desigCtrl = Get.find<DesignationController>();
      if (desigCtrl.designations.isNotEmpty) {
        final dynamicNames = desigCtrl.designations.map((d) => d.name).toList();
        designationOptions = {...designationOptions, ...dynamicNames}.toList();
      }
    }
    if (widget.role.designationName != null &&
        !designationOptions.contains(widget.role.designationName!)) {
      designationOptions.add(widget.role.designationName!);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textColorPrimary, size: 18),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText(
              'Edit Role',
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.textColorPrimary,
            ),
            AppText(
              'Modifying ${widget.role.name}',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textColorHint,
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ElevatedButton.icon(
              onPressed: () => controller.updateRole(widget.role.id),
              icon: const Icon(Icons.check_rounded, size: 16, color: Colors.white),
              label: const AppText(
                'Save Changes',
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ══════════════════════════════════════════════════
            // SECTION 1: ROLE INFORMATION
            // ══════════════════════════════════════════════════
            _buildSectionHeader(
              icon: Iconsax.user_tag,
              title: 'Section 1: Role Information',
              subtitle: 'Name, organizational classification & description',
            ),
            const SizedBox(height: 12),
            _buildRoleInfoCard(controller, departmentOptions, designationOptions),

            const SizedBox(height: 24),

            // ══════════════════════════════════════════════════
            // SECTION 2: GRANULAR PERMISSIONS MATRIX
            // ══════════════════════════════════════════════════
            _buildSectionHeader(
              icon: Iconsax.shield_security,
              title: 'Section 2: Granular Permissions',
              subtitle: 'Screen, card & action-level access controls',
            ),
            const SizedBox(height: 12),
            _buildQuickActionBar(controller),
            const SizedBox(height: 12),
            _buildPermissionsAccordionList(controller),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primaryColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                title,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textColorPrimary,
              ),
              const SizedBox(height: 2),
              AppText(
                subtitle,
                fontSize: 11,
                color: AppColors.textColorSecondary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoleInfoCard(
    RolePermissionsController controller,
    List<String> departmentOptions,
    List<String> designationOptions,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          _buildFieldLabel('Role Name', isRequired: true),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller.nameController,
            decoration: InputDecoration(
              hintText: 'e.g. Senior Flutter Developer / HR Executive',
              hintStyle: const TextStyle(color: AppColors.textColorHint, fontSize: 13),
              filled: true,
              fillColor: AppColors.slate50,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.slate200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.slate200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primaryColor),
              ),
            ),
          ),
          const SizedBox(height: 16),

          _buildFieldLabel('Department', isRequired: true),
          const SizedBox(height: 8),
          Obx(() {
            final selected = controller.selectedDepartmentName.value;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.slate50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.slate200),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: const AppText('Select Department',
                      fontSize: 13, color: AppColors.textColorHint),
                  value: departmentOptions.contains(selected) ? selected : null,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textColorSecondary),
                  items: departmentOptions.map((dept) {
                    return DropdownMenuItem<String>(
                      value: dept,
                      child: AppText(dept, fontSize: 13, fontWeight: FontWeight.w600),
                    );
                  }).toList(),
                  onChanged: (val) => controller.selectedDepartmentName.value = val,
                ),
              ),
            );
          }),
          const SizedBox(height: 16),

          _buildFieldLabel('Designation', isRequired: true),
          const SizedBox(height: 8),
          Obx(() {
            final selected = controller.selectedDesignationName.value;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.slate50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.slate200),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: const AppText('Select Designation',
                      fontSize: 13, color: AppColors.textColorHint),
                  value: designationOptions.contains(selected) ? selected : null,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textColorSecondary),
                  items: designationOptions.map((desig) {
                    return DropdownMenuItem<String>(
                      value: desig,
                      child: AppText(desig, fontSize: 13, fontWeight: FontWeight.w600),
                    );
                  }).toList(),
                  onChanged: (val) => controller.selectedDesignationName.value = val,
                ),
              ),
            );
          }),
          const SizedBox(height: 16),

          _buildFieldLabel('Role Description', isRequired: false),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller.descriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Explain the scope and responsibilities of this role...',
              hintStyle: const TextStyle(color: AppColors.textColorHint, fontSize: 13),
              filled: true,
              fillColor: AppColors.slate50,
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.slate200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.slate200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primaryColor),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText('Role Status', fontSize: 14, fontWeight: FontWeight.bold),
                  SizedBox(height: 2),
                  AppText('Inactive roles cannot be assigned to employees',
                      fontSize: 11, color: AppColors.textColorSecondary),
                ],
              ),
              Obx(() => Switch.adaptive(
                    value: controller.isActive.value,
                    activeTrackColor: AppColors.primaryColor,
                    onChanged: (val) => controller.isActive.value = val,
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label, {required bool isRequired}) {
    return Row(
      children: [
        AppText(label, fontSize: 13, fontWeight: FontWeight.w700),
        if (isRequired)
          const Text(' *', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
        else
          const AppText(' (Optional)', fontSize: 11, color: AppColors.textColorHint),
      ],
    );
  }

  Widget _buildQuickActionBar(RolePermissionsController controller) {
    return Obx(() {
      final totalGranted = controller.tempPermissionGroups
          .fold(0, (sum, g) => sum + g.grantedCount);
      final totalMax = controller.tempPermissionGroups
          .fold(0, (sum, g) => sum + g.totalCount);

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: AppText(
                    '$totalGranted / $totalMax Granted',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                TextButton(
                  onPressed: () => controller.toggleAllPermissions(true),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const AppText(
                    'Grant All',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => controller.toggleAllPermissions(false),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const AppText(
                    'Revoke All',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildPermissionsAccordionList(RolePermissionsController controller) {
    return Obx(() {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.tempPermissionGroups.length,
        itemBuilder: (context, index) {
          final group = controller.tempPermissionGroups[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: group.grantedCount > 0
                    ? AppColors.primaryColor.withValues(alpha: 0.25)
                    : AppColors.borderColor,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                initiallyExpanded: index == 0,
                tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: group.grantedCount > 0
                        ? AppColors.primaryColor.withValues(alpha: 0.1)
                        : AppColors.slate100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _resolveModuleIcon(group.iconKey),
                    color: group.grantedCount > 0
                        ? AppColors.primaryColor
                        : AppColors.textColorHint,
                    size: 20,
                  ),
                ),
                title: AppText(
                  group.moduleName,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                subtitle: AppText(
                  '${group.grantedCount} of ${group.totalCount} permissions enabled',
                  fontSize: 11,
                  color: group.grantedCount > 0
                      ? AppColors.primaryColor
                      : AppColors.textColorHint,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch.adaptive(
                      value: group.isAllGranted,
                      activeTrackColor: AppColors.primaryColor,
                      onChanged: (val) {
                        controller.toggleModuleAll(group.moduleId, val);
                      },
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down_rounded,
                        size: 20, color: AppColors.textColorSecondary),
                  ],
                ),
                children: [
                  const Divider(color: AppColors.slate100, height: 1),
                  const SizedBox(height: 8),
                  ...group.permissions.map((perm) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: perm.isGranted
                            ? AppColors.primaryColor.withValues(alpha: 0.03)
                            : AppColors.slate50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: perm.isGranted
                              ? AppColors.primaryColor.withValues(alpha: 0.2)
                              : AppColors.slate200,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: perm.isGranted
                                            ? AppColors.primaryColor
                                            : AppColors.slate400,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: AppText(
                                        perm.label,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: perm.isGranted
                                            ? AppColors.textColorPrimary
                                            : AppColors.textColorSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                if (perm.description != null) ...[
                                  const SizedBox(height: 4),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 14),
                                    child: AppText(
                                      perm.description!,
                                      fontSize: 11,
                                      color: AppColors.textColorHint,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Switch.adaptive(
                            value: perm.isGranted,
                            activeTrackColor: AppColors.primaryColor,
                            onChanged: (val) {
                              controller.togglePermission(
                                group.moduleId,
                                perm.key,
                                val,
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  IconData _resolveModuleIcon(String key) {
    switch (key) {
      case 'user':
        return Iconsax.user;
      case 'calendar':
        return Iconsax.calendar;
      case 'timer':
        return Iconsax.timer_1;
      case 'profile_2user':
        return Iconsax.profile_2user;
      case 'task':
        return Iconsax.task_square;
      case 'hierarchy':
        return Iconsax.hierarchy_2;
      case 'card':
        return Iconsax.card_pos;
      case 'monitor':
        return Iconsax.monitor;
      case 'people':
        return Iconsax.people;
      case 'clock':
        return Iconsax.clock;
      case 'folder':
        return Iconsax.folder_open;
      case 'buildings':
        return Iconsax.buildings;
      case 'shield_security':
        return Iconsax.shield_security;
      default:
        return Iconsax.element_4;
    }
  }
}
