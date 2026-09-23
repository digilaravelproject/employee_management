import '../../../core/constants/app_constants.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/utils/logger.dart';
import '../models/apply_leave_request_model.dart';
import '../models/apply_leave_response_model.dart';
import '../models/leave_type_model.dart';
import 'apply_leave_repository_interface.dart';

class ApplyLeaveRepository implements ApplyLeaveRepositoryInterface {
  final ApiClient apiClient;

  ApplyLeaveRepository({required this.apiClient});

  @override
  Future<LeaveTypeListResponseModel> getLeaveTypes() async {
    try {
      Logger.d('ApplyLeaveRepository => Fetching leave types from ${AppConstants.adminLeaveTypesUrl}');
      final response = await apiClient.get(
        AppConstants.adminLeaveTypesUrl,
        handleError: false,
        showToaster: false,
      );

      Logger.d('ApplyLeaveRepository => Leave types response: status=${response.statusCode}, isSuccess=${response.isSuccess}');

      if (response.json != null) {
        return LeaveTypeListResponseModel.fromJson(response.json!);
      } else if (response.body is Map<String, dynamic>) {
        return LeaveTypeListResponseModel.fromJson(response.body as Map<String, dynamic>);
      }

      return LeaveTypeListResponseModel(
        status: response.isSuccess,
        message: response.message.isNotEmpty ? response.message : 'Failed to retrieve leave types',
        data: [],
      );
    } catch (e, stackTrace) {
      Logger.e('ApplyLeaveRepository => Exception in getLeaveTypes: $e');
      Logger.e('ApplyLeaveRepository => StackTrace: $stackTrace');
      return LeaveTypeListResponseModel(
        status: false,
        message: 'Failed to fetch leave types: $e',
        data: [],
      );
    }
  }

  @override
  Future<ApplyLeaveResponseModel> applyLeave(ApplyLeaveRequestModel request) async {
    try {
      Logger.d('ApplyLeaveRepository => Submitting leave request to ${AppConstants.adminLeaveRequestsUrl}');
      final formData = await request.toFormData();

      final response = await apiClient.post(
        AppConstants.adminLeaveRequestsUrl,
        data: formData,
        handleError: false,
        showToaster: false,
      );

      Logger.d('ApplyLeaveRepository => Apply leave response: status=${response.statusCode}, isSuccess=${response.isSuccess}');

      if (response.json != null) {
        return ApplyLeaveResponseModel.fromJson(response.json!);
      } else if (response.body is Map<String, dynamic>) {
        return ApplyLeaveResponseModel.fromJson(response.body as Map<String, dynamic>);
      }

      return ApplyLeaveResponseModel(
        status: response.isSuccess,
        message: response.message.isNotEmpty
            ? response.message
            : (response.isSuccess ? 'Leave applied successfully' : 'Failed to apply leave'),
      );
    } catch (e, stackTrace) {
      Logger.e('ApplyLeaveRepository => Exception in applyLeave: $e');
      Logger.e('ApplyLeaveRepository => StackTrace: $stackTrace');
      return ApplyLeaveResponseModel(
        status: false,
        message: 'Something went wrong while applying for leave: $e',
      );
    }
  }
}
