import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/custom_snackbar.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_input_field.dart';
import '../../../../core/services/network/api_client.dart';
import '../../../departments/controllers/departments_controller.dart';
import '../../../departments/repositories/department_repository.dart';
import '../../designation/controllers/designation_controller.dart';
import '../../designation/repositories/designation_repository.dart';
import '../../../shift_management/controllers/shift_controller.dart';
import '../controllers/employee_controller.dart';
import '../models/create_employee_request_model.dart';
import '../models/employee_model.dart';

class AddEmployeeScreen extends StatefulWidget {
  final EmployeeModel? employee; // If provided, we are in Edit mode
  const AddEmployeeScreen({super.key, this.employee});

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final controller = Get.isRegistered<EmployeeController>()
      ? Get.find<EmployeeController>()
      : Get.put(EmployeeController());

  late final DepartmentsController _departmentsController;
  late final DesignationController _designationController;
  late final ShiftController _shiftController;

  File? _avatarFile;

  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 5;

  // ----------------------------------------------------
  // Step 1: Personal Details & Identity
  // ----------------------------------------------------
  late TextEditingController nameController;
  late TextEditingController empIdController;
  String selectedGender = 'Male';
  DateTime selectedDob = DateTime(1996, 5, 15);
  String selectedMaritalStatus = 'Single';
  String selectedBloodGroup = 'O+';

  // ----------------------------------------------------
  // Step 2: Contact & Full Address
  // ----------------------------------------------------
  late TextEditingController mobileController;
  late TextEditingController altMobileController;
  late TextEditingController emailController;
  late TextEditingController emergencyContactController;
  late TextEditingController addressController;
  late TextEditingController cityController;
  late TextEditingController stateController;
  late TextEditingController pincodeController;
  late TextEditingController countryController;

  // ----------------------------------------------------
  // Step 3: Employment, Roles & Lifecycle Status
  // ----------------------------------------------------
  String selectedWorkMode = 'Office';
  String selectedEmployeeType = 'Full-time';
  String selectedDepartment = 'Engineering';
  String selectedDesignation = 'Senior Flutter Developer';
  String selectedTeam = 'Team Alpha';
  String selectedShift = 'Morning Shift';
  String selectedReportingManager = '';
  DateTime selectedJoiningDate = DateTime.now();
  String selectedEmploymentStatus = 'Active';
  String selectedProbationPeriod = '3 Months';
  String selectedNoticePeriod = '30 Days';

  // ----------------------------------------------------
  // Step 4: Compensation & Sales Target
  // ----------------------------------------------------
  String selectedSalaryType = 'Monthly';
  late TextEditingController salaryController;
  bool hasSalesTarget = false;
  String selectedTargetType = 'Revenue';
  late TextEditingController targetAmountController;
  String selectedTargetPeriod = 'Monthly';
  late TextEditingController incentivePercentController;

  // ----------------------------------------------------
  // Step 5: Bank Details & Skills
  // ----------------------------------------------------
  late TextEditingController accountHolderNameController;
  late TextEditingController bankNameController;
  late TextEditingController accountNumberController;
  late TextEditingController ifscCodeController;
  late TextEditingController branchNameController;
  final TextEditingController skillInputController = TextEditingController();
  final List<String> _skillsList = [];

