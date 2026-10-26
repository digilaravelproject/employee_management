import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_validators.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_input_field.dart';
import '../../../core/widgets/custom_bottom_sheet_dropdown.dart';
import '../controllers/clients_controller.dart';

class AddEditClientScreen extends StatefulWidget {
  final bool isEditMode;
  final String? clientId;

  const AddEditClientScreen({
    super.key,
    required this.isEditMode,
    this.clientId,
  });

  @override
  State<AddEditClientScreen> createState() => _AddEditClientScreenState();
}

class _AddEditClientScreenState extends State<AddEditClientScreen> {
  final _formKey = GlobalKey<FormState>();
  late ClientsController controller;
  String? _statusError;

  @override
  void initState() {
    super.initState();
    controller = Get.find<ClientsController>();
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
        title: AppText(
          widget.isEditMode ? 'Edit Client' : 'Add Client',
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
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.slate200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Client Name
                          AppInputField(
                            controller: controller.nameController,
                            label: 'Client Name *',
                            hint: 'e.g. R K Enterprises',
                            isRequired: true,
                            validator: (val) => val == null || val.trim().isEmpty ? 'Please enter client name' : null,
                          ),
                          const SizedBox(height: 14),

                          // Email
                          AppInputField(
                            controller: controller.emailController,
                            label: 'Email *',
                            hint: 'e.g. info@client.com',
                            isRequired: true,
                            keyboardType: TextInputType.emailAddress,
                            validator: AppValidators.validateEmail,
                          ),
                          const SizedBox(height: 14),

                          // Mobile Number
                          AppInputField(
                            controller: controller.mobileController,
                            label: 'Mobile Number *',
                            hint: 'e.g. 9876543210',
                            isRequired: true,
                            keyboardType: TextInputType.phone,
                            validator: (val) => AppValidators.validateMobile(val, customMessage: 'Enter a valid 10-digit mobile number'),
                          ),
                          const SizedBox(height: 14),

                          // Website
                          AppInputField(
                            controller: controller.websiteController,
                            label: 'Website',
                            hint: 'e.g. www.client.com',
                          ),
                          const SizedBox(height: 14),

                          // Address
                          AppInputField(
                            controller: controller.addressController,
                            label: 'Address *',
                            hint: 'e.g. Suite 12, Tech Tower, Mumbai',
                            isRequired: true,
                            maxLines: 2,
                            validator: (val) => val == null || val.trim().isEmpty ? 'Please enter address' : null,
                          ),
                          const SizedBox(height: 14),

                          // Status Dropdown
                          const AppText(
                            'Status *',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColorSecondary,
                          ),
                          const SizedBox(height: 8),
                          Obx(() {
                            final status = controller.formSelectedStatus.value;
                            return CustomBottomSheetDropdown(
                              label: 'Status',
                              selectedValue: status,
                              items: controller.clientStatuses,
                              onChanged: (val) {
                                controller.formSelectedStatus.value = val;
                                setState(() {
                                  _statusError = null;
                                });
                              },
                              borderColor: _statusError != null ? AppColors.errorColor : null,
                            );
                          }),
                          if (_statusError != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 6, left: 16),
                              child: AppText(_statusError!, fontSize: 12, color: AppColors.errorColor),
                            ),
                          const SizedBox(height: 14),

                          // Notes
                          AppInputField(
                            controller: controller.notesController,
                            label: 'Notes',
                            hint: 'Enter special instructions or key client notes...',
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Symmetrical Bottom Actions
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
                        minimumSize: const Size(0, 50),
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
                    child: Obx(() {
                      final isSaving = controller.isSavingClient.value;
                      return ElevatedButton(
                        onPressed: isSaving ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          disabledBackgroundColor: AppColors.primaryColor.withValues(alpha: 0.6),
                          minimumSize: const Size(0, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : AppText(
                                widget.isEditMode ? 'Update Client' : 'Save Client',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() async {
    if (controller.formSelectedStatus.value == null) {
      setState(() {
        _statusError = 'Please select client status';
      });
    }

    if (_formKey.currentState!.validate() && _statusError == null) {
      final success = await controller.saveClient(id: widget.clientId);
      if (success && mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }
}

