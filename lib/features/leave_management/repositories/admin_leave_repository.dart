import '../../../core/constants/app_constants.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/services/network/response_model.dart';
import '../../../core/utils/logger.dart';
import '../models/admin_leave_model.dart';
import 'admin_leave_repository_interface.dart';

class AdminLeaveRepository implements AdminLeaveRepositoryInterface {
  final ApiClient apiClient;

  AdminLeaveRepository({required this.apiClient});

  @override
  Future<AdminLeaveListResponseModel> getLeaveRequests({
    String? status,
    String? dateRange,
    String? startDate,
    String? endDate,
    dynamic departmentId,
    dynamic leaveTypeId,
    String? search,
    int? page,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};

      if (status != null && status.isNotEmpty && status.toLowerCase() != 'all') {
        queryParams['status'] = status;
      }
      if (dateRange != null && dateRange.isNotEmpty && dateRange.toLowerCase() != 'all' && dateRange != 'All Time') {
        queryParams['date_range'] = dateRange;
      }
      if (startDate != null && startDate.isNotEmpty) {
        queryParams['start_date'] = startDate;
      }
      if (endDate != null && endDate.isNotEmpty) {
        queryParams['end_date'] = endDate;
      }
      if (departmentId != null &&
          departmentId.toString().isNotEmpty &&
          departmentId.toString() != 'All' &&
          departmentId.toString() != '0') {
        queryParams['department_id'] = departmentId;
      }
      if (leaveTypeId != null &&
          leaveTypeId.toString().isNotEmpty &&
          leaveTypeId.toString() != 'All' &&
          leaveTypeId.toString() != '0') {
        queryParams['leave_type_id'] = leaveTypeId;
      }
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }
      if (page != null && page > 0) {
        queryParams['page'] = page;
      }

      Logger.d('AdminLeaveRepository => Calling ${AppConstants.adminLeaveRequestsUrl} with queryParams: $queryParams');

      final response = await apiClient.get(
        AppConstants.adminLeaveRequestsUrl,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        handleError: false,
        showToaster: false,
      );

      Logger.d('AdminLeaveRepository => Status: ${response.statusCode}, isSuccess: ${response.isSuccess}');
      Logger.d('AdminLeaveRepository => Raw Data: ${response.json ?? response.body}');

      if (response.json != null) {
        return AdminLeaveListResponseModel.fromJson(response.json!);
      } else if (response.body is Map<String, dynamic>) {
        return AdminLeaveListResponseModel.fromJson(response.body as Map<String, dynamic>);
      } else {
        return AdminLeaveListResponseModel(
          status: response.isSuccess,
          message: response.message.isNotEmpty
              ? response.message
              : (response.isSuccess ? 'Leave requests retrieved successfully.' : 'Failed to retrieve leave requests.'),
          data: [],
        );
      }
    } catch (e, stackTrace) {
      Logger.e('AdminLeaveRepository => Exception in getLeaveRequests: $e');
      Logger.e('AdminLeaveRepository => StackTrace: $stackTrace');
      return AdminLeaveListResponseModel(
        status: false,
        message: 'Something went wrong while fetching leave requests: ${e.toString()}',
        data: [],
      );
    }
  }

  @override
  Future<AdminLeaveDetailResponseModel> getLeaveRequestDetails(int id) async {
    try {
      final endpoint = '${AppConstants.adminLeaveRequestsUrl}/$id';
      Logger.d('AdminLeaveRepository => Calling endpoint: $endpoint');

      final response = await apiClient.get(
        endpoint,
        handleError: false,
        showToaster: false,
      );

      Logger.d('AdminLeaveRepository => Detail Status: ${response.statusCode}, isSuccess: ${response.isSuccess}');
      Logger.d('AdminLeaveRepository => Detail Raw Data: ${response.json ?? response.body}');

      if (response.json != null) {
        return AdminLeaveDetailResponseModel.fromJson(response.json!);
      } else if (response.body is Map<String, dynamic>) {
        return AdminLeaveDetailResponseModel.fromJson(response.body as Map<String, dynamic>);
      } else {
        return AdminLeaveDetailResponseModel(
          status: response.isSuccess,
          message: response.message.isNotEmpty
              ? response.message
              : (response.isSuccess ? 'Leave request details retrieved successfully.' : 'Failed to retrieve details.'),
        );
      }
    } catch (e, stackTrace) {
      Logger.e('AdminLeaveRepository => Exception in getLeaveRequestDetails: $e');
      Logger.e('AdminLeaveRepository => StackTrace: $stackTrace');
      return AdminLeaveDetailResponseModel(
        status: false,
        message: 'Something went wrong while fetching leave details: ${e.toString()}',
      );
    }
  }

  @override
  Future<ResponseModel> approveLeaveRequest(int id, {String? note}) async {
    try {
      final endpoint = '${AppConstants.adminLeaveRequestsUrl}/$id/approve';
      Logger.d('AdminLeaveRepository => Approving leave request: $endpoint with note: $note');

      final response = await apiClient.post(
        endpoint,
        data: {
          'note': note ?? 'Approved by reporting manager.',
        },
        handleError: false,
        showToaster: false,
      );

      Logger.d('AdminLeaveRepository => Approve Status: ${response.statusCode}, isSuccess: ${response.isSuccess}');
      return response;
    } catch (e, stackTrace) {
      Logger.e('AdminLeaveRepository => Exception in approveLeaveRequest: $e');
      Logger.e('AdminLeaveRepository => StackTrace: $stackTrace');
      return ResponseModel(
        isSuccess: false,
        message: 'Something went wrong while approving leave request: ${e.toString()}',
      );
    }
  }

  @override
  Future<ResponseModel> rejectLeaveRequest(int id, {String? note}) async {
    try {
      final endpoint = '${AppConstants.adminLeaveRequestsUrl}/$id/reject';
      Logger.d('AdminLeaveRepository => Rejecting leave request: $endpoint with note: $note');

      final response = await apiClient.post(
        endpoint,
        data: {
          'note': note ?? 'Insufficient supporting information.',
        },
        handleError: false,
        showToaster: false,
      );

      Logger.d('AdminLeaveRepository => Reject Status: ${response.statusCode}, isSuccess: ${response.isSuccess}');
      return response;
    } catch (e, stackTrace) {
      Logger.e('AdminLeaveRepository => Exception in rejectLeaveRequest: $e');
      Logger.e('AdminLeaveRepository => StackTrace: $stackTrace');
      return ResponseModel(
        isSuccess: false,
        message: 'Something went wrong while rejecting leave request: ${e.toString()}',
      );
    }
  }
}
