import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/utils/logger.dart';
import '../models/admin_leave_model.dart';
import '../repositories/admin_leave_repository_interface.dart';

class FilterItemOption {
  final dynamic id;
  final String name;

  FilterItemOption({required this.id, required this.name});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FilterItemOption &&
          runtimeType == other.runtimeType &&
          id.toString() == other.id.toString();

  @override
  int get hashCode => id.hashCode;
}

class AdminLeaveController extends GetxController {
  final AdminLeaveRepositoryInterface repository;

  AdminLeaveController({required this.repository});

  // ── State Observables ──────────────────────────────────────────
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxString errorMessage = ''.obs;

  final RxList<AdminLeaveItemModel> allLeaves = <AdminLeaveItemModel>[].obs;
  final Rx<AdminLeaveCountsModel?> counts = Rx<AdminLeaveCountsModel?>(null);
  final Rx<AdminLeavePaginationModel?> pagination = Rx<AdminLeavePaginationModel?>(null);

  // ── Leave Detail State ─────────────────────────────────────────
  final Rx<AdminLeaveDetailDataModel?> leaveDetail = Rx<AdminLeaveDetailDataModel?>(null);
  final RxBool isDetailLoading = false.obs;
  final RxString detailError = ''.obs;
  final RxBool isApproving = false.obs;
  final RxBool isRejecting = false.obs;

  // ── Tab & Search State ─────────────────────────────────────────
  final RxString selectedStatus = 'All'.obs; // 'All', 'Pending', 'Approved', 'Rejected'
  final RxString searchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();
  Timer? _searchDebounce;

  // ── Filter State ───────────────────────────────────────────────
  final Rx<dynamic> selectedDepartmentId = Rx<dynamic>(null);
  final RxString selectedDepartmentName = 'All'.obs;

  final Rx<dynamic> selectedLeaveTypeId = Rx<dynamic>(null);
  final RxString selectedLeaveTypeName = 'All'.obs;

  final RxString selectedRole = 'All'.obs;
  final RxString selectedDesignation = 'All'.obs;
  final RxString selectedDatePreset = 'All Time'.obs;
  final Rx<DateTimeRange?> selectedDateRange = Rx<DateTimeRange?>(null);

  // ── Filter Options ─────────────────────────────────────────────
  final RxList<FilterItemOption> departmentOptions = <FilterItemOption>[
    FilterItemOption(id: null, name: 'All'),
  ].obs;

  final RxList<FilterItemOption> leaveTypeOptions = <FilterItemOption>[
    FilterItemOption(id: null, name: 'All'),
    FilterItemOption(id: 1, name: 'Casual Leave'),
    FilterItemOption(id: 2, name: 'Sick Leave'),
    FilterItemOption(id: 3, name: 'Paid Leave'),
    FilterItemOption(id: 4, name: 'Comp Off'),
    FilterItemOption(id: 5, name: 'Maternity Leave'),
    FilterItemOption(id: 6, name: 'Paternity Leave'),
    FilterItemOption(id: 7, name: 'Other Leave'),
  ].obs;

  final RxList<String> roles = <String>[
    'All',
    'Admin',
    'Manager',
    'Team Lead',
    'Employee',
  ].obs;

  final RxList<String> designations = <String>[
    'All',
    'UI/UX Designer',
    'Frontend Developer',
    'Backend Developer',
    'HR Executive',
    'Marketing Executive',
    'Sales Lead',
    'Project Manager',
  ].obs;

  final List<String> datePresets = [
    'All Time',
    'Today',
    'This Week',
    'This Month',
    'Last Month',
    'Custom Range',
  ];

  @override
  void onInit() {
    super.onInit();
    fetchDepartmentOptions();
    fetchLeaveRequests();
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    searchController.dispose();
    super.onClose();
  }

