import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/role_permissions_controller.dart';
import '../models/role_permission_models.dart';

class RolePermissionsScreen extends StatelessWidget {
  const RolePermissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RolePermissionsController>();
    final role = controller.selectedRole.value;

    if (role == null) {
      return const Scaffold(
        body: Center(child: AppText('No role selected')),
      );
    }

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
              'Role Permissions',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textColorPrimary,
            ),
            AppText(
              'Set permissions for ${role.name}',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textColorHint,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => controller.savePermissions(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: AppText(
                'Save',
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryColor,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Table Headers Row
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: const Row(
              children: [
                Expanded(
                  flex: 3,
                  child: AppText('Module', fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textColorSecondary),
                ),
                Expanded(
                  child: Center(
                    child: AppText('View', fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textColorSecondary),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: AppText('Add', fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textColorSecondary),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: AppText('Edit', fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textColorSecondary),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: AppText('Delete', fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textColorSecondary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Permission Grid Rows
          Expanded(
            child: Obx(() {
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                physics: const BouncingScrollPhysics(),
                itemCount: controller.tempPermissions.length,
                itemBuilder: (context, index) {
                  final perm = controller.tempPermissions[index];
                  return _PermissionRow(permission: perm);
                },
              );
            }),
          ),

          // Legend Footer Panel
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: SafeArea(
              top: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendItem(true, 'Allowed'),
                  const SizedBox(width: 32),
                  _buildLegendItem(false, 'Not Allowed'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(bool allowed, String text) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: allowed ? AppColors.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: allowed ? AppColors.primaryColor : AppColors.slate300,
              width: 1.5,
            ),
          ),
          child: allowed 
              ? const Icon(Icons.check, size: 12, color: Colors.white) 
              : null,
        ),
        const SizedBox(width: 8),
        AppText(
          text,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AppColors.textColorSecondary,
        ),
      ],
    );
  }
}

class _PermissionRow extends StatelessWidget {
  final ModulePermission permission;
  const _PermissionRow({required this.permission});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RolePermissionsController>();

    // Visual Module Icon definitions
    IconData moduleIcon = Iconsax.element_4;
    Color iconColor = AppColors.primaryColor;
    
    switch (permission.moduleName.toLowerCase()) {
      case 'dashboard':
        moduleIcon = Iconsax.category;
        iconColor = const Color(0xFF6366F1); // Indigo
        break;
      case 'users':
        moduleIcon = Iconsax.user_octagon;
        iconColor = const Color(0xFF3B82F6); // Blue
        break;
      case 'employees':
        moduleIcon = Iconsax.profile_2user;
        iconColor = const Color(0xFFF59E0B); // Amber
        break;
      case 'attendance':
        moduleIcon = Iconsax.calendar_tick;
        iconColor = const Color(0xFF10B981); // Emerald
        break;
      case 'leaves':
        moduleIcon = Iconsax.sun_1;
        iconColor = const Color(0xFFF97316); // Orange
        break;
      case 'payroll':
        moduleIcon = Iconsax.empty_wallet;
        iconColor = const Color(0xFF8B5CF6); // Purple
        break;
      case 'reports':
        moduleIcon = Iconsax.graph;
        iconColor = const Color(0xFFEF4444); // Red
        break;
      case 'settings':
        moduleIcon = Iconsax.setting;
        iconColor = const Color(0xFF64748B); // Slate
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF8FAFC)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Module Info Section
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(moduleIcon, color: iconColor, size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        permission.moduleName,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textColorPrimary,
                      ),
                      AppText(
                        'Manage ${permission.moduleName.toLowerCase()} data',
                        fontSize: 9,
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

          // View Checkbox
          Expanded(
            child: _buildCheckbox(
              permission.view,
              () => controller.togglePermissionCheckbox(permission.moduleName, 'view'),
            ),
          ),

          // Add Checkbox
          Expanded(
            child: _buildCheckbox(
              permission.add,
              () => controller.togglePermissionCheckbox(permission.moduleName, 'add'),
            ),
          ),

          // Edit Checkbox
          Expanded(
            child: _buildCheckbox(
              permission.edit,
              () => controller.togglePermissionCheckbox(permission.moduleName, 'edit'),
            ),
          ),

          // Delete Checkbox
          Expanded(
            child: _buildCheckbox(
              permission.delete,
              () => controller.togglePermissionCheckbox(permission.moduleName, 'delete'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckbox(bool val, VoidCallback onTap) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: val ? AppColors.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: val ? AppColors.primaryColor : AppColors.slate300,
              width: 1.5,
            ),
          ),
          child: val 
              ? const Icon(Icons.check, size: 14, color: Colors.white) 
              : null,
        ),
      ),
    );
  }
}
