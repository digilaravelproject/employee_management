import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/role_permissions_controller.dart';
import '../models/role_permission_models.dart';
import 'role_permissions_screen.dart';
import 'edit_role_screen.dart';

class RoleDetailsScreen extends StatelessWidget {
  const RoleDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RolePermissionsController>();

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
                if (value == 'edit_permissions') {
                  controller.editPermissions(role);
                  Get.to(() => const RolePermissionsScreen());
                } else if (value == 'edit_details') {
                  controller.setupEditForm(role);
                  Get.to(() => EditRoleScreen(role: role));
                } else if (value == 'delete') {
                  Get.defaultDialog(
                    title: 'Delete Role',
                    titleStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    middleText: 'Are you sure you want to delete the "${role.name}" role? This action cannot be undone.',
                    middleTextStyle: const TextStyle(fontSize: 13, color: AppColors.textColorSecondary),
                    textCancel: 'Cancel',
                    textConfirm: 'Delete',
                    confirmTextColor: Colors.white,
                    buttonColor: AppColors.errorColor,
                    onConfirm: () {
                      Get.back(); // close dialog
                      controller.deleteRole(role);
                    },
                  );
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit_permissions',
                  child: Row(
                    children: [
                      Icon(Iconsax.shield_tick, size: 18, color: AppColors.textColorPrimary),
                      SizedBox(width: 8),
                      AppText('Edit Permissions', fontSize: 13),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'edit_details',
                  child: Row(
                    children: [
                      Icon(Iconsax.edit, size: 18, color: AppColors.textColorPrimary),
                      SizedBox(width: 8),
                      AppText('Edit Details', fontSize: 13),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Iconsax.trash, size: 18, color: AppColors.errorColor),
                      SizedBox(width: 8),
                      AppText('Delete Role', fontSize: 13, color: AppColors.errorColor),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
      body: Obx(() {
        final role = controller.selectedRole.value;
        if (role == null) {
          return const Center(child: AppText('Role details not available'));
        }

        // Calculate counts
        int totalPerms = role.totalPermissionsCount;
        int viewPerms = role.permissions.fold(0, (sum, p) => sum + (p.view ? 1 : 0));
        int addPerms = role.permissions.fold(0, (sum, p) => sum + (p.add ? 1 : 0));
        int editPerms = role.permissions.fold(0, (sum, p) => sum + (p.edit ? 1 : 0));
        int deletePerms = role.permissions.fold(0, (sum, p) => sum + (p.delete ? 1 : 0));

        // Dynamic styling icons
        IconData roleIcon = Iconsax.shield;
        Color roleThemeColor = AppColors.primaryColor;
        if (role.name.toLowerCase().contains('admin')) {
          roleIcon = Iconsax.security_safe;
          roleThemeColor = const Color(0xFF6366F1);
        } else if (role.name.toLowerCase().contains('hr')) {
          roleIcon = Iconsax.profile_2user;
          roleThemeColor = const Color(0xFFF97316);
        } else if (role.name.toLowerCase().contains('manager')) {
          roleIcon = Iconsax.profile_add;
          roleThemeColor = const Color(0xFF3B82F6);
        } else if (role.name.toLowerCase().contains('lead')) {
          roleIcon = Iconsax.people;
          roleThemeColor = const Color(0xFF8B5CF6);
        } else if (role.name.toLowerCase().contains('accountant')) {
          roleIcon = Iconsax.empty_wallet;
          roleThemeColor = const Color(0xFF10B981);
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Role Header Info Card ──
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                  boxShadow: [
                    BoxShadow(
                      color: roleThemeColor.withValues(alpha: 0.04),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: roleThemeColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Icon(roleIcon, color: roleThemeColor, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  AppText(
                                    role.name,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textColorPrimary,
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: role.isActive 
                                          ? const Color(0xFFECFDF5) 
                                          : const Color(0xFFFEF2F2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: AppText(
                                      role.isActive ? 'Active' : 'Inactive',
                                      fontSize: 9,
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
                                fontSize: 13,
                                color: AppColors.textColorSecondary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    const SizedBox(height: 20),
                    
                    // Highlights Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildHeaderMetric(
                            '${role.assignedUsers.length}',
                            'Users Assigned',
                            roleThemeColor,
                          ),
                        ),
                        Container(height: 32, width: 1, color: const Color(0xFFF1F5F9)),
                        Expanded(
                          child: _buildHeaderMetric(
                            '$totalPerms',
                            'Permissions Enabled',
                            roleThemeColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Assigned Users Section ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText(
                    'Assigned Users',
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textColorPrimary,
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _showAssignUsersSheet(context, role, controller),
                        child: const Row(
                          children: [
                            Icon(Iconsax.user_add, size: 14, color: AppColors.primaryColor),
                            SizedBox(width: 4),
                            AppText(
                              'Assign Users',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () {
                          Get.snackbar(
                            'Assigned Users',
                            'Total of ${role.assignedUsers.length} users belong to this role.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: AppColors.primaryColor,
                            colorText: Colors.white,
                          );
                        },
                        child: const AppText(
                          'View All',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Assigned Users Scrollable List
              _buildAssignedUsersList(role, controller),
              const SizedBox(height: 24),

              // ── Permissions Summary Section ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText(
                    'Permissions Summary',
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textColorPrimary,
                  ),
                  GestureDetector(
                    onTap: () {
                      controller.editPermissions(role);
                      Get.to(() => const RolePermissionsScreen());
                    },
                    child: const AppText(
                      'View All',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Permissions Count Metric Panels Grid
              _buildPermissionsGrid(totalPerms, viewPerms, addPerms, editPerms, deletePerms),
              const SizedBox(height: 30),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeaderMetric(String value, String label, Color accentColor) {
    return Column(
      children: [
        AppText(
          value,
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: AppColors.textColorPrimary,
        ),
        const SizedBox(height: 4),
        AppText(
          label,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textColorHint,
        ),
      ],
    );
  }

  Widget _buildAssignedUsersList(Role role, RolePermissionsController controller) {
    if (role.assignedUsers.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Column(
          children: [
            Icon(Iconsax.profile_delete, size: 36, color: AppColors.textColorHint.withValues(alpha: 0.5)),
            const SizedBox(height: 8),
            const AppText(
              'No users assigned to this role',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textColorSecondary,
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: role.assignedUsers.length,
        separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF8FAFC)),
        itemBuilder: (context, index) {
          final user = role.assignedUsers[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(user.avatarUrl),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        user.name,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColorPrimary,
                      ),
                      AppText(
                        user.email,
                        fontSize: 10,
                        color: AppColors.textColorHint,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Iconsax.minus_cirlce, color: AppColors.errorColor, size: 20),
                  tooltip: 'Unassign User',
                  onPressed: () {
                    Get.defaultDialog(
                      title: 'Unassign User',
                      titleStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      middleText: 'Are you sure you want to remove ${user.name} from the ${role.name} role?',
                      middleTextStyle: const TextStyle(fontSize: 13, color: AppColors.textColorSecondary),
                      textCancel: 'Cancel',
                      textConfirm: 'Remove',
                      confirmTextColor: Colors.white,
                      buttonColor: AppColors.errorColor,
                      onConfirm: () {
                        Get.back();
                        controller.removeUserFromRole(role, user);
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPermissionsGrid(int total, int view, int add, int edit, int delete) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildPermissionCountCard(
                'Total Permissions',
                '$total',
                Iconsax.shield_tick,
                const Color(0xFF6366F1), // Indigo
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPermissionCountCard(
                'View Permissions',
                '$view Modules',
                Iconsax.eye,
                const Color(0xFF3B82F6), // Blue
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildPermissionCountCard(
                'Add Permissions',
                '$add Modules',
                Iconsax.add_circle,
                const Color(0xFF10B981), // Emerald/Green
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPermissionCountCard(
                'Edit Permissions',
                '$edit Modules',
                Iconsax.edit,
                const Color(0xFFF59E0B), // Amber/Orange
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildPermissionCountCard(
                'Delete Permissions',
                '$delete Modules',
                Iconsax.trash,
                const Color(0xFFEF4444), // Red
              ),
            ),
            const Expanded(child: SizedBox()),
          ],
        ),
      ],
    );
  }

  Widget _buildPermissionCountCard(String label, String count, IconData icon, Color themeColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: themeColor.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                count,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: themeColor,
              ),
              Icon(icon, color: themeColor, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          AppText(
            label,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppColors.textColorSecondary,
          ),
        ],
      ),
    );
  }

  void _showAssignUsersSheet(BuildContext context, Role role, RolePermissionsController controller) {
    // Users that are not already assigned to this role
    final availableUsers = controller.allUsers.where((u) => !role.assignedUsers.any((au) => au.email == u.email)).toList();
    final selectedUsersForAssignment = <AppUser>[].obs;
    
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
                AppText(
                  'Assign Users',
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
              'Assign team members to ${role.name}.',
              fontSize: 12,
              color: AppColors.textColorHint,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: availableUsers.isEmpty
                  ? const Center(
                      child: AppText(
                        'All users are already assigned to this role',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColorSecondary,
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: availableUsers.length,
                      itemBuilder: (context, index) {
                        final user = availableUsers[index];
                        return Obx(() {
                          final isSelected = selectedUsersForAssignment.contains(user);
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
                                      AppText(user.email, fontSize: 10, color: AppColors.textColorHint),
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
                                      selectedUsersForAssignment.remove(user);
                                    } else {
                                      selectedUsersForAssignment.add(user);
                                    }
                                  },
                                ),
                              ],
                            ),
                          );
                        });
                      },
                    ),
            ),
            const SizedBox(height: 16),
            if (availableUsers.isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (selectedUsersForAssignment.isNotEmpty) {
                      controller.assignUsersToRole(role, selectedUsersForAssignment);
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
              ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
