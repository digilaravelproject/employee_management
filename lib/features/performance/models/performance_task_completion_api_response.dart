class PerformanceTaskCompletionSummaryApiData {
  final int total;
  final int completed;
  final int inProgress;
  final num completionPercent;
  final int onTime;
  final num? timelinessPercent;

  PerformanceTaskCompletionSummaryApiData({
    this.total = 0,
    this.completed = 0,
    this.inProgress = 0,
    this.completionPercent = 0,
    this.onTime = 0,
    this.timelinessPercent,
  });

  factory PerformanceTaskCompletionSummaryApiData.fromJson(Map<String, dynamic> json) {
    return PerformanceTaskCompletionSummaryApiData(
      total: int.tryParse(json['total']?.toString() ?? '0') ?? 0,
      completed: int.tryParse(json['completed']?.toString() ?? '0') ?? 0,
      inProgress: int.tryParse(json['in_progress']?.toString() ?? '0') ?? 0,
      completionPercent: json['completion_percent'] is num
          ? (json['completion_percent'] as num)
          : (num.tryParse(json['completion_percent']?.toString() ?? '0') ?? 0),
      onTime: int.tryParse(json['on_time']?.toString() ?? '0') ?? 0,
      timelinessPercent: json['timeliness_percent'] is num
          ? (json['timeliness_percent'] as num)
          : (num.tryParse(json['timeliness_percent']?.toString() ?? '')),
    );
  }
}

class PerformanceTaskProjectApiData {
  final dynamic id;
  final String name;

  PerformanceTaskProjectApiData({this.id, this.name = ''});

  factory PerformanceTaskProjectApiData.fromJson(Map<String, dynamic> json) {
    return PerformanceTaskProjectApiData(
      id: json['id'],
      name: json['name']?.toString() ?? '',
    );
  }
}

class PerformanceTaskAssignedByApiData {
  final dynamic id;
  final String name;
  final String designation;

  PerformanceTaskAssignedByApiData({this.id, this.name = '', this.designation = ''});

  factory PerformanceTaskAssignedByApiData.fromJson(Map<String, dynamic> json) {
    return PerformanceTaskAssignedByApiData(
      id: json['id'],
      name: json['name']?.toString() ?? '',
      designation: json['designation']?.toString() ?? '',
    );
  }
}

class PerformanceSubtaskItemApiData {
  final dynamic id;
  final dynamic taskId;
  final String title;
  final bool isCompleted;
  final String? completedAt;

  PerformanceSubtaskItemApiData({
    this.id,
    this.taskId,
    this.title = '',
    this.isCompleted = false,
    this.completedAt,
  });

  factory PerformanceSubtaskItemApiData.fromJson(Map<String, dynamic> json) {
    return PerformanceSubtaskItemApiData(
      id: json['id'],
      taskId: json['task_id'],
      title: json['title']?.toString() ?? '',
      isCompleted: json['is_completed'] == true ||
          json['is_completed'] == 1 ||
          json['is_completed']?.toString().toLowerCase() == 'true',
      completedAt: json['completed_at']?.toString(),
    );
  }
}

class PerformanceSubtasksApiData {
  final int completed;
  final int total;
  final List<PerformanceSubtaskItemApiData> items;

  PerformanceSubtasksApiData({
    this.completed = 0,
    this.total = 0,
    this.items = const [],
  });

  factory PerformanceSubtasksApiData.fromJson(Map<String, dynamic> json) {
    final list = (json['items'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map((e) => PerformanceSubtaskItemApiData.fromJson(e))
            .toList() ??
        [];
    return PerformanceSubtasksApiData(
      completed: int.tryParse(json['completed']?.toString() ?? '0') ?? 0,
      total: int.tryParse(json['total']?.toString() ?? '0') ?? 0,
      items: list,
    );
  }
}

class PerformanceTaskItemApiData {
  final dynamic id;
  final String name;
  final String description;
  final PerformanceTaskProjectApiData? project;
  final String priority;
  final String status;
  final String assignedOn;
  final String startDate;
  final String dueDate;
  final String? completedAt;
  final PerformanceTaskAssignedByApiData? assignedBy;
  final bool? isOnTime;
  final int? daysFromDeadline;
  final PerformanceSubtasksApiData? subtasks;

  PerformanceTaskItemApiData({
    this.id,
    this.name = '',
    this.description = '',
    this.project,
    this.priority = 'Medium',
    this.status = 'Pending',
    this.assignedOn = '',
    this.startDate = '',
    this.dueDate = '',
    this.completedAt,
    this.assignedBy,
    this.isOnTime,
    this.daysFromDeadline,
    this.subtasks,
  });

  factory PerformanceTaskItemApiData.fromJson(Map<String, dynamic> json) {
    return PerformanceTaskItemApiData(
      id: json['id'],
      name: json['name']?.toString() ?? json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      project: json['project'] is Map<String, dynamic>
          ? PerformanceTaskProjectApiData.fromJson(json['project'] as Map<String, dynamic>)
          : null,
      priority: json['priority']?.toString() ?? 'Medium',
      status: json['status']?.toString() ?? 'Pending',
      assignedOn: json['assigned_on']?.toString() ?? json['created_at']?.toString() ?? '',
      startDate: json['start_date']?.toString() ?? '',
      dueDate: json['due_date']?.toString() ?? '',
      completedAt: json['completed_at']?.toString(),
      assignedBy: json['assigned_by'] is Map<String, dynamic>
          ? PerformanceTaskAssignedByApiData.fromJson(json['assigned_by'] as Map<String, dynamic>)
          : null,
      isOnTime: json['is_on_time'] is bool
          ? json['is_on_time'] as bool
          : (json['is_on_time'] != null
              ? json['is_on_time'].toString().toLowerCase() == 'true' || json['is_on_time'] == 1
              : null),
      daysFromDeadline: int.tryParse(json['days_from_deadline']?.toString() ?? ''),
      subtasks: json['subtasks'] is Map<String, dynamic>
          ? PerformanceSubtasksApiData.fromJson(json['subtasks'] as Map<String, dynamic>)
          : null,
    );
  }
}

class PerformanceTaskCompletionApiResponse {
  final bool status;
  final String message;
  final PerformanceTaskCompletionSummaryApiData? summary;
  final List<PerformanceTaskItemApiData> tasks;

  PerformanceTaskCompletionApiResponse({
    required this.status,
    required this.message,
    this.summary,
    this.tasks = const [],
  });

  factory PerformanceTaskCompletionApiResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : {};

    PerformanceTaskCompletionSummaryApiData? summaryData;
    if (data['summary'] is Map<String, dynamic>) {
      summaryData = PerformanceTaskCompletionSummaryApiData.fromJson(
          data['summary'] as Map<String, dynamic>);
    }

    final tasksList = (data['tasks'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map((e) => PerformanceTaskItemApiData.fromJson(e))
            .toList() ??
        [];

    return PerformanceTaskCompletionApiResponse(
      status: json['status'] == true ||
          json['status'] == 1 ||
          json['status']?.toString().toLowerCase() == 'true',
      message: json['message']?.toString() ?? '',
      summary: summaryData,
      tasks: tasksList,
    );
  }
}
