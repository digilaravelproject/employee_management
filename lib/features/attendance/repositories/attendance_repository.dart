import '../../../core/services/network/api_client.dart';
import '../models/attendance_history_response_model.dart';

class AttendanceRepository {
  final ApiClient apiClient;

  AttendanceRepository({required this.apiClient});

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
