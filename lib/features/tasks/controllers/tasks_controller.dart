import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../projects/controllers/projects_controller.dart';
import '../../projects/models/project_model.dart';
import '../../role_permissions/models/role_permission_models.dart';
import '../../../core/controllers/app_controller.dart';
import '../models/task_model.dart';

class TasksController extends GetxController {
  final RxList<TaskModel> tasks = <TaskModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedFilter = 'All'.obs; // All, To Do, In Progress, Testing, Completed, My Tasks, Team Tracking

  // Currently viewed task
  final Rxn<TaskModel> selectedTask = Rxn<TaskModel>();

  // Real-time ticker for live timers
  Timer? _timerTicker;
  final RxInt liveTicker = 0.obs;

  // Task Creation & Edit Form State
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final RxString selectedPriority = 'Medium'.obs;
  final RxString selectedStatus = TaskModel.statusToDo.obs;
  final Rx<DateTime> selectedDeadline = DateTime.now().add(const Duration(days: 7)).obs;
  final RxList<AppUser> tempAssignees = <AppUser>[].obs;
  final RxList<String> tempAttachments = <String>[].obs;
  final RxString selectedProjectName = 'None'.obs;

  @override
  void onInit() {
    if (!Get.isRegistered<ProjectsController>()) {
      Get.put(ProjectsController());
    }
    super.onInit();
    _initializeDummyTasks();

    // 1-second interval ticker for running timers
    _timerTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      final hasRunning = tasks.any((t) => t.isTimerRunning);
      if (hasRunning) {
        liveTicker.value++;
      }
    });
  }

  @override
  void onClose() {
    _timerTicker?.cancel();
    super.onClose();
  }

  void _initializeDummyTasks() {
    final projController = Get.find<ProjectsController>();
    final emps = projController.allEmployees;
    final projs = projController.projects;

    final websiteRedesign = projs.isNotEmpty ? projs[0] : null;
    final mobileApp = projs.length > 1 ? projs[1] : null;
    final crmIntegration = projs.length > 2 ? projs[2] : null;

    // Task 1: UI/UX Design (In Progress with tracked time)
    final t1SubTasks = [
      SubTask(id: 'st1', title: 'Create wireframes', isCompleted: true, date: DateTime(2024, 4, 12)),
      SubTask(id: 'st2', title: 'Design login screen', isCompleted: true, date: DateTime(2024, 4, 14)),
      SubTask(id: 'st3', title: 'Design dashboard', isCompleted: false, date: DateTime(2024, 5, 15)),
      SubTask(id: 'st4', title: 'User testing', isCompleted: false),
    ];

    final t1Comments = [
      TaskComment(
        id: 'c1',
        user: emps[0], // John Smith (Manager)
        text: 'Please make sure to follow the new design system and brand guidelines.',
        timestamp: DateTime(2024, 4, 10, 10, 30),
        userRole: 'Manager',
      ),
      TaskComment(
        id: 'c2',
        user: emps[1], // Sarah Johnson
        text: 'Sure, I\'ll share the initial wireframes by tomorrow.',
        timestamp: DateTime(2024, 4, 11, 11, 20),
        userRole: 'UI/UX Designer',
      ),
    ];

    final t1Timeline = [
      TaskStatusUpdate(
        id: 'u1',
        status: TaskModel.statusToDo,
        title: 'Task Created',
        description: 'Task allocated to Sarah Johnson.',
        timestamp: DateTime(2024, 4, 10, 10, 30),
        user: emps[0],
      ),
      TaskStatusUpdate(
        id: 'u2',
        status: TaskModel.statusInProgress,
        title: 'Work Started',
        description: 'Timer started. Wireframe research underway.',
        timestamp: DateTime(2024, 4, 11, 9, 15),
        user: emps[1],
      ),
    ];

    final t1TimeLogs = [
      TaskTimeLog(
        id: 'tl_1',
        user: emps[1],
        startTime: DateTime.now().subtract(const Duration(hours: 4)),
        endTime: DateTime.now().subtract(const Duration(hours: 2)),
        durationSeconds: 7200,
        note: 'Completed first pass of wireframes and navigation architecture.',
      ),
      TaskTimeLog(
        id: 'tl_2',
        user: emps[1],
        startTime: DateTime.now().subtract(const Duration(hours: 1)),
        endTime: DateTime.now().subtract(const Duration(minutes: 15)),
        durationSeconds: 2700,
        note: 'Design iterations for login screen.',
      ),
    ];

    tasks.addAll([
      TaskModel(
        id: 'task_1',
        title: 'UI/UX Design',
        description: 'Redesign the login and dashboard screens to improve user experience and align with the new brand guidelines.',
        assignees: [emps[1]], // Sarah Johnson
        project: websiteRedesign,
        priority: 'Medium',
        deadline: DateTime(2024, 5, 15),
        status: TaskModel.statusInProgress,
        subTasks: t1SubTasks,
        comments: t1Comments,
        statusUpdates: t1Timeline,
        attachments: ['Wireframes_v1.pdf', 'Design_System_v2.fig'],
        totalTrackedSeconds: 9900, // 2h 45m
        isTimerRunning: false,
        timeLogs: t1TimeLogs,
      ),
      TaskModel(
        id: 'task_2',
        title: 'API Integration',
        description: 'Integrate payment gateway with backend APIs and verify secure callbacks.',
        assignees: [emps[2]], // Michael Brown
        project: mobileApp,
        priority: 'High',
        deadline: DateTime(2024, 5, 20),
        status: TaskModel.statusToDo,
        subTasks: [],
        comments: [],
        statusUpdates: [
          TaskStatusUpdate(
            id: 'api_u1',
            status: TaskModel.statusToDo,
            title: 'Created',
            description: 'Task is created and assigned.',
            timestamp: DateTime(2024, 5, 12, 10, 00),
            user: emps[0],
          )
        ],
        attachments: [],
        totalTrackedSeconds: 0,
        isTimerRunning: false,
        timeLogs: [],
      ),
      TaskModel(
        id: 'task_3',
        title: 'Database Optimization',
        description: 'Optimize database queries and indexes to improve query response times under high payload.',
        assignees: [emps[3]], // David Wilson
        project: crmIntegration,
        priority: 'Low',
        deadline: DateTime(2024, 5, 25),
        status: TaskModel.statusTesting, // Ready for Manager/QA review!
        subTasks: [],
        comments: [],
        statusUpdates: [
          TaskStatusUpdate(
            id: 'db_u1',
            status: TaskModel.statusToDo,
            title: 'Created',
            description: 'Task created.',
            timestamp: DateTime(2024, 5, 13, 11, 00),
            user: emps[0],
          ),
          TaskStatusUpdate(
            id: 'db_u2',
            status: TaskModel.statusInProgress,
            title: 'Indexing & Tuning',
            description: 'Query optimization applied to PostgreSQL.',
            timestamp: DateTime(2024, 5, 14, 15, 00),
            user: emps[3],
          ),
          TaskStatusUpdate(
            id: 'db_u3',
            status: TaskModel.statusTesting,
            title: 'Submitted for Testing',
            description: 'Staging benchmark run completed. Please verify performance metrics.',
            timestamp: DateTime(2024, 5, 15, 11, 30),
            user: emps[3],
          ),
        ],
        attachments: ['QueryBenchmarkReport.pdf'],
        totalTrackedSeconds: 12600, // 3h 30m
        isTimerRunning: false,
        timeLogs: [
          TaskTimeLog(
            id: 'tl_db1',
            user: emps[3],
            startTime: DateTime.now().subtract(const Duration(days: 1)),
            endTime: DateTime.now().subtract(const Duration(days: 1)).add(const Duration(hours: 3, minutes: 30)),
            durationSeconds: 12600,
            note: 'Index execution plan analysis and index creation.',
          )
        ],
      ),
      TaskModel(
        id: 'task_4',
        title: 'Bug Fixing',
        description: 'Fix reported crash issues and API failures in the mobile app release candidate.',
        assignees: [emps[4]], // Emily Davis
        project: mobileApp,
        priority: 'High',
        deadline: DateTime(2024, 5, 10),
        status: TaskModel.statusCompleted,
        subTasks: [
          SubTask(id: 'st_bug1', title: 'Fix auth crash', isCompleted: true, date: DateTime(2024, 5, 8)),
          SubTask(id: 'st_bug2', title: 'Fix notification latency', isCompleted: true, date: DateTime(2024, 5, 9)),
        ],
        comments: [],
        statusUpdates: [
          TaskStatusUpdate(
            id: 'bug_u1',
            status: TaskModel.statusCompleted,
            title: 'Completed & Verified',
            description: 'All release candidate bugs verified and patched.',
            timestamp: DateTime(2024, 5, 9, 16, 30),
            user: emps[4],
          )
        ],
        attachments: ['CrashLog_v1.txt'],
        totalTrackedSeconds: 18000, // 5h
        isTimerRunning: false,
        timeLogs: [
          TaskTimeLog(
            id: 'tl_bg1',
            user: emps[4],
            startTime: DateTime(2024, 5, 8, 10),
            endTime: DateTime(2024, 5, 8, 15),
            durationSeconds: 18000,
            note: 'Resolved crash on logout and socket timeout.',
          )
        ],
      ),
      TaskModel(
        id: 'task_5',
        title: 'User Testing',
        description: 'Perform exhaustive user testing sessions on new beta features with 10 test user profiles.',
        assignees: [emps[5]], // James Anderson
        project: websiteRedesign,
        priority: 'Medium',
        deadline: DateTime(2024, 5, 18),
        status: TaskModel.statusInProgress,
        subTasks: [],
        comments: [],
        statusUpdates: [
          TaskStatusUpdate(
            id: 'test_u1',
            status: TaskModel.statusInProgress,
            title: 'In Progress',
            description: 'User testing panel set up and ready.',
            timestamp: DateTime(2024, 5, 14, 14, 00),
            user: emps[5],
          )
        ],
        attachments: [],
        totalTrackedSeconds: 5400, // 1h 30m
        isTimerRunning: false,
        timeLogs: [
          TaskTimeLog(
            id: 'tl_ut1',
            user: emps[5],
            startTime: DateTime.now().subtract(const Duration(hours: 3)),
            endTime: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
            durationSeconds: 5400,
            note: 'Cohort 1 feedback interviews.',
          )
        ],
      ),
    ]);

    // Initial synchronization of tasks with their corresponding project
    for (final t in tasks) {
      _syncTaskStatusWithProject(t);
    }
  }

  // Filtered task list feed
  List<TaskModel> get filteredTasks {
    List<TaskModel> results = tasks;

    // Check user role
    final appController = Get.isRegistered<AppController>() ? Get.find<AppController>() : null;
    final isEmployee = appController?.userRole.value.toLowerCase() == 'employee';

    if (isEmployee) {
      // Scope strictly to tasks assigned to current employee
      final projController = Get.find<ProjectsController>();
      final myUser = projController.allEmployees[1]; // Sarah Johnson
      results = results.where((t) => t.assignees.any((a) => a.name == myUser.name || a.email == myUser.email)).toList();
    }

    // Filter by tab selection
    final filter = selectedFilter.value;
    if (filter == 'To Do') {
      results = results.where((t) => t.normalizedStatus == TaskModel.statusToDo).toList();
    } else if (filter == 'In Progress') {
      results = results.where((t) => t.normalizedStatus == TaskModel.statusInProgress).toList();
    } else if (filter == 'Testing') {
      results = results.where((t) => t.normalizedStatus == TaskModel.statusTesting).toList();
    } else if (filter == 'Completed') {
      results = results.where((t) => t.normalizedStatus == TaskModel.statusCompleted).toList();
    }

    // Filter by search query
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      results = results.where((t) =>
          t.title.toLowerCase().contains(q) ||
          t.description.toLowerCase().contains(q) ||
          (t.project?.name.toLowerCase().contains(q) ?? false)).toList();
    }

    return results;
  }

  // ── Manager Metrics & Summaries ──
  int get totalTeamTrackedSeconds {
    return tasks.fold(0, (sum, t) => sum + t.activeTotalSeconds);
  }

  String get formattedTotalTeamTime {
    final secs = totalTeamTrackedSeconds;
    final hours = secs ~/ 3600;
    final minutes = (secs % 3600) ~/ 60;
    return '${hours}h ${minutes}m';
  }

  List<TaskModel> get activeRunningTasks {
    return tasks.where((t) => t.isTimerRunning).toList();
  }

  List<TaskModel> get testingTasks {
    return tasks.where((t) => t.normalizedStatus == TaskModel.statusTesting).toList();
  }

  Map<String, int> get employeeTimeSpentMap {
    final map = <String, int>{};
    for (var t in tasks) {
      for (var log in t.timeLogs) {
        map[log.user.name] = (map[log.user.name] ?? 0) + log.durationSeconds;
      }
      if (t.isTimerRunning && t.assignees.isNotEmpty) {
        final currentElapsed = DateTime.now().difference(t.timerStartedAt ?? DateTime.now()).inSeconds;
        final name = t.assignees.first.name;
        map[name] = (map[name] ?? 0) + currentElapsed;
      }
    }
    return map;
  }

  void selectTask(TaskModel task) {
    selectedTask.value = task;
  }

  // ── Employee Live Timer Operations ──
  void startTaskTimer(String taskId) {
    final idx = tasks.indexWhere((t) => t.id == taskId);
    if (idx == -1) return;

    final current = tasks[idx];

    // Check if any other task is running and pause it
    for (int i = 0; i < tasks.length; i++) {
      if (tasks[i].id != taskId && tasks[i].isTimerRunning) {
        pauseTaskTimer(tasks[i].id, showSnackbar: false);
      }
    }

    final projController = Get.find<ProjectsController>();
    final currentUser = current.assignees.isNotEmpty ? current.assignees.first : projController.allEmployees[1];

    final newStatus = current.normalizedStatus == TaskModel.statusToDo
        ? TaskModel.statusInProgress
        : current.status;

    final newUpdate = TaskStatusUpdate(
      id: 'timer_start_${DateTime.now().millisecondsSinceEpoch}',
      status: newStatus,
      title: 'Timer Started',
      description: 'Work commenced on task by ${currentUser.name}.',
      timestamp: DateTime.now(),
      user: currentUser,
    );

    final updated = current.copyWith(
      isTimerRunning: true,
      timerStartedAt: DateTime.now(),
      status: newStatus,
      statusUpdates: List<TaskStatusUpdate>.from(current.statusUpdates)..add(newUpdate),
    );

    tasks[idx] = updated;
    if (selectedTask.value?.id == taskId) {
      selectedTask.value = updated;
    }
    _syncTaskStatusWithProject(updated);

    Get.snackbar(
      'Timer Started',
      'Timer started for "${current.title}". Status is now In Progress.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void pauseTaskTimer(String taskId, {bool showSnackbar = true}) {
    final idx = tasks.indexWhere((t) => t.id == taskId);
    if (idx == -1) return;

    final current = tasks[idx];
    if (!current.isTimerRunning || current.timerStartedAt == null) return;

    final elapsed = DateTime.now().difference(current.timerStartedAt!).inSeconds;
    final projController = Get.find<ProjectsController>();
    final currentUser = current.assignees.isNotEmpty ? current.assignees.first : projController.allEmployees[1];

    final newLog = TaskTimeLog(
      id: 'log_${DateTime.now().millisecondsSinceEpoch}',
      user: currentUser,
      startTime: current.timerStartedAt!,
      endTime: DateTime.now(),
      durationSeconds: elapsed,
      note: 'Work session logged.',
    );

    final newUpdate = TaskStatusUpdate(
      id: 'timer_pause_${DateTime.now().millisecondsSinceEpoch}',
      status: current.status,
      title: 'Timer Paused',
      description: 'Session ended: ${newLog.formattedDuration} logged.',
      timestamp: DateTime.now(),
      user: currentUser,
    );

    final updated = current.copyWith(
      isTimerRunning: false,
      timerStartedAt: null,
      totalTrackedSeconds: current.totalTrackedSeconds + elapsed,
      timeLogs: List<TaskTimeLog>.from(current.timeLogs)..add(newLog),
      statusUpdates: List<TaskStatusUpdate>.from(current.statusUpdates)..add(newUpdate),
    );

    tasks[idx] = updated;
    if (selectedTask.value?.id == taskId) {
      selectedTask.value = updated;
    }

    if (showSnackbar) {
      Get.snackbar(
        'Timer Paused',
        'Logged ${newLog.formattedDuration} for "${current.title}".',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF3B82F6),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

  // ── Status Pipeline Transitions ──
  void moveToTesting(String taskId, {String? note}) {
    final idx = tasks.indexWhere((t) => t.id == taskId);
    if (idx == -1) return;

    final current = tasks[idx];

    // If timer is running, pause & log it first
    int addedSeconds = 0;
    List<TaskTimeLog> updatedLogs = List<TaskTimeLog>.from(current.timeLogs);
    if (current.isTimerRunning && current.timerStartedAt != null) {
      addedSeconds = DateTime.now().difference(current.timerStartedAt!).inSeconds;
      final projController = Get.find<ProjectsController>();
      final currentUser = current.assignees.isNotEmpty ? current.assignees.first : projController.allEmployees[1];
      updatedLogs.add(TaskTimeLog(
        id: 'log_${DateTime.now().millisecondsSinceEpoch}',
        user: currentUser,
        startTime: current.timerStartedAt!,
        endTime: DateTime.now(),
        durationSeconds: addedSeconds,
        note: note ?? 'Completed work before testing.',
      ));
    }

    final projController = Get.find<ProjectsController>();
    final currentUser = current.assignees.isNotEmpty ? current.assignees.first : projController.allEmployees[1];

    final newUpdate = TaskStatusUpdate(
      id: 'move_test_${DateTime.now().millisecondsSinceEpoch}',
      status: TaskModel.statusTesting,
      title: 'Submitted for Testing',
      description: note != null && note.trim().isNotEmpty
          ? note.trim()
          : 'Development finished. Awaiting QA testing / Manager review.',
      timestamp: DateTime.now(),
      user: currentUser,
    );

    final updated = current.copyWith(
      status: TaskModel.statusTesting,
      isTimerRunning: false,
      timerStartedAt: null,
      totalTrackedSeconds: current.totalTrackedSeconds + addedSeconds,
      timeLogs: updatedLogs,
      statusUpdates: List<TaskStatusUpdate>.from(current.statusUpdates)..add(newUpdate),
    );

    tasks[idx] = updated;
    if (selectedTask.value?.id == taskId) {
      selectedTask.value = updated;
    }
    _syncTaskStatusWithProject(updated);

    Get.snackbar(
      'Sent to Testing',
      'Task is now in Testing phase for verification.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF6366F1), // Indigo
      colorText: Colors.white,
    );
  }

  void approveAndCompleteTask(String taskId, {String? managerNote}) {
    final idx = tasks.indexWhere((t) => t.id == taskId);
    if (idx == -1) return;

    final current = tasks[idx];
    final projController = Get.find<ProjectsController>();
    final currentUser = projController.allEmployees[0]; // John Smith (Manager)

    // Stop timer if running
    int addedSeconds = 0;
    List<TaskTimeLog> updatedLogs = List<TaskTimeLog>.from(current.timeLogs);
    if (current.isTimerRunning && current.timerStartedAt != null) {
      addedSeconds = DateTime.now().difference(current.timerStartedAt!).inSeconds;
      updatedLogs.add(TaskTimeLog(
        id: 'log_${DateTime.now().millisecondsSinceEpoch}',
        user: currentUser,
        startTime: current.timerStartedAt!,
        endTime: DateTime.now(),
        durationSeconds: addedSeconds,
        note: managerNote ?? 'Final approval logged.',
      ));
    }

    final newUpdate = TaskStatusUpdate(
      id: 'approved_${DateTime.now().millisecondsSinceEpoch}',
      status: TaskModel.statusCompleted,
      title: 'Completed & Approved',
      description: managerNote != null && managerNote.trim().isNotEmpty
          ? managerNote.trim()
          : 'Testing verified and approved as Completed.',
      timestamp: DateTime.now(),
      user: currentUser,
    );

    final updated = current.copyWith(
      status: TaskModel.statusCompleted,
      isTimerRunning: false,
      timerStartedAt: null,
      totalTrackedSeconds: current.totalTrackedSeconds + addedSeconds,
      timeLogs: updatedLogs,
      statusUpdates: List<TaskStatusUpdate>.from(current.statusUpdates)..add(newUpdate),
    );

    tasks[idx] = updated;
    if (selectedTask.value?.id == taskId) {
      selectedTask.value = updated;
    }
    _syncTaskStatusWithProject(updated);

    Get.snackbar(
      'Task Completed',
      'Task verified and marked as Completed!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
    );
  }

  void sendBackToInProgress(String taskId, {String? reason}) {
    final idx = tasks.indexWhere((t) => t.id == taskId);
    if (idx == -1) return;

    final current = tasks[idx];
    final projController = Get.find<ProjectsController>();
    final currentUser = projController.allEmployees[0];

    final newUpdate = TaskStatusUpdate(
      id: 'back_prog_${DateTime.now().millisecondsSinceEpoch}',
      status: TaskModel.statusInProgress,
      title: 'Re-opened for Fixes',
      description: reason != null && reason.trim().isNotEmpty
          ? 'Changes requested: ${reason.trim()}'
          : 'Testing failed / changes required before completion.',
      timestamp: DateTime.now(),
      user: currentUser,
    );

    final updated = current.copyWith(
      status: TaskModel.statusInProgress,
      statusUpdates: List<TaskStatusUpdate>.from(current.statusUpdates)..add(newUpdate),
    );

    tasks[idx] = updated;
    if (selectedTask.value?.id == taskId) {
      selectedTask.value = updated;
    }
    _syncTaskStatusWithProject(updated);

    Get.snackbar(
      'Re-opened to In Progress',
      'Task returned to In Progress for adjustments.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFF59E0B),
      colorText: Colors.white,
    );
  }

  void updateTaskStatus(String newStatus, String comment) {
    final current = selectedTask.value;
    if (current == null) return;

    if (newStatus == TaskModel.statusTesting) {
      moveToTesting(current.id, note: comment);
      return;
    } else if (newStatus == TaskModel.statusCompleted) {
      approveAndCompleteTask(current.id, managerNote: comment);
      return;
    } else if (newStatus == TaskModel.statusInProgress && current.normalizedStatus == TaskModel.statusTesting) {
      sendBackToInProgress(current.id, reason: comment);
      return;
    }

    final projController = Get.find<ProjectsController>();
    final currentUser = projController.allEmployees[0];

    String logDescription = 'Status updated to $newStatus';
    if (comment.trim().isNotEmpty) {
      logDescription += '\n${comment.trim()}';
    }

    final newUpdate = TaskStatusUpdate(
      id: 'status_update_${DateTime.now().millisecondsSinceEpoch}',
      status: newStatus,
      title: newStatus,
      description: logDescription,
      timestamp: DateTime.now(),
      user: currentUser,
    );

    final updated = current.copyWith(
      status: newStatus,
      statusUpdates: List<TaskStatusUpdate>.from(current.statusUpdates)..add(newUpdate),
    );

    final idx = tasks.indexWhere((t) => t.id == current.id);
    if (idx != -1) {
      tasks[idx] = updated;
    }
    selectedTask.value = updated;
    _syncTaskStatusWithProject(updated);

    Get.snackbar(
      'Status Updated',
      'Task status successfully changed to $newStatus',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
    );
  }

  // ── Comments & Sub-tasks ──
  void addComment(String commentText) {
    final current = selectedTask.value;
    if (current == null || commentText.trim().isEmpty) return;

    final projController = Get.find<ProjectsController>();
    final currentUser = projController.allEmployees[0];

    final newComment = TaskComment(
      id: 'comment_${DateTime.now().millisecondsSinceEpoch}',
      user: currentUser,
      text: commentText.trim(),
      timestamp: DateTime.now(),
      userRole: 'Manager',
    );

    final updatedComments = List<TaskComment>.from(current.comments)..add(newComment);
    final updated = current.copyWith(comments: updatedComments);

    final idx = tasks.indexWhere((t) => t.id == current.id);
    if (idx != -1) {
      tasks[idx] = updated;
    }
    selectedTask.value = updated;
  }

  void toggleSubTask(String subTaskId) {
    final current = selectedTask.value;
    if (current == null) return;

    final updatedSubTasks = current.subTasks.map((st) {
      if (st.id == subTaskId) {
        return st.copyWith(isCompleted: !st.isCompleted, date: DateTime.now());
      }
      return st;
    }).toList();

    final updated = current.copyWith(subTasks: updatedSubTasks);

    final idx = tasks.indexWhere((t) => t.id == current.id);
    if (idx != -1) {
      tasks[idx] = updated;
    }
    selectedTask.value = updated;
  }

  void addSubTask(String title) {
    final current = selectedTask.value;
    if (current == null || title.trim().isEmpty) return;

    final newSubTask = SubTask(
      id: 'subtask_${DateTime.now().millisecondsSinceEpoch}',
      title: title.trim(),
      isCompleted: false,
    );

    final updatedSubTasks = List<SubTask>.from(current.subTasks)..add(newSubTask);
    final updated = current.copyWith(subTasks: updatedSubTasks);

    final idx = tasks.indexWhere((t) => t.id == current.id);
    if (idx != -1) {
      tasks[idx] = updated;
    }
    selectedTask.value = updated;
  }

  // ── Admin Task CRUD Lifecycle ──
  void clearCreationForm() {
    titleController.clear();
    descriptionController.clear();
    selectedPriority.value = 'Medium';
    selectedStatus.value = TaskModel.statusToDo;
    selectedDeadline.value = DateTime.now().add(const Duration(days: 7));
    tempAssignees.clear();
    tempAttachments.clear();
    selectedProjectName.value = 'None';
  }

  void populateTaskForm(TaskModel task) {
    titleController.text = task.title;
    descriptionController.text = task.description;
    selectedPriority.value = task.priority;
    selectedStatus.value = task.normalizedStatus;
    selectedDeadline.value = task.deadline;
    tempAssignees.assignAll(task.assignees);
    tempAttachments.assignAll(task.attachments);
    selectedProjectName.value = task.project?.name ?? 'None';
  }

  void saveTask() {
    if (titleController.text.trim().isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Task Title is required!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    final projController = Get.find<ProjectsController>();
    final currentUser = projController.allEmployees[0];

    var pName = selectedProjectName.value;
    var targetProject = projController.projects.firstWhereOrNull((p) => p.name == pName);

    final newTask = TaskModel(
      id: 'task_${DateTime.now().millisecondsSinceEpoch}',
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      assignees: List<AppUser>.from(tempAssignees),
      project: targetProject,
      priority: selectedPriority.value,
      deadline: selectedDeadline.value,
      status: selectedStatus.value,
      subTasks: [],
      comments: [],
      statusUpdates: [
        TaskStatusUpdate(
          id: 'status_init_${DateTime.now().millisecondsSinceEpoch}',
          status: selectedStatus.value,
          title: selectedStatus.value,
          description: 'Task created by ${currentUser.name}.',
          timestamp: DateTime.now(),
          user: currentUser,
        )
      ],
      attachments: List<String>.from(tempAttachments),
    );

    tasks.add(newTask);
    _syncTaskStatusWithProject(newTask);
    clearCreationForm();
    Get.back();
    Get.snackbar(
      'Task Created',
      'New task allocated successfully!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
    );
  }

  void updateExistingTask(String taskId) {
    final idx = tasks.indexWhere((t) => t.id == taskId);
    if (idx == -1) return;

    if (titleController.text.trim().isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Task Title is required!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    final projController = Get.find<ProjectsController>();
    final currentUser = projController.allEmployees[0];
    var pName = selectedProjectName.value;
    var targetProject = projController.projects.firstWhereOrNull((p) => p.name == pName);

    final oldTask = tasks[idx];
    final updated = oldTask.copyWith(
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      assignees: List<AppUser>.from(tempAssignees),
      project: targetProject,
      priority: selectedPriority.value,
      deadline: selectedDeadline.value,
      status: selectedStatus.value,
      attachments: List<String>.from(tempAttachments),
      statusUpdates: [
        ...oldTask.statusUpdates,
        TaskStatusUpdate(
          id: 'status_edit_${DateTime.now().millisecondsSinceEpoch}',
          status: selectedStatus.value,
          title: 'Task Edited',
          description: 'Task details modified by admin ${currentUser.name}.',
          timestamp: DateTime.now(),
          user: currentUser,
        ),
      ],
    );

    tasks[idx] = updated;
    if (selectedTask.value?.id == taskId) {
      selectedTask.value = updated;
    }
    _syncTaskStatusWithProject(updated);
    clearCreationForm();
    Get.back();
    Get.snackbar(
      'Task Updated',
      'Task details successfully updated!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
    );
  }

  void deleteTask(String id) {
    tasks.removeWhere((t) => t.id == id);
    if (selectedTask.value?.id == id) {
      selectedTask.value = null;
    }
    Get.back(); // Dismiss Dialog
    Get.back(); // Pop details screen
    Get.snackbar(
      'Task Deleted',
      'Task has been removed from the platform.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
    );
  }

  void toggleAssigneeSelection(AppUser emp) {
    if (tempAssignees.contains(emp)) {
      tempAssignees.remove(emp);
    } else {
      tempAssignees.add(emp);
    }
  }

  void addMockAttachment(String filename) {
    if (filename.trim().isNotEmpty) {
      tempAttachments.add(filename.trim());
    }
  }

  // ── Project-Task Synchronization ──
  void _syncTaskStatusWithProject(TaskModel task) {
    if (task.project == null) return;
    if (!Get.isRegistered<ProjectsController>()) return;
    final projController = Get.find<ProjectsController>();

    final pIdx = projController.projects.indexWhere(
      (p) => p.id == task.project!.id || p.name.toLowerCase().trim() == task.project!.name.toLowerCase().trim(),
    );
    if (pIdx == -1) return;

    final proj = projController.projects[pIdx];

    // Status mapping: 'To Do', 'In Progress', 'Testing', 'Done' / 'Completed'
    String mappedStatus = task.normalizedStatus;
    if (mappedStatus == TaskModel.statusCompleted) {
      mappedStatus = 'Done';
    }

    final tIdx = proj.tasks.indexWhere(
      (t) => t.id == task.id || t.title.toLowerCase().trim() == task.title.toLowerCase().trim(),
    );

    List<ProjectTask> updatedTasks = List<ProjectTask>.from(proj.tasks);
    if (tIdx != -1) {
      updatedTasks[tIdx] = updatedTasks[tIdx].copyWith(status: mappedStatus);
    } else {
      updatedTasks.add(ProjectTask(
        id: task.id,
        title: task.title,
        category: proj.category,
        status: mappedStatus,
        dueDate: task.deadline,
        assignee: task.assignees.isNotEmpty ? task.assignees.first : null,
      ));
    }

    // Auto-update project's overall status based on tasks progress
    String projectOverallStatus = proj.status;
    final totalTasks = updatedTasks.length;
    final doneTasks = updatedTasks.where((t) => t.status == 'Done' || t.status == 'Completed').length;
    final inProgressTasks = updatedTasks.where((t) => t.status == 'In Progress' || t.status == 'Testing').length;

    if (totalTasks > 0 && doneTasks == totalTasks) {
      projectOverallStatus = 'Completed';
    } else if (inProgressTasks > 0 || doneTasks > 0) {
      if (projectOverallStatus == 'Not Started') {
        projectOverallStatus = 'In Progress';
      }
    }

    final updatedProj = proj.copyWith(tasks: updatedTasks, status: projectOverallStatus);
    projController.projects[pIdx] = updatedProj;
    if (projController.selectedProject.value?.id == proj.id) {
      projController.selectedProject.value = updatedProj;
    }
  }

  void syncStatusFromProject(String taskIdOrTitle, String newStatus) {
    final idx = tasks.indexWhere(
      (t) => t.id == taskIdOrTitle || t.title.toLowerCase().trim() == taskIdOrTitle.toLowerCase().trim(),
    );
    if (idx == -1) return;

    String normalized = newStatus;
    if (newStatus == 'Done') normalized = TaskModel.statusCompleted;

    final current = tasks[idx];
    if (current.status == normalized) return;

    final updated = current.copyWith(status: normalized);
    tasks[idx] = updated;
    if (selectedTask.value?.id == current.id) {
      selectedTask.value = updated;
    }
  }
}
