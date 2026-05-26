import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_input_field.dart';
import '../../../core/widgets/custom_bottom_sheet_dropdown.dart';
import '../controllers/leads_controller.dart';

class AddEditLeadScreen extends StatefulWidget {
  final bool isEditMode;
  final String? leadId;

  const AddEditLeadScreen({
    super.key,
    required this.isEditMode,
    this.leadId,
  });

  @override
  State<AddEditLeadScreen> createState() => _AddEditLeadScreenState();
}

class _AddEditLeadScreenState extends State<AddEditLeadScreen> {
  final _formKey = GlobalKey<FormState>();
  late LeadsController controller;
  String? _sourceError;
  String? _statusError;
  String? _assigneeError;

  @override
  void initState() {
    super.initState();
    controller = Get.find<LeadsController>();
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
          widget.isEditMode ? 'Edit Lead' : 'Add / Edit Lead',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textColorPrimary,
        ),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: _submitForm,
            child: const AppText(
              'Save',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  children: [
                    // ── Basic Information Section ──
                    _buildSectionHeader('Basic Information'),
                    const SizedBox(height: 10),
                    _buildBasicInfoCard(),
                    const SizedBox(height: 20),

                    // ── Lead Information Section ──
                    _buildSectionHeader('Lead Information'),
                    const SizedBox(height: 10),
                    _buildLeadInfoCard(),
                    const SizedBox(height: 20),

                    // ── Additional Information Section ──
                    _buildSectionHeader('Additional Information'),
                    const SizedBox(height: 10),
                    _buildAdditionalInfoCard(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // ── Symmetrical Bottom Footer Buttons ──
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: AppText(
        title,
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: AppColors.indigo500, // Violet indigo matching mockup title headers
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        children: [
          AppInputField(
            controller: controller.nameController,
            label: 'Full Name *',
            hint: 'e.g. Rohan Mehta',
            isRequired: true,
            validator: (val) => val == null || val.trim().isEmpty ? 'Please enter lead name' : null,
          ),
          const SizedBox(height: 14),
          AppInputField(
            controller: controller.companyController,
            label: 'Company Name',
            hint: 'e.g. Mehta Enterprises',
          ),
          const SizedBox(height: 14),
          AppInputField(
            controller: controller.emailController,
            label: 'Email',
            hint: 'e.g. rohan.mehta@mehta.com',
            keyboardType: TextInputType.emailAddress,
            validator: (val) {
              if (val != null && val.trim().isNotEmpty) {
                final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                if (!regex.hasMatch(val.trim())) {
                  return 'Please enter a valid email address';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          AppInputField(
            controller: controller.mobileController,
            label: 'Mobile Number *',
            hint: 'e.g. +91 98765 43210',
            keyboardType: TextInputType.phone,
            isRequired: true,
            validator: (val) => val == null || val.trim().isEmpty ? 'Please enter mobile number' : null,
          ),
          const SizedBox(height: 14),
          AppInputField(
            controller: controller.designationController,
            label: 'Designation',
            hint: 'e.g. Proprietor',
          ),
        ],
      ),
    );
  }

  Widget _buildLeadInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText(
            'Lead Source *',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textColorPrimary,
          ),
          const SizedBox(height: 6),
          Obx(() {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomBottomSheetDropdown(
                  label: 'Lead Source',
                  selectedValue: controller.selectedSource.value,
                  items: controller.leadSources,
                  borderColor: _sourceError != null ? AppColors.errorColor : null,
                  onChanged: (val) {
                    controller.selectedSource.value = val;
                    setState(() {
                      _sourceError = null;
                    });
                  },
                ),
                if (_sourceError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 4),
                    child: AppText(
                      _sourceError!,
                      color: AppColors.errorColor,
                      fontSize: 12,
                    ),
                  ),
              ],
            );
          }),
          const SizedBox(height: 16),
          const AppText(
            'Lead Status *',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textColorPrimary,
          ),
          const SizedBox(height: 6),
          Obx(() {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomBottomSheetDropdown(
                  label: 'Lead Status',
                  selectedValue: controller.selectedStatus.value,
                  items: controller.leadStatuses,
                  borderColor: _statusError != null ? AppColors.errorColor : null,
                  onChanged: (val) {
                    controller.selectedStatus.value = val;
                    setState(() {
                      _statusError = null;
                    });
                  },
                ),
                if (_statusError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 4),
                    child: AppText(
                      _statusError!,
                      color: AppColors.errorColor,
                      fontSize: 12,
                    ),
                  ),
              ],
            );
          }),
          const SizedBox(height: 16),
          const AppText(
            'Assign to *',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textColorPrimary,
          ),
          const SizedBox(height: 6),
          Obx(() {
            final assignee = controller.selectedAssignee.value;
            final hasError = _assigneeError != null;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: _showAssigneePicker,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.slate50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: hasError ? AppColors.errorColor : AppColors.slate200),
                    ),
                    child: Row(
                      children: [
                        if (assignee != null) ...[
                          CircleAvatar(
                            radius: 12,
                            backgroundImage: NetworkImage(assignee.avatarUrl),
                          ),
                          const SizedBox(width: 10),
                          AppText(
                            assignee.name,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColorPrimary,
                          ),
                        ] else ...[
                          const AppText(
                            'Select Sales Representative',
                            fontSize: 14,
                            color: AppColors.textColorHint,
                          ),
                        ],
                        const Spacer(),
                        const Icon(Icons.keyboard_arrow_down, color: AppColors.textColorSecondary),
                      ],
                    ),
                  ),
                ),
                if (hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 4),
                    child: AppText(
                      _assigneeError!,
                      color: AppColors.errorColor,
                      fontSize: 12,
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        children: [
          AppInputField(
            controller: controller.locationController,
            label: 'Location',
            hint: 'e.g. Mumbai, Maharashtra',
            suffixIcon: const Icon(Icons.location_on_outlined, color: AppColors.textColorSecondary),
          ),
          const SizedBox(height: 14),
          AppInputField(
            controller: controller.estimatedValueController,
            label: 'Estimated Value',
            hint: 'e.g. 2,50,000',
            keyboardType: TextInputType.number,
            prefix: const Padding(
              padding: EdgeInsets.only(right: 6, left: 14),
              child: AppText('₹ ', fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
            ),
            validator: (val) {
              if (val != null && val.trim().isNotEmpty) {
                final sanitized = val.trim().replaceAll(',', '').replaceAll(' ', '');
                final parsed = double.tryParse(sanitized);
                if (parsed == null) {
                  return 'Please enter a valid amount';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          Obx(() {
            final date = controller.expectedClosingDate.value;
            final text = date != null ? DateFormat('dd MMMM yyyy').format(date) : '';
            return AppInputField(
              label: 'Expected Closing Date',
              hint: 'Select Date',
              readOnly: true,
              controller: TextEditingController(text: text),
              suffixIcon: const Icon(Iconsax.calendar_1, color: AppColors.textColorSecondary),
              onTap: () async {
                final chosen = await showDatePicker(
                  context: context,
                  initialDate: date ?? DateTime.now(),
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
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
                  controller.expectedClosingDate.value = chosen;
                }
              },
            );
          }),
          const SizedBox(height: 14),
          AppInputField(
            controller: controller.notesController,
            label: 'Notes',
            hint: 'Interested in our premium product...',
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
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
                'Save Lead',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAssigneePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.only(top: 12, bottom: 24),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.5,
          ),
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const AppText('Select Representative', fontSize: 16, fontWeight: FontWeight.bold),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textColorSecondary),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
              ),
              const Divider(color: AppColors.slate200),
              Expanded(
                child: ListView.builder(
                  itemCount: controller.salesReps.length,
                  itemBuilder: (context, index) {
                    final rep = controller.salesReps[index];
                    final isSelected = controller.selectedAssignee.value?.email == rep.email;

                    return InkWell(
                      onTap: () {
                        controller.selectedAssignee.value = rep;
                        setState(() {
                          _assigneeError = null;
                        });
                        Get.back();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        color: isSelected ? AppColors.primaryLight : Colors.transparent,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundImage: NetworkImage(rep.avatarUrl),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText(
                                    rep.name,
                                    fontSize: 14,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                    color: AppColors.textColorPrimary,
                                  ),
                                  AppText(
                                    rep.email,
                                    fontSize: 12,
                                    color: AppColors.textColorSecondary,
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(Iconsax.tick_circle, color: AppColors.primaryColor, size: 20),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _submitForm() {
    setState(() {
      _sourceError = controller.selectedSource.value == null || controller.selectedSource.value!.trim().isEmpty
          ? 'Please select lead source'
          : null;
      _statusError = controller.selectedStatus.value == null || controller.selectedStatus.value!.trim().isEmpty
          ? 'Please select lead status'
          : null;
      _assigneeError = controller.selectedAssignee.value == null
          ? 'Please select sales representative'
          : null;
    });

    final isTextFormValid = _formKey.currentState!.validate();
    final isDropdownValid = _sourceError == null && _statusError == null && _assigneeError == null;

    if (isTextFormValid && isDropdownValid) {
      controller.saveLead(id: widget.isEditMode ? widget.leadId : null);
      Get.back(); // Pop Add/Edit view and return to previous screen
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
}
