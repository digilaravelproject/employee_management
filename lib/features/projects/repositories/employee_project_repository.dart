import '../../../core/constants/app_constants.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/utils/logger.dart';
import '../models/create_project_model.dart';
import '../models/employee_assigned_project_model.dart';
import 'employee_project_repository_interface.dart';

class EmployeeProjectRepository implements EmployeeProjectRepositoryInterface {
  final ApiClient apiClient;

  EmployeeProjectRepository({required this.apiClient});

  @override
  Future<EmployeeAssignedProjectResponseModel> getAssignedProjects({
    String? status,
    int page = 1,
    int perPage = 20,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
      };

      if (status != null && status.trim().isNotEmpty) {
        queryParams['status'] = status.trim();
      }

      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }

      Logger.d('EmployeeProjectRepository => GET ${AppConstants.assignedProjectsUrl} params: $queryParams');

      final response = await apiClient.get(
        AppConstants.assignedProjectsUrl,
        queryParameters: queryParams,
        handleError: false,
        showToaster: false,
      );

      Logger.d('EmployeeProjectRepository => Status: ${response.statusCode}, isSuccess: ${response.isSuccess}');

      if (response.json != null) {
        return EmployeeAssignedProjectResponseModel.fromJson(response.json!);
      } else if (response.body is Map<String, dynamic>) {
        return EmployeeAssignedProjectResponseModel.fromJson(response.body as Map<String, dynamic>);
      }

      return EmployeeAssignedProjectResponseModel(
        status: false,
        message: response.message.isNotEmpty ? response.message : 'Failed to retrieve assigned projects',
        total: 0,
        data: [],
      );
    } catch (e, stack) {
      Logger.e('EmployeeProjectRepository => Error fetching assigned projects: $e');
      Logger.e('EmployeeProjectRepository => StackTrace: $stack');
      return EmployeeAssignedProjectResponseModel(
        status: false,
        message: e.toString(),
        total: 0,
        data: [],
      );
    }
  }

  @override
  Future<ProjectDetailsResponseModel> getAssignedProjectDetails(dynamic id) async {
    try {
      final endpoint = AppConstants.assignedProjectDetailsUrl(id);
      Logger.d('EmployeeProjectRepository => GET $endpoint');

      final response = await apiClient.get(
        endpoint,
        handleError: false,
        showToaster: false,
      );

      Logger.d('EmployeeProjectRepository => Details Status: ${response.statusCode}, isSuccess: ${response.isSuccess}');

      if (response.json != null) {
        return ProjectDetailsResponseModel.fromJson(response.json!);
      } else if (response.body is Map<String, dynamic>) {
        return ProjectDetailsResponseModel.fromJson(response.body as Map<String, dynamic>);
      }

      return ProjectDetailsResponseModel(
        status: response.isSuccess,
        message: response.message.isNotEmpty
            ? response.message
            : (response.isSuccess ? 'Project details retrieved successfully.' : 'Failed to retrieve project details.'),
      );
    } catch (e, stack) {
      Logger.e('EmployeeProjectRepository => Error fetching assigned project details: $e');
      Logger.e('EmployeeProjectRepository => StackTrace: $stack');
      return ProjectDetailsResponseModel(
        status: false,
        message: 'Something went wrong while fetching assigned project details: $e',
      );
    }
  }
}
