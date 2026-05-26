import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';

class PayslipDetailScreen extends StatelessWidget {
  final dynamic record; // Accepting the record from history to dynamicize month/date/earnings

  const PayslipDetailScreen({super.key, this.record});

  @override
  Widget build(BuildContext context) {
    // If no record is passed (e.g. direct link), fallback to mock data
    final String displayMonth = record?.month ?? 'May 2025';
    final String displayDate = record?.date ?? 'Paid on 31 May 2025';
    final String displayEarnings = record?.earnings ?? '₹ 55,000';
    final String displayDeductions = record?.deductions ?? '₹ 10,500';
    final String displayNetPay = record?.netPay ?? '₹ 44,500';

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
            icon: const Icon(Iconsax.import, color: AppColors.textColorPrimary), // download icon
            onPressed: () {
              Get.snackbar(
                'Download Started',
                'Downloading payslip PDF for $displayMonth...',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColors.primaryColor,
                colorText: Colors.white,
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          // Company Card
          _buildCompanyCard(displayMonth, displayDate),
          const SizedBox(height: 16),
          
          // Employee Info Card
          _buildEmployeeCard(),
          const SizedBox(height: 16),
          
          // Core Stats Row (4 stats columns)
          _buildCoreStatsRow(displayEarnings, displayDeductions, displayNetPay),
          const SizedBox(height: 20),
          
          // Earnings Breakdown
          _buildEarningsCard(),
          const SizedBox(height: 16),
          
          // Deductions Breakdown
          _buildDeductionsCard(),
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

  Widget _buildCompanyCard(String month, String date) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7FF), // Soft purple background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEBFF)),
      ),
      child: Row(
        children: [
          // Company Logo Placeholder Container
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
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const AppText('Paid', fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                    const SizedBox(width: 8),
                    AppText(date, fontSize: 11, color: AppColors.textColorSecondary),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeCard() {
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
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.slate200, width: 2),
              image: const DecorationImage(
                image: AssetImage('assets/images/user1.png'), // mock avatar
                fit: BoxFit.cover,
              ),
              color: AppColors.slate200,
            ),
            child: const Icon(Icons.person, size: 30, color: AppColors.slate400),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppText('Rahul Sharma', fontSize: 14, fontWeight: FontWeight.bold),
                      const SizedBox(height: 2),
                      const AppText('UI/UX Designer', fontSize: 11, color: AppColors.textColorSecondary),
                      const SizedBox(height: 4),
                      const AppText('EMP00123', fontSize: 11, color: AppColors.textColorSecondary, fontWeight: FontWeight.w600),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppText('Department', fontSize: 10.5, color: AppColors.textColorSecondary, fontWeight: FontWeight.w500),
                      const SizedBox(height: 2),
                      const AppText('Design', fontSize: 12, fontWeight: FontWeight.bold),
                      const SizedBox(height: 8),
                      const AppText('Location', fontSize: 10.5, color: AppColors.textColorSecondary, fontWeight: FontWeight.w500),
                      const SizedBox(height: 2),
                      const AppText('Bangalore', fontSize: 12, fontWeight: FontWeight.bold),
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

  Widget _buildCoreStatsRow(String earnings, String deductions, String netPay) {
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
          _buildStatItem(Iconsax.calendar, 'Total Days', '31', Colors.blue),
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
            color: color.withOpacity(0.08),
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

  Widget _buildEarningsCard() {
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
            children: const [
              AppText('Earnings', fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
              AppText('₹ 55,000', fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.borderColor, height: 1),
          const SizedBox(height: 12),
          _buildDetailRow('Basic Salary', '₹ 25,000'),
          _buildDetailRow('House Rent Allowance (HRA)', '₹ 10,000'),
          _buildDetailRow('Transport Allowance', '₹ 2,000'),
          _buildDetailRow('Special Allowance', '₹ 5,000'),
          _buildDetailRow('Performance Bonus', '₹ 10,000'),
          _buildDetailRow('Overtime', '₹ 3,000'),
        ],
      ),
    );
  }

  Widget _buildDeductionsCard() {
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
            children: const [
              AppText('Deductions', fontSize: 13, fontWeight: FontWeight.bold, color: Colors.red),
              AppText('₹ 10,500', fontSize: 13, fontWeight: FontWeight.bold, color: Colors.red),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.borderColor, height: 1),
          const SizedBox(height: 12),
          _buildDetailRow('Provident Fund (PF)', '₹ 2,500'),
          _buildDetailRow('Professional Tax', '₹ 200'),
          _buildDetailRow('Income Tax (TDS)', '₹ 5,000'),
          _buildDetailRow('Late Deduction (1 Day)', '₹ 800'),
          _buildDetailRow('Leave Deduction (2 Days)', '₹ 3,000'),
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
        color: const Color(0xFFF3F0FF), // Soft purple background
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
                // Mock signature graphic using a clean handwritten font style look in CustomPaint or a mock signatory lines
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

// A simple painter that draws a mock artistic signature scribble
class _SignaturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.indigo
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
