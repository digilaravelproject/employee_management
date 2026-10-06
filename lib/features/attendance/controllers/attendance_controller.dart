import 'dart:async';
import 'package:attendence_tracking_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/services/network/api_client.dart';
import '../../../core/utils/logger.dart';
import '../models/admin_attendance_model.dart';
import '../repositories/attendance_repository.dart';

class AttendanceController extends GetxController {
  final AttendanceRepository _repository;

  AttendanceController({AttendanceRepository? repository})
      : _repository = repository ??
            AttendanceRepository(
              apiClient: Get.isRegistered<ApiClient>()
                  ? Get.find<ApiClient>()
                  : Get.put(ApiClient()),
            );

  final RxInt selectedTab = 0.obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rxn<AdminAttendanceData> attendanceData = Rxn<AdminAttendanceData>();

  // Master list of all employees for the currently selected date
  final RxList<AdminAttendanceEmployeeItem> _allEmployeesMaster = <AdminAttendanceEmployeeItem>[].obs;

  // Reactively filtered employees to display in the UI
  final RxList<AdminAttendanceEmployeeItem> displayedEmployees = <AdminAttendanceEmployeeItem>[].obs;

  Timer? _debounceTimer;

  // Status mapping for tabs: 0: All (null), 1: Present, 2: Absent, 3: On Leave
  final List<String?> tabStatusKeys = [null, 'present', 'absent', 'leave'];

  int get allEmployeesCount =>
      attendanceData.value?.summary?.totalEmployees ?? _allEmployeesMaster.length;

  int get presentEmployeesCount {
    final apiPresent = attendanceData.value?.summary?.present;
    if (apiPresent != null && apiPresent > 0) return apiPresent;
    return _allEmployeesMaster.where(_isEmployeePresent).length;
  }

  int get absentEmployeesCount {
    final apiAbsent = attendanceData.value?.summary?.absent;
    if (apiAbsent != null && apiAbsent > 0) return apiAbsent;
    return _allEmployeesMaster.where(_isEmployeeAbsent).length;
  }

  int get leaveEmployeesCount {
    final apiLeave = attendanceData.value?.summary?.onLeave;
    if (apiLeave != null && apiLeave > 0) return apiLeave;
    return _allEmployeesMaster.where(_isEmployeeOnLeave).length;
  }

  @override
  void onInit() {
    super.onInit();
    fetchAttendance();
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    searchController.dispose();
    super.onClose();
  }

  Future<void> fetchAttendance({bool isSearch = false}) async {
    if (!isSearch) {
      isLoading.value = true;
      errorMessage.value = '';
    }

    final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate.value);
    // When master list is empty or tab is All, fetch all without status restriction
    final statusStr = _allEmployeesMaster.isEmpty || selectedTab.value == 0
        ? null
        : tabStatusKeys[selectedTab.value.clamp(0, tabStatusKeys.length - 1)];

