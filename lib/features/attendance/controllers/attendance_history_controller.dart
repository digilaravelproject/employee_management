import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/logger.dart';
import '../models/attendance_history_model.dart';
import '../models/attendance_history_response_model.dart';
import '../repositories/attendance_repository.dart';

class AttendanceHistoryController extends GetxController {
  final AttendanceRepository _repository;

  AttendanceHistoryController({AttendanceRepository? repository})
      : _repository = repository ??
            AttendanceRepository(
              apiClient: Get.isRegistered<ApiClient>()
                  ? Get.find<ApiClient>()
                  : ApiClient(),
            );

  static DateTime get currentMonthDate {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }

  // Active selected month/year (Always defaults to current month)
  final Rx<DateTime> selectedMonth = currentMonthDate.obs;

  // Selected daily record for bottom sheet & detail screen
  final Rxn<AttendanceRecord> selectedRecord = Rxn<AttendanceRecord>();

  // Full calendar records for current selected month
  final RxList<AttendanceRecord> attendanceRecords = <AttendanceRecord>[].obs;

  // Recent attendance records
  final RxList<AttendanceRecord> recentRecords = <AttendanceRecord>[].obs;

  // Active employee ID if viewing a specific employee's attendance
  final Rxn<dynamic> employeeId = Rxn<dynamic>();

  // Active employee name if viewing a specific employee's attendance
  final Rxn<String> employeeName = Rxn<String>();

  // Full API response data
  final Rxn<AttendanceHistoryData> historyData = Rxn<AttendanceHistoryData>();

  // Loading state
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    resetToCurrentMonth(fetch: false);
    fetchAttendanceHistory(selectedMonth.value);
  }

  /// Resets selection to the current month and optionally fetches history
  void resetToCurrentMonth({bool fetch = true}) {
    selectedMonth.value = currentMonthDate;
    if (fetch) {
      fetchAttendanceHistory(selectedMonth.value);
    }
  }

  // Fetch Attendance History from API for a specific month
  Future<void> fetchAttendanceHistory(DateTime month, {dynamic empId}) async {
    try {
      isLoading.value = true;
      final targetEmpId = empId ?? employeeId.value;
      final monthStr = DateFormat('yyyy-MM').format(month);
      Logger.d('AttendanceHistoryController => Fetching history for $monthStr (empId: $targetEmpId)');

      final response = targetEmpId != null
          ? await _repository.getEmployeeAttendanceHistory(
              employeeId: targetEmpId,
              month: monthStr,
            )
          : await _repository.getAttendanceHistory(monthStr);

      if (response.status && response.data != null) {
        final data = response.data!;
        historyData.value = data;

        // Map calendar items to AttendanceRecord
        final records = data.calendar.map((c) => c.toAttendanceRecord()).toList();
        attendanceRecords.assignAll(records);

        // Map recent records
        if (data.recentRecords.isNotEmpty) {
          recentRecords.assignAll(data.recentRecords.map((c) => c.toAttendanceRecord()).toList());
        } else {
          // Fallback: non-weekend records with check-in or present status
          final filtered = records.where((r) => r.status != 'Weekend' && r.hasCheckIn).toList();
          recentRecords.assignAll(filtered);
        }

        // Set default selected record (today or latest past record, never future)
        final now = DateTime.now();
        AttendanceRecord? currentDayRecord;
        if (month.year == now.year && month.month == now.month) {
          currentDayRecord = getRecordForDate(now);
        }
        selectedRecord.value = currentDayRecord ??
            records.where((r) => !r.date.isAfter(now)).lastOrNull ??
            records.firstOrNull;

        Logger.d('AttendanceHistoryController => Loaded ${records.length} calendar days, summary: present=${data.summary?.present}, absent=${data.summary?.absent}');
      } else {
        Logger.w('AttendanceHistoryController => API response error: ${response.message}');
      }
    } catch (e) {
      Logger.e('AttendanceHistoryController => Exception fetching history: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Interactive Calendar Date Picker
  Future<void> openDatePickerCalendar(BuildContext context) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final initial = selectedMonth.value.isAfter(today) ? today : selectedMonth.value;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 3, 1, 1),
      lastDate: today,
      currentDate: today,
      helpText: 'Select Date for Attendance Month',
      cancelText: 'Cancel',
      confirmText: 'Select',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              onSurface: AppColors.textColorPrimary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryColor,
              ),
            ),
          ),
          child: child ?? const SizedBox(),
        );
      },
    );

    if (pickedDate != null) {
      selectedMonth.value = DateTime(pickedDate.year, pickedDate.month, 1);
      await fetchAttendanceHistory(selectedMonth.value);
    }
  }

  // Get record for a specific date
  AttendanceRecord? getRecordForDate(DateTime date) {
    return attendanceRecords.firstWhereOrNull(
      (r) => r.date.year == date.year && r.date.month == date.month && r.date.day == date.day,
    );
  }

  // Get active month's records
  List<AttendanceRecord> get activeMonthRecords => attendanceRecords;

  // Stats computed reactively from summary or records:
  int get presentDaysCount {
    if (historyData.value?.summary != null) {
      return historyData.value!.summary!.present;
    }
    return attendanceRecords.where((r) => r.status == 'Present').length;
  }

  int get halfDayCount {
    if (historyData.value?.summary != null) {
      return historyData.value!.summary!.halfDay;
    }
    return attendanceRecords.where((r) => r.status == 'Half Day').length;
  }

  int get absentCount {
    if (historyData.value?.summary != null) {
      return historyData.value!.summary!.absent;
    }
    return attendanceRecords.where((r) => r.status == 'Absent').length;
  }

  int get leaveCount {
    if (historyData.value?.summary != null) {
      return historyData.value!.summary!.leave;
    }
    return attendanceRecords.where((r) => r.status == 'Leave').length;
  }

  int get weekendCount {
    if (historyData.value?.summary != null) {
      return historyData.value!.summary!.weekend;
    }
    return attendanceRecords.where((r) => r.status == 'Weekend').length;
  }

  int get lateCount {
    if (historyData.value?.summary != null && historyData.value!.summary!.late > 0) {
      return historyData.value!.summary!.late;
    }
    return attendanceRecords.where((r) => r.hasLateIndication).length;
  }

  int get workingDaysCount {
    if (historyData.value?.summary != null) {
      return historyData.value!.summary!.workingDays;
    }
    return attendanceRecords.where((r) => r.status != 'Weekend').length;
  }

  double get attendancePercentage {
    if (historyData.value?.summary != null) {
      return historyData.value!.summary!.attendancePercentage;
    }
    final working = workingDaysCount;
    if (working == 0) return 0.0;
    final present = presentDaysCount + (halfDayCount * 0.5);
    return double.parse(((present / working) * 100).toStringAsFixed(2));
  }

  // Dynamic Month Selector
  void changeMonth(DateTime month) {
    final now = DateTime.now();
    if (DateTime(month.year, month.month, 1).isAfter(DateTime(now.year, now.month, 1))) {
      return;
    }
    selectedMonth.value = month;
    fetchAttendanceHistory(month);
  }
}
