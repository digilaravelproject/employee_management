import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_input_field.dart';
import '../../../core/widgets/custom_bottom_sheet_dropdown.dart';
import '../controllers/payroll_controller.dart';
import 'payslip_created_screen.dart';

class CreateSalaryFormScreen extends StatefulWidget {
  const CreateSalaryFormScreen({super.key});

  @override
  State<CreateSalaryFormScreen> createState() => _CreateSalaryFormScreenState();
}

class _CreateSalaryFormScreenState extends State<CreateSalaryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late PayrollController controller;
  
  String? _modeError;
  String? _checkboxError;

  @override
  void initState() {
    super.initState();
    controller = Get.find<PayrollController>();
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
        title: const AppText(
          'Create Salary',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textColorPrimary,
        ),
        centerTitle: false,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Employee Mini Summary Card ──
                    Obx(() {
                      final record = controller.selectedRecord.value;
                      if (record == null) return const SizedBox();
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.slate200),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.slate100),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(22),
                                child: record.profilePic != null
                                    ? Image.network(record.profilePic!, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => _buildFallbackAvatar(record.employeeName))
                                    : _buildFallbackAvatar(record.employeeName),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText(
                                    record.employeeName,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textColorPrimary,
                                  ),
                                  const SizedBox(height: 2),
                                  AppText(
                                    '${record.employeeId} - ${record.department}',
                                    fontSize: 11,
                                    color: AppColors.textColorSecondary,
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const AppText(
                                  'Net Payable',
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textColorHint,
                                ),
                                const SizedBox(height: 2),
                                AppText(
                                  '₹${_formatSalary(record.netPayable.toInt())}',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primaryColor,
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 20),

                    // ── Payment Details Form Card ──
                    _buildSectionTitle('PAYMENT DETAILS'),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.slate200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Salary Month
                          Obx(() {
                            return AppInputField(
                              hint: 'e.g. May 2024',
                              label: 'Salary Month',
                              readOnly: true,
                              enabled: false,
                              controller: TextEditingController(text: controller.selectedMonth.value),
                            );
                          }),
                          const SizedBox(height: 14),

                          // Payment Date
                          Obx(() {
                            final date = controller.paymentDate.value;
                            final text = date != null ? DateFormat('dd MMMM yyyy').format(date) : '';
                            return AppInputField(
                              label: 'Payment Date *',
                              hint: 'Select Date',
                              readOnly: true,
                              controller: TextEditingController(text: text),
                              suffixIcon: const Icon(Iconsax.calendar_1, color: AppColors.textColorSecondary),
                              validator: (val) => val == null || val.trim().isEmpty ? 'Please select payment date' : null,
                              onTap: () async {
                                final chosen = await showDatePicker(
                                  context: context,
                                  initialDate: date ?? DateTime.now(),
                                  firstDate: DateTime.now().subtract(const Duration(days: 30)),
                                  lastDate: DateTime.now().add(const Duration(days: 365)),
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
                              },
                            );
                          }),
                          const SizedBox(height: 14),

                          // Payment Mode dropdown
                          const AppText(
                            'Payment Mode *',
                            style: AppTextStyle.body,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColorPrimary,
                          ),
                          const SizedBox(height: 6),
                          Obx(() {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomBottomSheetDropdown(
                                  label: 'Payment Mode',
                                  selectedValue: controller.selectedPaymentMode.value,
                                  items: controller.paymentModes,
                                  borderColor: _modeError != null ? AppColors.errorColor : null,
                                  onChanged: (val) {
                                    controller.selectedPaymentMode.value = val;
                                    setState(() {
                                      _modeError = null;
                                    });
                                  },
                                ),
                                if (_modeError != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4, left: 4),
                                    child: AppText(
                                      _modeError!,
                                      color: AppColors.errorColor,
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            );
                          }),
                          const SizedBox(height: 14),

                          // Bank Name
                          AppInputField(
                            controller: controller.bankNameController,
                            label: 'Bank Name *',
                            hint: 'e.g. HDFC Bank',
                            isRequired: true,
                            validator: (val) => val == null || val.trim().isEmpty ? 'Please enter bank name' : null,
                          ),
                          const SizedBox(height: 14),

                          // Account number
                          AppInputField(
                            controller: controller.accountController,
                            label: 'Account / UPI Address *',
                            hint: 'e.g. XXXX XXXX XXXX 1234',
                            isRequired: true,
                            validator: (val) => val == null || val.trim().isEmpty ? 'Please enter account or UPI ID' : null,
                          ),
                          const SizedBox(height: 14),

                          // Remarks
                          AppInputField(
                            controller: controller.remarksController,
                            label: 'Remarks (Optional)',
                            hint: 'e.g. Processed successfully...',
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Summary Math Card ──
                    Obx(() {
                      final record = controller.selectedRecord.value;
                      if (record == null) return const SizedBox();
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.slate200),
                        ),
                        child: Column(
                          children: [
                            _buildSummaryMathRow('Gross Earnings', '₹${_formatSalary(record.grossEarnings.toInt())}'),
                            const SizedBox(height: 8),
                            _buildSummaryMathRow('Total Deductions', '₹${_formatSalary(record.totalDeductions.toInt())}', isNegative: true),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.0),
                              child: Divider(color: AppColors.slate100),
                            ),
                            _buildSummaryMathRow('Net Payable Salary', '₹${_formatSalary(record.netPayable.toInt())}', isBold: true),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 20),

                    // ── Review Checkbox ──
                    Obx(() {
                      final hasError = _checkboxError != null;
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: hasError ? AppColors.errorColor.withValues(alpha: 0.04) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: hasError ? AppColors.errorColor : Colors.transparent),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: Checkbox(
                                    activeColor: AppColors.primaryColor,
                                    value: controller.confirmReviewed.value,
                                    onChanged: (val) {
                                      controller.confirmReviewed.value = val ?? false;
                                      if (val == true) {
                                        setState(() {
                                          _checkboxError = null;
                                        });
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Expanded(
                                  child: AppText(
                                    'I have reviewed all the details and confirm the salary is correct.',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textColorPrimary,
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
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ── Symmetrical Bottom Footer Buttons ──
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.slate200)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primaryColor, width: 1.5),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const AppText(
                        'Cancel',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const AppText(
                        'Create Salary',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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

  Widget _buildSummaryMathRow(String label, String value, {bool isBold = false, bool isNegative = false}) {
    Color valColor = AppColors.textColorPrimary;
    if (isNegative) valColor = AppColors.errorColor;
    if (isBold) valColor = AppColors.primaryColor;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(
          label,
          fontSize: isBold ? 14 : 13,
          fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          color: AppColors.textColorPrimary,
        ),
        AppText(
          value,
          fontSize: isBold ? 16 : 13,
          fontWeight: FontWeight.w900,
          color: valColor,
        ),
      ],
    );
  }

  Widget _buildFallbackAvatar(String name) {
    return Container(
      color: AppColors.primaryColor.withValues(alpha: 0.1),
      child: Center(
        child: AppText(
          name.substring(0, 1).toUpperCase(),
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryColor,
        ),
      ),
    );
  }

  void _submitForm() {
    setState(() {
      _modeError = controller.selectedPaymentMode.value == null || controller.selectedPaymentMode.value!.trim().isEmpty
          ? 'Please select payment mode'
          : null;
      _checkboxError = !controller.confirmReviewed.value
          ? 'You must review and check details before proceeding'
          : null;
    });

    final isTextFormValid = _formKey.currentState!.validate();
    final isDropdownValid = _modeError == null && _checkboxError == null;

    if (isTextFormValid && isDropdownValid) {
      controller.processCreateSalary();
      // Replace with success screen
      Get.off(() => const PayslipCreatedScreen());
    } else {
      Get.snackbar(
        'Validation Failure',
        'Please correct the flagged input errors in the form.',
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
