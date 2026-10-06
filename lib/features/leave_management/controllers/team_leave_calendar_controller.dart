import 'package:flutter/material.dart';
import 'package:attendence_tracking_app/core/theme/app_colors.dart';
import 'package:get/get.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/utils/logger.dart';
import '../models/admin_leave_model.dart';
import '../repositories/admin_leave_repository.dart';
import '../repositories/admin_leave_repository_interface.dart';

class TeamLeaveCalendarController extends GetxController {
  final AdminLeaveRepositoryInterface repository;

  TeamLeaveCalendarController({AdminLeaveRepositoryInterface? repository})
      : repository = repository ??
            (Get.isRegistered<AdminLeaveRepositoryInterface>()
                ? Get.find<AdminLeaveRepositoryInterface>()
                : AdminLeaveRepository(
                    apiClient: Get.isRegistered<ApiClient>()
                        ? Get.find<ApiClient>()
                        : Get.put(ApiClient(), permanent: true),
                  ));

  // ── Observables ────────────────────────────────────────────────
  final Rx<DateTime> selectedMonth = Rx<DateTime>(
    DateTime(DateTime.now().year, DateTime.now().month, 1),
  );
  final Rx<DateTime> selectedDate = Rx<DateTime>(
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
  );

  final RxString selectedStatusFilter = 'all'.obs; // 'all', 'pending', 'approved', 'rejected'
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxString errorMessage = ''.obs;

  final RxList<AdminLeaveItemModel> leavesList = <AdminLeaveItemModel>[].obs;
  final Rxn<AdminLeaveCountsModel> counts = Rxn<AdminLeaveCountsModel>();

  @override
  void onInit() {
    super.onInit();
    fetchLeavesForMonth();
  }

  // ── Fetch Leaves for the Selected Month ─────────────────────────
  Future<void> fetchLeavesForMonth({DateTime? month, bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        isRefreshing.value = true;
      } else {
        isLoading.value = true;
      }
      errorMessage.value = '';

      final targetMonth = month ?? selectedMonth.value;
      final year = targetMonth.year;
      final m = targetMonth.month;
      final daysInMonth = DateTime(year, m + 1, 0).day;

      final fromDate = '$year-${m.toString().padLeft(2, '0')}-01';
      final toDate = '$year-${m.toString().padLeft(2, '0')}-${daysInMonth.toString().padLeft(2, '0')}';

      Logger.d('TeamLeaveCalendarController => Fetching leaves for: $fromDate to $toDate (status: ${selectedStatusFilter.value})');

      final response = await repository.getEmployeeLeaves(
        status: selectedStatusFilter.value,
        fromDate: fromDate,
        toDate: toDate,
        perPage: 100,
      );

      if (response.status) {
        leavesList.assignAll(response.data);
        counts.value = response.counts;
        Logger.d('TeamLeaveCalendarController => Loaded ${leavesList.length} leaves');
      } else {
        errorMessage.value = response.message.isNotEmpty
            ? response.message
            : 'Failed to load employee leaves.';
        Logger.w('TeamLeaveCalendarController => Error: ${errorMessage.value}');
      }
    } catch (e) {
      Logger.e('TeamLeaveCalendarController => Exception: $e');
      errorMessage.value = 'Failed to load employee leaves: ${e.toString()}';
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  // ── Navigation Methods ──────────────────────────────────────────
  void previousMonth() {
    final cur = selectedMonth.value;
    final newMonth = DateTime(cur.year, cur.month - 1, 1);
    selectedMonth.value = newMonth;
    _adjustSelectedDateForMonth(newMonth);
    fetchLeavesForMonth(month: newMonth);
  }

  void nextMonth() {
    final cur = selectedMonth.value;
    final newMonth = DateTime(cur.year, cur.month + 1, 1);
    final now = DateTime.now();
    if (newMonth.isAfter(DateTime(now.year, now.month, 1))) {
      return;
    }
    selectedMonth.value = newMonth;
    _adjustSelectedDateForMonth(newMonth);
    fetchLeavesForMonth(month: newMonth);
  }

  void changeMonth(int year, int month) {
    final now = DateTime.now();
    final newMonth = DateTime(year, month, 1);
    if (newMonth.isAfter(DateTime(now.year, now.month, 1))) {
      return;
    }
    selectedMonth.value = newMonth;
    _adjustSelectedDateForMonth(newMonth);
    fetchLeavesForMonth(month: newMonth);
  }

  void _adjustSelectedDateForMonth(DateTime month) {
    final now = DateTime.now();
    if (month.year == now.year && month.month == now.month) {
      selectedDate.value = DateTime(now.year, now.month, now.day);
    } else {
      selectedDate.value = DateTime(month.year, month.month, 1);
    }
  }

  void selectDate(DateTime date) {
    selectedDate.value = DateTime(date.year, date.month, date.day);
  }

  void changeStatusFilter(String status) {
    if (selectedStatusFilter.value == status) return;
    selectedStatusFilter.value = status;
    fetchLeavesForMonth();
  }

  // ── Calendar Computed Data ─────────────────────────────────────
  /// Maps each day of the current selected month to the list of leaves active on that day.
  Map<int, List<AdminLeaveItemModel>> get leavesByDayInCurrentMonth {
    final Map<int, List<AdminLeaveItemModel>> map = {};
    final year = selectedMonth.value.year;
    final month = selectedMonth.value.month;
    final daysInMonth = DateTime(year, month + 1, 0).day;

    for (final leave in leavesList) {
      if (leave.startDate == null) continue;
      final start = leave.startDate!;
      final end = leave.endDate ?? start;

      final startNormalized = DateTime(start.year, start.month, start.day);
      final endNormalized = DateTime(end.year, end.month, end.day);

      for (int day = 1; day <= daysInMonth; day++) {
        final currentDate = DateTime(year, month, day);
        if (!currentDate.isBefore(startNormalized) && !currentDate.isAfter(endNormalized)) {
          map.putIfAbsent(day, () => []).add(leave);
        }
      }
    }
    return map;
  }

  /// Returns the leaves active on the currently selected date.
  List<AdminLeaveItemModel> get leavesForSelectedDate {
    final sel = selectedDate.value;
    final curMonth = selectedMonth.value;
    if (sel.year != curMonth.year || sel.month != curMonth.month) {
      return [];
    }
    return leavesByDayInCurrentMonth[sel.day] ?? [];
  }

  /// Total unique employees on leave this month.
  int get uniqueEmployeesOnLeaveThisMonth {
    final Set<int> empIds = {};
    for (var l in leavesList) {
      empIds.add(l.employee.id);
    }
    return empIds.length;
  }

  /// Helper to get status color
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return const Color(0xFF10B981); // Emerald / Green
      case 'pending':
        return const Color(0xFFF59E0B); // Amber / Orange
      case 'rejected':
      case 'declined':
        return const Color(0xFFEF4444); // Red
      case 'cancelled':
        return const Color(0xFF6B7280); // Gray
      default:
        return AppColors.primaryColor; // Indigo
    }
  }
}
