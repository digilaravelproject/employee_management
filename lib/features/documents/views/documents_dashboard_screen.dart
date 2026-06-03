import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/documents_controller.dart';
import '../models/document_model.dart';
import 'folders_list_screen.dart';
import 'employee_shared_screen.dart';
import 'document_preview_screen.dart';
import 'access_control_screen.dart';

class DocumentsDashboardScreen extends StatelessWidget {
  const DocumentsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Put or find controller
    final controller = Get.put(DocumentsController());

    return Obx(() {
      final isAdmin = controller.isAdminView.value;
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
          title: AppText(
            isAdmin ? 'Document Management' : 'My Documents',
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textColorPrimary,
          ),
          centerTitle: false,
          actions: [
            // Custom role switcher button in AppBar for easy showcase
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isAdmin 
                      ? [const Color(0xFF3B82F6), const Color(0xFF4F46E5)]
                      : [const Color(0xFF10B981), const Color(0xFF059669)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: (isAdmin ? const Color(0xFF3B82F6) : const Color(0xFF10B981)).withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => controller.toggleRoleView(),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Center(
                        child: Row(
                          children: [
                            Icon(
                              isAdmin ? Iconsax.user_tick : Iconsax.security_user,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            AppText(
                              isAdmin ? 'Admin View' : 'Emp View',
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              // Mock refresh
              await Future.delayed(const Duration(seconds: 1));
            },
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isAdmin) ...[
                    // ── ADMIN VIEW ──
                    const _AdminOverviewCard(),
                    const SizedBox(height: 24),
                    const AppText(
                      'Quick Actions',
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textColorSecondary,
                    ),
                    const SizedBox(height: 12),
                    const _AdminQuickActions(),
                    const SizedBox(height: 28),
                  ] else ...[
                    // ── EMPLOYEE VIEW ──
                    const _EmployeeOverviewCard(),
                    const SizedBox(height: 24),
                    const AppText(
                      'Quick Access',
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textColorSecondary,
                    ),
                    const SizedBox(height: 12),
                    const _EmployeeQuickAccess(),
                    const SizedBox(height: 28),
                  ],

                  // ── RECENT DOCUMENTS SECTION ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const AppText(
                        'Recent Documents',
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textColorSecondary,
                      ),
                      GestureDetector(
                        onTap: () {
                          // Navigate to folders listing
                          Get.to(() => const FoldersListScreen());
                        },
                        child: AppText(
                          'View all',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isAdmin ? const Color(0xFF4F46E5) : const Color(0xFF059669),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const _RecentDocumentsList(),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

// ── ADMIN OVERVIEW CARD ──────────────────────────────────────────────────────
class _AdminOverviewCard extends StatelessWidget {
  const _AdminOverviewCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF1E3A8A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText(
            'Overview',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white70,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStat('Total Files', '2,485'),
              _buildStat('Folders', '168'),
              _buildStat('Shared', '634'),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AppText(
                'Storage Used',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
              const AppText(
                '48.6 GB / 100 GB',
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: const LinearProgressIndicator(
              value: 0.486,
              minHeight: 8,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFEF08A)), // Yellow highlight
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          value,
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
        const SizedBox(height: 4),
        AppText(
          label,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Colors.white70,
        ),
      ],
    );
  }
}

// ── EMPLOYEE OVERVIEW CARD ───────────────────────────────────────────────────
class _EmployeeOverviewCard extends StatelessWidget {
  const _EmployeeOverviewCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF065F46)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText(
            'My Documents Overview',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white70,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStat('My Files', '48'),
              _buildStat('Shared with Me', '32'),
              _buildStat('Storage Used', '2.6 GB'),
            ],
          ),
          const SizedBox(height: 24),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                'Available Storage',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
              AppText(
                '26% Used of 10 GB',
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: const LinearProgressIndicator(
              value: 0.26,
              minHeight: 8,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFEF08A)), // Yellow highlight
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          value,
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
        const SizedBox(height: 4),
        AppText(
          label,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Colors.white70,
        ),
      ],
    );
  }
}

// ── ADMIN QUICK ACTIONS ──────────────────────────────────────────────────────
class _AdminQuickActions extends StatelessWidget {
  const _AdminQuickActions();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DocumentsController>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildAction(
          icon: Iconsax.document_upload,
          label: 'Upload\nDocument',
          color: const Color(0xFF3B82F6),
          onTap: () => _showUploadSheet(context, controller),
        ),
        _buildAction(
          icon: Iconsax.folder_add,
          label: 'New\nFolder',
          color: const Color(0xFF10B981),
          onTap: () => _showAddFolderDialog(context, controller),
        ),
        _buildAction(
          icon: Iconsax.security_user,
          label: 'Manage\nAccess',
          color: const Color(0xFF8B5CF6),
          onTap: () => Get.to(() => const FoldersListScreen()),
        ),
        _buildAction(
          icon: Iconsax.trash,
          label: 'Recycle\nBin',
          color: const Color(0xFFEF4444),
          onTap: () {
            Get.snackbar(
              'Recycle Bin',
              'Recycle Bin details loading...',
              backgroundColor: const Color(0xFF1E293B),
              colorText: Colors.white,
            );
          },
        ),
      ],
    );
  }

