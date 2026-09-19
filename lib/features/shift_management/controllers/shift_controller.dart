import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/utils/logger.dart';
import '../domain/usecases/assign_shift_usecase.dart';
import '../domain/usecases/create_shift_usecase.dart';
import '../domain/usecases/delete_shift_usecase.dart';
import '../domain/usecases/get_shift_details_usecase.dart';
import '../domain/usecases/get_shifts_usecase.dart';
import '../domain/usecases/update_shift_usecase.dart';
import '../models/create_shift_request_model.dart';
import '../models/shift_model.dart';
import '../models/shift_response_model.dart';
import '../repositories/shift_repository.dart';

class ShiftController extends GetxController {
  final CreateShiftUseCase? createShiftUseCase;
  final UpdateShiftUseCase? updateShiftUseCase;
  final DeleteShiftUseCase? deleteShiftUseCase;
  final GetShiftsUseCase? getShiftsUseCase;
  final GetShiftDetailsUseCase? getShiftDetailsUseCase;
  final AssignShiftUseCase? assignShiftUseCase;

  ShiftController({
    this.createShiftUseCase,
    this.updateShiftUseCase,
    this.deleteShiftUseCase,
    this.getShiftsUseCase,
    this.getShiftDetailsUseCase,
    this.assignShiftUseCase,
  });

  final RxList<ShiftModel> shifts = <ShiftModel>[].obs;
  final RxList<ShiftHistoryModel> historyList = <ShiftHistoryModel>[].obs;

  final Rxn<ShiftDataModel> selectedShiftDetails = Rxn<ShiftDataModel>();
  final RxBool isLoadingDetails = false.obs;

  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedType = 'All Types'.obs;
  final RxString selectedStatus = 'All Status'.obs;

  final List<String> typeFilterOptions = [
    'All Types',
    'Fixed Shift',
    'Flexible Shift',
    'Night Shift',
    'Rotational Shift',
  ];

  final List<String> statusFilterOptions = [
    'All Status',
    'Active',
    'Inactive',
  ];

  CreateShiftUseCase get _effectiveCreateShiftUseCase {
    if (createShiftUseCase != null) return createShiftUseCase!;
    if (Get.isRegistered<CreateShiftUseCase>()) {
      return Get.find<CreateShiftUseCase>();
    }
    final apiClient = Get.isRegistered<ApiClient>() ? Get.find<ApiClient>() : ApiClient();
    final repo = ShiftRepository(apiClient: apiClient);
    return CreateShiftUseCase(repo);
  }

  UpdateShiftUseCase get _effectiveUpdateShiftUseCase {
    if (updateShiftUseCase != null) return updateShiftUseCase!;
    if (Get.isRegistered<UpdateShiftUseCase>()) {
      return Get.find<UpdateShiftUseCase>();
    }
    final apiClient = Get.isRegistered<ApiClient>() ? Get.find<ApiClient>() : ApiClient();
    final repo = ShiftRepository(apiClient: apiClient);
    return UpdateShiftUseCase(repo);
  }

  DeleteShiftUseCase get _effectiveDeleteShiftUseCase {
    if (deleteShiftUseCase != null) return deleteShiftUseCase!;
    if (Get.isRegistered<DeleteShiftUseCase>()) {
      return Get.find<DeleteShiftUseCase>();
    }
    final apiClient = Get.isRegistered<ApiClient>() ? Get.find<ApiClient>() : ApiClient();
    final repo = ShiftRepository(apiClient: apiClient);
    return DeleteShiftUseCase(repo);
  }

  GetShiftsUseCase get _effectiveGetShiftsUseCase {
    if (getShiftsUseCase != null) return getShiftsUseCase!;
    if (Get.isRegistered<GetShiftsUseCase>()) {
      return Get.find<GetShiftsUseCase>();
    }
    final apiClient = Get.isRegistered<ApiClient>() ? Get.find<ApiClient>() : ApiClient();
    final repo = ShiftRepository(apiClient: apiClient);
    return GetShiftsUseCase(repo);
  }

  GetShiftDetailsUseCase get _effectiveGetShiftDetailsUseCase {
    if (getShiftDetailsUseCase != null) return getShiftDetailsUseCase!;
    if (Get.isRegistered<GetShiftDetailsUseCase>()) {
      return Get.find<GetShiftDetailsUseCase>();
    }
    final apiClient = Get.isRegistered<ApiClient>() ? Get.find<ApiClient>() : ApiClient();
    final repo = ShiftRepository(apiClient: apiClient);
    return GetShiftDetailsUseCase(repo);
  }

  AssignShiftUseCase get _effectiveAssignShiftUseCase {
    if (assignShiftUseCase != null) return assignShiftUseCase!;
    if (Get.isRegistered<AssignShiftUseCase>()) {
      return Get.find<AssignShiftUseCase>();
    }
    final apiClient = Get.isRegistered<ApiClient>() ? Get.find<ApiClient>() : ApiClient();
    final repo = ShiftRepository(apiClient: apiClient);
    return AssignShiftUseCase(repo);
  }

