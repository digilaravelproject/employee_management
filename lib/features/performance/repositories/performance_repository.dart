import '../../../core/constants/app_constants.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/utils/logger.dart';
import '../models/employee_performance_response_model.dart';
import '../models/performance_leave_api_response.dart';
import '../models/performance_messages_api_response.dart';
import '../models/performance_quality_api_response.dart';
import '../models/performance_task_completion_api_response.dart';
import 'performance_repository_interface.dart';

class PerformanceRepository implements PerformanceRepositoryInterface {
  final ApiClient apiClient;

  PerformanceRepository({required this.apiClient});

  @override
  Future<EmployeePerformanceResponseModel> getEmployeePerformance({
    required String month,
    String view = 'team',
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final queryParams = {
        'month': month,
        'view': view,
        'page': page,
        'per_page': perPage,
      };

      Logger.d('PerformanceRepository => Fetching performance: ${AppConstants.adminPerformanceEmployeesUrl} with $queryParams');

      final response = await apiClient.get(
        AppConstants.adminPerformanceEmployeesUrl,
        queryParameters: queryParams,
        handleError: false,
        showToaster: false,
      );

      Logger.d('PerformanceRepository => Response isSuccess: ${response.isSuccess}, statusCode: ${response.statusCode}');

      // Priority 1: Check full raw JSON map returned by server
      if (response.json != null && response.json is Map<String, dynamic>) {
        Logger.d('PerformanceRepository => Parsing response.json');
        return EmployeePerformanceResponseModel.fromJson(response.json!);
      }

      // Priority 2: Check response.body if it's the root Map
      if (response.body is Map<String, dynamic>) {
        Logger.d('PerformanceRepository => Parsing response.body as Map');
        return EmployeePerformanceResponseModel.fromJson(response.body as Map<String, dynamic>);
      }

      // Priority 3: If response.body is only the data list
      if (response.body is List) {
        Logger.d('PerformanceRepository => Parsing response.body as List of items');
        final items = (response.body as List)
            .whereType<Map<String, dynamic>>()
            .map((i) => EmployeePerformanceItemModel.fromJson(i))
            .toList();
        return EmployeePerformanceResponseModel(
          status: response.isSuccess,
          message: response.message,
          data: items,
        );
      }

      return EmployeePerformanceResponseModel(
        status: false,
        message: response.message.isNotEmpty ? response.message : 'Failed to retrieve employee performance.',
      );
    } catch (e, stackTrace) {
      Logger.e('PerformanceRepository => Exception in getEmployeePerformance: $e\n$stackTrace');
      return EmployeePerformanceResponseModel(
        status: false,
        message: 'Something went wrong while fetching employee performance: $e',
      );
    }
  }

  @override
  Future<EmployeePerformanceDetailResponseModel> getEmployeePerformanceDetail({
    required dynamic employeeId,
    required String month,
  }) async {
    try {
      final endpoint = AppConstants.adminEmployeePerformanceDetailUrl(employeeId);
      final queryParams = {'month': month};

      Logger.d('PerformanceRepository => Fetching employee detail: $endpoint with $queryParams');

      final response = await apiClient.get(
        endpoint,
        queryParameters: queryParams,
        handleError: false,
        showToaster: false,
      );

      Logger.d('PerformanceRepository => Response isSuccess: ${response.isSuccess}, statusCode: ${response.statusCode}');

      // Priority 1: Full raw JSON map returned by server
      if (response.json != null && response.json is Map<String, dynamic>) {
        Logger.d('PerformanceRepository => Parsing response.json for detail');
        return EmployeePerformanceDetailResponseModel.fromJson(response.json!);
      }

      // Priority 2: Check response.body if it's a Map
      if (response.body is Map<String, dynamic>) {
        Logger.d('PerformanceRepository => Parsing response.body as Map for detail');
        return EmployeePerformanceDetailResponseModel.fromJson(response.body as Map<String, dynamic>);
      }

      return EmployeePerformanceDetailResponseModel(
        status: false,
        message: response.message.isNotEmpty ? response.message : 'Failed to retrieve employee performance detail.',
      );
    } catch (e, stackTrace) {
      Logger.e('PerformanceRepository => Exception in getEmployeePerformanceDetail: $e\n$stackTrace');
      return EmployeePerformanceDetailResponseModel(
        status: false,
        message: 'Something went wrong while fetching employee detail: $e',
      );
    }
  }

