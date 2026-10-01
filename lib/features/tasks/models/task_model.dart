import '../../../core/constants/app_constants.dart';
import '../../role_permissions/models/role_permission_models.dart';
import '../../projects/models/project_model.dart';
import 'create_task_model.dart';

class SubTask {
  final String id;
  final String title;
  bool isCompleted;
  final DateTime? date;
  final String? taskId;
  final String? assignedTo;
  final AppUser? assignedUser;
  final String? dueDate;

  SubTask({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.date,
    this.taskId,
    this.assignedTo,
    this.assignedUser,
    this.dueDate,
  });

  SubTask copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    DateTime? date,
    String? taskId,
    String? assignedTo,
    AppUser? assignedUser,
    String? dueDate,
  }) {
    return SubTask(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      date: date ?? this.date,
      taskId: taskId ?? this.taskId,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedUser: assignedUser ?? this.assignedUser,
      dueDate: dueDate ?? this.dueDate,
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

class TaskHandoverEvent {
  final String id;
  final AppUser fromUser;
  final AppUser toUser;
  final String type; // 'Handover' (reassign/cannot complete), 'Query' (question/clarification), 'Blocker'
  final String reason;
  final DateTime timestamp;
  final bool isResolved;
  final String? resolutionNote;

  const TaskHandoverEvent({
    required this.id,
    required this.fromUser,
    required this.toUser,
    required this.type,
    required this.reason,
    required this.timestamp,
    this.isResolved = false,
    this.resolutionNote,
  });

  TaskHandoverEvent copyWith({
    String? id,
    AppUser? fromUser,
    AppUser? toUser,
    String? type,
    String? reason,
    DateTime? timestamp,
    bool? isResolved,
    String? resolutionNote,
  }) {
    return TaskHandoverEvent(
      id: id ?? this.id,
      fromUser: fromUser ?? this.fromUser,
      toUser: toUser ?? this.toUser,
      type: type ?? this.type,
      reason: reason ?? this.reason,
      timestamp: timestamp ?? this.timestamp,
      isResolved: isResolved ?? this.isResolved,
      resolutionNote: resolutionNote ?? this.resolutionNote,
    );
  }
}

class TaskTimeLog {
  final String id;
  final AppUser user;
  final DateTime startTime;
  final DateTime? endTime;
  final int durationSeconds;
  final String note;
  final String module;
  final String subModule;
  final String taskTitle;

  const TaskTimeLog({
    required this.id,
    required this.user,
    required this.startTime,
    this.endTime,
    required this.durationSeconds,
    this.note = '',
    this.module = 'General',
    this.subModule = 'Default',
    this.taskTitle = '',
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
  final List<TaskAttachmentData> attachmentDetails;

  // Jira Module & Sub-Module tagging
  final String module;
  final String subModule;

  // Task Handover & Query Escalation
  final List<TaskHandoverEvent> handovers;
  final bool hasActiveQuery;
  final String? activeQueryNote;
  final AppUser? queryToUser;

  // Time Tracking Attributes
  final int totalTrackedSeconds;
  final bool isTimerRunning;
  final DateTime? timerStartedAt;
  final List<TaskTimeLog> timeLogs;

  // Live API attributes
  final String? startDate;
  final String? dueDate;
  final String? estimatedHours;
  final String? category;
  final int? createdBy;
  final String? formattedLoggedTime;
  final AppUser? creator;

  const TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.assignees,
    this.project,
    required this.priority,
    required this.deadline,
    this.status = statusToDo,
    this.subTasks = const [],
    this.comments = const [],
    this.statusUpdates = const [],
    this.attachments = const [],
    this.attachmentDetails = const [],
    this.module = 'General',
    this.subModule = 'Default',
    this.handovers = const [],
    this.hasActiveQuery = false,
    this.activeQueryNote,
    this.queryToUser,
    this.totalTrackedSeconds = 0,
    this.isTimerRunning = false,
    this.timerStartedAt,
    this.timeLogs = const [],
    this.startDate,
    this.dueDate,
    this.estimatedHours,
    this.category,
    this.createdBy,
    this.formattedLoggedTime,
    this.creator,
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

  static String _formatAvatar(String? raw) {
    if (raw == null || raw.isEmpty) {
      return 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150';
    }
    if (raw.contains('127.0.0.1:8000')) {
      return raw.replaceAll('http://127.0.0.1:8000', AppConstants.baseUrl);
    }
    if (raw.contains('localhost:8000')) {
      return raw.replaceAll('http://localhost:8000', AppConstants.baseUrl);
    }
    if (!raw.startsWith('http')) {
      return '${AppConstants.baseUrl}/storage/$raw';
    }
    return raw;
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    // Project mapping
    Project? projectModel;
    if (json['project'] is Map<String, dynamic>) {
      final p = json['project'] as Map<String, dynamic>;
      projectModel = Project(
        id: p['id']?.toString() ?? '',
        name: p['name']?.toString() ?? '',
        description: p['description']?.toString() ?? '',
        category: p['category']?.toString() ?? '',
        status: p['status']?.toString() ?? 'In Progress',
        startDate: DateTime.tryParse(p['start_date']?.toString() ?? '') ?? DateTime.now(),
        endDate: DateTime.tryParse(p['end_date']?.toString() ?? '') ?? DateTime.now(),
        teamMembers: const [],
        tasks: const [],
        timeline: const [],
        files: const [],
        progress: (num.tryParse(p['progress']?.toString() ?? '') ?? 0).toDouble(),
      );
    }

    // Assignees mapping
    final assigneesList = <AppUser>[];
    if (json['assignees'] is List) {
      for (final a in json['assignees']) {
        if (a is Map<String, dynamic>) {
          assigneesList.add(AppUser(
            name: a['name']?.toString() ?? '',
            email: a['email']?.toString() ?? '',
            avatarUrl: _formatAvatar(a['avatar']?.toString()),
            designation: a['designation']?.toString() ?? a['role']?.toString(),
            employeeId: a['id']?.toString(),
            status: a['status']?.toString(),
          ));
        }
      }
    }

    // Creator mapping
    AppUser? taskCreator;
    if (json['creator'] is Map<String, dynamic>) {
      final c = json['creator'] as Map<String, dynamic>;
      taskCreator = AppUser(
        name: c['name']?.toString() ?? '',
        email: c['email']?.toString() ?? '',
        avatarUrl: _formatAvatar(c['avatar']?.toString()),
        designation: c['role']?.toString() ?? 'admin',
        employeeId: c['id']?.toString(),
      );
    }

    // Subtasks mapping
    final subTasksList = <SubTask>[];
    if (json['subtasks'] is List) {
      for (final st in json['subtasks']) {
        if (st is Map<String, dynamic>) {
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
          subTasksList.add(SubTask(
            id: st['id']?.toString() ?? '',
            taskId: st['task_id']?.toString(),
            title: st['task_name']?.toString() ?? st['title']?.toString() ?? '',
            assignedTo: st['assigned_to']?.toString(),
            assignedUser: assignedUser,
            isCompleted: st['is_completed'] == true || st['is_completed'] == 1 || st['status'] == 'completed',
            dueDate: st['due_date']?.toString(),
            date: DateTime.tryParse(st['due_date']?.toString() ?? ''),
          ));
        }
      }
    }

    // Comments mapping
    final commentsList = <TaskComment>[];
    if (json['comments'] is List) {
      for (final c in json['comments']) {
        if (c is Map<String, dynamic>) {
          AppUser commentUser = const AppUser(name: 'User', email: '', avatarUrl: '');
          if (c['user'] is Map<String, dynamic>) {
            final u = c['user'] as Map<String, dynamic>;
            commentUser = AppUser(
              name: u['name']?.toString() ?? '',
              email: u['email']?.toString() ?? '',
              avatarUrl: _formatAvatar(u['avatar']?.toString()),
              designation: u['designation']?.toString() ?? u['role']?.toString(),
            );
          }
          commentsList.add(TaskComment(
            id: c['id']?.toString() ?? '',
            user: commentUser,
            text: c['text']?.toString() ?? c['comment']?.toString() ?? '',
            timestamp: DateTime.tryParse(c['created_at']?.toString() ?? '') ?? DateTime.now(),
            userRole: commentUser.designation ?? 'Team Member',
          ));
        }
      }
    }

    // Time Logs mapping
    final timeLogsList = <TaskTimeLog>[];
    if (json['time_logs'] is List) {
      for (final tl in json['time_logs']) {
        if (tl is Map<String, dynamic>) {
          AppUser logUser = const AppUser(name: 'Employee', email: '', avatarUrl: '');
          if (tl['user'] is Map<String, dynamic>) {
            final u = tl['user'] as Map<String, dynamic>;
            logUser = AppUser(
              name: u['name']?.toString() ?? '',
              email: u['email']?.toString() ?? '',
              avatarUrl: _formatAvatar(u['avatar']?.toString()),
              designation: u['designation']?.toString() ?? u['role']?.toString(),
            );
          }
          timeLogsList.add(TaskTimeLog(
            id: tl['id']?.toString() ?? '',
            user: logUser,
            startTime: DateTime.tryParse(tl['start_time']?.toString() ?? '') ?? DateTime.now(),
            endTime: DateTime.tryParse(tl['end_time']?.toString() ?? ''),
            durationSeconds: int.tryParse(tl['duration_seconds']?.toString() ?? '') ?? 0,
            note: tl['note']?.toString() ?? '',
            taskTitle: json['task_name']?.toString() ?? '',
          ));
        }
      }
    }

    // Attachments mapping
    final attachmentDataList = <TaskAttachmentData>[];
    final attachmentNames = <String>[];
    if (json['attachments'] is List) {
      for (final att in json['attachments']) {
        if (att is Map<String, dynamic>) {
          final item = TaskAttachmentData.fromJson(att);
          attachmentDataList.add(item);
          attachmentNames.add(item.fileName);
        } else if (att is String) {
          attachmentNames.add(att);
        }
      }
    }

    // Deadline parsing
    DateTime deadlineDate = DateTime.now().add(const Duration(days: 7));
    if (json['due_date'] != null && json['due_date'].toString().isNotEmpty) {
      final parsed = DateTime.tryParse(json['due_date'].toString());
      if (parsed != null) deadlineDate = parsed;
    } else if (json['deadline'] != null && json['deadline'].toString().isNotEmpty) {
      final parsed = DateTime.tryParse(json['deadline'].toString());
      if (parsed != null) deadlineDate = parsed;
    }

    // Total seconds
    final int loggedSeconds = int.tryParse(json['total_logged_seconds']?.toString() ?? '') ??
        int.tryParse(json['current_logged_seconds']?.toString() ?? '') ??
        0;

    // Timer running
    final bool timerRunning = json['is_timer_running'] == true ||
        json['is_timer_running'] == 1 ||
        json['is_timer_running'] == 'true';

    DateTime? timerStarted;
    if (json['timer_started_at'] != null) {
      timerStarted = DateTime.tryParse(json['timer_started_at'].toString());
    }

    final cat = json['category']?.toString() ?? 'UI/UX Design';
    final taskStatus = json['status']?.toString() ?? statusToDo;

    // Default status update history item
    final statusUpdatesList = [
      TaskStatusUpdate(
        id: 'init_${json['id']}',
        status: taskStatus,
        title: 'Task Created',
        description: 'Task allocated under [$cat].',
        timestamp: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
        user: taskCreator ??
            const AppUser(
              name: 'Administrator',
              email: 'admin@empmanagement.com',
              avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
            ),
      ),
    ];

    return TaskModel(
      id: json['id']?.toString() ?? '',
      title: json['task_name']?.toString() ?? json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      assignees: assigneesList,
      project: projectModel,
      priority: json['priority']?.toString() ?? 'Medium',
      deadline: deadlineDate,
      status: taskStatus,
      subTasks: subTasksList,
      comments: commentsList,
      statusUpdates: statusUpdatesList,
      attachments: attachmentNames,
      attachmentDetails: attachmentDataList,
      module: cat,
      subModule: 'Default',
      totalTrackedSeconds: loggedSeconds,
      isTimerRunning: timerRunning,
      timerStartedAt: timerStarted,
      timeLogs: timeLogsList,
      startDate: json['start_date']?.toString(),
      dueDate: json['due_date']?.toString(),
      estimatedHours: json['estimated_hours']?.toString(),
      category: cat,
      createdBy: int.tryParse(json['created_by']?.toString() ?? ''),
      formattedLoggedTime: json['formatted_logged_time']?.toString(),
      creator: taskCreator,
    );
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
    List<TaskAttachmentData>? attachmentDetails,
    String? module,
    String? subModule,
    List<TaskHandoverEvent>? handovers,
    bool? hasActiveQuery,
    String? activeQueryNote,
    AppUser? queryToUser,
    int? totalTrackedSeconds,
    bool? isTimerRunning,
    DateTime? timerStartedAt,
    List<TaskTimeLog>? timeLogs,
    String? startDate,
    String? dueDate,
    String? estimatedHours,
    String? category,
    int? createdBy,
    String? formattedLoggedTime,
    AppUser? creator,
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
      attachmentDetails: attachmentDetails ?? this.attachmentDetails,
      module: module ?? this.module,
      subModule: subModule ?? this.subModule,
      handovers: handovers ?? this.handovers,
      hasActiveQuery: hasActiveQuery ?? this.hasActiveQuery,
      activeQueryNote: activeQueryNote ?? this.activeQueryNote,
      queryToUser: queryToUser ?? this.queryToUser,
      totalTrackedSeconds: totalTrackedSeconds ?? this.totalTrackedSeconds,
      isTimerRunning: isTimerRunning ?? this.isTimerRunning,
      timerStartedAt: timerStartedAt ?? this.timerStartedAt,
      timeLogs: timeLogs ?? this.timeLogs,
      startDate: startDate ?? this.startDate,
      dueDate: dueDate ?? this.dueDate,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      category: category ?? this.category,
      createdBy: createdBy ?? this.createdBy,
      formattedLoggedTime: formattedLoggedTime ?? this.formattedLoggedTime,
      creator: creator ?? this.creator,
    );
  }
}

class TasksListResponseModel {
  final bool status;
  final String message;
  final List<TaskModel> tasks;
  final int total;
  final int currentPage;
  final int lastPage;

  TasksListResponseModel({
    required this.status,
    required this.message,
    required this.tasks,
    this.total = 0,
    this.currentPage = 1,
    this.lastPage = 1,
  });

  factory TasksListResponseModel.fromJson(Map<String, dynamic> json) {
    List<TaskModel> taskList = [];
    int totalCount = 0;
    int currPage = 1;
    int lPage = 1;

    if (json['data'] is Map<String, dynamic>) {
      final dataMap = json['data'] as Map<String, dynamic>;
      totalCount = int.tryParse(dataMap['total']?.toString() ?? '0') ?? 0;
      currPage = int.tryParse(dataMap['current_page']?.toString() ?? '1') ?? 1;
      lPage = int.tryParse(dataMap['last_page']?.toString() ?? '1') ?? 1;

      if (dataMap['data'] is List) {
        taskList = (dataMap['data'] as List)
            .whereType<Map<String, dynamic>>()
            .map((item) => TaskModel.fromJson(item))
            .toList();
      }
    } else if (json['data'] is List) {
      taskList = (json['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map((item) => TaskModel.fromJson(item))
          .toList();
      totalCount = taskList.length;
    }

    return TasksListResponseModel(
      status: json['status'] == true || json['status'] == 'true',
      message: json['message']?.toString() ?? '',
      tasks: taskList,
      total: totalCount > 0 ? totalCount : taskList.length,
      currentPage: currPage,
      lastPage: lPage,
    );
  }
}

class TaskDetailResponseModel {
  final bool status;
  final String message;
  final TaskModel? data;

  TaskDetailResponseModel({
    required this.status,
    required this.message,
    this.data,
  });

  factory TaskDetailResponseModel.fromJson(Map<String, dynamic> json, {String? fallbackMessage}) {
    TaskModel? task;
    if (json['data'] is Map<String, dynamic>) {
      task = TaskModel.fromJson(json['data'] as Map<String, dynamic>);
    }
    return TaskDetailResponseModel(
      status: json['status'] == true || json['status'] == 'true',
      message: parseApiErrorMessage(json, fallbackMessage),
      data: task,
    );
  }
}


