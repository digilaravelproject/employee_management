import 'dart:io';
import 'package:dio/dio.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/utils/logger.dart';
import '../../employee/management/models/employee_model.dart';
import '../models/create_task_model.dart';
import '../models/task_model.dart';
import 'task_repository_interface.dart';

class TaskRepository implements TaskRepositoryInterface {
  final ApiClient apiClient;

  TaskRepository({required this.apiClient});

  @override
  Future<CreateTaskResponseModel> createTask(CreateTaskRequestModel request) async {
    try {
      final formData = await request.toFormData();
      Logger.d('TaskRepository => POST ${AppConstants.adminTasksUrl}');

      final response = await apiClient.post(
        AppConstants.adminTasksUrl,
        data: formData,
        handleError: false,
        showToaster: false,
      );

      Logger.d('TaskRepository => Status: ${response.statusCode}, isSuccess: ${response.isSuccess}');

      if (response.json != null) {
        return CreateTaskResponseModel.fromJson(response.json!, fallbackMessage: response.message);
      } else if (response.body is Map<String, dynamic>) {
        return CreateTaskResponseModel.fromJson(response.body as Map<String, dynamic>, fallbackMessage: response.message);
      }

      return CreateTaskResponseModel(
        status: response.isSuccess,
        message: response.message.isNotEmpty
            ? response.message
            : (response.isSuccess ? 'Task created successfully.' : 'Failed to create task.'),
      );
    } catch (e, stack) {
      Logger.e('TaskRepository => Error creating task: $e');
      Logger.e('TaskRepository => StackTrace: $stack');
      return CreateTaskResponseModel(
        status: false,
        message: 'Something went wrong while creating task: $e',
      );
    }
  }

  @override
  Future<EmployeeListResponseModel> getEmployees() async {
    try {
      Logger.d('TaskRepository => GET ${AppConstants.adminEmployeesUrl}');
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
      Logger.e('TaskRepository => Error fetching employees: $e');
      Logger.e('TaskRepository => StackTrace: $stack');
      return EmployeeListResponseModel(
        status: false,
        message: e.toString(),
        data: [],
      );
    }
  }

