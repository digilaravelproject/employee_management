import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_validators.dart';
import '../../../core/widgets/app_input_field.dart';
import '../../../core/widgets/app_text.dart';
import '../../auth/domain/models/user_model.dart';
import '../controllers/profile_controller.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final ProfileController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());
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
              child: AppText(
                'Select Profile Photo',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            ListTile(
              leading: const Icon(Iconsax.gallery, color: AppColors.primaryColor),
              title: const AppText('Choose from Gallery', fontSize: 15),
              onTap: () {
                Get.back();
                controller.pickAvatar(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Iconsax.camera, color: AppColors.primaryColor),
              title: const AppText('Take Photo with Camera', fontSize: 15),
              onTap: () {
                Get.back();
                controller.pickAvatar(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();
    try {
      if (controller.dateOfJoiningController.text.isNotEmpty) {
        initialDate = DateTime.parse(controller.dateOfJoiningController.text.trim());
      }
    } catch (_) {}

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1980),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              onSurface: AppColors.textColorPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formatted =
          "${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      controller.dateOfJoiningController.text = formatted;
    }
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
        title: Obx(() => AppText(
              controller.isUserAdmin ? 'Edit Admin Profile' : 'Edit Profile',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            )),
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
                      AppInputField(
                        label: 'Full Name',
                        hint: 'Enter your full name',
                        controller: controller.nameController,
                      ),
                      const SizedBox(height: 14),
                      AppInputField(
                        label: 'Email Address',
                        hint: 'Email address',
                        controller: controller.emailController,
                        readOnly: true,
                      ),
                      const SizedBox(height: 14),
                      AppInputField(
                        label: 'Phone Number',
                        hint: 'Enter 10-digit phone number',
                        controller: controller.phoneController,
                        keyboardType: TextInputType.phone,
                        validator: (val) => AppValidators.validateMobile(val, customMessage: 'Enter a valid 10-digit phone number'),
                      ),
                    ],
                  ),

                  // ── Section 2: Professional Details (Employee Only) ──
                  Obx(() {
                    if (controller.isUserAdmin) {
                      return const SizedBox.shrink();
                    }
                    return _buildSectionCard(
                      icon: Iconsax.briefcase,
                      title: 'Professional Details',
                      subtitle:
                          'Department, designation & employee credentials',
                      children: [
                        AppInputField(
                          label: 'Department',
                          hint: 'Enter department',
                          controller: controller.departmentController,
                        ),
                        const SizedBox(height: 14),
                        AppInputField(
                          label: 'Designation',
                          hint: 'Enter designation',
                          controller: controller.designationController,
                        ),
                        const SizedBox(height: 14),
                        AppInputField(
                          label: 'Employee ID',
                          hint: 'Enter employee ID',
                          controller: controller.employeeIdController,
                        ),
                        const SizedBox(height: 14),
                        GestureDetector(
                          onTap: () => _pickDate(context),
                          child: AbsorbPointer(
                            child: AppInputField(
                              label: 'Date of Joining',
                              hint: 'YYYY-MM-DD',
                              controller: controller.dateOfJoiningController,
                              suffixIcon: const Icon(
                                Iconsax.calendar,
                                color: AppColors.primaryColor,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),

                  // ── Section 3: Address Details ──
                  _buildSectionCard(
                    icon: Iconsax.location,
                    title: 'Address Details',
                    subtitle: 'Permanent and communication residential address',
                    children: [
                      AppInputField(
                        label: 'Full Address',
                        hint: 'Enter residential or official address',
                        controller: controller.addressController,
                        maxLines: 3,
                      ),
                    ],
                  ),

                  // ── Section 4: Bank Details (Employee Only) ──
                  Obx(() {
                    if (controller.isUserAdmin) {
                      return const SizedBox.shrink();
                    }
                    return _buildSectionCard(
                      icon: Iconsax.bank,
                      title: 'Bank Details',
                      subtitle: 'Salary and payout account information',
                      children: [
                        AppInputField(
                          label: 'Bank Name',
                          hint: 'Enter bank name',
                          controller: controller.bankNameController,
                        ),
                        const SizedBox(height: 14),
                        AppInputField(
                          label: 'Account Number',
                          hint: 'Enter account number',
                          controller: controller.accountNumberController,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 14),
                        AppInputField(
                          label: 'Account Holder Name',
                          hint: 'Enter account holder name',
                          controller: controller.accountHolderNameController,
                        ),
                        const SizedBox(height: 14),
                        AppInputField(
                          label: 'IFSC Code',
                          hint: 'Enter IFSC code',
                          controller: controller.ifscCodeController,
                        ),
                        const SizedBox(height: 14),
                        AppInputField(
                          label: 'Branch Name',
                          hint: 'Enter branch name',
                          controller: controller.branchNameController,
                        ),
                      ],
                    );
                  }),

                  // ── Section 5: Documents & ID Proofs (Employee Only) ──
                  Obx(() {
                    if (controller.isUserAdmin) {
                      return const SizedBox.shrink();
                    }
                    return _buildDocumentsSection(context);
                  }),

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
              child: Obx(
                () => ElevatedButton(
                  onPressed: controller.isUpdating.value
                      ? null
                      : () async {
                          final success = await controller.updateProfile();
                          if (success) {
                            Get.back();
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    disabledBackgroundColor:
                        AppColors.primaryColor.withValues(alpha: 0.6),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: controller.isUpdating.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      : const AppText(
                          'Save Changes',
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                ),
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
              Obx(() {
                final File? file = controller.selectedAvatar.value;
                final String? avatarUrl = controller.currentUser.value?.avatar;

                ImageProvider imageProvider;
                if (file != null) {
                  imageProvider = FileImage(file);
                } else if (avatarUrl != null &&
                    avatarUrl.isNotEmpty &&
                    avatarUrl.startsWith('http')) {
                  imageProvider = NetworkImage(avatarUrl);
                } else {
                  imageProvider = const AssetImage('assets/images/user1.png');
                }

                return Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryLight, width: 3),
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                    color: AppColors.slate200,
                  ),
                );
              }),
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
      subtitle: 'Upload document images (Camera or Gallery)',
      trailing: TextButton.icon(
        onPressed: () => controller.showAddDocumentImagePicker(context),
        icon: const Icon(Icons.add_a_photo_outlined, size: 15, color: AppColors.primaryColor),
        label: const AppText('Add Image',
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
          onTap: () => controller.showAddDocumentImagePicker(context),
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
                  child: const Icon(Iconsax.camera,
                      color: AppColors.primaryColor, size: 24),
                ),
                const SizedBox(height: 10),
                const AppText(
                  'Click here to Add Document Image',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryColor,
                ),
                const SizedBox(height: 3),
                const AppText(
                  'Camera or Gallery (Images only: JPG, PNG, WEBP)',
                  fontSize: 11,
                  color: AppColors.textColorSecondary,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // ── Newly Selected Documents (to be synced) ──
        Obx(() {
          if (controller.selectedDocuments.isEmpty) {
            return const SizedBox.shrink();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText(
                    'Selected for Upload (${controller.selectedDocuments.length})',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryColor,
                  ),
                  TextButton(
                    onPressed: () => controller.selectedDocuments.clear(),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const AppText('Clear All',
                        fontSize: 11, color: Colors.redAccent),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.selectedDocuments.length,
                itemBuilder: (context, index) {
                  final file = controller.selectedDocuments[index];
                  final name = file.path.split(Platform.pathSeparator).last;
                  final sizeKb = (file.lengthSync() / 1024).toStringAsFixed(1);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color:
                              AppColors.primaryColor.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.file(
                            file,
                            width: 38,
                            height: 38,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, stack) => const Icon(
                              Iconsax.image,
                              color: AppColors.primaryColor,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(name,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                              AppText('$sizeKb KB • Ready to submit',
                                  fontSize: 10,
                                  color: AppColors.textColorSecondary),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close,
                              size: 18, color: Colors.redAccent),
                          onPressed: () =>
                              controller.removeSelectedDocument(index),
                          tooltip: 'Remove',
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
          );
        }),

        // ── Server Uploaded Documents (from API response) ──
        Obx(() {
          final List<UserDocument>? serverDocs =
              controller.currentUser.value?.documents;
          if (serverDocs == null || serverDocs.isEmpty) {
            return const SizedBox.shrink();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                'Synced Server Documents (${serverDocs.length})',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textColorSecondary,
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: serverDocs.length,
                itemBuilder: (context, index) {
                  final doc = serverDocs[index];
                  final displayName =
                      doc.originalName ?? doc.fileName ?? 'Document ${index + 1}';
                  final sizeKb = doc.size != null
                      ? '${(doc.size! / 1024).toStringAsFixed(1)} KB'
                      : 'File';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.slate50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.slate200),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Iconsax.tick_circle,
                              color: Colors.green, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(displayName,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 2),
                              AppText(
                                '$sizeKb • Verified',
                                fontSize: 10,
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Iconsax.trash,
                              size: 18, color: Colors.redAccent),
                          tooltip: 'Delete Document',
                          onPressed: () {
                            if (doc.id != null) {
                              controller.showDeleteDocumentDialog(
                                context,
                                documentId: doc.id!,
                                documentName: displayName,
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
          );
        }),
      ],
    );
  }
}