  // ── Fetch Departments from API ─────────────────────────────────
  Future<void> fetchDepartmentOptions() async {
    try {
      if (Get.isRegistered<ApiClient>()) {
        final apiClient = Get.find<ApiClient>();
        final response = await apiClient.get('/api/admin/departments', handleError: false, showToaster: false);
        if (response.isSuccess && response.json != null) {
          final data = response.json!['data'];
          if (data is List) {
            final List<FilterItemOption> loaded = [FilterItemOption(id: null, name: 'All')];
            for (var item in data) {
              if (item is Map<String, dynamic>) {
                loaded.add(FilterItemOption(
                  id: item['id'],
                  name: item['name']?.toString() ?? 'Dept ${item['id']}',
                ));
              }
            }
            if (loaded.length > 1) {
              departmentOptions.assignAll(loaded);
            }
          }
        }
      }
    } catch (e) {
      Logger.d('AdminLeaveController => fetchDepartmentOptions error: $e');
    }
  }

  // ── Date Preset Mapping ────────────────────────────────────────
  String? _getDateRangeParam(String preset) {
    switch (preset) {
      case 'Today':
        return 'today';
      case 'This Week':
        return 'this_week';
      case 'This Month':
        return 'this_month';
      case 'Last Month':
        return 'last_month';
      case 'Custom Range':
        return 'custom';
      default:
        return null;
    }
  }

