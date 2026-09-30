import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/payroll_controller.dart';
import 'payslip_created_screen.dart';

class CreateSalaryFormScreen extends StatefulWidget {
  const CreateSalaryFormScreen({super.key});

  @override
  State<CreateSalaryFormScreen> createState() => _CreateSalaryFormScreenState();
}

class _CreateSalaryFormScreenState extends State<CreateSalaryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final PayrollController controller;

  String? _modeError;
  String? _checkboxError;

  @override
  void initState() {
    super.initState();
    controller = Get.find<PayrollController>();
    if (controller.formEarnings.isEmpty && controller.selectedRecord.value != null) {
      controller.initializePaymentForm(controller.selectedRecord.value!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.slate100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.textColorPrimary,
                size: 18,
              ),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText(
              'Create Salary',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textColorPrimary,
            ),
            Obx(() {
              final month = controller.selectedMonthLabel.value.isNotEmpty
                  ? controller.selectedMonthLabel.value
                  : controller.selectedMonth.value;
              return AppText(
                'Payroll Period • $month',
                fontSize: 11,
                color: AppColors.textColorSecondary,
              );
            }),
          ],
        ),
        actions: [
          Obx(() {
            final month = controller.selectedMonth.value;
            return Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Iconsax.calendar_1, size: 13, color: AppColors.primaryColor),
                  const SizedBox(width: 4),
                  AppText(
                    month,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryColor,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── 1. Hero Employee Overview Card ──
                    _buildEmployeeHeroCard(),
                    const SizedBox(height: 18),

                    // ── 2. Earnings Breakdown Card ──
                    _buildEarningsCard(),
                    const SizedBox(height: 18),

                    // ── 3. Deductions Breakdown Card ──
                    _buildDeductionsCard(),
                    const SizedBox(height: 18),

                    // ── 4. Payment & Disbursement Details Card ──
                    _buildPaymentDisbursementCard(),
                    const SizedBox(height: 18),

                    // ── 5. Real-time Calculation Summary Card ──
                    _buildCalculationSummaryCard(),
                    const SizedBox(height: 16),

                    // ── 6. Confirmation Verification Card ──
                    _buildConfirmationCard(),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // ── Sticky Bottom Action Bar ──
            _buildBottomActionBar(),
          ],
        ),
      ),
    );
  }

  // ── 1. Hero Employee Card ──
  Widget _buildEmployeeHeroCard() {
    return Obx(() {
      final record = controller.selectedRecord.value;
      final detail = controller.selectedSalaryDetail.value;
      if (record == null && detail == null) return const SizedBox();

      final empName = detail?.employee.name ?? record?.employeeName ?? '';
      final empId = detail?.employee.employeeId ?? record?.employeeId ?? '';
      final empDept = detail?.employee.department ?? record?.department ?? '';
      final empDesig = detail?.employee.designation ?? record?.designation ?? '';
      final avatarUrl = detail?.employee.safeAvatarUrl ?? record?.profilePic;
      final netAmount = controller.calculatedNetPayable;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.slate200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Avatar
                Stack(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.slate100, width: 2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: avatarUrl != null && avatarUrl.isNotEmpty
                            ? Image.network(
                                avatarUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildFallbackAvatar(empName),
                              )
                            : _buildFallbackAvatar(empName),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: AppColors.successColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                // Employee Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: AppText(
                              empName,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColorPrimary,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.slate100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: AppText(
                              empId,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textColorSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      AppText(
                        empDept.isNotEmpty ? '$empDesig • $empDept' : empDesig,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textColorSecondary,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Divider(color: AppColors.slate100, height: 1),
            ),
            // Bottom preview row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Iconsax.wallet_check, size: 15, color: AppColors.textColorSecondary),
                    const SizedBox(width: 6),
                    AppText(
                      'Target Net Payable',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColorSecondary,
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: AppText(
                    '₹${_formatSalary(netAmount.toInt())}',
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  // ── 2. Earnings Breakdown Card ──
  Widget _buildEarningsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.slate200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.successColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Iconsax.wallet_3, color: AppColors.successColor, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const AppText(
                            'EARNINGS',
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            color: AppColors.successColor,
                          ),
                          const SizedBox(width: 6),
                          Obx(() => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: AppColors.successColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: AppText(
                                  '${controller.formEarnings.length} items',
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.successColor,
                                ),
                              )),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Obx(() => AppText(
                            'Total: ₹${_formatSalary(controller.calculatedGrossEarnings.toInt())}',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColorSecondary,
                          )),
                    ],
                  ),
                ),
                // Add Item Button
                OutlinedButton.icon(
                  icon: const Icon(Icons.add_rounded, size: 15, color: AppColors.successColor),
                  label: const AppText(
                    'Add',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.successColor,
                  ),
                  onPressed: () {
                    controller.addEarningItem(name: '', amount: '0');
                    setState(() {});
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.successColor.withValues(alpha: 0.4)),
                    backgroundColor: AppColors.successColor.withValues(alpha: 0.05),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.slate100, height: 1),

          // Items List
          Padding(
            padding: const EdgeInsets.all(16),
            child: Obx(() {
              if (controller.formEarnings.isEmpty) {
                return _buildEmptySectionPlaceholder(
                  'No earnings added.',
                  'Tap "Add" above to add Basic, HRA or other allowances.',
                );
              }
              return Column(
                children: List.generate(
                  controller.formEarnings.length,
                  (index) => _buildEarningItemRow(index, controller.formEarnings[index]),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── 3. Deductions Breakdown Card ──
  Widget _buildDeductionsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.slate200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.errorColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Iconsax.card_remove, color: AppColors.errorColor, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const AppText(
                            'DEDUCTIONS',
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            color: AppColors.errorColor,
                          ),
                          const SizedBox(width: 6),
                          Obx(() => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: AppColors.errorColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: AppText(
                                  '${controller.formDeductions.length} items',
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.errorColor,
                                ),
                              )),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Obx(() => AppText(
                            'Total: - ₹${_formatSalary(controller.calculatedTotalDeductions.toInt())}',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColorSecondary,
                          )),
                    ],
                  ),
                ),
                // Add Item Button
                OutlinedButton.icon(
                  icon: const Icon(Icons.add_rounded, size: 15, color: AppColors.errorColor),
                  label: const AppText(
                    'Add',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.errorColor,
                  ),
                  onPressed: () {
                    controller.addDeductionItem(name: '', amount: '0');
                    setState(() {});
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.errorColor.withValues(alpha: 0.4)),
                    backgroundColor: AppColors.errorColor.withValues(alpha: 0.05),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.slate100, height: 1),

          // Items List
          Padding(
            padding: const EdgeInsets.all(16),
            child: Obx(() {
              if (controller.formDeductions.isEmpty) {
                return _buildEmptySectionPlaceholder(
                  'No deductions configured.',
                  'Leaves/LWP, PF, ESI or advance will be 0.',
                );
              }
              return Column(
                children: List.generate(
                  controller.formDeductions.length,
                  (index) => _buildDeductionItemRow(index, controller.formDeductions[index]),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── 4. Payment & Disbursement Card ──
  Widget _buildPaymentDisbursementCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.slate200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Iconsax.card_send, color: AppColors.primaryColor, size: 18),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    AppText(
                      'PAYMENT DETAILS',
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: AppColors.primaryColor,
                    ),
                    SizedBox(height: 2),
                    AppText(
                      'Select mode, date and transaction info',
                      fontSize: 11,
                      color: AppColors.textColorSecondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.slate100, height: 1),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Payment Mode Selection Pills
                const AppText(
                  'Payment Mode *',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColorPrimary,
                ),
                const SizedBox(height: 8),
                Obx(() {
                  final currentMode = controller.selectedPaymentMode.value ?? 'Bank Transfer';
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: controller.paymentModes.map((mode) {
                          final isSelected = currentMode == mode;
                          return InkWell(
                            onTap: () {
                              controller.selectedPaymentMode.value = mode;
                              setState(() {
                                _modeError = null;
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primaryColor : AppColors.slate50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? AppColors.primaryColor : AppColors.slate200,
                                  width: 1.2,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getPaymentModeIcon(mode),
                                    size: 15,
                                    color: isSelected ? Colors.white : AppColors.textColorSecondary,
                                  ),
                                  const SizedBox(width: 6),
                                  AppText(
                                    mode,
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                    color: isSelected ? Colors.white : AppColors.textColorPrimary,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      if (_modeError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 6, left: 4),
                          child: AppText(_modeError!, color: AppColors.errorColor, fontSize: 11),
                        ),
                    ],
                  );
                }),
                const SizedBox(height: 16),

                // Payment Date Picker Field
                const AppText(
                  'Payment Date *',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColorPrimary,
                ),
                const SizedBox(height: 6),
                Obx(() {
                  final date = controller.paymentDate.value ?? DateTime.now();
                  final formattedDisplay = DateFormat('dd MMMM yyyy').format(date);
                  return InkWell(
                    onTap: _selectPaymentDate,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.slate50,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.slate200),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Iconsax.calendar_1, size: 16, color: AppColors.primaryColor),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(
                                  formattedDisplay,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textColorPrimary,
                                ),
                                const SizedBox(height: 1),
                                const AppText(
                                  'Disbursement / Processing Date',
                                  fontSize: 10,
                                  color: AppColors.textColorHint,
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: AppColors.slate400),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),

                // Bank Name Input
                _buildModernTextField(
                  controller: controller.bankNameController,
                  label: 'Bank / Institution Name *',
                  hint: 'e.g. HDFC Bank, SBI',
                  prefixIcon: Iconsax.bank,
                  isRequired: true,
                  validator: (val) =>
                      val == null || val.trim().isEmpty ? 'Please enter bank name' : null,
                ),
                const SizedBox(height: 14),

                // Account / UPI ID Input
                _buildModernTextField(
                  controller: controller.accountController,
                  label: 'Account / UPI Address *',
                  hint: 'e.g. XXXX XXXX XXXX 1234 or name@upi',
                  prefixIcon: Iconsax.card_pos,
                  isRequired: true,
                  validator: (val) =>
                      val == null || val.trim().isEmpty ? 'Please enter account or UPI ID' : null,
                ),
                const SizedBox(height: 14),

                // Remarks Input
                _buildModernTextField(
                  controller: controller.remarksController,
                  label: 'Remarks (Optional)',
                  hint: 'e.g. Processed successfully',
                  prefixIcon: Iconsax.note_text,
                  isRequired: false,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 5. Real-time Calculation Summary Card ──
  Widget _buildCalculationSummaryCard() {
    return Obx(() {
      final gross = controller.calculatedGrossEarnings;
      final deductions = controller.calculatedTotalDeductions;
      final net = controller.calculatedNetPayable;

      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.slate200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Iconsax.calculator, size: 16, color: AppColors.primaryColor),
                    ),
                    const SizedBox(width: 8),
                    const AppText(
                      'CALCULATION SUMMARY',
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: AppColors.textColorPrimary,
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.successColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.bolt, size: 11, color: AppColors.successColor),
                      SizedBox(width: 2),
                      AppText(
                        'LIVE',
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.successColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Divider(color: AppColors.slate100, height: 1),
            ),
            _buildCalculationRow(
              label: 'Gross Earnings (A)',
              value: '₹${_formatSalary(gross.toInt())}',
              color: AppColors.successColor,
              prefix: '+ ',
            ),
            const SizedBox(height: 10),
            _buildCalculationRow(
              label: 'Total Deductions (B)',
              value: '₹${_formatSalary(deductions.toInt())}',
              color: AppColors.errorColor,
              prefix: '- ',
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Divider(color: AppColors.slate100, height: 1),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    AppText(
                      'Net Payable Salary',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColorPrimary,
                    ),
                    SizedBox(height: 2),
                    AppText(
                      '(A - B) Final Disbursement',
                      fontSize: 10,
                      color: AppColors.textColorHint,
                    ),
                  ],
                ),
                AppText(
                  '₹${_formatSalary(net.toInt())}',
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryColor,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  // ── 6. Confirmation Verification Card ──
  Widget _buildConfirmationCard() {
    return Obx(() {
      final isConfirmed = controller.confirmReviewed.value;
      final hasError = _checkboxError != null;

      return InkWell(
        onTap: () {
          controller.confirmReviewed.value = !isConfirmed;
          if (controller.confirmReviewed.value) {
            setState(() {
              _checkboxError = null;
            });
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isConfirmed
                ? AppColors.primaryColor.withValues(alpha: 0.04)
                : (hasError ? AppColors.errorColor.withValues(alpha: 0.04) : Colors.white),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isConfirmed
                  ? AppColors.primaryColor.withValues(alpha: 0.3)
                  : (hasError ? AppColors.errorColor : AppColors.slate200),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      color: isConfirmed ? AppColors.primaryColor : Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isConfirmed ? AppColors.primaryColor : AppColors.slate300,
                        width: 1.5,
                      ),
                    ),
                    child: isConfirmed
                        ? const Icon(Icons.check, size: 15, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: AppText(
                      'I have reviewed all the earnings, deductions, and payment details and confirm the salary calculation is accurate.',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColorPrimary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
              if (hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 34),
                  child: AppText(
                    _checkboxError!,
                    color: AppColors.errorColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  // ── Sticky Bottom Action Bar ──
  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: AppColors.slate200)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Left net summary
            Expanded(
              flex: 4,
              child: Obx(() {
                final net = controller.calculatedNetPayable;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppText(
                      'Total Disbursement',
                      fontSize: 11,
                      color: AppColors.textColorSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                    const SizedBox(height: 2),
                    AppText(
                      '₹${_formatSalary(net.toInt())}',
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryColor,
                    ),
                  ],
                );
              }),
            ),
            const SizedBox(width: 12),
            // Right submit button
            Expanded(
              flex: 6,
              child: Obx(() {
                final isSubmitting = controller.isSubmittingSalary.value;
                return ElevatedButton(
                  onPressed: isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            AppText(
                              'Disburse Salary',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            SizedBox(width: 6),
                            Icon(Iconsax.arrow_right_3, size: 16, color: Colors.white),
                          ],
                        ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ── Items Row Builders ──
  Widget _buildEarningItemRow(int index, SalaryLineItemController item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.slate50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Index Badge
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.successColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: AppText(
                '${index + 1}',
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.successColor,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Head Name
          Expanded(
            flex: 5,
            child: TextFormField(
              controller: item.nameController,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Head Name (e.g. Basic)',
                hintStyle: const TextStyle(fontSize: 12, color: AppColors.textColorHint),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.slate200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.slate200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.successColor, width: 1.5),
                ),
              ),
              validator: (val) => val == null || val.trim().isEmpty ? 'Enter name' : null,
            ),
          ),
          const SizedBox(width: 8),
          // Amount
          Expanded(
            flex: 4,
            child: TextFormField(
              controller: item.amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                isDense: true,
                prefixText: '₹ ',
                prefixStyle: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.successColor),
                hintText: '0',
                hintStyle: const TextStyle(fontSize: 12, color: AppColors.textColorHint),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.slate200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.slate200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.successColor, width: 1.5),
                ),
              ),
              onChanged: (_) => setState(() {}),
              validator: (val) {
                if (val == null || val.trim().isEmpty) return 'Enter amount';
                if (double.tryParse(val.trim()) == null) return 'Invalid';
                return null;
              },
            ),
          ),
          // Delete
          if (controller.formEarnings.length > 1) ...[
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Iconsax.trash, color: AppColors.errorColor, size: 18),
              visualDensity: VisualDensity.compact,
              tooltip: 'Remove',
              onPressed: () {
                controller.removeEarningItem(index);
                setState(() {});
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDeductionItemRow(int index, SalaryLineItemController item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.slate50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Index Badge
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.errorColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: AppText(
                '${index + 1}',
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.errorColor,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Head Name
          Expanded(
            flex: 5,
            child: TextFormField(
              controller: item.nameController,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Head Name (e.g. Leaves/LWP)',
                hintStyle: const TextStyle(fontSize: 12, color: AppColors.textColorHint),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.slate200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.slate200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.errorColor, width: 1.5),
                ),
              ),
              validator: (val) => val == null || val.trim().isEmpty ? 'Enter name' : null,
            ),
          ),
          const SizedBox(width: 8),
          // Amount
          Expanded(
            flex: 4,
            child: TextFormField(
              controller: item.amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                isDense: true,
                prefixText: '₹ ',
                prefixStyle: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.errorColor),
                hintText: '0',
                hintStyle: const TextStyle(fontSize: 12, color: AppColors.textColorHint),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.slate200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.slate200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.errorColor, width: 1.5),
                ),
              ),
              onChanged: (_) => setState(() {}),
              validator: (val) {
                if (val == null || val.trim().isEmpty) return 'Enter amount';
                if (double.tryParse(val.trim()) == null) return 'Invalid';
                return null;
              },
            ),
          ),
          // Delete
          if (controller.formDeductions.length > 1) ...[
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Iconsax.trash, color: AppColors.errorColor, size: 18),
              visualDensity: VisualDensity.compact,
              tooltip: 'Remove',
              onPressed: () {
                controller.removeDeductionItem(index);
                setState(() {});
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    bool isRequired = false,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            AppText(
              label,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textColorPrimary,
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            isDense: true,
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 12, color: AppColors.textColorHint),
            prefixIcon: Icon(prefixIcon, size: 17, color: AppColors.textColorSecondary),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            fillColor: AppColors.slate50,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.slate200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.slate200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.5),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildEmptySectionPlaceholder(String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            AppText(
              title,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textColorSecondary,
            ),
            const SizedBox(height: 2),
            AppText(
              subtitle,
              fontSize: 11,
              color: AppColors.textColorHint,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculationRow({
    required String label,
    required String value,
    required Color color,
    String prefix = '',
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(
          label,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textColorSecondary,
        ),
        AppText(
          '$prefix$value',
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: color,
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
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryColor,
        ),
      ),
    );
  }

  IconData _getPaymentModeIcon(String mode) {
    switch (mode.toLowerCase()) {
      case 'bank transfer':
        return Iconsax.bank;
      case 'upi':
        return Iconsax.mobile;
      case 'cheque':
        return Iconsax.document_text;
      case 'cash':
        return Iconsax.money;
      default:
        return Iconsax.card;
    }
  }

  Future<void> _selectPaymentDate() async {
    final now = DateTime.now();
    final date = controller.paymentDate.value ?? now;
    final initial = date.isAfter(now) ? now : date;
    final chosen = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              onSurface: AppColors.textColorPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (chosen != null) {
      controller.paymentDate.value = chosen;
    }
  }

  Future<void> _submitForm() async {
    setState(() {
      _modeError = controller.selectedPaymentMode.value == null ||
              controller.selectedPaymentMode.value!.trim().isEmpty
          ? 'Please select payment mode'
          : null;
      _checkboxError = !controller.confirmReviewed.value
          ? 'You must review and check details before proceeding'
          : null;
    });

    final isTextFormValid = _formKey.currentState!.validate();
    final isDropdownValid = _modeError == null && _checkboxError == null;

    if (!isTextFormValid || !isDropdownValid) {
      Get.snackbar(
        'Validation Notice',
        'Please complete all required fields and check the confirmation.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    if (controller.formEarnings.isEmpty) {
      Get.snackbar(
        'Validation Notice',
        'Please add at least one earning head (e.g. Basic salary).',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
      );
      return;
    }

    final success = await controller.submitCreateSalary();
    if (success) {
      Get.off(() => const PayslipCreatedScreen());
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
