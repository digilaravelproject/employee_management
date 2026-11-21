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
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textColorPrimary,
        ),
        centerTitle: false,
      ),
      body: Obx(() {
        final record = controller.selectedRecord.value;
        final detail = controller.selectedSalaryDetail.value;
        if (record == null && detail == null) {
          return const Center(child: AppText('No employee selected.'));
        }

        final employeeName = detail?.employee.name ?? record?.employeeName ?? 'Employee';
        final designation = detail?.employee.designation ?? record?.designation ?? '—';
        final monthLabel = controller.selectedMonthLabel.value.isNotEmpty
            ? controller.selectedMonthLabel.value
            : (detail?.monthLabel.isNotEmpty == true ? detail!.monthLabel : (record?.salaryMonth ?? ''));

        final hasApiEarnings = detail != null && detail.earnings.isNotEmpty;
        final hasApiDeductions = detail != null && detail.deductions.isNotEmpty;

        final grossAmount = (detail?.grossEarnings ?? record?.grossEarnings ?? 0).toInt();
        final deductAmount = (detail?.totalDeductions ?? record?.totalDeductions ?? 0).toInt();
        final netAmount = (detail?.netPayable ?? record?.netPayable ?? 0).toInt();

        final grossVal = "₹${_formatSalary(grossAmount)}";
        final deductVal = "₹${_formatSalary(deductAmount)}";
        final netVal = "₹${_formatSalary(netAmount)}";

        final takeHomePercent = grossAmount > 0
            ? ((netAmount / grossAmount) * 100).clamp(0, 100).toStringAsFixed(1)
            : '100';

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── TOP EMPLOYEE & MONTH BADGE ──
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.slate200),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primaryLight,
                      child: Text(
                        employeeName.isNotEmpty ? employeeName[0].toUpperCase() : 'E',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            employeeName,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColorPrimary,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          AppText(
                            designation,
                            fontSize: 11,
                            color: AppColors.textColorSecondary,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Iconsax.calendar_1, size: 12, color: AppColors.primaryColor),
                          const SizedBox(width: 4),
                          AppText(
                            monthLabel,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── EARNINGS SECTION CARD (ADDITIONS) ──
              _buildSectionTitle('EARNINGS & ALLOWANCES'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.slate200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Iconsax.wallet_3, color: Color(0xFF16A34A), size: 16),
                          ),
                          const SizedBox(width: 10),
                          const AppText(
                            'Total Gross Earnings',
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColorPrimary,
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: AppText(
                              '+ $grossVal',
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF15803D),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(color: AppColors.slate100, height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(
                        children: [
                          if (hasApiEarnings)
                            ...detail.earnings.map(
                              (item) => _buildBreakdownRow(item.name, item.amount.toDouble(), isAddition: true),
                            )
                          else if (record != null) ...[
                            _buildBreakdownRow('Basic Salary', record.basicSalary, isAddition: true),
                            _buildBreakdownRow('House Rent Allowance (HRA)', record.hra, isAddition: true),
                            _buildBreakdownRow('Conveyance Allowance', record.conveyance, isAddition: true),
                            _buildBreakdownRow('Special Allowance', record.specialAllowance, isAddition: true),
                            if (record.incentive > 0) _buildBreakdownRow('Incentive', record.incentive, isAddition: true),
                            if (record.bonus > 0) _buildBreakdownRow('Bonus', record.bonus, isAddition: true),
                            if (record.overtimeAmount > 0) _buildBreakdownRow('Overtime Amount', record.overtimeAmount, isAddition: true),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // ── DEDUCTIONS SECTION CARD (SUBTRACTIONS) ──
              _buildSectionTitle('DEDUCTIONS & TAXES'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.slate200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Iconsax.card_remove, color: Color(0xFFDC2626), size: 16),
                          ),
                          const SizedBox(width: 10),
                          const AppText(
                            'Total Deductions',
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColorPrimary,
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: AppText(
                              '- $deductVal',
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFFB91C1C),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(color: AppColors.slate100, height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(
                        children: [
                          if (hasApiDeductions)
                            ...detail.deductions.map(
                              (item) => _buildBreakdownRow(item.name, item.amount.toDouble(), isDeduction: true),
                            )
                          else if (record != null) ...[
                            if (record.leaveDeduction > 0) _buildBreakdownRow('Leave Deduction', record.leaveDeduction, isDeduction: true),
                            if (record.lateDeduction > 0) _buildBreakdownRow('Late Coming Deduction', record.lateDeduction, isDeduction: true),
                            _buildBreakdownRow('Provident Fund (PF)', record.pf, isDeduction: true),
                            _buildBreakdownRow('Employee State Insurance (ESI)', record.esi, isDeduction: true),
                            if (record.loanAdvance > 0) _buildBreakdownRow('Loan / Advance Repayment', record.loanAdvance, isDeduction: true),
                            if (record.otherDeduction > 0) _buildBreakdownRow('Other Deductions / TDS', record.otherDeduction, isDeduction: true),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── E-COMMERCE BILL SUMMARY CARD ──
              _buildSectionTitle('BILL SUMMARY / NET SETTLEMENT'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.slate200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Iconsax.receipt_item, color: AppColors.primaryColor, size: 16),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              AppText(
                                'Payment Settlement',
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColorPrimary,
                              ),
                              SizedBox(height: 1),
                              AppText(
                                'Complete itemized payroll breakdown',
                                fontSize: 10.5,
                                color: AppColors.textColorHint,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(color: AppColors.slate100, height: 1),

                    // Bill Line Items
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                      child: Column(
                        children: [
                          _buildSummaryMathRow('Gross Salary (A)', grossVal, isAddition: true),
                          const SizedBox(height: 10),
                          _buildSummaryMathRow('Total Deductions (B)', '- $deductVal', isDeduction: true),
                        ],
                      ),
                    ),

                    // Dashed Divider Line (E-Commerce Receipt Style)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildDashedLine(),
                    ),
                    const SizedBox(height: 12),

                    // Highlighted Net Payable Banner
                    Container(
                      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF5F3FF), Color(0xFFEDE9FE)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFC4B5FD)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const AppText(
                                    'Net Take-Home Pay',
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textColorPrimary,
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: const [
                                      Icon(Icons.check_circle_rounded, size: 13, color: Color(0xFF16A34A)),
                                      SizedBox(width: 4),
                                      AppText(
                                        'Net Payable (A - B)',
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textColorSecondary,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              AppText(
                                netVal,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primaryColor,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Visual take-home progress bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: (double.tryParse(takeHomePercent) ?? 100) / 100,
                              minHeight: 6,
                              backgroundColor: const Color(0xFFFCA5A5),
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF16A34A)),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              AppText(
                                'Take-home: $takeHomePercent% of gross pay',
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF15803D),
                              ),
                              AppText(
                                'Deductions: ${(100 - (double.tryParse(takeHomePercent) ?? 100)).toStringAsFixed(1)}%',
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFB91C1C),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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

  Widget _buildBreakdownRow(String label, double value, {bool isAddition = false, bool isDeduction = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isDeduction ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              AppText(
                label,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: AppColors.textColorSecondary,
              ),
            ],
          ),
          AppText(
            isDeduction
                ? '- ₹${_formatSalary(value.toInt())}'
                : '₹${_formatSalary(value.toInt())}',
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isDeduction ? const Color(0xFFDC2626) : AppColors.textColorPrimary,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryMathRow(String label, String value, {bool isAddition = false, bool isDeduction = false}) {
    Color valColor = AppColors.textColorPrimary;
    if (isAddition) valColor = const Color(0xFF16A34A);
    if (isDeduction) valColor = const Color(0xFFDC2626);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(
          label,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textColorPrimary,
        ),
        AppText(
          value,
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: valColor,
        ),
      ],
    );
  }

  Widget _buildDashedLine() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 5.0;
        const dashHeight = 1.0;
        const dashSpace = 4.0;
        final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
        return SizedBox(
          width: boxWidth,
          height: dashHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(dashCount, (_) {
              return const SizedBox(
                width: dashWidth,
                height: dashHeight,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: AppColors.slate300),
                ),
              );
            }),
          ),
        );
      },
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
