import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/controllers/app_controller.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/utils/logger.dart';
import '../../employee/management/models/employee_model.dart';
import '../models/create_project_model.dart';
import 'project_repository_interface.dart';

class ProjectRepository implements ProjectRepositoryInterface {
  final ApiClient apiClient;

  ProjectRepository({required this.apiClient});

  @override
  Future<CreateProjectResponseModel> createProject(CreateProjectRequestModel request) async {
    try {
      final formData = await request.toFormData();
      Logger.d('ProjectRepository => POST ${AppConstants.adminProjectsUrl}');

      final response = await apiClient.post(
        AppConstants.adminProjectsUrl,
        data: formData,
        handleError: false,
        showToaster: false,
      );

      Logger.d('ProjectRepository => Status: ${response.statusCode}, isSuccess: ${response.isSuccess}');

      if (response.json != null) {
        return CreateProjectResponseModel.fromJson(response.json!);
      } else if (response.body is Map<String, dynamic>) {
        return CreateProjectResponseModel.fromJson(response.body as Map<String, dynamic>);
      }

      return CreateProjectResponseModel(
        status: response.isSuccess,
        message: response.message.isNotEmpty
            ? response.message
            : (response.isSuccess ? 'Project created successfully.' : 'Failed to create project.'),
      );
    } catch (e, stack) {
      Logger.e('ProjectRepository => Error creating project: $e');
      Logger.e('ProjectRepository => StackTrace: $stack');
      return CreateProjectResponseModel(
        status: false,
        message: 'Something went wrong while creating project: $e',
      );
    }
  }

  @override
  Future<EmployeeListResponseModel> getEmployees() async {
    try {
      Logger.d('ProjectRepository => GET ${AppConstants.adminEmployeesUrl}');
      final response = await apiClient.get(
        AppConstants.adminEmployeesUrl,
        handleError: false,
        showToaster: false,
      );

      if (response.json != null) {
        return EmployeeListResponseModel.fromJson(response.json!);
      } else if (response.body is Map<String, dynamic>) {
        return EmployeeListResponseModel.fromJson(response.body as Map<String, dynamic>);
      }

      return EmployeeListResponseModel(
        status: false,
        message: response.message.isNotEmpty ? response.message : 'Failed to load employees',
        data: [],
      );
    } catch (e, stack) {
      Logger.e('ProjectRepository => Error fetching employees: $e');
      Logger.e('ProjectRepository => StackTrace: $stack');
      return EmployeeListResponseModel(
        status: false,
        message: e.toString(),
        data: [],
      );
    }
  }

  @override
  Future<ProjectListResponseModel> getProjects({
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

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status.toLowerCase() == 'all' ? 'all' : status;
      } else {
        queryParams['status'] = 'all';
      }

      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }

      Logger.d('ProjectRepository => GET ${AppConstants.adminProjectsUrl} with query: $queryParams');

      final response = await apiClient.get(
        AppConstants.adminProjectsUrl,
        queryParameters: queryParams,
        handleError: false,
        showToaster: false,
      );

      Logger.d('ProjectRepository => Status: ${response.statusCode}, isSuccess: ${response.isSuccess}');

      if (response.json != null) {
        return ProjectListResponseModel.fromJson(response.json!);
      } else if (response.body is Map<String, dynamic>) {
        return ProjectListResponseModel.fromJson(response.body as Map<String, dynamic>);
      }

