import '../../../core/constants/app_constants.dart';
import 'performance_model.dart';

class EmployeePerformanceResponseModel {
  final bool status;
  final String message;
  final PerformanceSummaryModel? summary;
  final PerformanceFiltersModel? filters;
  final PerformancePaginationModel? pagination;
  final List<EmployeePerformanceItemModel> data;

  EmployeePerformanceResponseModel({
    required this.status,
    required this.message,
    this.summary,
    this.filters,
    this.pagination,
    this.data = const [],
  });

  factory EmployeePerformanceResponseModel.fromJson(Map<String, dynamic> json) {
    List<EmployeePerformanceItemModel> items = [];
    if (json['data'] is List) {
      items = (json['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map((i) => EmployeePerformanceItemModel.fromJson(i))
          .toList();
    }

    return EmployeePerformanceResponseModel(
      status: json['status'] == true ||
          json['status'] == 1 ||
          json['status']?.toString().toLowerCase() == 'true',
      message: json['message']?.toString() ?? '',
      summary: json['summary'] is Map<String, dynamic>
          ? PerformanceSummaryModel.fromJson(json['summary'] as Map<String, dynamic>)
          : null,
      filters: json['filters'] is Map<String, dynamic>
          ? PerformanceFiltersModel.fromJson(json['filters'] as Map<String, dynamic>)
          : null,
      pagination: json['pagination'] is Map<String, dynamic>
          ? PerformancePaginationModel.fromJson(json['pagination'] as Map<String, dynamic>)
          : null,
      data: items,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      if (summary != null) 'summary': summary!.toJson(),
      if (filters != null) 'filters': filters!.toJson(),
      if (pagination != null) 'pagination': pagination!.toJson(),
      'data': data.map((d) => d.toJson()).toList(),
    };
  }
}

class PerformanceFiltersModel {
  final PerformancePeriodModel? period;
  final String view;

  PerformanceFiltersModel({
    this.period,
    this.view = 'team',
  });

  factory PerformanceFiltersModel.fromJson(Map<String, dynamic> json) {
    return PerformanceFiltersModel(
      period: json['period'] is Map<String, dynamic>
          ? PerformancePeriodModel.fromJson(json['period'] as Map<String, dynamic>)
          : null,
      view: json['view']?.toString() ?? 'team',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (period != null) 'period': period!.toJson(),
      'view': view,
    };
  }
}

class PerformancePeriodModel {
  final String from;
  final String to;
  final String month;
  final String label;

  PerformancePeriodModel({
    required this.from,
    required this.to,
    required this.month,
    required this.label,
  });

  factory PerformancePeriodModel.fromJson(Map<String, dynamic> json) {
    return PerformancePeriodModel(
      from: json['from']?.toString() ?? '',
      to: json['to']?.toString() ?? '',
      month: json['month']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'from': from,
      'to': to,
      'month': month,
      'label': label,
    };
  }
}

class PerformancePaginationModel {
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;

  PerformancePaginationModel({
    this.currentPage = 1,
    this.perPage = 20,
    this.total = 0,
    this.lastPage = 1,
  });

  factory PerformancePaginationModel.fromJson(Map<String, dynamic> json) {
    return PerformancePaginationModel(
      currentPage: int.tryParse(json['current_page']?.toString() ?? '1') ?? 1,
      perPage: int.tryParse(json['per_page']?.toString() ?? '20') ?? 20,
      total: int.tryParse(json['total']?.toString() ?? '0') ?? 0,
      lastPage: int.tryParse(json['last_page']?.toString() ?? '1') ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'per_page': perPage,
      'total': total,
      'last_page': lastPage,
    };
  }
}

class PerformanceEmployeeModel {
  final int id;
  final String employeeId;
  final String name;
  final String email;
  final String? avatar;
  final String? designation;
  final String? department;
  final int? departmentId;
  final String? team;

  PerformanceEmployeeModel({
    required this.id,
    required this.employeeId,
    required this.name,
    required this.email,
    this.avatar,
    this.designation,
    this.department,
    this.departmentId,
    this.team,
  });

  factory PerformanceEmployeeModel.fromJson(Map<String, dynamic> json) {
    return PerformanceEmployeeModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      employeeId: json['employee_id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown Employee',
      email: json['email']?.toString() ?? '',
      avatar: json['avatar']?.toString(),
      designation: json['designation']?.toString(),
      department: json['department']?.toString(),
      departmentId: int.tryParse(json['department_id']?.toString() ?? ''),
      team: json['team']?.toString(),
    );
  }

  String get resolvedAvatar {
    if (avatar == null || avatar!.trim().isEmpty) return '';
    var p = avatar!.trim();
    if (p.contains('127.0.0.1:8000') || p.contains('localhost:8000')) {
      p = p
          .replaceFirst('http://127.0.0.1:8000', AppConstants.baseUrl)
          .replaceFirst('http://localhost:8000', AppConstants.baseUrl);
    }
    if (p.startsWith('http://') || p.startsWith('https://')) {
      return p;
    }
    final base = AppConstants.baseUrl.endsWith('/')
        ? AppConstants.baseUrl.substring(0, AppConstants.baseUrl.length - 1)
        : AppConstants.baseUrl;
    if (p.startsWith('/')) {
      return '$base$p';
    } else if (p.startsWith('storage/')) {
      return '$base/$p';
    } else {
      return '$base/storage/$p';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'name': name,
      'email': email,
      if (avatar != null) 'avatar': avatar,
      if (designation != null) 'designation': designation,
      if (department != null) 'department': department,
      if (departmentId != null) 'department_id': departmentId,
      if (team != null) 'team': team,
    };
  }
}

class EmployeePerformanceItemModel {
  final PerformanceEmployeeModel employee;
  final PerformancePeriodModel? period;
  final num? score;
  final String evaluation;
  final PerformanceSourceCountsModel? sourceCounts;
  final PerformanceMetricsModel? metrics;
  final int rank;

  EmployeePerformanceItemModel({
    required this.employee,
    this.period,
    this.score,
    required this.evaluation,
    this.sourceCounts,
    this.metrics,
    required this.rank,
  });

  factory EmployeePerformanceItemModel.fromJson(Map<String, dynamic> json) {
    return EmployeePerformanceItemModel(
      employee: json['employee'] is Map<String, dynamic>
          ? PerformanceEmployeeModel.fromJson(json['employee'] as Map<String, dynamic>)
          : PerformanceEmployeeModel.fromJson(json),
      period: json['period'] is Map<String, dynamic>
          ? PerformancePeriodModel.fromJson(json['period'] as Map<String, dynamic>)
          : null,
      score: json['score'] is num ? (json['score'] as num) : null,
      evaluation: json['evaluation']?.toString() ?? 'Not Rated',
      sourceCounts: json['source_counts'] is Map<String, dynamic>
          ? PerformanceSourceCountsModel.fromJson(json['source_counts'] as Map<String, dynamic>)
          : null,
      metrics: json['metrics'] is Map<String, dynamic>
          ? PerformanceMetricsModel.fromJson(json['metrics'] as Map<String, dynamic>)
          : null,
      rank: int.tryParse(json['rank']?.toString() ?? '1') ?? 1,
    );
  }

  EmployeePerformance toUiModel() {
    return EmployeePerformance(
      id: employee.id.toString(),
      name: employee.name,
      designation: employee.designation != null && employee.designation!.isNotEmpty
          ? employee.designation!
          : (employee.department != null && employee.department!.isNotEmpty
              ? employee.department!
              : 'Employee'),
      department: employee.department ?? 'General',
      performanceScore: score?.round() ?? 0,
      ratingLabel: evaluation,
      imageUrl: employee.resolvedAvatar,
      rank: rank,
      employeeCode: employee.employeeId,
      email: employee.email,
      team: employee.team,
      rawScore: score,
      metricsData: metrics?.toJson(),
      sourceCountsData: sourceCounts?.toJson(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employee': employee.toJson(),
      if (period != null) 'period': period!.toJson(),
      'score': score,
      'evaluation': evaluation,
      if (sourceCounts != null) 'source_counts': sourceCounts!.toJson(),
      if (metrics != null) 'metrics': metrics!.toJson(),
      'rank': rank,
    };
  }
}

class PerformanceSourceCountsModel {
  final int projects;
  final int tasks;
  final int qualityReviews;

  PerformanceSourceCountsModel({
    this.projects = 0,
    this.tasks = 0,
    this.qualityReviews = 0,
  });

  factory PerformanceSourceCountsModel.fromJson(Map<String, dynamic> json) {
    return PerformanceSourceCountsModel(
      projects: int.tryParse(json['projects']?.toString() ?? '0') ?? 0,
      tasks: int.tryParse(json['tasks']?.toString() ?? '0') ?? 0,
      qualityReviews: int.tryParse(json['quality_reviews']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'projects': projects,
      'tasks': tasks,
      'quality_reviews': qualityReviews,
    };
  }
}

class PerformanceMetricsModel {
  final ProjectProgressMetric? projectProgress;
  final TaskCompletionMetric? taskCompletion;
  final TimelySubmissionMetric? timelySubmission;
  final QualityOfWorkMetric? qualityOfWork;

  PerformanceMetricsModel({
    this.projectProgress,
    this.taskCompletion,
    this.timelySubmission,
    this.qualityOfWork,
  });

  factory PerformanceMetricsModel.fromJson(Map<String, dynamic> json) {
    return PerformanceMetricsModel(
      projectProgress: json['project_progress'] is Map<String, dynamic>
          ? ProjectProgressMetric.fromJson(json['project_progress'] as Map<String, dynamic>)
          : null,
      taskCompletion: json['task_completion'] is Map<String, dynamic>
          ? TaskCompletionMetric.fromJson(json['task_completion'] as Map<String, dynamic>)
          : null,
      timelySubmission: json['timely_submission'] is Map<String, dynamic>
          ? TimelySubmissionMetric.fromJson(json['timely_submission'] as Map<String, dynamic>)
          : null,
      qualityOfWork: json['quality_of_work'] is Map<String, dynamic>
          ? QualityOfWorkMetric.fromJson(json['quality_of_work'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (projectProgress != null) 'project_progress': projectProgress!.toJson(),
      if (taskCompletion != null) 'task_completion': taskCompletion!.toJson(),
      if (timelySubmission != null) 'timely_submission': timelySubmission!.toJson(),
      if (qualityOfWork != null) 'quality_of_work': qualityOfWork!.toJson(),
    };
  }
}

class ProjectProgressMetric {
  final num? averagePercent;
  final int totalProjects;

  ProjectProgressMetric({this.averagePercent, this.totalProjects = 0});

  factory ProjectProgressMetric.fromJson(Map<String, dynamic> json) {
    return ProjectProgressMetric(
      averagePercent: json['average_percent'] is num ? (json['average_percent'] as num) : null,
      totalProjects: int.tryParse(json['total_projects']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'average_percent': averagePercent,
      'total_projects': totalProjects,
    };
  }
}

class TaskCompletionMetric {
  final num? percent;
  final int completed;
  final int total;

  TaskCompletionMetric({this.percent, this.completed = 0, this.total = 0});

  factory TaskCompletionMetric.fromJson(Map<String, dynamic> json) {
    return TaskCompletionMetric(
      percent: json['percent'] is num ? (json['percent'] as num) : null,
      completed: int.tryParse(json['completed']?.toString() ?? '0') ?? 0,
      total: int.tryParse(json['total']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'percent': percent,
      'completed': completed,
      'total': total,
    };
  }
}

class TimelySubmissionMetric {
  final num? percent;
  final int onTime;
  final int eligibleCompletedTasks;

  TimelySubmissionMetric({this.percent, this.onTime = 0, this.eligibleCompletedTasks = 0});

  factory TimelySubmissionMetric.fromJson(Map<String, dynamic> json) {
    return TimelySubmissionMetric(
      percent: json['percent'] is num ? (json['percent'] as num) : null,
      onTime: int.tryParse(json['on_time']?.toString() ?? '0') ?? 0,
      eligibleCompletedTasks: int.tryParse(json['eligible_completed_tasks']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'percent': percent,
      'on_time': onTime,
      'eligible_completed_tasks': eligibleCompletedTasks,
    };
  }
}

class QualityOfWorkMetric {
  final num? overallPercent;
  final int reviewCount;
  final Map<String, dynamic>? criteria;

  QualityOfWorkMetric({this.overallPercent, this.reviewCount = 0, this.criteria});

  factory QualityOfWorkMetric.fromJson(Map<String, dynamic> json) {
    return QualityOfWorkMetric(
      overallPercent: json['overall_percent'] is num ? (json['overall_percent'] as num) : null,
      reviewCount: int.tryParse(json['review_count']?.toString() ?? '0') ?? 0,
      criteria: json['criteria'] is Map<String, dynamic> ? json['criteria'] as Map<String, dynamic> : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'overall_percent': overallPercent,
      'review_count': reviewCount,
      if (criteria != null) 'criteria': criteria,
    };
  }
}

class EmployeePerformanceDetailResponseModel {
  final bool status;
  final String message;
  final EmployeePerformanceDetailDataModel? data;

  EmployeePerformanceDetailResponseModel({
    required this.status,
    required this.message,
    this.data,
  });

  factory EmployeePerformanceDetailResponseModel.fromJson(Map<String, dynamic> json) {
    EmployeePerformanceDetailDataModel? detailData;
    if (json['data'] is Map<String, dynamic>) {
      detailData = EmployeePerformanceDetailDataModel.fromJson(json['data'] as Map<String, dynamic>);
    } else if (json['employee'] is Map<String, dynamic> || json['score'] != null || json['metrics'] != null) {
      detailData = EmployeePerformanceDetailDataModel.fromJson(json);
    }

    return EmployeePerformanceDetailResponseModel(
      status: json['status'] == true ||
          json['status'] == 1 ||
          json['status']?.toString().toLowerCase() == 'true',
      message: json['message']?.toString() ?? '',
      data: detailData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      if (data != null) 'data': data!.toJson(),
    };
  }
}

class EmployeePerformanceDetailDataModel {
  final PerformanceEmployeeModel employee;
  final PerformancePeriodModel? period;
  final num? score;
  final String evaluation;
  final PerformanceSourceCountsModel? sourceCounts;
  final PerformanceMetricsModel? metrics;
  final int rank;
  final List<PerformanceTaskDetailModel> tasks;
  final List<PerformanceLeaveDetailModel> leaves;
  final PerformanceQualityFeedbackModel? qualityFeedback;
  final Map<String, dynamic>? rawJson;

  EmployeePerformanceDetailDataModel({
    required this.employee,
    this.period,
    this.score,
    required this.evaluation,
    this.sourceCounts,
    this.metrics,
    this.rank = 1,
    this.tasks = const [],
    this.leaves = const [],
    this.qualityFeedback,
    this.rawJson,
  });

  factory EmployeePerformanceDetailDataModel.fromJson(Map<String, dynamic> json) {
    List<PerformanceTaskDetailModel> tasksList = [];
    if (json['tasks'] is List) {
      tasksList = (json['tasks'] as List)
          .whereType<Map<String, dynamic>>()
          .map((t) => PerformanceTaskDetailModel.fromJson(t))
          .toList();
    }

    List<PerformanceLeaveDetailModel> leavesList = [];
    if (json['leaves'] is List) {
      leavesList = (json['leaves'] as List)
          .whereType<Map<String, dynamic>>()
          .map((l) => PerformanceLeaveDetailModel.fromJson(l))
          .toList();
    }

    return EmployeePerformanceDetailDataModel(
      employee: json['employee'] is Map<String, dynamic>
          ? PerformanceEmployeeModel.fromJson(json['employee'] as Map<String, dynamic>)
          : PerformanceEmployeeModel.fromJson(json),
      period: json['period'] is Map<String, dynamic>
          ? PerformancePeriodModel.fromJson(json['period'] as Map<String, dynamic>)
          : null,
      score: json['score'] is num ? (json['score'] as num) : null,
      evaluation: json['evaluation']?.toString() ?? 'Not Rated',
      sourceCounts: json['source_counts'] is Map<String, dynamic>
          ? PerformanceSourceCountsModel.fromJson(json['source_counts'] as Map<String, dynamic>)
          : null,
      metrics: json['metrics'] is Map<String, dynamic>
          ? PerformanceMetricsModel.fromJson(json['metrics'] as Map<String, dynamic>)
          : null,
      rank: int.tryParse(json['rank']?.toString() ?? '1') ?? 1,
      tasks: tasksList,
      leaves: leavesList,
      qualityFeedback: json['quality_feedback'] is Map<String, dynamic>
          ? PerformanceQualityFeedbackModel.fromJson(json['quality_feedback'] as Map<String, dynamic>)
          : (json['qualityFeedback'] is Map<String, dynamic>
              ? PerformanceQualityFeedbackModel.fromJson(json['qualityFeedback'] as Map<String, dynamic>)
              : null),
      rawJson: json,
    );
  }

  EmployeePerformance toUiModel() {
    return EmployeePerformance(
      id: employee.id.toString(),
      name: employee.name,
      designation: employee.designation != null && employee.designation!.isNotEmpty
          ? employee.designation!
          : (employee.department != null && employee.department!.isNotEmpty
              ? employee.department!
              : 'Employee'),
      department: employee.department ?? 'General',
      performanceScore: score?.round() ?? 0,
      ratingLabel: evaluation,
      imageUrl: employee.resolvedAvatar,
      rank: rank,
      employeeCode: employee.employeeId,
      email: employee.email,
      team: employee.team,
      rawScore: score,
      metricsData: metrics?.toJson(),
      sourceCountsData: sourceCounts?.toJson(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employee': employee.toJson(),
      if (period != null) 'period': period!.toJson(),
      'score': score,
      'evaluation': evaluation,
      if (sourceCounts != null) 'source_counts': sourceCounts!.toJson(),
      if (metrics != null) 'metrics': metrics!.toJson(),
      'rank': rank,
      'tasks': tasks.map((t) => t.toJson()).toList(),
      'leaves': leaves.map((l) => l.toJson()).toList(),
      if (qualityFeedback != null) 'quality_feedback': qualityFeedback!.toJson(),
    };
  }
}

class PerformanceTaskDetailModel {
  final String title;
  final String project;
  final String priority;
  final String status;
  final String assignedDate;
  final String assignedBy;
  final String deadline;
  final String completedDate;
  final String timeliness;
  final bool isEarly;
  final String subtasks;
  final String description;

  PerformanceTaskDetailModel({
    required this.title,
    this.project = 'Project',
    this.priority = 'Medium',
    this.status = 'In Progress',
    this.assignedDate = '',
    this.assignedBy = '',
    this.deadline = '',
    this.completedDate = '',
    this.timeliness = '',
    this.isEarly = false,
    this.subtasks = '',
    this.description = '',
  });

  factory PerformanceTaskDetailModel.fromJson(Map<String, dynamic> json) {
    return PerformanceTaskDetailModel(
      title: json['title']?.toString() ?? json['task_title']?.toString() ?? 'Task',
      project: json['project']?.toString() ?? json['project_name']?.toString() ?? 'Project',
      priority: json['priority']?.toString() ?? 'Medium',
      status: json['status']?.toString() ?? 'In Progress',
      assignedDate: json['assignedDate']?.toString() ?? json['assigned_date']?.toString() ?? json['created_at']?.toString() ?? '',
      assignedBy: json['assignedBy']?.toString() ?? json['assigned_by']?.toString() ?? '',
      deadline: json['deadline']?.toString() ?? json['due_date']?.toString() ?? '',
      completedDate: json['completedDate']?.toString() ?? json['completed_date']?.toString() ?? '',
      timeliness: json['timeliness']?.toString() ?? '',
      isEarly: json['isEarly'] == true || json['is_early'] == true,
      subtasks: json['subtasks']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'project': project,
      'priority': priority,
      'status': status,
      'assignedDate': assignedDate,
      'assignedBy': assignedBy,
      'deadline': deadline,
      'completedDate': completedDate,
      'timeliness': timeliness,
      'isEarly': isEarly,
      'subtasks': subtasks,
      'description': description,
    };
  }
}

class PerformanceLeaveDetailModel {
  final String type;
  final String dates;
  final String appliedDate;
  final String approvedDate;
  final String approvedBy;
  final String reason;
  final String status;

  PerformanceLeaveDetailModel({
    required this.type,
    this.dates = '',
    this.appliedDate = '',
    this.approvedDate = '',
    this.approvedBy = '',
    this.reason = '',
    this.status = 'Approved',
  });

  factory PerformanceLeaveDetailModel.fromJson(Map<String, dynamic> json) {
    String type = json['type']?.toString() ?? 'Leave';
    if (json['leave_type'] is Map) {
      type = json['leave_type']['name']?.toString() ?? type;
    } else if (json['leave_type'] != null) {
      type = json['leave_type'].toString();
    }

    String dates = json['dates']?.toString() ?? json['date']?.toString() ?? '';
    if (dates.isEmpty && json['from_date'] != null) {
      dates = '${json['from_date']} to ${json['to_date']} (${json['total_days']} days)';
    }

    return PerformanceLeaveDetailModel(
      type: type,
      dates: dates,
      appliedDate: json['appliedDate']?.toString() ?? json['applied_date']?.toString() ?? json['created_at']?.toString() ?? '',
      approvedDate: json['approvedDate']?.toString() ?? json['approved_date']?.toString() ?? '',
      approvedBy: json['approvedBy']?.toString() ?? json['approved_by']?.toString() ?? '',
      reason: json['reason']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Approved',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'dates': dates,
      'appliedDate': appliedDate,
      'approvedDate': approvedDate,
      'approvedBy': approvedBy,
      'reason': reason,
      'status': status,
    };
  }
}

class PerformanceQualityFeedbackModel {
  final String author;
  final String date;
  final String comment;
  final double accuracy;
  final double timeliness;
  final double qaPass;
  final double collaboration;

  PerformanceQualityFeedbackModel({
    this.author = '',
    this.date = '',
    this.comment = '',
    this.accuracy = 0.0,
    this.timeliness = 0.0,
    this.qaPass = 0.0,
    this.collaboration = 0.0,
  });

  factory PerformanceQualityFeedbackModel.fromJson(Map<String, dynamic> json) {
    return PerformanceQualityFeedbackModel(
      author: json['author']?.toString() ?? json['reviewer']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      comment: json['comment']?.toString() ?? json['feedback']?.toString() ?? '',
      accuracy: (json['accuracy'] is num) ? (json['accuracy'] as num).toDouble() : 0.0,
      timeliness: (json['timeliness'] is num) ? (json['timeliness'] as num).toDouble() : 0.0,
      qaPass: (json['qaPass'] is num || json['qa_pass'] is num) ? ((json['qaPass'] ?? json['qa_pass']) as num).toDouble() : 0.0,
      collaboration: (json['collaboration'] is num) ? (json['collaboration'] as num).toDouble() : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'author': author,
      'date': date,
      'comment': comment,
      'accuracy': accuracy,
      'timeliness': timeliness,
      'qaPass': qaPass,
      'collaboration': collaboration,
    };
  }
}

