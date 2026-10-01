import '../../employee/management/models/employee_model.dart';
import '../models/create_task_model.dart';
import '../models/task_model.dart';

abstract class TaskRepositoryInterface {
  Future<CreateTaskResponseModel> createTask(CreateTaskRequestModel request);
  Future<EmployeeListResponseModel> getEmployees();
  Future<TasksListResponseModel> getAdminTasks({
    String status = 'all',
    String priority = 'all',
    int perPage = 20,
    int page = 1,
  });
  Future<TaskDetailResponseModel> getAdminTaskDetails(dynamic taskId);
  Future<TaskDetailResponseModel> updateAdminTask(dynamic taskId, UpdateTaskRequestModel request);
  Future<DeleteTaskResponseModel> deleteAdminTask(dynamic taskId);
  Future<SubTaskResponseModel> addSubTask(dynamic taskId, AddSubTaskRequestModel request);
}


