import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/payroll_controller.dart';
import 'salary_breakdown_screen.dart';
import 'create_salary_form_screen.dart';
import 'payslip_created_screen.dart';

class SalaryOverviewScreen extends StatelessWidget {
  const SalaryOverviewScreen({super.key});

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
              onPressed: () => Get.back(),
            ),
          ),
        ),
        title: Obx(() {
          final record = controller.selectedRecord.value;
          return AppText(
            record != null ? record.employeeName : 'Overview',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textColorPrimary,
          );
        }),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: AppColors.textColorPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: Obx(() {
        final record = controller.selectedRecord.value;
        if (record == null) {
          return const Center(child: AppText('No employee selected.'));
        }

        final isCreated = record.status == 'Created';
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
                    // ── Employee Header Banner Card ──
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.slate200),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.slate100, width: 2),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: record.profilePic != null
                                  ? Image.network(record.profilePic!, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => _buildFallbackAvatar(record.employeeName))
                                  : _buildFallbackAvatar(record.employeeName),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(
                                  record.employeeName,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textColorPrimary,
                                ),
                                const SizedBox(height: 4),
                                AppText(
                                  record.designation,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textColorSecondary,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Iconsax.calendar_1, color: AppColors.textColorHint, size: 12),
                                    const SizedBox(width: 4),
                                    AppText(
                                      'Joining: 15 Jan 2022',
                                      fontSize: 11,
                                      color: AppColors.textColorSecondary,
                                    ),
                                    const SizedBox(width: 10),
                                    const Icon(Iconsax.card, color: AppColors.textColorHint, size: 12),
                                    const SizedBox(width: 4),
                                    const AppText(
                                      'Mode: Monthly',
                                      fontSize: 11,
                                      color: AppColors.textColorSecondary,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Symmetrical Month Header ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AppText(
                          record.salaryMonth,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textColorPrimary,
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.slate200),
                          ),
                          child: const Icon(Iconsax.calendar_1, color: AppColors.textColorSecondary, size: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ── Symmetrical Attendance Grid Overview Card ──
                    _buildSectionTitle('OVERVIEW'),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.slate200),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              _buildGridCell('Total Working Days', '${record.totalWorkingDays}', AppColors.slate600),
                              _buildGridCell('Present Days', '${record.presentDays}', AppColors.successColor),
                              _buildGridCell('Absent Days', '${record.absentDays}', AppColors.errorColor),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                            child: Divider(color: AppColors.slate100),
                          ),
                          Row(
                            children: [
                              _buildGridCell('Paid Leaves', '${record.paidLeaves}', AppColors.infoColor),
                              _buildGridCell('Unpaid Leaves', '${record.unpaidLeaves}', AppColors.warningColor),
                              _buildGridCell('Half Days', '${record.halfDays}', AppColors.slate500),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                            child: Divider(color: AppColors.slate100),
                          ),
                          Row(
                            children: [
                              _buildGridCell('Late Coming (Days)', '${record.lateComingDays}', AppColors.errorColor),
                              _buildGridCell('Overtime (Hrs)', '${record.overtimeHours}', AppColors.successColor),
                              const Expanded(child: SizedBox()),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Summary Financial Metrics Cards ──
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.slate200),
                      ),
                      child: Column(
                        children: [
                          _buildSummaryRow(
                            icon: Iconsax.wallet_3,
                            iconColor: AppColors.successColor,
                            title: 'Total Earnings',
                            value: grossVal,
                            textColor: AppColors.successColor,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                            child: Divider(color: AppColors.slate100),
                          ),
                          _buildSummaryRow(
                            icon: Iconsax.card_remove,
                            iconColor: AppColors.errorColor,
                            title: 'Total Deductions',
                            value: deductVal,
                            textColor: AppColors.errorColor,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                            child: Divider(color: AppColors.slate100),
                          ),
                          _buildSummaryRow(
                            icon: Iconsax.money_3,
                            iconColor: AppColors.primaryColor,
                            title: 'Net Payable Salary',
                            value: netVal,
                            textColor: AppColors.primaryColor,
                            isBold: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── View Salary Breakdown Link ──
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Get.to(() => const SalaryBreakdownScreen()),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primaryColor, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const AppText(
                          'View Salary Breakdown',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // ── Symmetrical Bottom Process Button ──
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.slate200)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (isCreated) {
                      Get.to(() => const PayslipCreatedScreen());
                    } else {
                      controller.initializePaymentForm(record);
                      Get.to(() => const CreateSalaryFormScreen());
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: AppText(
                    isCreated ? 'View Processed Payslip' : 'Proceed to Create Salary',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSectionTitle(String title) {
    return AppText(
      title,
      fontSize: 11,
      fontWeight: FontWeight.bold,
      color: AppColors.textColorHint,
      letterSpacing: 0.8,
    );
  }

  Widget _buildGridCell(String title, String value, Color valueColor) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppText(
            title,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.textColorSecondary,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          AppText(
            value,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: valueColor,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required Color textColor,
    bool isBold = false,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 14),
        AppText(
          title,
          fontSize: 14,
          fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          color: AppColors.textColorPrimary,
        ),
        const Spacer(),
        AppText(
          value,
          fontSize: isBold ? 16 : 14,
          fontWeight: FontWeight.w900,
          color: textColor,
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
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryColor,
        ),
      ),
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
