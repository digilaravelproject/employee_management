import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../bindings/admin_leads_hub_binding.dart';
import '../controllers/admin_leads_hub_controller.dart';
import '../controllers/admin_lead_sources_controller.dart';
import '../controllers/admin_lead_statuses_controller.dart';
import '../models/admin_leads_request_model.dart';
import '../models/admin_leads_response_model.dart';
import '../models/sales_employee_model.dart';
import '../repositories/admin_leads_repository_interface.dart';

class SalesExecutiveCreateLeadScreen extends StatefulWidget {
  const SalesExecutiveCreateLeadScreen({super.key});

  @override
  State<SalesExecutiveCreateLeadScreen> createState() => _SalesExecutiveCreateLeadScreenState();
}

class _SalesExecutiveCreateLeadScreenState extends State<SalesExecutiveCreateLeadScreen> {
  // Common styles
  final Color _sectionTitleColor = AppColors.primaryColor;
  final Color _labelColor = const Color(0xFF1E293B);
  final Color _hintColor = const Color(0xFF94A3B8);
  final Color _borderColor = const Color(0xFFE2E8F0);
  final Color _bgColor = const Color(0xFFF8FAFC);

  // Form Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _designationController = TextEditingController();
  final TextEditingController _requirementController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _estimatedValueController = TextEditingController();
  final TextEditingController _closingDateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DateTime? _selectedClosingDate;

  // Dropdown States - 'Referral' as the very first default option
  String? _selectedSource = 'Referral';
  String? _selectedStatus = 'Interested';
  SalesEmployeeModel? _selectedSalesEmployee;

  // Sales Employees list from API
  List<SalesEmployeeModel> _salesEmployees = [];
  bool _isLoadingEmployees = false;
  bool _isSubmitting = false;

  List<String> get _sourceOptions {
    if (Get.isRegistered<AdminLeadSourcesController>()) {
      final list = Get.find<AdminLeadSourcesController>()
          .leadSources
          .map((s) => s.name)
          .where((n) => n.isNotEmpty)
          .toList();
      if (list.isNotEmpty) return list;
    }
    return [];
  }

  List<String> get _statusOptions {
    if (Get.isRegistered<AdminLeadStatusesController>()) {
      final list = Get.find<AdminLeadStatusesController>()
          .leadStatuses
          .map((s) => s.name)
          .where((n) => n.isNotEmpty)
          .toList();
      if (list.isNotEmpty) return list;
    }
    return [];
  }

