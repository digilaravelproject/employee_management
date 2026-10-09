import 'package:flutter/material.dart';
import 'package:dgm360/core/theme/app_colors.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/utils/logger.dart';
import '../models/leave_report_model.dart';
import '../repositories/admin_leave_repository.dart';
import '../repositories/admin_leave_repository_interface.dart';

class ReportFilterOption {
  final dynamic id;
  final String name;

  ReportFilterOption({required this.id, required this.name});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportFilterOption &&
          runtimeType == other.runtimeType &&
          id.toString() == other.id.toString();

  @override
  int get hashCode => id.hashCode;
}

class LeaveReportsController extends GetxController {
  final AdminLeaveRepositoryInterface repository;

  LeaveReportsController({AdminLeaveRepositoryInterface? repository})
      : repository = repository ??
            (Get.isRegistered<AdminLeaveRepositoryInterface>()
                ? Get.find<AdminLeaveRepositoryInterface>()
                : AdminLeaveRepository(
                    apiClient: Get.isRegistered<ApiClient>()
                        ? Get.find<ApiClient>()
                        : Get.put(ApiClient(), permanent: true),
                  ));

  // ── Observables ────────────────────────────────────────────────
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxString errorMessage = ''.obs;

  final Rxn<LeaveReportResponseModel> reportResponse = Rxn<LeaveReportResponseModel>();

  // Filter Observables
  final RxString selectedDateRangePreset = 'This Month'.obs;
  final Rxn<DateTimeRange> customDateRange = Rxn<DateTimeRange>();

  final Rxn<dynamic> selectedDepartmentId = Rxn<dynamic>();
  final RxString selectedDepartmentName = 'All Departments'.obs;

  final Rxn<dynamic> selectedLeaveTypeId = Rxn<dynamic>();
  final RxString selectedLeaveTypeName = 'All Leave Types'.obs;

  final RxString selectedStatus = 'all'.obs; // 'all', 'approved', 'rejected', 'pending'

  // Dynamic Options
  final RxList<ReportFilterOption> departmentOptions = <ReportFilterOption>[
    ReportFilterOption(id: null, name: 'All Departments'),
  ].obs;

  final RxList<ReportFilterOption> leaveTypeOptions = <ReportFilterOption>[
    ReportFilterOption(id: null, name: 'All Leave Types'),
  ].obs;

  final List<String> dateRangePresets = [
    'This Month',
    'Today',
    'This Week',
    'Last Month',
    'Custom Date Range...',
  ];

  final List<String> statusOptions = [
    'All Status',
    'Approved',
    'Rejected',
    'Pending',
  ];

  @override
  void onInit() {
    super.onInit();
    _fetchDepartmentOptions();
    _fetchLeaveTypeOptions();
    fetchLeaveReport();
  }

