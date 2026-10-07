import '../../../core/constants/app_constants.dart';
import '../../../core/services/network/api_client.dart';
import '../models/admin_attendance_model.dart';
import '../models/attendance_history_response_model.dart';
import '../models/check_in_model.dart';

class AttendanceRepository {
  final ApiClient apiClient;

  AttendanceRepository({required this.apiClient});

  Future<AdminAttendanceResponseModel> getAdminAttendance({
    required String date,
    String? search,
    String? status,
    String? sort = 'name',
    String? direction = 'asc',
  }) async {
    final Map<String, dynamic> query = {
      'date': date,
    };
    if (search != null && search.trim().isNotEmpty) {
      query['search'] = search.trim();
    }
    if (status != null && status.isNotEmpty && status.toLowerCase() != 'all') {
      query['status'] = status;
    }
    if (sort != null && sort.isNotEmpty) {
      query['sort'] = sort;
    }
    if (direction != null && direction.isNotEmpty) {
      query['direction'] = direction;
    }

    final response = await apiClient.get(
      AppConstants.adminAttendanceUrl,
      queryParameters: query,
      handleError: false,
      showToaster: false,
    );

    final json = response.json ?? (response.body is Map ? Map<String, dynamic>.from(response.body as Map) : null);
    if (json != null) {
      return AdminAttendanceResponseModel.fromJson(json);
    }
    return AdminAttendanceResponseModel(
      status: false,
      message: response.message.isNotEmpty ? response.message : 'Failed to retrieve attendance data',
    );
  }

  Future<CheckInResponseModel> checkIn(CheckInRequestModel request) async {
    final response = await apiClient.post(
      AppConstants.adminAttendanceCheckInUrl,
      data: request.toJson(),
      handleError: false,
      showToaster: false,
    );

    final json = response.json ?? (response.body is Map<String, dynamic> ? response.body as Map<String, dynamic> : null);
    if (json != null) {
      return CheckInResponseModel.fromJson(json);
    }
    return CheckInResponseModel(
      status: false,
      message: response.message.isNotEmpty ? response.message : 'Failed to check in. Please try again.',
    );
  }

  Future<CheckOutResponseModel> checkOut(CheckOutRequestModel request) async {
    final response = await apiClient.post(
      AppConstants.adminAttendanceCheckOutUrl,
      data: request.toJson(),
      handleError: false,
      showToaster: false,
    );

    final json = response.json ?? (response.body is Map<String, dynamic> ? response.body as Map<String, dynamic> : null);
    if (json != null) {
      return CheckOutResponseModel.fromJson(json);
    }
    return CheckOutResponseModel(
      status: false,
      message: response.message.isNotEmpty ? response.message : 'Failed to clock out. Please try again.',
    );
  }

  Future<AttendanceHistoryResponseModel> getAttendanceHistory(String month) async {
    final response = await apiClient.get(
      AppConstants.adminAttendanceHistoryUrl,
      queryParameters: {'month': month},
      handleError: false,
      showToaster: false,
    );

    final json = response.json ?? (response.body is Map<String, dynamic> ? response.body as Map<String, dynamic> : null);
    if (json != null) {
      return AttendanceHistoryResponseModel.fromJson(json);
    }
    return AttendanceHistoryResponseModel(
      status: false,
      message: response.message.isNotEmpty ? response.message : 'Invalid response format',
    );
  }

  Future<AttendanceHistoryResponseModel> getEmployeeAttendanceHistory({
    required dynamic employeeId,
    required String month,
  }) async {
    final endpoint = AppConstants.adminEmployeePerformanceAttendanceUrl(employeeId);
    final response = await apiClient.get(
      endpoint,
      queryParameters: {'month': month},
      handleError: false,
      showToaster: false,
    );

    final json = response.json ?? (response.body is Map<String, dynamic> ? response.body as Map<String, dynamic> : null);
    if (json != null) {
      return AttendanceHistoryResponseModel.fromJson(json);
    }
    return AttendanceHistoryResponseModel(
      status: false,
      message: response.message.isNotEmpty
          ? response.message
          : 'Failed to retrieve employee attendance history',
    );
  }
}
