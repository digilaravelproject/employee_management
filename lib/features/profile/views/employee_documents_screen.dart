import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/user_document_controller.dart';
import '../models/user_document_model.dart';
import 'document_image_viewer_screen.dart';
import 'upload_document_bottom_sheet.dart';

class EmployeeDocumentsScreen extends StatelessWidget {
  const EmployeeDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserDocumentController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const AppText(
          'My Documents',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textColorPrimary,
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.textColorPrimary, size: 18),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            tooltip: 'Upload Document',
            icon: const Icon(Iconsax.document_upload,
                color: AppColors.primaryColor),
            onPressed: () => UploadDocumentBottomSheet.show(context),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.documents.isEmpty) {
          return _buildEmptyState(context);
        }

        return Column(
          children: [
            // Top Banner info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: AppColors.primaryColor.withValues(alpha: 0.06),
              child: Row(
                children: [
                  const Icon(Iconsax.info_circle,
                      size: 18, color: AppColors.primaryColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppText(
                      'Tap on any document to view full-screen and zoom in/out.',
                      fontSize: 12,
                      color: AppColors.primaryColor.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Document List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: controller.documents.length,
                itemBuilder: (context, index) {
                  final doc = controller.documents[index];
                  return _buildDocumentCard(context, doc, controller);
                },
              ),
            ),
          ],
        );
      }),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: AppButton(
            text: 'Upload New Document',
            icon: const Icon(Iconsax.document_upload,
                color: Colors.white, size: 18),
            onPressed: () => UploadDocumentBottomSheet.show(context),
            height: 52,
            borderRadius: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconsax.document_upload,
                size: 64,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            const AppText(
              'No Documents Uploaded',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textColorPrimary,
            ),
            const SizedBox(height: 8),
            const AppText(
              'Upload your Aadhar, PAN Card, Student ID, or other certificates to view them here.',
              fontSize: 13,
              textAlign: TextAlign.center,
              color: AppColors.textColorSecondary,
            ),
            const SizedBox(height: 24),
            AppButton(
              text: 'Upload Document',
              icon: const Icon(Iconsax.add, color: Colors.white, size: 18),
              onPressed: () => UploadDocumentBottomSheet.show(context),
              width: 200,
              height: 48,
              borderRadius: 12,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentCard(
    BuildContext context,
    UserDocumentItem doc,
    UserDocumentController controller,
  ) {
    final isVerified = doc.status.toLowerCase() == 'verified';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Open interactive full-screen zoomable image viewer!
            Get.to(
              () => DocumentImageViewerScreen(document: doc),
              transition: Transition.fadeIn,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 58,
                    height: 58,
                    color: AppColors.primaryColor.withValues(alpha: 0.08),
                    child: _buildThumbnail(doc),
                  ),
                ),
                const SizedBox(width: 14),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        doc.name,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textColorPrimary,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            doc.type == 'PDF'
                                ? Iconsax.document_text
                                : Iconsax.image,
                            size: 13,
                            color: AppColors.textColorSecondary,
                          ),
                          const SizedBox(width: 4),
                          AppText(
                            '${doc.type} • ${doc.size}',
                            fontSize: 12,
                            color: AppColors.textColorSecondary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Status tag & View icon
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isVerified
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: AppText(
                        doc.status,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: isVerified
                            ? Colors.green
                            : AppColors.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.zoom_in_rounded,
                          size: 18,
                          color: AppColors.primaryColor,
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            _confirmDelete(context, doc, controller);
                          },
                          child: const Icon(
                            Iconsax.trash,
                            size: 16,
                            color: AppColors.slate400,
                          ),
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

  Widget _buildThumbnail(UserDocumentItem doc) {
    if (doc.filePath != null && File(doc.filePath!).existsSync()) {
      return Image.file(
        File(doc.filePath!),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Iconsax.gallery, color: AppColors.primaryColor, size: 26),
        ),
      );
    } else if (doc.assetPath != null && doc.assetPath!.isNotEmpty) {
      return Image.asset(
        doc.assetPath!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Iconsax.gallery, color: AppColors.primaryColor, size: 26),
        ),
      );
    } else {
      return const Center(
        child: Icon(Iconsax.document_text,
            color: AppColors.primaryColor, size: 26),
      );
    }
  }

  void _confirmDelete(
    BuildContext context,
    UserDocumentItem doc,
    UserDocumentController controller,
  ) {
    Get.defaultDialog(
      title: 'Delete Document',
      middleText: 'Are you sure you want to delete "${doc.name}"?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        Get.back();
        controller.deleteDocument(doc.id);
      },
    );
  }
}
