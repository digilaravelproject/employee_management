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
  String? _managerError;
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
        title: const AppText(
          'Assign Project',
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

                          // Due Date
                          const AppText('Due Date *', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textColorSecondary),
                          const SizedBox(height: 8),
                          Obx(() {
                            final date = controller.projectDueDate.value;
                            return _buildDatePicker(
                              context,
                              value: date,
                              hint: 'Select Due Date',
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

                          // Project Manager Dropdown
                          const AppText('Project Manager *', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textColorSecondary),
                          const SizedBox(height: 8),
                          Obx(() {
                            final manager = controller.projectSelectedManager.value;
                            return CustomBottomSheetDropdown(
                              label: 'Project Manager',
                              selectedValue: manager?.name,
                              items: controller.projectManagers.map((m) => m.name).toList(),
                              onChanged: (name) {
                                final selected = controller.projectManagers.firstWhere((m) => m.name == name);
                                controller.projectSelectedManager.value = selected;
                                setState(() {
                                  _managerError = null;
                                });
                              },
                              borderColor: _managerError != null ? AppColors.errorColor : null,
                            );
                          }),
                          if (_managerError != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 6, left: 16),
                              child: AppText(_managerError!, fontSize: 12, color: AppColors.errorColor),
                            ),
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
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        minimumSize: const Size(0, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: const AppText(
                        'Save Project',
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

  void _submitForm() {
    if (controller.projectSelectedManager.value == null) {
      setState(() {
        _managerError = 'Please select a project manager';
      });
    }
    if (controller.projectSelectedStatus.value == null) {
      setState(() {
        _statusError = 'Please select status';
      });
    }

    if (_formKey.currentState!.validate() && _managerError == null && _statusError == null) {
      controller.saveProject(widget.clientId);
      Get.back();
    }
  }
}