  @override
  Future<PerformanceLeaveApiResponse> getEmployeePerformanceLeaves({
    required dynamic employeeId,
    required String month,
  }) async {
    try {
      final endpoint = AppConstants.adminEmployeePerformanceLeaveUrl(employeeId);
      final queryParams = {'month': month};

      Logger.d('PerformanceRepository => Fetching leaves: $endpoint with $queryParams');

      final response = await apiClient.get(
        endpoint,
        queryParameters: queryParams,
        handleError: false,
        showToaster: false,
      );

      Logger.d('PerformanceRepository => Leaves Response isSuccess: ${response.isSuccess}, statusCode: ${response.statusCode}');

      if (response.json != null && response.json is Map<String, dynamic>) {
        return PerformanceLeaveApiResponse.fromJson(response.json!);
      }

      if (response.body is Map<String, dynamic>) {
        return PerformanceLeaveApiResponse.fromJson(response.body as Map<String, dynamic>);
      }

      return PerformanceLeaveApiResponse(
        status: false,
        message: response.message.isNotEmpty ? response.message : 'Failed to retrieve leaves.',
        requests: [],
      );
    } catch (e, stackTrace) {
      Logger.e('PerformanceRepository => Exception in getEmployeePerformanceLeaves: $e\n$stackTrace');
      return PerformanceLeaveApiResponse(
        status: false,
        message: 'Something went wrong while fetching leaves: $e',
        requests: [],
      );
    }
  }

  @override
  Future<PerformanceTaskCompletionApiResponse> getEmployeePerformanceTaskCompletion({
    required dynamic employeeId,
    required String month,
  }) async {
    try {
      final endpoint = AppConstants.adminEmployeePerformanceTaskCompletionUrl(employeeId);
      final queryParams = {'month': month};

      Logger.d('PerformanceRepository => Fetching task completion: $endpoint with $queryParams');

      final response = await apiClient.get(
        endpoint,
        queryParameters: queryParams,
        handleError: false,
        showToaster: false,
      );

      Logger.d('PerformanceRepository => Task Completion Response isSuccess: ${response.isSuccess}, statusCode: ${response.statusCode}');

      if (response.json != null && response.json is Map<String, dynamic>) {
        return PerformanceTaskCompletionApiResponse.fromJson(response.json!);
      }

      if (response.body is Map<String, dynamic>) {
        return PerformanceTaskCompletionApiResponse.fromJson(response.body as Map<String, dynamic>);
      }

      return PerformanceTaskCompletionApiResponse(
        status: false,
        message: response.message.isNotEmpty ? response.message : 'Failed to retrieve task completion details.',
        tasks: [],
      );
    } catch (e, stackTrace) {
      Logger.e('PerformanceRepository => Exception in getEmployeePerformanceTaskCompletion: $e\n$stackTrace');
      return PerformanceTaskCompletionApiResponse(
        status: false,
        message: 'Something went wrong while fetching task completion details: $e',
        tasks: [],
      );
    }
  }

  @override
  Future<PerformanceTaskCompletionApiResponse> getEmployeePerformanceTimelySubmissions({
    required dynamic employeeId,
    required String month,
  }) async {
    try {
      final endpoint = AppConstants.adminEmployeePerformanceTimelySubmissionsUrl(employeeId);
      final queryParams = {'month': month};

      Logger.d('PerformanceRepository => Fetching timely submissions: $endpoint with $queryParams');

      final response = await apiClient.get(
        endpoint,
        queryParameters: queryParams,
        handleError: false,
        showToaster: false,
      );

      Logger.d('PerformanceRepository => Timely Submissions Response isSuccess: ${response.isSuccess}, statusCode: ${response.statusCode}');

      if (response.json != null && response.json is Map<String, dynamic>) {
        return PerformanceTaskCompletionApiResponse.fromJson(response.json!);
      }

      if (response.body is Map<String, dynamic>) {
        return PerformanceTaskCompletionApiResponse.fromJson(response.body as Map<String, dynamic>);
      }

      return PerformanceTaskCompletionApiResponse(
        status: false,
        message: response.message.isNotEmpty ? response.message : 'Failed to retrieve timely submissions details.',
        tasks: [],
      );
    } catch (e, stackTrace) {
      Logger.e('PerformanceRepository => Exception in getEmployeePerformanceTimelySubmissions: $e\n$stackTrace');
      return PerformanceTaskCompletionApiResponse(
        status: false,
        message: 'Something went wrong while fetching timely submissions details: $e',
        tasks: [],
      );
    }
  }

