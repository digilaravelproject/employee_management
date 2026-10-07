import '../models/employee_performance_response_model.dart';
import '../models/performance_leave_api_response.dart';
import '../models/performance_messages_api_response.dart';
import '../models/performance_quality_api_response.dart';
import '../models/performance_task_completion_api_response.dart';

abstract class PerformanceRepositoryInterface {
  /// Fetches employee performance rankings and summary for a given month and view
  /// GET /api/admin/performance/employees?month=YYYY-MM&view=team&page=1&per_page=20
  Future<EmployeePerformanceResponseModel> getEmployeePerformance({
    required String month,
    String view = 'team',
    int page = 1,
    int perPage = 20,
  });

  /// Fetches individual employee performance details for a given month
  /// GET /api/admin/performance/employees/{id}?month=YYYY-MM
  Future<EmployeePerformanceDetailResponseModel> getEmployeePerformanceDetail({
    required dynamic employeeId,
    required String month,
  });

  /// Fetches individual employee leaves for a given month
  /// GET /api/admin/performance/employees/{id}/leave?month=YYYY-MM
  Future<PerformanceLeaveApiResponse> getEmployeePerformanceLeaves({
    required dynamic employeeId,
    required String month,
  });

  /// Fetches individual employee task completion details for a given month
  /// GET /api/admin/performance/employees/{id}/task-completion?month=YYYY-MM
  Future<PerformanceTaskCompletionApiResponse> getEmployeePerformanceTaskCompletion({
    required dynamic employeeId,
    required String month,
  });

  /// Fetches individual employee timely submissions details for a given month
  /// GET /api/admin/performance/employees/{id}/timely-submissions?month=YYYY-MM
  Future<PerformanceTaskCompletionApiResponse> getEmployeePerformanceTimelySubmissions({
    required dynamic employeeId,
    required String month,
  });

  /// Fetches individual employee quality of work details for a given month
  /// GET /api/admin/performance/employees/{id}/quality?month=YYYY-MM
  Future<PerformanceQualityApiResponse> getEmployeePerformanceQuality({
    required dynamic employeeId,
    required String month,
  });

  /// Fetches performance message history for an employee
  /// GET /api/admin/performance/employees/{id}/messages?page=1&per_page=50
  Future<PerformanceMessagesApiResponse> getEmployeePerformanceMessages({
    required dynamic employeeId,
    int page = 1,
    int perPage = 50,
  });

  /// Sends a performance message to an employee
  /// POST /api/admin/performance/employees/{id}/messages
  Future<PerformanceMessageItemApiData?> sendEmployeePerformanceMessage({
    required dynamic employeeId,
    required String message,
  });
}