  @override
  Future<TasksListResponseModel> getAdminTasks({
    String status = 'all',
    String priority = 'all',
    int perPage = 20,
    int page = 1,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'status': status,
        'priority': priority,
        'per_page': perPage,
        'page': page,
      };
      Logger.d('TaskRepository => GET ${AppConstants.adminTasksUrl} with params: $queryParams');
      final response = await apiClient.get(
        AppConstants.adminTasksUrl,
        queryParameters: queryParams,
        handleError: false,
        showToaster: false,
      );

      if (response.json != null) {
        return TasksListResponseModel.fromJson(response.json!);
      } else if (response.body is Map<String, dynamic>) {
        return TasksListResponseModel.fromJson(response.body as Map<String, dynamic>);
      }

      return TasksListResponseModel(
        status: false,
        message: response.message.isNotEmpty ? response.message : 'Failed to load tasks',
        tasks: [],
      );
    } catch (e, stack) {
      Logger.e('TaskRepository => Error fetching tasks: $e');
      Logger.e('TaskRepository => StackTrace: $stack');
      return TasksListResponseModel(
        status: false,
        message: e.toString(),
        tasks: [],
      );
    }
  }

  @override
  Future<TaskDetailResponseModel> getAdminTaskDetails(dynamic taskId) async {
    try {
      final url = AppConstants.adminTaskDetailUrl(taskId);
      Logger.d('TaskRepository => GET $url');
      final response = await apiClient.get(
        url,
        handleError: false,
        showToaster: false,
      );

      if (response.json != null) {
        return TaskDetailResponseModel.fromJson(response.json!, fallbackMessage: response.message);
      } else if (response.body is Map<String, dynamic>) {
        return TaskDetailResponseModel.fromJson(response.body as Map<String, dynamic>, fallbackMessage: response.message);
      }

      return TaskDetailResponseModel(
        status: false,
        message: response.message.isNotEmpty ? response.message : 'Failed to load task details',
      );
    } catch (e, stack) {
      Logger.e('TaskRepository => Error fetching task details: $e');
      Logger.e('TaskRepository => StackTrace: $stack');
      return TaskDetailResponseModel(
        status: false,
        message: e.toString(),
      );
    }
  }

  @override
  Future<TaskDetailResponseModel> updateAdminTask(dynamic taskId, UpdateTaskRequestModel request) async {
    try {
      final url = AppConstants.adminTaskDetailUrl(taskId);
      final jsonBody = request.toJson();
      Logger.d('TaskRepository => PUT $url with body: $jsonBody');

      final response = await apiClient.put(
        url,
        data: jsonBody,
        handleError: false,
        showToaster: false,
      );

      Logger.d('TaskRepository => Status: ${response.statusCode}, isSuccess: ${response.isSuccess}');

      if (response.json != null) {
        return TaskDetailResponseModel.fromJson(response.json!, fallbackMessage: response.message);
      } else if (response.body is Map<String, dynamic>) {
        return TaskDetailResponseModel.fromJson(response.body as Map<String, dynamic>, fallbackMessage: response.message);
      }

      return TaskDetailResponseModel(
        status: response.isSuccess,
        message: response.message.isNotEmpty
            ? response.message
            : (response.isSuccess ? 'Task updated successfully' : 'Failed to update task'),
      );
    } catch (e, stack) {
      Logger.e('TaskRepository => Error updating task: $e');
      Logger.e('TaskRepository => StackTrace: $stack');
      return TaskDetailResponseModel(
        status: false,
        message: 'Something went wrong while updating task: $e',
      );
    }
  }

  @override
  Future<DeleteTaskResponseModel> deleteAdminTask(dynamic taskId) async {
    try {
      final url = AppConstants.adminTaskDetailUrl(taskId);
      Logger.d('TaskRepository => DELETE $url');

      final response = await apiClient.delete(
        url,
        handleError: false,
        showToaster: false,
      );

      Logger.d('TaskRepository => Status: ${response.statusCode}, isSuccess: ${response.isSuccess}');

      if (response.json != null) {
        return DeleteTaskResponseModel.fromJson(response.json!, fallbackMessage: response.message);
      } else if (response.body is Map<String, dynamic>) {
        return DeleteTaskResponseModel.fromJson(response.body as Map<String, dynamic>, fallbackMessage: response.message);
      }

      return DeleteTaskResponseModel(
        status: response.isSuccess,
        message: response.message.isNotEmpty
            ? response.message
            : (response.isSuccess ? 'Task deleted successfully.' : 'Failed to delete task.'),
      );
    } catch (e, stack) {
      Logger.e('TaskRepository => Error deleting task: $e');
      Logger.e('TaskRepository => StackTrace: $stack');
      return DeleteTaskResponseModel(
        status: false,
        message: 'Something went wrong while deleting task: $e',
      );
    }
  }

  @override
  Future<SubTaskResponseModel> addSubTask(dynamic taskId, AddSubTaskRequestModel request) async {
    try {
      final url = AppConstants.adminTaskSubtasksUrl(taskId);
      final jsonBody = request.toJson();
      Logger.d('TaskRepository => POST $url with body: $jsonBody');

      final response = await apiClient.post(
        url,
        data: jsonBody,
        handleError: false,
        showToaster: false,
      );

      Logger.d('TaskRepository => Status: ${response.statusCode}, isSuccess: ${response.isSuccess}');

      if (response.json != null) {
        return SubTaskResponseModel.fromJson(response.json!, fallbackMessage: response.message);
      } else if (response.body is Map<String, dynamic>) {
        return SubTaskResponseModel.fromJson(response.body as Map<String, dynamic>, fallbackMessage: response.message);
      }

      return SubTaskResponseModel(
        status: response.isSuccess,
        message: response.message.isNotEmpty
            ? response.message
            : (response.isSuccess ? 'Subtask added successfully' : 'Failed to add subtask'),
      );
    } catch (e, stack) {
      Logger.e('TaskRepository => Error adding subtask: $e');
      Logger.e('TaskRepository => StackTrace: $stack');
      return SubTaskResponseModel(
        status: false,
        message: 'Something went wrong while adding subtask: $e',
      );
    }
  }

  @override
  Future<TaskDetailResponseModel> startAdminTask(dynamic taskId, {String? note}) async {
    try {
      final url = AppConstants.adminTaskStartUrl(taskId);
      final body = <String, dynamic>{
        'note': (note != null && note.trim().isNotEmpty) ? note.trim() : 'Starting work on task',
      };
      Logger.d('TaskRepository => POST $url with body: $body');

      final response = await apiClient.post(
        url,
        data: body,
        handleError: false,
        showToaster: false,
      );

      Logger.d('TaskRepository => Status: ${response.statusCode}, isSuccess: ${response.isSuccess}');

      if (response.json != null) {
        return TaskDetailResponseModel.fromJson(response.json!, fallbackMessage: response.message);
      } else if (response.body is Map<String, dynamic>) {
        return TaskDetailResponseModel.fromJson(response.body as Map<String, dynamic>, fallbackMessage: response.message);
      }

      return TaskDetailResponseModel(
        status: response.isSuccess,
        message: response.message.isNotEmpty
            ? response.message
            : (response.isSuccess ? 'Task timer started successfully' : 'Failed to start timer'),
      );
    } catch (e, stack) {
      Logger.e('TaskRepository => Error starting task timer: $e');
      Logger.e('TaskRepository => StackTrace: $stack');
      return TaskDetailResponseModel(
        status: false,
        message: 'Something went wrong while starting timer: $e',
      );
    }
  }

  @override
  Future<TaskDetailResponseModel> pauseAdminTask(dynamic taskId, {String? note}) async {
    try {
      final url = AppConstants.adminTaskPauseUrl(taskId);
      final body = <String, dynamic>{
        'note': (note != null && note.trim().isNotEmpty) ? note.trim() : 'Paused work on task',
      };
      Logger.d('TaskRepository => POST $url with body: $body');

      final response = await apiClient.post(
        url,
        data: body,
        handleError: false,
        showToaster: false,
      );

      Logger.d('TaskRepository => Status: ${response.statusCode}, isSuccess: ${response.isSuccess}');

      if (response.json != null) {
        return TaskDetailResponseModel.fromJson(response.json!, fallbackMessage: response.message);
      } else if (response.body is Map<String, dynamic>) {
        return TaskDetailResponseModel.fromJson(response.body as Map<String, dynamic>, fallbackMessage: response.message);
      }

      return TaskDetailResponseModel(
        status: response.isSuccess,
        message: response.message.isNotEmpty
            ? response.message
            : (response.isSuccess ? 'Task timer paused successfully' : 'Failed to pause timer'),
      );
    } catch (e, stack) {
      Logger.e('TaskRepository => Error pausing task timer: $e');
      Logger.e('TaskRepository => StackTrace: $stack');
      return TaskDetailResponseModel(
        status: false,
        message: 'Something went wrong while pausing timer: $e',
      );
    }
  }

  @override
  Future<TaskDetailResponseModel> stopAdminTask(dynamic taskId, {String? note}) async {
    try {
      final url = AppConstants.adminTaskStopUrl(taskId);
      final body = <String, dynamic>{
        'note': (note != null && note.trim().isNotEmpty) ? note.trim() : 'Stopped work on task',
      };
      Logger.d('TaskRepository => POST $url with body: $body');

      final response = await apiClient.post(
        url,
        data: body,
        handleError: false,
        showToaster: false,
      );

      Logger.d('TaskRepository => Status: ${response.statusCode}, isSuccess: ${response.isSuccess}');

      if (response.json != null) {
        return TaskDetailResponseModel.fromJson(response.json!, fallbackMessage: response.message);
      } else if (response.body is Map<String, dynamic>) {
        return TaskDetailResponseModel.fromJson(response.body as Map<String, dynamic>, fallbackMessage: response.message);
      }

      return TaskDetailResponseModel(
        status: response.isSuccess,
        message: response.message.isNotEmpty
            ? response.message
            : (response.isSuccess ? 'Task timer stopped successfully' : 'Failed to stop timer'),
      );
    } catch (e, stack) {
      Logger.e('TaskRepository => Error stopping task timer: $e');
      Logger.e('TaskRepository => StackTrace: $stack');
      return TaskDetailResponseModel(
        status: false,
        message: 'Something went wrong while stopping timer: $e',
      );
    }
  }

  @override
  Future<TaskCommentResponseModel> addTaskComment({
    required dynamic taskId,
    required String comment,
    String? userId,
    String? filePath,
  }) async {
    try {
      final url = AppConstants.adminTaskCommentsUrl(taskId);
      Logger.d('TaskRepository => POST $url (multipart comment)');

      final Map<String, dynamic> formMap = {
        'comment': comment.trim(),
      };
      if (userId != null && userId.trim().isNotEmpty) {
        formMap['user_id'] = userId.trim();
      }

      if (filePath != null && filePath.trim().isNotEmpty) {
        final file = File(filePath);
        if (await file.exists()) {
          final fileName = filePath.split(RegExp(r'[\\/]')).last;
          formMap['file'] = await MultipartFile.fromFile(filePath, filename: fileName);
        }
      }

      final formData = FormData.fromMap(formMap);

      final response = await apiClient.post(
        url,
        data: formData,
        handleError: false,
        showToaster: false,
      );

      Logger.d('TaskRepository => Comment POST Status: ${response.statusCode}, isSuccess: ${response.isSuccess}');

      if (response.json != null) {
        return TaskCommentResponseModel.fromJson(response.json!, fallbackMessage: response.message);
      } else if (response.body is Map<String, dynamic>) {
        return TaskCommentResponseModel.fromJson(response.body as Map<String, dynamic>, fallbackMessage: response.message);
      }

      return TaskCommentResponseModel(
        status: response.isSuccess,
        message: response.message.isNotEmpty
            ? response.message
            : (response.isSuccess ? 'Comment added successfully' : 'Failed to add comment'),
      );
    } catch (e, stack) {
      Logger.e('TaskRepository => Error adding comment: $e');
      Logger.e('TaskRepository => StackTrace: $stack');
      return TaskCommentResponseModel(
        status: false,
        message: 'Something went wrong while adding comment: $e',
      );
    }
  }

  @override
  Future<TaskDetailResponseModel> submitTaskForTesting(
    dynamic taskId, {
    String? remarks,
    String? filePath,
  }) async {
    try {
      final url = AppConstants.adminTaskSubmitForTestingUrl(taskId);
      Logger.d('TaskRepository => POST $url (submit for testing)');

      final Map<String, dynamic> formMap = {};
      if (remarks != null && remarks.trim().isNotEmpty) {
        formMap['remarks'] = remarks.trim();
      }

      if (filePath != null && filePath.trim().isNotEmpty) {
        final file = File(filePath);
        if (await file.exists()) {
          final fileName = filePath.split(RegExp(r'[\\/]')).last;
          formMap['file'] = await MultipartFile.fromFile(filePath, filename: fileName);
        }
      }

      final formData = FormData.fromMap(formMap);

      final response = await apiClient.post(
        url,
        data: formData,
        handleError: false,
        showToaster: false,
      );

      Logger.d('TaskRepository => SubmitForTesting POST Status: ${response.statusCode}, isSuccess: ${response.isSuccess}');

      if (response.json != null) {
        return TaskDetailResponseModel.fromJson(response.json!, fallbackMessage: response.message);
      } else if (response.body is Map<String, dynamic>) {
        return TaskDetailResponseModel.fromJson(response.body as Map<String, dynamic>, fallbackMessage: response.message);
      }

      return TaskDetailResponseModel(
        status: response.isSuccess,
        message: response.message.isNotEmpty
            ? response.message
            : (response.isSuccess ? 'Task submitted for testing successfully' : 'Failed to submit task for testing'),
      );
    } catch (e, stack) {
      Logger.e('TaskRepository => Error submitting task for testing: $e');
      Logger.e('TaskRepository => StackTrace: $stack');
      return TaskDetailResponseModel(
        status: false,
        message: 'Something went wrong while submitting task for testing: $e',
      );
    }
  }

  @override
  Future<TaskCommentsListResponseModel> getTaskComments(dynamic taskId) async {
    try {
      final url = AppConstants.adminTaskCommentsUrl(taskId);
      Logger.d('TaskRepository => GET $url (get task comments)');

      final response = await apiClient.get(
        url,
        handleError: false,
        showToaster: false,
      );

      Logger.d('TaskRepository => Comments GET Status: ${response.statusCode}, isSuccess: ${response.isSuccess}');

      if (response.json != null) {
        return TaskCommentsListResponseModel.fromJson(response.json!, fallbackMessage: response.message);
      } else if (response.body is Map<String, dynamic>) {
        return TaskCommentsListResponseModel.fromJson(response.body as Map<String, dynamic>, fallbackMessage: response.message);
      }

      return TaskCommentsListResponseModel(
        status: response.isSuccess,
        message: response.message.isNotEmpty
            ? response.message
            : (response.isSuccess ? 'Comments retrieved successfully' : 'Failed to retrieve comments'),
        data: const [],
      );
    } catch (e, stack) {
      Logger.e('TaskRepository => Error getting task comments: $e');
      Logger.e('TaskRepository => StackTrace: $stack');
      return TaskCommentsListResponseModel(
        status: false,
        message: 'Something went wrong while retrieving comments: $e',
        data: const [],
      );
    }
  }
}



