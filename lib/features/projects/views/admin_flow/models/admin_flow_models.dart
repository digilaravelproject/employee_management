import 'package:flutter/material.dart';

/// Data models for the new Admin Project Management Flow
/// Designed to mirror the exact UI reference flow:
/// Projects List -> Project Details (Overview, Team, Modules, Timeline, Settings) ->
/// Employee Details -> Module Details -> Task Details ->
/// Handover Task -> Handover History -> Project Report -> Project Actions

class AdminFlowHandoverRecord {
  final String id;
  final String taskTitle;
  final String timestamp;
  final String fromUser;
  final String toUser;
  final String reason;
  final String notes;
  final String status; // 'Initial Assignment', 'Handover', 'Accepted', 'In Progress'

  const AdminFlowHandoverRecord({
    required this.id,
    required this.taskTitle,
    required this.timestamp,
    required this.fromUser,
    required this.toUser,
    required this.reason,
    this.notes = '',
    this.status = 'Handover',
  });
}

class AdminFlowTask {
  final String id;
  final String title;
  final String moduleTitle;
  String status; // 'Completed', 'In Progress', 'Pending', 'Overdue'
  String assigneeName;
  String assigneeRole;
  String assigneeAvatar;
  final double allocatedHours; // Time given for task (e.g. 8.0)
  final double actualHours;    // Time spent on task (e.g. 11.0)
  final String estimatedTime;
  final String actualTime;
  final String startDate;
  final String dueDate;
  final String priority; // 'High', 'Medium', 'Low'
  final String description;
  final List<AdminFlowHandoverRecord> handoverHistory;

  AdminFlowTask({
    required this.id,
    required this.title,
    required this.moduleTitle,
    this.status = 'In Progress',
    required this.assigneeName,
    this.assigneeRole = 'Developer',
    this.assigneeAvatar = '',
    this.allocatedHours = 8.0,
    this.actualHours = 5.0,
    String? estimatedTime,
    String? actualTime,
    this.startDate = '12 Sep 2025',
    this.dueDate = '15 Sep 2025',
    this.priority = 'High',
    this.description = 'Implement user signup flow with email verification.',
    List<AdminFlowHandoverRecord>? handoverHistory,
  })  : estimatedTime = estimatedTime ?? '${allocatedHours.toInt()} hours',
        actualTime = actualTime ?? '${actualHours.toInt()} hours',
        handoverHistory = handoverHistory ?? [];

  bool get isTimeExceeded => actualHours > allocatedHours;
  double get extraHours => isTimeExceeded ? (actualHours - allocatedHours) : 0.0;
  double get remainingHours => !isTimeExceeded ? (allocatedHours - actualHours) : 0.0;

  AdminFlowTask copyWith({
    String? id,
    String? title,
    String? moduleTitle,
    String? status,
    String? assigneeName,
    String? assigneeRole,
    String? assigneeAvatar,
    double? allocatedHours,
    double? actualHours,
    String? estimatedTime,
    String? actualTime,
    String? startDate,
    String? dueDate,
    String? priority,
    String? description,
    List<AdminFlowHandoverRecord>? handoverHistory,
  }) {
    return AdminFlowTask(
      id: id ?? this.id,
      title: title ?? this.title,
      moduleTitle: moduleTitle ?? this.moduleTitle,
      status: status ?? this.status,
      assigneeName: assigneeName ?? this.assigneeName,
      assigneeRole: assigneeRole ?? this.assigneeRole,
      assigneeAvatar: assigneeAvatar ?? this.assigneeAvatar,
      allocatedHours: allocatedHours ?? this.allocatedHours,
      actualHours: actualHours ?? this.actualHours,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      actualTime: actualTime ?? this.actualTime,
      startDate: startDate ?? this.startDate,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      description: description ?? this.description,
      handoverHistory: handoverHistory ?? List.from(this.handoverHistory),
    );
  }
}

class AdminFlowModule {
  final String id;
  final String title;
  final int tasksCount;
  final double progress; // 0.0 to 1.0 (e.g. 0.70 for 70%)
  final String status; // 'In Progress', 'Completed', 'Pending'
  final String description;
  final List<AdminFlowTask> tasks;

  const AdminFlowModule({
    required this.id,
    required this.title,
    required this.tasksCount,
    required this.progress,
    required this.status,
    this.description = '',
    this.tasks = const [],
  });

  AdminFlowModule copyWith({
    String? id,
    String? title,
    int? tasksCount,
    double? progress,
    String? status,
    String? description,
    List<AdminFlowTask>? tasks,
  }) {
    return AdminFlowModule(
      id: id ?? this.id,
      title: title ?? this.title,
      tasksCount: tasksCount ?? this.tasksCount,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      description: description ?? this.description,
      tasks: tasks ?? this.tasks,
    );
  }
}

class AdminFlowMemberModule {
  final String title;
  final int tasksCount;
  final double progress; // 0.0 to 1.0
  final List<AdminFlowTask> tasks;

  const AdminFlowMemberModule({
    required this.title,
    required this.tasksCount,
    required this.progress,
    this.tasks = const [],
  });
}

class AdminFlowMember {
  final String id;
  final String employeeId;
  final String name;
  final String role;
  final String department;
  final String status; // 'Working', 'On Leave'
  final double progress; // 0.0 to 1.0 (e.g. 0.60 for 60%)
  final int assignedModulesCount;
  final String email;
  final String mobile;
  final String fullAddress;
  final String city;
  final String state;
  final String pincode;
  final String country;
  final String joinedOn;
  final String avatarUrl;
  final int handoversGivenCount;
  final int handoversReceivedCount;
  final List<AdminFlowMemberModule> assignedModules;
  final List<AdminFlowTask> assignedTasks;

