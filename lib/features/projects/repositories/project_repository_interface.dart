import '../../employee/management/models/employee_model.dart';
import '../models/create_project_model.dart';

abstract class ProjectRepositoryInterface {
  Future<CreateProjectResponseModel> createProject(CreateProjectRequestModel request);
  Future<EmployeeListResponseModel> getEmployees();
  Future<ProjectListResponseModel> getProjects({
    String? status,
    int page = 1,
    int perPage = 20,
    String? search,
  });
  Future<ProjectListResponseModel> searchProjects({
    required String query,
    int page = 1,
    int perPage = 20,
  });
  Future<ProjectDetailsResponseModel> getProjectDetails(dynamic id);
  Future<ProjectDetailsResponseModel> updateProject(dynamic id, UpdateProjectRequestModel request);
  Future<DeleteProjectResponseModel> deleteProject(dynamic id);
  Future<RemoveProjectEmployeeResponseModel> removeEmployeeFromProject({
    required dynamic projectId,
    required dynamic employeeId,
  });
}
