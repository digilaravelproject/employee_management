import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/documents_controller.dart';
import '../models/document_model.dart';
import 'document_preview_screen.dart';

class FoldersListScreen extends StatelessWidget {
  const FoldersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DocumentsController>();
    final searchFieldController = TextEditingController();

    return Obx(() {
      final isAdmin = controller.isAdminView.value;
      final selectedFolder = controller.selectedFolder.value;

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
                onPressed: () {
                  if (selectedFolder != null) {
                    controller.selectFolder(null);
                  } else {
                    Get.back();
                  }
                },
              ),
            ),
          ),
          title: AppText(
            selectedFolder != null ? selectedFolder.name : (isAdmin ? 'All Folders' : 'My Documents'),
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textColorPrimary,
          ),
          centerTitle: false,
          actions: [
            IconButton(
              icon: const Icon(Iconsax.search_normal, color: AppColors.textColorPrimary, size: 20),
              onPressed: () {},
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Input field
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: TextField(
                    controller: searchFieldController,
                    onChanged: (val) => controller.searchQuery.value = val,
                    decoration: const InputDecoration(
                      hintText: 'Search folders and files...',
                      hintStyle: TextStyle(color: AppColors.textColorHint, fontSize: 13),
                      prefixIcon: Icon(Iconsax.search_normal, color: AppColors.textColorHint, size: 18),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
              ),

              // Folders list or files inside folder
              Expanded(
                child: selectedFolder != null 
                  ? _buildFolderFilesList(controller, selectedFolder)
                  : _buildFoldersGrid(controller, isAdmin),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: isAdmin ? const Color(0xFF3B82F6) : const Color(0xFF10B981),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: const Icon(Iconsax.add, color: Colors.white, size: 26),
          onPressed: () => _showAddOptionsBottomSheet(context, controller),
        ),
      );
    });
  }

  Widget _buildFoldersGrid(DocumentsController controller, bool isAdmin) {
    return Obx(() {
      final folders = controller.filteredFolders;

      if (folders.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Iconsax.folder_open, size: 48, color: AppColors.textColorHint.withValues(alpha: 0.3)),
              const SizedBox(height: 12),
              const AppText('No folders found', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textColorHint),
            ],
          ),
        );
      }

      return GridView.builder(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
        physics: const BouncingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.35,
        ),
        itemCount: folders.length,
        itemBuilder: (context, index) {
          final folder = folders[index];
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFEEF2FF)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.01),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  controller.selectFolder(folder);
                },
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: (isAdmin ? const Color(0xFF3B82F6) : const Color(0xFF10B981)).withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Iconsax.folder_open5,
                              color: isAdmin ? const Color(0xFF3B82F6) : const Color(0xFF10B981),
                              size: 20,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.more_vert_rounded, color: AppColors.textColorHint, size: 18),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {},
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            folder.name,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textColorPrimary,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          AppText(
                            '${folder.fileCount} Files',
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
        },
      );
    });
  }

  Widget _buildFolderFilesList(DocumentsController controller, DocumentFolder folder) {
    return Obx(() {
      final documents = controller.filteredDocuments;

      if (documents.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Iconsax.document_text, size: 48, color: AppColors.textColorHint.withValues(alpha: 0.3)),
              const SizedBox(height: 12),
              const AppText('No files in this folder', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textColorHint),
            ],
          ),
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
        physics: const BouncingScrollPhysics(),
        itemCount: documents.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final doc = documents[index];
          final iconData = _getIconData(doc.type);
          final iconColor = _getIconColor(doc.type);

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFEEF2FF)),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Get.to(() => DocumentPreviewScreen(fileName: doc.name));
                },
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: iconColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(iconData, color: iconColor, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              doc.name,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textColorPrimary,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            AppText(
                              '${doc.size} • ${doc.uploadedDate}',
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textColorHint,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusBgColor(doc.status),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: AppText(
                          doc.status,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: _getStatusTextColor(doc.status),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textColorHint),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }

  IconData _getIconData(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Iconsax.document_text5;
      case 'xlsx':
      case 'xls':
        return Iconsax.document_text;
      case 'docx':
      case 'doc':
        return Iconsax.document;
      case 'zip':
      case 'rar':
        return Iconsax.folder;
      default:
        return Iconsax.document_text;
    }
  }

  Color _getIconColor(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return const Color(0xFFEF4444);
      case 'xlsx':
      case 'xls':
        return const Color(0xFF10B981);
      case 'docx':
      case 'doc':
        return const Color(0xFF3B82F6);
      case 'zip':
      case 'rar':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF64748B);
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'public':
        return const Color(0xFFEFF6FF);
      case 'hr only':
        return const Color(0xFFEEF2FF);
      case 'team':
      default:
        return const Color(0xFFFFF7ED);
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'public':
        return const Color(0xFF2563EB);
      case 'hr only':
        return const Color(0xFF4F46E5);
      case 'team':
      default:
        return const Color(0xFFEA580C);
    }
  }

  void _showAddOptionsBottomSheet(BuildContext context, DocumentsController controller) {
    final isAdmin = controller.isAdminView.value;
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
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
            const AppText('Create or Upload', fontSize: 15, fontWeight: FontWeight.w800),
            const SizedBox(height: 20),

            _buildActionItem(
              icon: Iconsax.folder_add,
              label: 'Create New Folder',
              color: isAdmin ? const Color(0xFF3B82F6) : const Color(0xFF10B981),
              onTap: () {
                Get.back();
                _showAddFolderDialog(context, controller);
              },
            ),
            const SizedBox(height: 12),
            _buildActionItem(
              icon: Iconsax.document_upload,
              label: 'Upload New File',
              color: isAdmin ? const Color(0xFF3B82F6) : const Color(0xFF10B981),
              onTap: () {
                Get.back();
                _showUploadSheet(context, controller);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.slate50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEF2FF)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 16),
                AppText(
                  label,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textColorPrimary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddFolderDialog(BuildContext context, DocumentsController controller) {
    final folderNameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const AppText('Create New Folder', fontSize: 16, fontWeight: FontWeight.w800),
        content: TextField(
          controller: folderNameController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'e.g. Policies, Legal Documents',
            hintStyle: const TextStyle(color: AppColors.textColorHint, fontSize: 13),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const AppText('Cancel', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textColorSecondary),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: controller.isAdminView.value ? const Color(0xFF3B82F6) : const Color(0xFF10B981),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              if (folderNameController.text.trim().isNotEmpty) {
                controller.addFolder(folderNameController.text.trim());
                Get.back();
              }
            },
            child: const AppText('Create', fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ],
      ),
    );
  }

  void _showUploadSheet(BuildContext context, DocumentsController controller) {
    final nameController = TextEditingController();
    String selectedType = 'pdf';
    String selectedFolder = controller.selectedFolder.value != null 
      ? controller.selectedFolder.value!.name 
      : (controller.isAdminView.value 
          ? (controller.adminFolders.isNotEmpty ? controller.adminFolders.first.name : 'Policies')
          : (controller.employeeFolders.isNotEmpty ? controller.employeeFolders.first.name : 'My Documents'));
    String selectedStatus = 'Public';

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.slate200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const AppText('Upload Document', fontSize: 16, fontWeight: FontWeight.w800),
              const SizedBox(height: 16),

              const AppText('Document Name', fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textColorSecondary),
              const SizedBox(height: 8),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'e.g. Marketing Brief',
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
                        const AppText('File Type', fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textColorSecondary),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: selectedType,
                          items: ['pdf', 'xlsx', 'docx', 'zip']
                              .map((t) => DropdownMenuItem(value: t, child: Text(t.toUpperCase())))
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
                        const AppText('Access Scope', fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textColorSecondary),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: selectedStatus,
                          items: ['Public', 'HR Only', 'Team']
                              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) selectedStatus = val;
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
              const SizedBox(height: 16),

              const AppText('Select Folder', fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textColorSecondary),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedFolder,
                items: (controller.isAdminView.value ? controller.adminFolders : controller.employeeFolders)
                    .map((f) => DropdownMenuItem(value: f.name, child: Text(f.name)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) selectedFolder = val;
                },
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: controller.isAdminView.value ? const Color(0xFF3B82F6) : const Color(0xFF10B981),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    if (nameController.text.trim().isNotEmpty) {
                      controller.uploadFile(
                        nameController.text.trim(),
                        selectedType,
                        selectedFolder,
                        selectedStatus,
                      );
                      Get.back();
                    }
                  },
                  child: const AppText('Start Upload', fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
