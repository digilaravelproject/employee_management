import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../projects/controllers/projects_controller.dart';
import '../../role_permissions/models/role_permission_models.dart';
import '../models/task_model.dart';

class TasksController extends GetxController {
  final RxList<TaskModel> tasks = <TaskModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedFilter = 'All'.obs; // All, My Tasks, Assigned, Completed

  // Currently viewed task
  final Rxn<TaskModel> selectedTask = Rxn<TaskModel>();

  // Task Creation Form State
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final RxString selectedPriority = 'Medium'.obs;
  final RxString selectedStatus = 'Pending'.obs;
  final Rx<DateTime> selectedDeadline = DateTime.now().add(const Duration(days: 7)).obs;
  final Rxn<AppUser> selectedSingleAssignee = Rxn<AppUser>();
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
  }

  void _initializeDummyTasks() {
    final projController = Get.find<ProjectsController>();
    final emps = projController.allEmployees;
    final projs = projController.projects;

    final websiteRedesign = projs.isNotEmpty ? projs[0] : null;
    final mobileApp = projs.length > 1 ? projs[1] : null;
    final crmIntegration = projs.length > 2 ? projs[2] : null;

    // Task 1: UI/UX Design
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
      TaskComment(
        id: 'c3',
        user: emps[3], // David Wilson (Project Manager)
        text: 'Great progress! Please check the comments I added on the design.',
        timestamp: DateTime(2024, 4, 14, 15, 45),
        userRole: 'Project Manager',
      ),
    ];

    final t1Timeline = [
      TaskStatusUpdate(
        id: 'u1',
        status: 'Pending',
        title: 'Pending',
        description: 'Task is created',
        timestamp: DateTime(2024, 4, 10, 10, 30),
        user: emps[0], // John Smith
      ),
      TaskStatusUpdate(
        id: 'u2',
        status: 'In Progress',
        title: 'In Progress',
        description: 'Work has been started\nStarted working on wireframes and initial design.',
        timestamp: DateTime(2024, 4, 11, 9, 15),
        user: emps[1], // Sarah Johnson
      ),
      TaskStatusUpdate(
        id: 'u3',
        status: 'Review',
        title: 'Review',
        description: 'Task is under review\nPlease review the latest progress and provide feedback.',
        timestamp: DateTime(2024, 4, 14, 15, 40),
        user: emps[3], // David Wilson
      ),
      TaskStatusUpdate(
        id: 'u4',
        status: 'Completed',
        title: 'Completed',
        description: 'Task has been completed\nAll screens designed and submitted for review.',
        timestamp: DateTime(2024, 4, 15, 17, 20),
        user: emps[1], // Sarah Johnson
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
        status: 'In Progress',
        subTasks: t1SubTasks,
        comments: t1Comments,
        statusUpdates: t1Timeline,
        attachments: ['Wireframes_v1.pdf', 'Design_System_v2.fig'],
      ),
      TaskModel(
        id: 'task_2',
        title: 'API Integration',
        description: 'Integrate payment gateway with backend APIs and verify secure callbacks.',
        assignees: [emps[2]], // Michael Brown
        project: mobileApp,
        priority: 'Medium',
        deadline: DateTime(2024, 5, 20),
        status: 'Pending',
        subTasks: [],
        comments: [],
        statusUpdates: [
          TaskStatusUpdate(
            id: 'api_u1',
            status: 'Pending',
            title: 'Pending',
            description: 'Task is created and assigned.',
            timestamp: DateTime(2024, 5, 12, 10, 00),
            user: emps[0],
          )
        ],
        attachments: [],
      ),
      TaskModel(
        id: 'task_3',
        title: 'Database Optimization',
        description: 'Optimize database queries and indexes to improve query response times under high payload.',
        assignees: [emps[3]], // David Wilson
        project: crmIntegration,
        priority: 'Low',
        deadline: DateTime(2024, 5, 25),
        status: 'Pending',
        subTasks: [],
        comments: [],
        statusUpdates: [
          TaskStatusUpdate(
            id: 'db_u1',
            status: 'Pending',
            title: 'Pending',
            description: 'Task is created and assigned.',
            timestamp: DateTime(2024, 5, 13, 11, 00),
            user: emps[0],
          )
        ],
        attachments: [],
      ),
      TaskModel(
        id: 'task_4',
        title: 'Bug Fixing',
        description: 'Fix reported crash issues and API failures in the mobile app release candidate.',
        assignees: [emps[4]], // Emily Davis
        project: mobileApp,
        priority: 'High',
        deadline: DateTime(2024, 5, 10),
        status: 'Completed',
        subTasks: [
          SubTask(id: 'st_bug1', title: 'Fix auth crash', isCompleted: true, date: DateTime(2024, 5, 8)),
          SubTask(id: 'st_bug2', title: 'Fix notification latency', isCompleted: true, date: DateTime(2024, 5, 9)),
        ],
        comments: [],
        statusUpdates: [
          TaskStatusUpdate(
            id: 'bug_u1',
            status: 'Completed',
            title: 'Completed',
            description: 'All release candidate bugs verified and patched.',
            timestamp: DateTime(2024, 5, 9, 16, 30),
            user: emps[4],
          )
        ],
        attachments: ['CrashLog_v1.txt'],
      ),
      TaskModel(
        id: 'task_5',
        title: 'User Testing',
        description: 'Perform exhaustive user testing sessions on new beta features with 10 test user profiles.',
        assignees: [emps[5]], // James Anderson
        project: websiteRedesign,
        priority: 'Medium',
        deadline: DateTime(2024, 5, 18),
        status: 'In Progress',
        subTasks: [],
        comments: [],
        statusUpdates: [
          TaskStatusUpdate(
            id: 'test_u1',
            status: 'In Progress',
            title: 'In Progress',
            description: 'User testing panel set up and ready.',
            timestamp: DateTime(2024, 5, 14, 14, 00),
            user: emps[5],
          )
        ],
        attachments: [],
      ),
    ]);
  }

  // Filtered task list feed
  List<TaskModel> get filteredTasks {
    List<TaskModel> results = tasks;

    // Filter by tab selection
    if (selectedFilter.value == 'Completed') {
      results = results.where((t) => t.status == 'Completed').toList();
    } else if (selectedFilter.value == 'My Tasks') {
      // Mock 'My Tasks' as those assigned to Sarah Johnson (emps[1])
      final projController = Get.find<ProjectsController>();
      final myUser = projController.allEmployees[1];
      results = results.where((t) => t.assignees.contains(myUser)).toList();
    } else if (selectedFilter.value == 'Assigned') {
      // Mock 'Assigned' as tasks assigned to others (not Sarah Johnson)
      final projController = Get.find<ProjectsController>();
      final myUser = projController.allEmployees[1];
      results = results.where((t) => t.assignees.isNotEmpty && !t.assignees.contains(myUser)).toList();
    }

    // Filter by search query
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      results = results.where((t) => t.title.toLowerCase().contains(q) || t.description.toLowerCase().contains(q)).toList();
    }

    return results;
  }

  void selectTask(TaskModel task) {
    selectedTask.value = task;
  }

  // Comments Operations
  void addComment(String commentText) {
    final current = selectedTask.value;
    if (current == null || commentText.trim().isEmpty) return;

    final projController = Get.find<ProjectsController>();
    final currentUser = projController.allEmployees[0]; // John Smith (Manager)

    final newComment = TaskComment(
      id: 'comment_${DateTime.now().millisecondsSinceEpoch}',
      user: currentUser,
      text: commentText.trim(),
      timestamp: DateTime.now(),
      userRole: 'Manager',
    );

    final updatedComments = List<TaskComment>.from(current.comments)..add(newComment);
    final updated = current.copyWith(comments: updatedComments);

    // Update in list
    final idx = tasks.indexWhere((t) => t.id == current.id);
    if (idx != -1) {
      tasks[idx] = updated;
    }
    selectedTask.value = updated;
  }

  // Toggle Sub-Task checkbox
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

    // Update in list
    final idx = tasks.indexWhere((t) => t.id == current.id);
    if (idx != -1) {
      tasks[idx] = updated;
    }
    selectedTask.value = updated;
  }

  // Add new Sub-Task
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

    // Update in list
    final idx = tasks.indexWhere((t) => t.id == current.id);
    if (idx != -1) {
      tasks[idx] = updated;
    }
    selectedTask.value = updated;
  }

  // Update Task Status & Append to status updates timeline track
  void updateTaskStatus(String newStatus, String comment) {
    final current = selectedTask.value;
    if (current == null) return;

    final projController = Get.find<ProjectsController>();
    final currentUser = projController.allEmployees[0]; // John Smith (Manager)

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

    final updatedUpdates = List<TaskStatusUpdate>.from(current.statusUpdates)..add(newUpdate);
    final updated = current.copyWith(
      status: newStatus,
      statusUpdates: updatedUpdates,
    );

    // Update in list
    final idx = tasks.indexWhere((t) => t.id == current.id);
    if (idx != -1) {
      tasks[idx] = updated;
    }
    selectedTask.value = updated;

    Get.snackbar(
      'Status Updated',
      'Task status successfully changed to $newStatus',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
    );
  }

  // Task Creation Lifecycle
  void clearCreationForm() {
    titleController.clear();
    descriptionController.clear();
    selectedPriority.value = 'Medium';
    selectedStatus.value = 'Pending';
    selectedDeadline.value = DateTime.now().add(const Duration(days: 7));
    tempAssignees.clear();
    tempAttachments.clear();
    selectedProjectName.value = 'None';
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
    final currentUser = projController.allEmployees[0]; // John Smith (Manager)

    // Lookup matching project if selected
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
          description: 'Task was created by ${currentUser.name}.',
          timestamp: DateTime.now(),
          user: currentUser,
        )
      ],
      attachments: List<String>.from(tempAttachments),
    );

    tasks.add(newTask);
    clearCreationForm();
    Get.back(); // Pop Create Task Screen
    Get.snackbar(
      'Task Created',
      'New task was created and allocated successfully!',
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
}
