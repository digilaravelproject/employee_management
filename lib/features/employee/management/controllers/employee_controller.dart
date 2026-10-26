import 'dart:async';
import 'dart:io';
import 'package:get/get.dart';
import '../../../../core/services/network/api_client.dart';
import '../../../../core/services/network/response_model.dart';
import '../../../../core/utils/custom_snackbar.dart';
import '../../../../core/utils/logger.dart';
import '../domain/usecases/create_employee_usecase.dart';
import '../models/create_employee_request_model.dart';
import '../models/create_employee_response_model.dart';
import '../models/employee_model.dart';
import '../repositories/employee_repository_interface.dart';
import '../repositories/employee_repository.dart';
import '../../designation/controllers/designation_controller.dart';

import '../../../departments/controllers/departments_controller.dart';
import '../../../shift_management/controllers/shift_controller.dart';

class EmployeeController extends GetxController {
  final CreateEmployeeUseCase? createEmployeeUseCase;
  final EmployeeRepositoryInterface? repository;

  EmployeeController({
    this.createEmployeeUseCase,
    this.repository,
  });

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isSubmitting = false.obs;
  final RxBool isDeleting = false.obs;
  final RxBool isUploadingAvatar = false.obs;
  var employees = <EmployeeModel>[].obs;
  var filteredEmployees = <EmployeeModel>[].obs;

  // Search API & In-memory Cache State
  final List<EmployeeModel> _allEmployeesCache = [];
  final RxBool isSearching = false.obs;
  Timer? _searchDebounceTimer;

  // Single Employee Detail State
  final Rx<EmployeeModel?> employeeDetail = Rx<EmployeeModel?>(null);
  final RxBool isLoadingDetail = false.obs;
  final RxString detailErrorMessage = ''.obs;

  EmployeeRepositoryInterface get _effectiveEmployeeRepository {
    if (repository != null) return repository!;
    if (Get.isRegistered<EmployeeRepositoryInterface>()) {
      return Get.find<EmployeeRepositoryInterface>();
    }
    final apiClient = Get.isRegistered<ApiClient>() ? Get.find<ApiClient>() : ApiClient();
    return EmployeeRepository(apiClient: apiClient);
  }

  CreateEmployeeUseCase get _effectiveCreateEmployeeUseCase {
    if (createEmployeeUseCase != null) return createEmployeeUseCase!;
    if (Get.isRegistered<CreateEmployeeUseCase>()) {
      return Get.find<CreateEmployeeUseCase>();
    }
    return CreateEmployeeUseCase(_effectiveEmployeeRepository);
  }

  // Search & Filter State
  var searchQuery = ''.obs;
  var filterDepartment = 'All'.obs;
  var filterDesignation = 'All'.obs;
  var filterTeam = 'All'.obs;
  var filterShift = 'All'.obs;
  var filterStatus = 'All'.obs; // 'All', 'Active', 'Inactive'
  var filterJoiningYear = 'All'.obs; // 'All', '2025', '2024', '2023'

  // Master Filter & Form Options
  List<String> get departmentsList {
    List<String> dynamicList = [];
    if (Get.isRegistered<DepartmentsController>()) {
      final deptCtrl = Get.find<DepartmentsController>();
      if (deptCtrl.departments.isNotEmpty) {
        dynamicList = deptCtrl.departments.map((d) => d.name).where((n) => n.isNotEmpty).toList();
      } else if (deptCtrl.apiDepartments.isNotEmpty) {
        dynamicList = deptCtrl.apiDepartments.map((d) => d.name).where((n) => n.isNotEmpty).toList();
      }
    }
    return ['All', ...dynamicList];
  }

  List<String> get teamsList {
    final list = employees
        .map((e) => e.team.trim())
        .where((t) => t.isNotEmpty)
        .toSet()
        .toList();
    list.sort();
    return ['All', ...list];
  }

