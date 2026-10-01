import 'dart:async';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/controllers/app_controller.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/services/storage/shared_prefs.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/logger.dart';
import '../../employee/management/models/employee_model.dart';
import '../../projects/controllers/projects_controller.dart';
import '../../projects/models/project_model.dart';
import '../../role_permissions/models/role_permission_models.dart';
import '../models/create_task_model.dart';
import '../models/task_model.dart';
import '../repositories/task_repository.dart';
import '../repositories/task_repository_interface.dart';

class TasksController extends GetxController {
  final TaskRepositoryInterface repository;

  TasksController({TaskRepositoryInterface? repository})
      : repository = repository ??
            (Get.isRegistered<TaskRepositoryInterface>()
                ? Get.find<TaskRepositoryInterface>()
                : TaskRepository(
                    apiClient: Get.isRegistered<ApiClient>()
                        ? Get.find<ApiClient>()
                        : Get.put(ApiClient(), permanent: true),
                  ));

  final RxList<TaskModel> tasks = <TaskModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedFilter = 'All'.obs; // All, To Do, In Progress, Testing, Completed, My Tasks, Team Tracking

  // Currently viewed task
  final Rxn<TaskModel> selectedTask = Rxn<TaskModel>();

  // Real-time ticker for live timers
  Timer? _timerTicker;
  final RxInt liveTicker = 0.obs;

  // Scope switcher for employees (My Tasks vs All Project Tasks / Project History)
  final RxString employeeTaskScope = 'My Tasks'.obs; // 'My Tasks', 'All Project Tasks'

  // Task Creation & Edit Form State
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final customCategoryController = TextEditingController();
  final RxString selectedCategory = 'UI/UX Design'.obs;
  final RxBool isCustomCategory = false.obs;
  final RxString selectedPriority = 'Medium'.obs;
  final RxString selectedStatus = 'Pending'.obs;
  final Rx<DateTime> startDate = DateTime.now().obs;
  final Rx<DateTime> dueDate = DateTime.now().add(const Duration(days: 14)).obs;
  final Rx<DateTime> selectedDeadline = DateTime.now().add(const Duration(days: 14)).obs;
  final RxInt estimatedHours = 5.obs;
  final RxInt estimatedMinutes = 30.obs;

  String get formattedEstimatedHours {
    final hStr = estimatedHours.value.toString().padLeft(2, '0');
    final mStr = estimatedMinutes.value.toString().padLeft(2, '0');
    return '${hStr}h ${mStr}m';
  }

  // Selected project for API submission
  final Rxn<Project> selectedProject = Rxn<Project>();
  final RxString selectedProjectName = 'None'.obs;
  final RxString selectedModuleName = 'General'.obs;
  final RxString selectedSubModuleName = 'Default'.obs;

  // Selected employees from API
  final RxList<EmployeeModel> selectedEmployees = <EmployeeModel>[].obs;
  final RxList<AppUser> tempAssignees = <AppUser>[].obs; // For backwards compatibility

  // Attached files
  final RxList<PlatformFile> attachedRealFiles = <PlatformFile>[].obs;
  final RxList<String> tempAttachments = <String>[].obs; // For backwards compatibility

  // Live Employee List from API
  final RxList<EmployeeModel> employeesList = <EmployeeModel>[].obs;
  final RxBool isLoadingEmployees = false.obs;
  final RxString employeeSearchQuery = ''.obs;

  // API Submission loading state
  final RxBool isCreatingTask = false.obs;
  final RxBool isUpdatingTask = false.obs;
  final RxBool isDeletingTask = false.obs;
  final RxBool isAddingSubTask = false.obs;

  // Live Tasks API state
  final RxBool isLoadingTasks = false.obs;
  final RxBool isLoadingTaskDetails = false.obs;
  final RxInt totalTasksCount = 0.obs;
  final RxString tasksErrorMessage = ''.obs;