  // ── Fetch Departments ──────────────────────────────────────────
  Future<void> _fetchDepartmentOptions() async {
    try {
      if (Get.isRegistered<ApiClient>()) {
        final apiClient = Get.find<ApiClient>();
        final response = await apiClient.get(AppConstants.adminDepartmentsUrl, handleError: false, showToaster: false);
        if (response.isSuccess && response.json != null) {
          final data = response.json!['data'];
          if (data is List) {
            final List<ReportFilterOption> loaded = [ReportFilterOption(id: null, name: 'All Departments')];
            for (var item in data) {
              if (item is Map<String, dynamic>) {
                loaded.add(ReportFilterOption(
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
      Logger.d('LeaveReportsController => fetchDepartmentOptions error: $e');
    }
  }

  // ── Fetch Leave Types ──────────────────────────────────────────
  Future<void> _fetchLeaveTypeOptions() async {
    try {
      if (Get.isRegistered<ApiClient>()) {
        final apiClient = Get.find<ApiClient>();
        final response = await apiClient.get(AppConstants.adminLeaveTypesUrl, handleError: false, showToaster: false);
        if (response.isSuccess && response.json != null) {
          final data = response.json!['data'];
          if (data is List) {
            final List<ReportFilterOption> loaded = [ReportFilterOption(id: null, name: 'All Leave Types')];
            for (var item in data) {
              if (item is Map<String, dynamic>) {
                loaded.add(ReportFilterOption(
                  id: item['id'],
                  name: item['name']?.toString() ?? 'Leave ${item['id']}',
                ));
              }
            }
            if (loaded.length > 1) {
              leaveTypeOptions.assignAll(loaded);
            }
          }
        }
      }
    } catch (e) {
      Logger.d('LeaveReportsController => fetchLeaveTypeOptions error: $e');
    }
  }

  // ── Date Range Calculation ─────────────────────────────────────
  Map<String, String> get resolvedDateRange {
    final now = DateTime.now();
    DateTime start;
    DateTime end;

    switch (selectedDateRangePreset.value) {
      case 'Today':
        start = DateTime(now.year, now.month, now.day);
        end = DateTime(now.year, now.month, now.day);
        break;
      case 'This Week':
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
        end = DateTime(now.year, now.month, now.day);
        break;
      case 'Last Month':
        start = DateTime(now.year, now.month - 1, 1);
        end = DateTime(now.year, now.month, 0);
        break;
      case 'Custom Date Range...':
        if (customDateRange.value != null) {
          start = customDateRange.value!.start;
          end = customDateRange.value!.end.isAfter(now) ? now : customDateRange.value!.end;
        } else {
          start = DateTime(now.year, now.month, 1);
          end = DateTime(now.year, now.month + 1, 0);
        }
        break;
      case 'This Month':
      default:
        start = DateTime(now.year, now.month, 1);
        final lastDay = DateTime(now.year, now.month + 1, 0).day;
        end = DateTime(now.year, now.month, lastDay);
        break;
    }

    return {
      'from_date': DateFormat('yyyy-MM-dd').format(start),
      'to_date': DateFormat('yyyy-MM-dd').format(end),
    };
  }

  String get formattedDisplayDateRange {
    final dates = resolvedDateRange;
    try {
      final f = DateTime.parse(dates['from_date']!);
      final t = DateTime.parse(dates['to_date']!);
      return '${DateFormat('dd MMM yyyy').format(f)} - ${DateFormat('dd MMM yyyy').format(t)}';
    } catch (_) {
      return '${dates['from_date']} to ${dates['to_date']}';
    }
  }

  // ── Fetch Leave Report from API ────────────────────────────────
  Future<void> fetchLeaveReport({bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        isRefreshing.value = true;
      } else {
        isLoading.value = true;
      }
      errorMessage.value = '';

      final dates = resolvedDateRange;
      final fromDate = dates['from_date']!;
      final toDate = dates['to_date']!;

      Logger.d('LeaveReportsController => Fetching report: from=$fromDate, to=$toDate, dept=${selectedDepartmentId.value}, type=${selectedLeaveTypeId.value}, status=${selectedStatus.value}');

      final response = await repository.getLeaveReports(
        fromDate: fromDate,
        toDate: toDate,
        departmentId: selectedDepartmentId.value,
        leaveTypeId: selectedLeaveTypeId.value,
        status: selectedStatus.value,
      );

      if (response.status) {
        reportResponse.value = response;
        Logger.d('LeaveReportsController => Loaded report successfully: ${response.data.length} records, total_requests=${response.summary?.totalRequests}');
      } else {
        errorMessage.value = response.message.isNotEmpty
            ? response.message
            : 'Failed to retrieve leave report.';
        Logger.w('LeaveReportsController => Error: ${errorMessage.value}');
      }
    } catch (e) {
      Logger.e('LeaveReportsController => Exception in fetchLeaveReport: $e');
      errorMessage.value = 'Failed to load leave report: ${e.toString()}';
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  // ── Filter Setters ─────────────────────────────────────────────
  void setDepartment(ReportFilterOption option) {
    if (selectedDepartmentId.value != option.id) {
      selectedDepartmentId.value = option.id;
      selectedDepartmentName.value = option.name;
      fetchLeaveReport();
    }
  }

  void setLeaveType(ReportFilterOption option) {
    if (selectedLeaveTypeId.value != option.id) {
      selectedLeaveTypeId.value = option.id;
      selectedLeaveTypeName.value = option.name;
      fetchLeaveReport();
    }
  }

  void setStatus(String statusLabel) {
    String apiStatus = 'all';
    if (statusLabel == 'Approved') apiStatus = 'approved';
    if (statusLabel == 'Rejected') apiStatus = 'rejected';
    if (statusLabel == 'Pending') apiStatus = 'pending';

    if (selectedStatus.value != apiStatus) {
      selectedStatus.value = apiStatus;
      fetchLeaveReport();
    }
  }

  void setDatePreset(String preset, [DateTimeRange? customRange]) {
    selectedDateRangePreset.value = preset;
    if (preset == 'Custom Date Range...' && customRange != null) {
      final now = DateTime.now();
      customDateRange.value = DateTimeRange(
        start: customRange.start.isAfter(now) ? now : customRange.start,
        end: customRange.end.isAfter(now) ? now : customRange.end,
      );
    } else if (preset != 'Custom Date Range...') {
      customDateRange.value = null;
    }
    fetchLeaveReport();
  }

  bool get hasActiveFilters {
    return selectedDepartmentId.value != null ||
        selectedLeaveTypeId.value != null ||
        selectedStatus.value != 'all' ||
        selectedDateRangePreset.value != 'This Month';
  }

  void resetAllFilters() {
    selectedDateRangePreset.value = 'This Month';
    customDateRange.value = null;
    selectedDepartmentId.value = null;
    selectedDepartmentName.value = 'All Departments';
    selectedLeaveTypeId.value = null;
    selectedLeaveTypeName.value = 'All Leave Types';
    selectedStatus.value = 'all';
    fetchLeaveReport();
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return const Color(0xFF10B981);
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'rejected':
      case 'declined':
        return const Color(0xFFEF4444);
      case 'cancelled':
        return const Color(0xFF6B7280);
      default:
        return AppColors.primaryColor;
    }
  }
}
