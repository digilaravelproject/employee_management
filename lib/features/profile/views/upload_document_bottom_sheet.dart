import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/profile_controller.dart';

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
  bool _isUploading = false;

  final List<String> _quickCategories = [
    'Aadhar Card',
    'PAN Card',
    'Student ID Card',
    'Marksheet / Degree',
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

  Future<void> _pickAndUpload(ImageSource source) async {
    final profileController = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());

    final file = await profileController.pickDocumentImage(source);
    if (file != null) {
      if (mounted) {
        setState(() {
          _isUploading = true;
        });
        Navigator.pop(context);
      }
      await profileController.uploadDocumentImageViaEditProfile(file);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      'Upload Document Image',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textColorPrimary,
                    ),
                    SizedBox(height: 2),
                    AppText(
                      'Select category and choose an image (Images only)',
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
                      color: isSelected
                          ? Colors.white
                          : AppColors.textColorPrimary,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Document Title Input Field
            const AppText(
              'Document Title',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textColorPrimary,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: 'e.g. Aadhar Front & Back',
                hintStyle: const TextStyle(
                    fontSize: 13, color: AppColors.textColorSecondary),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                filled: true,
                fillColor: AppColors.slate50,
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

            // Upload Options (Images only)
            const AppText(
              'Choose Upload Method (Images Only)',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textColorPrimary,
            ),
            const SizedBox(height: 12),

            if (_isUploading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: AppColors.primaryColor),
                      SizedBox(height: 10),
                      AppText(
                        'Uploading document via edit profile API...',
                        fontSize: 13,
                        color: AppColors.textColorSecondary,
                      ),
                    ],
                  ),
                ),
              )
            else
              Row(
                children: [
                  // Camera
                  Expanded(
                    child: _buildUploadOption(
                      icon: Iconsax.camera,
                      title: 'Camera',
                      subtitle: 'Take photo',
                      color: AppColors.primaryColor,
                      onTap: () => _pickAndUpload(ImageSource.camera),
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
                      onTap: () => _pickAndUpload(ImageSource.gallery),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 10),
              AppText(
                title,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
              ),
              const SizedBox(height: 2),
              AppText(
                subtitle,
                fontSize: 11,
                color: AppColors.textColorSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
