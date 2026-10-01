import '../models/create_project_model.dart';
import '../models/employee_assigned_project_model.dart';

abstract class EmployeeProjectRepositoryInterface {
  Future<EmployeeAssignedProjectResponseModel> getAssignedProjects({
    String? status,
    int page = 1,
    int perPage = 20,
    String? search,
  });

  Future<ProjectDetailsResponseModel> getAssignedProjectDetails(dynamic id);
}
