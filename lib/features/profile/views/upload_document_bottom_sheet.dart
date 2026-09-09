import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/user_document_controller.dart';

class UploadDocumentBottomSheet extends StatefulWidget {
  const UploadDocumentBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const UploadDocumentBottomSheet(),
    );
  }

  @override
  State<UploadDocumentBottomSheet> createState() =>
      _UploadDocumentBottomSheetState();
}

class _UploadDocumentBottomSheetState extends State<UploadDocumentBottomSheet> {
  final TextEditingController _nameController = TextEditingController();
  String _selectedCategory = 'Aadhar Card';

  final List<String> _quickCategories = [
    'Aadhar Card',
    'PAN Card',
    'Student ID Card',
    'Marksheet / Degree',
    'Resume / CV',
    'Certificate',
  ];

  @override
  void initState() {
    super.initState();
    _nameController.text = _selectedCategory;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserDocumentController());
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: bottomInset + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle Bar
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.slate300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Iconsax.document_upload,
                    color: AppColors.primaryColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      'Upload Document',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textColorPrimary,
                    ),
                    SizedBox(height: 2),
                    AppText(
                      'Select category and choose an image or file',
                      fontSize: 12,
                      color: AppColors.textColorSecondary,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Quick Category Chips
            const AppText(
              'Select Document Type',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textColorPrimary,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _quickCategories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = cat;
                      _nameController.text = cat;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryColor
                          : AppColors.slate100,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryColor
                            : AppColors.slate200,
                      ),
                    ),
                    child: AppText(
                      cat,
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      color:
                          isSelected ? Colors.white : AppColors.textColorPrimary,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Custom Title Input
            const AppText(
              'Document Title',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textColorPrimary,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Enter document name',
                filled: true,
                fillColor: AppColors.slate50,
                prefixIcon: const Icon(Iconsax.edit_2,
                    size: 18, color: AppColors.slate400),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
            const SizedBox(height: 24),

            // Upload Options
            const AppText(
              'Choose Upload Method',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textColorPrimary,
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                // Camera
                Expanded(
                  child: _buildUploadOption(
                    icon: Iconsax.camera,
                    title: 'Camera',
                    subtitle: 'Take photo',
                    color: const Color(0xFF2563EB),
                    onTap: () async {
                      Navigator.pop(context);
                      await controller.pickAndUploadImage(
                        documentName: _nameController.text.trim(),
                        source: ImageSource.camera,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),

                // Gallery
                Expanded(
                  child: _buildUploadOption(
                    icon: Iconsax.gallery,
                    title: 'Gallery',
                    subtitle: 'Choose image',
                    color: const Color(0xFF059669),
                    onTap: () async {
                      Navigator.pop(context);
                      await controller.pickAndUploadImage(
                        documentName: _nameController.text.trim(),
                        source: ImageSource.gallery,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),

                // File
                Expanded(
                  child: _buildUploadOption(
                    icon: Iconsax.document,
                    title: 'Files',
                    subtitle: 'PDF / Image',
                    color: const Color(0xFF7C3AED),
                    onTap: () async {
                      Navigator.pop(context);
                      await controller.pickAndUploadFile(
                        documentName: _nameController.text.trim(),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 10),
            AppText(
              title,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textColorPrimary,
            ),
            const SizedBox(height: 2),
            AppText(
              subtitle,
              fontSize: 10,
              color: AppColors.textColorSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
