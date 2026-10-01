import 'package:dio/dio.dart';
import '../../../core/constants/app_constants.dart';
import '../../projects/models/project_model.dart';
import '../../role_permissions/models/role_permission_models.dart';
import 'task_model.dart';

class CreateTaskRequestModel {
  final String taskName;
  final String description;
  final String category;
  final String priority;
  final String status;
  final String startDate; // yyyy-MM-dd
  final String dueDate;   // yyyy-MM-dd
  final String estimatedHours; // e.g. "05h 30m"
  final String projectId;
  final String? userId;
  final List<String> employeeIds;
  final List<String> filePaths;

  CreateTaskRequestModel({
    required this.taskName,
    required this.description,
    required this.category,
    required this.priority,
    required this.status,
    required this.startDate,
    required this.dueDate,
    required this.estimatedHours,
    required this.projectId,
    this.userId,
    required this.employeeIds,
    this.filePaths = const [],
  });

  Future<FormData> toFormData() async {
    final formData = FormData();

    formData.fields.add(MapEntry('task_name', taskName));
    formData.fields.add(MapEntry('description', description));
    formData.fields.add(MapEntry('category', category));
    formData.fields.add(MapEntry('priority', priority));
    formData.fields.add(MapEntry('status', mapTaskStatusToApi(status)));
    formData.fields.add(MapEntry('start_date', startDate));
    formData.fields.add(MapEntry('due_date', dueDate));
    formData.fields.add(MapEntry('estimated_hours', estimatedHours));
    formData.fields.add(MapEntry('project_id', projectId));

    if (userId != null && userId!.trim().isNotEmpty) {
      formData.fields.add(MapEntry('user_id', userId!.trim()));
    }

    for (final empId in employeeIds) {
      if (empId.trim().isNotEmpty) {
        formData.fields.add(MapEntry('employee_ids[]', empId.trim()));
      }
    }

    for (int i = 0; i < filePaths.length; i++) {
      final path = filePaths[i];
      if (path.isNotEmpty) {
        final fileName = path.split('/').last;
        formData.files.add(
          MapEntry(
            'files[]',
            await MultipartFile.fromFile(path, filename: fileName),
          ),
        );
      }
    }

    return formData;
  }
}

class CreateTaskResponseModel {
  final bool status;
  final String message;
  final TaskApiData? data;

  CreateTaskResponseModel({
    required this.status,
    required this.message,
    this.data,
  });

