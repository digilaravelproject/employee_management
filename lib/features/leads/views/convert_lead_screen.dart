import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_input_field.dart';
import '../controllers/leads_controller.dart';
import '../models/lead_model.dart';
import 'leads_dashboard_shell.dart';

class ConvertLeadScreen extends StatefulWidget {
  final Lead lead;
  const ConvertLeadScreen({super.key, required this.lead});

  @override
  State<ConvertLeadScreen> createState() => _ConvertLeadScreenState();
}

class _ConvertLeadScreenState extends State<ConvertLeadScreen> {
  final _formKey = GlobalKey<FormState>();
  late LeadsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<LeadsController>();
    
    // Symmetrical pre-populating controllers
    controller.conversionCompanyController.text = widget.lead.companyName;
    controller.conversionValueController.text = widget.lead.estimatedValue.toInt().toString();
    controller.conversionNotesController.text = 'Converted after productive product demo.';
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
          'Convert Lead',
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
                    // ── 1. Mini Client summary card ──
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.slate200),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primaryColor.withValues(alpha: 0.1),
                                  AppColors.indigo500.withValues(alpha: 0.1),
                                ],
                              ),
                            ),
                            child: Center(
                              child: AppText(
                                widget.lead.name.substring(0, 2).toUpperCase(),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(
                                  widget.lead.name,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textColorPrimary,
                                ),
                                const SizedBox(height: 2),
                                AppText(
                                  widget.lead.mobile,
                                  fontSize: 12,
                                  color: AppColors.textColorSecondary,
                                ),
                                const SizedBox(height: 2),
                                AppText(
                                  widget.lead.email,
                                  fontSize: 11,
                                  color: AppColors.textColorHint,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── 2. Conversion details form fields ──
                    const AppText(
                      'Conversion Details',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColorHint,
                      letterSpacing: 0.8,
                    ),
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
                          // Customer Name
                          AppInputField(
                            hint: widget.lead.name,
                            label: 'Customer Name *',
                            readOnly: true,
                            enabled: false,
                            controller: TextEditingController(text: widget.lead.name),
                          ),
                          const SizedBox(height: 14),

                          // Company Name
                          AppInputField(
                            controller: controller.conversionCompanyController,
                            label: 'Company Name',
                            hint: 'e.g. R K Enterprises',
                          ),
                          const SizedBox(height: 14),

                          // Deal value
                          AppInputField(
                            controller: controller.conversionValueController,
                            label: 'Deal Value (₹) *',
                            hint: 'e.g. 50,000',
                            keyboardType: TextInputType.number,
                            prefix: const Padding(
                              padding: EdgeInsets.only(right: 6, left: 14),
                              child: AppText('₹ ', fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
                            ),
                            isRequired: true,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please enter deal value';
                              }
                              final sanitized = val.replaceAll(',', '').replaceAll(' ', '');
                              final parsed = double.tryParse(sanitized);
                              if (parsed == null) {
                                return 'Please enter a valid amount';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // Conversion notes
                          AppInputField(
                            controller: controller.conversionNotesController,
                            label: 'Conversion Notes',
                            hint: 'Conversion comments...',
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ── Symmetrical Button Footer ──
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.slate200)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitConversion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const AppText(
                    'Convert to Customer',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitConversion() {
    if (_formKey.currentState!.validate()) {
      final valStr = controller.conversionValueController.text.trim().replaceAll(',', '').replaceAll(' ', '');
      final valDouble = double.parse(valStr);
      final companyStr = controller.conversionCompanyController.text.trim();
      final notesStr = controller.conversionNotesController.text.trim();

      controller.processLeadConversion(
        widget.lead.id,
        valDouble,
        companyStr,
        notesStr,
      );

      // Navigate to Leads main shell and switch to Customers Tab!
      controller.currentTabIdx.value = 2; // Switch to Converted Customers tab!
      Get.offAll(() => const LeadsDashboardShell());
    } else {
      Get.snackbar(
        'Validation Failure',
        'Please enter a valid deal value to complete conversion.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
      );
    }
  }
}
