import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/departments_controller.dart';
import '../models/department_api_model.dart';
import '../../../core/utils/custom_snackbar.dart';
import 'edit_department_screen.dart';
import 'department_details_screen.dart';

class DepartmentListScreen extends StatelessWidget {
  const DepartmentListScreen({super.key});

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
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textColorPrimary, size: 20),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        title: Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText(
              'Departments',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textColorPrimary,
            ),
            AppText(
              '${controller.apiDepartments.length} departments',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textColorHint,
            ),
          ],
        )),
        actions: [
          // Refresh button
          Obx(() => controller.isLoading.value
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryColor),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryColor),
                  onPressed: () => controller.fetchDepartments(),
                )),
          Padding(
            padding: const EdgeInsets.only(right: 12, top: 10, bottom: 10),
            child: ElevatedButton.icon(
              onPressed: () {
                controller.clearForm();
                Get.toNamed('/add-department');
              },
              icon: const Icon(Iconsax.add, size: 14, color: Colors.white),
              label: const AppText(
                'Add',
                fontSize: 11,
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
          // ── Search Section ──
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              onChanged: controller.onSearch,
              decoration: InputDecoration(
                hintText: 'Search department...',
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
          // Slim search indicator
          Obx(() => controller.isSearching.value
              ? const LinearProgressIndicator(color: AppColors.primaryColor, minHeight: 2)
              : const SizedBox.shrink()),
          const SizedBox(height: 4),

          // ── Departments list ──
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.apiDepartments.isEmpty) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primaryColor));
              }

              final deptList = controller.apiDepartments;

              if (deptList.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Iconsax.building_3, size: 60, color: AppColors.textColorHint.withValues(alpha: 0.3)),
                      const SizedBox(height: 16),
                      const AppText('No Departments Found', fontSize: 16, fontWeight: FontWeight.bold),
                      const SizedBox(height: 4),
                      const AppText('Try searching for another keyword', fontSize: 12, color: AppColors.textColorHint),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => controller.fetchDepartments(),
                        icon: const Icon(Icons.refresh_rounded, size: 16, color: Colors.white),
                        label: const AppText('Refresh', fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                color: AppColors.primaryColor,
                onRefresh: () => controller.fetchDepartments(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: deptList.length,
                  itemBuilder: (context, index) {
                    final dept = deptList[index];
                    return _ApiDepartmentCard(dept: dept, controller: controller);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _ApiDepartmentCard extends StatelessWidget {
  final DepartmentApiModel dept;
  final DepartmentsController controller;

  const _ApiDepartmentCard({required this.dept, required this.controller});

  @override
  Widget build(BuildContext context) {
    final themeColor = _getThemeColor(dept.name);
    final icon = _getIcon(dept.name);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Get.to(() => DepartmentDetailsScreen(departmentId: dept.id.toString()));
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tinted Icon Circle
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: themeColor.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: themeColor, size: 24),
                    ),
                    const SizedBox(width: 14),
                    // Department Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            dept.name,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColorPrimary,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _statChip(Iconsax.people, '${dept.employeesCount} Employees', AppColors.primaryColor),
                              const SizedBox(width: 8),
                              _statChip(Iconsax.element_3, '${dept.teamCount} Teams', const Color(0xFF8B5CF6)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Status badge + menu
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: dept.status == 'Active'
                                ? const Color(0xFF10B981).withValues(alpha: 0.1)
                                : AppColors.textColorHint.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: AppText(
                            dept.status,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: dept.status == 'Active' ? const Color(0xFF10B981) : AppColors.textColorHint,
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert_rounded, color: AppColors.textColorHint, size: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          onSelected: (value) {
                            if (value == 'edit') {
                              controller.populateFormFromApi(dept);
                              Get.to(() => const EditDepartmentScreen());
                            } else if (value == 'delete') {
                              _showDeleteConfirmation(context);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Iconsax.edit, size: 16, color: AppColors.textColorSecondary),
                                  SizedBox(width: 8),
                                  AppText('Edit', fontSize: 13, fontWeight: FontWeight.w500),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Iconsax.trash, size: 16, color: Colors.redAccent),
                                  SizedBox(width: 8),
                                  AppText('Delete', fontSize: 13, fontWeight: FontWeight.w500, color: Colors.redAccent),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),

                if (dept.description != null && dept.description!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  AppText(
                    dept.description!,
                    fontSize: 12,
                    color: AppColors.textColorSecondary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const SizedBox(height: 14),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 12),

                // Head of Department row
                Row(
                  children: [
                    dept.head != null
                        ? (dept.head!.avatar != null
                            ? CircleAvatar(
                                radius: 14,
                                backgroundImage: NetworkImage(dept.head!.avatar!),
                              )
                            : CircleAvatar(
                                radius: 14,
                                backgroundColor: themeColor.withValues(alpha: 0.15),
                                child: AppText(
                                  dept.head!.name.substring(0, 1).toUpperCase(),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: themeColor,
                                ),
                              ))
                        : CircleAvatar(
                            radius: 14,
                            backgroundColor: AppColors.slate100,
                            child: const Icon(Iconsax.profile_circle, size: 14, color: AppColors.textColorHint),
                          ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            dept.head?.name ?? 'No Head Assigned',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: dept.head != null ? AppColors.textColorPrimary : AppColors.textColorHint,
                          ),
                          if (dept.head?.designation != null)
                            AppText(
                              dept.head!.designation!,
                              fontSize: 10,
                              color: AppColors.textColorHint,
                            ),
                        ],
                      ),
                    ),
                    const AppText(
                      'Head of Dept',
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textColorHint,
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

  Widget _statChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 4),
          AppText(label, fontSize: 10, fontWeight: FontWeight.w600, color: color),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Iconsax.trash, color: Colors.redAccent, size: 20),
            ),
            const SizedBox(width: 10),
            const AppText('Delete Department', fontSize: 16, fontWeight: FontWeight.bold),
          ],
        ),
        content: AppText(
          'Are you sure you want to delete "${dept.name}"?',
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
              final success = await controller.deleteDepartmentApi(dept.id.toString());
              if (success) {
                CustomSnackbar.showSuccess('Department deleted successfully');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const AppText('Delete', color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Color _getThemeColor(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('tech') || lower.contains('eng') || lower.contains('code') || lower.contains('dev') || lower.contains('product')) return const Color(0xFF6366F1);
    if (lower.contains('hr') || lower.contains('people') || lower.contains('recruit') || lower.contains('human')) return const Color(0xFFEC4899);
    if (lower.contains('market') || lower.contains('advert') || lower.contains('social')) return const Color(0xFF10B981);
    if (lower.contains('finance') || lower.contains('money') || lower.contains('audit') || lower.contains('pay')) return const Color(0xFFF59E0B);
    if (lower.contains('sale') || lower.contains('deal') || lower.contains('revenue')) return const Color(0xFF3B82F6);
    if (lower.contains('support') || lower.contains('it') || lower.contains('help')) return const Color(0xFF06B6D4);
    return const Color(0xFF8B5CF6);
  }

  IconData _getIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('tech') || lower.contains('eng') || lower.contains('code') || lower.contains('dev') || lower.contains('product')) return Iconsax.code;
    if (lower.contains('hr') || lower.contains('people') || lower.contains('recruit') || lower.contains('human')) return Iconsax.user_octagon;
    if (lower.contains('market') || lower.contains('advert') || lower.contains('social')) return Iconsax.volume_high;
    if (lower.contains('finance') || lower.contains('money') || lower.contains('audit') || lower.contains('pay')) return Iconsax.empty_wallet;
    if (lower.contains('sale') || lower.contains('deal') || lower.contains('revenue')) return Iconsax.graph;
    if (lower.contains('support') || lower.contains('it') || lower.contains('help')) return Iconsax.monitor;
    return Iconsax.category;
  }
}
