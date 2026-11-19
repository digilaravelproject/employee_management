import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_input_field.dart';
import '../../../core/widgets/custom_bottom_sheet_dropdown.dart';
import '../controllers/clients_controller.dart';

class AssignProjectScreen extends StatefulWidget {
  final String clientId;
  const AssignProjectScreen({super.key, required this.clientId});

  @override
  State<AssignProjectScreen> createState() => _AssignProjectScreenState();
}

class _AssignProjectScreenState extends State<AssignProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  late ClientsController controller;
  String? _statusError;

  @override
  void initState() {
    super.initState();
    controller = Get.find<ClientsController>();
    controller.clearProjectForm();
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
          'Add Project',
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
                          // Project Name
                          AppInputField(
                            controller: controller.projectNameController,
                            label: 'Project Name *',
                            hint: 'e.g. CRM Software Development',
                            isRequired: true,
                            validator: (val) => val == null || val.trim().isEmpty ? 'Please enter project name' : null,
                          ),
                          const SizedBox(height: 14),

                          // Category
                          const AppText('Category *', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textColorSecondary),
                          const SizedBox(height: 8),
                          Obx(() {
                            final cat = controller.projectSelectedCategory.value ?? controller.projectCategories[0];
                            return CustomBottomSheetDropdown(
                              label: 'Category',
                              selectedValue: cat,
                              items: controller.projectCategories,
                              onChanged: (val) {
                                controller.projectSelectedCategory.value = val;
                              },
                            );
                          }),
                          const SizedBox(height: 14),

                          // Description
                          AppInputField(
                            controller: controller.projectDescController,
                            label: 'Description',
                            hint: 'Develop a custom CRM software as per their business process.',
                            maxLines: 3,
                          ),
                          const SizedBox(height: 14),

                          // Start Date
                          const AppText('Start Date *', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textColorSecondary),
                          const SizedBox(height: 8),
                          Obx(() {
                            final date = controller.projectStartDate.value;
                            return _buildDatePicker(
                              context,
                              value: date,
                              hint: 'Select Start Date',
                              onTap: () async {
                                final selected = await showDatePicker(
                                  context: context,
                                  initialDate: date ?? DateTime.now(),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2030),
                                );
                                if (selected != null) {
                                  controller.projectStartDate.value = selected;
                                }
                              },
                            );
                          }),
                          const SizedBox(height: 14),

                          // End Date
                          const AppText('End Date *', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textColorSecondary),
                          const SizedBox(height: 8),
                          Obx(() {
                            final date = controller.projectDueDate.value;
                            return _buildDatePicker(
                              context,
                              value: date,
                              hint: 'Select End Date',
                              onTap: () async {
                                final selected = await showDatePicker(
                                  context: context,
                                  initialDate: date ?? DateTime.now().add(const Duration(days: 90)),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2030),
                                );
                                if (selected != null) {
                                  controller.projectDueDate.value = selected;
                                }
                              },
                            );
                          }),
                          const SizedBox(height: 14),

                          // Estimated Value (₹)
                          AppInputField(
                            controller: controller.projectValueController,
                            label: 'Estimated Value (₹) *',
                            hint: 'e.g. 5,50,000',
                            keyboardType: TextInputType.number,
                            isRequired: true,
                            prefix: const Padding(
                              padding: EdgeInsets.only(right: 6, left: 14),
                              child: AppText('₹ ', fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please enter estimated value';
                              }
                              if (double.tryParse(val.replaceAll(',', '').replaceAll(' ', '')) == null) {
                                return 'Please enter a valid amount';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // Status Dropdown
                          const AppText('Status *', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textColorSecondary),
                          const SizedBox(height: 8),
                          Obx(() {
                            final status = controller.projectSelectedStatus.value;
                            return CustomBottomSheetDropdown(
                              label: 'Status',
                              selectedValue: status,
                              items: controller.projectStatuses,
                              onChanged: (val) {
                                controller.projectSelectedStatus.value = val;
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
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Buttons
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                      final isSubmitting = controller.isSubmittingProject.value;
                      return ElevatedButton(
                        onPressed: isSubmitting ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          minimumSize: const Size(0, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: isSubmitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const AppText(
                                'Add Project',
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

  Widget _buildDatePicker(
    BuildContext context, {
    required DateTime? value,
    required String hint,
    required VoidCallback onTap,
  }) {
    final text = value != null ? DateFormat('dd MMMM yyyy').format(value) : hint;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.slate50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.slate200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppText(
              text,
              fontSize: 14,
              fontWeight: value != null ? FontWeight.bold : FontWeight.w600,
              color: value != null ? AppColors.textColorPrimary : AppColors.textColorHint,
            ),
            const Icon(Iconsax.calendar, color: AppColors.textColorHint, size: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (controller.projectSelectedStatus.value == null) {
      setState(() {
        _statusError = 'Please select status';
      });
    }

    if (_formKey.currentState!.validate() && _statusError == null) {
      final success = await controller.saveProject(widget.clientId);
      if (success) {
        Get.back(result: true);
      }
    }
  }
}
