import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';

class LeaveApprovalScreen extends StatelessWidget {
  final Map<String, dynamic> requestData;

  const LeaveApprovalScreen({super.key, required this.requestData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textColorPrimary),
          onPressed: () => Get.back(),
        ),
        title: const AppText('Leave Approval', fontSize: 18, fontWeight: FontWeight.bold),
        centerTitle: false,
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.more_vert, color: AppColors.textColorPrimary),
        //     onPressed: () {},
        //   ),
        // ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderColor),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.slate200,
                          child: Icon(Icons.person, color: AppColors.slate400, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(requestData['name'] ?? 'Rahul Sharma', fontSize: 16, fontWeight: FontWeight.bold),
                              const SizedBox(height: 2),
                              AppText(requestData['designation'] ?? 'UI/UX Designer', fontSize: 12, color: AppColors.textColorSecondary),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLight,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const AppText('EMP1025', fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const AppText('Design Department', fontSize: 12, color: AppColors.textColorPrimary),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const AppText('CL', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Leave Details
                  const AppText('Leave Details', fontSize: 14, fontWeight: FontWeight.bold),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderColor),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow('Leave Type', requestData['type'] ?? 'Casual Leave'),
                        _buildDivider(),
                        _buildDetailRow('From Date', '20 May 2025 (Tue)'),
                        _buildDivider(),
                        _buildDetailRow('To Date', '22 May 2025 (Thu)'),
                        _buildDivider(),
                        _buildDetailRow('Total Days', requestData['duration'] ?? '3 Days', isBoldValue: true),
                        _buildDivider(),
                        _buildDetailRow('Reason', 'Personal work at hometown.'),
                        _buildDivider(),
                        _buildDetailRow('Contact During Leave', '9876543210'),
                        _buildDivider(),
                        _buildDetailRow('Applied On', '18 May 2025, 10:30 AM'),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Leave Balance
                  const AppText('Leave Balance', fontSize: 14, fontWeight: FontWeight.bold),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderColor),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildBalanceItem('Total', '12 Days', Colors.black),
                        _buildVerticalDivider(),
                        _buildBalanceItem('Taken', '6 Days', Colors.black),
                        _buildVerticalDivider(),
                        _buildBalanceItem('Pending', '0 Days', Colors.black),
                        _buildVerticalDivider(),
                        _buildBalanceItem('Remaining', '6 Days', Colors.green),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Attachment
                  const AppText('Attachment', fontSize: 14, fontWeight: FontWeight.bold),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderColor),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Iconsax.document, color: AppColors.primaryColor, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const AppText('Train_Ticket.pdf', fontSize: 13, fontWeight: FontWeight.w600),
                              const SizedBox(height: 4),
                              const AppText('120 KB', fontSize: 11, color: AppColors.textColorSecondary),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Iconsax.document_download, color: AppColors.textColorPrimary),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Approval Timeline
                  const AppText('Approval Timeline', fontSize: 14, fontWeight: FontWeight.bold),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.slate200,
                        child: Icon(Icons.person, color: AppColors.slate400, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(requestData['name'] ?? 'Rahul Sharma', fontSize: 13, fontWeight: FontWeight.w600),
                            const SizedBox(height: 2),
                            const AppText('Leave Applied', fontSize: 11, color: AppColors.textColorSecondary),
                          ],
                        ),
                      ),
                      const AppText('18 May 2025, 10:30 AM', fontSize: 11, color: AppColors.textColorSecondary),
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          
          // Bottom Buttons
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
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Get.back();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const AppText('Reject', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const AppText('Approve', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBoldValue = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: AppText(label, fontSize: 12, color: AppColors.textColorSecondary),
          ),
          Expanded(
            flex: 3,
            child: AppText(
              value,
              fontSize: 12,
              fontWeight: isBoldValue ? FontWeight.bold : FontWeight.w500,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Divider(color: AppColors.borderColor, height: 1),
    );
  }

  Widget _buildBalanceItem(String label, String value, Color valueColor) {
    return Column(
      children: [
        AppText(label, fontSize: 11, color: AppColors.textColorSecondary),
        const SizedBox(height: 4),
        AppText(
          value,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: valueColor,
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 30,
      color: AppColors.slate200,
    );
  }
}