  List<String> get shiftsList {
    List<String> dynamicList = [];
    if (Get.isRegistered<ShiftController>()) {
      final shiftCtrl = Get.find<ShiftController>();
      if (shiftCtrl.shifts.isNotEmpty) {
        dynamicList = shiftCtrl.shifts.map((s) => s.name).where((n) => n.isNotEmpty).toList();
      }
    }
    return ['All', ...dynamicList];
  }

  final List<String> statusList = [
    'All',
    'Active',
    'Probation',
    'Notice Period',
    'Terminated',
    'Inactive',
  ];

  // Employee Form Masters
  final List<String> workModesList = ['Office', 'Remote', 'Hybrid'];
  final List<String> employeeTypesList = ['Full-time', 'Part-time', 'Contract', 'Freelancer', 'Intern'];
  final List<String> employmentStatusesList = ['Active', 'Probation', 'Notice Period', 'Terminated', 'Inactive'];
  final List<String> probationPeriodsList = ['None', '1 Month', '3 Months', '6 Months'];
  final List<String> noticePeriodsList = ['15 Days', '30 Days', '60 Days', '90 Days'];
  final List<String> salaryTypesList = ['Monthly', 'Hourly', 'Weekly', 'Annual CTC'];
  final List<String> targetTypesList = ['Revenue', 'Deals Closed', 'Units Sold'];
  final List<String> targetPeriodsList = ['Monthly', 'Quarterly', 'Yearly'];

  List<String> get reportingManagersList {
    return employees
        .where((e) => e.name.isNotEmpty)
        .map((e) => e.designation.isNotEmpty ? '${e.name} (${e.designation})' : e.name)
        .toList();
  }

  List<String> get joiningYearsList {
    final years = employees
        .map((e) {
          if (e.joiningDate.isNotEmpty) {
            try {
              final dt = DateTime.tryParse(e.joiningDate);
              if (dt != null) return dt.year.toString();
            } catch (_) {}
          }
          return null;
        })
        .whereType<String>()
        .toSet()
        .toList();
    years.sort((a, b) => b.compareTo(a));
    return ['All', ...years];
  }

  List<String> get designations {
    if (Get.isRegistered<DesignationController>()) {
      final desigs = Get.find<DesignationController>().designations.map((d) => d.name).where((n) => n.isNotEmpty).toList();
      if (desigs.isNotEmpty) return desigs;
    }
    return [];
  }

  List<String> get filterDesignationsList => ['All', ...designations];

  // Skills
  var selectedSkills = <String>[].obs;
  var availableSkills = [
    'Flutter',
    'Dart',
    'React Native',
    'Python',
    'Node.js',
    'UI/UX',
    'Marketing',
    'Sales',
    'Firebase',
    'SQL',
    'HR Ops',
  ].obs;

  int get activeFiltersCount {
    int count = 0;
    if (filterDepartment.value != 'All') count++;
    if (filterDesignation.value != 'All') count++;
    if (filterTeam.value != 'All') count++;
    if (filterShift.value != 'All') count++;
    if (filterStatus.value != 'All') count++;
    if (filterJoiningYear.value != 'All') count++;
    return count;
  }

  @override
  void onInit() {
    super.onInit();
    fetchEmployees();
  }

