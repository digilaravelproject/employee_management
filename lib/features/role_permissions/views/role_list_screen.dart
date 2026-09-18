import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/role_permissions_controller.dart';
import '../models/role_permission_models.dart';
import 'add_role_screen.dart';
import 'role_details_screen.dart';

class RoleListScreen extends StatelessWidget {
  const RoleListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject / retrieve controller
    final controller = Get.put(RolePermissionsController());

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
              'Roles',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textColorPrimary,
            ),
            AppText(
              'Manage system roles',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textColorHint,
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: ElevatedButton.icon(
              onPressed: () {
                controller.clearForm();
                Get.to(() => const AddRoleScreen());
              },
              icon: const Icon(Iconsax.add, size: 14, color: Colors.white),
              label: const AppText(
                'Add Role',
                fontSize: 12,
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
      body: Column(
        children: [
          // ── Search & Filter Section ──
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) => controller.searchQuery.value = value,
                    decoration: InputDecoration(
                      hintText: 'Search roles...',
                      hintStyle: const TextStyle(color: AppColors.textColorHint, fontSize: 13),
                      prefixIcon: const Icon(Iconsax.search_normal, color: AppColors.textColorHint, size: 18),
                      filled: true,
                      fillColor: AppColors.slate50,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ── Roles List ──
          Expanded(
            child: Obx(() {
              if (controller.isLoadingRoles.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final rolesList = controller.filteredRoles;
              if (rolesList.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Iconsax.shield_search, size: 60, color: AppColors.textColorHint.withValues(alpha: 0.3)),
                      const SizedBox(height: 16),
                      const AppText('No Roles Found', fontSize: 16, fontWeight: FontWeight.bold),
                      const SizedBox(height: 4),
                      const AppText('Try searching for another keyword', fontSize: 12, color: AppColors.textColorHint),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                physics: const BouncingScrollPhysics(),
                itemCount: rolesList.length,
                itemBuilder: (context, index) {
                  final role = rolesList[index];
                  return _RoleCard(role: role);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final Role role;
  const _RoleCard({required this.role});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RolePermissionsController>();

    // Dynamic icon and colors based on role name
    IconData roleIcon = Iconsax.shield;
    Color iconColor = AppColors.primaryColor;
    
    if (role.name.toLowerCase().contains('admin')) {
      roleIcon = Iconsax.security_safe;
      iconColor = const Color(0xFF6366F1); // Indigo
    } else if (role.name.toLowerCase().contains('hr')) {
      roleIcon = Iconsax.profile_2user;
      iconColor = const Color(0xFFF97316); // Orange/Amber
    } else if (role.name.toLowerCase().contains('manager')) {
      roleIcon = Iconsax.profile_add;
      iconColor = const Color(0xFF3B82F6); // Blue
    } else if (role.name.toLowerCase().contains('lead')) {
      roleIcon = Iconsax.people;
      iconColor = const Color(0xFF8B5CF6); // Purple
    } else if (role.name.toLowerCase().contains('accountant')) {
      roleIcon = Iconsax.empty_wallet;
      iconColor = const Color(0xFF10B981); // Emerald
    } else if (role.name.toLowerCase().contains('employee')) {
      roleIcon = Iconsax.user;
      iconColor = const Color(0xFF64748B); // Slate
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: iconColor.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            controller.selectedRole.value = role;
            controller.fetchRoleDetails(role.id);
            Get.to(() => const RoleDetailsScreen());
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon Tinted Background Box
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        roleIcon,
                        color: iconColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    
                    // Role details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              AppText(
                                role.name,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textColorPrimary,
                              ),
                              
                              // Active / Inactive badge
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
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textColorSecondary,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              if (role.departmentName != null && role.departmentName!.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryColor.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Iconsax.hierarchy_2, size: 10, color: AppColors.primaryColor),
                                      const SizedBox(width: 4),
                                      AppText(
                                        role.departmentName!,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryColor,
                                      ),
                                    ],
                                  ),
                                ),
                              if (role.designationName != null && role.designationName!.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                  decoration: BoxDecoration(
                                    color: AppColors.slate100,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Iconsax.briefcase, size: 10, color: AppColors.textColorSecondary),
                                      const SizedBox(width: 4),
                                      AppText(
                                        role.designationName!,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textColorSecondary,
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Navigation Chevron
                    const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.textColorHint,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 14),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 12),
                
                // Bottom row showing Modules count and Granular Permissions count
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Iconsax.category, size: 13, color: AppColors.textColorHint),
                        const SizedBox(width: 5),
                        AppText(
                          '${role.permissionGroups.length} Modules',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColorSecondary,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Iconsax.shield_tick, size: 13, color: AppColors.primaryColor),
                        const SizedBox(width: 5),
                        AppText(
                          '${role.totalPermissionsCount} / ${role.maxPermissionsCount} Allowed',
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
