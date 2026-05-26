import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/payroll_controller.dart';

class SalaryBreakdownScreen extends StatelessWidget {
  const SalaryBreakdownScreen({super.key});

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
        title: const AppText(
          'Salary Breakdown',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textColorPrimary,
        ),
        centerTitle: false,
      ),
      body: Obx(() {
        final record = controller.selectedRecord.value;
        if (record == null) {
          return const Center(child: AppText('No employee selected.'));
        }

        final grossVal = "₹${_formatSalary(record.grossEarnings.toInt())}";
        final deductVal = "₹${_formatSalary(record.totalDeductions.toInt())}";
        final netVal = "₹${_formatSalary(record.netPayable.toInt())}";

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── EARNINGS SECTION CARD ──
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
                        const Icon(Iconsax.wallet_3, color: AppColors.successColor, size: 20),
                        const SizedBox(width: 8),
                        const AppText(
                          'EARNINGS',
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.successColor,
                          letterSpacing: 0.8,
                        ),
                        const Spacer(),
                        AppText(
                          grossVal,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppColors.successColor,
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Divider(color: AppColors.slate100, height: 1),
                    ),
                    _buildBreakdownRow('Basic Salary', record.basicSalary),
                    _buildBreakdownRow('House Rent Allowance (HRA)', record.hra),
                    _buildBreakdownRow('Conveyance Allowance', record.conveyance),
                    _buildBreakdownRow('Special Allowance', record.specialAllowance),
                    _buildBreakdownRow('Incentive', record.incentive),
                    _buildBreakdownRow('Bonus', record.bonus),
                    _buildBreakdownRow('Overtime Amount', record.overtimeAmount),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── DEDUCTIONS SECTION CARD ──
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
                        const Icon(Iconsax.card_remove, color: AppColors.errorColor, size: 20),
                        const SizedBox(width: 8),
                        const AppText(
                          'DEDUCTIONS',
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.errorColor,
                          letterSpacing: 0.8,
                        ),
                        const Spacer(),
                        AppText(
                          deductVal,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppColors.errorColor,
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Divider(color: AppColors.slate100, height: 1),
                    ),
                    _buildBreakdownRow('Leave Deduction', record.leaveDeduction),
                    _buildBreakdownRow('Late Deduction', record.lateDeduction),
                    _buildBreakdownRow('PF (12%)', record.pf),
                    _buildBreakdownRow('ESI', record.esi),
                    _buildBreakdownRow('Loan / Advance', record.loanAdvance),
                    _buildBreakdownRow('Other Deduction', record.otherDeduction),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── CALCULATION SUMMARY CARD ──
              _buildSectionTitle('CALCULATION SUMMARY'),
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
                    _buildSummaryMathRow('Gross Earnings (A)', grossVal, isBold: false),
                    const SizedBox(height: 10),
                    _buildSummaryMathRow('Total Deductions (B)', '- $deductVal', isBold: false, isNegative: true),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14.0),
                      child: Divider(color: AppColors.slate200, height: 1, thickness: 1),
                    ),
                    _buildSummaryMathRow('Net Payable (A - B)', netVal, isBold: true, isPrimary: true),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
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

  Widget _buildBreakdownRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(
            label,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textColorSecondary,
          ),
          AppText(
            '₹${_formatSalary(value.toInt())}',
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.textColorPrimary,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryMathRow(String label, String value, {required bool isBold, bool isNegative = false, bool isPrimary = false}) {
    Color valColor = AppColors.textColorPrimary;
    if (isNegative) valColor = AppColors.errorColor;
    if (isPrimary) valColor = AppColors.primaryColor;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(
          label,
          fontSize: isBold ? 14 : 13,
          fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          color: AppColors.textColorPrimary,
        ),
        AppText(
          value,
          fontSize: isBold ? 16 : 14,
          fontWeight: FontWeight.w900,
          color: valColor,
        ),
      ],
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
