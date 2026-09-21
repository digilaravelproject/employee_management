import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/services/network/api_client.dart';
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

  // Active selected month/year (default to September 2026 or current date)
  final Rx<DateTime> selectedMonth = DateTime(2026, 9, 1).obs;

  // Selected daily record for bottom sheet & detail screen
  final Rxn<AttendanceRecord> selectedRecord = Rxn<AttendanceRecord>();

  // Full calendar records for current selected month
  final RxList<AttendanceRecord> attendanceRecords = <AttendanceRecord>[].obs;

  // Recent attendance records
  final RxList<AttendanceRecord> recentRecords = <AttendanceRecord>[].obs;

  // Full API response data
  final Rxn<AttendanceHistoryData> historyData = Rxn<AttendanceHistoryData>();

  // Loading state
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAttendanceHistory(selectedMonth.value);
  }

  // Fetch Attendance History from API for a specific month
  Future<void> fetchAttendanceHistory(DateTime month) async {
    try {
      isLoading.value = true;
      final monthStr = DateFormat('yyyy-MM').format(month);
      Logger.d('AttendanceHistoryController => Fetching history for $monthStr');

      final response = await _repository.getAttendanceHistory(monthStr);

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

        // Set default selected record
        final now = DateTime.now();
        AttendanceRecord? currentDayRecord;
        if (month.year == now.year && month.month == now.month) {
          currentDayRecord = getRecordForDate(now);
        }
        selectedRecord.value = currentDayRecord ?? records.firstOrNull;

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
    selectedMonth.value = month;
    fetchAttendanceHistory(month);
  }
}