  @override
  void initState() {
    super.initState();
    AdminLeadsHubBinding().dependencies();
    final sourcesCtrl = AdminLeadSourcesController.to;
    if (sourcesCtrl.leadSources.isEmpty) {
      sourcesCtrl.fetchLeadSources();
    }
    final statusesCtrl = AdminLeadStatusesController.to;
    if (statusesCtrl.leadStatuses.isEmpty) {
      statusesCtrl.fetchLeadStatuses();
    }
    _loadSalesEmployees();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _designationController.dispose();
    _requirementController.dispose();
    _locationController.dispose();
    _estimatedValueController.dispose();
    _closingDateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadSalesEmployees() async {
    // 1. Try from controller if already loaded
    if (Get.isRegistered<AdminLeadsHubController>()) {
      final ctrl = Get.find<AdminLeadsHubController>();
      if (ctrl.salesEmployees.isNotEmpty) {
        setState(() {
          _salesEmployees = ctrl.salesEmployees.toList();
          _selectedSalesEmployee = _salesEmployees.first;
        });
        return;
      }
    }

    // 2. Fetch from repository
    setState(() => _isLoadingEmployees = true);
    try {
      if (Get.isRegistered<AdminLeadsRepositoryInterface>()) {
        final repo = Get.find<AdminLeadsRepositoryInterface>();
        final response = await repo.getSalesEmployees();
        if (response.status && response.data.isNotEmpty) {
          if (mounted) {
            setState(() {
              _salesEmployees = response.data;
              _selectedSalesEmployee = _salesEmployees.first;
            });
            // Also sync controller
            if (Get.isRegistered<AdminLeadsHubController>()) {
              Get.find<AdminLeadsHubController>().salesEmployees.assignAll(response.data);
            }
          }
        }
      }
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() => _isLoadingEmployees = false);
      }
    }
  }

  Future<void> _selectClosingDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedClosingDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              onSurface: const Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      _selectedClosingDate = picked;
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      setState(() {
        _closingDateController.text = '${picked.day} ${months[picked.month - 1]} ${picked.year}';
      });
    }
  }

  Future<void> _submitForm() async {
    final name = _nameController.text.trim();
    final phone = _mobileController.text.trim();

    if (name.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please enter the full name',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    if (phone.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please enter the mobile number',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final request = CreateAdminLeadRequestModel(
        fullName: name,
        companyName: _companyController.text.trim().isNotEmpty ? _companyController.text.trim() : null,
        email: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
        mobileNumber: phone,
        designation: _designationController.text.trim().isNotEmpty ? _designationController.text.trim() : null,
        leadSource: _selectedSource,
        leadStatus: _selectedStatus,
        assignTo: _selectedSalesEmployee?.id,
        requirement: _requirementController.text.trim().isNotEmpty ? _requirementController.text.trim() : null,
        location: _locationController.text.trim().isNotEmpty ? _locationController.text.trim() : null,
        estimatedValue: _estimatedValueController.text.trim().isNotEmpty
            ? double.tryParse(_estimatedValueController.text.replaceAll(',', '').trim())
            : null,
        expectedClosingDate: _selectedClosingDate != null
            ? '${_selectedClosingDate!.year}-${_selectedClosingDate!.month.toString().padLeft(2, '0')}-${_selectedClosingDate!.day.toString().padLeft(2, '0')}'
            : null,
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      );

      AdminLeadDetailResponseModel response;
      if (Get.isRegistered<AdminLeadsHubController>()) {
        response = await Get.find<AdminLeadsHubController>().createLead(request);
      } else if (Get.isRegistered<AdminLeadsRepositoryInterface>()) {
        final repo = Get.find<AdminLeadsRepositoryInterface>();
        response = await repo.createAdminLead(request);
      } else {
        response = AdminLeadDetailResponseModel(status: false, message: 'Controller not initialized');
      }

      if (response.status) {
        Get.back();
        Get.snackbar(
          'Lead Created Successfully 🎯',
          response.message.isNotEmpty
              ? response.message
              : 'Lead ${response.data?.displayLeadCode ?? ''} created successfully.',
          backgroundColor: const Color(0xFF16A34A),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
      } else {
        Get.snackbar(
          'Creation Failed',
          response.message.isNotEmpty ? response.message : 'Failed to create lead',
          backgroundColor: const Color(0xFFEF4444),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: _bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 18),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        title: const AppText(
          'Add / Edit Lead',
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: Color(0xFF0F172A),
        ),
        centerTitle: false,
        actions: [
          if (_isSubmitting)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _submitForm,
              child: AppText(
                'Save',
                color: AppColors.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSubmitting ? null : () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: AppColors.primaryColor, width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: AppText(
                    'Cancel',
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const AppText(
                          'Save Lead',
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Basic Information'),
            const SizedBox(height: 12),
            _buildWhiteContainer(
              children: [
                _buildLabeledTextField(controller: _nameController, label: 'Full Name *', hint: 'e.g. Rohan Mehta'),
                const SizedBox(height: 16),
                _buildLabeledTextField(controller: _companyController, label: 'Company Name', hint: 'e.g. Mehta Enterprises'),
                const SizedBox(height: 16),
                _buildLabeledTextField(controller: _emailController, label: 'Email', hint: 'e.g. rohan.mehta@mehta.com', keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 16),
                _buildLabeledTextField(controller: _mobileController, label: 'Mobile Number *', hint: 'e.g. +91 9876543210', keyboardType: TextInputType.phone),
                const SizedBox(height: 16),
                _buildLabeledTextField(controller: _designationController, label: 'Designation', hint: 'e.g. Proprietor'),
              ],
            ),

            const SizedBox(height: 24),
            _buildSectionTitle('Lead Information'),
            const SizedBox(height: 12),
            _buildWhiteContainer(
              children: [
                _buildSourceDropdown(),
                const SizedBox(height: 16),
                _buildStatusDropdown(),
                const SizedBox(height: 16),
                _buildAssignToDropdown(),
                const SizedBox(height: 16),
                _buildLabeledTextField(
                  controller: _requirementController,
                  label: 'Requirement',
                  hint: 'e.g. Custom attendance and payroll application',
                ),
              ],
            ),

            const SizedBox(height: 24),
            _buildSectionTitle('Additional Information'),
            const SizedBox(height: 12),
            _buildWhiteContainer(
              children: [
                _buildLabeledTextField(
                  controller: _locationController,
                  label: 'Location',
                  hint: 'e.g. Mumbai, Maharashtra',
                  suffixIcon: Iconsax.location,
                ),
                const SizedBox(height: 16),
                _buildLabeledTextField(
                  controller: _estimatedValueController,
                  label: 'Estimated Value',
                  hint: 'e.g. 250000',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildLabeledTextField(
                  controller: _closingDateController,
                  label: 'Expected Closing Date',
                  hint: 'Select Date',
                  suffixIcon: Iconsax.calendar_1,
                  readOnly: true,
                  onTap: _selectClosingDate,
                ),
                const SizedBox(height: 16),
                _buildLabeledTextField(
                  controller: _notesController,
                  label: 'Notes',
                  hint: 'Referred by an existing client...',
                  maxLines: 4,
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return AppText(
      title,
      fontSize: 14,
      fontWeight: FontWeight.w800,
      color: _sectionTitleColor,
    );
  }

  Widget _buildWhiteContainer({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildLabeledTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? suffixIcon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(label, fontSize: 12, fontWeight: FontWeight.bold, color: _labelColor),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF0F172A)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: _hintColor, fontSize: 13, fontWeight: FontWeight.w400),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primaryColor),
            ),
            suffixIcon: suffixIcon != null
                ? InkWell(
                    onTap: onTap,
                    child: Icon(suffixIcon, color: const Color(0xFF64748B), size: 18),
                  )
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildSourceDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText('Lead Source *', fontSize: 12, fontWeight: FontWeight.bold, color: _labelColor),
        const SizedBox(height: 6),
        Obx(() {
          final sources = _sourceOptions;
          final validSource = sources.contains(_selectedSource) ? _selectedSource : null;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _borderColor),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: validSource,
                isExpanded: true,
                hint: AppText('Select Lead Source', fontSize: 13, color: _hintColor),
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                items: sources.map((source) {
                  return DropdownMenuItem<String>(
                    value: source,
                    child: AppText(source, fontSize: 13, fontWeight: FontWeight.w500),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedSource = val);
                },
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStatusDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText('Lead Status *', fontSize: 12, fontWeight: FontWeight.bold, color: _labelColor),
        const SizedBox(height: 6),
        Obx(() {
          final statuses = _statusOptions;
          final validStatus = statuses.contains(_selectedStatus) ? _selectedStatus : null;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _borderColor),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: validStatus,
                isExpanded: true,
                hint: AppText('Select Lead Status', fontSize: 13, color: _hintColor),
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                items: statuses.map((st) {
                  return DropdownMenuItem<String>(
                    value: st,
                    child: AppText(st, fontSize: 13, fontWeight: FontWeight.w500),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedStatus = val);
                },
              ),
            ),
          );
        }),
      ],
    );
  }

  // ── Assign to * Dropdown backed by sales-employees API ───────────────────────
  Widget _buildAssignToDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppText('Assign to *', fontSize: 12, fontWeight: FontWeight.bold, color: _labelColor),
            if (_isLoadingEmployees)
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _borderColor),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<SalesEmployeeModel>(
              value: _selectedSalesEmployee != null &&
                      _salesEmployees.any((e) => e.id == _selectedSalesEmployee!.id)
                  ? _salesEmployees.firstWhere((e) => e.id == _selectedSalesEmployee!.id)
                  : null,
              isExpanded: true,
              hint: AppText(
                _isLoadingEmployees
                    ? 'Loading sales employees...'
                    : (_salesEmployees.isEmpty ? 'No sales employees found' : 'Select Sales Representative'),
                fontSize: 13,
                color: _hintColor,
              ),
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
              items: _salesEmployees.map((emp) {
                return DropdownMenuItem<SalesEmployeeModel>(
                  value: emp,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: AppColors.primaryLight,
                        backgroundImage: (emp.avatar != null && emp.avatar!.isNotEmpty)
                            ? NetworkImage(emp.avatar!)
                            : null,
                        child: (emp.avatar == null || emp.avatar!.isEmpty)
                            ? const Icon(Iconsax.user, size: 12, color: AppColors.primaryColor)
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${emp.displayName} (${emp.displayDesignation})',
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: AppText(
                          emp.displayEmployeeId,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF4F46E5),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (emp) {
                if (emp != null) {
                  setState(() => _selectedSalesEmployee = emp);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
