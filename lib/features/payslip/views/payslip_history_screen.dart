import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../payroll/controllers/salary_history_controller.dart';
import '../../payroll/models/salary_history_model.dart';
import '../../payroll/repositories/payroll_repository.dart';
import '../../payroll/repositories/payroll_repository_interface.dart';
import 'payslip_detail_screen.dart';

class PayslipHistoryScreen extends StatelessWidget {
  const PayslipHistoryScreen({super.key});

  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹ ',
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textColorPrimary, size: 18),
          onPressed: () => Get.back(),
        ),
        title: const AppText('Payslip History', fontSize: 18, fontWeight: FontWeight.bold),
        centerTitle: true,
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
      body: Obx(() {
        if (controller.isLoading.value && controller.salaryHistoryData.value == null) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primaryColor),
                SizedBox(height: 16),
                AppText('Loading payslips...', fontSize: 14, color: AppColors.textColorSecondary),
              ],
            ),
          );
        }

        if (controller.errorMessage.value.isNotEmpty && controller.salaryHistoryData.value == null) {
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

        final payslips = controller.recentPayslips;

        // Calculate YTD totals dynamically from recent payslips of the selected year
        num totalEarningsYtd = 0;
        num totalDeductionsYtd = 0;
        num totalNetPayYtd = 0;

        for (final p in payslips) {
          totalEarningsYtd += p.grossEarnings;
          totalDeductionsYtd += p.totalDeductions;
          totalNetPayYtd += p.netPayable;
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchSalaryHistory(),
          color: AppColors.primaryColor,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            children: [
              // YTD Summary Card with dynamic totals
              _buildYtdCard(
                controller: controller,
                earningsYtd: totalEarningsYtd,
                deductionsYtd: totalDeductionsYtd,
                netPayYtd: totalNetPayYtd,
              ),

              const SizedBox(height: 10),

              // Header & Count
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const AppText('Payslips', fontSize: 16, fontWeight: FontWeight.bold),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.slate200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: AppText(
                          '${payslips.length}',
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

              const SizedBox(height: 12),

              // List of Payslips or Empty State
              if (payslips.isEmpty)
                _buildEmptyState(controller)
              else
                ...payslips.map((rec) => _buildRecordCard(rec, controller)),

              const SizedBox(height: 16),

              // YTD Banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.slate50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.slate200),
                ),
                child: Row(
                  children: [
                    const Icon(Iconsax.info_circle5, color: AppColors.primaryColor, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AppText(
                        'YTD (Year To Date) summary is calculated from January to the current month for year ${controller.selectedYear.value}.',
                        fontSize: 11,
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
      }),
    );
  }


  Widget _buildYtdCard({
    required SalaryHistoryController controller,
    required num earningsYtd,
    required num deductionsYtd,
    required num netPayYtd,
  }) {
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
                        const AppText(
                          'Total Earnings (YTD)',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColorSecondary,
                        ),
                        const SizedBox(height: 4),
                        AppText(
                          _currencyFormat.format(earningsYtd),
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
                        const AppText(
                          'Total Deductions (YTD)',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColorSecondary,
                        ),
                        const SizedBox(height: 4),
                        AppText(
                          _currencyFormat.format(deductionsYtd),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColorPrimary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: Color(0xFFE0D8FF), height: 1),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppText(
                    'Net Pay (YTD)',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColorSecondary,
                  ),
                  const SizedBox(height: 4),
                  AppText(
                    _currencyFormat.format(netPayYtd),
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryColor,
                  ),
                ],
              ),
            ],
          ),

          // Wallet/Coin Graphic Illustration
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
                      color: AppColors.primaryShade300,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryColor.withValues(alpha: 0.2),
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
                        color: AppColors.primaryColor,
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

  Widget _buildRecordCard(RecentPayslipModel record, SalaryHistoryController controller) {
    final monthText = record.monthLabel.isNotEmpty ? record.monthLabel : record.salaryMonth;
    final dateText = record.paymentDate != null && record.paymentDate!.isNotEmpty
        ? 'Paid on ${record.paymentDate}'
        : 'Status: ${record.status}';

    final isPaid = record.status.toLowerCase() == 'paid';
    final statusColor = isPaid ? Colors.green : Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderColor,
          width: 1,
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
                    AppText(monthText, fontSize: 14, fontWeight: FontWeight.bold),
                    const Icon(Icons.keyboard_arrow_right, color: AppColors.textColorSecondary, size: 20),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText(dateText, fontSize: 11, color: AppColors.textColorSecondary),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: AppText(
                        record.status,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
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
                    _buildStatColumn('Earnings', _currencyFormat.format(record.grossEarnings)),
                    _buildStatColumn('Deductions', _currencyFormat.format(record.totalDeductions)),
                    _buildStatColumn('Net Pay', _currencyFormat.format(record.netPayable), isHighlight: true),
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

  Widget _buildEmptyState(SalaryHistoryController controller) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.slate50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Iconsax.receipt_item, size: 32, color: AppColors.textColorHint),
          ),
          const SizedBox(height: 12),
          AppText(
            'No Payslips for ${controller.selectedYear.value}',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textColorPrimary,
          ),
          const SizedBox(height: 4),
          const AppText(
            'No salary history records were found for this year.',
            fontSize: 12,
            color: AppColors.textColorSecondary,
            textAlign: TextAlign.center,
          ),
        ],
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
