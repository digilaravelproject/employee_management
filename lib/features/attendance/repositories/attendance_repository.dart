import '../../../core/constants/app_constants.dart';
import '../../../core/services/network/api_client.dart';
import '../models/attendance_history_response_model.dart';
import '../models/check_in_model.dart';

class AttendanceRepository {
  final ApiClient apiClient;

  AttendanceRepository({required this.apiClient});

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
      '/api/admin/attendance/history',
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
}