  // ── Fetch Leave Requests from API ──────────────────────────────
  Future<void> fetchLeaveRequests({bool showLoader = true}) async {
    try {
      if (showLoader) {
        isLoading.value = true;
      }
      errorMessage.value = '';

      final statusParam = selectedStatus.value == 'All' ? null : selectedStatus.value;
      final dateRangeParam = _getDateRangeParam(selectedDatePreset.value);
      final startDateParam = selectedDatePreset.value == 'Custom Range' && selectedDateRange.value != null
          ? DateFormat('yyyy-MM-dd').format(selectedDateRange.value!.start)
          : null;
      final endDateParam = selectedDatePreset.value == 'Custom Range' && selectedDateRange.value != null
          ? DateFormat('yyyy-MM-dd').format(selectedDateRange.value!.end)
          : null;

      Logger.d('AdminLeaveController => Fetching leaves [status: $statusParam, dateRange: $dateRangeParam, dept: ${selectedDepartmentId.value}, type: ${selectedLeaveTypeId.value}, search: ${searchQuery.value}]');

      final response = await repository.getLeaveRequests(
        status: statusParam,
        dateRange: dateRangeParam,
        startDate: startDateParam,
        endDate: endDateParam,
        departmentId: selectedDepartmentId.value,
        leaveTypeId: selectedLeaveTypeId.value,
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
      );

      if (response.status) {
        allLeaves.assignAll(response.data);
        counts.value = response.counts;
        pagination.value = response.pagination;
        _updateDynamicFilterLists();
        Logger.d('AdminLeaveController => Loaded ${allLeaves.length} leave requests (counts: ${response.counts?.toJson()})');
      } else {
        errorMessage.value = response.message.isNotEmpty
            ? response.message
            : 'Failed to load leave requests.';
        Logger.w('AdminLeaveController => ${errorMessage.value}');
      }
    } catch (e) {
      Logger.e('AdminLeaveController => Error fetching leaves: $e');
      errorMessage.value = 'Failed to load leave requests. Please try again.';
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  // ── Pull to refresh ────────────────────────────────────────────
  Future<void> refreshLeaves() async {
    isRefreshing.value = true;
    await fetchLeaveRequests(showLoader: false);
  }

  // ── Fetch single leave request details ─────────────────────────
  Future<void> fetchLeaveDetails(int id) async {
    try {
      isDetailLoading.value = true;
      detailError.value = '';

      Logger.d('AdminLeaveController => Fetching details for leave ID: $id');
      final response = await repository.getLeaveRequestDetails(id);

      if (response.status && response.data != null) {
        leaveDetail.value = response.data;
        Logger.d('AdminLeaveController => Successfully loaded details for leave ID: $id');
      } else {
        detailError.value = response.message.isNotEmpty
            ? response.message
            : 'Failed to load leave details.';
        Logger.w('AdminLeaveController => ${detailError.value}');
      }
    } catch (e) {
      Logger.e('AdminLeaveController => Error fetching leave details: $e');
      detailError.value = 'Failed to load leave details. Please try again.';
    } finally {
      isDetailLoading.value = false;
    }
  }

  // ── Approve Leave Request ──────────────────────────────────────
  Future<bool> approveLeave(int id, {String note = 'Approved by reporting manager.'}) async {
    try {
      isApproving.value = true;
      Logger.d('AdminLeaveController => Approving leave ID: $id with note: $note');

      final response = await repository.approveLeaveRequest(id, note: note);

      if (response.isSuccess) {
        Get.snackbar(
          'Success',
          response.message.isNotEmpty ? response.message : 'Leave request approved successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.9),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
        // Refresh details and list
        await fetchLeaveDetails(id);
        fetchLeaveRequests(showLoader: false);
        return true;
      } else {
        Get.snackbar(
          'Error',
          response.message.isNotEmpty ? response.message : 'Failed to approve leave request.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
        return false;
      }
    } catch (e) {
      Logger.e('AdminLeaveController => Error approving leave: $e');
      Get.snackbar(
        'Error',
        'Something went wrong while approving leave: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return false;
    } finally {
      isApproving.value = false;
    }
  }

  // ── Reject Leave Request ───────────────────────────────────────
  Future<bool> rejectLeave(int id, {String note = 'Insufficient supporting information.'}) async {
    try {
      isRejecting.value = true;
      Logger.d('AdminLeaveController => Rejecting leave ID: $id with note: $note');

      final response = await repository.rejectLeaveRequest(id, note: note);

      if (response.isSuccess) {
        Get.snackbar(
          'Rejected',
          response.message.isNotEmpty ? response.message : 'Leave request rejected.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withValues(alpha: 0.9),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
        // Refresh details and list
        await fetchLeaveDetails(id);
        fetchLeaveRequests(showLoader: false);
        return true;
      } else {
        Get.snackbar(
          'Error',
          response.message.isNotEmpty ? response.message : 'Failed to reject leave request.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
        return false;
      }
    } catch (e) {
      Logger.e('AdminLeaveController => Error rejecting leave: $e');
      Get.snackbar(
        'Error',
        'Something went wrong while rejecting leave: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return false;
    } finally {
      isRejecting.value = false;
    }
  }

  // ── Dynamic filter options updater based on returned data ─────
  void _updateDynamicFilterLists() {
    final Set<String> desigSet = {'All'};
    final Set<String> roleSet = {'All'};

    for (var leave in allLeaves) {
      if (leave.employee.designation.isNotEmpty && leave.employee.designation != 'Employee') {
        desigSet.add(leave.employee.designation);
      }
      if (leave.employee.role.isNotEmpty) {
        roleSet.add(leave.employee.role);
      }
      if (leave.leaveTypeId != null && leave.leaveType.isNotEmpty) {
        final exists = leaveTypeOptions.any((opt) => opt.id?.toString() == leave.leaveTypeId.toString());
        if (!exists) {
          leaveTypeOptions.add(FilterItemOption(id: leave.leaveTypeId, name: leave.leaveType));
        }
      }
    }

    if (desigSet.length > 1) {
      designations.assignAll(desigSet.toList());
    }
    if (roleSet.length > 1) {
      roles.assignAll(roleSet.toList());
    }
  }

  // ── Tab selection ──────────────────────────────────────────────
  void setStatusTab(String status) {
    if (selectedStatus.value == status) return;
    selectedStatus.value = status;
    fetchLeaveRequests(showLoader: true);
  }

  // ── Search handler with debouncing ────────────────────────────
  void onSearchQueryChanged(String query) {
    searchQuery.value = query.trim();
    if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      fetchLeaveRequests(showLoader: false);
    });
  }

  // ── Apply Filters from Sheet ───────────────────────────────────
  void applyFilters({
    required String status,
    required dynamic departmentId,
    required String departmentName,
    required dynamic leaveTypeId,
    required String leaveTypeName,
    required String datePreset,
    required DateTimeRange? dateRange,
    String? role,
    String? designation,
  }) {
    selectedStatus.value = status;
    selectedDepartmentId.value = departmentId;
    selectedDepartmentName.value = departmentName;
    selectedLeaveTypeId.value = leaveTypeId;
    selectedLeaveTypeName.value = leaveTypeName;
    selectedDatePreset.value = datePreset;
    selectedDateRange.value = dateRange;
    if (role != null) selectedRole.value = role;
    if (designation != null) selectedDesignation.value = designation;

    fetchLeaveRequests(showLoader: true);
  }

  // ── Active Filters Getters ─────────────────────────────────────
  bool get hasActiveFilters {
    return (selectedDepartmentId.value != null && selectedDepartmentId.value.toString() != 'All') ||
        (selectedDepartmentName.value != 'All') ||
        (selectedLeaveTypeId.value != null && selectedLeaveTypeId.value.toString() != 'All') ||
        (selectedLeaveTypeName.value != 'All') ||
        selectedRole.value != 'All' ||
        selectedDesignation.value != 'All' ||
        selectedDatePreset.value != 'All Time' ||
        selectedDateRange.value != null;
  }

  int get activeFilterCount {
    int count = 0;
    if ((selectedDepartmentId.value != null && selectedDepartmentId.value.toString() != 'All') || selectedDepartmentName.value != 'All') count++;
    if ((selectedLeaveTypeId.value != null && selectedLeaveTypeId.value.toString() != 'All') || selectedLeaveTypeName.value != 'All') count++;
    if (selectedRole.value != 'All') count++;
    if (selectedDesignation.value != 'All') count++;
    if (selectedDatePreset.value != 'All Time' || selectedDateRange.value != null) count++;
    return count;
  }

  // ── Reset Filters ──────────────────────────────────────────────
  void resetAllFilters() {
    selectedStatus.value = 'All';
    selectedDepartmentId.value = null;
    selectedDepartmentName.value = 'All';
    selectedLeaveTypeId.value = null;
    selectedLeaveTypeName.value = 'All';
    selectedRole.value = 'All';
    selectedDesignation.value = 'All';
    selectedDatePreset.value = 'All Time';
    selectedDateRange.value = null;
    searchQuery.value = '';
    searchController.clear();
    fetchLeaveRequests(showLoader: true);
  }

  // ── Remove single filter and refresh ───────────────────────────
  void removeDepartmentFilter() {
    selectedDepartmentId.value = null;
    selectedDepartmentName.value = 'All';
    fetchLeaveRequests(showLoader: true);
  }

  void removeLeaveTypeFilter() {
    selectedLeaveTypeId.value = null;
    selectedLeaveTypeName.value = 'All';
    fetchLeaveRequests(showLoader: true);
  }

  void removeDateFilter() {
    selectedDatePreset.value = 'All Time';
    selectedDateRange.value = null;
    fetchLeaveRequests(showLoader: true);
  }

  void removeRoleFilter() {
    selectedRole.value = 'All';
    fetchLeaveRequests(showLoader: true);
  }

  void removeDesignationFilter() {
    selectedDesignation.value = 'All';
    fetchLeaveRequests(showLoader: true);
  }

  // ── Counts for Status Badges ───────────────────────────────────
  int countForStatus(String status) {
    return allLeaves
        .where((r) => r.status.toLowerCase() == status.toLowerCase())
        .length;
  }

  int get allCount => counts.value?.all ?? (selectedStatus.value == 'All' ? allLeaves.length : 0);
  int get pendingCount => counts.value?.pending ?? countForStatus('Pending');
  int get approvedCount => counts.value?.approved ?? countForStatus('Approved');
  int get rejectedCount => counts.value?.rejected ?? countForStatus('Rejected');
  int get cancelledCount => counts.value?.cancelled ?? countForStatus('Cancelled');

  // ── Filtered Requests ──────────────────────────────────────────
  List<AdminLeaveItemModel> get filteredRequests => allLeaves;
}
