import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/role_permissions_controller.dart';
import 'edit_role_screen.dart';

class RoleDetailsScreen extends StatelessWidget {
  const RoleDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RolePermissionsController>();

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
        title: const AppText(
          'Role Details',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textColorPrimary,
        ),
        actions: [
          Obx(() {
            final role = controller.selectedRole.value;
            if (role == null) return const SizedBox();
            return PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: AppColors.textColorPrimary),
              onSelected: (value) {
                if (value == 'edit') {
                  Get.to(() => EditRoleScreen(role: role));
                } else if (value == 'delete') {
                  Get.dialog(
                    Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      backgroundColor: Colors.white,
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.errorColor.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Iconsax.trash,
                                color: AppColors.errorColor,
                                size: 32,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const AppText(
                              'Delete Role?',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColorPrimary,
                            ),
                            const SizedBox(height: 12),
                            AppText(
                              'Are you sure you want to delete the "${role.name}" role? This action cannot be undone and will remove all associated permissions.',
                              fontSize: 13,
                              color: AppColors.textColorSecondary,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => Get.back(),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      side: const BorderSide(color: AppColors.slate200),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const AppText(
                                      'Cancel',
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textColorPrimary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () => controller.deleteRole(role.id),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.errorColor,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const AppText(
                                      'Delete',
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Iconsax.edit, size: 18, color: AppColors.textColorPrimary),
                      SizedBox(width: 8),
                      AppText('Edit Role', fontSize: 13),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Iconsax.trash, size: 18, color: AppColors.errorColor),
                      SizedBox(width: 8),
                      AppText('Delete Role',
                          fontSize: 13, color: AppColors.errorColor),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoadingRoleDetails.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final role = controller.selectedRole.value;
        if (role == null) {
          return const Center(child: AppText('Role details not available'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Role Header Card ──
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
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
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Iconsax.shield_security,
                              color: AppColors.primaryColor, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: AppText(
                                      role.name,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textColorPrimary,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: role.isActive
                                          ? const Color(0xFFECFDF5)
                                          : const Color(0xFFFEF2F2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: AppText(
                                      role.isActive ? 'Active' : 'Inactive',
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: role.isActive
                                          ? const Color(0xFF10B981)
                                          : const Color(0xFFEF4444),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              AppText(
                                role.description,
                                fontSize: 12,
                                color: AppColors.textColorSecondary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Department and Designation tags
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        if (role.departmentName != null &&
                            role.departmentName!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor
                                  .withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Iconsax.hierarchy_2,
                                    size: 13, color: AppColors.primaryColor),
                                const SizedBox(width: 6),
                                AppText(
                                  'Dept: ${role.departmentName!}',
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryColor,
                                ),
                              ],
                            ),
                          ),
                        if (role.designationName != null &&
                            role.designationName!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.slate100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Iconsax.briefcase,
                                    size: 13,
                                    color: AppColors.textColorSecondary),
                                const SizedBox(width: 6),
                                AppText(
                                  'Role: ${role.designationName!}',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textColorSecondary,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    const Divider(height: 1, color: AppColors.slate100),
                    const SizedBox(height: 14),

                    // Metrics row
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricTile(
                            title: '${role.totalPermissionsCount} / ${role.maxPermissionsCount}',
                            subtitle: 'Permissions Allowed',
                            icon: Iconsax.shield_tick,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        Container(
                            height: 36, width: 1, color: AppColors.slate200),
                        Expanded(
                          child: _buildMetricTile(
                            title: '${role.permissionGroups.length}',
                            subtitle: 'Configured Modules',
                            icon: Iconsax.category,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Granular Permissions Section Header ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AppText(
                    'Granular Module Permissions',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColorPrimary,
                  ),
                  TextButton.icon(
                    onPressed: () => Get.to(() => EditRoleScreen(role: role)),
                    icon: const Icon(Iconsax.edit,
                        size: 14, color: AppColors.primaryColor),
                    label: const AppText(
                      'Modify',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // ── Modules and Action List ──
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: role.permissionGroups.length,
                itemBuilder: (context, index) {
                  final group = role.permissionGroups[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderColor),
                    ),
                    child: Theme(
                      data: Theme.of(context)
                          .copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        initiallyExpanded: false,
                        tilePadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        childrenPadding:
                            const EdgeInsets.fromLTRB(16, 0, 16, 12),
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
                          '${group.grantedCount} of ${group.totalCount} permitted',
                          fontSize: 11,
                          color: group.grantedCount > 0
                              ? AppColors.primaryColor
                              : AppColors.textColorHint,
                        ),
                        children: [
                          const Divider(height: 1, color: AppColors.slate100),
                          const SizedBox(height: 8),
                          ...group.permissions.map((perm) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: perm.isGranted
                                    ? AppColors.primaryColor
                                        .withValues(alpha: 0.04)
                                    : AppColors.slate50,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    perm.isGranted
                                        ? Icons.check_circle_rounded
                                        : Icons.cancel_rounded,
                                    size: 16,
                                    color: perm.isGranted
                                        ? AppColors.primaryColor
                                        : AppColors.textColorHint,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        AppText(
                                          perm.label,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: perm.isGranted
                                              ? AppColors.textColorPrimary
                                              : AppColors.textColorSecondary,
                                        ),
                                        if (perm.description != null)
                                          AppText(
                                            perm.description!,
                                            fontSize: 10,
                                            color: AppColors.textColorHint,
                                          ),
                                      ],
                                    ),
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
              ),

              const SizedBox(height: 30),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            AppText(title,
                fontSize: 14, fontWeight: FontWeight.bold, color: color),
          ],
        ),
        const SizedBox(height: 2),
        AppText(subtitle, fontSize: 11, color: AppColors.textColorSecondary),
      ],
    );
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