  Future<void> fetchEmployees({bool showLoader = true}) async {
    try {
      if (showLoader) {
        isLoading.value = true;
      }
      errorMessage.value = '';

      Logger.d('EmployeeController => Fetching employees from API');
      final response = await _effectiveEmployeeRepository.getEmployees();

      if (response.status) {
        employees.assignAll(response.data);
        _allEmployeesCache.assignAll(response.data);
        applyFilters();
        Logger.d('EmployeeController => Loaded ${employees.length} employees from API');
      } else {
        errorMessage.value = response.message.isNotEmpty
            ? response.message
            : 'Failed to retrieve employees';
        Logger.w('EmployeeController => ${errorMessage.value}');
      }
    } catch (e) {
      Logger.e('EmployeeController => Error in fetchEmployees: $e');
      errorMessage.value = 'Failed to load employees. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<EmployeeModel?> fetchEmployeeDetail(String id, {bool showLoader = true}) async {
    try {
      if (showLoader) {
        isLoadingDetail.value = true;
      }
      detailErrorMessage.value = '';
      Logger.d('EmployeeController => Fetching employee detail for ID: $id');
      final response = await _effectiveEmployeeRepository.getEmployeeById(id);

      if (response.status && response.data != null) {
        employeeDetail.value = response.data;
        // Update in employees list if exists
        final index = employees.indexWhere((e) => e.id == id || e.employeeId == response.data!.employeeId);
        if (index != -1) {
          employees[index] = response.data!;
          applyFilters();
        }
        Logger.d('EmployeeController => Successfully retrieved details for ${response.data!.name}');
        return response.data;
      } else {
        detailErrorMessage.value = response.message.isNotEmpty
            ? response.message
            : 'Failed to retrieve employee details';
        Logger.w('EmployeeController => ${detailErrorMessage.value}');
      }
    } catch (e) {
      Logger.e('EmployeeController => Error in fetchEmployeeDetail: $e');
      detailErrorMessage.value = 'Failed to load employee details. Please try again.';
    } finally {
      isLoadingDetail.value = false;
    }
    return null;
  }

  void setEmployeeDetail(EmployeeModel employee) {
    employeeDetail.value = employee;
  }


  void filterEmployees(String query) {
    searchQuery.value = query;
    _searchDebounceTimer?.cancel();

    if (query.trim().isEmpty) {
      isSearching.value = false;
      if (_allEmployeesCache.isNotEmpty) {
        employees.assignAll(_allEmployeesCache);
      }
      applyFilters();
      return;
    }

    // Apply immediate local filter for instant responsiveness
    applyFilters();

    // Debounce remote search API call (350ms) without triggering full-screen loading spinners
    _searchDebounceTimer = Timer(const Duration(milliseconds: 350), () {
      searchEmployeesApi(query.trim());
    });
  }

  Future<void> searchEmployeesApi(String query) async {
    if (query.isEmpty) return;
    try {
      isSearching.value = true;
      Logger.d('EmployeeController => Calling search API for query: "$query"');
      final response = await _effectiveEmployeeRepository.searchEmployees(query);
      if (response.status) {
        // Ensure the active search query has not changed while waiting for API
        if (searchQuery.value.trim().toLowerCase() == query.trim().toLowerCase()) {
          employees.assignAll(response.data);
          applyFilters();
          Logger.d('EmployeeController => Search retrieved ${response.data.length} employees');
        }
      }
    } catch (e) {
      Logger.e('EmployeeController => Error in searchEmployeesApi: $e');
    } finally {
      isSearching.value = false;
    }
  }

  void applyFilters() {
    final query = searchQuery.value.trim().toLowerCase();

    filteredEmployees.assignAll(
      employees.where((e) {
        // Search query match
        final matchesQuery = query.isEmpty ||
            e.name.toLowerCase().contains(query) ||
            e.employeeId.toLowerCase().contains(query) ||
            e.designation.toLowerCase().contains(query) ||
            e.department.toLowerCase().contains(query) ||
            e.mobile.contains(query);

        // Department filter
        final matchesDept = filterDepartment.value == 'All' ||
            e.department.toLowerCase() == filterDepartment.value.toLowerCase();

        // Designation filter
        final matchesDesig = filterDesignation.value == 'All' ||
            e.designation.toLowerCase() == filterDesignation.value.toLowerCase();

        // Team filter
        final matchesTeam = filterTeam.value == 'All' ||
            e.team.toLowerCase() == filterTeam.value.toLowerCase();

        // Shift filter
        final matchesShift = filterShift.value == 'All' ||
            e.shift.toLowerCase() == filterShift.value.toLowerCase();

        // Status filter
        final matchesStatus = filterStatus.value == 'All' ||
            (filterStatus.value == 'Active' && (e.isActive || e.employmentStatus == 'Active')) ||
            (filterStatus.value == 'Inactive' && (!e.isActive || e.employmentStatus == 'Inactive')) ||
            e.employmentStatus.toLowerCase() == filterStatus.value.toLowerCase();

        // Joining Year filter
        final matchesYear = filterJoiningYear.value == 'All' ||
            e.joiningDate.contains(filterJoiningYear.value);

        return matchesQuery &&
            matchesDept &&
            matchesDesig &&
            matchesTeam &&
            matchesShift &&
            matchesStatus &&
            matchesYear;
      }).toList(),
    );
  }

  void resetFilters() {
    filterDepartment.value = 'All';
    filterDesignation.value = 'All';
    filterTeam.value = 'All';
    filterShift.value = 'All';
    filterStatus.value = 'All';
    filterJoiningYear.value = 'All';
    applyFilters();
  }

  void addEmployee(EmployeeModel employee) {
    employees.insert(0, employee);
    applyFilters();
  }

  Future<CreateEmployeeResponseModel> createEmployeeApi(CreateEmployeeRequestModel request) async {
    isSubmitting.value = true;
    try {
      final response = await _effectiveCreateEmployeeUseCase.execute(request);
      if (response.status) {
        String empId = response.data?.employeeId ?? request.employeeId;
        String newId = response.data?.id?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();

        final double sal = double.tryParse(request.monthlyBaseSalary) ?? 0.0;
        final newEmp = EmployeeModel(
          id: newId,
          employeeId: empId,
          name: response.data?.name ?? request.name,
          mobile: response.data?.mobileNumber ?? request.mobileNumber,
          alternateMobile: response.data?.alternateMobileNumber ?? request.alternateMobileNumber ?? '',
          email: response.data?.email ?? request.email,
          gender: response.data?.gender ?? request.gender,
          dob: response.data?.dateOfBirth ?? request.dateOfBirth,
          designation: response.data?.designation ?? request.designationId,
          department: response.data?.department ?? request.department,
          team: response.data?.team ?? request.team ?? 'Team Alpha',
          shift: request.assignedShiftId ?? 'Morning Shift',
          workMode: response.data?.workMode ?? request.workMode,
          employeeType: response.data?.employeeType ?? request.employeeType,
          employmentStatus: response.data?.employmentStatus ?? request.employmentStatus,
          probationPeriod: response.data?.probationPeriod ?? request.probationPeriod ?? '3 Months',
          noticePeriod: response.data?.noticePeriod ?? request.noticePeriod ?? '30 Days',
          joiningDate: response.data?.dateOfJoining ?? request.dateOfJoining,
          salaryType: response.data?.salaryType ?? request.salaryType,
          salary: sal,
          hasSalesTarget: request.salesTargetEnabled == '1',
          targetType: request.salesTargetMetricType ?? 'Revenue',
          targetAmount: request.salesTarget ?? '0',
          targetPeriod: request.salesTargetPeriod ?? 'Monthly',
          incentivePercent: request.incentiveCommissionPercent ?? '0',
          address: response.data?.streetAddress ?? request.streetAddress ?? '',
          city: response.data?.city ?? request.city ?? '',
          state: response.data?.state ?? request.state ?? '',
          pincode: response.data?.postalCode ?? request.postalCode ?? '',
          country: response.data?.country ?? request.country ?? 'India',
          emergencyContact: response.data?.emergencyContact ?? request.emergencyContact ?? '',
          accountHolderName: response.data?.accountHolderName ?? request.accountHolderName ?? '',
          bankName: response.data?.bankName ?? request.bankName ?? '',
          accountNumber: response.data?.accountNumber ?? request.accountNumber ?? '',
          ifscCode: response.data?.ifscCode ?? request.ifscCode ?? '',
          branchName: response.data?.branchName ?? request.branchName ?? '',
          skills: response.data?.skills.isNotEmpty == true ? response.data!.skills : request.skills,
          profilePic: response.data?.avatar,
          isActive: request.employmentStatus.toLowerCase() == 'active' || request.employmentStatus.toLowerCase() == 'probation',
        );

        addEmployee(newEmp);
        fetchEmployees(showLoader: false);
      }
      return response;
    } catch (e) {
      Logger.e('EmployeeController => Error in createEmployeeApi: $e');
      return CreateEmployeeResponseModel(
        status: false,
        message: e.toString(),
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<ResponseModel> updateEmployeeApi(
    String id,
    Map<String, dynamic> data,
    EmployeeModel updatedModel,
  ) async {
    isSubmitting.value = true;
    try {
      Logger.d('EmployeeController => Updating employee ID: $id');
      final response = await _effectiveEmployeeRepository.updateEmployee(id, data);

      if (response.isSuccess) {
        int index = employees.indexWhere((e) => e.id == id);
        if (index != -1) {
          employees[index] = updatedModel;
          applyFilters();
        }
        if (employeeDetail.value?.id == id) {
          employeeDetail.value = updatedModel;
        }
        // Sync fresh data from API in background
        fetchEmployeeDetail(id, showLoader: false);
        fetchEmployees(showLoader: false);
      }
      return response;
    } catch (e) {
      Logger.e('EmployeeController => Error in updateEmployeeApi: $e');
      return ResponseModel(
        isSuccess: false,
        message: 'Failed to update employee: ${e.toString()}',
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  void updateEmployee(EmployeeModel updatedEmployee) {
    int index = employees.indexWhere((e) => e.id == updatedEmployee.id);
    if (index != -1) {
      employees[index] = updatedEmployee;
      applyFilters();
    }
  }

  Future<bool> deleteEmployee(String id) async {
    isDeleting.value = true;
    try {
      Logger.d('EmployeeController => Deleting employee ID: $id');
      final response = await _effectiveEmployeeRepository.deleteEmployee(id);

      if (response.isSuccess) {
        employees.removeWhere((e) => e.id == id);
        applyFilters();
        if (employeeDetail.value?.id == id) {
          employeeDetail.value = null;
        }
        CustomSnackbar.showSuccess(
          response.message.isNotEmpty ? response.message : 'Employee removed successfully.',
          title: 'Deleted',
        );
        return true;
      } else {
        CustomSnackbar.showError(
          response.message.isNotEmpty ? response.message : 'Failed to delete employee.',
          title: 'Error',
        );
        return false;
      }
    } catch (e) {
      Logger.e('EmployeeController => Error in deleteEmployee: $e');
      CustomSnackbar.showError(
        'Failed to delete employee: ${e.toString()}',
        title: 'Error',
      );
      return false;
    } finally {
      isDeleting.value = false;
    }
  }

  Future<bool> updateEmployeeAvatar(String id, File imageFile) async {
    isUploadingAvatar.value = true;
    try {
      Logger.d('EmployeeController => Updating avatar for employee ID: $id');
      final response = await _effectiveEmployeeRepository.updateEmployeeAvatar(id, imageFile);

      if (response.isSuccess) {
        // Re-fetch detail in background to get new avatar URL
        await fetchEmployeeDetail(id, showLoader: false);
        fetchEmployees(showLoader: false);
        CustomSnackbar.showSuccess(
          response.message.isNotEmpty ? response.message : 'Profile image updated successfully!',
          title: 'Success',
        );
        return true;
      } else {
        CustomSnackbar.showError(
          response.message.isNotEmpty ? response.message : 'Failed to update profile image.',
          title: 'Error',
        );
        return false;
      }
    } catch (e) {
      Logger.e('EmployeeController => Error in updateEmployeeAvatar: $e');
      CustomSnackbar.showError(
        'Failed to update profile image: ${e.toString()}',
        title: 'Error',
      );
      return false;
    } finally {
      isUploadingAvatar.value = false;
    }
  }

  void toggleSkill(String skill) {
    if (selectedSkills.contains(skill)) {
      selectedSkills.remove(skill);
    } else {
      selectedSkills.add(skill);
    }
  }

  @override
  void onClose() {
    _searchDebounceTimer?.cancel();
    super.onClose();
  }
}
