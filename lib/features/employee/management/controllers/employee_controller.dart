import 'package:get/get.dart';
import '../../../../core/services/network/api_client.dart';
import '../../../../core/utils/logger.dart';
import '../domain/usecases/create_employee_usecase.dart';
import '../models/create_employee_request_model.dart';
import '../models/create_employee_response_model.dart';
import '../models/employee_model.dart';
import '../repositories/employee_repository.dart';
import '../../designation/controllers/designation_controller.dart';

import '../../../departments/controllers/departments_controller.dart';
import '../../../shift_management/controllers/shift_controller.dart';

class EmployeeController extends GetxController {
  final CreateEmployeeUseCase? createEmployeeUseCase;

  EmployeeController({
    this.createEmployeeUseCase,
  });

  final RxBool isSubmitting = false.obs;
  var employees = <EmployeeModel>[].obs;
  var filteredEmployees = <EmployeeModel>[].obs;

  CreateEmployeeUseCase get _effectiveCreateEmployeeUseCase {
    if (createEmployeeUseCase != null) return createEmployeeUseCase!;
    if (Get.isRegistered<CreateEmployeeUseCase>()) {
      return Get.find<CreateEmployeeUseCase>();
    }
    final apiClient = Get.isRegistered<ApiClient>() ? Get.find<ApiClient>() : ApiClient();
    final repo = EmployeeRepository(apiClient: apiClient);
    return CreateEmployeeUseCase(repo);
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
    if (dynamicList.isEmpty) {
      dynamicList = [
        'Engineering',
        'Human Resources',
        'Sales',
        'Marketing',
        'Support',
        'Operations',
      ];
    }
    return ['All', ...dynamicList];
  }

  final List<String> teamsList = [
    'All',
    'Team Alpha',
    'Team Beta',
    'Core Operations',
    'Growth Team',
  ];

