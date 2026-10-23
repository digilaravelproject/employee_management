import 'package:flutter/material.dart';

/// Data models for the Employee Project & Task Management Flow
/// Designed to follow the Admin Flow structure and match the user's design reference:
/// 1. Employee Dashboard / Home (Today's overview, Current Project, Quick Actions)
/// 2. My Projects (Search, Filters, Progress, Days Left)
/// 3. Project Details (Dates grid, Overall progress, Modules count, My progress)
/// 4. My Tasks (All, In Progress, Completed, Pending; Live Timer Start/Pause/Stop)
/// 5. Request Handover (Reason, Notes, Assignee, Attachments)
/// 6. Handover History (Chronological timeline of task transfers)
/// 7. Time Log (This Week / This Month, Task-wise time breakdown with red overtime)
/// 8. Project Timeline (Milestone phases)
/// 9. Task History (When started, break logs, remaining time, handover records)

/// Represents a work or break session for a task
class EmployeeWorkSession {
  final String id;
  final DateTime startTime;
  DateTime? endTime;
  final bool isBreak;
  final String breakReason; // e.g., 'Tea Break', 'Lunch Break', 'Meeting', 'Call'
  Duration duration;

  EmployeeWorkSession({
    required this.id,
    required this.startTime,
    this.endTime,
    this.isBreak = false,
    this.breakReason = '',
    Duration? duration,
  }) : duration = duration ?? (endTime != null ? endTime.difference(startTime) : Duration.zero);

  String get formattedDuration {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  String get formattedStartTime {
    final h = startTime.hour;
    final m = startTime.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'PM' : 'AM';
    final hour12 = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '${hour12.toString().padLeft(2, '0')}:$m $period';
  }

  String get formattedEndTime {
    if (endTime == null) return 'Active';
    final h = endTime!.hour;
    final m = endTime!.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'PM' : 'AM';
    final hour12 = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '${hour12.toString().padLeft(2, '0')}:$m $period';
  }
}

/// Handover record for employee tasks
class EmployeeFlowHandoverRecord {
  final String id;
  final String taskTitle;
  final String projectId;
  final String timestamp;
  final String fromUser;
  final String fromUserRole;
  final String toUser;
  final String toUserRole;
  final String reason;
  final String notes;
  final String status; // 'Requested', 'Approved', 'Transferred', 'Completed'
  final double progressAtHandover; // e.g., 60.0%
  final String? attachmentName;

  const EmployeeFlowHandoverRecord({
    required this.id,
    required this.taskTitle,
    this.projectId = 'PRJ-001',
    required this.timestamp,
    required this.fromUser,
    this.fromUserRole = 'Developer',
    required this.toUser,
    this.toUserRole = 'UI/UX Designer',
    required this.reason,
    this.notes = '',
    this.status = 'Approved',
    this.progressAtHandover = 60.0,
    this.attachmentName,
  });
}

/// Task assigned to employee with live work tracking
class EmployeeFlowTask {
  final String id;
  final String title;
  final String moduleTitle;
  final String projectId;
  final String projectName;
  String status; // 'In Progress', 'Completed', 'Pending', 'On Hold'
  final String priority; // 'High', 'Medium', 'Low'
  final String dueDate;
  final String startDate;
  final String description;

  // Time tracking properties
  final double allocatedHours; // e.g. 8.0 hours
  double spentSeconds; // Tracked active seconds

  // Live state
  bool isRunning;
  bool isPaused;
  DateTime? currentSessionStartTime;
  DateTime? lastStartTime;
  List<EmployeeWorkSession> workSessions;
  List<EmployeeFlowHandoverRecord> handoverHistory;

  EmployeeFlowTask({
    required this.id,
    required this.title,
    required this.moduleTitle,
    required this.projectId,
    this.projectName = 'E-Commerce Mobile App',
    this.status = 'In Progress',
    this.priority = 'High',
    this.dueDate = '18 Sep 2025',
    this.startDate = '12 Sep 2025',
    this.description = 'Implement and test the UI and logic according to the specification.',
    this.allocatedHours = 8.0,
    double initialSpentHours = 0.0,
    this.isRunning = false,
    this.isPaused = false,
    this.currentSessionStartTime,
    this.lastStartTime,
    List<EmployeeWorkSession>? workSessions,
    List<EmployeeFlowHandoverRecord>? handoverHistory,
  })  : spentSeconds = (initialSpentHours * 3600.0),
        workSessions = workSessions ?? [],
        handoverHistory = handoverHistory ?? [];

  double get spentHours => spentSeconds / 3600.0;
  bool get isTimeExceeded => spentHours > allocatedHours;
  double get overtimeHours => isTimeExceeded ? (spentHours - allocatedHours) : 0.0;
  double get remainingHours => isTimeExceeded ? 0.0 : (allocatedHours - spentHours);

  double get progress {
    if (status == 'Completed') return 1.0;
    if (allocatedHours <= 0) return 0.0;
    final p = spentHours / allocatedHours;
    return p.clamp(0.0, 1.0);
  }

  String get formattedSpentTime {
    final totalSec = spentSeconds.toInt();
    final h = totalSec ~/ 3600;
    final m = (totalSec % 3600) ~/ 60;
    final s = totalSec % 60;
    if (isRunning || isPaused) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${h}h ${m}m';
  }

