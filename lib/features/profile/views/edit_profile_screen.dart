import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_input_field.dart';
import '../../../core/controllers/app_controller.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined, color: AppColors.textColorPrimary),
          onPressed: () => Get.back(),
        ),
        title: const AppText('Edit Profile', fontSize: 18, fontWeight: FontWeight.bold),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar Section
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.primaryLight, width: 4),
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
                          child: _profileImage == null ? const Icon(Icons.person, size: 50, color: AppColors.slate400) : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              Get.bottomSheet(
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 20),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                                  ),
                                  child: Wrap(
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                        child: AppText('Select Photo', fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                      ListTile(
                                        leading: const Icon(Iconsax.gallery, color: AppColors.primaryColor),
                                        title: const AppText('Gallery', fontSize: 15),
                                        onTap: () {
                                          Get.back();
                                          _pickImage(ImageSource.gallery);
                                        },
                                      ),
                                      ListTile(
                                        leading: const Icon(Iconsax.camera, color: AppColors.primaryColor),
                                        title: const AppText('Camera', fontSize: 15),
                                        onTap: () {
                                          Get.back();
                                          _pickImage(ImageSource.camera);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(Iconsax.camera, size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Basic Information
                  _buildSectionHeader(Iconsax.user, 'Basic Information'),
                  const SizedBox(height: 16),
                  _buildTextField('Name', 'Rahul Sharma'),
                  const SizedBox(height: 16),
                  _buildTextField('Email', 'rahul.sharma@company.com'),
                  const SizedBox(height: 16),
                  _buildTextField('Phone', '+91 98765 43210'),
                  
                  const SizedBox(height: 32),
                  
                  // Professional Details
                  _buildSectionHeader(Iconsax.briefcase, 'Professional Details'),
                  const SizedBox(height: 16),
                  _buildTextField('Department', 'Design'),
                  const SizedBox(height: 16),
                  _buildTextField('Designation', 'UI/UX Designer'),
                  const SizedBox(height: 16),
                  _buildTextField('Employee ID', 'EMP1025'),
                  const SizedBox(height: 16),
                  _buildTextField('Date of Joining', '15 Jan 2024'),
                  
                  const SizedBox(height: 32),
                  
                  // Address Details
                  _buildSectionHeader(Iconsax.location, 'Address Details'),
                  const SizedBox(height: 16),
                  _buildTextField(
                    'Full Address', 
                    '123, Green Park Street, Sector 45,\nNoida, Uttar Pradesh - 201301',
                    maxLines: 3,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  Obx(() => Get.find<AppController>().userRole.value != 'admin' ? Column(
                    children: [
                      // Bank Details
                      _buildSectionHeader(Iconsax.bank, 'Bank Details'),
                      const SizedBox(height: 16),
                      _buildTextField('Bank Name', 'HDFC Bank'),
                      const SizedBox(height: 16),
                      _buildTextField('Account Number', '5010 1234 5678 90'),
                      const SizedBox(height: 16),
                      _buildTextField('Account Holder Name', 'Rahul Sharma'),
                      const SizedBox(height: 16),
                      _buildTextField('IFSC Code', 'HDFC0001234'),
                    ],
                  ) : const SizedBox.shrink()),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          
          // Save Button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const AppText('Save Changes', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryColor, size: 20),
        const SizedBox(width: 8),
        AppText(title, fontSize: 15, fontWeight: FontWeight.bold),
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
}