      return ProjectListResponseModel(
        status: response.isSuccess,
        message: response.message.isNotEmpty
            ? response.message
            : (response.isSuccess ? 'Projects retrieved successfully.' : 'Failed to retrieve projects.'),
        total: 0,
        data: [],
      );
    } catch (e, stack) {
      Logger.e('ProjectRepository => Error fetching projects: $e');
      Logger.e('ProjectRepository => StackTrace: $stack');
      return ProjectListResponseModel(
        status: false,
        message: 'Something went wrong while fetching projects: $e',
        total: 0,
        data: [],
      );
    }
  }

  @override
  Future<ProjectListResponseModel> searchProjects({
    required String query,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'query': query.trim(),
        'page': page,
        'per_page': perPage,
      };

      Logger.d('ProjectRepository => GET ${AppConstants.adminSearchProjectsUrl} with query: $queryParams');

      final response = await apiClient.get(
        AppConstants.adminSearchProjectsUrl,
        queryParameters: queryParams,
        handleError: false,
        showToaster: false,
      );

      Logger.d('ProjectRepository => Search status: ${response.statusCode}, isSuccess: ${response.isSuccess}');

      if (response.json != null) {
        return ProjectListResponseModel.fromJson(response.json!);
      } else if (response.body is Map<String, dynamic>) {
        return ProjectListResponseModel.fromJson(response.body as Map<String, dynamic>);
      }

      return ProjectListResponseModel(
        status: response.isSuccess,
        message: response.message.isNotEmpty
            ? response.message
            : (response.isSuccess ? 'Project search results retrieved successfully.' : 'Failed to search projects.'),
        total: 0,
        data: [],
      );
    } catch (e, stack) {
      Logger.e('ProjectRepository => Error searching projects: $e');
      Logger.e('ProjectRepository => StackTrace: $stack');
      return ProjectListResponseModel(
        status: false,
        message: 'Something went wrong while searching projects: $e',
        total: 0,
        data: [],
      );
    }
  }

  @override
  Future<ProjectDetailsResponseModel> getProjectDetails(dynamic id) async {
    try {
      final appController = Get.isRegistered<AppController>() ? Get.find<AppController>() : null;
      final isEmployee = appController?.userRole.value.toLowerCase() == 'employee';
      final endpoint = isEmployee
          ? AppConstants.assignedProjectDetailsUrl(id)
          : AppConstants.adminProjectDetailsUrl(id);

      Logger.d('ProjectRepository => GET $endpoint (isEmployee: $isEmployee)');

      final response = await apiClient.get(
        endpoint,
        handleError: false,
        showToaster: false,
      );

      Logger.d('ProjectRepository => Details Status: ${response.statusCode}, isSuccess: ${response.isSuccess}');

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
      Logger.e('ProjectRepository => Error fetching project details: $e');
      Logger.e('ProjectRepository => StackTrace: $stack');
      return ProjectDetailsResponseModel(
        status: false,
        message: 'Something went wrong while fetching project details: $e',
      );
    }
  }

  @override
  Future<ProjectDetailsResponseModel> updateProject(dynamic id, UpdateProjectRequestModel request) async {
    try {
      final endpoint = AppConstants.adminProjectDetailsUrl(id);
      Logger.d('ProjectRepository => PATCH $endpoint, body: ${request.toJson()}');

      final response = await apiClient.patch(
        endpoint,
        data: request.toJson(),
        handleError: false,
        showToaster: false,
      );

      Logger.d('ProjectRepository => Update Status: ${response.statusCode}, isSuccess: ${response.isSuccess}');

      if (response.json != null) {
        return ProjectDetailsResponseModel.fromJson(response.json!);
      } else if (response.body is Map<String, dynamic>) {
        return ProjectDetailsResponseModel.fromJson(response.body as Map<String, dynamic>);
      }

      return ProjectDetailsResponseModel(
        status: response.isSuccess,
        message: response.message.isNotEmpty
            ? response.message
            : (response.isSuccess ? 'Project updated successfully.' : 'Failed to update project.'),
      );
    } catch (e, stack) {
      Logger.e('ProjectRepository => Error updating project: $e');
      Logger.e('ProjectRepository => StackTrace: $stack');
      return ProjectDetailsResponseModel(
        status: false,
        message: 'Something went wrong while updating project: $e',
      );
    }
  }

  @override
  Future<DeleteProjectResponseModel> deleteProject(dynamic id) async {
    try {
      final endpoint = AppConstants.adminProjectDetailsUrl(id);
      Logger.d('ProjectRepository => DELETE $endpoint');

      final response = await apiClient.delete(
        endpoint,
        handleError: false,
        showToaster: false,
      );

      Logger.d('ProjectRepository => Delete Status: ${response.statusCode}, isSuccess: ${response.isSuccess}');

      if (response.json != null) {
        return DeleteProjectResponseModel.fromJson(response.json!);
      } else if (response.body is Map<String, dynamic>) {
        return DeleteProjectResponseModel.fromJson(response.body as Map<String, dynamic>);
      }

      return DeleteProjectResponseModel(
        status: response.isSuccess,
        message: response.message.isNotEmpty
            ? response.message
            : (response.isSuccess ? 'Project deleted successfully.' : 'Failed to delete project.'),
      );
    } catch (e, stack) {
      Logger.e('ProjectRepository => Error deleting project: $e');
      Logger.e('ProjectRepository => StackTrace: $stack');
      return DeleteProjectResponseModel(
        status: false,
        message: 'Something went wrong while deleting project: $e',
      );
    }
  }

  @override
  Future<RemoveProjectEmployeeResponseModel> removeEmployeeFromProject({
    required dynamic projectId,
    required dynamic employeeId,
  }) async {
    try {
      final endpoint = AppConstants.adminProjectEmployeeUrl(projectId, employeeId);
      Logger.d('ProjectRepository => DELETE $endpoint');

      final response = await apiClient.delete(
        endpoint,
        handleError: false,
        showToaster: false,
      );

      Logger.d('ProjectRepository => removeEmployee Status: ${response.statusCode}, isSuccess: ${response.isSuccess}');

      if (response.json != null) {
        return RemoveProjectEmployeeResponseModel.fromJson(response.json!);
      } else if (response.body is Map<String, dynamic>) {
        return RemoveProjectEmployeeResponseModel.fromJson(response.body as Map<String, dynamic>);
      }

      return RemoveProjectEmployeeResponseModel(
        status: response.isSuccess,
        message: response.message.isNotEmpty
            ? response.message
            : (response.isSuccess ? 'Employee removed from project successfully.' : 'Failed to remove employee from project.'),
      );
    } catch (e, stack) {
      Logger.e('ProjectRepository => Error removing employee from project: $e');
      Logger.e('ProjectRepository => StackTrace: $stack');
      return RemoveProjectEmployeeResponseModel(
        status: false,
        message: 'Something went wrong while removing employee: $e',
      );
    }
  }
}
