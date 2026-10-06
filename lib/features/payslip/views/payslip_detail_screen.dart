import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../payroll/models/salary_history_model.dart';

class PayslipDetailScreen extends StatelessWidget {
  final dynamic record; // Accepting RecentPayslipModel or legacy mock record

  const PayslipDetailScreen({super.key, this.record});

  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹ ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final isLiveModel = record is RecentPayslipModel;
    final RecentPayslipModel? liveRecord = isLiveModel ? (record as RecentPayslipModel) : null;

    final String displayMonth = isLiveModel
        ? (liveRecord!.monthLabel.isNotEmpty ? liveRecord.monthLabel : liveRecord.salaryMonth)
        : (record?.month ?? 'May 2025');

    final String displayDate = isLiveModel
        ? (liveRecord!.paymentDate != null && liveRecord.paymentDate!.isNotEmpty
            ? 'Paid on ${liveRecord.paymentDate}'
            : 'Status: ${liveRecord.status}')
        : (record?.date ?? 'Paid on 31 May 2025');

    final String displayEarnings = isLiveModel
        ? _currencyFormat.format(liveRecord!.grossEarnings)
        : (record?.earnings ?? '₹ 55,000');

    final String displayDeductions = isLiveModel
        ? _currencyFormat.format(liveRecord!.totalDeductions)
        : (record?.deductions ?? '₹ 10,500');

    final String displayNetPay = isLiveModel
        ? _currencyFormat.format(liveRecord!.netPayable)
        : (record?.netPay ?? '₹ 44,500');

