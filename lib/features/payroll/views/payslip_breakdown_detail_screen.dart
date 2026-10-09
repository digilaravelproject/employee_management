import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/salary_history_controller.dart';
import '../models/salary_history_model.dart';

class PayslipBreakdownDetailScreen extends StatelessWidget {
  final RecentPayslipModel payslip;

  const PayslipBreakdownDetailScreen({
    super.key,
    required this.payslip,
  });

  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<SalaryHistoryController>()
        ? Get.find<SalaryHistoryController>()
        : Get.put(SalaryHistoryController(repository: Get.find()));

    final isPaid = payslip.status.toLowerCase() == 'paid';
    final monthTitle = payslip.monthLabel.isNotEmpty ? payslip.monthLabel : payslip.salaryMonth;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.slate100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textColorPrimary, size: 18),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              monthTitle,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textColorPrimary,
            ),
            const AppText(
              'Salary & Attendance Breakdown',
              fontSize: 11,
              color: AppColors.textColorHint,
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Download PDF',
            icon: const Icon(Iconsax.document_download, color: AppColors.primaryColor),
            onPressed: () => controller.openPayslip(payslip),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 1. NET PAY HERO CARD ──
              _buildNetPayHeroCard(isPaid),
              const SizedBox(height: 20),

              // ── 2. ATTENDANCE SUMMARY SECTION ──
              _buildSectionTitle(
                icon: Iconsax.calendar_tick,
                iconColor: const Color(0xFF0EA5E9),
                title: 'Attendance Summary',
                subtitle: 'Working days and leaves calculation',
              ),
              const SizedBox(height: 10),
              _buildAttendanceGrid(),
              const SizedBox(height: 20),

              // ── 3. EARNINGS BREAKDOWN ──
              _buildSectionTitle(
                icon: Iconsax.wallet_add,
                iconColor: AppColors.successColor,
                title: 'Earnings Breakdown',
                subtitle: 'Basic salary & added allowances',
              ),
              const SizedBox(height: 10),
              _buildEarningsCard(),
              const SizedBox(height: 20),

              // ── 4. DEDUCTIONS BREAKDOWN ──
              _buildSectionTitle(
                icon: Iconsax.wallet_remove,
                iconColor: AppColors.errorColor,
                title: 'Deductions Breakdown',
                subtitle: 'Taxes, PF & attendance deductions',
              ),
              const SizedBox(height: 10),
              _buildDeductionsCard(),
              const SizedBox(height: 20),

              // ── 5. PAYMENT & BANK DETAILS ──
              if (_hasPaymentInfo()) ...[
                _buildSectionTitle(
                  icon: Iconsax.card_send,
                  iconColor: const Color(0xFF8B5CF6),
                  title: 'Payment & Bank Details',
                  subtitle: 'Transaction mode & bank account info',
                ),
                const SizedBox(height: 10),
                _buildPaymentInfoCard(),
                const SizedBox(height: 24),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
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
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () => controller.openPayslip(payslip),
            icon: const Icon(Iconsax.document_download, size: 20),
            label: const Text(
              'Download Payslip (PDF)',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ),
    );
  }

  // ── HERO CARD ──
  Widget _buildNetPayHeroCard(bool isPaid) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor,
            AppColors.primaryColor.withValues(alpha: 0.85),
            const Color(0xFF1E1B4B),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.3),
            blurRadius: 16,
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Iconsax.receipt_2, color: Colors.white, size: 14),
                    const SizedBox(width: 6),
                    AppText(
                      payslip.monthLabel.isNotEmpty ? payslip.monthLabel : payslip.salaryMonth,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: isPaid ? const Color(0xFF22C55E) : const Color(0xFFF59E0B),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: (isPaid ? const Color(0xFF22C55E) : const Color(0xFFF59E0B)).withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: AppText(
                  payslip.status.toUpperCase(),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          AppText(
            'NET PAYABLE AMOUNT',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.white.withValues(alpha: 0.8),
            letterSpacing: 0.8,
          ),
          const SizedBox(height: 4),
          AppText(
            _currencyFormat.format(payslip.netPayable),
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        'Gross Earnings',
                        fontSize: 10,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                      const SizedBox(height: 2),
                      AppText(
                        _currencyFormat.format(payslip.grossEarnings),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF86EFAC),
                      ),
                    ],
                  ),
                ),
                Container(height: 24, width: 1, color: Colors.white.withValues(alpha: 0.2)),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          'Total Deductions',
                          fontSize: 10,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                        const SizedBox(height: 2),
                        AppText(
                          _currencyFormat.format(payslip.totalDeductions),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFFCA5A5),
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

  // ── SECTION TITLE HELPER ──
  Widget _buildSectionTitle({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              title,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textColorPrimary,
            ),
            AppText(
              subtitle,
              fontSize: 11,
              color: AppColors.textColorHint,
            ),
          ],
        ),
      ],
    );
  }

  // ── ATTENDANCE GRID ──
  Widget _buildAttendanceGrid() {
    final summary = payslip.attendanceSummary;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildAttendanceStatTile(
                  label: 'Working Days',
                  value: '${summary.totalWorkingDays}',
                  unit: 'Days',
                  icon: Iconsax.calendar,
                  color: const Color(0xFF3B82F6),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildAttendanceStatTile(
                  label: 'Present',
                  value: '${summary.presentDays}',
                  unit: 'Days',
                  icon: Iconsax.tick_circle,
                  color: const Color(0xFF10B981),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildAttendanceStatTile(
                  label: 'Absent',
                  value: '${summary.absentDays}',
                  unit: 'Days',
                  icon: Iconsax.close_circle,
                  color: const Color(0xFFEF4444),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildAttendanceStatTile(
                  label: 'Half Days',
                  value: '${summary.halfDays}',
                  unit: 'Days',
                  icon: Iconsax.timer_1,
                  color: const Color(0xFFF59E0B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildAttendanceStatTile(
                  label: 'Paid Leaves',
                  value: '${summary.paidLeaves}',
                  unit: 'Days',
                  icon: Iconsax.airplane,
                  color: const Color(0xFF8B5CF6),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildAttendanceStatTile(
                  label: 'Unpaid Leaves',
                  value: '${summary.unpaidLeaves}',
                  unit: 'Days',
                  icon: Iconsax.slash,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          if (summary.lateComingDays > 0 || summary.overtimeHours > 0) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                if (summary.lateComingDays > 0)
                  Expanded(
                    child: _buildAttendanceStatTile(
                      label: 'Late Days',
                      value: '${summary.lateComingDays}',
                      unit: 'Days',
                      icon: Iconsax.clock,
                      color: const Color(0xFFEC4899),
                    ),
                  ),
                if (summary.lateComingDays > 0 && summary.overtimeHours > 0)
                  const SizedBox(width: 10),
                if (summary.overtimeHours > 0)
                  Expanded(
                    child: _buildAttendanceStatTile(
                      label: 'Overtime',
                      value: '${summary.overtimeHours}',
                      unit: 'Hrs',
                      icon: Iconsax.flash,
                      color: const Color(0xFF06B6D4),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAttendanceStatTile({
    required String label,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(label, fontSize: 10, color: AppColors.textColorSecondary),
                const SizedBox(height: 2),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: value,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColorPrimary,
                        ),
                      ),
                      TextSpan(
                        text: ' $unit',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textColorHint,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── EARNINGS CARD ──
  Widget _buildEarningsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (payslip.earnings.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: AppText('No earnings data available', fontSize: 12, color: AppColors.textColorHint),
                  )
                else
                  ...payslip.earnings.map(
                    (e) => _buildDetailRow(
                      label: e.name,
                      value: _currencyFormat.format(e.amount),
                      valueColor: AppColors.textColorPrimary,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.successColor.withValues(alpha: 0.06),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
              border: Border(top: BorderSide(color: AppColors.successColor.withValues(alpha: 0.2))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const AppText(
                  'Gross Earnings',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColorPrimary,
                ),
                AppText(
                  _currencyFormat.format(payslip.grossEarnings),
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.successColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── DEDUCTIONS CARD ──
  Widget _buildDeductionsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (payslip.deductions.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: AppText('No deductions applied for this month 🎉', fontSize: 12, color: AppColors.textColorHint),
                  )
                else
                  ...payslip.deductions.map(
                    (d) => _buildDetailRow(
                      label: d.name,
                      value: '- ${_currencyFormat.format(d.amount)}',
                      valueColor: AppColors.errorColor,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.errorColor.withValues(alpha: 0.06),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
              border: Border(top: BorderSide(color: AppColors.errorColor.withValues(alpha: 0.2))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const AppText(
                  'Total Deductions',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColorPrimary,
                ),
                AppText(
                  _currencyFormat.format(payslip.totalDeductions),
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: payslip.totalDeductions > 0 ? AppColors.errorColor : AppColors.successColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── PAYMENT INFO CARD ──
  Widget _buildPaymentInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        children: [
          if (payslip.paymentDate != null && payslip.paymentDate!.isNotEmpty)
            _buildDetailRow(label: 'Payment Date', value: payslip.paymentDate!),
          if (payslip.paymentMode != null && payslip.paymentMode!.isNotEmpty)
            _buildDetailRow(label: 'Payment Mode', value: payslip.paymentMode!),
          if (payslip.bankName != null && payslip.bankName!.isNotEmpty)
            _buildDetailRow(label: 'Bank Name', value: payslip.bankName!),
          if (payslip.accountUpiAddress != null && payslip.accountUpiAddress!.isNotEmpty)
            _buildDetailRow(label: 'Account / UPI ID', value: payslip.accountUpiAddress!),
          if (payslip.remarks != null && payslip.remarks!.isNotEmpty)
            _buildDetailRow(label: 'Remarks', value: payslip.remarks!),
        ],
      ),
    );
  }

  bool _hasPaymentInfo() {
    return (payslip.paymentDate != null && payslip.paymentDate!.isNotEmpty) ||
        (payslip.paymentMode != null && payslip.paymentMode!.isNotEmpty) ||
        (payslip.bankName != null && payslip.bankName!.isNotEmpty) ||
        (payslip.accountUpiAddress != null && payslip.accountUpiAddress!.isNotEmpty) ||
        (payslip.remarks != null && payslip.remarks!.isNotEmpty);
  }

  // ── ROW BUILDER ──
  Widget _buildDetailRow({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(
            label,
            fontSize: 12.5,
            color: AppColors.textColorSecondary,
            fontWeight: FontWeight.w500,
          ),
          AppText(
            value,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: valueColor ?? AppColors.textColorPrimary,
          ),
        ],
      ),
    );
  }
}
