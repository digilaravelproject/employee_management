import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/logger.dart';
import '../../attendance/models/attendance_history_response_model.dart';
import '../../attendance/repositories/attendance_repository.dart';
import '../models/employee_performance_response_model.dart';
import '../models/performance_leave_api_response.dart';
import '../models/performance_quality_api_response.dart';
import '../models/performance_task_completion_api_response.dart';
import '../repositories/performance_repository_interface.dart';

class EmployeePerformanceDetailController extends GetxController {
  final PerformanceRepositoryInterface repository;
  final AttendanceRepository _attendanceRepository;

  EmployeePerformanceDetailController({
    PerformanceRepositoryInterface? repository,
    AttendanceRepository? attendanceRepository,
  })  : repository = repository ?? Get.find<PerformanceRepositoryInterface>(),
        _attendanceRepository = attendanceRepository ??
            AttendanceRepository(
              apiClient: Get.isRegistered<ApiClient>()
                  ? Get.find<ApiClient>()
                  : ApiClient(),
            );

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rxn<EmployeePerformanceDetailDataModel> detail = Rxn<EmployeePerformanceDetailDataModel>();
  final Rxn<AttendanceSummary> attendanceSummary = Rxn<AttendanceSummary>();
  final Rxn<PerformanceLeaveApiResponse> apiLeaveResponse = Rxn<PerformanceLeaveApiResponse>();
  final RxList<PerformanceLeaveDetailModel> apiLeaves = <PerformanceLeaveDetailModel>[].obs;
  final Rxn<PerformanceTaskCompletionApiResponse> apiTaskCompletionResponse = Rxn<PerformanceTaskCompletionApiResponse>();
  final RxList<PerformanceTaskItemApiData> apiTaskCompletionList = <PerformanceTaskItemApiData>[].obs;
  final Rxn<PerformanceTaskCompletionApiResponse> apiTimelySubmissionsResponse = Rxn<PerformanceTaskCompletionApiResponse>();
  final RxList<PerformanceTaskItemApiData> apiTimelySubmissionsList = <PerformanceTaskItemApiData>[].obs;
  final Rxn<PerformanceQualityApiResponse> apiQualityResponse = Rxn<PerformanceQualityApiResponse>();
  final RxList<PerformanceQualityReviewItemApiData> apiQualityReviewsList = <PerformanceQualityReviewItemApiData>[].obs;

  // Calendar Date & Month selector
  late final Rx<DateTime> selectedDate;
  final RxString selectedMonthApi = ''.obs; // e.g. "2026-10"
  final RxString selectedMonthDisplay = ''.obs; // e.g. "October 2026"

  @override
  void onInit() {
    super.onInit();
    final now = DateTime.now();
    selectedDate = now.obs;
    selectedMonthApi.value = DateFormat('yyyy-MM').format(now);
    selectedMonthDisplay.value = DateFormat('MMMM yyyy').format(now);
  }

  /// Sets an initial month from parent or screen navigation if provided
  void setInitialMonth(String? month) {
    if (month == null || month.trim().isEmpty) return;
    try {
      if (month.contains('-')) {
        final parts = month.split('-');
        if (parts.length >= 2) {
          final year = int.parse(parts[0]);
          final m = int.parse(parts[1]);
          final dt = DateTime(year, m, 1);
          selectedDate.value = dt;
          selectedMonthApi.value = DateFormat('yyyy-MM').format(dt);
          selectedMonthDisplay.value = DateFormat('MMMM yyyy').format(dt);
        }
      }
    } catch (e) {
      Logger.e('EmployeePerformanceDetailController => Error parsing initial month: $e');
    }
  }