  String get formattedRatio {
    final spentH = (spentSeconds / 3600.0).toStringAsFixed(spentSeconds % 3600 == 0 ? 0 : 1);
    final allocH = allocatedHours.toStringAsFixed(allocatedHours % 1 == 0 ? 0 : 1);
    return '${spentH}h / ${allocH}h';
  }

  String get formattedRemainingOrOvertime {
    if (isTimeExceeded) {
      final overH = overtimeHours.toStringAsFixed(1);
      return 'Exceeded +${overH}h';
    } else {
      final remH = remainingHours.toStringAsFixed(1);
      return '${remH}h left';
    }
  }

  EmployeeFlowTask copyWith({
    String? id,
    String? title,
    String? moduleTitle,
    String? projectId,
    String? projectName,
    String? status,
    String? priority,
    String? dueDate,
    String? startDate,
    String? description,
    double? allocatedHours,
    double? spentSeconds,
    bool? isRunning,
    bool? isPaused,
    DateTime? currentSessionStartTime,
    DateTime? lastStartTime,
    List<EmployeeWorkSession>? workSessions,
    List<EmployeeFlowHandoverRecord>? handoverHistory,
  }) {
    final task = EmployeeFlowTask(
      id: id ?? this.id,
      title: title ?? this.title,
      moduleTitle: moduleTitle ?? this.moduleTitle,
      projectId: projectId ?? this.projectId,
      projectName: projectName ?? this.projectName,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      startDate: startDate ?? this.startDate,
      description: description ?? this.description,
      allocatedHours: allocatedHours ?? this.allocatedHours,
      isRunning: isRunning ?? this.isRunning,
      isPaused: isPaused ?? this.isPaused,
      currentSessionStartTime: currentSessionStartTime ?? this.currentSessionStartTime,
      lastStartTime: lastStartTime ?? this.lastStartTime,
      workSessions: workSessions ?? List.from(this.workSessions),
      handoverHistory: handoverHistory ?? List.from(this.handoverHistory),
    );
    task.spentSeconds = spentSeconds ?? this.spentSeconds;
    return task;
  }
}

/// Module assigned to employee
class EmployeeFlowModule {
  final String id;
  final String projectId;
  final String title;
  final String description;
  final int totalTasks;
  final int completedTasks;
  final double progress; // 0.0 to 1.0
  final String status; // 'In Progress', 'Completed', 'Pending'
  final List<EmployeeFlowTask> tasks;

  const EmployeeFlowModule({
    required this.id,
    required this.projectId,
    required this.title,
    this.description = '',
    required this.totalTasks,
    required this.completedTasks,
    required this.progress,
    this.status = 'In Progress',
    this.tasks = const [],
  });
}

/// Milestone in project timeline
class EmployeeFlowMilestone {
  final String id;
  final String date;
  final String title;
  final String status; // 'Completed', 'In Progress', 'Pending'

  const EmployeeFlowMilestone({
    required this.id,
    required this.date,
    required this.title,
    required this.status,
  });
}

/// Time Log metric item
class EmployeeFlowTimeLogItem {
  final String taskTitle;
  final double allocatedHours;
  final double actualHours;
  final double diffHours; // e.g. -1.0 means 1h overtime or saving
  final bool isOvertime;

  const EmployeeFlowTimeLogItem({
    required this.taskTitle,
    required this.allocatedHours,
    required this.actualHours,
    required this.diffHours,
    required this.isOvertime,
  });
}

/// Project file or document attachment
class ProjectFileItem {
  final String id;
  final String projectId;
  final String fileName;
  final String fileSize; // e.g. '2.4 MB'
  final String fileExtension; // 'pdf', 'docx', 'xlsx', 'fig', 'zip', 'png'
  final String uploadedBy; // 'Admin' or 'Sneha Patel (Employee)'
  final String uploadDate; // '23 Oct 2026'
  final String? fileUrl;

  const ProjectFileItem({
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

/// Assigned Project for the employee
class EmployeeFlowProject {
  final String id;
  final String code; // e.g. 'PRJ-001'
  final String title;
  final String description;
  final String status; // 'Active', 'On Hold', 'Completed'
  final double progress; // e.g. 0.37 for 37%
  final String startDate;
  final String endDate;
  final String deadline;
  final String duration;
  final int daysLeft;
  final int totalModules;
  final int totalTasks;
  final int myCompletedTasks;
  final int myPendingTasks;
  final IconData icon;
  final Color themeColor;
  final List<EmployeeFlowModule> modules;
  final List<EmployeeFlowMilestone> milestones;
  final List<ProjectFileItem> files;

  const EmployeeFlowProject({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.status,
    required this.progress,
    required this.startDate,
    required this.endDate,
    required this.deadline,
    required this.duration,
    required this.daysLeft,
    required this.totalModules,
    required this.totalTasks,
    required this.myCompletedTasks,
    required this.myPendingTasks,
    required this.icon,
    required this.themeColor,
    this.modules = const [],
    this.milestones = const [],
    this.files = const [],
  });
}

/// Employee User Profile representation
class EmployeeUserProfile {
  final String name;
  final String role;
  final String department;
  final String avatarUrl;
  final String employeeId;

  const EmployeeUserProfile({
    this.name = 'Aarav Sharma',
    this.role = 'Frontend Developer',
    this.department = 'Engineering',
    this.avatarUrl = '',
    this.employeeId = 'EMP-104',
  });
}
