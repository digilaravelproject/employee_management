import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import 'payslip_detail_screen.dart';

class PayslipHistoryScreen extends StatelessWidget {
  const PayslipHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock records matching high fidelity screenshots
    final records = [
      _PayslipRecord(month: 'May 2025', date: 'Paid on 31 May 2025', earnings: '₹ 55,000', deductions: '₹ 10,500', netPay: '₹ 44,500'),
      _PayslipRecord(month: 'April 2025', date: 'Paid on 30 Apr 2025', earnings: '₹ 50,000', deductions: '₹ 9,500', netPay: '₹ 40,500'),
      _PayslipRecord(month: 'March 2025', date: 'Paid on 31 Mar 2025', earnings: '₹ 50,000', deductions: '₹ 9,000', netPay: '₹ 41,000'),
      _PayslipRecord(month: 'February 2025', date: 'Paid on 28 Feb 2025', earnings: '₹ 45,000', deductions: '₹ 8,000', netPay: '₹ 37,000'),
      _PayslipRecord(month: 'January 2025', date: 'Paid on 31 Jan 2025', earnings: '₹ 45,000', deductions: '₹ 7,500', netPay: '₹ 37,500'),
      _PayslipRecord(month: 'December 2024', date: 'Paid on 31 Dec 2024', earnings: '₹ 45,000', deductions: '₹ 7,000', netPay: '₹ 38,000'),
      _PayslipRecord(month: 'November 2024', date: 'Paid on 30 Nov 2024', earnings: '₹ 45,000', deductions: '₹ 7,000', netPay: '₹ 38,000'),
      _PayslipRecord(month: 'October 2024', date: 'Paid on 31 Oct 2024', earnings: '₹ 45,000', deductions: '₹ 7,000', netPay: '₹ 38,000'),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textColorPrimary),
          onPressed: () => Get.back(),
        ),
        title: const AppText('Payslip History', fontSize: 18, fontWeight: FontWeight.bold),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.setting_4, color: AppColors.textColorPrimary), // filter icon
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          // YTD Summary Card (No outer padding in children list to match margins)
          _buildYtdCard(),
          
          const SizedBox(height: 10),
          
          // List of Payslips
          ...records.map((rec) => _buildRecordCard(rec)),
          
          const SizedBox(height: 16),
          
          // YTD Banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.slate50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Iconsax.info_circle5, color: AppColors.primaryColor, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: AppText(
                    'YTD (Year To Date) summary is calculated from January to the current month.',
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textColorSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildYtdCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F0FF), // Very soft purple background
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE9E3FF)),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          'Total Earnings (YTD)',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColorSecondary,
                        ),
                        const SizedBox(height: 4),
                        const AppText(
                          '₹ 2,75,000',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColorPrimary,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          'Total Deductions (YTD)',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColorSecondary,
                        ),
                        const SizedBox(height: 4),
                        const AppText(
                          '₹ 52,500',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColorPrimary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(color: Color(0xFFE0D8FF), height: 1),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    'Net Pay (YTD)',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColorSecondary,
                  ),
                  const SizedBox(height: 4),
                  const AppText(
                    '₹ 2,22,500',
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryColor,
                  ),
                ],
              ),
            ],
          ),
          
          // Wallet/Coin Graphic Illustration in standard widgets
          Positioned(
            right: 0,
            bottom: 0,
            child: SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  // Wallet body
                  Container(
                    width: 60,
                    height: 45,
                    decoration: BoxDecoration(
                      color: const Color(0xFF818CF8),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.indigo.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                  // Wallet flap
                  Positioned(
                    top: 15,
                    right: 0,
                    child: Container(
                      width: 30,
                      height: 15,
                      decoration: const BoxDecoration(
                        color: Color(0xFF6366F1),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(5),
                          bottomLeft: Radius.circular(5),
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(left: 4),
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFCD34D),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Cash sticking out
                  Positioned(
                    top: 15,
                    left: 20,
                    child: Transform.rotate(
                      angle: -0.15,
                      child: Container(
                        width: 32,
                        height: 20,
                        decoration: BoxDecoration(
                          color: const Color(0xFF34D399),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 28,
                    child: Transform.rotate(
                      angle: 0.1,
                      child: Container(
                        width: 32,
                        height: 20,
                        decoration: BoxDecoration(
                          color: const Color(0xFF6EE7B7),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                  ),
                  // Coins
                  Positioned(
                    left: 5,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBBF24),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 15,
                    bottom: 2,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
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
  }

  Widget _buildRecordCard(_PayslipRecord record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: record.month.contains('May') 
              ? AppColors.primaryLight 
              : AppColors.borderColor, 
          width: record.month.contains('May') ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Get.to(() => PayslipDetailScreen(record: record)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText(record.month, fontSize: 14, fontWeight: FontWeight.bold),
                    const Icon(Icons.keyboard_arrow_right, color: AppColors.textColorSecondary, size: 20),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText(record.date, fontSize: 11, color: AppColors.textColorSecondary),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const AppText(
                        'Paid',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: AppColors.borderColor, height: 1),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatColumn('Earnings', record.earnings),
                    _buildStatColumn('Deductions', record.deductions),
                    _buildStatColumn('Net Pay', record.netPay, isHighlight: true),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, {bool isHighlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(label, fontSize: 10.5, color: AppColors.textColorSecondary, fontWeight: FontWeight.w500),
        const SizedBox(height: 4),
        AppText(
          value,
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: isHighlight ? AppColors.primaryColor : AppColors.textColorPrimary,
        ),
      ],
    );
  }
}

class _PayslipRecord {
  final String month;
  final String date;
  final String earnings;
  final String deductions;
  final String netPay;

  _PayslipRecord({
    required this.month,
    required this.date,
    required this.earnings,
    required this.deductions,
    required this.netPay,
  });
}