  @override
  void onInit() {
    super.onInit();
    _loadInitialHistory();
    fetchShifts();
  }

  Future<void> fetchShifts({String? status}) async {
    isLoading.value = true;
    try {
      final statusParam = status ?? (selectedStatus.value == 'All Status' ? null : selectedStatus.value);
      final response = await _effectiveGetShiftsUseCase.execute(status: statusParam);
      if (response.status && response.data.isNotEmpty) {
        final mappedShifts = response.data.map((d) => ShiftModel.fromDataModel(d)).toList();
        shifts.assignAll(mappedShifts);
      } else if (response.status && response.data.isEmpty) {
        shifts.clear();
      }
    } catch (e) {
      Logger.e('ShiftController => Error fetching shifts: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<ShiftDataModel?> fetchShiftDetails(String id) async {
    isLoadingDetails.value = true;
    try {
      final response = await _effectiveGetShiftDetailsUseCase.execute(id);
      if (response.status && response.data != null) {
        selectedShiftDetails.value = response.data;
        return response.data;
      }
      return null;
    } catch (e) {
      Logger.e('ShiftController => Error fetching shift details for id $id: $e');
      return null;
    } finally {
      isLoadingDetails.value = false;
    }
  }

  void _loadInitialHistory() {
    historyList.assignAll([
      ShiftHistoryModel(
        date: '10 Sep 2026',
        userName: 'Firoz Mohammad',
        action: 'Updated',
        details: 'Grace Period: 10 min → 15 min',
        actionColor: Colors.blue,
      ),
      ShiftHistoryModel(
        date: '08 Sep 2026',
        userName: 'Admin',
        action: 'Assigned',
        details: '5 employees assigned to Morning Shift',
        actionColor: Colors.green,
      ),
      ShiftHistoryModel(
        date: '01 Sep 2026',
        userName: 'Firoz Mohammad',
        action: 'Created',
        details: 'Created Morning Shift (10:00 AM - 07:00 PM)',
        actionColor: Colors.purple,
      ),
      ShiftHistoryModel(
        date: '28 Aug 2026',
        userName: 'Admin',
        action: 'Updated',
        details: 'Break Time: 01:00 PM - 02:00 PM (Paid)',
        actionColor: Colors.blue,
      ),
      ShiftHistoryModel(
        date: '20 Aug 2026',
        userName: 'Firoz Mohammad',
        action: 'Updated',
        details: 'Overtime rule: Enabled (starts after 08:00 Hours)',
        actionColor: Colors.orange,
      ),
      ShiftHistoryModel(
        date: '15 Aug 2026',
        userName: 'Admin',
        action: 'Deactivated',
        details: 'Flexible Shift set to inactive',
        actionColor: Colors.redAccent,
      ),
    ]);
  }

  // Getters for Stats
  int get totalShifts => shifts.length;
  int get totalEmployees => shifts.fold<int>(0, (sum, s) => sum + s.employeesCount);
  int get activeShifts => shifts.where((s) => s.isActive).length;
  int get inactiveShifts => shifts.where((s) => !s.isActive).length;

  List<ShiftModel> get filteredShifts {
    final query = searchQuery.value.trim().toLowerCase();
    return shifts.where((shift) {
      final matchesQuery = query.isEmpty ||
          shift.name.toLowerCase().contains(query) ||
          shift.code.toLowerCase().contains(query);

      final matchesType = selectedType.value == 'All Types' ||
          shift.type.toLowerCase().contains(selectedType.value.toLowerCase().replaceAll(' shift', ''));

      final matchesStatus = selectedStatus.value == 'All Status' ||
          (selectedStatus.value == 'Active' ? shift.isActive : !shift.isActive);

      return matchesQuery && matchesType && matchesStatus;
    }).toList();
  }

  Future<ShiftResponseModel> createShiftApi(CreateShiftRequestModel request) async {
    isSubmitting.value = true;
    try {
      final response = await _effectiveCreateShiftUseCase.execute(request);
      if (response.status && response.data != null) {
        final data = response.data!;
        final newShift = ShiftModel.fromDataModel(data);
        addShift(newShift);
      }
      return response;
    } catch (e) {
      return ShiftResponseModel(
        status: false,
        message: e.toString(),
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<ShiftResponseModel> updateShiftApi(String id, CreateShiftRequestModel request) async {
    isSubmitting.value = true;
    try {
      final response = await _effectiveUpdateShiftUseCase.execute(id, request);
      if (response.status && response.data != null) {
        final data = response.data!;
        final updatedShift = ShiftModel.fromDataModel(data);
        final index = shifts.indexWhere((s) => s.id == id || s.id == data.id.toString());
        if (index != -1) {
          shifts[index] = updatedShift;
        } else {
          shifts.insert(0, updatedShift);
        }
        shifts.refresh();
        selectedShiftDetails.value = data;

        historyList.insert(
          0,
          ShiftHistoryModel(
            date: 'Today',
            userName: 'Current Admin',
            action: 'Updated',
            details: 'Updated ${updatedShift.name} (${updatedShift.startTime} - ${updatedShift.endTime})',
            actionColor: Colors.blue,
          ),
        );
      }
      return response;
    } catch (e) {
      return ShiftResponseModel(
        status: false,
        message: e.toString(),
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<ShiftResponseModel> deleteShiftApi(String id) async {
    isSubmitting.value = true;
    try {
      final response = await _effectiveDeleteShiftUseCase.execute(id);
      if (response.status) {
        final shiftIndex = shifts.indexWhere((s) => s.id == id);
        final shiftName = shiftIndex != -1 ? shifts[shiftIndex].name : 'Shift #$id';
        shifts.removeWhere((s) => s.id == id);
        shifts.refresh();

        if (selectedShiftDetails.value?.id.toString() == id) {
          selectedShiftDetails.value = null;
        }

        historyList.insert(
          0,
          ShiftHistoryModel(
            date: 'Today',
            userName: 'Current Admin',
            action: 'Deleted',
            details: 'Deleted $shiftName',
            actionColor: Colors.redAccent,
          ),
        );
      }
      return response;
    } catch (e) {
      return ShiftResponseModel(
        status: false,
        message: e.toString(),
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<ShiftResponseModel> assignShiftApi(String shiftId, List<int> employeeIds) async {
    isSubmitting.value = true;
    try {
      final response = await _effectiveAssignShiftUseCase.execute(shiftId, employeeIds);
      if (response.status && response.data != null) {
        final data = response.data!;
        final updatedShift = ShiftModel.fromDataModel(data);
        final index = shifts.indexWhere((s) => s.id == shiftId || s.id == data.id.toString());
        if (index != -1) {
          shifts[index] = updatedShift;
        } else {
          shifts.insert(0, updatedShift);
        }
        shifts.refresh();
        selectedShiftDetails.value = data;

        historyList.insert(
          0,
          ShiftHistoryModel(
            date: 'Today',
            userName: 'Current Admin',
            action: 'Assigned',
            details: 'Assigned ${employeeIds.length} employees to ${updatedShift.name}',
            actionColor: Colors.green,
          ),
        );
      }
      return response;
    } catch (e) {
      return ShiftResponseModel(
        status: false,
        message: e.toString(),
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  void addShift(ShiftModel newShift) {
    shifts.insert(0, newShift);
    historyList.insert(
      0,
      ShiftHistoryModel(
        date: 'Today',
        userName: 'Current Admin',
        action: 'Created',
        details: 'Created ${newShift.name} (${newShift.startTime} - ${newShift.endTime})',
        actionColor: Colors.purple,
      ),
    );
  }

  void toggleShiftStatus(ShiftModel shift) {
    shift.isActive = !shift.isActive;
    shifts.refresh();
    historyList.insert(
      0,
      ShiftHistoryModel(
        date: 'Today',
        userName: 'Current Admin',
        action: shift.isActive ? 'Updated' : 'Deactivated',
        details: '${shift.name} marked as ${shift.isActive ? "Active" : "Inactive"}',
        actionColor: shift.isActive ? Colors.green : Colors.redAccent,
      ),
    );
  }

  void duplicateShift(ShiftModel shift) {
    final copy = ShiftModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '${shift.name} (Copy)',
      code: '${shift.code}_COPY',
      type: shift.type,
      isActive: shift.isActive,
      description: shift.description,
      startTime: shift.startTime,
      endTime: shift.endTime,
      crossMidnight: shift.crossMidnight,
      workingHours: shift.workingHours,
      enableBreak: shift.enableBreak,
      breakType: shift.breakType,
      breakDuration: shift.breakDuration,
      gracePeriod: shift.gracePeriod,
      lateAfter: shift.lateAfter,
      minWorkingHours: shift.minWorkingHours,
      earlyLeavingAllowed: shift.earlyLeavingAllowed,
      autoMarkLate: shift.autoMarkLate,
      autoMarkHalfDay: shift.autoMarkHalfDay,
      lateThreshold: shift.lateThreshold,
      halfDayAfter: shift.halfDayAfter,
      enableOvertime: shift.enableOvertime,
      otStartsAfter: shift.otStartsAfter,
      minimumOT: shift.minimumOT,
      otCalculation: shift.otCalculation,
      approvalRequired: shift.approvalRequired,
      employeesCount: 0,
      icon: shift.icon,
      iconColor: shift.iconColor,
      assignedEmployeeNames: [],
    );
    addShift(copy);
  }
}
