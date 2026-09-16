import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/documents_controller.dart';
import 'document_preview_screen.dart';

class EmployeeSharedScreen extends StatelessWidget {
  const EmployeeSharedScreen({super.key});

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
          'Shared with Me',
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
        child: Obx(() {
          final docs = controller.sharedDocuments;

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.people, size: 48, color: AppColors.textColorHint.withValues(alpha: 0.3)),
                  const SizedBox(height: 12),
                  const AppText(
                    'No shared documents found',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColorHint,
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            physics: const BouncingScrollPhysics(),
            itemCount: docs.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final doc = docs[index];
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
                      blurRadius: 8,
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
                                  'Shared by ${doc.uploadedBy} • ${doc.uploadedDate}',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textColorHint,
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textColorHint),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }),
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
}
