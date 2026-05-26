import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_input_field.dart';
import '../../../core/widgets/custom_bottom_sheet_dropdown.dart';
import '../controllers/hr_controller.dart';
import '../models/hr_models.dart';

class AddPolicyScreen extends StatefulWidget {
  const AddPolicyScreen({super.key});

  @override
  State<AddPolicyScreen> createState() => _AddPolicyScreenState();
}

class _AddPolicyScreenState extends State<AddPolicyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  
  final _selectedCategory = RxnString();
  String? _categoryError;

  final List<String> categories = [
    'HR Policies',
    'Work Policies',
    'Leave Policies'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HrController>();

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
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textColorPrimary, size: 18),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        title: const AppText(
          'Add New Policy',
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
                          // Policy Title
                          AppInputField(
                            controller: _titleController,
                            label: 'Policy Title *',
                            hint: 'e.g. Work From Home Policy',
                            isRequired: true,
                            validator: (val) => val == null || val.trim().isEmpty ? 'Please enter policy title' : null,
                          ),
                          const SizedBox(height: 16),

                          // Category Dropdown
                          const AppText(
                            'Policy Category *',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColorSecondary,
                          ),
                          const SizedBox(height: 8),
                          Obx(() {
                            final category = _selectedCategory.value;
                            return CustomBottomSheetDropdown(
                              label: 'Category',
                              selectedValue: category,
                              items: categories,
                              onChanged: (val) {
                                _selectedCategory.value = val;
                                setState(() {
                                  _categoryError = null;
                                });
                              },
                              borderColor: _categoryError != null ? AppColors.errorColor : null,
                            );
                          }),
                          if (_categoryError != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 6, left: 16),
                              child: AppText(_categoryError!, fontSize: 12, color: AppColors.errorColor),
                            ),
                          const SizedBox(height: 16),

                          // Policy Description / Document
                          AppInputField(
                            controller: _descController,
                            label: 'Policy Description / Document *',
                            hint: 'Write policy guidelines here...',
                            maxLines: 8,
                            isRequired: true,
                            validator: (val) => val == null || val.trim().isEmpty ? 'Please write policy description' : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Symmetrical footer buttons
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
                      onPressed: () => _submitForm(controller),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        minimumSize: const Size(0, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const AppText(
                        'Save Policy',
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

  void _submitForm(HrController controller) {
    if (_selectedCategory.value == null) {
      setState(() {
        _categoryError = 'Please select policy category';
      });
    }

    if (_formKey.currentState!.validate() && _categoryError == null) {
      final newPol = CompanyPolicy(
        id: 'pol_${DateTime.now().millisecondsSinceEpoch}',
        title: _titleController.text.trim(),
        type: _selectedCategory.value!,
        updatedDate: DateTime.now(),
        description: _descController.text.trim(),
      );
      
      controller.addPolicy(newPol);
      Get.back();
    }
  }
}
