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
  final RxBool isAddingComment = false.obs;
  final Rxn<PlatformFile> commentAttachedFile = Rxn<PlatformFile>();

  // Helper getter for currently logged-in user
  AppUser get currentLoggedInUser {
    try {
      final userDataString = SharedPrefs.getString(AppConstants.userData);
      if (userDataString != null && userDataString.isNotEmpty) {
        final u = jsonDecode(userDataString);
        return AppUser(
          name: u['name']?.toString() ?? 'User',
          email: u['email']?.toString() ?? '',
          avatarUrl: u['avatar']?.toString() ?? '',
          designation: u['role']?.toString() ?? 'Employee',
        );
      }
    } catch (_) {}
    return const AppUser(name: 'User', email: '', avatarUrl: '');
  }

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

      if (employeeTaskScope.value == 'My Tasks') {
        // Scope strictly to tasks assigned to current employee
        final assigned = results.where((t) {
          if (myEmail.isNotEmpty || myName.isNotEmpty) {
            return t.assignees.any((a) =>
                (myEmail.isNotEmpty && a.email.toLowerCase().trim() == myEmail) ||
                (myName.isNotEmpty && a.name.toLowerCase().trim() == myName));
          }
          return true;
        }).toList();

        results = assigned;
      } else {
        // 'All Project Tasks / Project History': All tasks belonging to projects where this employee is a member!
        final projController = Get.isRegistered<ProjectsController>() ? Get.find<ProjectsController>() : null;
        if (projController != null) {
          results = results.where((t) {
            if (t.project == null) return true;
            final proj = projController.projects.firstWhereOrNull((p) => p.id == t.project!.id || p.name == t.project!.name);
            if (proj == null) return true;
            return proj.teamMembers.any((m) =>
                (myEmail.isNotEmpty && m.email.toLowerCase().trim() == myEmail) ||
                (myName.isNotEmpty && m.name.toLowerCase().trim() == myName));
          }).toList();
        }
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

  final RxBool isStartingTimer = false.obs;

  // ── Employee Live Timer Operations ──
  Future<bool> startTaskTimer(String taskId, {String? note}) async {
    isStartingTimer.value = true;
    try {
      final response = await repository.startAdminTask(taskId, note: note);
      if (response.status && response.data != null) {
        final serverTask = response.data!;

        // Find existing task
        final idx = tasks.indexWhere((t) => t.id == taskId || t.id == serverTask.id);

        // Check if any other task is running locally and pause it
        for (int i = 0; i < tasks.length; i++) {
          if ((tasks[i].id != taskId && tasks[i].id != serverTask.id) && tasks[i].isTimerRunning) {
            tasks[i] = tasks[i].copyWith(isTimerRunning: false, timerStartedAt: null);
          }
        }

        final existingTask = idx != -1 ? tasks[idx] : selectedTask.value;
        final mergedTask = serverTask.copyWith(
          subTasks: serverTask.subTasks.isNotEmpty ? serverTask.subTasks : existingTask?.subTasks,
          comments: serverTask.comments.isNotEmpty ? serverTask.comments : existingTask?.comments,
          attachments: serverTask.attachments.isNotEmpty ? serverTask.attachments : existingTask?.attachments,
          timeLogs: serverTask.timeLogs.isNotEmpty ? serverTask.timeLogs : existingTask?.timeLogs,
        );

        if (idx != -1) {
          tasks[idx] = mergedTask;
        } else {
          tasks.insert(0, mergedTask);
        }

        if (selectedTask.value?.id == taskId || selectedTask.value?.id == serverTask.id) {
          selectedTask.value = mergedTask;
        }

        _syncTaskStatusWithProject(mergedTask);

        Get.snackbar(
          'Timer Started',
          response.message.isNotEmpty ? response.message : 'Task timer started successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        return true;
      } else {
        Get.snackbar(
          'Failed',
          response.message.isNotEmpty ? response.message : 'Could not start task timer',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.errorColor,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      Logger.e('TasksController => Error in startTaskTimer: $e');
      Get.snackbar(
        'Error',
        'Something went wrong while starting timer: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isStartingTimer.value = false;
    }
  }

  final RxBool isPausingTimer = false.obs;

  Future<bool> pauseTaskTimer(String taskId, {String? note, bool showSnackbar = true}) async {
    isPausingTimer.value = true;
    try {
      final response = await repository.pauseAdminTask(taskId, note: note);
      if (response.status && response.data != null) {
        final serverTask = response.data!;

        final idx = tasks.indexWhere((t) => t.id == taskId || t.id == serverTask.id);
        final existingTask = idx != -1 ? tasks[idx] : selectedTask.value;

        final mergedTask = serverTask.copyWith(
          isTimerRunning: false,
          timerStartedAt: null,
          subTasks: serverTask.subTasks.isNotEmpty ? serverTask.subTasks : existingTask?.subTasks,
          comments: serverTask.comments.isNotEmpty ? serverTask.comments : existingTask?.comments,
          attachments: serverTask.attachments.isNotEmpty ? serverTask.attachments : existingTask?.attachments,
          timeLogs: serverTask.timeLogs.isNotEmpty ? serverTask.timeLogs : existingTask?.timeLogs,
        );

        if (idx != -1) {
          tasks[idx] = mergedTask;
        }

        if (selectedTask.value?.id == taskId || selectedTask.value?.id == serverTask.id) {
          selectedTask.value = mergedTask;
        }

        _syncTaskStatusWithProject(mergedTask);

        if (showSnackbar) {
          Get.snackbar(
            'Timer Paused',
            response.message.isNotEmpty ? response.message : 'Task timer paused successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF3B82F6),
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
        }
        return true;
      } else {
        if (showSnackbar) {
          Get.snackbar(
            'Failed',
            response.message.isNotEmpty ? response.message : 'Failed to pause timer',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.errorColor,
            colorText: Colors.white,
          );
        }
        return false;
      }
    } catch (e) {
      Logger.e('TasksController => Error in pauseTaskTimer: $e');
      if (showSnackbar) {
        Get.snackbar(
          'Error',
          'Something went wrong while pausing timer: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.errorColor,
          colorText: Colors.white,
        );
      }
      return false;
    } finally {
      isPausingTimer.value = false;
    }
  }

  final RxBool isStoppingTimer = false.obs;

  Future<bool> stopTaskTimer(String taskId, {String? note, bool showSnackbar = true}) async {
    isStoppingTimer.value = true;
    try {
      final response = await repository.stopAdminTask(taskId, note: note);
      if (response.status && response.data != null) {
        final serverTask = response.data!;

        final idx = tasks.indexWhere((t) => t.id == taskId || t.id == serverTask.id);
        final existingTask = idx != -1 ? tasks[idx] : selectedTask.value;

        final mergedTask = serverTask.copyWith(
          isTimerRunning: false,
          timerStartedAt: null,
          subTasks: serverTask.subTasks.isNotEmpty ? serverTask.subTasks : existingTask?.subTasks,
          comments: serverTask.comments.isNotEmpty ? serverTask.comments : existingTask?.comments,
          attachments: serverTask.attachments.isNotEmpty ? serverTask.attachments : existingTask?.attachments,
          timeLogs: serverTask.timeLogs.isNotEmpty ? serverTask.timeLogs : existingTask?.timeLogs,
        );

        if (idx != -1) {
          tasks[idx] = mergedTask;
        }

        if (selectedTask.value?.id == taskId || selectedTask.value?.id == serverTask.id) {
          selectedTask.value = mergedTask;
        }

        _syncTaskStatusWithProject(mergedTask);

        if (showSnackbar) {
          Get.snackbar(
            'Timer Stopped',
            response.message.isNotEmpty ? response.message : 'Task timer stopped successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFFEF4444),
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
        }
        return true;
      } else {
        if (showSnackbar) {
          Get.snackbar(
            'Failed',
            response.message.isNotEmpty ? response.message : 'Failed to stop timer',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.errorColor,
            colorText: Colors.white,
          );
        }
        return false;
      }
    } catch (e) {
      Logger.e('TasksController => Error in stopTaskTimer: $e');
      if (showSnackbar) {
        Get.snackbar(
          'Error',
          'Something went wrong while stopping timer: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.errorColor,
          colorText: Colors.white,
        );
      }
      return false;
    } finally {
      isStoppingTimer.value = false;
    }
  }

  final RxBool isSubmittingForTesting = false.obs;

  Future<bool> submitTaskForTesting(
    String taskId, {
    String? remarks,
    String? filePath,
    bool showSnackbar = true,
  }) async {
    isSubmittingForTesting.value = true;
    try {
      final response = await repository.submitTaskForTesting(
        taskId,
        remarks: remarks,
        filePath: filePath,
      );

      if (response.status && response.data != null) {
        final serverTask = response.data!;

        final idx = tasks.indexWhere((t) => t.id == taskId || t.id == serverTask.id);
        final existingTask = idx != -1 ? tasks[idx] : selectedTask.value;

        final mergedTask = serverTask.copyWith(
          isTimerRunning: false,
          timerStartedAt: null,
          subTasks: serverTask.subTasks.isNotEmpty ? serverTask.subTasks : existingTask?.subTasks,
          comments: serverTask.comments.isNotEmpty ? serverTask.comments : existingTask?.comments,
          attachments: serverTask.attachments.isNotEmpty ? serverTask.attachments : existingTask?.attachments,
          attachmentDetails: serverTask.attachmentDetails.isNotEmpty ? serverTask.attachmentDetails : existingTask?.attachmentDetails,
          timeLogs: serverTask.timeLogs.isNotEmpty ? serverTask.timeLogs : existingTask?.timeLogs,
        );

        if (idx != -1) {
          tasks[idx] = mergedTask;
        }

        if (selectedTask.value?.id == taskId || selectedTask.value?.id == serverTask.id) {
          selectedTask.value = mergedTask;
        }

        _syncTaskStatusWithProject(mergedTask);

        if (showSnackbar) {
          Get.snackbar(
            'Submitted For Testing',
            response.message.isNotEmpty ? response.message : 'Task submitted for testing successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF6366F1),
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
        }
        return true;
      } else {
        if (showSnackbar) {
          Get.snackbar(
            'Failed',
            response.message.isNotEmpty ? response.message : 'Could not submit task for testing',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.errorColor,
            colorText: Colors.white,
          );
        }
        return false;
      }
    } catch (e) {
      Logger.e('TasksController => Error in submitTaskForTesting: $e');
      if (showSnackbar) {
        Get.snackbar(
          'Error',
          'Something went wrong while submitting task for testing: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.errorColor,
          colorText: Colors.white,
        );
      }
      return false;
    } finally {
      isSubmittingForTesting.value = false;
    }
  }

  // ── Status Pipeline Transitions ──
  Future<void> moveToTesting(String taskId, {String? note, String? filePath}) async {
    final success = await submitTaskForTesting(taskId, remarks: note, filePath: filePath);
    if (!success) {
      // Local fallback in case network error occurs
      final idx = tasks.indexWhere((t) => t.id == taskId);
      if (idx == -1) return;

      final current = tasks[idx];

      int addedSeconds = 0;
      List<TaskTimeLog> updatedLogs = List<TaskTimeLog>.from(current.timeLogs);
      if (current.isTimerRunning && current.timerStartedAt != null) {
        addedSeconds = DateTime.now().difference(current.timerStartedAt!).inSeconds;
        final currentUser = current.assignees.isNotEmpty ? current.assignees.first : currentLoggedInUser;
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

      final currentUser = current.assignees.isNotEmpty ? current.assignees.first : currentLoggedInUser;

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
    }
  }

  void approveAndCompleteTask(String taskId, {String? managerNote}) {
    final idx = tasks.indexWhere((t) => t.id == taskId);
    if (idx == -1) return;

    final current = tasks[idx];
    final currentUser = currentLoggedInUser;

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
    final currentUser = currentLoggedInUser;

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
    final currentUser = current.assignees.isNotEmpty ? current.assignees.first : currentLoggedInUser;

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
    final currentUser = currentLoggedInUser;

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

    final currentUser = currentLoggedInUser;

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

  // ── Comments API ──
  Future<bool> addComment(String commentText, {String? filePath}) async {
    final current = selectedTask.value;
    if (current == null) return false;
    final trimmed = commentText.trim();
    if (trimmed.isEmpty && (filePath == null || filePath.isEmpty)) {
      return false;
    }

    try {
      isAddingComment.value = true;

      // Extract current user ID
      String? currentUserId;
      final userDataStr = SharedPrefs.getString(AppConstants.userData);
      if (userDataStr != null && userDataStr.isNotEmpty) {
        try {
          final uMap = jsonDecode(userDataStr);
          if (uMap is Map && uMap['id'] != null) {
            currentUserId = uMap['id'].toString();
          }
        } catch (_) {}
      }

      final response = await repository.addTaskComment(
        taskId: current.id,
        comment: trimmed,
        userId: currentUserId ?? '20',
        filePath: filePath,
      );

      if (response.status && response.data != null) {
        final newComment = response.data!;
        final updatedComments = List<TaskComment>.from(current.comments)..add(newComment);
        final updated = current.copyWith(comments: updatedComments);

        final idx = tasks.indexWhere((t) => t.id == current.id);
        if (idx != -1) {
          tasks[idx] = updated;
        }
        selectedTask.value = updated;
        commentAttachedFile.value = null;

        // Refresh full comments list from server
        fetchTaskComments(current.id);

        Get.snackbar(
          'Success',
          response.message.isNotEmpty ? response.message : 'Comment added successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        return true;
      } else {
        Get.snackbar(
          'Error',
          response.message.isNotEmpty ? response.message : 'Failed to add comment',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFEF4444),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add comment: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return false;
    } finally {
      isAddingComment.value = false;
    }
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
        // Also fetch live comments from GET /api/admin/tasks/{id}/comments
        fetchTaskComments(taskId);
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

  final RxBool isLoadingComments = false.obs;

  Future<List<TaskComment>> fetchTaskComments(dynamic taskId) async {
    isLoadingComments.value = true;
    try {
      final response = await repository.getTaskComments(taskId);
      if (response.status) {
        final comments = response.data;
        final current = selectedTask.value;
        if (current != null && (current.id == taskId.toString() || current.id == taskId)) {
          final updated = current.copyWith(comments: comments);
          selectedTask.value = updated;

          final idx = tasks.indexWhere((t) => t.id == current.id);
          if (idx != -1) {
            tasks[idx] = updated;
          }
        }
        return comments;
      } else {
        Logger.w('TasksController => Failed to load task comments: ${response.message}');
      }
    } catch (e) {
      Logger.e('TasksController => Error fetching task comments: $e');
    } finally {
      isLoadingComments.value = false;
    }
    return [];
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