  /// Fetches individual employee performance details from backend API
  /// GET /api/admin/performance/employees/{id}?month=YYYY-MM
  Future<void> fetchEmployeeDetail({
    required dynamic employeeId,
    String? month,
  }) async {
    final queryMonth = month ?? selectedMonthApi.value;
    isLoading.value = true;
    errorMessage.value = '';

    Logger.d('EmployeePerformanceDetailController => Fetching detail for empId=$employeeId, month=$queryMonth');

    try {
      final response = await repository.getEmployeePerformanceDetail(
        employeeId: employeeId,
        month: queryMonth,
      );

      if (response.status && response.data != null) {
        detail.value = response.data;
        errorMessage.value = '';
        Logger.d('EmployeePerformanceDetailController => Loaded detail successfully for ${detail.value?.employee.name}');
      } else {
        errorMessage.value = response.message.isNotEmpty
            ? response.message
            : 'Failed to load employee performance details.';
        Logger.e('EmployeePerformanceDetailController => Error: ${errorMessage.value}');
      }

      // Concurrently fetch attendance summary for this employee and period
      try {
        final attResponse = await _attendanceRepository.getEmployeeAttendanceHistory(
          employeeId: employeeId,
          month: queryMonth,
        );
        if (attResponse.status && attResponse.data?.summary != null) {
          attendanceSummary.value = attResponse.data!.summary;
          Logger.d('EmployeePerformanceDetailController => Loaded attendance summary: present=${attResponse.data!.summary?.present}, workingDays=${attResponse.data!.summary?.workingDays}, pct=${attResponse.data!.summary?.attendancePercentage}%');
        }
      } catch (attErr) {
        Logger.w('EmployeePerformanceDetailController => Warning fetching attendance summary: $attErr');
      }

      // Concurrently fetch leaves for this employee and period
      try {
        final leaveResponse = await repository.getEmployeePerformanceLeaves(
          employeeId: employeeId,
          month: queryMonth,
        );
        if (leaveResponse.status) {
          apiLeaveResponse.value = leaveResponse;
          apiLeaves.value = leaveResponse.requests;
          Logger.d('EmployeePerformanceDetailController => Loaded leaves: count=${leaveResponse.requests.length}, annualBalance=${leaveResponse.summary?.annualBalance}');
        } else {
          apiLeaveResponse.value = null;
          apiLeaves.clear();
        }
      } catch (leaveErr) {
        apiLeaveResponse.value = null;
        apiLeaves.clear();
        Logger.w('EmployeePerformanceDetailController => Warning fetching leaves: $leaveErr');
      }

      // Concurrently fetch task completion for this employee and period
      try {
        final taskCompResponse = await repository.getEmployeePerformanceTaskCompletion(
          employeeId: employeeId,
          month: queryMonth,
        );
        if (taskCompResponse.status) {
          apiTaskCompletionResponse.value = taskCompResponse;
          apiTaskCompletionList.value = taskCompResponse.tasks;
          Logger.d('EmployeePerformanceDetailController => Loaded task completion: total=${taskCompResponse.summary?.total}, completed=${taskCompResponse.summary?.completed}, tasksCount=${taskCompResponse.tasks.length}');
        } else {
          apiTaskCompletionResponse.value = null;
          apiTaskCompletionList.clear();
        }
      } catch (taskErr) {
        apiTaskCompletionResponse.value = null;
        apiTaskCompletionList.clear();
        Logger.w('EmployeePerformanceDetailController => Warning fetching task completion: $taskErr');
      }

      // Concurrently fetch timely submissions for this employee and period
      try {
        final timelyResponse = await repository.getEmployeePerformanceTimelySubmissions(
          employeeId: employeeId,
          month: queryMonth,
        );
        if (timelyResponse.status) {
          apiTimelySubmissionsResponse.value = timelyResponse;
          apiTimelySubmissionsList.value = timelyResponse.tasks;
          Logger.d('EmployeePerformanceDetailController => Loaded timely submissions: onTime=${timelyResponse.summary?.onTime}, total=${timelyResponse.summary?.total}');
        } else {
          apiTimelySubmissionsResponse.value = null;
          apiTimelySubmissionsList.clear();
        }
      } catch (timelyErr) {
        apiTimelySubmissionsResponse.value = null;
        apiTimelySubmissionsList.clear();
        Logger.w('EmployeePerformanceDetailController => Warning fetching timely submissions: $timelyErr');
      }

      // Concurrently fetch quality of work for this employee and period
      try {
        final qualityResponse = await repository.getEmployeePerformanceQuality(
          employeeId: employeeId,
          month: queryMonth,
        );
        if (qualityResponse.status) {
          apiQualityResponse.value = qualityResponse;
          apiQualityReviewsList.value = qualityResponse.reviews;
          Logger.d('EmployeePerformanceDetailController => Loaded quality of work: overallPct=${qualityResponse.summary?.overallPercent}, reviewCount=${qualityResponse.summary?.reviewCount}');
        } else {
          apiQualityResponse.value = null;
          apiQualityReviewsList.clear();
        }
      } catch (qualityErr) {
        apiQualityResponse.value = null;
        apiQualityReviewsList.clear();
        Logger.w('EmployeePerformanceDetailController => Warning fetching quality of work: $qualityErr');
      }
    } catch (e, stackTrace) {
      Logger.e('EmployeePerformanceDetailController => Exception: $e\n$stackTrace');
      errorMessage.value = 'An unexpected error occurred: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Interactive Calendar Date Picker with Current Year
  Future<void> openDatePickerCalendar(BuildContext context, {required dynamic employeeId}) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final initial = selectedDate.value.isAfter(today) ? today : selectedDate.value;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 3, 1, 1),
      lastDate: today,
      currentDate: today,
      helpText: 'Select Date for Performance Period',
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
      selectedDate.value = pickedDate;
      selectedMonthApi.value = DateFormat('yyyy-MM').format(pickedDate);
      selectedMonthDisplay.value = DateFormat('MMMM yyyy').format(pickedDate);
      await fetchEmployeeDetail(employeeId: employeeId, month: selectedMonthApi.value);
    }
  }
}
