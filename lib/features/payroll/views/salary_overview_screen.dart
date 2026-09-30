import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/payroll_controller.dart';
import '../models/salary_detail_model.dart';
import 'salary_breakdown_screen.dart';
import 'create_salary_form_screen.dart';
import 'payslip_created_screen.dart';

class SalaryOverviewScreen extends StatefulWidget {
  const SalaryOverviewScreen({super.key});

  @override
  State<SalaryOverviewScreen> createState() => _SalaryOverviewScreenState();
}

class _SalaryOverviewScreenState extends State<SalaryOverviewScreen> {
  late final PayrollController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<PayrollController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDetailsIfNeeded();
    });
  }

  void _loadDetailsIfNeeded() {
    final record = controller.selectedRecord.value;
    if (record == null) return;

    final currentDetail = controller.selectedSalaryDetail.value;
    final currentEmpId = currentDetail?.employee.employeeId ?? currentDetail?.employee.id.toString();

    // Fetch if detail is null or belongs to another employee or different month
    if (currentDetail == null ||
        currentEmpId != record.employeeId ||
        currentDetail.month != controller.selectedMonth.value) {
      controller.fetchEmployeeSalaryDetails(
        record.employeeId,
        month: controller.selectedMonth.value,
      );
    }
  }

  Future<void> _refreshDetails() async {
    final record = controller.selectedRecord.value;
    if (record == null) return;
    await controller.fetchEmployeeSalaryDetails(
      record.employeeId,
      month: controller.selectedMonth.value,
    );
  }

  @override
  Widget build(BuildContext context) {
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
          final detail = controller.selectedSalaryDetail.value;
          final record = controller.selectedRecord.value;
          final titleName = detail?.employee.name ?? record?.employeeName ?? 'Overview';
          return AppText(
            titleName,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textColorPrimary,
          );
        }),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.refresh, color: AppColors.textColorPrimary, size: 20),
            tooltip: 'Refresh',
            onPressed: _refreshDetails,
          ),
        ],
      ),
      body: Obx(() {
        final record = controller.selectedRecord.value;
        final detail = controller.selectedSalaryDetail.value;
        final isLoading = controller.isDetailLoading.value;
        final errorMsg = controller.detailErrorMessage.value;

        // If no record is selected at all
        if (record == null && detail == null) {
          return const Center(child: AppText('No employee selected.'));
        }

        // Initial loading state when detail is not yet loaded and no previous record exists
        if (isLoading && detail == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CircularProgressIndicator(color: AppColors.primaryColor),
                SizedBox(height: 16),
                AppText('Loading salary details...', fontSize: 14, color: AppColors.textColorSecondary),
              ],
            ),
          );
        }

        // Error state when no detail is available
        if (detail == null && errorMsg.isNotEmpty && record == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Iconsax.info_circle, color: AppColors.errorColor, size: 48),
                  const SizedBox(height: 12),
                  AppText(errorMsg, fontSize: 14, color: AppColors.textColorSecondary, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshDetails,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const AppText('Retry', color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          );
        }

        // Active values: prefer detailed API data, fallback to list record
        final isCreated = detail?.salaryCreated ?? (record?.status.toLowerCase() == 'created');
        final grossVal = "₹${_formatSalary((detail?.grossEarnings ?? record?.grossEarnings ?? 0).toInt())}";
        final deductVal = "₹${_formatSalary((detail?.totalDeductions ?? record?.totalDeductions ?? 0).toInt())}";
        final netVal = "₹${_formatSalary((detail?.netPayable ?? record?.netPayable ?? 0).toInt())}";

        final employeeName = detail?.employee.name ?? record?.employeeName ?? 'Employee';
        final employeeId = detail?.employee.employeeId ?? record?.employeeId ?? '';
        final designation = detail?.employee.designation ?? record?.designation ?? '—';
        final department = detail?.employee.department ?? record?.department ?? '';
        final avatarUrl = detail?.employee.safeAvatarUrl ?? record?.profilePic;
        final joiningDate = _formatDate(detail?.employee.dateOfJoining);
        final salaryType = detail?.employee.salaryType ?? 'Monthly';
        final monthLabel = detail?.monthLabel.isNotEmpty == true ? detail!.monthLabel : (record?.salaryMonth ?? '');

        // Attendance stats
        final totalWorkingDays = detail?.attendanceSummary.totalWorkingDays ?? record?.totalWorkingDays ?? 0;
        final presentDays = detail?.attendanceSummary.presentDays ?? record?.presentDays ?? 0;
        final absentDays = detail?.attendanceSummary.absentDays ?? record?.absentDays ?? 0;
        final paidLeaves = detail?.attendanceSummary.paidLeaves ?? record?.paidLeaves ?? 0;
        final unpaidLeaves = detail?.attendanceSummary.unpaidLeaves ?? record?.unpaidLeaves ?? 0;
        final halfDays = detail?.attendanceSummary.halfDays ?? record?.halfDays ?? 0;
        final lateComingDays = detail?.attendanceSummary.lateComingDays ?? record?.lateComingDays ?? 0;
        final overtimeHours = detail?.attendanceSummary.overtimeHours ?? record?.overtimeHours ?? 0;

        return Column(
          children: [
            // Linear loading indicator when re-fetching in background
            if (isLoading)
              const LinearProgressIndicator(
                backgroundColor: Colors.transparent,
                color: AppColors.primaryColor,
                minHeight: 2.5,
              ),

            Expanded(
              child: RefreshIndicator(
                color: AppColors.primaryColor,
                onRefresh: _refreshDetails,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                child: avatarUrl != null && avatarUrl.isNotEmpty
                                    ? Image.network(
                                        avatarUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) =>
                                            _buildFallbackAvatar(employeeName),
                                      )
                                    : _buildFallbackAvatar(employeeName),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: AppText(
                                          employeeName,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textColorPrimary,
                                        ),
                                      ),
                                      if (employeeId.isNotEmpty)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: AppColors.slate100,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: AppText(
                                            employeeId,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textColorSecondary,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  AppText(
                                    department.isNotEmpty ? '$designation • $department' : designation,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textColorSecondary,
                                  ),
                                  const SizedBox(height: 6),
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 4,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Iconsax.calendar_1, color: AppColors.textColorHint, size: 12),
                                          const SizedBox(width: 4),
                                          AppText(
                                            'Joining: $joiningDate',
                                            fontSize: 11,
                                            color: AppColors.textColorSecondary,
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Iconsax.card, color: AppColors.textColorHint, size: 12),
                                          const SizedBox(width: 4),
                                          AppText(
                                            'Mode: $salaryType',
                                            fontSize: 11,
                                            color: AppColors.textColorSecondary,
                                          ),
                                        ],
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

                      // ── Month & Status Bar ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.slate200),
                                ),
                                child: const Icon(Iconsax.calendar_1, color: AppColors.primaryColor, size: 16),
                              ),
                              const SizedBox(width: 10),
                              AppText(
                                monthLabel,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textColorPrimary,
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: (isCreated ? AppColors.successColor : AppColors.warningColor).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: (isCreated ? AppColors.successColor : AppColors.warningColor).withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isCreated ? Icons.check_circle_rounded : Icons.pending_rounded,
                                  size: 13,
                                  color: isCreated ? AppColors.successColor : AppColors.warningColor,
                                ),
                                const SizedBox(width: 4),
                                AppText(
                                  isCreated ? 'Created' : 'Pending',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isCreated ? AppColors.successColor : AppColors.warningColor,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ── Attendance Grid Overview Card ──
                      _buildSectionTitle('ATTENDANCE SUMMARY'),
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
                                _buildGridCell('Total Working Days', '$totalWorkingDays', AppColors.slate600),
                                _buildGridCell('Present Days', '$presentDays', AppColors.successColor),
                                _buildGridCell('Absent Days', '$absentDays', AppColors.errorColor),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12.0),
                              child: Divider(color: AppColors.slate100),
                            ),
                            Row(
                              children: [
                                _buildGridCell('Paid Leaves', '$paidLeaves', AppColors.infoColor),
                                _buildGridCell('Unpaid Leaves', '$unpaidLeaves', AppColors.warningColor),
                                _buildGridCell('Half Days', '$halfDays', AppColors.slate500),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12.0),
                              child: Divider(color: AppColors.slate100),
                            ),
                            Row(
                              children: [
                                _buildGridCell('Late Coming (Days)', '$lateComingDays', AppColors.errorColor),
                                _buildGridCell('Overtime (Hrs)', '$overtimeHours', AppColors.successColor),
                                const Expanded(child: SizedBox()),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Financial Metrics Summary Card ──
                      _buildSectionTitle('SALARY SUMMARY'),
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
                      const SizedBox(height: 20),

                      // ── Payment Details Section (if available) ──
                      if (detail?.paymentDetails != null) ...[
                        _buildSectionTitle('PAYMENT DETAILS'),
                        const SizedBox(height: 8),
                        _buildPaymentDetailsCard(detail!.paymentDetails!),
                        const SizedBox(height: 20),
                      ],

                      // ── Payslip URL Banner (if available) ──
                      if (detail?.payslipUrl != null && detail!.payslipUrl!.isNotEmpty) ...[
                        _buildPayslipDownloadBanner(detail.payslipUrl!),
                        const SizedBox(height: 20),
                      ],

                      // ── View Salary Breakdown Button ──
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(Iconsax.chart_2, size: 18, color: AppColors.primaryColor),
                          onPressed: () => Get.to(() => const SalaryBreakdownScreen()),
                          label: const AppText(
                            'View Detailed Salary Breakdown',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primaryColor, width: 1.5),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),

            // ── Symmetrical Bottom Action Button ──
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
                      if (record != null) {
                        controller.initializePaymentForm(record);
                      }
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

  Widget _buildPaymentDetailsCard(SalaryPaymentDetails payment) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.successColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Iconsax.receipt_2_1, color: AppColors.successColor, size: 18),
                  ),
                  const SizedBox(width: 10),
                  const AppText(
                    'Disbursement Status',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColorPrimary,
                  ),
                ],
              ),
              if (payment.status != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.successColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: AppText(
                    payment.status!,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.successColor,
                  ),
                ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Divider(color: AppColors.slate100),
          ),
          _buildPaymentRow('Payment Mode', payment.paymentMode ?? '—'),
          if (payment.paymentDate != null && payment.paymentDate!.isNotEmpty)
            _buildPaymentRow('Payment Date', _formatDate(payment.paymentDate)),
          if (payment.bankName != null && payment.bankName!.isNotEmpty)
            _buildPaymentRow('Bank Name', payment.bankName!),
          if (payment.accountUpiAddress != null && payment.accountUpiAddress!.isNotEmpty)
            _buildPaymentRow('Account / UPI', payment.accountUpiAddress!),
          if (payment.remarks != null && payment.remarks!.isNotEmpty)
            _buildPaymentRow('Remarks', payment.remarks!),
        ],
      ),
    );
  }

  Widget _buildPayslipDownloadBanner(String url) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Iconsax.document_download, color: AppColors.primaryColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                AppText(
                  'Official Payslip Document',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColorPrimary,
                ),
                SizedBox(height: 2),
                AppText(
                  'Download or open official receipt',
                  fontSize: 11,
                  color: AppColors.textColorSecondary,
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _openPayslip(url),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              elevation: 0,
            ),
            child: const AppText('View', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(
            label,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textColorSecondary,
          ),
          AppText(
            value,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.textColorPrimary,
          ),
        ],
      ),
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
          name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'E',
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryColor,
        ),
      ),
    );
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '—';
    try {
      final parsed = DateTime.tryParse(raw);
      if (parsed != null) {
        return DateFormat('dd MMM yyyy').format(parsed);
      }
    } catch (_) {}
    return raw;
  }

  Future<void> _openPayslip(String? url) async {
    if (url == null || url.isEmpty) return;
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'Notice',
          'Cannot open payslip URL: $url',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.warningColor,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Notice',
        'Could not open link: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
      );
    }
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