  // Dropdown & Option Masters
  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _maritalStatuses = ['Single', 'Married', 'Divorced', 'Widowed'];
  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];

  @override
  void initState() {
    super.initState();
    final e = widget.employee;

    final apiClient = Get.isRegistered<ApiClient>() ? Get.find<ApiClient>() : ApiClient();

    _departmentsController = Get.isRegistered<DepartmentsController>()
        ? Get.find<DepartmentsController>()
        : Get.put(DepartmentsController(repository: DepartmentRepository(apiClient: apiClient)));

    _designationController = Get.isRegistered<DesignationController>()
        ? Get.find<DesignationController>()
        : Get.put(DesignationController(repository: DesignationRepository(apiClient: apiClient)));

    _shiftController = Get.isRegistered<ShiftController>()
        ? Get.find<ShiftController>()
        : Get.put(ShiftController());

    if (_departmentsController.departments.isEmpty && _departmentsController.apiDepartments.isEmpty) {
      _departmentsController.fetchDepartments();
    }
    if (_designationController.designations.isEmpty) {
      _designationController.fetchDesignations();
    }
    if (_shiftController.shifts.isEmpty) {
      _shiftController.fetchShifts();
    }

    // Step 1 Controllers
    nameController = TextEditingController(text: e?.name);
    empIdController = TextEditingController(
      text: e?.employeeId ??
          'EMP-${DateFormat('yyyy').format(DateTime.now())}-${(controller.employees.length + 1).toString().padLeft(3, '0')}',
    );
    selectedGender = e?.gender ?? 'Male';
    if (e != null && e.dob.isNotEmpty) {
      try {
        selectedDob = DateFormat('dd MMM yyyy').parse(e.dob);
      } catch (_) {}
    }

    // Step 2 Controllers
    mobileController = TextEditingController(text: e?.mobile);
    altMobileController = TextEditingController(text: e?.alternateMobile);
    emailController = TextEditingController(text: e?.email);
    emergencyContactController = TextEditingController(text: e?.emergencyContact);
    addressController = TextEditingController(text: e?.address);
    cityController = TextEditingController(text: e != null && e.city.isNotEmpty ? e.city : 'Bengaluru');
    stateController = TextEditingController(text: e != null && e.state.isNotEmpty ? e.state : 'Karnataka');
    pincodeController = TextEditingController(text: e != null && e.pincode.isNotEmpty ? e.pincode : '560038');
    countryController = TextEditingController(text: e != null && e.country.isNotEmpty ? e.country : 'India');

    // Step 3 Employment
    selectedWorkMode = e != null && e.workMode.isNotEmpty ? e.workMode : 'Office';
    selectedEmployeeType = e != null && e.employeeType.isNotEmpty ? e.employeeType : 'Full-time';
    selectedDepartment = e?.department ?? (controller.departmentsList.length > 1 ? controller.departmentsList[1] : 'Engineering');
    selectedDesignation = e?.designation ?? (controller.designations.isNotEmpty ? controller.designations[0] : 'Senior Flutter Developer');
    selectedTeam = e?.team ?? (controller.teamsList.length > 1 ? controller.teamsList[1] : 'Team Alpha');
    selectedShift = e?.shift ?? (controller.shiftsList.length > 1 ? controller.shiftsList[1] : 'Morning Shift');
    selectedReportingManager = e != null && e.reportingManager.isNotEmpty
        ? e.reportingManager
        : (controller.reportingManagersList.isNotEmpty ? controller.reportingManagersList.first : '');
    selectedEmploymentStatus = e != null && e.employmentStatus.isNotEmpty ? e.employmentStatus : 'Active';
    selectedProbationPeriod = e != null && e.probationPeriod.isNotEmpty ? e.probationPeriod : '3 Months';
    selectedNoticePeriod = e != null && e.noticePeriod.isNotEmpty ? e.noticePeriod : '30 Days';

    if (e != null && e.joiningDate.isNotEmpty) {
      try {
        selectedJoiningDate = DateFormat('dd MMMM yyyy').parse(e.joiningDate);
      } catch (_) {}
    }

    // Step 4 Compensation & Target
    selectedSalaryType = e != null && e.salaryType.isNotEmpty ? e.salaryType : 'Monthly';
    salaryController = TextEditingController(text: e != null && e.salary > 0 ? e.salary.toStringAsFixed(0) : '60000');
    hasSalesTarget = e?.hasSalesTarget ?? (selectedDepartment == 'Sales');
    selectedTargetType = e != null && e.targetType.isNotEmpty ? e.targetType : 'Revenue';
    targetAmountController = TextEditingController(text: e != null && e.targetAmount.isNotEmpty ? e.targetAmount : '500000');
    selectedTargetPeriod = e != null && e.targetPeriod.isNotEmpty ? e.targetPeriod : 'Monthly';
    incentivePercentController = TextEditingController(text: e != null && e.incentivePercent.isNotEmpty ? e.incentivePercent : '5');

    // Step 5 Bank & Skills
    accountHolderNameController = TextEditingController(text: e != null && e.accountHolderName.isNotEmpty ? e.accountHolderName : (e?.name ?? ''));
    bankNameController = TextEditingController(text: e != null && e.bankName.isNotEmpty ? e.bankName : 'HDFC Bank');
    accountNumberController = TextEditingController(text: e?.accountNumber ?? '');
    ifscCodeController = TextEditingController(text: e != null && e.ifscCode.isNotEmpty ? e.ifscCode : 'HDFC0001234');
    branchNameController = TextEditingController(text: e != null && e.branchName.isNotEmpty ? e.branchName : 'Main Branch');

    if (e != null && e.skills.isNotEmpty) {
      _skillsList.addAll(e.skills);
    } else {
      _skillsList.addAll(['Flutter', 'Dart', 'Teamwork']);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    nameController.dispose();
    empIdController.dispose();
    mobileController.dispose();
    altMobileController.dispose();
    emailController.dispose();
    emergencyContactController.dispose();
    addressController.dispose();
    cityController.dispose();
    stateController.dispose();
    pincodeController.dispose();
    countryController.dispose();
    salaryController.dispose();
    targetAmountController.dispose();
    incentivePercentController.dispose();
    accountHolderNameController.dispose();
    bankNameController.dispose();
    accountNumberController.dispose();
    ifscCodeController.dispose();
    branchNameController.dispose();
    skillInputController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    if (step < 0 || step >= _totalSteps) return;
    setState(() {
      _currentStep = step;
    });
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _handleNext() {
    // Validate Step 1
    if (_currentStep == 0) {
      if (nameController.text.trim().isEmpty) {
        CustomSnackbar.showError('Please enter employee full name');
        return;
      }
      if (empIdController.text.trim().isEmpty) {
        CustomSnackbar.showError('Please enter employee ID');
        return;
      }
      // Auto-fill account holder name with employee name if empty
      if (accountHolderNameController.text.trim().isEmpty) {
        accountHolderNameController.text = nameController.text.trim();
      }
    }

    // Validate Step 2
    if (_currentStep == 1) {
      if (mobileController.text.trim().isEmpty) {
        CustomSnackbar.showError('Please enter mobile number');
        return;
      }
      if (addressController.text.trim().isEmpty) {
        CustomSnackbar.showError('Please enter street address');
        return;
      }
      if (cityController.text.trim().isEmpty) {
        CustomSnackbar.showError('Please enter city');
        return;
      }
      if (pincodeController.text.trim().isEmpty) {
        CustomSnackbar.showError('Please enter pincode');
        return;
      }
    }

    // Move next or Submit
    if (_currentStep < _totalSteps - 1) {
      _goToStep(_currentStep + 1);
    } else {
      _saveEmployee();
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source, imageQuality: 80);
      if (picked != null) {
        setState(() {
          _avatarFile = File(picked.path);
        });
      }
    } catch (e) {
      CustomSnackbar.showError('Could not select image: $e');
    }
  }

  void _showPhotoPicker() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Wrap(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: AppText('Select Profile Photo', fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ListTile(
              leading: const Icon(Iconsax.camera, color: AppColors.primaryColor),
              title: const AppText('Take Photo from Camera', fontSize: 14),
              onTap: () {
                Get.back();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Iconsax.gallery, color: AppColors.primaryColor),
              title: const AppText('Choose from Gallery', fontSize: 14),
              onTap: () {
                Get.back();
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getSelectedDesignationId() {
    if (Get.isRegistered<DesignationController>()) {
      final desigCtrl = Get.find<DesignationController>();
      final match = desigCtrl.designations.firstWhereOrNull(
        (d) => d.name.toLowerCase().trim() == selectedDesignation.toLowerCase().trim(),
      );
      if (match != null && match.id.isNotEmpty) {
        return match.id;
      }
      if (desigCtrl.designations.isNotEmpty) {
        return desigCtrl.designations.first.id;
      }
    }
    return '2';
  }

  String _getSelectedShiftId() {
    if (Get.isRegistered<ShiftController>()) {
      final shiftCtrl = Get.find<ShiftController>();
      final match = shiftCtrl.shifts.firstWhereOrNull(
        (s) => s.name.toLowerCase().contains(selectedShift.toLowerCase()) ||
               selectedShift.toLowerCase().contains(s.name.toLowerCase()),
      );
      if (match != null && match.id.isNotEmpty) {
        return match.id;
      }
      if (shiftCtrl.shifts.isNotEmpty) {
        return shiftCtrl.shifts.first.id;
      }
    }
    return '2';
  }

  Future<void> _saveEmployee() async {
    final name = nameController.text.trim();
    final empId = empIdController.text.trim();
    final mobile = mobileController.text.trim();
    final email = emailController.text.trim();
    final address = addressController.text.trim();
    final city = cityController.text.trim();
    final state = stateController.text.trim();
    final pincode = pincodeController.text.trim();
    final country = countryController.text.trim();

    final salaryVal = salaryController.text.trim().isNotEmpty
        ? salaryController.text.trim()
        : '60000';

    if (widget.employee == null) {
      final request = CreateEmployeeRequestModel(
        name: name,
        employeeId: empId,
        gender: selectedGender,
        dateOfBirth: DateFormat('yyyy-MM-dd').format(selectedDob),
        maritalStatus: selectedMaritalStatus,
        bloodGroup: selectedBloodGroup,
        mobileNumber: mobile,
        alternateMobileNumber: altMobileController.text.trim(),
        email: email.isNotEmpty ? email : '${empId.toLowerCase()}@company.com',
        emergencyContact: emergencyContactController.text.trim(),
        streetAddress: address,
        city: city,
        postalCode: pincode,
        state: state,
        country: country.isNotEmpty ? country : 'India',
        workMode: selectedWorkMode,
        employeeType: selectedEmployeeType,
        department: selectedDepartment,
        designationId: _getSelectedDesignationId(),
        team: selectedTeam,
        assignedShiftId: _getSelectedShiftId(),
        dateOfJoining: DateFormat('yyyy-MM-dd').format(selectedJoiningDate),
        employmentStatus: selectedEmploymentStatus,
        probationPeriod: selectedProbationPeriod,
        noticePeriod: selectedNoticePeriod,
        salaryType: selectedSalaryType,
        monthlyBaseSalary: salaryVal,
        salesTargetEnabled: hasSalesTarget ? '1' : '0',
        salesTargetMetricType: hasSalesTarget ? selectedTargetType : null,
        salesTarget: hasSalesTarget ? targetAmountController.text.trim() : null,
        salesTargetPeriod: hasSalesTarget ? selectedTargetPeriod : null,
        incentiveCommissionPercent: hasSalesTarget ? incentivePercentController.text.trim() : null,
        accountHolderName: accountHolderNameController.text.trim(),
        bankName: bankNameController.text.trim(),
        accountNumber: accountNumberController.text.trim(),
        ifscCode: ifscCodeController.text.trim().toUpperCase(),
        branchName: branchNameController.text.trim(),
        skills: List.from(_skillsList),
        roleIds: const [9],
        avatarPath: _avatarFile?.path,
      );

      final response = await controller.createEmployeeApi(request);
      if (response.status) {
        CustomSnackbar.showSuccess(
          response.message.isNotEmpty
              ? response.message
              : 'Employee $name registered successfully!',
        );
        Get.back(result: true);
      } else {
        CustomSnackbar.showError(
          response.message.isNotEmpty
              ? response.message
              : 'Failed to create employee. Please try again.',
        );
      }
    } else {
      final double sal = double.tryParse(salaryVal) ?? 0.0;
      final employeeToSave = EmployeeModel(
        id: widget.employee!.id,
        employeeId: empId,
        name: name,
        mobile: mobile,
        alternateMobile: altMobileController.text.trim(),
        email: email.isNotEmpty ? email : '${empId.toLowerCase()}@company.com',
        gender: selectedGender,
        dob: DateFormat('dd MMM yyyy').format(selectedDob),
        designation: selectedDesignation,
        department: selectedDepartment,
        team: selectedTeam,
        shift: selectedShift,
        workMode: selectedWorkMode,
        employeeType: selectedEmployeeType,
        reportingManager: selectedReportingManager,
        employmentStatus: selectedEmploymentStatus,
        probationPeriod: selectedProbationPeriod,
        noticePeriod: selectedNoticePeriod,
        joiningDate: DateFormat('dd MMMM yyyy').format(selectedJoiningDate),
        salaryType: selectedSalaryType,
        salary: sal,
        hasSalesTarget: hasSalesTarget,
        targetType: selectedTargetType,
        targetAmount: targetAmountController.text.trim(),
        targetPeriod: selectedTargetPeriod,
        incentivePercent: incentivePercentController.text.trim(),
        address: address,
        city: city,
        state: state,
        pincode: pincode,
        country: country.isNotEmpty ? country : 'India',
        emergencyContact: emergencyContactController.text.trim(),
        accountHolderName: accountHolderNameController.text.trim(),
        bankName: bankNameController.text.trim(),
        accountNumber: accountNumberController.text.trim(),
        ifscCode: ifscCodeController.text.trim().toUpperCase(),
        branchName: branchNameController.text.trim(),
        skills: List.from(_skillsList),
        isActive: selectedEmploymentStatus == 'Active' || selectedEmploymentStatus == 'Probation',
      );

      controller.updateEmployee(employeeToSave);
      CustomSnackbar.showSuccess('Employee ${employeeToSave.name} updated successfully!');
      Get.back(result: true);
    }
  }

  void _addSkill() {
    final text = skillInputController.text.trim();
    if (text.isNotEmpty) {
      if (!_skillsList.contains(text)) {
        setState(() {
          _skillsList.add(text);
        });
        if (!controller.availableSkills.contains(text)) {
          controller.availableSkills.add(text);
        }
      }
      skillInputController.clear();
    }
  }

  void _removeSkill(String skill) {
    setState(() {
      _skillsList.remove(skill);
    });
  }

  // ----------------------------------------------------
  // Main Build
  // ----------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textColorPrimary, size: 20),
          onPressed: () {
            if (_currentStep > 0) {
              _goToStep(_currentStep - 1);
            } else {
              Get.back();
            }
          },
        ),
        title: AppText(
          widget.employee == null ? 'Add New Employee' : 'Edit Employee Details',
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const AppText('Cancel', fontSize: 13, color: AppColors.textColorSecondary, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Numbered Stepper Timeline (1 to 5)
          _buildStepperBar(),

          // Step Pages
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep1Personal(),
                _buildStep2Address(),
                _buildStep3Employment(),
                _buildStep4SalaryAndTarget(),
                _buildStep5BankAndSkills(),
              ],
            ),
          ),

          // Persistent Bottom Navigation Bar
          _buildBottomBar(),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // Numbered Stepper Timeline (1, 2, 3, 4, 5)
  // ----------------------------------------------------
  Widget _buildStepperBar() {
    final stepTitles = ['Personal', 'Address', 'Work & Status', 'Salary & Target', 'Bank & Skills'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.slate200.withValues(alpha: 0.8))),
      ),
      child: Column(
        children: [
          Row(
            children: List.generate(_totalSteps * 2 - 1, (index) {
              if (index.isOdd) {
                final stepIndex = index ~/ 2;
                final isPassed = stepIndex < _currentStep;
                return Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    height: 2.5,
                    color: isPassed ? AppColors.primaryColor : AppColors.slate200,
                  ),
                );
              }

              final stepIndex = index ~/ 2;
              final isPassed = stepIndex < _currentStep;
              final isCurrent = stepIndex == _currentStep;

              return GestureDetector(
                onTap: () => _goToStep(stepIndex),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isPassed
                        ? AppColors.primaryColor
                        : isCurrent
                            ? AppColors.primaryColor
                            : Colors.white,
                    border: Border.all(
                      color: (isPassed || isCurrent) ? AppColors.primaryColor : AppColors.slate300,
                      width: isCurrent ? 2 : 1.5,
                    ),
                    boxShadow: isCurrent
                        ? [
                            BoxShadow(
                              color: AppColors.primaryColor.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: isPassed
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : AppText(
                            '${stepIndex + 1}',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isCurrent ? Colors.white : AppColors.textColorHint,
                          ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_totalSteps, (index) {
              final isCurrent = index == _currentStep;
              final isPassed = index < _currentStep;
              return Expanded(
                child: Text(
                  stepTitles[index],
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500,
                    color: isCurrent
                        ? AppColors.primaryColor
                        : isPassed
                            ? const Color(0xFF334155)
                            : AppColors.textColorHint,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // Step Header Widget (rendered above cards)
  // ----------------------------------------------------
  Widget _buildStepHeader({
    required String title,
    required String subtitle,
    required IconData icon,
    required String stepBadge,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primaryColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: AppText(
                        stepBadge,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AppText(
                        title,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                AppText(
                  subtitle,
                  fontSize: 11,
                  color: AppColors.textColorSecondary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // STEP 1: Personal Details & Identity
  // ----------------------------------------------------
  Widget _buildStep1Personal() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            title: 'Personal Information',
            subtitle: 'Profile photo, full name, employee identity & personal info',
            icon: Iconsax.user_tag,
            stepBadge: 'STEP 1 OF 5',
          ),

          // Profile Photo Uploader
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 46,
                        backgroundColor: AppColors.primaryLight,
                        backgroundImage: _avatarFile != null ? FileImage(_avatarFile!) : null,
                        child: _avatarFile == null
                            ? AppText(
                                nameController.text.trim().isNotEmpty ? nameController.text.trim()[0].toUpperCase() : 'EMP',
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryColor,
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _showPhotoPicker,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const AppText('Profile Photo', fontSize: 13, fontWeight: FontWeight.w700),
                  const SizedBox(height: 2),
                  const AppText('Tap camera icon to update picture', fontSize: 11, color: AppColors.textColorSecondary),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Basic Identity Card
          _buildCard(
            title: 'Basic Identity',
            icon: Iconsax.personalcard,
            children: [
              _buildFieldTitle('Full Name', isRequired: true),
              const SizedBox(height: 6),
              AppInputField(
                controller: nameController,
                hint: 'e.g. Rahul Sharma',
                prefixIcon: const Icon(Iconsax.user, color: AppColors.textColorSecondary, size: 18),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),

              _buildFieldTitle('Employee ID', isRequired: true),
              const SizedBox(height: 6),
              AppInputField(
                controller: empIdController,
                hint: 'EMP-2026-001',
                prefixIcon: const Icon(Iconsax.card, color: AppColors.textColorSecondary, size: 18),
              ),
              const SizedBox(height: 16),

              // Gender Selector
              _buildFieldTitle('Gender', isRequired: true),
              const SizedBox(height: 8),
              Row(
                children: _genders.map((gender) {
                  final isSelected = selectedGender == gender;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => selectedGender = gender),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primaryColor : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? AppColors.primaryColor : const Color(0xFFCBD5E1),
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: AppText(
                            gender,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white : const Color(0xFF334155),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Date of Birth
              _buildFieldTitle('Date of Birth', isRequired: false),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDob,
                    firstDate: DateTime(1950),
                    lastDate: DateTime.now().subtract(const Duration(days: 365 * 16)),
                  );
                  if (picked != null) {
                    setState(() => selectedDob = picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Iconsax.calendar, color: AppColors.textColorSecondary, size: 18),
                          const SizedBox(width: 10),
                          AppText(
                            DateFormat('dd MMM yyyy').format(selectedDob),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ],
                      ),
                      const Icon(Icons.arrow_drop_down, color: AppColors.textColorSecondary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Marital Status & Blood Group in 2 Columns
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldTitle('Marital Status'),
                        const SizedBox(height: 6),
                        _buildDropdown(
                          value: selectedMaritalStatus,
                          items: _maritalStatuses,
                          onChanged: (val) {
                            if (val != null) setState(() => selectedMaritalStatus = val);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldTitle('Blood Group'),
                        const SizedBox(height: 6),
                        _buildDropdown(
                          value: selectedBloodGroup,
                          items: _bloodGroups,
                          onChanged: (val) {
                            if (val != null) setState(() => selectedBloodGroup = val);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // STEP 2: Contact & Full Address
  // ----------------------------------------------------
  Widget _buildStep2Address() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            title: 'Contact & Detailed Address',
            subtitle: 'Phone numbers, email, complete residential address & emergency contact',
            icon: Iconsax.location,
            stepBadge: 'STEP 2 OF 5',
          ),

          // Contact Information Card
          _buildCard(
            title: 'Contact Information',
            icon: Iconsax.call,
            children: [
              _buildFieldTitle('Primary Mobile Number', isRequired: true),
              const SizedBox(height: 6),
              AppInputField(
                controller: mobileController,
                hint: '10-digit mobile number',
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Iconsax.call, color: AppColors.textColorSecondary, size: 18),
              ),
              const SizedBox(height: 16),

              _buildFieldTitle('Alternate Mobile Number'),
              const SizedBox(height: 6),
              AppInputField(
                controller: altMobileController,
                hint: 'Secondary contact number',
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Iconsax.call_calling, color: AppColors.textColorSecondary, size: 18),
              ),
              const SizedBox(height: 16),

              _buildFieldTitle('Email Address'),
              const SizedBox(height: 6),
              AppInputField(
                controller: emailController,
                hint: 'name@example.com',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Iconsax.sms, color: AppColors.textColorSecondary, size: 18),
              ),
              const SizedBox(height: 16),

              _buildFieldTitle('Emergency Contact Phone'),
              const SizedBox(height: 6),
              AppInputField(
                controller: emergencyContactController,
                hint: 'Guardian / Spouse / Next of kin number',
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Iconsax.security_user, color: AppColors.textColorSecondary, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Detailed Residential Address Card
          _buildCard(
            title: 'Full Address Details',
            icon: Iconsax.building_3,
            children: [
              _buildFieldTitle('Street Address / Flat / Building', isRequired: true),
              const SizedBox(height: 6),
              AppInputField(
                controller: addressController,
                hint: 'e.g. Flat 402, Sunshine Heights, MG Road',
                prefixIcon: const Icon(Iconsax.home_2, color: AppColors.textColorSecondary, size: 18),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldTitle('City', isRequired: true),
                        const SizedBox(height: 6),
                        AppInputField(
                          controller: cityController,
                          hint: 'e.g. Bengaluru',
                          prefixIcon: const Icon(Iconsax.building_4, color: AppColors.textColorSecondary, size: 18),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldTitle('Pincode / Postal', isRequired: true),
                        const SizedBox(height: 6),
                        AppInputField(
                          controller: pincodeController,
                          hint: 'e.g. 560038',
                          keyboardType: TextInputType.number,
                          prefixIcon: const Icon(Iconsax.location_tick, color: AppColors.textColorSecondary, size: 18),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldTitle('State / Province', isRequired: true),
                        const SizedBox(height: 6),
                        AppInputField(
                          controller: stateController,
                          hint: 'e.g. Karnataka',
                          prefixIcon: const Icon(Iconsax.map_1, color: AppColors.textColorSecondary, size: 18),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldTitle('Country', isRequired: true),
                        const SizedBox(height: 6),
                        AppInputField(
                          controller: countryController,
                          hint: 'e.g. India',
                          prefixIcon: const Icon(Iconsax.global, color: AppColors.textColorSecondary, size: 18),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // STEP 3: Employment, Roles & Lifecycle Status
  // ----------------------------------------------------
  Widget _buildStep3Employment() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            title: 'Employment & Status Lifecycle',
            subtitle: 'Work mode, employee type, roles, reporting manager & status',
            icon: Iconsax.briefcase,
            stepBadge: 'STEP 3 OF 5',
          ),

          // Work Mode & Employee Type Card
          _buildCard(
            title: 'Work Arrangement',
            icon: Iconsax.status_up,
            children: [
              _buildFieldTitle('Work Mode', isRequired: true),
              const SizedBox(height: 8),
              Row(
                children: controller.workModesList.map((mode) {
                  final isSelected = selectedWorkMode == mode;
                  IconData modeIcon = Iconsax.building;
                  if (mode == 'Remote') modeIcon = Iconsax.home_wifi;
                  if (mode == 'Hybrid') modeIcon = Iconsax.shuffle;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => selectedWorkMode = mode),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primaryColor.withValues(alpha: 0.08) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppColors.primaryColor : const Color(0xFFE2E8F0),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(modeIcon, color: isSelected ? AppColors.primaryColor : const Color(0xFF64748B), size: 22),
                            const SizedBox(height: 6),
                            AppText(
                              mode,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? AppColors.primaryColor : const Color(0xFF334155),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              _buildFieldTitle('Employee Type', isRequired: true),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.employeeTypesList.map((type) {
                  final isSelected = selectedEmployeeType == type;
                  return ChoiceChip(
                    label: Text(type),
                    selected: isSelected,
                    selectedColor: AppColors.primaryColor,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF334155),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    side: BorderSide(
                      color: isSelected ? AppColors.primaryColor : const Color(0xFFCBD5E1),
                    ),
                    onSelected: (selected) {
                      if (selected) setState(() => selectedEmployeeType = type);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Department, Designation, Reporting Manager
          _buildCard(
            title: 'Organization Placement',
            icon: Iconsax.hierarchy_2,
            children: [
              _buildFieldTitle('Department', isRequired: true),
              const SizedBox(height: 6),
              Obx(() {
                final depts = controller.departmentsList.where((d) => d != 'All').toList();
                return _buildDropdown(
                  value: depts.contains(selectedDepartment) ? selectedDepartment : (depts.isNotEmpty ? depts.first : 'Engineering'),
                  items: depts,
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        selectedDepartment = val;
                        if (selectedDepartment.toLowerCase().contains('sales')) {
                          hasSalesTarget = true;
                        }
                      });
                    }
                  },
                );
              }),
              const SizedBox(height: 16),

              _buildFieldTitle('Designation / Role', isRequired: true),
              const SizedBox(height: 6),
              Obx(() {
                final desigs = controller.designations;
                return _buildDropdown(
                  value: desigs.contains(selectedDesignation) ? selectedDesignation : (desigs.isNotEmpty ? desigs.first : 'Senior Flutter Developer'),
                  items: desigs,
                  onChanged: (val) {
                    if (val != null) setState(() => selectedDesignation = val);
                  },
                );
              }),
              const SizedBox(height: 16),

              _buildFieldTitle('Team / Unit', isRequired: true),
              const SizedBox(height: 6),
              _buildDropdown(
                value: selectedTeam,
                items: controller.teamsList.where((t) => t != 'All').toList(),
                onChanged: (val) {
                  if (val != null) setState(() => selectedTeam = val);
                },
              ),
              const SizedBox(height: 16),

              _buildFieldTitle('Assigned Shift', isRequired: true),
              const SizedBox(height: 6),
              Obx(() {
                final shifts = controller.shiftsList.where((s) => s != 'All').toList();
                return _buildDropdown(
                  value: shifts.contains(selectedShift) ? selectedShift : (shifts.isNotEmpty ? shifts.first : 'Morning Shift'),
                  items: shifts,
                  onChanged: (val) {
                    if (val != null) setState(() => selectedShift = val);
                  },
                );
              }),
              const SizedBox(height: 16),

              _buildFieldTitle('Reporting Manager', isRequired: true),
              const SizedBox(height: 6),
              _buildDropdown(
                value: selectedReportingManager.isNotEmpty
                    ? selectedReportingManager
                    : (controller.reportingManagersList.isNotEmpty ? controller.reportingManagersList.first : 'None'),
                items: controller.reportingManagersList,
                onChanged: (val) {
                  if (val != null) setState(() => selectedReportingManager = val);
                },
              ),
              const SizedBox(height: 16),

              // Date of Joining
              _buildFieldTitle('Date of Joining', isRequired: true),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedJoiningDate,
                    firstDate: DateTime(2010),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    setState(() => selectedJoiningDate = picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Iconsax.calendar_1, color: AppColors.textColorSecondary, size: 18),
                          const SizedBox(width: 10),
                          AppText(
                            DateFormat('dd MMMM yyyy').format(selectedJoiningDate),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ],
                      ),
                      const Icon(Icons.arrow_drop_down, color: AppColors.textColorSecondary),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Lifecycle Status (Active, Probation, Notice, Terminate, Inactive)
          _buildCard(
            title: 'Employee Lifecycle Status',
            icon: Iconsax.timer_1,
            children: [
              _buildFieldTitle('Current Employment Status', isRequired: true),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.employmentStatusesList.map((st) {
                  final isSelected = selectedEmploymentStatus == st;
                  Color pillColor = Colors.green;
                  if (st == 'Probation') pillColor = Colors.orange;
                  if (st == 'Notice Period') pillColor = Colors.amber.shade800;
                  if (st == 'Terminated') pillColor = Colors.red;
                  if (st == 'Inactive') pillColor = Colors.grey;

                  return GestureDetector(
                    onTap: () => setState(() => selectedEmploymentStatus = st),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? pillColor : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? pillColor : const Color(0xFFCBD5E1),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected ? Colors.white : pillColor,
                            ),
                          ),
                          const SizedBox(width: 6),
                          AppText(
                            st,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white : const Color(0xFF334155),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldTitle('Probation Period'),
                        const SizedBox(height: 6),
                        _buildDropdown(
                          value: selectedProbationPeriod,
                          items: controller.probationPeriodsList,
                          onChanged: (val) {
                            if (val != null) setState(() => selectedProbationPeriod = val);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldTitle('Notice Period'),
                        const SizedBox(height: 6),
                        _buildDropdown(
                          value: selectedNoticePeriod,
                          items: controller.noticePeriodsList,
                          onChanged: (val) {
                            if (val != null) setState(() => selectedNoticePeriod = val);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // STEP 4: Compensation & Sales Target
  // ----------------------------------------------------
  Widget _buildStep4SalaryAndTarget() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            title: 'Compensation & Target',
            subtitle: 'Salary type (monthly, hourly, etc.), base salary & sales target',
            icon: Iconsax.money_send,
            stepBadge: 'STEP 4 OF 5',
          ),

          // Salary Configuration Card
          _buildCard(
            title: 'Salary & Compensation Type',
            icon: Iconsax.wallet_money,
            children: [
              _buildFieldTitle('Salary Type', isRequired: true),
              const SizedBox(height: 8),
              Row(
                children: controller.salaryTypesList.map((type) {
                  final isSelected = selectedSalaryType == type;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => selectedSalaryType = type),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primaryColor : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? AppColors.primaryColor : const Color(0xFFCBD5E1),
                          ),
                        ),
                        child: Center(
                          child: AppText(
                            type,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white : const Color(0xFF334155),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              _buildFieldTitle(
                selectedSalaryType == 'Hourly'
                    ? 'Hourly Rate (₹ / hr)'
                    : selectedSalaryType == 'Weekly'
                        ? 'Weekly Payout (₹)'
                        : selectedSalaryType == 'Annual CTC'
                            ? 'Annual CTC (₹)'
                            : 'Monthly Base Salary (₹)',
                isRequired: true,
              ),
              const SizedBox(height: 6),
              AppInputField(
                controller: salaryController,
                hint: 'e.g. 75000',
                keyboardType: TextInputType.number,
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 14, top: 12),
                  child: AppText('₹', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Sales Target Section (Optional or mandatory for Sales Dept)
          _buildCard(
            title: 'Sales Target & Performance Goals',
            icon: Iconsax.chart_21,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppText('Set Sales Target & Incentives', fontSize: 13, fontWeight: FontWeight.w800),
                        const SizedBox(height: 2),
                        AppText(
                          selectedDepartment == 'Sales'
                              ? 'Recommended for sales team employees'
                              : 'Enable if this employee has KPI quota',
                          fontSize: 11,
                          color: AppColors.textColorSecondary,
                        ),
                      ],
                    ),
                  ),
                  CupertinoSwitch(
                    value: hasSalesTarget,
                    activeTrackColor: AppColors.primaryColor,
                    onChanged: (val) => setState(() => hasSalesTarget = val),
                  ),
                ],
              ),

              if (hasSalesTarget) ...[
                const SizedBox(height: 16),
                const Divider(color: Color(0xFFF1F5F9)),
                const SizedBox(height: 10),

                // Target Type
                _buildFieldTitle('Target Metric Type', isRequired: true),
                const SizedBox(height: 8),
                Row(
                  children: controller.targetTypesList.map((tType) {
                    final isSelected = selectedTargetType == tType;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => selectedTargetType = tType),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF0284C7) : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF0284C7) : const Color(0xFFCBD5E1),
                            ),
                          ),
                          child: Center(
                            child: AppText(
                              tType,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? Colors.white : const Color(0xFF334155),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Target Amount and Target Period
                Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldTitle(
                            selectedTargetType == 'Revenue'
                                ? 'Target Revenue (₹)'
                                : selectedTargetType == 'Deals Closed'
                                    ? 'Deals Target Count'
                                    : 'Units to Sell',
                            isRequired: true,
                          ),
                          const SizedBox(height: 6),
                          AppInputField(
                            controller: targetAmountController,
                            hint: 'e.g. 500000',
                            keyboardType: TextInputType.number,
                            prefixIcon: const Icon(Iconsax.radar, color: AppColors.textColorSecondary, size: 18),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldTitle('Target Period'),
                          const SizedBox(height: 6),
                          _buildDropdown(
                            value: selectedTargetPeriod,
                            items: controller.targetPeriodsList,
                            onChanged: (val) {
                              if (val != null) setState(() => selectedTargetPeriod = val);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Incentive %
                _buildFieldTitle('Incentive Commission (%)', isRequired: false),
                const SizedBox(height: 6),
                AppInputField(
                  controller: incentivePercentController,
                  hint: 'e.g. 5.0 % on target achievement',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  prefixIcon: const Icon(Iconsax.percentage_circle, color: AppColors.textColorSecondary, size: 18),
                ),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Iconsax.info_circle, size: 18, color: Color(0xFF16A34A)),
                      SizedBox(width: 10),
                      Expanded(
                        child: AppText(
                          'Incentives and sales commission will be tracked against employee monthly attendance and invoices.',
                          fontSize: 11,
                          color: Color(0xFF15803D),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // STEP 5: Bank Details & Dynamic Skills
  // ----------------------------------------------------
  Widget _buildStep5BankAndSkills() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            title: 'Bank Account & Skills',
            subtitle: 'Direct deposit bank details and professional employee skills',
            icon: Iconsax.bank,
            stepBadge: 'STEP 5 OF 5',
          ),

          // Bank Details Card
          _buildCard(
            title: 'Banking Information (for Payroll)',
            icon: Iconsax.card_pos,
            children: [
              _buildFieldTitle('Account Holder Name', isRequired: true),
              const SizedBox(height: 6),
              AppInputField(
                controller: accountHolderNameController,
                hint: 'Name as registered with bank',
                prefixIcon: const Icon(Iconsax.user, color: AppColors.textColorSecondary, size: 18),
              ),
              const SizedBox(height: 16),

              _buildFieldTitle('Bank Name', isRequired: true),
              const SizedBox(height: 6),
              AppInputField(
                controller: bankNameController,
                hint: 'e.g. HDFC Bank, SBI, ICICI Bank',
                prefixIcon: const Icon(Iconsax.bank, color: AppColors.textColorSecondary, size: 18),
              ),
              const SizedBox(height: 16),

              _buildFieldTitle('Account Number', isRequired: true),
              const SizedBox(height: 6),
              AppInputField(
                controller: accountNumberController,
                hint: 'e.g. 50100456789123',
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Iconsax.card_edit, color: AppColors.textColorSecondary, size: 18),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldTitle('IFSC Code', isRequired: true),
                        const SizedBox(height: 6),
                        AppInputField(
                          controller: ifscCodeController,
                          hint: 'e.g. HDFC0001234',
                          prefixIcon: const Icon(Iconsax.code, color: AppColors.textColorSecondary, size: 18),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldTitle('Branch Name'),
                        const SizedBox(height: 6),
                        AppInputField(
                          controller: branchNameController,
                          hint: 'e.g. Indiranagar Branch',
                          prefixIcon: const Icon(Iconsax.buildings, color: AppColors.textColorSecondary, size: 18),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Dynamic Skills Adder
          _buildCard(
            title: 'Professional Skills & Tech Stack',
            icon: Iconsax.award,
            children: [
              _buildFieldTitle('Add Skill Tag'),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: AppInputField(
                      controller: skillInputController,
                      hint: 'e.g. Flutter, Sales, React, Python...',
                      prefixIcon: const Icon(Iconsax.tag, color: AppColors.textColorSecondary, size: 18),
                      onFieldSubmitted: (_) => _addSkill(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _addSkill,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, color: Colors.white, size: 18),
                        SizedBox(width: 4),
                        AppText('Add', color: Colors.white, fontWeight: FontWeight.bold),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Selected skills tags
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AppText('Added Skills:', fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textColorSecondary),
                  AppText('${_skillsList.length} skills added', fontSize: 11, color: AppColors.primaryColor, fontWeight: FontWeight.w700),
                ],
              ),
              const SizedBox(height: 8),

              if (_skillsList.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Center(
                    child: AppText('No skills added yet. Type above and click "Add"', fontSize: 12, color: AppColors.textColorHint),
                  ),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _skillsList.map((skill) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppText(skill, fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryColor),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => _removeSkill(skill),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: const Icon(Icons.close, size: 12, color: AppColors.primaryColor),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 16),
              const Divider(color: Color(0xFFF1F5F9)),
              const SizedBox(height: 8),

              // Popular skill suggestions
              const AppText('Popular Suggestions:', fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textColorSecondary),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  'Flutter',
                  'Dart',
                  'Firebase',
                  'Node.js',
                  'React Native',
                  'UI/UX',
                  'Sales',
                  'SEO',
                  'Lead Gen',
                  'HR Ops',
                ].where((s) => !_skillsList.contains(s)).map((suggested) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _skillsList.add(suggested);
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.add, size: 12, color: Color(0xFF64748B)),
                          const SizedBox(width: 4),
                          AppText(suggested, fontSize: 11, color: const Color(0xFF475569), fontWeight: FontWeight.w600),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // Persistent Bottom Action Bar
  // ----------------------------------------------------
  Widget _buildBottomBar() {
    final isLastStep = _currentStep == _totalSteps - 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -4),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentStep > 0) ...[
              Expanded(
                flex: 4,
                child: OutlinedButton(
                  onPressed: () => _goToStep(_currentStep - 1),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: AppColors.textColorPrimary),
                      SizedBox(width: 6),
                      AppText('Previous', fontSize: 14, fontWeight: FontWeight.w700),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              flex: 6,
              child: Obx(() => AppButton(
                text: isLastStep
                    ? (widget.employee == null ? 'Register Employee' : 'Save Changes')
                    : 'Save & Continue',
                color: AppColors.primaryColor,
                isLoading: controller.isSubmitting.value,
                onPressed: _handleNext,
              )),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // Helper Section Card
  // ----------------------------------------------------
  Widget _buildCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryColor, size: 20),
              const SizedBox(width: 10),
              AppText(title, fontSize: 15, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B)),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildFieldTitle(String title, {bool isRequired = false}) {
    return RichText(
      text: TextSpan(
        text: title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFF334155),
        ),
        children: [
          if (isRequired)
            const TextSpan(
              text: ' *',
              style: TextStyle(
                color: AppColors.errorColor,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : (items.isNotEmpty ? items.first : null),
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.textColorSecondary),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: AppText(item, fontSize: 13, fontWeight: FontWeight.w600),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
