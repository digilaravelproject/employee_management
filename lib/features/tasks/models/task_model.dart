import '../../role_permissions/models/role_permission_models.dart';
import '../../projects/models/project_model.dart';

class SubTask {
  final String id;
  final String title;
  bool isCompleted;
  final DateTime? date;

  SubTask({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.date,
  });

  SubTask copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    DateTime? date,
  }) {
    return SubTask(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      date: date ?? this.date,
    );
  }
}

class TaskComment {
  final String id;
  final AppUser user;
  final String text;
  final DateTime timestamp;
  final String userRole; // e.g. Manager, UI/UX Designer

  const TaskComment({
    required this.id,
    required this.user,
    required this.text,
    required this.timestamp,
    this.userRole = 'Employee',
  });
}

class TaskStatusUpdate {
  final String id;
  final String status; // Pending, In Progress, Review, Completed
  final String title;
  final String description;
  final DateTime timestamp;
  final AppUser user;

  const TaskStatusUpdate({
    required this.id,
    required this.status,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.user,
  });
}

class TaskModel {
  final String id;
  final String title;
  final String description;
  final List<AppUser> assignees;
  final Project? project;
  final String priority; // Low, Medium, High
  final DateTime deadline;
  final String status; // Pending, In Progress, Review, Completed
  final List<SubTask> subTasks;
  final List<TaskComment> comments;
  final List<TaskStatusUpdate> statusUpdates;
  final List<String> attachments; // Mock file names

  const TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.assignees,
    this.project,
    required this.priority,
    required this.deadline,
    this.status = 'Pending',
    required this.subTasks,
    required this.comments,
    required this.statusUpdates,
    required this.attachments,
  });

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    List<AppUser>? assignees,
    Project? project,
    String? priority,
    DateTime? deadline,
    String? status,
    List<SubTask>? subTasks,
    List<TaskComment>? comments,
    List<TaskStatusUpdate>? statusUpdates,
    List<String>? attachments,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      assignees: assignees ?? this.assignees,
      project: project ?? this.project,
      priority: priority ?? this.priority,
      deadline: deadline ?? this.deadline,
      status: status ?? this.status,
      subTasks: subTasks ?? this.subTasks,
      comments: comments ?? this.comments,
      statusUpdates: statusUpdates ?? this.statusUpdates,
      attachments: attachments ?? this.attachments,
    );
  }
}
