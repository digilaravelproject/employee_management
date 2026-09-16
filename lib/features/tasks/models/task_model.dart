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
  final String status; // To Do, In Progress, Testing, Completed
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

class TaskTimeLog {
  final String id;
  final AppUser user;
  final DateTime startTime;
  final DateTime? endTime;
  final int durationSeconds;
  final String note;

  const TaskTimeLog({
    required this.id,
    required this.user,
    required this.startTime,
    this.endTime,
    required this.durationSeconds,
    this.note = '',
  });

  String get formattedDuration {
    final hours = durationSeconds ~/ 3600;
    final minutes = (durationSeconds % 3600) ~/ 60;
    final seconds = durationSeconds % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}

class TaskModel {
  static const String statusToDo = 'To Do';
  static const String statusInProgress = 'In Progress';
  static const String statusTesting = 'Testing';
  static const String statusCompleted = 'Completed';

  final String id;
  final String title;
  final String description;
  final List<AppUser> assignees;
  final Project? project;
  final String priority; // Low, Medium, High
  final DateTime deadline;
  final String status; // To Do, In Progress, Testing, Completed
  final List<SubTask> subTasks;
  final List<TaskComment> comments;
  final List<TaskStatusUpdate> statusUpdates;
  final List<String> attachments; // Mock file names

  // Time Tracking Attributes
  final int totalTrackedSeconds;
  final bool isTimerRunning;
  final DateTime? timerStartedAt;
  final List<TaskTimeLog> timeLogs;

  const TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.assignees,
    this.project,
    required this.priority,
    required this.deadline,
    this.status = statusToDo,
    required this.subTasks,
    required this.comments,
    required this.statusUpdates,
    required this.attachments,
    this.totalTrackedSeconds = 0,
    this.isTimerRunning = false,
    this.timerStartedAt,
    this.timeLogs = const [],
  });

  String get normalizedStatus {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'to do':
      case 'todo':
        return statusToDo;
      case 'in progress':
      case 'inprogress':
        return statusInProgress;
      case 'review':
      case 'testing':
        return statusTesting;
      case 'completed':
      case 'done':
        return statusCompleted;
      default:
        return status;
    }
  }

  int get activeTotalSeconds {
    if (isTimerRunning && timerStartedAt != null) {
      final elapsed = DateTime.now().difference(timerStartedAt!).inSeconds;
      return totalTrackedSeconds + (elapsed > 0 ? elapsed : 0);
    }
    return totalTrackedSeconds;
  }

  String get formattedActiveTime {
    final secs = activeTotalSeconds;
    final hours = secs ~/ 3600;
    final minutes = (secs % 3600) ~/ 60;
    final seconds = secs % 60;
    final hStr = hours.toString().padLeft(2, '0');
    final mStr = minutes.toString().padLeft(2, '0');
    final sStr = seconds.toString().padLeft(2, '0');
    return '$hStr:$mStr:$sStr';
  }

  String get formattedHumanTime {
    final secs = activeTotalSeconds;
    final hours = secs ~/ 3600;
    final minutes = (secs % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m';
    } else {
      return secs > 0 ? '${secs}s' : '0m';
    }
  }

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
    int? totalTrackedSeconds,
    bool? isTimerRunning,
    DateTime? timerStartedAt,
    List<TaskTimeLog>? timeLogs,
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
      totalTrackedSeconds: totalTrackedSeconds ?? this.totalTrackedSeconds,
      isTimerRunning: isTimerRunning ?? this.isTimerRunning,
      timerStartedAt: timerStartedAt ?? this.timerStartedAt,
      timeLogs: timeLogs ?? this.timeLogs,
    );
  }
}
