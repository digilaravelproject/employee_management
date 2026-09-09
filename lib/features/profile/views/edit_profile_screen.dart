import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/controllers/app_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_input_field.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/user_document_controller.dart';
import '../models/user_document_model.dart';
import 'document_image_viewer_screen.dart';
import 'employee_documents_screen.dart';
import 'upload_document_bottom_sheet.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  File? _profileImage;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  void _showPhotoPicker() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Wrap(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: AppText('Select Profile Photo',
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListTile(
              leading: const Icon(Iconsax.gallery, color: AppColors.primaryColor),
              title: const AppText('Choose from Gallery', fontSize: 15),
              onTap: () {
                Get.back();
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Iconsax.camera, color: AppColors.primaryColor),
              title: const AppText('Take Photo with Camera', fontSize: 15),
              onTap: () {
                Get.back();
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined,
              color: AppColors.textColorPrimary, size: 18),
          onPressed: () => Get.back(),
        ),
        title: const AppText('Edit Profile',
            fontSize: 18, fontWeight: FontWeight.bold),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Avatar Card ──
                  _buildAvatarCard(),

                  // ── Section 1: Basic Information ──
                  _buildSectionCard(
                    icon: Iconsax.user,
                    title: 'Basic Information',
                    subtitle: 'Update your name and primary contact details',
                    children: [
                      _buildTextField('Full Name', 'Rahul Sharma'),
                      const SizedBox(height: 14),
                      _buildTextField('Email Address', 'rahul.sharma@company.com'),
                      const SizedBox(height: 14),
                      _buildTextField('Phone Number', '+91 98765 43210'),
                    ],
                  ),

                  // ── Section 2: Professional Details (Hide for Admin) ──
                  Obx(() => Get.find<AppController>().userRole.value != 'admin'
                      ? _buildSectionCard(
                          icon: Iconsax.briefcase,
                          title: 'Professional Details',
                          subtitle: 'Department, designation & employee credentials',
                          children: [
                            _buildTextField('Department', 'Design'),
                            const SizedBox(height: 14),
                            _buildTextField('Designation', 'UI/UX Designer'),
                            const SizedBox(height: 14),
                            _buildTextField('Employee ID', 'EMP1025'),
                            const SizedBox(height: 14),
                            _buildTextField('Date of Joining', '15 Jan 2024'),
                          ],
                        )
                      : const SizedBox.shrink()),

                  // ── Section 3: Address Details ──
                  _buildSectionCard(
                    icon: Iconsax.location,
                    title: 'Address Details',
                    subtitle: 'Permanent and communication residential address',
                    children: [
                      _buildTextField(
                        'Full Address',
                        '123, Green Park Street, Sector 45,\nNoida, Uttar Pradesh - 201301',
                        maxLines: 3,
                      ),
                    ],
                  ),

                  // ── Section 4: Bank Details (if not admin) ──
                  Obx(() => Get.find<AppController>().userRole.value != 'admin'
                      ? _buildSectionCard(
                          icon: Iconsax.bank,
                          title: 'Bank Details',
                          subtitle: 'Salary and payout account information',
                          children: [
                            _buildTextField('Bank Name', 'HDFC Bank'),
                            const SizedBox(height: 14),
                            _buildTextField('Account Number', '5010 1234 5678 90'),
                            const SizedBox(height: 14),
                            _buildTextField('Account Holder Name', 'Rahul Sharma'),
                            const SizedBox(height: 14),
                            _buildTextField('IFSC Code', 'HDFC0001234'),
                          ],
                        )
                      : const SizedBox.shrink()),

                  // ── Section 5: Documents & ID Proofs ──
                  _buildDocumentsSection(context),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Save Changes Bottom Bar
          Container(
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
              top: false,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  Get.snackbar(
                    'Success',
                    'Profile updated successfully',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const AppText('Save Changes',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryLight, width: 3),
                  image: _profileImage != null
                      ? DecorationImage(
                          image: FileImage(_profileImage!),
                          fit: BoxFit.cover,
                        )
                      : const DecorationImage(
                          image: AssetImage('assets/images/user1.png'),
                          fit: BoxFit.cover,
                        ),
                  color: AppColors.slate200,
                ),
                child: _profileImage == null
                    ? const Icon(Icons.person,
                        size: 38, color: AppColors.slate400)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _showPhotoPicker,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Iconsax.camera,
                        size: 13, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppText(
                  'Profile Photo',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColorPrimary,
                ),
                const SizedBox(height: 3),
                const AppText(
                  'Clear photo helps in easy identity verification',
                  fontSize: 12,
                  color: AppColors.textColorSecondary,
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _showPhotoPicker,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Iconsax.edit,
                            size: 13, color: AppColors.primaryColor),
                        SizedBox(width: 5),
                        AppText(
                          'Change Avatar',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primaryColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      title,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColorPrimary,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      AppText(
                        subtitle,
                        fontSize: 11,
                        color: AppColors.textColorSecondary,
                      ),
                    ],
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: AppColors.slate100, height: 1),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDocumentsSection(BuildContext context) {
    return _buildSectionCard(
      icon: Iconsax.document_upload,
      title: 'Documents & ID Proofs',
      subtitle: 'Upload and preview verified documents',
      trailing: TextButton.icon(
        onPressed: () => UploadDocumentBottomSheet.show(context),
        icon: const Icon(Icons.add, size: 15, color: AppColors.primaryColor),
        label: const AppText('Upload New',
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
      children: [
        // Upload Button Box
        InkWell(
          onTap: () => UploadDocumentBottomSheet.show(context),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.primaryColor.withValues(alpha: 0.25),
                width: 1.2,
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Iconsax.document_upload,
                      color: AppColors.primaryColor, size: 24),
                ),
                const SizedBox(height: 10),
                const AppText(
                  'Click here to Upload Document',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryColor,
                ),
                const SizedBox(height: 3),
                const AppText(
                  'Aadhar, PAN, Student ID, Marksheets or Certificates',
                  fontSize: 11,
                  color: AppColors.textColorSecondary,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // List of uploaded documents
        Obx(() {
          final docController = Get.put(UserDocumentController());
          if (docController.documents.isEmpty) {
            return const SizedBox.shrink();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText(
                    'Uploaded Documents (${docController.documents.length})',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textColorSecondary,
                  ),
                  GestureDetector(
                    onTap: () => Get.to(() => const EmployeeDocumentsScreen()),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppText(
                          'View Full List',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                        SizedBox(width: 2),
                        Icon(Icons.keyboard_arrow_right,
                            size: 14, color: AppColors.primaryColor),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: docController.documents.length,
                itemBuilder: (context, index) {
                  final doc = docController.documents[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.slate50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.slate200),
                    ),
                    child: Row(
                      children: [
                        // Thumbnail with zoom on tap
                        GestureDetector(
                          onTap: () {
                            Get.to(() =>
                                DocumentImageViewerScreen(document: doc));
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 44,
                              height: 44,
                              color:
                                  AppColors.primaryColor.withValues(alpha: 0.1),
                              child: _buildDocThumbnail(doc),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Get.to(() =>
                                  DocumentImageViewerScreen(document: doc));
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(doc.name,
                                    fontSize: 13, fontWeight: FontWeight.w700),
                                const SizedBox(height: 2),
                                AppText('${doc.type} • ${doc.size}',
                                    fontSize: 11,
                                    color: AppColors.textColorSecondary),
                              ],
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.zoom_in_rounded,
                              size: 20, color: AppColors.primaryColor),
                          tooltip: 'Preview & Zoom',
                          onPressed: () {
                            Get.to(() =>
                                DocumentImageViewerScreen(document: doc));
                          },
                        ),
                        IconButton(
                          icon: const Icon(Iconsax.trash,
                              size: 17, color: Colors.redAccent),
                          tooltip: 'Delete',
                          onPressed: () {
                            docController.deleteDocument(doc.id);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildTextField(String label, String initialValue, {int maxLines = 1}) {
    return AppInputField(
      label: label,
      hint: 'Enter $label',
      controller: TextEditingController(text: initialValue),
      maxLines: maxLines,
    );
  }

  Widget _buildDocThumbnail(UserDocumentItem doc) {
    if (doc.filePath != null && File(doc.filePath!).existsSync()) {
      return Image.file(
        File(doc.filePath!),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Iconsax.gallery, color: AppColors.primaryColor, size: 22),
      );
    } else if (doc.assetPath != null && doc.assetPath!.isNotEmpty) {
      return Image.asset(
        doc.assetPath!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Iconsax.gallery, color: AppColors.primaryColor, size: 22),
      );
    } else {
      return const Icon(Iconsax.document_text,
          color: AppColors.primaryColor, size: 22);
    }
  }
}