    try {
      Logger.d('AttendanceController => Fetching for date: $dateStr, status: $statusStr, search: ${searchQuery.value}');
      final response = await _repository.getAdminAttendance(
        date: dateStr,
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
        status: statusStr,
        sort: 'name',
        direction: 'asc',
      );

      if (response.status && response.data != null) {
        attendanceData.value = response.data;
        final newEmployees = response.data!.employees;

        if (statusStr == null || selectedTab.value == 0 || _allEmployeesMaster.isEmpty || newEmployees.length > _allEmployeesMaster.length) {
          _allEmployeesMaster.assignAll(newEmployees);
        } else if (newEmployees.isNotEmpty) {
          // Merge or update records into master list
          for (final item in newEmployees) {
            final idx = _allEmployeesMaster.indexWhere((e) =>
                (e.attendanceId != null && e.attendanceId == item.attendanceId) ||
                (e.employee?.id != null && e.employee?.id == item.employee?.id) ||
                (e.employee?.employeeId != null &&
                    item.employee?.employeeId != null &&
                    e.employee!.employeeId!.isNotEmpty &&
                    e.employee!.employeeId == item.employee!.employeeId));
            if (idx != -1) {
              _allEmployeesMaster[idx] = item;
            } else {
              _allEmployeesMaster.add(item);
            }
          }
        }

        _updateDisplayedEmployees();
      } else {
        if (!isSearch) {
          errorMessage.value = response.message.isNotEmpty
              ? response.message
              : 'Failed to retrieve attendance data.';
        }
      }
    } catch (e) {
      Logger.e('AttendanceController => Error: $e');
      if (!isSearch) {
        errorMessage.value = e.toString();
      }
    } finally {
      if (!isSearch) {
        isLoading.value = false;
      }
    }
  }

  void _updateDisplayedEmployees() {
    List<AdminAttendanceEmployeeItem> pool = [];
    final currentEmployees = attendanceData.value?.employees ?? [];

    if (_allEmployeesMaster.isNotEmpty) {
      pool = List.from(_allEmployeesMaster);
    } else if (currentEmployees.isNotEmpty) {
      pool = List.from(currentEmployees);
    }

    List<AdminAttendanceEmployeeItem> tabFiltered = [];
    switch (selectedTab.value) {
      case 1: // Present
        tabFiltered = pool.where((emp) => _isEmployeePresent(emp)).toList();
        break;
      case 2: // Absent
        tabFiltered = pool.where((emp) => _isEmployeeAbsent(emp)).toList();
        break;
      case 3: // On Leave
        tabFiltered = pool.where((emp) => _isEmployeeOnLeave(emp)).toList();
        break;
      case 0: // All
      default:
        tabFiltered = List.from(pool);
        break;
    }

    // Fallback: If local filtering gave 0, but API response for this specific tab returned records, use them
    if (tabFiltered.isEmpty && currentEmployees.isNotEmpty && selectedTab.value != 0) {
      tabFiltered = List.from(currentEmployees);
    }

    // Filter by search query
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isNotEmpty) {
      tabFiltered = tabFiltered.where((emp) {
        final name = (emp.employee?.name ?? '').toLowerCase();
        final empId = (emp.employee?.employeeId ?? '').toLowerCase();
        final designation = (emp.employee?.designation ?? '').toLowerCase();
        final department = (emp.employee?.department ?? '').toLowerCase();
        return name.contains(q) || empId.contains(q) || designation.contains(q) || department.contains(q);
      }).toList();
    }

    displayedEmployees.assignAll(tabFiltered);
  }

  bool _isEmployeePresent(AdminAttendanceEmployeeItem emp) {
    final s = emp.status.trim().toLowerCase();
    final cat = (emp.category ?? '').trim().toLowerCase();
    final hasCheckIn = emp.checkIn != null &&
        emp.checkIn!.trim().isNotEmpty &&
        emp.checkIn != '--:-- --' &&
        emp.checkIn != '--';

    if (s == 'present' || s.contains('present')) return true;
    if (s == 'late' || s.contains('late')) return true;
    if (s == 'half day' || s.contains('half')) return true;
    if (cat.contains('present') || cat.contains('late')) return true;
    if (emp.isLate) return true;
    if (hasCheckIn) return true;
    return false;
  }

  bool _isEmployeeAbsent(AdminAttendanceEmployeeItem emp) {
    if (_isEmployeeOnLeave(emp)) return false;
    if (_isEmployeePresent(emp)) return false;
    final s = emp.status.trim().toLowerCase();
    if (s == 'absent' || s.contains('absent')) return true;
    return true;
  }

  bool _isEmployeeOnLeave(AdminAttendanceEmployeeItem emp) {
    final s = emp.status.trim().toLowerCase();
    final cat = (emp.category ?? '').trim().toLowerCase();
    return s == 'leave' || s.contains('leave') || cat.contains('leave');
  }

  void changeTab(int index) {
    if (selectedTab.value == index) return;
    selectedTab.value = index;
    // Update displayed employees immediately for instant UX
    _updateDisplayedEmployees();

    // If master list is empty or needs refresh, fetch from API
    if (_allEmployeesMaster.isEmpty) {
      fetchAttendance();
    }
  }

  void changeDate(DateTime date) {
    final now = DateTime.now();
    if (DateTime(date.year, date.month, date.day).isAfter(DateTime(now.year, now.month, now.day))) {
      return;
    }
    selectedDate.value = date;
    _allEmployeesMaster.clear();
    displayedEmployees.clear();
    fetchAttendance();
  }

  void previousDay() {
    selectedDate.value = selectedDate.value.subtract(const Duration(days: 1));
    _allEmployeesMaster.clear();
    displayedEmployees.clear();
    fetchAttendance();
  }

  void nextDay() {
    final now = DateTime.now();
    final next = selectedDate.value.add(const Duration(days: 1));
    if (DateTime(next.year, next.month, next.day).isAfter(DateTime(now.year, now.month, now.day))) {
      return;
    }
    selectedDate.value = next;
    _allEmployeesMaster.clear();
    displayedEmployees.clear();
    fetchAttendance();
  }

  void selectToday() {
    selectedDate.value = DateTime.now();
    _allEmployeesMaster.clear();
    displayedEmployees.clear();
    fetchAttendance();
  }

  Future<void> selectDateFromPicker(BuildContext context) async {
    final now = DateTime.now();
    final initial = selectedDate.value.isAfter(now) ? now : selectedDate.value;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primaryColor,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      changeDate(picked);
    }
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    _updateDisplayedEmployees();
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      fetchAttendance(isSearch: true);
    });
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    _updateDisplayedEmployees();
    fetchAttendance(isSearch: true);
  }
}
