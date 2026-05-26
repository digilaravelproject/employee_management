import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/payroll_controller.dart';
import 'salary_employee_list_screen.dart';

class PayslipCreatedScreen extends StatelessWidget {
  const PayslipCreatedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PayrollController>();

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
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textColorPrimary, size: 20),
              onPressed: () {
                // If popping success screen, pop to the list screen and refresh state
                Get.offAll(() => const SalaryEmployeeListScreen());
              },
            ),
          ),
        ),
        title: const AppText(
          'Payslip',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textColorPrimary,
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.document_download, color: AppColors.textColorPrimary),
            onPressed: () => _triggerDownload(controller),
          ),
        ],
      ),
      body: Obx(() {
        final record = controller.selectedRecord.value;
        if (record == null) {
          return const Center(child: AppText('No details available.'));
        }

        final grossVal = "₹${_formatSalary(record.grossEarnings.toInt())}";
        final deductVal = "₹${_formatSalary(record.totalDeductions.toInt())}";
        final netVal = "₹${_formatSalary(record.netPayable.toInt())}";

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── 1. Success Message Banner ──
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.successColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.successColor.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.successColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check, color: Colors.white, size: 14),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: AppText(
                              'Salary Created Successfully',
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.successColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── 2. Employee Profile Card ──
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.slate200),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.slate100),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(25),
                              child: record.profilePic != null
                                  ? Image.network(record.profilePic!, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => _buildFallbackAvatar(record.employeeName))
                                  : _buildFallbackAvatar(record.employeeName),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(
                                  record.employeeName,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textColorPrimary,
                                ),
                                const SizedBox(height: 2),
                                AppText(
                                  '${record.employeeId} - ${record.department}',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textColorSecondary,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── 3. Receipt-Style Breakdown Card ──
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.slate200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: AppText(
                              'Payslip for ${record.salaryMonth}',
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textColorSecondary,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14.0),
                            child: Divider(color: AppColors.slate200, height: 1, thickness: 1),
                          ),
                          
                          // Earnings Details List
                          _buildMiniSectionTitle('EARNINGS', AppColors.successColor),
                          const SizedBox(height: 6),
                          _buildReceiptItem('Basic Salary', record.basicSalary),
                          _buildReceiptItem('House Rent Allowance (HRA)', record.hra),
                          _buildReceiptItem('Conveyance Allowance', record.conveyance),
                          _buildReceiptItem('Special Allowance', record.specialAllowance),
                          _buildReceiptItem('Incentive', record.incentive),
                          _buildReceiptItem('Bonus', record.bonus),
                          _buildReceiptItem('Overtime Amount', record.overtimeAmount),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Divider(color: AppColors.slate100),
                          ),
                          _buildReceiptTotal('Total Earnings', grossVal, AppColors.successColor),
                          
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14.0),
                            child: Divider(color: AppColors.slate200, height: 1),
                          ),

                          // Deductions Details List
                          _buildMiniSectionTitle('DEDUCTIONS', AppColors.errorColor),
                          const SizedBox(height: 6),
                          _buildReceiptItem('Leave Deduction', record.leaveDeduction),
                          _buildReceiptItem('Late Deduction', record.lateDeduction),
                          _buildReceiptItem('PF (12%)', record.pf),
                          _buildReceiptItem('ESI', record.esi),
                          _buildReceiptItem('Loan / Advance', record.loanAdvance),
                          _buildReceiptItem('Other Deduction', record.otherDeduction),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Divider(color: AppColors.slate100),
                          ),
                          _buildReceiptTotal('Total Deductions', deductVal, AppColors.errorColor),

                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Divider(color: AppColors.slate300, height: 1, thickness: 1.5),
                          ),

                          // Net Payable Big Capsule
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withValues(alpha: 0.04),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.12)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const AppText(
                                  'NET PAYABLE SALARY',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textColorPrimary,
                                  letterSpacing: 0.5,
                                ),
                                AppText(
                                  netVal,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primaryColor,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Symmetrical transaction logs
                          _buildTransactionLog('Payment Mode', record.paymentMode ?? 'Bank Transfer'),
                          const SizedBox(height: 10),
                          _buildTransactionLog('Payment Date', record.paymentDate ?? '31 May 2024'),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const AppText(
                                'Payment Status',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textColorSecondary,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.successColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const AppText(
                                  'Paid',
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.successColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ── Symmetrical Bottom Process Actions ──
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.slate200)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _triggerShare(controller),
                      icon: const Icon(Iconsax.share, size: 18),
                      label: const AppText('Share Payslip'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primaryColor, width: 1.5),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        foregroundColor: AppColors.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _triggerDownload(controller),
                      icon: const Icon(Iconsax.document_download, size: 18),
                      label: const AppText('Download Payslip'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildMiniSectionTitle(String title, Color color) {
    return AppText(
      title,
      fontSize: 11,
      fontWeight: FontWeight.bold,
      color: color,
      letterSpacing: 0.8,
    );
  }

  Widget _buildReceiptItem(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(
            label,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textColorSecondary,
          ),
          AppText(
            '₹${_formatSalary(value.toInt())}',
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.textColorPrimary,
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptTotal(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(
          label,
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: AppColors.textColorPrimary,
        ),
        AppText(
          value,
          fontSize: 14,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ],
    );
  }

  Widget _buildTransactionLog(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(
          label,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textColorSecondary,
        ),
        AppText(
          value,
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: AppColors.textColorPrimary,
        ),
      ],
    );
  }

  Widget _buildFallbackAvatar(String name) {
    return Container(
      color: AppColors.primaryColor.withValues(alpha: 0.1),
      child: Center(
        child: AppText(
          name.substring(0, 1).toUpperCase(),
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryColor,
        ),
      ),
    );
  }

  void _triggerDownload(PayrollController controller) {
    final record = controller.selectedRecord.value;
    if (record == null) return;
    Get.snackbar(
      'Download Started 📥',
      'Downloading Payslip_${record.employeeName.replaceAll(' ', '_')}_May_2024.pdf',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primaryColor,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      borderRadius: 16,
    );
  }

  void _triggerShare(PayrollController controller) {
    final record = controller.selectedRecord.value;
    if (record == null) return;
    Get.snackbar(
      'Sharing Payslip 📤',
      'Generating shared link for ${record.employeeName}\'s payslip.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.infoColor,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      borderRadius: 16,
    );
  }

  String _formatSalary(int amount) {
    if (amount < 1000) return amount.toString();
    final str = amount.toString();
    var result = '';
    var count = 0;
    for (var i = str.length - 1; i >= 0; i--) {
      result = str[i] + result;
      count++;
      if (count == 3 && i > 0) {
        result = ',$result';
        count = 0;
      } else if (count == 2 && i > 0 && result.contains(',')) {
        result = ',$result';
        count = 0;
      }
    }
    return result;
  }
}