  @override
  Future<PerformanceQualityApiResponse> getEmployeePerformanceQuality({
    required dynamic employeeId,
    required String month,
  }) async {
    try {
      final endpoint = AppConstants.adminEmployeePerformanceQualityUrl(employeeId);
      final queryParams = {'month': month};

      Logger.d('PerformanceRepository => Fetching quality of work: $endpoint with $queryParams');

      final response = await apiClient.get(
        endpoint,
        queryParameters: queryParams,
        handleError: false,
        showToaster: false,
      );

      Logger.d('PerformanceRepository => Quality Response isSuccess: ${response.isSuccess}, statusCode: ${response.statusCode}');

      if (response.json != null && response.json is Map<String, dynamic>) {
        return PerformanceQualityApiResponse.fromJson(response.json!);
      }

      if (response.body is Map<String, dynamic>) {
        return PerformanceQualityApiResponse.fromJson(response.body as Map<String, dynamic>);
      }

      return PerformanceQualityApiResponse(
        status: false,
        message: response.message.isNotEmpty ? response.message : 'Failed to retrieve quality details.',
        reviews: [],
      );
    } catch (e, stackTrace) {
      Logger.e('PerformanceRepository => Exception in getEmployeePerformanceQuality: $e\n$stackTrace');
      return PerformanceQualityApiResponse(
        status: false,
        message: 'Something went wrong while fetching quality details: $e',
        reviews: [],
      );
    }
  }

  @override
  Future<PerformanceMessagesApiResponse> getEmployeePerformanceMessages({
    required dynamic employeeId,
    int page = 1,
    int perPage = 50,
  }) async {
    try {
      final endpoint = AppConstants.adminEmployeePerformanceMessagesUrl(employeeId);
      final queryParams = {
        'page': page,
        'per_page': perPage,
      };

      Logger.d('PerformanceRepository => Fetching messages: $endpoint with $queryParams');

      final response = await apiClient.get(
        endpoint,
        queryParameters: queryParams,
        handleError: false,
        showToaster: false,
      );

      Logger.d('PerformanceRepository => Messages Response isSuccess: ${response.isSuccess}, statusCode: ${response.statusCode}');

      if (response.json != null && response.json is Map<String, dynamic>) {
        return PerformanceMessagesApiResponse.fromJson(response.json!);
      }

      if (response.body is Map<String, dynamic>) {
        return PerformanceMessagesApiResponse.fromJson(response.body as Map<String, dynamic>);
      }

      return PerformanceMessagesApiResponse(
        status: false,
        message: response.message.isNotEmpty ? response.message : 'Failed to retrieve message history.',
        data: [],
      );
    } catch (e, stackTrace) {
      Logger.e('PerformanceRepository => Exception in getEmployeePerformanceMessages: $e\n$stackTrace');
      return PerformanceMessagesApiResponse(
        status: false,
        message: 'Something went wrong while fetching message history: $e',
        data: [],
      );
    }
  }

  @override
  Future<PerformanceMessageItemApiData?> sendEmployeePerformanceMessage({
    required dynamic employeeId,
    required String message,
  }) async {
    try {
      final endpoint = AppConstants.adminEmployeePerformanceMessagesUrl(employeeId);
      final body = {'message': message};

      Logger.d('PerformanceRepository => Sending message: $endpoint with body: $body');

      final response = await apiClient.post(
        endpoint,
        data: body,
        handleError: false,
        showToaster: false,
      );

      Logger.d('PerformanceRepository => Send Message Response isSuccess: ${response.isSuccess}, statusCode: ${response.statusCode}');

      if (response.json != null && response.json is Map<String, dynamic>) {
        final data = response.json!['data'];
        if (data is Map<String, dynamic>) {
          return PerformanceMessageItemApiData.fromJson(data);
        }
      }

      if (response.body is Map<String, dynamic>) {
        final data = (response.body as Map<String, dynamic>)['data'];
        if (data is Map<String, dynamic>) {
          return PerformanceMessageItemApiData.fromJson(data);
        }
      }

      return null;
    } catch (e, stackTrace) {
      Logger.e('PerformanceRepository => Exception in sendEmployeePerformanceMessage: $e\n$stackTrace');
      return null;
    }
  }
}