  List<String> get shiftsList {
    List<String> dynamicList = [];
    if (Get.isRegistered<ShiftController>()) {
      final shiftCtrl = Get.find<ShiftController>();
      if (shiftCtrl.shifts.isNotEmpty) {
        dynamicList = shiftCtrl.shifts.map((s) => s.name).where((n) => n.isNotEmpty).toList();
      }
    }
    if (dynamicList.isEmpty) {
      dynamicList = [
        'Morning Shift',
        'Evening Shift',
        'Night Shift',
        'General Shift',
      ];
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
    final list = employees.map((e) => '${e.name} (${e.designation})').toList();
    if (list.isEmpty) {
      return ['Rajesh Verma (VP Engineering)', 'Ananya Roy (Director of HR)'];
    }
    return ['Rajesh Verma (VP Operations)', ...list];
  }

  final List<String> joiningYearsList = [
    'All',
    '2026',
    '2025',
    '2024',
    '2023',
  ];

  List<String> get designations {
    if (Get.isRegistered<DesignationController>()) {
      final desigs = Get.find<DesignationController>().designations.map((d) => d.name).toList();
      if (desigs.isNotEmpty) return desigs;
    }
    return [
      'Senior Flutter Developer',
      'Backend Developer',
      'Frontend Developer',
      'UI/UX Designer',
      'HR Manager',
      'QA Engineer',
      'Sales Executive',
      'Marketing Executive',
      'Operations Lead',
    ];
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
    _loadInitialMockData();
  }

  void _loadInitialMockData() {
    employees.assignAll([
      EmployeeModel(
        id: '1',
        employeeId: 'EMP-2025-001',
        name: 'Rohit Sharma',
        gender: 'Male',
        dob: '15 Aug 1993',
        mobile: '9876543210',
        alternateMobile: '9876543219',
        email: 'rohit.sharma@example.com',
        designation: 'Senior Flutter Developer',
        department: 'Engineering',
        team: 'Team Alpha',
        shift: 'Morning Shift',
        salary: 85000,
        salaryType: 'Monthly',
        skills: ['Flutter', 'Firebase', 'Dart'],
        joiningDate: '10 May 2024',
        address: '123, Tech Park, Indiranagar',
        city: 'Bengaluru',
        state: 'Karnataka',
        pincode: '560038',
        country: 'India',
        workMode: 'Hybrid',
        employeeType: 'Full-time',
        reportingManager: 'Rajesh Verma (VP Operations)',
        employmentStatus: 'Active',
        probationPeriod: 'Completed',
        noticePeriod: '30 Days',
        accountHolderName: 'Rohit Sharma',
        bankName: 'HDFC Bank',
        accountNumber: '50100456789123',
        ifscCode: 'HDFC0001234',
        branchName: 'Indiranagar Branch',
        isActive: true,
      ),
      EmployeeModel(
        id: '2',
        employeeId: 'EMP-2025-002',
        name: 'Neha Gupta',
        gender: 'Female',
        dob: '22 Oct 1995',
        mobile: '9876543211',
        alternateMobile: '9876543218',
        email: 'neha.gupta@example.com',
        designation: 'HR Manager',
        department: 'Human Resources',
        team: 'Core Operations',
        shift: 'General Shift',
        salary: 65000,
        salaryType: 'Monthly',
        skills: ['HR Ops', 'Recruitment', 'Operations'],
        joiningDate: '15 Jun 2024',
        address: '456, Green View, Bandra West',
        city: 'Mumbai',
        state: 'Maharashtra',
        pincode: '400050',
        country: 'India',
        workMode: 'Office',
        employeeType: 'Full-time',
        reportingManager: 'Rajesh Verma (VP Operations)',
        employmentStatus: 'Active',
        probationPeriod: 'Completed',
        noticePeriod: '60 Days',
        accountHolderName: 'Neha Gupta',
        bankName: 'ICICI Bank',
        accountNumber: '102345678901',
        ifscCode: 'ICIC0001023',
        branchName: 'Bandra West',
        isActive: true,
      ),
      EmployeeModel(
        id: '3',
        employeeId: 'EMP-2025-003',
        name: 'Amit Kumar',
        gender: 'Male',
        dob: '05 Jan 1994',
        mobile: '9876543212',
        alternateMobile: '',
        email: 'amit.kumar@example.com',
        designation: 'Sales Executive',
        department: 'Sales',
        team: 'Growth Team',
        shift: 'Morning Shift',
        salary: 55000,
        salaryType: 'Monthly',
        hasSalesTarget: true,
        targetType: 'Revenue',
        targetAmount: '500000',
        targetPeriod: 'Monthly',
        incentivePercent: '5',
        skills: ['Sales', 'Negotiation', 'CRM'],
        joiningDate: '01 Mar 2025',
        address: 'Sector 62, Commercial Hub',
        city: 'Noida',
        state: 'Uttar Pradesh',
        pincode: '201309',
        country: 'India',
        workMode: 'Office',
        employeeType: 'Full-time',
        reportingManager: 'Rajesh Verma (VP Operations)',
        employmentStatus: 'Active',
        probationPeriod: '3 Months',
        noticePeriod: '30 Days',
        accountHolderName: 'Amit Kumar',
        bankName: 'State Bank of India',
        accountNumber: '203456789012',
        ifscCode: 'SBIN0002034',
        branchName: 'Sector 62 Noida',
        isActive: true,
      ),
      EmployeeModel(
        id: '4',
        employeeId: 'EMP-2025-004',
        name: 'Priya Sharma',
        gender: 'Female',
        dob: '12 Dec 1996',
        mobile: '9876543213',
        alternateMobile: '',
        email: 'priya.sharma@example.com',
        designation: 'UI/UX Designer',
        department: 'Engineering',
        team: 'Team Alpha',
        shift: 'Morning Shift',
        salary: 60000,
        salaryType: 'Monthly',
        skills: ['UI/UX', 'Figma', 'Prototyping'],
        joiningDate: '18 Nov 2024',
        address: 'Indira Nagar, 2nd Stage',
        city: 'Bengaluru',
        state: 'Karnataka',
        pincode: '560038',
        country: 'India',
        workMode: 'Remote',
        employeeType: 'Contract',
        reportingManager: 'Rohit Sharma (Senior Flutter Developer)',
        employmentStatus: 'Probation',
        probationPeriod: '6 Months',
        noticePeriod: '15 Days',
        accountHolderName: 'Priya Sharma',
        bankName: 'Axis Bank',
        accountNumber: '912010045678901',
        ifscCode: 'UTIB0000912',
        branchName: 'Indiranagar',
        isActive: true,
      ),
      EmployeeModel(
        id: '5',
        employeeId: 'EMP-2025-005',
        name: 'Vikram Joshi',
        gender: 'Male',
        dob: '30 Mar 1992',
        mobile: '9876543214',
        alternateMobile: '9876543220',
        email: 'vikram.joshi@example.com',
        designation: 'Backend Developer',
        department: 'Engineering',
        team: 'Team Beta',
        shift: 'Night Shift',
        salary: 78000,
        salaryType: 'Monthly',
        skills: ['Node.js', 'Python', 'SQL'],
        joiningDate: '05 Jan 2024',
        address: 'Kothrud, Mayur Colony',
        city: 'Pune',
        state: 'Maharashtra',
        pincode: '411038',
        country: 'India',
        workMode: 'Remote',
        employeeType: 'Full-time',
        reportingManager: 'Rajesh Verma (VP Operations)',
        employmentStatus: 'Notice Period',
        probationPeriod: 'Completed',
        noticePeriod: '90 Days',
        accountHolderName: 'Vikram Joshi',
        bankName: 'Kotak Mahindra Bank',
        accountNumber: '4011234567',
        ifscCode: 'KKBK0004011',
        branchName: 'Kothrud Pune',
        isActive: true,
      ),
      EmployeeModel(
        id: '6',
        employeeId: 'EMP-2025-006',
        name: 'Anjali Verma',
        gender: 'Female',
        dob: '14 Sep 1997',
        mobile: '9876543215',
        alternateMobile: '',
        email: 'anjali.verma@example.com',
        designation: 'QA Engineer',
        department: 'Engineering',
        team: 'Team Beta',
        shift: 'Evening Shift',
        salary: 50000,
        salaryType: 'Monthly',
        skills: ['Testing', 'Automation'],
        joiningDate: '12 Feb 2025',
        address: 'Salt Lake, Sector V',
        city: 'Kolkata',
        state: 'West Bengal',
        pincode: '700091',
        country: 'India',
        workMode: 'Office',
        employeeType: 'Part-time',
        reportingManager: 'Rohit Sharma (Senior Flutter Developer)',
        employmentStatus: 'Terminated',
        probationPeriod: 'None',
        noticePeriod: '15 Days',
        accountHolderName: 'Anjali Verma',
        bankName: 'Punjab National Bank',
        accountNumber: '0123001500045678',
        ifscCode: 'PUNB0012300',
        branchName: 'Salt Lake',
        isActive: false,
      ),
    ]);
    applyFilters();
  }

  void filterEmployees(String query) {
    searchQuery.value = query;
    applyFilters();
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

  void updateEmployee(EmployeeModel updatedEmployee) {
    int index = employees.indexWhere((e) => e.id == updatedEmployee.id);
    if (index != -1) {
      employees[index] = updatedEmployee;
      applyFilters();
    }
  }

  void deleteEmployee(String id) {
    employees.removeWhere((e) => e.id == id);
    applyFilters();
  }

  void toggleSkill(String skill) {
    if (selectedSkills.contains(skill)) {
      selectedSkills.remove(skill);
    } else {
      selectedSkills.add(skill);
    }
  }
}
