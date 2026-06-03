import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/documents_controller.dart';

class AccessControlScreen extends StatelessWidget {
  final String fileName;
  const AccessControlScreen({super.key, required this.fileName});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DocumentsController>();

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
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.textColorPrimary,
                size: 18,
              ),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        title: const AppText(
          'Access Control',
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppColors.textColorPrimary,
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Box File Meta Info ──
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Iconsax.document_text5, color: Color(0xFFEF4444), size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          fileName,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textColorPrimary,
                        ),
                        const SizedBox(height: 4),
                        const AppText(
                          'Policies • 2.4 MB',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColorHint,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Who has access list header & Add button ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AppText(
                    'Who has access',
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textColorSecondary,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      backgroundColor: const Color(0xFF3B82F6).withValues(alpha: 0.08),
                      foregroundColor: const Color(0xFF3B82F6),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => _showAddPeopleBottomSheet(context, controller),
                    child: const Row(
                      children: [
                        Icon(Iconsax.user_add, size: 14),
                        SizedBox(width: 6),
                        AppText(
                          'Add People / Group',
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF3B82F6),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Access Members List ──
            Expanded(
              child: Obx(() {
                final list = controller.activeAccessList;
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  physics: const BouncingScrollPhysics(),
                  itemCount: list.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final access = list[index];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFEEF2FF)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _getAccessTypeColor(access.type).withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getAccessTypeIcon(access.type),
                              color: _getAccessTypeColor(access.type),
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(
                                  access.name,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textColorPrimary,
                                ),
                                const SizedBox(height: 3),
                                AppText(
                                  access.details,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textColorHint,
                                ),
                              ],
                            ),
                          ),

                          // Role Dropdown Button
                          PopupMenuButton<String>(
                            onSelected: (role) {
                              if (role == 'Remove') {
                                controller.revokeAccess(access.id);
                              } else {
                                controller.updateAccessRole(access.id, role);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.slate100,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  AppText(
                                    access.role,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textColorPrimary,
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.arrow_drop_down, color: AppColors.textColorPrimary, size: 18),
                                ],
                              ),
                            ),
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'Viewer',
                                child: AppText('Viewer', fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                              const PopupMenuItem(
                                value: 'Editor',
                                child: AppText('Editor', fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                              const PopupMenuDivider(),
                              const PopupMenuItem(
                                value: 'Remove',
                                child: AppText(
                                  'Remove Access', 
                                  fontSize: 13, 
                                  fontWeight: FontWeight.w700, 
                                  color: Colors.redAccent,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getAccessTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'group':
        return Iconsax.people;
      case 'department':
        return Iconsax.briefcase;
      case 'individual':
      default:
        return Iconsax.user;
    }
  }

  Color _getAccessTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'group':
        return const Color(0xFF3B82F6);
      case 'department':
        return const Color(0xFF8B5CF6);
      case 'individual':
      default:
        return const Color(0xFF10B981);
    }
  }

  void _showAddPeopleBottomSheet(BuildContext context, DocumentsController controller) {
    final nameController = TextEditingController();
    String selectedType = 'Individual';
    String selectedRole = 'Viewer';

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.slate200,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const AppText('Grant Document Access', fontSize: 15, fontWeight: FontWeight.w800),
            const SizedBox(height: 16),

            const AppText('User or Group Name', fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textColorSecondary),
            const SizedBox(height: 8),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: 'e.g. Finance Team, Amit Singh',
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppText('Entity Type', fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textColorSecondary),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedType,
                        items: ['Individual', 'Group', 'Department']
                            .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) selectedType = val;
                        },
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppText('Default Access Role', fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textColorSecondary),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedRole,
                        items: ['Viewer', 'Editor']
                            .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) selectedRole = val;
                        },
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  if (nameController.text.trim().isNotEmpty) {
                    controller.grantNewAccess(
                      nameController.text.trim(),
                      selectedType,
                      selectedRole,
                    );
                    Get.back();
                  }
                },
                child: const AppText('Grant Access', fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
