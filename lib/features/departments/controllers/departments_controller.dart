import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../role_permissions/models/role_permission_models.dart';
import '../../employee/management/controllers/employee_controller.dart';
import '../models/department_model.dart';
import '../models/department_api_model.dart';
import '../models/department_request_model.dart';
import '../repositories/department_repository.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../../../core/utils/logger.dart';

class DepartmentsController extends GetxController {
  final DepartmentRepository? repository;

  DepartmentsController({this.repository});

  // Backward compatible allEmployees list (used by external widgets like AudiencePicker)
  final List<AppUser> allEmployees = const [
    AppUser(name: 'John Smith', email: 'john.smith@example.com', avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150'),
    AppUser(name: 'Sarah Johnson', email: 'sarah.johnson@example.com', avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150'),
    AppUser(name: 'Michael Brown', email: 'michael.brown@example.com', avatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150'),
    AppUser(name: 'David Wilson', email: 'david.wilson@example.com', avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150'),
    AppUser(name: 'Emily Davis', email: 'emily.davis@example.com', avatarUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150'),
    AppUser(name: 'James Anderson', email: 'james.anderson@example.com', avatarUrl: 'https://images.unsplash.com/photo-1463453091185-61582044d556?w=150'),
    AppUser(name: 'Alex Johnson', email: 'alex.johnson@example.com', avatarUrl: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=150'),
    AppUser(name: 'Lisa Anderson', email: 'lisa.anderson@example.com', avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150'),
    AppUser(name: 'Robert Taylor', email: 'robert.taylor@example.com', avatarUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=150'),
  ];

  // Reactive list of departments
  final RxList<Department> departments = <Department>[].obs;
  final RxList<DepartmentApiModel> apiDepartments = <DepartmentApiModel>[].obs;

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool isAddingEmployees = false.obs;
  final RxBool isSearching = false.obs;

  // Search state
  final RxString searchQuery = ''.obs;
  Timer? _searchDebounce;

  // Status toggle (for create/edit form)
  final RxString formStatus = 'Active'.obs;

  // Forms / Creation Observables
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final Rxn<DepartmentMemberModel> selectedHead = Rxn<DepartmentMemberModel>();
  final RxList<DepartmentMemberModel> selectedEmployees = <DepartmentMemberModel>[].obs;

  // Selected Department for Details / Edit Screen
  final Rxn<Department> selectedDepartment = Rxn<Department>();
  final Rxn<DepartmentApiModel> selectedApiDepartment = Rxn<DepartmentApiModel>();

  // Available system employees for assignment
  List<DepartmentMemberModel> get availableEmployees {
    final empCtrl = Get.isRegistered<EmployeeController>()
        ? Get.find<EmployeeController>()
        : Get.put(EmployeeController());

    if (empCtrl.employees.isNotEmpty) {
      return empCtrl.employees.map((e) {
        return DepartmentMemberModel(
          id: int.tryParse(e.id) ?? 0,
          employeeId: e.employeeId,
          name: e.name,
          email: e.email,
          avatar: e.profilePic,
          designation: e.designation,
          status: e.isActive ? 'active' : 'inactive',
        );
      }).toList();
    }
    return [];
  }

  @override
  void onInit() {
    super.onInit();
    // Ensure live employee data is fetched
    final empCtrl = Get.isRegistered<EmployeeController>()
        ? Get.find<EmployeeController>()
        : Get.put(EmployeeController());
    if (empCtrl.employees.isEmpty) {
      empCtrl.fetchEmployees(showLoader: false);
    }

    if (repository != null) {
      fetchDepartments();
    } else {
      _initializeDummyDepartments();
    }
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    nameController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  // ── API Methods ──────────────────────────────────────────────────────────

  Future<void> fetchDepartments({String status = 'Active'}) async {
    if (repository == null) return;
    try {
      isLoading.value = true;
      final response = await repository!.getDepartments(status: status);
      if (response.status) {
        apiDepartments.assignAll(response.data);
        departments.assignAll(response.data.map(_apiModelToUiModel).toList());
      } else {
        CustomSnackbar.showError(response.message);
      }
    } catch (e) {
      Logger.e('DepartmentsController => fetchDepartments: $e');
      CustomSnackbar.showError('Failed to fetch departments');
    } finally {
      isLoading.value = false;
    }
  }

  /// Called when the search field changes. Debounces 400ms then hits the API.
  void onSearch(String query) {
    searchQuery.value = query;
    _searchDebounce?.cancel();

    if (query.trim().isEmpty) {
      fetchDepartments();
      return;
    }

    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      _searchDepartments(query.trim());
    });
  }

  Future<void> _searchDepartments(String query) async {
    if (repository == null) return;
    try {
      isSearching.value = true;
      final response = await repository!.searchDepartments(query);
      if (response.status) {
        apiDepartments.assignAll(response.data);
        departments.assignAll(response.data.map(_apiModelToUiModel).toList());
      }
    } catch (e) {
      Logger.e('DepartmentsController => _searchDepartments: $e');
    } finally {
      isSearching.value = false;
    }
  }

  Future<DepartmentApiModel?> fetchDepartmentDetails(String id) async {
    if (repository == null) return null;
    try {
      final response = await repository!.getDepartmentDetails(id);
      if (response.status && response.data != null) {
        return response.data;
      }
      return null;
    } catch (e) {
      Logger.e('DepartmentsController => fetchDepartmentDetails: $e');
      return null;
    }
  }

  Future<bool> createDepartmentApi() async {
    if (repository == null) return false;

    final name = nameController.text.trim();
    if (name.isEmpty) {
      CustomSnackbar.showError('Department Name is required!');
      return false;
    }

    try {
      isSaving.value = true;
      final request = DepartmentRequestModel(
        name: name,
        description: descriptionController.text.trim(),
        status: formStatus.value,
        headUserId: selectedHead.value?.id,
        employeeIds: selectedEmployees.isNotEmpty ? selectedEmployees.map((e) => e.id).toList() : null,
      );
      final response = await repository!.createDepartment(request);

      if (response.status && response.data != null) {
        final uiModel = _apiModelToUiModel(response.data!);
        departments.add(uiModel);
        apiDepartments.add(response.data!);
        clearForm();
        return true;
      } else {
        CustomSnackbar.showError(response.message);
        return false;
      }
    } catch (e) {
      Logger.e('DepartmentsController => createDepartmentApi: $e');
      CustomSnackbar.showError('Something went wrong');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> updateDepartmentApi([String? id]) async {
    if (repository == null) return false;

    final targetId = id ?? selectedApiDepartment.value?.id.toString() ?? selectedDepartment.value?.id;
    if (targetId == null) {
      CustomSnackbar.showError('Department ID not found');
      return false;
    }

    final name = nameController.text.trim();
    if (name.isEmpty) {
      CustomSnackbar.showError('Department Name is required!');
      return false;
    }

    try {
      isSaving.value = true;
      final request = DepartmentRequestModel(
        name: name,
        description: descriptionController.text.trim(),
        status: formStatus.value,
        headUserId: selectedHead.value?.id,
        employeeIds: selectedEmployees.map((e) => e.id).toList(),
      );
      final response = await repository!.updateDepartment(targetId, request);

      if (response.status && response.data != null) {
        final updatedData = response.data!;
        final uiModel = _apiModelToUiModel(updatedData);

        final apiIdx = apiDepartments.indexWhere((d) => d.id.toString() == targetId);
        if (apiIdx != -1) {
          apiDepartments[apiIdx] = updatedData;
        } else {
          apiDepartments.add(updatedData);
        }

        final idx = departments.indexWhere((d) => d.id == targetId);
        if (idx != -1) departments[idx] = uiModel;

        selectedApiDepartment.value = updatedData;
        selectedDepartment.value = uiModel;
        clearForm();
        return true;
      } else {
        CustomSnackbar.showError(response.message);
        return false;
      }
    } catch (e) {
      Logger.e('DepartmentsController => updateDepartmentApi: $e');
      CustomSnackbar.showError('Something went wrong');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> deleteDepartmentApi(String id) async {
    if (repository == null) return false;

    try {
      final response = await repository!.deleteDepartment(id);
      if (response.status) {
        departments.removeWhere((d) => d.id == id);
        apiDepartments.removeWhere((d) => d.id.toString() == id);
        selectedDepartment.value = null;
        selectedApiDepartment.value = null;
        return true;
      } else {
        CustomSnackbar.showError(response.message);
        return false;
      }
    } catch (e) {
      Logger.e('DepartmentsController => deleteDepartmentApi: $e');
      CustomSnackbar.showError('Failed to delete department');
      return false;
    }
  }

  Future<bool> addEmployeesToDepartment(String departmentId, List<int> employeeIds) async {
    if (repository == null) {
      CustomSnackbar.showError('Repository not available');
      return false;
    }

    if (employeeIds.isEmpty) {
      CustomSnackbar.showError('Please select at least one employee');
      return false;
    }

    try {
      isAddingEmployees.value = true;
      final response = await repository!.addEmployeesToDepartment(departmentId, employeeIds);

      if (response.status && response.data != null) {
        final updatedData = response.data!;
        final uiModel = _apiModelToUiModel(updatedData);

        final apiIdx = apiDepartments.indexWhere((d) => d.id.toString() == departmentId);
        if (apiIdx != -1) {
          apiDepartments[apiIdx] = updatedData;
        } else {
          apiDepartments.add(updatedData);
        }

        final idx = departments.indexWhere((d) => d.id == departmentId);
        if (idx != -1) {
          departments[idx] = uiModel;
        }

        selectedApiDepartment.value = updatedData;
        selectedDepartment.value = uiModel;
        selectedEmployees.assignAll(updatedData.employees);

        CustomSnackbar.showSuccess(
          response.message.isNotEmpty ? response.message : 'Employees added successfully.',
        );
        fetchDepartments();
        return true;
      } else {
        CustomSnackbar.showError(
          response.message.isNotEmpty ? response.message : 'Failed to add employees',
        );
        return false;
      }
    } catch (e) {
      Logger.e('DepartmentsController => addEmployeesToDepartment: $e');
      CustomSnackbar.showError('Something went wrong while adding employees');
      return false;
    } finally {
      isAddingEmployees.value = false;
    }
  }

  Future<bool> removeEmployeeFromDepartmentApi(String departmentId, String employeeId) async {
    if (repository == null) return false;

    try {
      final response = await repository!.removeEmployeeFromDepartment(departmentId, employeeId);
      if (response.status) {
        if (response.data != null) {
          final updatedData = response.data!;
          final uiModel = _apiModelToUiModel(updatedData);
          final apiIdx = apiDepartments.indexWhere((d) => d.id.toString() == departmentId);
          if (apiIdx != -1) apiDepartments[apiIdx] = updatedData;
          final idx = departments.indexWhere((d) => d.id == departmentId);
          if (idx != -1) departments[idx] = uiModel;
          selectedApiDepartment.value = updatedData;
          selectedEmployees.assignAll(updatedData.employees);
        } else {
          selectedEmployees.removeWhere((e) => e.id.toString() == employeeId);
        }
        fetchDepartments();
        return true;
      } else {
        CustomSnackbar.showError(response.message);
        return false;
      }
    } catch (e) {
      Logger.e('DepartmentsController => removeEmployeeFromDepartmentApi: $e');
      CustomSnackbar.showError('Failed to remove employee');
      return false;
    }
  }

  // ── Local helper ─────────────────────────────────────────────────────────

  Department _apiModelToUiModel(DepartmentApiModel api) {
    return Department(
      id: api.id.toString(),
      name: api.name,
      description: api.description ?? '',
      employees: [],
      teamsCount: api.teamCount,
      icon: _getIconForDepartmentName(api.name),
      themeColor: _getThemeColorForDepartmentName(api.name),
    );
  }

  // ── Reactive list of departments filtered by search query ─────────────────
  List<Department> get filteredDepartments {
    if (searchQuery.isEmpty) return departments;
    return departments
        .where((dept) => dept.name.toLowerCase().contains(searchQuery.value.toLowerCase()))
        .toList();
  }

  // ── Form helpers ─────────────────────────────────────────────────────────

  void clearForm() {
    nameController.clear();
    descriptionController.clear();
    selectedHead.value = null;
    selectedEmployees.clear();
    formStatus.value = 'Active';
    selectedApiDepartment.value = null;
  }

  void populateFormFromApi(DepartmentApiModel dept) {
    selectedApiDepartment.value = dept;
    nameController.text = dept.name;
    descriptionController.text = dept.description ?? '';
    formStatus.value = dept.status.isNotEmpty ? dept.status : 'Active';
    selectedHead.value = dept.head;
    selectedEmployees.assignAll(dept.employees);
  }

  void populateForm(Department dept) {
    nameController.text = dept.name;
    descriptionController.text = dept.description;
    final apiDept = apiDepartments.firstWhereOrNull((d) => d.id.toString() == dept.id);
    if (apiDept != null) {
      populateFormFromApi(apiDept);
    } else {
      formStatus.value = 'Active';
      selectedHead.value = null;
      selectedEmployees.clear();
    }
  }

  // ── Save / Update Actions ────────────────────────────────────────────────

  void saveDepartment() {
    if (repository != null) {
      createDepartmentApi().then((success) {
        if (success) {
          Get.back();
          CustomSnackbar.showSuccess('Department added successfully!');
        }
      });
      return;
    }

    if (nameController.text.trim().isEmpty) {
      CustomSnackbar.showError('Department Name is required!');
      return;
    }

    final newDept = Department(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: nameController.text.trim(),
      description: descriptionController.text.trim(),
      head: null,
      employees: const [],
      teamsCount: 5,
      icon: _getIconForDepartmentName(nameController.text.trim()),
      themeColor: _getThemeColorForDepartmentName(nameController.text.trim()),
    );

    departments.add(newDept);
    clearForm();
    Get.back();
    CustomSnackbar.showSuccess('Department added successfully!');
  }

  void updateDepartment([String? id]) {
    final targetId = id ?? selectedApiDepartment.value?.id.toString() ?? selectedDepartment.value?.id;
    if (targetId == null) return;

    if (repository != null) {
      updateDepartmentApi(targetId).then((success) {
        if (success) {
          Get.back();
          CustomSnackbar.showSuccess('Department updated successfully.');
        }
      });
      return;
    }

    if (nameController.text.trim().isEmpty) {
      CustomSnackbar.showError('Department Name is required!');
      return;
    }

    final current = selectedDepartment.value;
    if (current != null) {
      final updated = current.copyWith(
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
      );
      final idx = departments.indexWhere((dept) => dept.id == current.id);
      if (idx != -1) departments[idx] = updated;
      selectedDepartment.value = updated;
    }
    clearForm();
    Get.back();
    CustomSnackbar.showSuccess('Department updated successfully.');
  }

  void deleteDepartment(String id) {
    if (repository != null) {
      deleteDepartmentApi(id).then((success) {
        if (success) {
          Get.back();
          CustomSnackbar.showSuccess('Department deleted successfully!');
        }
      });
      return;
    }

    departments.removeWhere((dept) => dept.id == id);
    selectedDepartment.value = null;
    Get.back();
    CustomSnackbar.showSuccess('Department deleted successfully!');
  }

  void toggleEmployeeSelection(DepartmentMemberModel user) {
    final exists = selectedEmployees.any((e) => e.id == user.id);
    if (exists) {
      selectedEmployees.removeWhere((e) => e.id == user.id);
    } else {
      selectedEmployees.add(user);
    }
  }

  void assignHead(DepartmentMemberModel user) {
    selectedHead.value = user;
    if (!selectedEmployees.any((e) => e.id == user.id)) {
      selectedEmployees.add(user);
    }
  }

  void unassignHead() {
    selectedHead.value = null;
  }

  void removeEmployee(DepartmentMemberModel user) {
    selectedEmployees.removeWhere((e) => e.id == user.id);
    if (selectedHead.value?.id == user.id) {
      selectedHead.value = null;
    }
  }

  // ── Icon / Color mapping ─────────────────────────────────────────────────

  IconData _getIconForDepartmentName(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('tech') || lower.contains('eng') || lower.contains('code') || lower.contains('dev') || lower.contains('product')) {
      return Iconsax.code;
    } else if (lower.contains('hr') || lower.contains('people') || lower.contains('recruit') || lower.contains('human')) {
      return Iconsax.user_octagon;
    } else if (lower.contains('market') || lower.contains('advert') || lower.contains('social')) {
      return Iconsax.volume_high;
    } else if (lower.contains('finance') || lower.contains('money') || lower.contains('audit') || lower.contains('pay')) {
      return Iconsax.empty_wallet;
    } else if (lower.contains('sale') || lower.contains('deal') || lower.contains('revenue')) {
      return Iconsax.graph;
    } else if (lower.contains('support') || lower.contains('it') || lower.contains('help')) {
      return Iconsax.monitor;
    }
    return Iconsax.category;
  }

  Color _getThemeColorForDepartmentName(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('tech') || lower.contains('eng') || lower.contains('code') || lower.contains('dev') || lower.contains('product')) {
      return const Color(0xFF6366F1);
    } else if (lower.contains('hr') || lower.contains('people') || lower.contains('recruit') || lower.contains('human')) {
      return const Color(0xFFEC4899);
    } else if (lower.contains('market') || lower.contains('advert') || lower.contains('social')) {
      return const Color(0xFF10B981);
    } else if (lower.contains('finance') || lower.contains('money') || lower.contains('audit') || lower.contains('pay')) {
      return const Color(0xFFF59E0B);
    } else if (lower.contains('sale') || lower.contains('deal') || lower.contains('revenue')) {
      return const Color(0xFF3B82F6);
    } else if (lower.contains('support') || lower.contains('it') || lower.contains('help')) {
      return const Color(0xFF06B6D4);
    }
    return const Color(0xFF8B5CF6);
  }

  // ── Dummy data ───────────────────────────────────────────────────────────

  void _initializeDummyDepartments() {
    departments.addAll([
      Department(id: '1', name: 'Engineering', description: 'Handles all engineering and product development activities.', head: null, employees: const [], teamsCount: 5, icon: Iconsax.code, themeColor: const Color(0xFF6366F1)),
      Department(id: '2', name: 'Human Resources', description: 'Manages employee recruitment, onboarding, benefits, and workplace culture.', head: null, employees: const [], teamsCount: 3, icon: Iconsax.user_octagon, themeColor: const Color(0xFFEC4899)),
      Department(id: '3', name: 'Marketing', description: 'Promotes brand growth, social media presence, and strategic campaigns.', head: null, employees: const [], teamsCount: 4, icon: Iconsax.volume_high, themeColor: const Color(0xFF10B981)),
      Department(id: '4', name: 'Finance', description: 'Oversees payroll, budgets, financial audits, and investment metrics.', head: null, employees: const [], teamsCount: 2, icon: Iconsax.empty_wallet, themeColor: const Color(0xFFF59E0B)),
      Department(id: '5', name: 'Sales', description: 'Generates client deals, client management, and revenue expansion.', head: null, employees: const [], teamsCount: 4, icon: Iconsax.graph, themeColor: const Color(0xFF3B82F6)),
      Department(id: '6', name: 'IT Support', description: 'Administers server operations, security settings, and technical support.', head: null, employees: const [], teamsCount: 2, icon: Iconsax.monitor, themeColor: const Color(0xFF06B6D4)),
    ]);
  }
}
