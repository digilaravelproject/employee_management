import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text.dart';
import '../../auth/domain/models/user_model.dart';
import '../controllers/profile_controller.dart';

class EmployeeDocumentsScreen extends StatelessWidget {
  const EmployeeDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileController = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());

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
            tooltip: 'Add Document Image',
            icon: const Icon(Icons.add_a_photo_outlined,
                color: AppColors.primaryColor),
            onPressed: () => profileController.showAddDocumentImagePicker(context),
          ),
        ],
      ),
      body: Obx(() {
        final serverDocs = profileController.currentUser.value?.documents ?? [];

        if (serverDocs.isEmpty) {
          return _buildEmptyState(context, profileController);
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
                      'Tap on delete icon to permanently remove document.',
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
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Row(
                    children: [
                      const Icon(Iconsax.document,
                          size: 16, color: AppColors.primaryColor),
                      const SizedBox(width: 8),
                      AppText(
                        'Uploaded Documents (${serverDocs.length})',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColorPrimary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...serverDocs.map((doc) =>
                      _buildServerDocumentCard(context, doc, profileController)),
                ],
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
            text: 'Add Document Image',
            icon: const Icon(Iconsax.camera, color: Colors.white, size: 18),
            onPressed: () => profileController.showAddDocumentImagePicker(context),
            height: 52,
            borderRadius: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
      BuildContext context, ProfileController profileController) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconsax.document_text,
                size: 44,
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
              'No documents found on server. Upload document images (Camera or Gallery) using the button below.',
              fontSize: 13,
              textAlign: TextAlign.center,
              color: AppColors.textColorSecondary,
            ),
            const SizedBox(height: 24),
            AppButton(
              text: 'Add Document Image',
              icon: const Icon(Iconsax.camera, color: Colors.white, size: 18),
              onPressed: () =>
                  profileController.showAddDocumentImagePicker(context),
              width: 220,
              height: 48,
              borderRadius: 12,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServerDocumentCard(
    BuildContext context,
    UserDocument doc,
    ProfileController profileController,
  ) {
    final String displayName =
        doc.originalName ?? doc.fileName ?? 'Document #${doc.id ?? ''}';
    final String sizeStr = doc.size != null
        ? '${(doc.size! / 1024).toStringAsFixed(1)} KB'
        : 'File';
    final bool isImage = (doc.mimeType ?? '').contains('image') ||
        (doc.fileName ?? '').endsWith('.jpg') ||
        (doc.fileName ?? '').endsWith('.png') ||
        (doc.fileName ?? '').endsWith('.jpeg');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Thumbnail / Icon
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 54,
                height: 54,
                color: Colors.green.withValues(alpha: 0.08),
                child: doc.url != null && isImage
                    ? Image.network(
                        doc.url!,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => const Center(
                          child: Icon(Iconsax.gallery,
                              color: Colors.green, size: 24),
                        ),
                      )
                    : const Center(
                        child: Icon(Iconsax.document_text,
                            color: Colors.green, size: 24),
                      ),
              ),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    displayName,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textColorPrimary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        isImage ? Iconsax.image : Iconsax.document,
                        size: 13,
                        color: AppColors.textColorSecondary,
                      ),
                      const SizedBox(width: 4),
                      AppText(
                        '$sizeStr • Synced',
                        fontSize: 12,
                        color: AppColors.textColorSecondary,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Verified Badge & Delete Button
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const AppText(
                    'Verified',
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(
                    Iconsax.trash,
                    size: 18,
                    color: Colors.redAccent,
                  ),
                  tooltip: 'Delete Document',
                  onPressed: () {
                    if (doc.id != null) {
                      profileController.showDeleteDocumentDialog(
                        context,
                        documentId: doc.id!,
                        documentName: displayName,
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
