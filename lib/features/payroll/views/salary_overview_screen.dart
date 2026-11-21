import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../employee/management/models/employee_model.dart';
import '../controllers/payroll_controller.dart';
import '../models/payroll_record_model.dart';
import '../models/salary_detail_model.dart';
import '../repositories/payroll_repository.dart';
import '../widgets/salary_month_picker_sheet.dart';
import 'salary_breakdown_screen.dart';
import 'create_salary_form_screen.dart';
import 'payslip_created_screen.dart';

class SalaryOverviewScreen extends StatefulWidget {
  final EmployeeModel? employee;
  final PayrollRecord? record;

  const SalaryOverviewScreen({
    super.key,
    this.employee,
    this.record,
  });

  @override
  State<SalaryOverviewScreen> createState() => _SalaryOverviewScreenState();
}

class _SalaryOverviewScreenState extends State<SalaryOverviewScreen> {
  late final PayrollController controller;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<PayrollController>()) {
      Get.put(PayrollController(repository: PayrollRepository(apiClient: Get.find<ApiClient>())));
    }
    controller = Get.find<PayrollController>();

    if (widget.record != null) {
      controller.selectedRecord.value = widget.record;
    } else if (widget.employee != null) {
      final emp = widget.employee!;
      final existing = controller.payrollRecords.firstWhereOrNull(
        (r) => r.employeeId == emp.id || r.employeeId == emp.employeeId,
      );
      if (existing != null) {
        controller.selectedRecord.value = existing;
      } else {
        final basic = emp.salary;
        controller.selectedRecord.value = PayrollRecord(
          id: emp.id,
          employeeId: emp.employeeId.isNotEmpty ? emp.employeeId : emp.id,
          employeeName: emp.name,
          designation: emp.designation,
          department: emp.department,
          profilePic: emp.profilePic,
          salaryMonth: controller.selectedMonth.value,
          status: 'Pending',
          totalWorkingDays: 0,
          presentDays: 0,
          absentDays: 0,
          paidLeaves: 0,
          unpaidLeaves: 0,
          halfDays: 0,
          lateComingDays: 0,
          overtimeHours: 0,
          basicSalary: basic,
          hra: 0,
          conveyance: 0,
          specialAllowance: 0,
          incentive: 0,
          bonus: 0,
          overtimeAmount: 0,
          leaveDeduction: 0,
          lateDeduction: 0,
          pf: 0,
          esi: 0,
          loanAdvance: 0,
          otherDeduction: 0,
        );
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDetailsIfNeeded();
    });
  }

  void _loadDetailsIfNeeded() {
    final empId = widget.employee?.employeeId.isNotEmpty == true
        ? widget.employee!.employeeId
        : (widget.employee?.id.isNotEmpty == true
            ? widget.employee!.id
            : controller.selectedRecord.value?.employeeId);
    if (empId == null || empId.isEmpty) return;

    final currentDetail = controller.selectedSalaryDetail.value;
    final currentEmpId = currentDetail?.employee.employeeId ?? currentDetail?.employee.id.toString();

    // Fetch if detail is null or belongs to another employee or different month
    if (currentDetail == null ||
        currentEmpId != empId ||
        currentDetail.month != controller.selectedMonth.value) {
      controller.fetchEmployeeSalaryDetails(
        empId,
        month: controller.selectedMonth.value,
      );
    }
  }

  Future<void> _refreshDetails() async {
    final empId = widget.employee?.employeeId.isNotEmpty == true
        ? widget.employee!.employeeId
        : (widget.employee?.id.isNotEmpty == true
            ? widget.employee!.id
            : controller.selectedRecord.value?.employeeId);
    if (empId == null || empId.isEmpty) return;
    await controller.fetchEmployeeSalaryDetails(
      empId,
      month: controller.selectedMonth.value,
    );
  }

  void _showMonthPicker() {
    showSalaryMonthPickerSheet(
      context: context,
      initialMonthCode: controller.selectedMonth.value,
      onMonthSelected: (code, label) {
        controller.selectedMonth.value = code;
        controller.selectedMonthLabel.value = label;
        final empId = widget.employee?.employeeId.isNotEmpty == true
            ? widget.employee!.employeeId
            : (widget.employee?.id.isNotEmpty == true
                ? widget.employee!.id
                : controller.selectedRecord.value?.employeeId);
        if (empId != null && empId.isNotEmpty) {
          controller.fetchEmployeeSalaryDetails(empId, month: code);
        }
      },
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
            tooltip: 'Select Month',
            onPressed: _showMonthPicker,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Iconsax.calendar_1, color: AppColors.primaryColor, size: 18),
            ),
          ),
          const SizedBox(width: 8),
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
        final monthLabel = controller.selectedMonthLabel.value.isNotEmpty
            ? controller.selectedMonthLabel.value
            : (detail?.monthLabel.isNotEmpty == true ? detail!.monthLabel : (record?.salaryMonth ?? ''));

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

                      // ── Month & Status Bar (Interactive Month Selector) ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: _showMonthPicker,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.35)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLight,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Icon(Iconsax.calendar_1, color: AppColors.primaryColor, size: 14),
                                  ),
                                  const SizedBox(width: 8),
                                  AppText(
                                    monthLabel,
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textColorPrimary,
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.primaryColor),
                                ],
                              ),
                            ),
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
                      // ── E-Commerce Style Salary Bill Details Card ──
                      _buildSectionTitle('SALARY BILL DETAILS'),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.slate200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Receipt Header
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
                                    child: const Icon(Iconsax.receipt_2_1, color: AppColors.primaryColor, size: 16),
                                  ),
                                  const SizedBox(width: 10),
                                  const AppText(
                                    'Bill Details',
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textColorPrimary,
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: isCreated
                                          ? AppColors.successColor.withValues(alpha: 0.1)
                                          : AppColors.slate100,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: AppText(
                                      isCreated ? 'Disbursed' : 'Computed',
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                      color: isCreated ? AppColors.successColor : AppColors.textColorSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(color: AppColors.slate100, height: 1),

                            // Line Items
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                              child: Column(
                                children: [
                                  _buildBillItemRow(
                                    label: 'Total Gross Earnings',
                                    value: grossVal,
                                    isAddition: true,
                                    subtitle: 'Basic Pay + Allowances & Incentives',
                                  ),
                                  const SizedBox(height: 12),
                                  _buildBillItemRow(
                                    label: 'Total Deductions',
                                    value: '- $deductVal',
                                    isDeduction: true,
                                    subtitle: 'Leaves, PF, ESI & Statutory Taxes',
                                  ),
                                ],
                              ),
                            ),

                            // Dashed Divider
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: _buildDashedLine(),
                            ),
                            const SizedBox(height: 12),

                            // Total Net Payable Highlight Banner
                            Container(
                              margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F3FF),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFDDD6FE)),
                              ),
                              child: Row(
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
                                          Icon(Icons.verified_rounded, size: 12, color: Color(0xFF8B5CF6)),
                                          SizedBox(width: 4),
                                          AppText(
                                            'To be credited to bank',
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.textColorSecondary,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  AppText(
                                    netVal,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primaryColor,
                                  ),
                                ],
                              ),
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

  Widget _buildBillItemRow({
    required String label,
    required String value,
    bool isAddition = false,
    bool isDeduction = false,
    String? subtitle,
  }) {
    Color valColor = AppColors.textColorPrimary;
    if (isAddition) valColor = const Color(0xFF16A34A);
    if (isDeduction) valColor = const Color(0xFFDC2626);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                label,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textColorPrimary,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                AppText(
                  subtitle,
                  fontSize: 10.5,
                  color: AppColors.textColorHint,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
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
