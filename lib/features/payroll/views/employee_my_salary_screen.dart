import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';

class EmployeeMySalaryScreen extends StatelessWidget {
  const EmployeeMySalaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for salary history
    final List<Map<String, dynamic>> salaryHistory = [
      {
        'month': 'August 2026',
        'paidAmount': 42500.0,
        'deductions': 2500.0,
        'status': 'Paid',
        'date': '01 Sep 2026',
      },
      {
        'month': 'July 2026',
        'paidAmount': 42500.0,
        'deductions': 2500.0,
        'status': 'Paid',
        'date': '01 Aug 2026',
      },
      {
        'month': 'June 2026',
        'paidAmount': 45000.0,
        'deductions': 0.0,
        'status': 'Paid',
        'date': '01 Jul 2026',
      },
      {
        'month': 'May 2026',
        'paidAmount': 42500.0,
        'deductions': 2500.0,
        'status': 'Paid',
        'date': '01 Jun 2026',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current CTC Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppText(
                      'Current Monthly CTC',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                    const SizedBox(height: 8),
                    const AppText(
                      '₹45,000.00',
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildCtcDetail('Basic', '₹22,500'),
                        _buildCtcDetail('HRA', '₹11,250'),
                        _buildCtcDetail('Allowances', '₹11,250'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const AppText(
                'Recent Payslips',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textColorPrimary,
              ),
              const SizedBox(height: 16),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: salaryHistory.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final data = salaryHistory[index];
                  return _SalaryHistoryCard(data: data);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCtcDetail(String label, String amount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          label,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Colors.white70,
        ),
        const SizedBox(height: 4),
        AppText(
          amount,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ],
    );
  }
}

class _SalaryHistoryCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const _SalaryHistoryCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final paidAmount = data['paidAmount'] as double;
    final deductions = data['deductions'] as double;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                data['month'],
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textColorPrimary,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: AppText(
                  data['status'],
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.successColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.slate200, height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppText(
                    'Net Pay',
                    fontSize: 12,
                    color: AppColors.textColorSecondary,
                  ),
                  const SizedBox(height: 4),
                  AppText(
                    '₹${paidAmount.toStringAsFixed(2)}',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryColor,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const AppText(
                    'Deductions (Leaves/LWP)',
                    fontSize: 12,
                    color: AppColors.textColorSecondary,
                  ),
                  const SizedBox(height: 4),
                  AppText(
                    '₹${deductions.toStringAsFixed(2)}',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: deductions > 0 ? AppColors.errorColor : AppColors.successColor,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Iconsax.calendar_1, size: 14, color: AppColors.textColorHint),
              const SizedBox(width: 4),
              AppText(
                'Paid on ${data['date']}',
                fontSize: 12,
                color: AppColors.textColorSecondary,
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  Get.snackbar(
                    'Download',
                    'Downloading payslip for ${data['month']}...',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: AppColors.primaryColor,
                    colorText: Colors.white,
                  );
                },
                icon: const Icon(Iconsax.document_download, size: 16, color: AppColors.primaryColor),
                label: const AppText(
                  'Payslip',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryColor,
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