  const AdminFlowMember({
    required this.id,
    this.employeeId = 'EMP-001',
    required this.name,
    required this.role,
    this.department = 'Engineering',
    this.status = 'Working',
    required this.progress,
    required this.assignedModulesCount,
    required this.email,
    this.mobile = '+91 98765 43210',
    this.fullAddress = 'Flat 402, Royal Palms Apartment, Sector 62',
    this.city = 'Noida',
    this.state = 'Uttar Pradesh',
    this.pincode = '201309',
    this.country = 'India',
    required this.joinedOn,
    this.avatarUrl = '',
    this.handoversGivenCount = 2,
    this.handoversReceivedCount = 1,
    this.assignedModules = const [],
    this.assignedTasks = const [],
  });

  String get completeAddressString => '$fullAddress, $city, $state - $pincode, $country';
  int get totalHandoversCount => handoversGivenCount + handoversReceivedCount;
}

class AdminFlowMilestone {
  final String id;
  final String title;
  final String date;
  final String status; // 'Completed', 'In Progress', 'Pending'

  const AdminFlowMilestone({
    required this.id,
    required this.title,
    required this.date,
    required this.status,
  });
}

class AdminFlowActivityItem {
  final String id;
  final String title;
  final String timestamp;
  final String user;
  final IconData icon;
  final Color iconColor;

  const AdminFlowActivityItem({
    required this.id,
    required this.title,
    required this.timestamp,
    required this.user,
    required this.icon,
    required this.iconColor,
  });
}

class AdminProjectFileItem {
  final String id;
  final String projectId;
  final String fileName;
  final String fileSize; // e.g. '2.4 MB'
  final String fileExtension; // 'pdf', 'docx', 'xlsx', 'fig', 'zip', 'png'
  final String uploadedBy; // 'Admin' or 'Aarav Sharma (Employee)'
  final String uploadDate; // '23 Oct 2026'
  final String? fileUrl;

  const AdminProjectFileItem({
    required this.id,
    required this.projectId,
    required this.fileName,
    required this.fileSize,
    required this.fileExtension,
    required this.uploadedBy,
    required this.uploadDate,
    this.fileUrl,
  });
}

class AdminFlowProject {
  final String id;
  final String code; // e.g. 'PRJ-001'
  final String title;
  final String description;
  final String category;
  final String status; // 'Active', 'On Hold', 'Completed'
  final String startDate;
  final String endDate;
  final String deadline;
  final String duration;
  final double progress; // e.g. 0.37
  final int totalMembers;
  final int totalModules;
  final int completedModules;
  final int pendingModules;
  final IconData icon;
  final Color themeColor;
  final Color iconBgColor;
  final List<AdminFlowMember> members;
  final List<AdminFlowModule> modules;
  final List<AdminFlowMilestone> milestones;
  final List<AdminFlowActivityItem> activityLog;
  final List<AdminProjectFileItem> files;

  // Time & Task reporting metrics
  final int estimatedHours;
  final int actualHours;
  final int remainingHours;
  final int completedTasksCount;
  final int inProgressTasksCount;
  final int pendingTasksCount;
  final int overdueTasksCount;

  const AdminFlowProject({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.deadline,
    required this.duration,
    required this.progress,
    required this.totalMembers,
    required this.totalModules,
    required this.completedModules,
    required this.pendingModules,
    required this.icon,
    required this.themeColor,
    required this.iconBgColor,
    this.members = const [],
    this.modules = const [],
    this.milestones = const [],
    this.activityLog = const [],
    this.files = const [],
    this.estimatedHours = 330,
    this.actualHours = 287,
    this.remainingHours = 33,
    this.completedTasksCount = 12,
    this.inProgressTasksCount = 14,
    this.pendingTasksCount = 6,
    this.overdueTasksCount = 2,
  });

  AdminFlowProject copyWith({
    String? id,
    String? code,
    String? title,
    String? description,
    String? category,
    String? status,
    String? startDate,
    String? endDate,
    String? deadline,
    String? duration,
    double? progress,
    int? totalMembers,
    int? totalModules,
    int? completedModules,
    int? pendingModules,
    IconData? icon,
    Color? themeColor,
    Color? iconBgColor,
    List<AdminFlowMember>? members,
    List<AdminFlowModule>? modules,
    List<AdminFlowMilestone>? milestones,
    List<AdminFlowActivityItem>? activityLog,
    int? estimatedHours,
    int? actualHours,
    int? remainingHours,
    int? completedTasksCount,
    int? inProgressTasksCount,
    int? pendingTasksCount,
    int? overdueTasksCount,
  }) {
    return AdminFlowProject(
      id: id ?? this.id,
      code: code ?? this.code,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      deadline: deadline ?? this.deadline,
      duration: duration ?? this.duration,
      progress: progress ?? this.progress,
      totalMembers: totalMembers ?? this.totalMembers,
      totalModules: totalModules ?? this.totalModules,
      completedModules: completedModules ?? this.completedModules,
      pendingModules: pendingModules ?? this.pendingModules,
      icon: icon ?? this.icon,
      themeColor: themeColor ?? this.themeColor,
      iconBgColor: iconBgColor ?? this.iconBgColor,
      members: members ?? this.members,
      modules: modules ?? this.modules,
      milestones: milestones ?? this.milestones,
      activityLog: activityLog ?? this.activityLog,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      actualHours: actualHours ?? this.actualHours,
      remainingHours: remainingHours ?? this.remainingHours,
      completedTasksCount: completedTasksCount ?? this.completedTasksCount,
      inProgressTasksCount: inProgressTasksCount ?? this.inProgressTasksCount,
      pendingTasksCount: pendingTasksCount ?? this.pendingTasksCount,
      overdueTasksCount: overdueTasksCount ?? this.overdueTasksCount,
    );
  }
}
