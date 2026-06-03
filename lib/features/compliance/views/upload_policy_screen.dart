import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_input_field.dart';
import '../../../core/widgets/custom_bottom_sheet_dropdown.dart';
import '../controllers/compliance_controller.dart';

class UploadPolicyScreen extends StatefulWidget {
  const UploadPolicyScreen({super.key});

  @override
  State<UploadPolicyScreen> createState() => _UploadPolicyScreenState();
}

class _UploadPolicyScreenState extends State<UploadPolicyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _versionController = TextEditingController(text: '1.0');
  final _summaryController = TextEditingController();
  final _descriptionController = TextEditingController();

  final _selectedCategory = RxnString();
  final _selectedDate = Rxn<DateTime>();
  final _isDocumentUploading = false.obs;
  final _uploadedFileName = RxnString();
  final _uploadedFileSize = RxnString();

  String? _categoryError;
  String? _dateError;
  String? _docError;

  final List<String> categories = [
    'HR Policies',
    'Leave Policies',
    'IT & Security',
    'Work Policies'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _versionController.dispose();
    _summaryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4F46E5),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1E293B),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      _selectedDate.value = picked;
      setState(() {
        _dateError = null;
      });
    }
  }

  Future<void> _simulateDocumentPick() async {
    _isDocumentUploading.value = true;
    _docError = null;
    
    // Simulate compilation network load lag for file selection
    await Future.delayed(const Duration(milliseconds: 1200));
    
    _uploadedFileName.value = 'code_of_conduct_draft_v${_versionController.text.trim()}.pdf';
    _uploadedFileSize.value = '1.4 MB';
    _isDocumentUploading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ComplianceController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
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
          'Upload New Policy',
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Color(0xFF1E293B),
        ),
        centerTitle: false,
      ),
      body: Obx(() {
        if (controller.isPublishing.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Color(0xFF4F46E5)),
                SizedBox(height: 16),
                AppText(
                  'Publishing Policy & Notifying Employees...',
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF475569),
                ),
              ],
            ),
          );
        }

        return Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFEEF2FF)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const AppText(
                              'Policy Information',
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E293B),
                            ),
                            const SizedBox(height: 16),

                            // Policy Title
                            AppInputField(
                              controller: _titleController,
                              label: 'Policy Title *',
                              hint: 'Enter policy title',
                              isRequired: true,
                              validator: (val) => val == null || val.trim().isEmpty ? 'Please enter policy title' : null,
                            ),
                            const SizedBox(height: 16),

                            // Category Dropdown
                            const AppText(
                              'Category *',
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF475569),
                            ),
                            const SizedBox(height: 8),
                            Obx(() {
                              final category = _selectedCategory.value;
                              return CustomBottomSheetDropdown(
                                label: 'Select category',
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
                                padding: const EdgeInsets.only(top: 6, left: 4),
                                child: AppText(_categoryError!, fontSize: 11, color: AppColors.errorColor),
                              ),
                            const SizedBox(height: 16),

                            // Version Input
                            AppInputField(
                              controller: _versionController,
                              label: 'Version',
                              hint: 'e.g. 1.0',
                              isRequired: true,
                              validator: (val) => val == null || val.trim().isEmpty ? 'Please enter version' : null,
                            ),
                            const SizedBox(height: 16),

                            // Review Date selector
                            const AppText(
                              'Review Date *',
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF475569),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () => _selectDate(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: _dateError != null ? AppColors.errorColor : const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Obx(() {
                                      final date = _selectedDate.value;
                                      return AppText(
                                        date == null ? 'Select review date' : DateFormat('dd MMMM yyyy').format(date),
                                        fontSize: 13,
                                        fontWeight: date == null ? FontWeight.w500 : FontWeight.w700,
                                        color: date == null ? const Color(0xFF94A3B8) : const Color(0xFF1E293B),
                                      );
                                    }),
                                    const Icon(Iconsax.calendar, color: Color(0xFF64748B), size: 18),
                                  ],
                                ),
                              ),
                            ),
                            if (_dateError != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 6, left: 4),
                                child: AppText(_dateError!, fontSize: 11, color: AppColors.errorColor),
                              ),
                            const SizedBox(height: 24),

                            // ── Policy Document Upload ──
                            const AppText(
                              'Policy Document',
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF475569),
                            ),
                            const SizedBox(height: 8),
                            Obx(() {
                              final isUploading = _isDocumentUploading.value;
                              final fileName = _uploadedFileName.value;
                              final fileSize = _uploadedFileSize.value;

                              return Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: _docError != null 
                                        ? AppColors.errorColor 
                                        : const Color(0xFFEEF2FF),
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    if (isUploading) ...[
                                      const CircularProgressIndicator(color: Color(0xFF4F46E5)),
                                      const SizedBox(height: 12),
                                      const AppText('Reading PDF metadata...', fontSize: 11.5, color: Color(0xFF64748B)),
                                    ] else if (fileName != null) ...[
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Iconsax.document_text, color: Color(0xFFEF4444), size: 20),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                AppText(fileName, fontSize: 12.5, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B)),
                                                const SizedBox(height: 2),
                                                AppText('Size: $fileSize • Format: PDF', fontSize: 10, color: const Color(0xFF64748B)),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B), size: 18),
                                            onPressed: () {
                                              _uploadedFileName.value = null;
                                              _uploadedFileSize.value = null;
                                            },
                                          ),
                                        ],
                                      ),
                                    ] else ...[
                                      const Icon(Iconsax.document_upload, color: Color(0xFF4F46E5), size: 36),
                                      const SizedBox(height: 12),
                                      const AppText('Upload Document (PDF only)', fontSize: 12.5, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
                                      const SizedBox(height: 4),
                                      const AppText('Maximum size 10MB', fontSize: 10, color: Color(0xFF94A3B8)),
                                      const SizedBox(height: 16),
                                      ElevatedButton(
                                        onPressed: () => _simulateDocumentPick(),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF4F46E5),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                          elevation: 0,
                                        ),
                                        child: const AppText('Choose PDF File', fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white),
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            }),
                            if (_docError != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 6, left: 4),
                                child: AppText(_docError!, fontSize: 11, color: AppColors.errorColor),
                              ),
                            const SizedBox(height: 24),

                            // Policy Summary
                            AppInputField(
                              controller: _summaryController,
                              label: 'Policy Summary (Optional)',
                              hint: 'Write short summary about this policy...',
                              maxLines: 3,
                            ),
                            const SizedBox(height: 16),

                            // Policy Document Guidelines
                            AppInputField(
                              controller: _descriptionController,
                              label: 'Policy Statement / Detailed Content *',
                              hint: 'Write the complete policy terms & clauses here...',
                              maxLines: 8,
                              isRequired: true,
                              validator: (val) => val == null || val.trim().isEmpty ? 'Please write policy terms' : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Footer Buttons ──
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
                          minimumSize: const Size(0, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const AppText(
                          'Cancel',
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF4F46E5),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _submitForm(controller),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F46E5),
                          minimumSize: const Size(0, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: const AppText(
                          'Publish Policy',
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  void _submitForm(ComplianceController controller) {
    bool hasErr = false;

    if (_selectedCategory.value == null) {
      setState(() {
        _categoryError = 'Please select policy category';
      });
      hasErr = true;
    }

    if (_selectedDate.value == null) {
      setState(() {
        _dateError = 'Please select review date';
      });
      hasErr = true;
    }

    if (_uploadedFileName.value == null) {
      setState(() {
        _docError = 'Please upload document PDF';
      });
      hasErr = true;
    }

    if (_formKey.currentState!.validate() && !hasErr) {
      controller
          .publishPolicy(
        title: _titleController.text.trim(),
        category: _selectedCategory.value!,
        version: _versionController.text.trim(),
        reviewDate: _selectedDate.value!,
        summary: _summaryController.text.trim(),
        description: _descriptionController.text.trim(),
      )
          .then((success) {
        if (success) {
          Get.back();
          Get.snackbar(
            'Policy Published! 🛡️',
            'Policy has been added to catalogs and all active employees notified.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF10B981),
            colorText: Colors.white,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            borderRadius: 16,
          );
        }
      });
    }
  }
}
