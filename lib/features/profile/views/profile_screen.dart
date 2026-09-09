import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/controllers/app_controller.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';
import 'employee_documents_screen.dart';
import '../controllers/user_document_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back, color: AppColors.textColorPrimary),
        //   onPressed: () {},
        // ),
        title: const AppText('Profile', fontSize: 18, fontWeight: FontWeight.bold),
        centerTitle: false,
      ),
      body: ListView(
        children: [
          // Profile Header
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.slate50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/user1.png'), // Will fallback to icon if not found
                      fit: BoxFit.cover,
                    ),
                    color: AppColors.slate200,
                  ),
                  child: const Icon(Icons.person, size: 40, color: AppColors.slate400),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const AppText('Rahul Sharma', fontSize: 16, fontWeight: FontWeight.bold),
                      const SizedBox(height: 4),
                      const AppText('UI/UX Designer', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primaryColor),
                      const SizedBox(height: 8),
                      _buildContactRow(Iconsax.sms, 'rahul.sharma@company.com'),
                      const SizedBox(height: 4),
                      _buildContactRow(Iconsax.call, '+91 98765 43210'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Iconsax.document_copy, color: AppColors.textColorSecondary, size: 14),
                          const SizedBox(width: 4),
                          const AppText('EMP1025', fontSize: 12, color: AppColors.textColorSecondary),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                                const SizedBox(width: 4),
                                const AppText('Active', fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Get.to(() => const EditProfileScreen()),
                    icon: const Icon(Iconsax.edit, size: 16, color: AppColors.primaryColor),
                    label: const AppText('Edit Profile', fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: AppColors.primaryColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      backgroundColor: AppColors.primaryColor.withValues(alpha: 0.05),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Get.to(() => const ChangePasswordScreen()),
                    icon: const Icon(Iconsax.lock, size: 16, color: AppColors.textColorPrimary),
                    label: const AppText('Change Password', fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: AppColors.borderColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Overview Sections
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _buildSectionCard(
                  icon: Iconsax.user,
                  title: 'Basic Information',
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildDetailItem('Name', 'Rahul Sharma')),
                        Expanded(child: _buildDetailItem('Email', 'rahul.sharma@company.com')),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildDetailItem('Phone', '+91 98765 43210')),
                        const Expanded(child: SizedBox()),
                      ],
                    ),
                  ],
                ),
                
                // Professional Details (Hide for Admin)
                Obx(() => Get.find<AppController>().userRole.value != 'admin'
                    ? Column(
                        children: [
                          const SizedBox(height: 16),
                          _buildSectionCard(
                            icon: Iconsax.briefcase,
                            title: 'Professional Details',
                            children: [
                              Row(
                                children: [
                                  Expanded(child: _buildDetailItem('Department', 'Design')),
                                  Expanded(child: _buildDetailItem('Designation', 'UI/UX Designer')),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(child: _buildDetailItem('Employee ID', 'EMP1025')),
                                  Expanded(child: _buildDetailItem('Date of Joining', '15 Jan 2024')),
                                ],
                              ),
                            ],
                          ),
                        ],
                      )
                    : const SizedBox.shrink()),
                
                const SizedBox(height: 16),
                
                _buildSectionCard(
                  icon: Iconsax.location,
                  title: 'Address Details',
                  children: [
                    const AppText(
                      '123, Green Park Street, Sector 45,\nNoida, Uttar Pradesh - 201301',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
                
                // Bank Details (Hide for Admin)
                Obx(() => Get.find<AppController>().userRole.value != 'admin'
                    ? Column(
                        children: [
                          const SizedBox(height: 16),
                          _buildSectionCard(
                            icon: Iconsax.bank,
                            title: 'Bank Details',
                            children: [
                              Row(
                                children: [
                                  Expanded(child: _buildDetailItem('Bank Name', 'HDFC Bank')),
                                  Expanded(child: _buildDetailItem('Account Number', '5010 1234 5678 90')),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(child: _buildDetailItem('Account Holder Name', 'Rahul Sharma')),
                                  Expanded(child: _buildDetailItem('IFSC Code', 'HDFC0001234')),
                                ],
                              ),
                            ],
                          ),
                        ],
                      )
                    : const SizedBox.shrink()),

                const SizedBox(height: 16),

                // View Documents Button
                InkWell(
                  onTap: () => Get.to(() => const EmployeeDocumentsScreen()),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderColor),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.slate100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Iconsax.folder_open, color: AppColors.textColorPrimary, size: 20),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                'View Documents',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColorPrimary,
                              ),
                              SizedBox(height: 2),
                              AppText(
                                'View, zoom & review uploaded documents',
                                fontSize: 11,
                                color: AppColors.textColorSecondary,
                              ),
                            ],
                          ),
                        ),
                        Obx(() {
                          final docController = Get.put(UserDocumentController());
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: AppText(
                              '${docController.documents.length} Files',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryColor,
                            ),
                          );
                        }),
                        const SizedBox(width: 6),
                        const Icon(Icons.keyboard_arrow_right, color: AppColors.textColorSecondary),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24), // Small spacing at the bottom of list
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textColorSecondary, size: 14),
        const SizedBox(width: 6),
        AppText(text, fontSize: 11, color: AppColors.textColorSecondary),
      ],
    );
  }

  Widget _buildSectionCard({required IconData icon, required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
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
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.primaryColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppText(title, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const Icon(Icons.keyboard_arrow_right, color: AppColors.textColorSecondary),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.borderColor, height: 1),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(label, fontSize: 11, color: AppColors.textColorSecondary),
        const SizedBox(height: 4),
        AppText(value, fontSize: 13, fontWeight: FontWeight.w600),
      ],
    );
  }
}