  factory CreateTaskResponseModel.fromJson(Map<String, dynamic> json, {String? fallbackMessage}) {
    return CreateTaskResponseModel(
      status: json['status'] == true ||
          json['status'] == 1 ||
          json['status']?.toString().toLowerCase() == 'true',
      message: parseApiErrorMessage(json, fallbackMessage),
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? TaskApiData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class TaskApiData {
  final int id;
  final String taskName;
  final String description;
  final String category;
  final String priority;
  final String status;
  final String startDate;
  final String dueDate;
  final String estimatedHours;
  final int? createdBy;
  final String? createdAt;
  final String? updatedAt;
  final String? formattedLoggedTime;
  final int currentLoggedSeconds;
  final TaskProjectData? project;
  final TaskCreatorData? creator;
  final List<TaskAssigneeData> assignees;
  final List<TaskAttachmentData> attachments;

  TaskApiData({
    required this.id,
    required this.taskName,
    required this.description,
    required this.category,
    required this.priority,
    required this.status,
    required this.startDate,
    required this.dueDate,
    required this.estimatedHours,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.formattedLoggedTime,
    this.currentLoggedSeconds = 0,
    this.project,
    this.creator,
    this.assignees = const [],
    this.attachments = const [],
  });

  factory TaskApiData.fromJson(Map<String, dynamic> json) {
    return TaskApiData(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      taskName: json['task_name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      priority: json['priority']?.toString() ?? 'Medium',
      status: json['status']?.toString() ?? 'Pending',
      startDate: json['start_date']?.toString() ?? '',
      dueDate: json['due_date']?.toString() ?? '',
      estimatedHours: json['estimated_hours']?.toString() ?? '',
      createdBy: int.tryParse(json['created_by']?.toString() ?? ''),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      formattedLoggedTime: json['formatted_logged_time']?.toString(),
      currentLoggedSeconds: int.tryParse(json['current_logged_seconds']?.toString() ?? '') ?? 0,
      project: json['project'] != null && json['project'] is Map<String, dynamic>
          ? TaskProjectData.fromJson(json['project'] as Map<String, dynamic>)
          : null,
      creator: json['creator'] != null && json['creator'] is Map<String, dynamic>
          ? TaskCreatorData.fromJson(json['creator'] as Map<String, dynamic>)
          : null,
      assignees: json['assignees'] is List
          ? (json['assignees'] as List)
              .whereType<Map<String, dynamic>>()
              .map((e) => TaskAssigneeData.fromJson(e))
              .toList()
          : [],
      attachments: json['attachments'] is List
          ? (json['attachments'] as List)
              .whereType<Map<String, dynamic>>()
              .map((e) => TaskAttachmentData.fromJson(e))
              .toList()
          : [],
    );
  }

  TaskModel toTaskModel() {
    DateTime deadlineDate = DateTime.tryParse(dueDate) ?? DateTime.now().add(const Duration(days: 7));

    Project? projectModel;
    if (project != null) {
      projectModel = Project(
        id: project!.id.toString(),
        name: project!.name,
        description: project!.description,
        category: project!.category,
        status: project!.status,
        startDate: DateTime.tryParse(project!.startDate) ?? DateTime.now(),
        endDate: DateTime.tryParse(project!.endDate) ?? DateTime.now(),
        teamMembers: assignees.map((a) => a.toAppUser()).toList(),
        tasks: [],
        timeline: [],
        files: [],
        modules: [],
        progress: project!.progress.toDouble(),
      );
    }

    return TaskModel(
      id: id.toString(),
      title: taskName,
      description: description,
      assignees: assignees.map((a) => a.toAppUser()).toList(),
      project: projectModel,
      priority: priority,
      deadline: deadlineDate,
      status: status,
      subTasks: [],
      comments: [],
      statusUpdates: [
        TaskStatusUpdate(
          id: 'init_$id',
          status: status,
          title: 'Task Created',
          description: 'Task allocated under [$category].',
          timestamp: DateTime.tryParse(createdAt ?? '') ?? DateTime.now(),
          user: creator?.toAppUser() ??
              const AppUser(
                name: 'Admin',
                email: 'admin@empmanagement.com',
                avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
              ),
        ),
      ],
      attachments: attachments.map((a) => a.fileName).toList(),
      module: category,
      subModule: 'Default',
    );
  }
}

class TaskProjectData {
  final int id;
  final String name;
  final String description;
  final String category;
  final String startDate;
  final String endDate;
  final String status;
  final num progress;
  final int? createdBy;
  final String? createdAt;
  final String? updatedAt;

  TaskProjectData({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.progress,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  factory TaskProjectData.fromJson(Map<String, dynamic> json) {
    return TaskProjectData(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Not Started',
      progress: num.tryParse(json['progress']?.toString() ?? '') ?? 0,
      createdBy: int.tryParse(json['created_by']?.toString() ?? ''),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }
}

class TaskCreatorData {
  final int id;
  final String name;
  final String email;
  final String? avatar;
  final String role;

  TaskCreatorData({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    this.role = 'admin',
  });

  factory TaskCreatorData.fromJson(Map<String, dynamic> json) {
    return TaskCreatorData(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      avatar: json['avatar']?.toString(),
      role: json['role']?.toString() ?? 'admin',
    );
  }

  AppUser toAppUser() {
    return AppUser(
      name: name,
      email: email,
      avatarUrl: avatar != null && avatar!.isNotEmpty
          ? (avatar!.startsWith('http') ? avatar! : '${AppConstants.baseUrl}/storage/$avatar')
          : 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
    );
  }
}

class TaskAssigneeData {
  final int id;
  final String name;
  final String email;
  final String? avatar;
  final String role;
  final String designation;

  TaskAssigneeData({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    this.role = 'employee',
    this.designation = '',
  });

  factory TaskAssigneeData.fromJson(Map<String, dynamic> json) {
    return TaskAssigneeData(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      avatar: json['avatar']?.toString(),
      role: json['role']?.toString() ?? 'employee',
      designation: json['designation']?.toString() ?? '',
    );
  }

  AppUser toAppUser() {
    return AppUser(
      name: name,
      email: email,
      employeeId: id.toString(),
      designation: designation,
      avatarUrl: avatar != null && avatar!.isNotEmpty
          ? (avatar!.startsWith('http') ? avatar! : '${AppConstants.baseUrl}/storage/$avatar')
          : 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
    );
  }
}

class TaskAttachmentData {
  final int id;
  final int taskId;
  final String filePath;
  final String fileName;
  final int fileSize;
  final String fileType;
  final int? uploadedBy;
  final String? createdAt;
  final String? fileUrl;

  TaskAttachmentData({
    required this.id,
    required this.taskId,
    required this.filePath,
    required this.fileName,
    required this.fileSize,
    required this.fileType,
    this.uploadedBy,
    this.createdAt,
    this.fileUrl,
  });

  factory TaskAttachmentData.fromJson(Map<String, dynamic> json) {
    return TaskAttachmentData(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      taskId: int.tryParse(json['task_id']?.toString() ?? '') ?? 0,
      filePath: json['file_path']?.toString() ?? '',
      fileName: json['file_name']?.toString() ?? '',
      fileSize: int.tryParse(json['file_size']?.toString() ?? '') ?? 0,
      fileType: json['file_type']?.toString() ?? '',
      uploadedBy: int.tryParse(json['uploaded_by']?.toString() ?? ''),
      createdAt: json['created_at']?.toString(),
      fileUrl: json['file_url']?.toString(),
    );
  }
}

class UpdateTaskRequestModel {
  final String? taskName;
  final String? description;
  final String? category;
  final String? priority;
  final String? status;
  final String? startDate;
  final String? dueDate;
  final String? estimatedHours;
  final dynamic projectId;
  final List<dynamic>? employeeIds;

  UpdateTaskRequestModel({
    this.taskName,
    this.description,
    this.category,
    this.priority,
    this.status,
    this.startDate,
    this.dueDate,
    this.estimatedHours,
    this.projectId,
    this.employeeIds,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (taskName != null && taskName!.trim().isNotEmpty) {
      data['task_name'] = taskName!.trim();
    }
    if (description != null && description!.trim().isNotEmpty) {
      data['description'] = description!.trim();
    }
    if (category != null && category!.trim().isNotEmpty) {
      data['category'] = category!.trim();
    }
    if (priority != null && priority!.trim().isNotEmpty) {
      data['priority'] = priority!.trim();
    }
    if (status != null && status!.trim().isNotEmpty) {
      data['status'] = mapTaskStatusToApi(status!);
    }
    if (startDate != null && startDate!.trim().isNotEmpty) {
      data['start_date'] = startDate!.trim();
    }
    if (dueDate != null && dueDate!.trim().isNotEmpty) {
      data['due_date'] = dueDate!.trim();
    }
    if (estimatedHours != null && estimatedHours!.trim().isNotEmpty) {
      data['estimated_hours'] = estimatedHours!.trim();
    }
    if (projectId != null) {
      final pInt = int.tryParse(projectId.toString());
      data['project_id'] = pInt ?? projectId;
    }
    if (employeeIds != null) {
      data['employee_ids'] = employeeIds!.map((id) {
        return int.tryParse(id.toString()) ?? id;
      }).toList();
    }
    return data;
  }
}

class DeleteTaskResponseModel {
  final bool status;
  final String message;

  DeleteTaskResponseModel({
    required this.status,
    required this.message,
  });

  factory DeleteTaskResponseModel.fromJson(Map<String, dynamic> json, {String? fallbackMessage}) {
    return DeleteTaskResponseModel(
      status: json['status'] == true ||
          json['status'] == 1 ||
          json['status']?.toString().toLowerCase() == 'true',
      message: parseApiErrorMessage(json, fallbackMessage),
    );
  }
}

/// Helper to extract clean error message from API response map,
/// specifically checking nested `errors` map (e.g. `{status: [The selected status is invalid.]}`)
String parseApiErrorMessage(Map<String, dynamic>? json, [String? fallback]) {
  if (json == null) return fallback ?? 'Something went wrong';

  if (json['errors'] != null) {
    final errors = json['errors'];
    if (errors is Map) {
      final List<String> list = [];
      errors.forEach((key, val) {
        if (val is List && val.isNotEmpty) {
          list.addAll(val.map((v) => v.toString()));
        } else if (val is String && val.trim().isNotEmpty) {
          list.add(val.trim());
        }
      });
      if (list.isNotEmpty) {
        return list.join('\n');
      }
    } else if (errors is List && errors.isNotEmpty) {
      return errors.map((e) => e.toString()).join('\n');
    } else if (errors is String && errors.trim().isNotEmpty) {
      return errors.trim();
    }
  }

  if (json['message'] != null && json['message'].toString().trim().isNotEmpty) {
    return json['message'].toString().trim();
  }

  if (json['msg'] != null && json['msg'].toString().trim().isNotEmpty) {
    return json['msg'].toString().trim();
  }

  if (json['error'] != null && json['error'].toString().trim().isNotEmpty) {
    return json['error'].toString().trim();
  }

  return fallback ?? 'Something went wrong';
}

/// Helper to ensure task status matches backend expectations:
/// 'Pending', 'In Progress', 'Testing', 'Completed'
String mapTaskStatusToApi(String status) {
  final lower = status.toLowerCase().trim();
  if (lower == 'to do' || lower == 'todo' || lower == 'pending') {
    return 'Pending';
  } else if (lower == 'in progress' || lower == 'inprogress') {
    return 'In Progress';
  } else if (lower == 'testing' || lower == 'review') {
    return 'Testing';
  } else if (lower == 'completed' || lower == 'done') {
    return 'Completed';
  }
  return status;
}

class AddSubTaskRequestModel {
  final String title;
  final dynamic assignedTo;
  final String? dueDate;

  AddSubTaskRequestModel({
    required this.title,
    this.assignedTo,
    this.dueDate,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'title': title.trim(),
    };
    if (assignedTo != null) {
      final aInt = int.tryParse(assignedTo.toString());
      data['assigned_to'] = aInt ?? assignedTo;
    }
    if (dueDate != null && dueDate!.trim().isNotEmpty) {
      data['due_date'] = dueDate!.trim();
    }
    return data;
  }
}

class SubTaskResponseModel {
  final bool status;
  final String message;
  final SubTask? data;

  SubTaskResponseModel({
    required this.status,
    required this.message,
    this.data,
  });

  factory SubTaskResponseModel.fromJson(Map<String, dynamic> json, {String? fallbackMessage}) {
    SubTask? subTask;
    if (json['data'] is Map<String, dynamic>) {
      final st = json['data'] as Map<String, dynamic>;
      AppUser? assignedUser;
      if (st['assigned_user'] is Map<String, dynamic>) {
        final u = st['assigned_user'] as Map<String, dynamic>;
        assignedUser = AppUser(
          name: u['name']?.toString() ?? '',
          email: u['email']?.toString() ?? '',
          employeeId: u['id']?.toString(),
          avatarUrl: u['avatar'] != null && u['avatar'].toString().isNotEmpty
              ? (u['avatar'].toString().startsWith('http')
                  ? u['avatar'].toString()
                  : '${AppConstants.baseUrl}/storage/${u['avatar']}')
              : '',
        );
      }

      subTask = SubTask(
        id: st['id']?.toString() ?? '',
        taskId: st['task_id']?.toString(),
        title: st['title']?.toString() ?? st['task_name']?.toString() ?? '',
        assignedTo: st['assigned_to']?.toString(),
        assignedUser: assignedUser,
        isCompleted: st['is_completed'] == true || st['is_completed'] == 1 || st['status'] == 'completed',
        dueDate: st['due_date']?.toString(),
        date: DateTime.tryParse(st['due_date']?.toString() ?? ''),
      );
    }

    return SubTaskResponseModel(
      status: json['status'] == true || json['status'] == 'true',
      message: parseApiErrorMessage(json, fallbackMessage),
      data: subTask,
    );
  }
}