  @override
  void onInit() {
    if (!Get.isRegistered<ProjectsController>()) {
      Get.put(ProjectsController());
    }
    super.onInit();
    _initializeDummyTasks();
    fetchEmployees();
    fetchTasks();

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

    // Task 1: UI/UX Design (Sarah Johnson - In Progress with tracked time)
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
        module: 'UI/UX & Design System',
        subModule: 'Wireframes & Architecture',
        taskTitle: 'UI/UX Design',
      ),
      TaskTimeLog(
        id: 'tl_2',
        user: emps[1],
        startTime: DateTime.now().subtract(const Duration(hours: 1)),
        endTime: DateTime.now().subtract(const Duration(minutes: 15)),
        durationSeconds: 2700,
        note: 'Design iterations for login screen tokens.',
        module: 'UI/UX & Design System',
        subModule: 'Design Tokens & Theme',
        taskTitle: 'UI/UX Design',
      ),
    ];

    // Task 6: Handed-over task with query / blocker (Jira pass/query flow example)
    final t6Handovers = [
      TaskHandoverEvent(
        id: 'ho_1',
        fromUser: emps[1], // Sarah Johnson passed to Michael Brown
        toUser: emps[2],   // Michael Brown
        type: 'Handover',
        reason: 'Requires backend token validation support before UI review.',
        timestamp: DateTime(2024, 4, 16, 14, 20),
        isResolved: true,
        resolutionNote: 'Backend endpoints provided and tested.',
      ),
      TaskHandoverEvent(
        id: 'ho_2',
        fromUser: emps[2], // Michael Brown asked question to John Smith (Manager)
        toUser: emps[0],   // John Smith (Manager)
        type: 'Query',
        reason: 'Do we need multi-tenant JWT refresh or standard cookie session?',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isResolved: false,
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
        module: 'UI/UX & Design System',
        subModule: 'Wireframes & Architecture',
        totalTrackedSeconds: 9900, // 2h 45m
        isTimerRunning: false,
        timeLogs: t1TimeLogs,
      ),
      TaskModel(
        id: 'task_2',
        title: 'API Integration & Auth Client',
        description: 'Integrate payment gateway with backend APIs and verify secure callbacks.',
        assignees: [emps[2]], // Michael Brown
        project: websiteRedesign,
        priority: 'High',
        deadline: DateTime(2024, 5, 20),
        status: TaskModel.statusInProgress,
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
        module: 'Backend & APIs',
        subModule: 'OAuth & Session Management',
        totalTrackedSeconds: 14400, // 4 hours
        isTimerRunning: false,
        timeLogs: [
          TaskTimeLog(
            id: 'tl_mb1',
            user: emps[2], // Michael Brown
            startTime: DateTime.now().subtract(const Duration(days: 2, hours: 4)),
            endTime: DateTime.now().subtract(const Duration(days: 2)),
            durationSeconds: 14400,
            note: 'Implemented JWT token refresh interceptor in Dio client.',
            module: 'Backend & APIs',
            subModule: 'OAuth & Session Management',
            taskTitle: 'API Integration & Auth Client',
          ),
        ],
      ),
      TaskModel(
        id: 'task_3',
        title: 'Database Optimization & Indexing',
        description: 'Optimize database queries and indexes to improve query response times under high payload.',
        assignees: [emps[3]], // David Wilson
        project: websiteRedesign,
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
        module: 'Backend & APIs',
        subModule: 'Database Schemas',
        totalTrackedSeconds: 12600, // 3h 30m
        isTimerRunning: false,
        timeLogs: [
          TaskTimeLog(
            id: 'tl_db1',
            user: emps[3],
            startTime: DateTime.now().subtract(const Duration(days: 1)),
            endTime: DateTime.now().subtract(const Duration(days: 1)).add(const Duration(hours: 3, minutes: 30)),
            durationSeconds: 12600,
            note: 'Index execution plan analysis and index creation on tasks table.',
            module: 'Backend & APIs',
            subModule: 'Database Schemas',
            taskTitle: 'Database Optimization & Indexing',
          )
        ],
      ),
      TaskModel(
        id: 'task_4',
        title: 'Regression Bug Fixing',
        description: 'Fix reported crash issues and API failures in the responsive web viewport.',
        assignees: [emps[4]], // Emily Davis
        project: websiteRedesign,
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
        module: 'QA & Testing',
        subModule: 'Regression Testing',
        totalTrackedSeconds: 18000, // 5h
        isTimerRunning: false,
        timeLogs: [
          TaskTimeLog(
            id: 'tl_bg1',
            user: emps[4],
            startTime: DateTime(2024, 5, 8, 10),
            endTime: DateTime(2024, 5, 8, 15),
            durationSeconds: 18000,
            note: 'Resolved crash on logout and socket timeout across Safari and Chrome.',
            module: 'QA & Testing',
            subModule: 'Regression Testing',
            taskTitle: 'Regression Bug Fixing',
          )
        ],
      ),
      TaskModel(
        id: 'task_5',
        title: 'User Testing & Panel Interviews',
        description: 'Perform exhaustive user testing sessions on new beta features with 10 test user profiles.',
        assignees: [emps[0]], // John Smith
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
            user: emps[0],
          )
        ],
        attachments: [],
        module: 'UI/UX & Design System',
        subModule: 'Interactive Prototypes',
        totalTrackedSeconds: 7200, // 2h
        isTimerRunning: false,
        timeLogs: [
          TaskTimeLog(
            id: 'tl_ut1',
            user: emps[0],
            startTime: DateTime.now().subtract(const Duration(hours: 3)),
            endTime: DateTime.now().subtract(const Duration(hours: 1)),
            durationSeconds: 7200,
            note: 'Cohort 1 feedback interviews and usability evaluation.',
            module: 'UI/UX & Design System',
            subModule: 'Interactive Prototypes',
            taskTitle: 'User Testing & Panel Interviews',
          )
        ],
      ),
      TaskModel(
        id: 'task_6',
        title: 'Stripe Payment Gateway Integration',
        description: 'Setup Stripe checkout sessions and webhook signatures verification. Blocker query active.',
        assignees: [emps[2]], // Michael Brown
        project: websiteRedesign,
        priority: 'High',
        deadline: DateTime(2024, 5, 22),
        status: TaskModel.statusInProgress,
        subTasks: [],
        comments: [],
        statusUpdates: [
          TaskStatusUpdate(
            id: 'st_u1',
            status: TaskModel.statusInProgress,
            title: 'Task Handed Over & Query Raised',
            description: 'Handed over from Sarah Johnson to Michael Brown. Query asked to Manager John Smith.',
            timestamp: DateTime.now().subtract(const Duration(hours: 2)),
            user: emps[2],
          )
        ],
        attachments: ['StripeDoc_v2.pdf'],
        module: 'Backend & APIs',
        subModule: 'Payment Integrations',
        handovers: t6Handovers,
        hasActiveQuery: true,
        activeQueryNote: 'Do we need multi-tenant JWT refresh or standard cookie session?',
        queryToUser: emps[0],
        totalTrackedSeconds: 10800, // 3h
        isTimerRunning: false,
        timeLogs: [
          TaskTimeLog(
            id: 'tl_st1',
            user: emps[2],
            startTime: DateTime.now().subtract(const Duration(hours: 5)),
            endTime: DateTime.now().subtract(const Duration(hours: 2)),
            durationSeconds: 10800,
            note: 'Configured webhook secret validation and event handling in Node.js server.',
            module: 'Backend & APIs',
            subModule: 'Payment Integrations',
            taskTitle: 'Stripe Payment Gateway Integration',
          )
        ],
      ),
    ]);

    // Initial synchronization of tasks with their corresponding project
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final t in tasks) {
        _syncTaskStatusWithProject(t);
      }
    });
  }

  // Filtered task list feed (with employee scope switcher: My Tasks vs All Project Tasks/History)
  List<TaskModel> get filteredTasks {
    List<TaskModel> results = tasks;

    // Check user role
    final appController = Get.isRegistered<AppController>() ? Get.find<AppController>() : null;
    final isEmployee = appController?.userRole.value.toLowerCase() == 'employee';

    if (isEmployee) {
      String myEmail = '';
      String myName = '';
      try {
        final userDataString = SharedPrefs.getString(AppConstants.userData);
        if (userDataString != null && userDataString.isNotEmpty) {
          final u = jsonDecode(userDataString);
          myEmail = (u['email'] ?? '').toString().toLowerCase().trim();
          myName = (u['name'] ?? '').toString().toLowerCase().trim();
        }
      } catch (_) {}

      final projController = Get.find<ProjectsController>();
      final myUser = projController.allEmployees.length > 1 ? projController.allEmployees[1] : null;

      if (employeeTaskScope.value == 'My Tasks') {
        // Scope strictly to tasks assigned to current employee
        final assigned = results.where((t) {
          if (myEmail.isNotEmpty || myName.isNotEmpty) {
            return t.assignees.any((a) =>
                (myEmail.isNotEmpty && a.email.toLowerCase().trim() == myEmail) ||
                (myName.isNotEmpty && a.name.toLowerCase().trim() == myName));
          }
          if (myUser != null) {
            return t.assignees.any((a) => a.name == myUser.name || a.email == myUser.email);
          }
          return true;
        }).toList();

        if (assigned.isNotEmpty) {
          results = assigned;
        }
      } else {
        // 'All Project Tasks / Project History': All tasks belonging to projects where this employee is a member!
        results = results.where((t) {
          if (t.project == null) return true;
          final proj = projController.projects.firstWhereOrNull((p) => p.id == t.project!.id || p.name == t.project!.name);
          if (proj == null) return true;
          return proj.teamMembers.any((m) =>
              (myEmail.isNotEmpty && m.email.toLowerCase().trim() == myEmail) ||
              (myName.isNotEmpty && m.name.toLowerCase().trim() == myName) ||
              (myUser != null && (m.name == myUser.name || m.email == myUser.email)));
        }).toList();
      }
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
          t.module.toLowerCase().contains(q) ||
          t.subModule.toLowerCase().contains(q) ||
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
    fetchTaskDetails(task.id);
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
      module: current.module,
      subModule: current.subModule,
      taskTitle: current.title,
    );

    final newUpdate = TaskStatusUpdate(
      id: 'timer_pause_${DateTime.now().millisecondsSinceEpoch}',
      status: current.status,
      title: 'Timer Paused',
      description: 'Session ended: ${newLog.formattedDuration} logged for [${current.module} > ${current.subModule}].',
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
        module: current.module,
        subModule: current.subModule,
        taskTitle: current.title,
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
        module: current.module,
        subModule: current.subModule,
        taskTitle: current.title,
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

  // ── Jira Task Handover & Query Escalation Flow ──
  // If someone cannot complete a task, they pass it to someone else with reason.
  // Or if they have questions/blockers, they pass a query/blocker to another person.
  void handoverTask({
    required String taskId,
    required AppUser toUser,
    required String type, // 'Handover', 'Query', 'Blocker'
    required String reason,
  }) {
    final idx = tasks.indexWhere((t) => t.id == taskId);
    if (idx == -1) return;

    final current = tasks[idx];
    final projController = Get.find<ProjectsController>();
    final currentUser = current.assignees.isNotEmpty ? current.assignees.first : projController.allEmployees[1];

    final handoverEvent = TaskHandoverEvent(
      id: 'handover_${DateTime.now().millisecondsSinceEpoch}',
      fromUser: currentUser,
      toUser: toUser,
      type: type,
      reason: reason.trim(),
      timestamp: DateTime.now(),
    );

    String updateTitle;
    String updateDesc;
    List<AppUser> updatedAssignees = List<AppUser>.from(current.assignees);
    bool hasQuery = current.hasActiveQuery;
    String? queryNote = current.activeQueryNote;
    AppUser? queryTarget = current.queryToUser;

    if (type == 'Handover') {
      updateTitle = 'Task Handed Over';
      updateDesc = 'Reassigned from ${currentUser.name} to ${toUser.name}.\nReason: ${reason.trim()}';
      updatedAssignees = [toUser];
    } else if (type == 'Query') {
      updateTitle = 'Question / Help Escalated';
      updateDesc = 'Question asked to ${toUser.name}:\n"${reason.trim()}"';
      hasQuery = true;
      queryNote = reason.trim();
      queryTarget = toUser;
    } else {
      updateTitle = 'Blocker Reported';
      updateDesc = 'Blocker reported to ${toUser.name}:\n"${reason.trim()}"';
      hasQuery = true;
      queryNote = reason.trim();
      queryTarget = toUser;
    }

    final newStatusUpdate = TaskStatusUpdate(
      id: 'update_ho_${DateTime.now().millisecondsSinceEpoch}',
      status: current.status,
      title: updateTitle,
      description: updateDesc,
      timestamp: DateTime.now(),
      user: currentUser,
    );

    final updated = current.copyWith(
      assignees: updatedAssignees,
      handovers: List<TaskHandoverEvent>.from(current.handovers)..add(handoverEvent),
      statusUpdates: List<TaskStatusUpdate>.from(current.statusUpdates)..add(newStatusUpdate),
      hasActiveQuery: hasQuery,
      activeQueryNote: queryNote,
      queryToUser: queryTarget,
    );

    tasks[idx] = updated;
    if (selectedTask.value?.id == taskId) {
      selectedTask.value = updated;
    }
    _syncTaskStatusWithProject(updated);

    Get.snackbar(
      type == 'Handover' ? 'Task Handed Over' : (type == 'Query' ? 'Question Passed' : 'Blocker Raised'),
      type == 'Handover'
          ? 'Task successfully reassigned to ${toUser.name}'
          : 'Query passed to ${toUser.name}. They will be notified to review.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: type == 'Handover' ? const Color(0xFF3B82F6) : const Color(0xFFF59E0B),
      colorText: Colors.white,
    );
  }

  // Resolve pending question/blocker
  void resolveTaskQuery(String taskId, String resolutionNote) {
    final idx = tasks.indexWhere((t) => t.id == taskId);
    if (idx == -1) return;

    final current = tasks[idx];
    final projController = Get.find<ProjectsController>();
    final currentUser = projController.allEmployees[0];

    final updatedHandovers = current.handovers.map((h) {
      if (!h.isResolved) {
        return h.copyWith(isResolved: true, resolutionNote: resolutionNote.trim());
      }
      return h;
    }).toList();

    final resolutionUpdate = TaskStatusUpdate(
      id: 'res_${DateTime.now().millisecondsSinceEpoch}',
      status: current.status,
      title: 'Query / Blocker Resolved',
      description: resolutionNote.trim().isNotEmpty
          ? 'Resolved by ${currentUser.name}: ${resolutionNote.trim()}'
          : 'Query resolved by ${currentUser.name}.',
      timestamp: DateTime.now(),
      user: currentUser,
    );

    final updated = current.copyWith(
      hasActiveQuery: false,
      activeQueryNote: null,
      queryToUser: null,
      handovers: updatedHandovers,
      statusUpdates: List<TaskStatusUpdate>.from(current.statusUpdates)..add(resolutionUpdate),
    );

    tasks[idx] = updated;
    if (selectedTask.value?.id == taskId) {
      selectedTask.value = updated;
    }

    Get.snackbar(
      'Resolved',
      'Task query marked as resolved.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
    );
  }

  // ── Jira Member-wise & Module-wise Project Timesheet Reports (Admin/Manager) ──
  List<Map<String, dynamic>> getMemberProjectTimesheet(String projectId) {
    final projController = Get.find<ProjectsController>();
    final proj = projController.projects.firstWhereOrNull((p) => p.id == projectId);
    if (proj == null) return [];

    final results = <Map<String, dynamic>>[];

    for (final member in proj.teamMembers) {
      int totalSeconds = 0;
      final memberLogs = <TaskTimeLog>[];
      final moduleSecondsMap = <String, int>{};
      final subModuleSecondsMap = <String, int>{};
      final tasksContributed = <String>{};

      for (final task in tasks) {
        if (task.project?.id == proj.id || task.project?.name.toLowerCase().trim() == proj.name.toLowerCase().trim()) {
          for (final log in task.timeLogs) {
            if (log.user.name == member.name || log.user.email == member.email) {
              totalSeconds += log.durationSeconds;
              memberLogs.add(log);
              final mod = log.module.isNotEmpty && log.module != 'General' ? log.module : task.module;
              final subMod = log.subModule.isNotEmpty && log.subModule != 'Default' ? log.subModule : task.subModule;
              moduleSecondsMap[mod] = (moduleSecondsMap[mod] ?? 0) + log.durationSeconds;
              subModuleSecondsMap['$mod > $subMod'] = (subModuleSecondsMap['$mod > $subMod'] ?? 0) + log.durationSeconds;
              tasksContributed.add(task.title);
            }
          }
          // Include live running timer if active for this member
          if (task.isTimerRunning && task.timerStartedAt != null && task.assignees.any((a) => a.name == member.name)) {
            final runningElapsed = DateTime.now().difference(task.timerStartedAt!).inSeconds;
            totalSeconds += runningElapsed;
            final mod = task.module;
            moduleSecondsMap[mod] = (moduleSecondsMap[mod] ?? 0) + runningElapsed;
            tasksContributed.add(task.title);
          }
        }
      }

      results.add({
        'member': member,
        'totalSeconds': totalSeconds,
        'worklogs': memberLogs,
        'moduleHours': moduleSecondsMap,
        'subModuleHours': subModuleSecondsMap,
        'tasksCount': tasksContributed.length,
        'tasksList': tasksContributed.toList(),
      });
    }

    return results;
  }

  List<Map<String, dynamic>> getModuleProjectTimesheet(String projectId) {
    final projController = Get.find<ProjectsController>();
    final proj = projController.projects.firstWhereOrNull((p) => p.id == projectId);
    if (proj == null) return [];

    final results = <Map<String, dynamic>>[];
    final modules = proj.modules;

    for (final mod in modules) {
      int totalSeconds = 0;
      final contributorSecondsMap = <String, int>{};
      final subModuleSecondsMap = <String, int>{};
      int moduleTasksCount = 0;

      for (final task in tasks) {
        if ((task.project?.id == proj.id || task.project?.name.toLowerCase().trim() == proj.name.toLowerCase().trim()) &&
            (task.module.toLowerCase().trim() == mod.name.toLowerCase().trim())) {
          moduleTasksCount++;
          for (final log in task.timeLogs) {
            totalSeconds += log.durationSeconds;
            contributorSecondsMap[log.user.name] = (contributorSecondsMap[log.user.name] ?? 0) + log.durationSeconds;
            final sub = log.subModule.isNotEmpty && log.subModule != 'Default' ? log.subModule : task.subModule;
            subModuleSecondsMap[sub] = (subModuleSecondsMap[sub] ?? 0) + log.durationSeconds;
          }
          if (task.isTimerRunning && task.timerStartedAt != null) {
            final running = DateTime.now().difference(task.timerStartedAt!).inSeconds;
            totalSeconds += running;
            if (task.assignees.isNotEmpty) {
              final aName = task.assignees.first.name;
              contributorSecondsMap[aName] = (contributorSecondsMap[aName] ?? 0) + running;
            }
          }
        }
      }

      results.add({
        'module': mod,
        'totalSeconds': totalSeconds,
        'tasksCount': moduleTasksCount,
        'contributors': contributorSecondsMap,
        'subModules': subModuleSecondsMap,
      });
    }

    return results;
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

    // Sync status change with backend API
    repository.updateAdminTask(
      current.id,
      UpdateTaskRequestModel(status: newStatus),
    ).then((res) {
      if (res.status && res.data != null) {
        final idx = tasks.indexWhere((t) => t.id == current.id);
        if (idx != -1) tasks[idx] = res.data!;
        if (selectedTask.value?.id == current.id) selectedTask.value = res.data!;
      } else if (!res.status) {
        Get.snackbar(
          'Status Update Error',
          res.message.isNotEmpty ? res.message : 'Failed to update status on server',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.errorColor,
          colorText: Colors.white,
        );
      }
    }).catchError((err) {
      Logger.e('TasksController => Error syncing task status to API: $err');
    });

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

  Future<bool> addSubTaskApi({
    required dynamic taskId,
    required String title,
    dynamic assignedTo,
    String? dueDate,
  }) async {
    if (title.trim().isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Subtask title is required!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
      );
      return false;
    }

    isAddingSubTask.value = true;
    try {
      final request = AddSubTaskRequestModel(
        title: title.trim(),
        assignedTo: assignedTo,
        dueDate: dueDate,
      );

      final response = await repository.addSubTask(taskId, request);

      if (response.status && response.data != null) {
        final newSub = response.data!;
        final current = selectedTask.value;
        if (current != null && current.id == taskId.toString()) {
          final updatedSubTasks = List<SubTask>.from(current.subTasks)..add(newSub);
          final updated = current.copyWith(subTasks: updatedSubTasks);
          selectedTask.value = updated;

          final idx = tasks.indexWhere((t) => t.id == current.id);
          if (idx != -1) {
            tasks[idx] = updated;
          }
        }

        Get.back(); // Dismiss dialog
        Get.snackbar(
          'Success',
          response.message.isNotEmpty ? response.message : 'Subtask added successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
        );
        return true;
      } else {
        Get.snackbar(
          'Error',
          response.message.isNotEmpty ? response.message : 'Failed to add subtask',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.errorColor,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      Logger.e('TasksController => addSubTaskApi error: $e');
      Get.snackbar(
        'Error',
        'An unexpected error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isAddingSubTask.value = false;
    }
  }

  void addSubTask(String title) {
    final current = selectedTask.value;
    if (current == null) return;
    addSubTaskApi(taskId: current.id, title: title);
  }


  // ── Employee and File Management for Task Creation ──
  Future<void> fetchEmployees() async {
    if (Get.isRegistered<ProjectsController>()) {
      final pCtrl = Get.find<ProjectsController>();
      if (pCtrl.employeesList.isNotEmpty) {
        employeesList.assignAll(pCtrl.employeesList);
        return;
      }
    }

    try {
      isLoadingEmployees.value = true;
      final response = await repository.getEmployees();
      if (response.status && response.data.isNotEmpty) {
        employeesList.assignAll(response.data);
      }
    } catch (e) {
      Logger.e('TasksController => Error fetching employees: $e');
    } finally {
      isLoadingEmployees.value = false;
    }
  }

  // ── Live Tasks Fetching API ──
  Future<void> fetchTasks({bool isRefresh = false}) async {
    if (!isRefresh && tasks.isEmpty) {
      isLoadingTasks.value = true;
    }
    tasksErrorMessage.value = '';
    try {
      final response = await repository.getAdminTasks(
        status: 'all',
        priority: 'all',
        perPage: 20,
      );

      if (response.status) {
        tasks.assignAll(response.tasks);
        totalTasksCount.value = response.total;
        Logger.d('TasksController => Loaded ${response.tasks.length} tasks from API, total: ${response.total}');
      } else {
        tasksErrorMessage.value = response.message;
        Logger.w('TasksController => Failed to load tasks from API: ${response.message}');
      }
    } catch (e) {
      tasksErrorMessage.value = e.toString();
      Logger.e('TasksController => Error fetching tasks: $e');
    } finally {
      isLoadingTasks.value = false;
    }
  }

  // ── Live Task Details API ──
  Future<TaskModel?> fetchTaskDetails(dynamic taskId) async {
    try {
      isLoadingTaskDetails.value = true;
      final response = await repository.getAdminTaskDetails(taskId);
      if (response.status && response.data != null) {
        selectedTask.value = response.data;
        final idx = tasks.indexWhere((t) => t.id == response.data!.id);
        if (idx != -1) {
          tasks[idx] = response.data!;
        }
        Logger.d('TasksController => Loaded task details for ID $taskId');
        return response.data;
      } else {
        Logger.w('TasksController => Failed to load task details: ${response.message}');
      }
    } catch (e) {
      Logger.e('TasksController => Error fetching task details: $e');
    } finally {
      isLoadingTaskDetails.value = false;
    }
    return null;
  }

  List<EmployeeModel> get filteredEmployeesList {
    if (employeeSearchQuery.value.trim().isEmpty) {
      return employeesList;
    }
    final q = employeeSearchQuery.value.toLowerCase().trim();
    return employeesList.where((emp) {
      return emp.name.toLowerCase().contains(q) ||
          emp.email.toLowerCase().contains(q) ||
          emp.employeeId.toLowerCase().contains(q) ||
          emp.designation.toLowerCase().contains(q) ||
          emp.department.toLowerCase().contains(q) ||
          emp.role.toLowerCase().contains(q);
    }).toList();
  }

  bool isEmployeeSelected(EmployeeModel emp) {
    // Explicitly read length to ensure GetX Obx observes changes to the lists
    selectedEmployees.length;

    final empIdStr = emp.id.toString().trim();
    final empCode = emp.employeeId.trim().toLowerCase();
    final empEmail = emp.email.trim().toLowerCase();

    return selectedEmployees.any((e) {
      final eIdStr = e.id.toString().trim();
      final eCode = e.employeeId.trim().toLowerCase();
      final eEmail = e.email.trim().toLowerCase();

      // 1. Primary: Match by unique primary database ID (e.g. 15 vs 14)
      if (empIdStr.isNotEmpty && empIdStr != '0' && eIdStr.isNotEmpty && eIdStr != '0') {
        return empIdStr == eIdStr;
      }

      // 2. Secondary: Match by unique Employee Code (e.g. "EMP-2026-015" vs "EMP-2026-014")
      if (empCode.isNotEmpty && eCode.isNotEmpty) {
        return empCode == eCode;
      }

      // 3. Fallback: Match by unique Email address
      if (empEmail.isNotEmpty && eEmail.isNotEmpty) {
        return empEmail == eEmail;
      }

      // 4. Object reference equality
      return identical(emp, e);
    });
  }

  void toggleEmployeeSelection(EmployeeModel emp) {
    final empIdStr = emp.id.toString().trim();
    final empCode = emp.employeeId.trim().toLowerCase();
    final empEmail = emp.email.trim().toLowerCase();

    final existingIdx = selectedEmployees.indexWhere((e) {
      final eIdStr = e.id.toString().trim();
      final eCode = e.employeeId.trim().toLowerCase();
      final eEmail = e.email.trim().toLowerCase();

      // 1. Primary: Match by unique primary database ID (e.g. 15 vs 14)
      if (empIdStr.isNotEmpty && empIdStr != '0' && eIdStr.isNotEmpty && eIdStr != '0') {
        return empIdStr == eIdStr;
      }

      // 2. Secondary: Match by unique Employee Code (e.g. "EMP-2026-015" vs "EMP-2026-014")
      if (empCode.isNotEmpty && eCode.isNotEmpty) {
        return empCode == eCode;
      }

      // 3. Fallback: Match by unique Email address
      if (empEmail.isNotEmpty && eEmail.isNotEmpty) {
        return empEmail == eEmail;
      }

      return identical(emp, e);
    });

    if (existingIdx != -1) {
      // Unselect only this specific employee
      selectedEmployees.removeAt(existingIdx);
      if (existingIdx < tempAssignees.length) {
        tempAssignees.removeAt(existingIdx);
      }
    } else {
      // Add employee to multiple selection
      selectedEmployees.add(emp);
      tempAssignees.add(AppUser(
        name: emp.name,
        email: emp.email,
        avatarUrl: emp.profilePic != null && emp.profilePic!.isNotEmpty
            ? (emp.profilePic!.startsWith('http') ? emp.profilePic! : '${AppConstants.baseUrl}/storage/${emp.profilePic}')
            : 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
      ));
    }

    selectedEmployees.refresh();
    tempAssignees.refresh();
  }

  Future<void> pickRealFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'png', 'jpg', 'jpeg', 'webp', 'zip', 'txt', 'csv', 'xlsx'],
      );

      if (result != null && result.files.isNotEmpty) {
        for (final file in result.files) {
          if (!attachedRealFiles.any((f) => f.name == file.name && f.size == file.size)) {
            attachedRealFiles.add(file);
            tempAttachments.add(file.name);
          }
        }
      }
    } catch (e) {
      Logger.e('TasksController => Error picking files: $e');
      Get.snackbar(
        'Error',
        'Could not access files: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
      );
    }
  }

  void removeAttachedFile(int index) {
    if (index >= 0 && index < attachedRealFiles.length) {
      final f = attachedRealFiles.removeAt(index);
      tempAttachments.remove(f.name);
    }
  }

  // ── Admin Task CRUD Lifecycle ──
  void clearCreationForm() {
    titleController.clear();
    descriptionController.clear();
    customCategoryController.clear();
    selectedCategory.value = 'UI/UX Design';
    isCustomCategory.value = false;
    selectedPriority.value = 'Medium';
    selectedStatus.value = 'Pending';
    startDate.value = DateTime.now();
    dueDate.value = DateTime.now().add(const Duration(days: 14));
    selectedDeadline.value = DateTime.now().add(const Duration(days: 14));
    estimatedHours.value = 5;
    estimatedMinutes.value = 30;
    selectedProject.value = null;
    selectedProjectName.value = 'None';
    selectedModuleName.value = 'General';
    selectedSubModuleName.value = 'Default';
    selectedEmployees.clear();
    tempAssignees.clear();
    attachedRealFiles.clear();
    tempAttachments.clear();
    employeeSearchQuery.value = '';
  }

  void populateTaskForm(TaskModel task) {
    titleController.text = task.title;
    descriptionController.text = task.description;
    selectedPriority.value = task.priority;
    selectedStatus.value = mapTaskStatusToApi(task.status);
    selectedDeadline.value = (task.dueDate != null && task.dueDate!.isNotEmpty)
        ? (DateTime.tryParse(task.dueDate!) ?? task.deadline)
        : task.deadline;
    dueDate.value = selectedDeadline.value;
    startDate.value = (task.startDate != null && task.startDate!.isNotEmpty)
        ? (DateTime.tryParse(task.startDate!) ?? DateTime.now())
        : DateTime.now();

    if (task.category != null && task.category!.isNotEmpty) {
      selectedCategory.value = task.category!;
    }

    if (task.estimatedHours != null && task.estimatedHours!.isNotEmpty) {
      final regHours = RegExp(r'(\d+)\s*h', caseSensitive: false);
      final regMins = RegExp(r'(\d+)\s*m', caseSensitive: false);
      final hMatch = regHours.firstMatch(task.estimatedHours!);
      final mMatch = regMins.firstMatch(task.estimatedHours!);
      if (hMatch != null) {
        estimatedHours.value = int.tryParse(hMatch.group(1)!) ?? 0;
      }
      if (mMatch != null) {
        estimatedMinutes.value = int.tryParse(mMatch.group(1)!) ?? 0;
      }
    }

    tempAssignees.assignAll(task.assignees);
    tempAttachments.assignAll(task.attachments);
    selectedProjectName.value = task.project?.name ?? 'None';
    selectedModuleName.value = task.module;
    selectedSubModuleName.value = task.subModule;
    if (task.project != null) {
      selectedProject.value = task.project;
    }

    selectedEmployees.clear();
    for (final a in task.assignees) {
      final aEmpId = a.employeeId ?? '';
      final match = employeesList.firstWhereOrNull((e) =>
          (aEmpId.isNotEmpty && e.id.toString() == aEmpId) ||
          e.email.toLowerCase() == a.email.toLowerCase());
      if (match != null) {
        if (!selectedEmployees.any((se) => se.id.toString() == match.id.toString())) {
          selectedEmployees.add(match);
        }
      } else {
        selectedEmployees.add(
          EmployeeModel.fromJson({
            'id': aEmpId.isNotEmpty ? aEmpId : 'emp_${a.name.hashCode}',
            'employee_id': aEmpId,
            'name': a.name,
            'email': a.email,
            'designation': a.designation ?? 'Team Member',
            'avatar': a.avatarUrl,
          }),
        );
      }
    }
  }

  Future<bool> createTaskApi() async {
    final title = titleController.text.trim();
    if (title.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Task Title is required!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
      );
      return false;
    }

    if (title.length < 3) {
      Get.snackbar(
        'Validation Error',
        'Task Title must be at least 3 characters!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
      );
      return false;
    }

    final desc = descriptionController.text.trim();
    if (desc.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Task Description is required!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
      );
      return false;
    }

    if (selectedProject.value == null) {
      Get.snackbar(
        'Validation Error',
        'Please select a Project for this task!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
      );
      return false;
    }

    final category = isCustomCategory.value
        ? customCategoryController.text.trim()
        : selectedCategory.value.trim();
    if (category.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Category is required!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
      );
      return false;
    }

    if (dueDate.value.isBefore(startDate.value)) {
      Get.snackbar(
        'Validation Error',
        'Due Date cannot be earlier than Start Date!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
      );
      return false;
    }

    if (estimatedHours.value == 0 && estimatedMinutes.value == 0) {
      Get.snackbar(
        'Validation Error',
        'Estimated Hours must be greater than 0!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
      );
      return false;
    }

    if (selectedEmployees.isEmpty && tempAssignees.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please assign at least one employee to this task!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
      );
      return false;
    }

    isCreatingTask.value = true;

    try {
      final sDateStr = DateFormat('yyyy-MM-dd').format(startDate.value);
      final dDateStr = DateFormat('yyyy-MM-dd').format(dueDate.value);

      // Collect employee IDs
      List<String> empIds = selectedEmployees
          .map((e) => e.id.toString())
          .where((id) => id.isNotEmpty)
          .toList();

      // Fallback if user selected through legacy list
      if (empIds.isEmpty && tempAssignees.isNotEmpty) {
        if (employeesList.isNotEmpty) {
          for (final a in tempAssignees) {
            final match = employeesList.firstWhereOrNull((e) => e.name == a.name || e.email == a.email);
            if (match != null && !empIds.contains(match.id)) {
              empIds.add(match.id);
            }
          }
        }
      }

      // Collect file paths
      final filePaths = attachedRealFiles
          .map((f) => f.path)
          .whereType<String>()
          .where((p) => p.isNotEmpty)
          .toList();

      // Retrieve user_id from stored user_data if available
      String? currentUserId = '1';
      final userDataStr = SharedPrefs.getString(AppConstants.userData);
      if (userDataStr != null && userDataStr.isNotEmpty) {
        try {
          final uMap = jsonDecode(userDataStr);
          if (uMap is Map && uMap['id'] != null) {
            currentUserId = uMap['id'].toString();
          }
        } catch (_) {}
      }

      final request = CreateTaskRequestModel(
        taskName: title,
        description: desc,
        category: category,
        priority: selectedPriority.value,
        status: selectedStatus.value,
        startDate: sDateStr,
        dueDate: dDateStr,
        estimatedHours: formattedEstimatedHours,
        projectId: selectedProject.value!.id.toString(),
        userId: currentUserId,
        employeeIds: empIds,
        filePaths: filePaths,
      );

      final response = await repository.createTask(request);

      if (response.status && response.data != null) {
        final newTask = response.data!.toTaskModel();
        tasks.insert(0, newTask);
        _syncTaskStatusWithProject(newTask);
        clearCreationForm();
        fetchTasks(isRefresh: true);
        Get.back();
        Get.snackbar(
          'Success',
          response.message.isNotEmpty ? response.message : 'Task created successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
        );
        return true;
      } else {
        Get.snackbar(
          'Error',
          response.message.isNotEmpty ? response.message : 'Failed to create task.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.errorColor,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      Logger.e('TasksController => createTaskApi error: $e');
      Get.snackbar(
        'Error',
        'An unexpected error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isCreatingTask.value = false;
    }
  }

  void saveTask() {
    createTaskApi();
  }

  Future<bool> updateExistingTask(String taskId) async {
    final title = titleController.text.trim();
    if (title.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Task Title is required!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
      );
      return false;
    }

    if (dueDate.value.isBefore(startDate.value)) {
      Get.snackbar(
        'Validation Error',
        'Due Date cannot be earlier than Start Date!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
      );
      return false;
    }

    // Collect employee IDs (convert to int if possible)
    List<dynamic> empIds = selectedEmployees
        .map((e) => int.tryParse(e.id.toString()) ?? e.id.toString())
        .toList();

    // Fallback if user selected through legacy list
    if (empIds.isEmpty && tempAssignees.isNotEmpty) {
      for (final a in tempAssignees) {
        final aId = a.employeeId;
        if (aId != null && aId.isNotEmpty) {
          empIds.add(int.tryParse(aId) ?? aId);
        } else if (employeesList.isNotEmpty) {
          final match = employeesList.firstWhereOrNull((e) => e.name == a.name || e.email == a.email);
          if (match != null) {
            empIds.add(int.tryParse(match.id.toString()) ?? match.id);
          }
        }
      }
    }

    isUpdatingTask.value = true;

    try {
      final sDateStr = DateFormat('yyyy-MM-dd').format(startDate.value);
      final dDateStr = DateFormat('yyyy-MM-dd').format(dueDate.value);
      final category = isCustomCategory.value
          ? customCategoryController.text.trim()
          : selectedCategory.value.trim();

      final request = UpdateTaskRequestModel(
        taskName: title,
        description: descriptionController.text.trim().isNotEmpty
            ? descriptionController.text.trim()
            : null,
        category: category.isNotEmpty ? category : null,
        priority: selectedPriority.value,
        status: selectedStatus.value,
        startDate: sDateStr,
        dueDate: dDateStr,
        estimatedHours: formattedEstimatedHours,
        projectId: selectedProject.value?.id,
        employeeIds: empIds.isNotEmpty ? empIds : null,
      );

      final response = await repository.updateAdminTask(taskId, request);

      if (response.status && response.data != null) {
        final updatedTask = response.data!;
        final idx = tasks.indexWhere((t) => t.id == taskId);
        if (idx != -1) {
          tasks[idx] = updatedTask;
        } else {
          tasks.insert(0, updatedTask);
        }

        if (selectedTask.value?.id == taskId) {
          selectedTask.value = updatedTask;
        }

        _syncTaskStatusWithProject(updatedTask);
        clearCreationForm();
        fetchTasks(isRefresh: true);
        Get.back();
        Get.snackbar(
          'Success',
          response.message.isNotEmpty ? response.message : 'Task updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
        );
        return true;
      } else {
        Get.snackbar(
          'Error',
          response.message.isNotEmpty ? response.message : 'Failed to update task',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.errorColor,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      Logger.e('TasksController => updateExistingTask error: $e');
      Get.snackbar(
        'Error',
        'An unexpected error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isUpdatingTask.value = false;
    }
  }

  Future<bool> deleteTask(String id, {bool fromDetail = false}) async {
    isDeletingTask.value = true;
    try {
      final response = await repository.deleteAdminTask(id);

      if (response.status) {
        tasks.removeWhere((t) => t.id == id);
        if (selectedTask.value?.id == id) {
          selectedTask.value = null;
        }

        // Dismiss confirmation dialog
        Get.back();

        // If invoked from the task details screen, pop back to task list
        if (fromDetail) {
          Get.back();
        }

        Get.snackbar(
          'Task Deleted',
          response.message.isNotEmpty ? response.message : 'Task deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
        );

        fetchTasks(isRefresh: true);
        return true;
      } else {
        Get.back();
        Get.snackbar(
          'Error',
          response.message.isNotEmpty ? response.message : 'Failed to delete task',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.errorColor,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      Logger.e('TasksController => deleteTask error: $e');
      Get.back();
      Get.snackbar(
        'Error',
        'An unexpected error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isDeletingTask.value = false;
    }
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

    if (WidgetsBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _syncTaskStatusWithProject(task));
      return;
    }

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
