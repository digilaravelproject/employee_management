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

      ),
      body: Column(
        children: [
          // ── Search & Filter Section ──
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
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
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.5),
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
                return RefreshIndicator(
                  color: AppColors.primaryColor,
                  onRefresh: () => controller.fetchRolesFromApi(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.6,
                      alignment: Alignment.center,
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
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                color: AppColors.primaryColor,
                onRefresh: () => controller.fetchRolesFromApi(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  itemCount: rolesList.length,
                  itemBuilder: (context, index) {
                    final role = rolesList[index];
                    return _RoleCard(role: role);
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.clearForm();
          Get.to(() => const AddRoleScreen());
        },
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
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
      iconColor = AppColors.primaryColor; // Indigo
    } else if (role.name.toLowerCase().contains('hr')) {
      roleIcon = Iconsax.profile_2user;
      iconColor = const Color(0xFFF97316); // Orange/Amber
    } else if (role.name.toLowerCase().contains('manager')) {
      roleIcon = Iconsax.profile_add;
      iconColor = AppColors.primaryColor; // Blue
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
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
          borderRadius: BorderRadius.circular(16),
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
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        roleIcon,
                        color: iconColor,
                        size: 22,
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
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                          if (role.description.isNotEmpty &&
                              role.description.toLowerCase() != 'no description provided') ...[
                            const SizedBox(height: 3),
                            AppText(
                              role.description,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textColorSecondary,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              if (role.departmentName != null && role.departmentName!.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Iconsax.hierarchy_2, size: 11, color: AppColors.primaryColor),
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
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.slate100,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Iconsax.briefcase, size: 11, color: AppColors.textColorSecondary),
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
                      padding: EdgeInsets.only(top: 10),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.textColorHint,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 10),
                
                // Bottom row showing Permissions count & progress
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Iconsax.shield_tick, size: 14, color: iconColor),
                            const SizedBox(width: 6),
                            const AppText(
                              'Permissions Allowed',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textColorSecondary,
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: iconColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: AppText(
                            '${role.totalPermissionsCount} / ${role.maxPermissionsCount}',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: iconColor,
                          ),
                        ),
                      ],
                    ),
                    if (role.maxPermissionsCount > 0) ...[
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (role.totalPermissionsCount / role.maxPermissionsCount).clamp(0.0, 1.0),
                          backgroundColor: const Color(0xFFF1F5F9),
                          valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                          minHeight: 4,
                        ),
                      ),
                    ],
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