  Widget _buildAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF475569),
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── EMPLOYEE QUICK ACCESS ────────────────────────────────────────────────────
class _EmployeeQuickAccess extends StatelessWidget {
  const _EmployeeQuickAccess();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildAccessCard(
          icon: Iconsax.document_text,
          label: 'My Documents',
          color: const Color(0xFF10B981),
          onTap: () => Get.to(() => const FoldersListScreen()),
        ),
        _buildAccessCard(
          icon: Iconsax.people,
          label: 'Shared with Me',
          color: const Color(0xFF3B82F6),
          onTap: () => Get.to(() => const EmployeeSharedScreen()),
        ),
        _buildAccessCard(
          icon: Iconsax.clock,
          label: 'Recent Files',
          color: const Color(0xFFF97316),
          onTap: () => Get.to(() => const FoldersListScreen()),
        ),
        _buildAccessCard(
          icon: Iconsax.star,
          label: 'Favorites',
          color: const Color(0xFFF59E0B),
          onTap: () {
            Get.snackbar(
              'Favorites',
              'No favorites documents set yet.',
              backgroundColor: const Color(0xFF1E293B),
              colorText: Colors.white,
            );
          },
        ),
      ],
    );
  }

  Widget _buildAccessCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 10),
              AppText(
                label,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF475569),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── RECENT DOCUMENTS LIST ────────────────────────────────────────────────────
class _RecentDocumentsList extends StatelessWidget {
  const _RecentDocumentsList();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DocumentsController>();

    return Obx(() {
      final documents = controller.isAdminView.value 
        ? controller.adminDocuments 
        : controller.employeeDocuments;

      if (documents.isEmpty) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 40),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFEEF2FF)),
          ),
          child: Column(
            children: [
              Icon(
                Iconsax.document_text,
                size: 40,
                color: AppColors.textColorHint.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 12),
              const AppText(
                'No recent documents found',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textColorHint,
              ),
            ],
          ),
        );
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: documents.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final doc = documents[index];
          return _DocumentTile(doc: doc);
        },
      );
    });
  }
}