    final String displayDays = isLiveModel
        ? '${liveRecord!.attendanceSummary.totalWorkingDays}'
        : '31';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textColorPrimary),
          onPressed: () => Get.back(),
        ),
        title: const AppText('Payslip', fontSize: 18, fontWeight: FontWeight.bold),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.import, color: AppColors.textColorPrimary),
            tooltip: 'Download Payslip',
            onPressed: () => _handleDownload(context, displayMonth, liveRecord?.payslipUrl),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          // Company Card
          _buildCompanyCard(displayMonth, displayDate, liveRecord?.status ?? 'Paid'),
          const SizedBox(height: 16),

          // Employee Info Card
          _buildEmployeeCard(liveRecord),
          const SizedBox(height: 16),

          // Core Stats Row (4 stats columns)
          _buildCoreStatsRow(displayEarnings, displayDeductions, displayNetPay, displayDays),
          const SizedBox(height: 20),

          // Earnings Breakdown
          _buildEarningsCard(liveRecord, displayEarnings),
          const SizedBox(height: 16),

          // Deductions Breakdown
          _buildDeductionsCard(liveRecord, displayDeductions),
          const SizedBox(height: 16),

          // Net Pay Banner
          _buildNetPayBanner(displayNetPay),
          const SizedBox(height: 24),

          // Footnote & Signature
          _buildFooterSection(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Future<void> _handleDownload(BuildContext context, String month, String? payslipUrl) async {
    if (payslipUrl != null && payslipUrl.trim().isNotEmpty) {
      try {
        final uri = Uri.parse(payslipUrl.trim());
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return;
        }
      } catch (_) {}
    }

    Get.snackbar(
      'Download Payslip',
      'Downloading payslip PDF for $month...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primaryColor,
      colorText: Colors.white,
    );
  }

  Widget _buildCompanyCard(String month, String date, String status) {
    final isPaid = status.toLowerCase() == 'paid';
    final statusColor = isPaid ? Colors.green : Colors.orange;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEBFF)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFEEEBFF), width: 1.5),
            ),
            child: const Icon(Iconsax.teacher, size: 24, color: AppColors.primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppText('ABC Technologies Pvt. Ltd.', fontSize: 15, fontWeight: FontWeight.bold),
                const SizedBox(height: 4),
                AppText('Payslip for $month', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primaryColor),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: AppText(status, fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AppText(date, fontSize: 11, color: AppColors.textColorSecondary, maxLines: 1),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeCard(RecentPayslipModel? liveRecord) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryLight,
              border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.2)),
            ),
            child: const Icon(Icons.person, size: 28, color: AppColors.primaryColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppText('Employee Payslip Record', fontSize: 14, fontWeight: FontWeight.bold),
                const SizedBox(height: 4),
                if (liveRecord?.paymentMode != null)
                  AppText('Mode: ${liveRecord!.paymentMode}', fontSize: 11, color: AppColors.textColorSecondary),
                if (liveRecord?.bankName != null)
                  AppText('Bank: ${liveRecord!.bankName}', fontSize: 11, color: AppColors.textColorSecondary),
                if (liveRecord?.accountUpiAddress != null)
                  AppText('Account: ${liveRecord!.accountUpiAddress}', fontSize: 11, color: AppColors.textColorHint),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoreStatsRow(String earnings, String deductions, String netPay, String days) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(Iconsax.briefcase, 'Total Earnings', earnings, Colors.green),
          _buildDivider(),
          _buildStatItem(Iconsax.minus_cirlce, 'Total Deductions', deductions, Colors.red),
          _buildDivider(),
          _buildStatItem(Iconsax.wallet, 'Net Pay', netPay, AppColors.primaryColor),
          _buildDivider(),
          _buildStatItem(Iconsax.calendar, 'Total Days', days, AppColors.primaryColor),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(height: 8),
        AppText(label, fontSize: 9.5, color: AppColors.textColorSecondary, fontWeight: FontWeight.w500),
        const SizedBox(height: 4),
        AppText(value, fontSize: 12, fontWeight: FontWeight.bold),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 35,
      width: 1,
      color: AppColors.borderColor,
    );
  }

  Widget _buildEarningsCard(RecentPayslipModel? liveRecord, String totalEarnings) {
    final hasLiveEarnings = liveRecord != null && liveRecord.earnings.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AppText('Earnings', fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
              AppText(totalEarnings, fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.borderColor, height: 1),
          const SizedBox(height: 12),
          if (hasLiveEarnings)
            ...liveRecord.earnings.map(
              (e) => _buildDetailRow(e.name, _currencyFormat.format(e.amount)),
            )
          else ...[
            _buildDetailRow('Basic Salary', '₹ 25,000'),
            _buildDetailRow('House Rent Allowance (HRA)', '₹ 10,000'),
            _buildDetailRow('Transport Allowance', '₹ 2,000'),
            _buildDetailRow('Special Allowance', '₹ 5,000'),
          ],
        ],
      ),
    );
  }

  Widget _buildDeductionsCard(RecentPayslipModel? liveRecord, String totalDeductions) {
    final hasLiveDeductions = liveRecord != null && liveRecord.deductions.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AppText('Deductions', fontSize: 13, fontWeight: FontWeight.bold, color: Colors.red),
              AppText(totalDeductions, fontSize: 13, fontWeight: FontWeight.bold, color: Colors.red),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.borderColor, height: 1),
          const SizedBox(height: 12),
          if (hasLiveDeductions)
            ...liveRecord.deductions.map(
              (d) => _buildDetailRow(d.name, _currencyFormat.format(d.amount)),
            )
          else if (liveRecord != null && liveRecord.deductions.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: AppText(
                'No deductions for this period',
                fontSize: 12,
                color: AppColors.textColorSecondary,
              ),
            )
          else ...[
            _buildDetailRow('Provident Fund (PF)', '₹ 2,500'),
            _buildDetailRow('Professional Tax', '₹ 200'),
            _buildDetailRow('Leaves / LWP', '₹ 2,500'),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(label, fontSize: 11.5, color: AppColors.textColorSecondary, fontWeight: FontWeight.w500),
          AppText(value, fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
        ],
      ),
    );
  }

  Widget _buildNetPayBanner(String netPay) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F0FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE9E3FF)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const AppText('Net Pay', fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
          AppText(netPay, fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primaryColor),
        ],
      ),
    );
  }

  Widget _buildFooterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Expanded(
              child: AppText(
                'This is a system generated payslip.',
                fontSize: 10.5,
                color: AppColors.textColorSecondary,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomPaint(
                  size: const Size(80, 25),
                  painter: _SignaturePainter(),
                ),
                const SizedBox(height: 4),
                Container(width: 90, height: 1, color: AppColors.slate300),
                const SizedBox(height: 6),
                const AppText(
                  'Authorized Signatory',
                  fontSize: 9.5,
                  color: AppColors.textColorSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _SignaturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path()
      ..moveTo(5, size.height * 0.8)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.2, size.width * 0.4, size.height * 0.6)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.9, size.width * 0.6, size.height * 0.4)
      ..quadraticBezierTo(size.width * 0.7, size.height * 0.1, size.width * 0.8, size.height * 0.5)
      ..lineTo(size.width * 0.95, size.height * 0.4);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
