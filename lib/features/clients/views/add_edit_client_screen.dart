import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
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
        actions: [
          if (widget.isEditMode)
            IconButton(
              icon: const Icon(Iconsax.trash, color: AppColors.errorColor),
              onPressed: _confirmDelete,
            ),
        ],
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
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please enter email address';
                              }
                              final reg = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                              if (!reg.hasMatch(val.trim())) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // Mobile Number
                          AppInputField(
                            controller: controller.mobileController,
                            label: 'Mobile Number *',
                            hint: 'e.g. 98765 43210',
                            isRequired: true,
                            keyboardType: TextInputType.phone,
                            validator: (val) => val == null || val.trim().isEmpty ? 'Please enter mobile number' : null,
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
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        minimumSize: const Size(0, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: AppText(
                        widget.isEditMode ? 'Update Client' : 'Save Client',
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

  void _submitForm() {
    if (controller.formSelectedStatus.value == null) {
      setState(() {
        _statusError = 'Please select client status';
      });
    }

    if (_formKey.currentState!.validate() && _statusError == null) {
      controller.saveClient(id: widget.clientId);
      Get.back();
    }
  }

  void _confirmDelete() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const AppText('Delete Client', fontSize: 16, fontWeight: FontWeight.bold),
        content: const AppText('Are you sure you want to permanently delete this client? All projects and log history will be removed.', fontSize: 13, color: AppColors.textColorSecondary),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const AppText('Cancel', fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorHint),
          ),
          ElevatedButton(
            onPressed: () {
              if (widget.clientId != null) {
                controller.deleteClient(widget.clientId!);
                Get.close(2); // close dialog and edit screen!
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const AppText('Delete', fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