class _DocumentTile extends StatelessWidget {
  final AppDocument doc;
  const _DocumentTile({required this.doc});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DocumentsController>();
    final iconData = _getIconData(doc.type);
    final iconColor = _getIconColor(doc.type);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEEF2FF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
                // File type icon box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(iconData, color: iconColor, size: 24),
                ),
                const SizedBox(width: 14),

                // Name & Metadata
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
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          AppText(
                            doc.folderName,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColorHint,
                          ),
                          Container(
                            width: 3,
                            height: 3,
                            decoration: const BoxDecoration(
                              color: AppColors.textColorHint,
                              shape: BoxShape.circle,
                            ),
                          ),
                          AppText(
                            doc.uploadedDate,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textColorHint,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Tag Badge & Menu
                Row(
                  children: [
                    // Status Badge (Public, HR Only, Team)
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

                    // Actions Menu Icon
                    IconButton(
                      icon: const Icon(
                        Icons.more_vert_rounded,
                        color: AppColors.textColorHint,
                        size: 20,
                      ),
                      onPressed: () => _showDocumentActionsBottomSheet(context, controller, doc),
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
        return const Color(0xFFEF4444); // Red
      case 'xlsx':
      case 'xls':
        return const Color(0xFF10B981); // Green
      case 'docx':
      case 'doc':
        return const Color(0xFF3B82F6); // Blue
      case 'zip':
      case 'rar':
        return const Color(0xFFF59E0B); // Amber
      default:
        return const Color(0xFF64748B); // Slate
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'public':
        return const Color(0xFFEFF6FF); // Slate Blue
      case 'hr only':
        return const Color(0xFFEEF2FF); // Indigo
      case 'team':
      default:
        return const Color(0xFFFFF7ED); // Orange
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'public':
        return const Color(0xFF2563EB); // Dark Blue
      case 'hr only':
        return const Color(0xFF4F46E5); // Indigo
      case 'team':
      default:
        return const Color(0xFFEA580C); // Dark Orange
    }
  }
}

// ── UTILITIES & MODALS ────────────────────────────────────────────────────────

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
          hintText: 'e.g. Finance, Marketing',
          hintStyle: const TextStyle(color: AppColors.textColorHint, fontSize: 13),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const AppText('Cancel', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textColorSecondary),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3B82F6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
  String selectedFolder = controller.isAdminView.value 
    ? (controller.adminFolders.isNotEmpty ? controller.adminFolders.first.name : 'Policies')
    : (controller.employeeFolders.isNotEmpty ? controller.employeeFolders.first.name : 'My Documents');
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

            // Document Name field
            const AppText('Document Name', fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textColorSecondary),
            const SizedBox(height: 8),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: 'e.g. Employee Handbook',
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),

            // Type and Status
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

            // Folder Select
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

            // Upload button
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

void _showDocumentActionsBottomSheet(BuildContext context, DocumentsController controller, AppDocument doc) {
  Get.bottomSheet(
    Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
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
          const SizedBox(height: 16),

          // File Title Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Iconsax.document_text5, color: Color(0xFFEF4444), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        doc.name,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textColorPrimary,
                      ),
                      const SizedBox(height: 2),
                      AppText(
                        '${doc.size} • ${doc.folderName}',
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

          const Divider(height: 24, color: AppColors.borderColor),

          _buildBottomSheetItem(
            icon: Iconsax.eye,
            label: 'Preview Document',
            onTap: () {
              Get.back();
              Get.to(() => DocumentPreviewScreen(fileName: doc.name));
            },
          ),
          _buildBottomSheetItem(
            icon: Iconsax.document_download,
            label: 'Download File',
            onTap: () {
              Get.back();
              Get.snackbar(
                'Downloading File',
                'Successfully downloaded "${doc.name}" to your local device.',
                backgroundColor: AppColors.successColor,
                colorText: Colors.white,
              );
            },
          ),
          if (controller.isAdminView.value)
            _buildBottomSheetItem(
              icon: Iconsax.security_user,
              label: 'Manage Access Controls',
              onTap: () {
                Get.back();
                Get.to(() => AccessControlScreen(fileName: doc.name));
              },
            ),
          _buildBottomSheetItem(
            icon: Iconsax.trash,
            label: 'Delete Document',
            iconColor: Colors.redAccent,
            textColor: Colors.redAccent,
            onTap: () {
              Get.back();
              controller.deleteDocument(doc);
            },
          ),
        ],
      ),
    ),
  );
}

Widget _buildBottomSheetItem({
  required IconData icon,
  required String label,
  required VoidCallback onTap,
  Color iconColor = AppColors.textColorSecondary,
  Color textColor = AppColors.textColorPrimary,
}) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 16),
            AppText(
              label,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ],
        ),
      ),
    ),
  );
}
