import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/salary_history_controller.dart';
import '../models/salary_history_model.dart';
import '../repositories/payroll_repository.dart';
import '../repositories/payroll_repository_interface.dart';

class EmployeeMySalaryScreen extends StatelessWidget {
  const EmployeeMySalaryScreen({super.key});

  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static final _currencyFormatCompact = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<SalaryHistoryController>()
        ? Get.find<SalaryHistoryController>()
        : Get.put(SalaryHistoryController(
            repository: Get.isRegistered<PayrollRepositoryInterface>()
                ? Get.find<PayrollRepositoryInterface>()
                : PayrollRepository(
                    apiClient: Get.isRegistered<ApiClient>()
                        ? Get.find<ApiClient>()
                        : Get.put(ApiClient(), permanent: true),
                  ),
          ));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textColorPrimary, size: 18),
          onPressed: () => Get.back(),
        ),
        title: const AppText(
          'My Salary History',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textColorPrimary,
        ),
        centerTitle: false,
        actions: [
          Obx(() {
            return Padding(
              padding: const EdgeInsets.only(right: 14),
              child: InkWell(
                onTap: () => _showYearPickerBottomSheet(context, controller),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Iconsax.calendar_1, size: 14, color: AppColors.primaryColor),
                      const SizedBox(width: 6),
                      AppText(
                        '${controller.selectedYear.value}',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryColor,
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: AppColors.primaryColor),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value && controller.salaryHistoryData.value == null) {
            return _buildLoadingState();
          }

          if (controller.errorMessage.value.isNotEmpty && controller.salaryHistoryData.value == null) {
            return _buildErrorState(controller);
          }

          return RefreshIndicator(
            onRefresh: () => controller.fetchSalaryHistory(),
            color: AppColors.primaryColor,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current CTC Card
                  _buildCurrentCtcCard(controller),
                  const SizedBox(height: 24),

                  // Recent Payslips Section Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const AppText(
                            'Recent Payslips',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textColorPrimary,
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.slate200,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: AppText(
                              '${controller.recentPayslips.length}',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textColorSecondary,
                            ),
                          ),
                        ],
                      ),
                      if (controller.isLoading.value)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Payslips List or Empty State
                  if (controller.recentPayslips.isEmpty)
                    _buildEmptyPayslipsState(controller)
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.recentPayslips.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final payslip = controller.recentPayslips[index];
                        return _SalaryHistoryCard(
                          payslip: payslip,
                          controller: controller,
                        );
                      },
                    ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }


  Widget _buildCurrentCtcCard(SalaryHistoryController controller) {
    final ctc = controller.currentMonthlyCtc;
    final breakdown = controller.currentCtcBreakdown;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF2563EB), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AppText(
                'Current Monthly CTC',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.white70,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Iconsax.verify, color: Colors.white, size: 13),
                    const SizedBox(width: 4),
                    AppText(
                      '${controller.selectedYear.value}',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          AppText(
            _currencyFormat.format(ctc),
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCtcDetail('Basic', _currencyFormatCompact.format(breakdown?.basic ?? 0)),
                Container(width: 1, height: 28, color: Colors.white24),
                _buildCtcDetail('HRA', _currencyFormatCompact.format(breakdown?.hra ?? 0)),
                Container(width: 1, height: 28, color: Colors.white24),
                _buildCtcDetail('Allowances', _currencyFormatCompact.format(breakdown?.allowances ?? 0)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCtcDetail(String label, String amount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AppText(
          label,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Colors.white70,
        ),
        const SizedBox(height: 3),
        AppText(
          amount,
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ],
    );
  }

  Widget _buildEmptyPayslipsState(SalaryHistoryController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.slate100,
              shape: BoxShape.circle,
            ),
            child: const Icon(Iconsax.receipt_item, size: 36, color: AppColors.textColorHint),
          ),
          const SizedBox(height: 14),
          AppText(
            'No Payslips in ${controller.selectedYear.value}',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textColorPrimary,
          ),
          const SizedBox(height: 6),
          const AppText(
            'No salary history records were generated for this year.',
            fontSize: 13,
            color: AppColors.textColorSecondary,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primaryColor),
          SizedBox(height: 16),
          AppText(
            'Loading salary history...',
            fontSize: 14,
            color: AppColors.textColorSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(SalaryHistoryController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.errorColor, size: 48),
            const SizedBox(height: 16),
            AppText(
              controller.errorMessage.value,
              fontSize: 14,
              color: AppColors.textColorPrimary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => controller.fetchSalaryHistory(),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showYearPickerBottomSheet(BuildContext context, SalaryHistoryController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.slate300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Icon(Iconsax.calendar_search, size: 20, color: AppColors.primaryColor),
                    SizedBox(width: 8),
                    AppText(
                      'Select Financial Year',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Divider(color: AppColors.slate100, height: 1),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.availableYears.length,
                itemBuilder: (context, index) {
                  final year = controller.availableYears[index];
                  final isSelected = controller.selectedYear.value == year;
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
                    title: AppText(
                      '$year',
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? AppColors.primaryColor : AppColors.textColorPrimary,
                    ),
                    trailing: isSelected
                        ? const Icon(Iconsax.tick_circle, color: AppColors.primaryColor, size: 20)
                        : null,
                    onTap: () {
                      controller.changeYear(year);
                      Get.back();
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SalaryHistoryCard extends StatelessWidget {
  final RecentPayslipModel payslip;
  final SalaryHistoryController controller;

  const _SalaryHistoryCard({
    required this.payslip,
    required this.controller,
  });

  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context) {
    final isPaid = payslip.status.toLowerCase() == 'paid';
    final statusColor = isPaid ? AppColors.successColor : AppColors.warningColor;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.slate200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Month & Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Iconsax.receipt_2_1, size: 18, color: AppColors.primaryColor),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        payslip.monthLabel.isNotEmpty ? payslip.monthLabel : payslip.salaryMonth,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textColorPrimary,
                      ),
                      if (payslip.salaryMonth.isNotEmpty)
                        AppText(
                          'Month Code: ${payslip.salaryMonth}',
                          fontSize: 11,
                          color: AppColors.textColorHint,
                        ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: AppText(
                  payslip.status,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: statusColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(color: AppColors.slate100, height: 1),
          const SizedBox(height: 14),

          // Net Payable & Deductions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppText(
                    'Net Payable',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textColorSecondary,
                  ),
                  const SizedBox(height: 4),
                  AppText(
                    _currencyFormat.format(payslip.netPayable),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryColor,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const AppText(
                    'Gross Earnings',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textColorSecondary,
                  ),
                  const SizedBox(height: 4),
                  AppText(
                    _currencyFormat.format(payslip.grossEarnings),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textColorPrimary,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.remove_circle_outline_rounded, size: 13, color: AppColors.errorColor),
                  const SizedBox(width: 4),
                  const AppText(
                    'Total Deductions: ',
                    fontSize: 11,
                    color: AppColors.textColorSecondary,
                  ),
                  AppText(
                    _currencyFormat.format(payslip.totalDeductions),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: payslip.totalDeductions > 0 ? AppColors.errorColor : AppColors.successColor,
                  ),
                ],
              ),
              if (payslip.paymentDate != null && payslip.paymentDate!.isNotEmpty)
                Row(
                  children: [
                    const Icon(Iconsax.calendar_1, size: 12, color: AppColors.textColorHint),
                    const SizedBox(width: 4),
                    AppText(
                      'Paid on ${payslip.paymentDate}',
                      fontSize: 11,
                      color: AppColors.textColorSecondary,
                    ),
                  ],
                ),
            ],
          ),

          // Attendance Summary Chips Preview
          if (payslip.attendanceSummary.totalWorkingDays > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.slate100.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMiniStat('Working', '${payslip.attendanceSummary.totalWorkingDays}d'),
                  _buildMiniStat('Present', '${payslip.attendanceSummary.presentDays}d'),
                  _buildMiniStat('Absent', '${payslip.attendanceSummary.absentDays}d'),
                  _buildMiniStat('Half Day', '${payslip.attendanceSummary.halfDays}d'),
                  if (payslip.attendanceSummary.paidLeaves > 0)
                    _buildMiniStat('Leaves', '${payslip.attendanceSummary.paidLeaves}d'),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),
          const Divider(color: AppColors.slate100, height: 1),
          const SizedBox(height: 10),

          // Actions: View Breakdown & Download Payslip
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () => _showPayslipBreakdownBottomSheet(context, payslip),
                icon: const Icon(Iconsax.eye, size: 14),
                label: const Text('Breakdown'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryColor,
                  side: const BorderSide(color: AppColors.primaryColor),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => controller.openPayslip(payslip),
                icon: const Icon(Iconsax.document_download, size: 14),
                label: const Text('Download Payslip'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      children: [
        AppText(label, fontSize: 10, color: AppColors.textColorHint),
        const SizedBox(height: 2),
        AppText(value, fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textColorPrimary),
      ],
    );
  }

  void _showPayslipBreakdownBottomSheet(BuildContext context, RecentPayslipModel item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppColors.slate300, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 14),

              // Title Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Iconsax.receipt_2_1, color: AppColors.primaryColor, size: 20),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              item.monthLabel.isNotEmpty ? item.monthLabel : item.salaryMonth,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                            const AppText(
                              'Salary & Attendance Breakdown',
                              fontSize: 11,
                              color: AppColors.textColorHint,
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textColorSecondary, size: 20),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
              ),

              const Divider(color: AppColors.slate100, height: 1),

              // Breakdown Body
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Net Pay Highlight Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const AppText(
                                  'Net Payable Amount',
                                  fontSize: 12,
                                  color: AppColors.textColorSecondary,
                                ),
                                const SizedBox(height: 4),
                                AppText(
                                  _currencyFormat.format(item.netPayable),
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryColor,
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: item.status.toLowerCase() == 'paid'
                                    ? AppColors.successColor
                                    : AppColors.warningColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: AppText(
                                item.status,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Attendance Summary
                      const AppText('Attendance Summary', fontSize: 14, fontWeight: FontWeight.w700),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.slate50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.slate200),
                        ),
                        child: Column(
                          children: [
                            _buildInfoRow('Total Working Days', '${item.attendanceSummary.totalWorkingDays} days'),
                            _buildInfoRow('Present Days', '${item.attendanceSummary.presentDays} days'),
                            _buildInfoRow('Absent Days', '${item.attendanceSummary.absentDays} days'),
                            _buildInfoRow('Half Days', '${item.attendanceSummary.halfDays} days'),
                            _buildInfoRow('Paid Leaves', '${item.attendanceSummary.paidLeaves} days'),
                            _buildInfoRow('Unpaid Leaves', '${item.attendanceSummary.unpaidLeaves} days'),
                            _buildInfoRow('Late Coming Days', '${item.attendanceSummary.lateComingDays} days'),
                            if (item.attendanceSummary.overtimeHours > 0)
                              _buildInfoRow('Overtime', '${item.attendanceSummary.overtimeHours} hours'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Earnings
                      const AppText('Earnings Breakdown', fontSize: 14, fontWeight: FontWeight.w700),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.slate50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.slate200),
                        ),
                        child: Column(
                          children: [
                            ...item.earnings.map(
                              (e) => _buildInfoRow(e.name, _currencyFormat.format(e.amount)),
                            ),
                            const Divider(color: AppColors.slate200),
                            _buildInfoRow(
                              'Gross Earnings',
                              _currencyFormat.format(item.grossEarnings),
                              isBold: true,
                              valueColor: AppColors.textColorPrimary,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Deductions
                      const AppText('Deductions Breakdown', fontSize: 14, fontWeight: FontWeight.w700),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.slate50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.slate200),
                        ),
                        child: Column(
                          children: [
                            if (item.deductions.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 6),
                                child: AppText(
                                  'No deductions applied for this month',
                                  fontSize: 12,
                                  color: AppColors.textColorSecondary,
                                ),
                              )
                            else
                              ...item.deductions.map(
                                (d) => _buildInfoRow(d.name, _currencyFormat.format(d.amount), valueColor: AppColors.errorColor),
                              ),
                            const Divider(color: AppColors.slate200),
                            _buildInfoRow(
                              'Total Deductions',
                              _currencyFormat.format(item.totalDeductions),
                              isBold: true,
                              valueColor: item.totalDeductions > 0 ? AppColors.errorColor : AppColors.successColor,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Payment & Bank Details
                      const AppText('Payment & Bank Details', fontSize: 14, fontWeight: FontWeight.w700),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.slate50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.slate200),
                        ),
                        child: Column(
                          children: [
                            if (item.paymentDate != null) _buildInfoRow('Payment Date', item.paymentDate!),
                            if (item.paymentMode != null) _buildInfoRow('Payment Mode', item.paymentMode!),
                            if (item.bankName != null) _buildInfoRow('Bank Name', item.bankName!),
                            if (item.accountUpiAddress != null) _buildInfoRow('Account / UPI', item.accountUpiAddress!),
                            if (item.remarks != null && item.remarks!.isNotEmpty) _buildInfoRow('Remarks', item.remarks!),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Download Button in Bottom Sheet
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Get.back();
                            controller.openPayslip(item);
                          },
                          icon: const Icon(Iconsax.document_download, size: 18),
                          label: const Text('Download Payslip PDF'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(
            label,
            fontSize: 12,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: isBold ? AppColors.textColorPrimary : AppColors.textColorSecondary,
          ),
          AppText(
            value,
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            color: valueColor ?? AppColors.textColorPrimary,
          ),
        ],
      ),
    );
  }
}
