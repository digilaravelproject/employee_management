import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/role_permissions_controller.dart';
import '../models/role_permission_models.dart';

class EditRoleScreen extends StatelessWidget {
  final Role role;
  const EditRoleScreen({super.key, required this.role});

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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText(
              'Edit Role',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textColorPrimary,
            ),
            AppText(
              'Modify role details',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textColorHint,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => controller.updateRole(role.id),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Form Card ──
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFF1F5F9)),
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
                  // Role Name Input
                  _buildLabel('Role Name', true),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: controller.nameController,
                    decoration: InputDecoration(
                      hintText: 'Enter role name',
                      hintStyle: const TextStyle(color: AppColors.textColorHint, fontSize: 13),
                      filled: true,
                      fillColor: AppColors.slate50,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                  const SizedBox(height: 20),

                  // Description Input
                  _buildLabel('Description', false),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: controller.descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Enter role description',
                      hintStyle: const TextStyle(color: AppColors.textColorHint, fontSize: 13),
                      filled: true,
                      fillColor: AppColors.slate50,
                      contentPadding: const EdgeInsets.all(16),
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
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Assign Users Card (Optional) ──
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFF1F5F9)),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildLabel('Assign Users', false, isOptional: true),
                      GestureDetector(
                        onTap: () => _showUserSelectionSheet(context, controller),
                        child: const Row(
                          children: [
                            Icon(Iconsax.add, size: 14, color: AppColors.primaryColor),
                            SizedBox(width: 4),
                            AppText(
                              'Add Users',
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
                  
                  // Selected Users List
                  Obx(() {
                    if (controller.selectedUsers.isEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        decoration: BoxDecoration(
                          color: AppColors.slate50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Icon(Iconsax.user_add, size: 36, color: AppColors.textColorHint.withValues(alpha: 0.5)),
                            const SizedBox(height: 8),
                            const AppText(
                              'No users assigned yet',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textColorSecondary,
                            ),
                            const SizedBox(height: 4),
                            const AppText(
                              'You can assign users to this role later',
                              fontSize: 10,
                              color: AppColors.textColorHint,
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.selectedUsers.length,
                      itemBuilder: (context, index) {
                        final user = controller.selectedUsers[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.slate50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.slate100),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
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
                              IconButton(
                                icon: const Icon(Iconsax.minus_cirlce, color: AppColors.errorColor, size: 20),
                                onPressed: () => controller.toggleUserSelection(user),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Role Status Card ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFF1F5F9)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppText('Role Status', fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
                      const SizedBox(height: 2),
                      AppText('Active roles can be assigned to users', fontSize: 10, color: AppColors.textColorHint),
                    ],
                  ),
                  Obx(() => Switch.adaptive(
                    value: controller.isActive.value,
                    activeThumbColor: AppColors.primaryColor,
                    onChanged: (val) => controller.isActive.value = val,
                  )),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, bool isRequired, {bool isOptional = false}) {
    return Row(
      children: [
        AppText(text, fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
        if (isRequired)
          const AppText(' *', fontSize: 13, fontWeight: FontWeight.bold, color: Colors.red),
        if (isOptional)
          const AppText(' (Optional)', fontSize: 11, color: AppColors.textColorHint),
      ],
    );
  }

  // Show bottom sheet to choose users
  void _showUserSelectionSheet(BuildContext context, RolePermissionsController controller) {
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
                  'Select Users',
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
            const AppText(
              'Select team members to assign this role.',
              fontSize: 12,
              color: AppColors.textColorHint,
            ),
            const SizedBox(height: 20),
            
            // List of all dummy users
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: controller.allUsers.length,
                itemBuilder: (context, index) {
                  final user = controller.allUsers[index];
                  return Obx(() {
                    final isSelected = controller.selectedUsers.contains(user);
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
                            onChanged: (val) => controller.toggleUserSelection(user),
                          ),
                        ],
                      ),
                    );
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const AppText('Done', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
