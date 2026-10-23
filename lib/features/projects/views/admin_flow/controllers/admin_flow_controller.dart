import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../models/admin_flow_models.dart';
import 'package:dgm360/features/projects/models/project_model.dart';

class AdminFlowController extends GetxController {
  static AdminFlowController get to => Get.find<AdminFlowController>();

  // Filter & Search Observables for Projects List
  final RxString projectFilter = 'All'.obs; // 'All', 'Active', 'Completed', 'On Hold'
  final RxString projectSearchQuery = ''.obs;
  final TextEditingController projectSearchController = TextEditingController();
  final RxInt selectedMainBottomTab = 0.obs; // 0: Projects, 1: Employees, 2: Reports, 3: Settings

  // Project Details Hub Tabs: 0: Overview, 1: Team, 2: Modules, 3: Timeline, 4: Settings
  final RxInt selectedHubTab = 0.obs;

  // Modules Filter & Search
  final RxString moduleFilter = 'All'.obs; // 'All', 'Completed', 'Pending'
  final RxString moduleSearchQuery = ''.obs;
  final TextEditingController moduleSearchController = TextEditingController();

  // Team Search
  final RxString teamSearchQuery = ''.obs;
  final TextEditingController teamSearchController = TextEditingController();

  // Timeline Sub-Tab: 0: Milestones, 1: Activity Log
  final RxInt timelineSubTab = 0.obs;

  // Module Details Sub-Tab: 0: Tasks, 1: Overview
  final RxInt moduleDetailsSubTab = 0.obs;

  // Selected State
  late Rx<AdminFlowProject> selectedProject;
  final Rxn<AdminFlowMember> selectedMember = Rxn<AdminFlowMember>();
  final Rxn<AdminFlowModule> selectedModule = Rxn<AdminFlowModule>();
  final Rxn<AdminFlowTask> selectedTask = Rxn<AdminFlowTask>();

  // All Projects
  final RxList<AdminFlowProject> projects = <AdminFlowProject>[].obs;

  // Dynamic Handover Audit Trail for the entire flow
  final RxList<AdminFlowHandoverRecord> globalHandoverHistory = <AdminFlowHandoverRecord>[].obs;

  // Shared Project Files & Documents (Admin & Employee can both view and upload)
  final RxList<AdminProjectFileItem> allProjectFiles = <AdminProjectFileItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
  }

  void _loadInitialData() {
    final defaultProjects = _generateSampleProjects();
    projects.assignAll(defaultProjects);
    selectedProject = Rx<AdminFlowProject>(projects.first);
    if (selectedProject.value.modules.isNotEmpty) {
      selectedModule.value = selectedProject.value.modules.first;
      if (selectedModule.value!.tasks.isNotEmpty) {
        selectedTask.value = selectedModule.value!.tasks.length > 1
            ? selectedModule.value!.tasks[1] // "Signup Flow"
            : selectedModule.value!.tasks.first;
      }
    }
    if (selectedProject.value.members.isNotEmpty) {
      selectedMember.value = selectedProject.value.members.first;
    }

    _loadDefaultHandovers();
    _loadDefaultFiles();
  }

  void _loadDefaultFiles() {
    allProjectFiles.assignAll([
      const AdminProjectFileItem(
        id: 'FILE-01',
        projectId: 'PRJ-001',
        fileName: 'Project_SRS_Specification_v2.pdf',
        fileSize: '4.2 MB',
        fileExtension: 'pdf',
        uploadedBy: 'Admin (System)',
        uploadDate: '10 Sep 2025',
      ),
      const AdminProjectFileItem(
        id: 'FILE-02',
        projectId: 'PRJ-001',
        fileName: 'App_UI_UX_Design_System.fig',
        fileSize: '18.6 MB',
        fileExtension: 'fig',
        uploadedBy: 'Neha Singh (UI Lead)',
        uploadDate: '14 Sep 2025',
      ),
      const AdminProjectFileItem(
        id: 'FILE-03',
        projectId: 'PRJ-001',
        fileName: 'API_Contracts_and_Swagger.docx',
        fileSize: '1.8 MB',
        fileExtension: 'docx',
        uploadedBy: 'Aarav Sharma (Employee)',
        uploadDate: '20 Sep 2025',
      ),
      const AdminProjectFileItem(
        id: 'FILE-04',
        projectId: 'PRJ-001',
        fileName: 'Database_Schema_ERD_Export.png',
        fileSize: '3.1 MB',
        fileExtension: 'png',
        uploadedBy: 'Aarav Sharma (Employee)',
        uploadDate: '25 Sep 2025',
      ),
      const AdminProjectFileItem(
        id: 'FILE-05',
        projectId: 'PRJ-001',
        fileName: 'Sprint_3_Task_Estimates.xlsx',
        fileSize: '950 KB',
        fileExtension: 'xlsx',
        uploadedBy: 'Admin (Manager)',
        uploadDate: '02 Oct 2025',
      ),
      const AdminProjectFileItem(
        id: 'FILE-06',
        projectId: 'PRJ-002',
        fileName: 'POS_Integration_Architecture.pdf',
        fileSize: '5.6 MB',
        fileExtension: 'pdf',
        uploadedBy: 'Admin (System)',
        uploadDate: '18 Aug 2025',
      ),
      const AdminProjectFileItem(
        id: 'FILE-07',
        projectId: 'PRJ-002',
        fileName: 'Hardware_SDK_Bundle.zip',
        fileSize: '42.0 MB',
        fileExtension: 'zip',
        uploadedBy: 'Rohit Verma (Employee)',
        uploadDate: '22 Aug 2025',
      ),
      const AdminProjectFileItem(
        id: 'FILE-08',
        projectId: 'PRJ-003',
        fileName: 'Payment_Gateway_Security_Audit.pdf',
        fileSize: '2.9 MB',
        fileExtension: 'pdf',
        uploadedBy: 'Admin (System)',
        uploadDate: '05 Jul 2025',
      ),
    ]);
  }

  /// Get all files belonging to a specific project
  List<AdminProjectFileItem> getFilesForProject(String projectId) {
    return allProjectFiles.where((f) => f.projectId == projectId).toList();
  }

  /// Add a new file to project (accessible by both Admin & Employee)
  void addFileToProject({
    required String projectId,
    required String fileName,
    required String fileSize,
    required String fileExtension,
    required String uploadedBy,
    String? fileUrl,
  }) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final now = DateTime.now();
    final newFile = AdminProjectFileItem(
      id: 'FILE-${now.millisecondsSinceEpoch}',
      projectId: projectId,
      fileName: fileName,
      fileSize: fileSize,
      fileExtension: fileExtension.toLowerCase().replaceAll('.', ''),
      uploadedBy: uploadedBy,
      uploadDate: '${now.day} ${months[now.month - 1]} ${now.year}',
      fileUrl: fileUrl,
    );
    allProjectFiles.insert(0, newFile);
  }

  /// Delete a file from project
  void deleteProjectFile(String fileId) {
    allProjectFiles.removeWhere((f) => f.id == fileId);
  }

  void _loadDefaultHandovers() {
    globalHandoverHistory.assignAll([
      const AdminFlowHandoverRecord(
        id: 'HO-01',
        taskTitle: 'Signup Flow',
        timestamp: '12 Sep 2025 10:00 AM',
        fromUser: 'System Admin',
        toUser: 'Sneha Patel',
        reason: 'Initial sprint allocation',
        notes: 'Task assigned for auth milestone.',
        status: 'Initial Assignment',
      ),
      const AdminFlowHandoverRecord(
        id: 'HO-02',
        taskTitle: 'Signup Flow',
        timestamp: '15 Sep 2025 02:30 PM',
        fromUser: 'Rohit Verma',
        toUser: 'Sneha Patel',
        reason: 'Workload balance',
        notes: 'Transferred pending validation tasks due to sprint rebalancing.',
        status: 'Handover',
      ),
      const AdminFlowHandoverRecord(
        id: 'HO-03',
        taskTitle: 'Signup Flow',
        timestamp: '18 Sep 2025 11:20 AM',
        fromUser: 'Sneha Patel',
        toUser: 'Aarav Sharma',
        reason: 'Leave',
        notes: 'Sneha on medical leave for 2 days. Aarav taking over email OTP verification.',
        status: 'Handover',
      ),
      const AdminFlowHandoverRecord(
        id: 'HO-04',
        taskTitle: 'Signup Flow',
        timestamp: '20 Sep 2025 09:15 AM',
        fromUser: 'Aarav Sharma',
        toUser: 'Aarav Sharma',
        reason: 'Sprint resume',
        notes: 'Accepted by Aarav Sharma. Code review and unit tests initiated.',
        status: 'Accepted',
      ),
    ]);
  }

  /// Initialize flow with optional existing project from app
  void selectProjectByIdOrModel({String? projectId, String? projectName, Project? existingProject}) {
    if (projects.isEmpty) _loadInitialData();

    if (existingProject != null) {
      final found = projects.firstWhereOrNull((p) => p.title.toLowerCase() == existingProject.name.toLowerCase() || p.id == existingProject.id);
      if (found != null) {
        selectedProject.value = found;
        _syncSelectedModuleAndTask();
        return;
      }
    }

    if (projectId != null && projectId.isNotEmpty) {
      final found = projects.firstWhereOrNull((p) => p.id == projectId);
      if (found != null) {
        selectedProject.value = found;
        _syncSelectedModuleAndTask();
        return;
      }
    }

    if (projectName != null && projectName.isNotEmpty) {
      final found = projects.firstWhereOrNull((p) => p.title.toLowerCase().contains(projectName.toLowerCase()));
      if (found != null) {
        selectedProject.value = found;
        _syncSelectedModuleAndTask();
        return;
      }
    }
  }

  void _syncSelectedModuleAndTask() {
    if (selectedProject.value.modules.isNotEmpty) {
      selectedModule.value = selectedProject.value.modules.first;
      if (selectedModule.value!.tasks.isNotEmpty) {
        selectedTask.value = selectedModule.value!.tasks.first;
      }
    }
    if (selectedProject.value.members.isNotEmpty) {
      selectedMember.value = selectedProject.value.members.first;
    }
  }

  // Filtered Projects for Screen 1
  List<AdminFlowProject> get filteredProjects {
    return projects.where((p) {
      final query = projectSearchQuery.value.trim().toLowerCase();
      final matchesQuery = query.isEmpty ||
          p.title.toLowerCase().contains(query) ||
          p.code.toLowerCase().contains(query) ||
          p.category.toLowerCase().contains(query);

      if (!matchesQuery) return false;

      if (projectFilter.value == 'All') return true;
      if (projectFilter.value == 'Active') return p.status == 'Active';
      if (projectFilter.value == 'Completed') return p.status == 'Completed';
      if (projectFilter.value == 'On Hold') return p.status == 'On Hold';
      return true;
    }).toList();
  }

  // Filtered Modules for Screen 5
  List<AdminFlowModule> get filteredModules {
    final modules = selectedProject.value.modules;
    return modules.where((m) {
      final query = moduleSearchQuery.value.trim().toLowerCase();
      final matchesQuery = query.isEmpty || m.title.toLowerCase().contains(query);
      if (!matchesQuery) return false;

      if (moduleFilter.value == 'All') return true;
      if (moduleFilter.value == 'Completed') return m.status == 'Completed' || m.progress >= 1.0;
      if (moduleFilter.value == 'Pending') return m.status != 'Completed' && m.progress < 1.0;
      return true;
    }).toList();
  }

  // Filtered Team Members for Screen 3
  List<AdminFlowMember> get filteredMembers {
    final members = selectedProject.value.members;
    final query = teamSearchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return members;
    return members.where((m) =>
        m.name.toLowerCase().contains(query) ||
        m.role.toLowerCase().contains(query) ||
        m.email.toLowerCase().contains(query) ||
        m.city.toLowerCase().contains(query) ||
        m.department.toLowerCase().contains(query)).toList();
  }

  // All members across the organization / current project
  List<AdminFlowMember> get allMembers => selectedProject.value.members;

  // ─────────────────────────────────────────────────────────────
  // 🚀 PROJECT CRUD OPERATIONS
  // ─────────────────────────────────────────────────────────────

  /// Create a New Project
  void createNewProject({
    required String title,
    required String code,
    required String category,
    required String status,
    required String description,
    required String startDate,
    required String endDate,
    required String duration,
  }) {
    final newProj = AdminFlowProject(
      id: 'PRJ-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      code: code.isNotEmpty ? code : 'PRJ-00${projects.length + 1}',
      title: title,
      description: description,
      category: category,
      status: status,
      startDate: startDate,
      endDate: endDate,
      deadline: endDate,
      duration: duration,
      progress: 0.05,
      totalMembers: selectedProject.value.members.length,
      totalModules: 1,
      completedModules: 0,
      pendingModules: 1,
      icon: Iconsax.folder_favorite,
      themeColor: const Color(0xFF3B206A),
      iconBgColor: const Color(0xFFF5F0FB),
      members: selectedProject.value.members,
      modules: [
        const AdminFlowModule(
          id: 'MOD-INIT',
          title: 'Initial Setup & Architecture',
          tasksCount: 1,
          progress: 0.10,
          status: 'In Progress',
          description: 'Repository setup, environment configs, and baseline CI/CD pipelines.',
        ),
      ],
      milestones: [
        AdminFlowMilestone(id: 'M-1', title: 'Project Kickoff', date: startDate, status: 'In Progress'),
        AdminFlowMilestone(id: 'M-2', title: 'Phase 1 Delivery', date: endDate, status: 'Pending'),
      ],
      activityLog: [
        AdminFlowActivityItem(
          id: 'A-INIT',
          title: 'Project "$title" created by Admin',
          timestamp: 'Just now',
          user: 'Admin',
          icon: Iconsax.add_circle,
          iconColor: const Color(0xFF10B981),
        ),
      ],
    );

    projects.insert(0, newProj);
    selectedProject.value = newProj;
    _syncSelectedModuleAndTask();
  }

  /// Update / Edit Existing Project
  void updateProjectDetails({
    required String title,
    required String category,
    required String status,
    required String description,
    required String deadline,
    required String duration,
  }) {
    final current = selectedProject.value;
    final updated = current.copyWith(
      title: title,
      category: category,
      status: status,
      description: description,
      deadline: deadline,
      duration: duration,
    );

    final idx = projects.indexWhere((p) => p.id == current.id);
    if (idx != -1) {
      projects[idx] = updated;
    }
    selectedProject.value = updated;
  }

  /// Delete Existing Project
  bool deleteProject(String projectId) {
    if (projects.length <= 1) {
      Get.snackbar(
        'Action Denied',
        'Cannot delete the only remaining project in workspace.',
        backgroundColor: const Color(0xFFFEE2E2),
        colorText: const Color(0xFFDC2626),
      );
      return false;
    }

    projects.removeWhere((p) => p.id == projectId);
    selectedProject.value = projects.first;
    _syncSelectedModuleAndTask();
    return true;
  }

  // ─────────────────────────────────────────────────────────────
  // 🚀 MODULE & TASK CREATION (WITH ASSIGNEE ASSIGNMENT)
  // ─────────────────────────────────────────────────────────────

  /// Add a New Module (with optional initial task)
  void addModuleToCurrentProject({
    required String title,
    required String description,
    String status = 'Pending',
    AdminFlowTask? initialTask,
  }) {
    final current = selectedProject.value;
    final newModId = 'MOD-0${current.modules.length + 1}';

    final tasksList = <AdminFlowTask>[];
    if (initialTask != null) {
      tasksList.add(initialTask);
    }

    final newModule = AdminFlowModule(
      id: newModId,
      title: title,
      tasksCount: tasksList.length,
      progress: status == 'Completed' ? 1.0 : (status == 'In Progress' ? 0.3 : 0.0),
      status: status,
      description: description,
      tasks: tasksList,
    );

    final updatedModules = List<AdminFlowModule>.from(current.modules)..add(newModule);
    final updated = current.copyWith(
      modules: updatedModules,
      totalModules: updatedModules.length,
      pendingModules: current.pendingModules + 1,
    );

    _updateCurrentProjectAndSave(updated);

    // If an initial task was assigned to a member, link it to them
    if (initialTask != null) {
      _assignTaskToMember(initialTask);
    }
  }

  /// Add a New Task to a Module and assign it directly to a Team Member
  void addTaskToModule({
    required String moduleTitle,
    required String title,
    required String assigneeName,
    required double allocatedHours,
    required String priority,
    required String dueDate,
    required String description,
  }) {
    final current = selectedProject.value;

    // Find the member to get role
    final member = current.members.firstWhereOrNull((m) => m.name == assigneeName);
    final role = member?.role ?? 'Developer';

    final newTask = AdminFlowTask(
      id: 'TSK-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      title: title,
      moduleTitle: moduleTitle,
      status: 'In Progress',
      assigneeName: assigneeName,
      assigneeRole: role,
      allocatedHours: allocatedHours,
      actualHours: 0.0,
      estimatedTime: '${allocatedHours.toInt()} hours',
      actualTime: '0 hours',
      startDate: 'Today',
      dueDate: dueDate,
      priority: priority,
      description: description,
      handoverHistory: [
        AdminFlowHandoverRecord(
          id: 'HO-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
          taskTitle: title,
          timestamp: 'Just now',
          fromUser: 'Project Manager',
          toUser: assigneeName,
          reason: 'Initial task assignment',
          notes: 'Task created and allocated $allocatedHours hours.',
          status: 'Initial Assignment',
        ),
      ],
    );

    // Update modules in project
    final updatedModules = current.modules.map((m) {
      if (m.title.toLowerCase() == moduleTitle.toLowerCase()) {
        final updatedTasks = List<AdminFlowTask>.from(m.tasks)..insert(0, newTask);
        return m.copyWith(
          tasks: updatedTasks,
          tasksCount: updatedTasks.length,
        );
      }
      return m;
    }).toList();

    final updated = current.copyWith(
      modules: updatedModules,
      inProgressTasksCount: current.inProgressTasksCount + 1,
    );

    _updateCurrentProjectAndSave(updated);
    _assignTaskToMember(newTask);

    // Also record into global handover history
    globalHandoverHistory.insert(0, newTask.handoverHistory.first);
  }

  void _assignTaskToMember(AdminFlowTask task) {
    final current = selectedProject.value;
    final updatedMembers = current.members.map((m) {
      if (m.name.toLowerCase() == task.assigneeName.toLowerCase()) {
        final updatedTasks = List<AdminFlowTask>.from(m.assignedTasks)..insert(0, task);
        // Also update or add module entry
        final hasMod = m.assignedModules.any((mod) => mod.title == task.moduleTitle);
        List<AdminFlowMemberModule> updatedMods;
        if (hasMod) {
          updatedMods = m.assignedModules.map((mod) {
            if (mod.title == task.moduleTitle) {
              return AdminFlowMemberModule(
                title: mod.title,
                tasksCount: mod.tasksCount + 1,
                progress: mod.progress,
                tasks: List<AdminFlowTask>.from(mod.tasks)..add(task),
              );
            }
            return mod;
          }).toList();
        } else {
          updatedMods = List<AdminFlowMemberModule>.from(m.assignedModules)
            ..add(AdminFlowMemberModule(
              title: task.moduleTitle,
              tasksCount: 1,
              progress: 0.2,
              tasks: [task],
            ));
        }

        return AdminFlowMember(
          id: m.id,
          employeeId: m.employeeId,
          name: m.name,
          role: m.role,
          department: m.department,
          status: m.status,
          progress: m.progress,
          assignedModulesCount: updatedMods.length,
          email: m.email,
          mobile: m.mobile,
          fullAddress: m.fullAddress,
          city: m.city,
          state: m.state,
          pincode: m.pincode,
          country: m.country,
          joinedOn: m.joinedOn,
          avatarUrl: m.avatarUrl,
          handoversGivenCount: m.handoversGivenCount,
          handoversReceivedCount: m.handoversReceivedCount,
          assignedModules: updatedMods,
          assignedTasks: updatedTasks,
        );
      }
      return m;
    }).toList();

    final updated = current.copyWith(members: updatedMembers);
    _updateCurrentProjectAndSave(updated);

    // If currently selected member was this member, update selectedMember
    if (selectedMember.value != null && selectedMember.value!.name == task.assigneeName) {
      selectedMember.value = updatedMembers.firstWhereOrNull((m) => m.name == task.assigneeName);
    }
  }

  void _updateCurrentProjectAndSave(AdminFlowProject updated) {
    final idx = projects.indexWhere((p) => p.id == updated.id);
    if (idx != -1) {
      projects[idx] = updated;
    }
    selectedProject.value = updated;
  }

  // ─────────────────────────────────────────────────────────────
  // 🚀 HANDOVER OPERATIONS
  // ─────────────────────────────────────────────────────────────

  // Submit Handover
  bool performHandover({
    required AdminFlowTask task,
    required String newAssigneeName,
    required String reason,
    required String notes,
  }) {
    final nowFormatted = '23 Oct 2026 11:00 AM';
    final fromUser = task.assigneeName;

    final newRecord = AdminFlowHandoverRecord(
      id: 'HO-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      taskTitle: task.title,
      timestamp: nowFormatted,
      fromUser: fromUser,
      toUser: newAssigneeName,
      reason: reason,
      notes: notes,
      status: 'Handover',
    );

    // Update global list
    globalHandoverHistory.insert(0, newRecord);

    // Update the task itself
    task.assigneeName = newAssigneeName;
    task.handoverHistory.insert(0, newRecord);

    // Update in selected module tasks
    if (selectedModule.value != null) {
      final updatedTasks = selectedModule.value!.tasks.map((t) {
        if (t.id == task.id) {
          return task;
        }
        return t;
      }).toList();
      selectedModule.value = selectedModule.value!.copyWith(tasks: updatedTasks);
    }

    selectedTask.value = task;

    // Increment handovers counters on the two employees
    final current = selectedProject.value;
    final updatedMembers = current.members.map((m) {
      if (m.name.toLowerCase() == fromUser.toLowerCase()) {
        return AdminFlowMember(
          id: m.id,
          employeeId: m.employeeId,
          name: m.name,
          role: m.role,
          department: m.department,
          status: m.status,
          progress: m.progress,
          assignedModulesCount: m.assignedModulesCount,
          email: m.email,
          mobile: m.mobile,
          fullAddress: m.fullAddress,
          city: m.city,
          state: m.state,
          pincode: m.pincode,
          country: m.country,
          joinedOn: m.joinedOn,
          avatarUrl: m.avatarUrl,
          handoversGivenCount: m.handoversGivenCount + 1,
          handoversReceivedCount: m.handoversReceivedCount,
          assignedModules: m.assignedModules,
          assignedTasks: m.assignedTasks,
        );
      }
      if (m.name.toLowerCase() == newAssigneeName.toLowerCase()) {
        return AdminFlowMember(
          id: m.id,
          employeeId: m.employeeId,
          name: m.name,
          role: m.role,
          department: m.department,
          status: m.status,
          progress: m.progress,
          assignedModulesCount: m.assignedModulesCount,
          email: m.email,
          mobile: m.mobile,
          fullAddress: m.fullAddress,
          city: m.city,
          state: m.state,
          pincode: m.pincode,
          country: m.country,
          joinedOn: m.joinedOn,
          avatarUrl: m.avatarUrl,
          handoversGivenCount: m.handoversGivenCount,
          handoversReceivedCount: m.handoversReceivedCount + 1,
          assignedModules: m.assignedModules,
          assignedTasks: List<AdminFlowTask>.from(m.assignedTasks)..insert(0, task),
        );
      }
      return m;
    }).toList();

    _updateCurrentProjectAndSave(current.copyWith(members: updatedMembers));

    return true;
  }

  List<AdminFlowProject> _generateSampleProjects() {
    final commonMilestones = [
      const AdminFlowMilestone(id: 'M-1', title: 'Project Kickoff', date: '01 Sep 2025', status: 'Completed'),
      const AdminFlowMilestone(id: 'M-2', title: 'Design Phase', date: '15 Sep 2025', status: 'Completed'),
      const AdminFlowMilestone(id: 'M-3', title: 'Development Phase', date: '01 Oct 2025', status: 'In Progress'),
      const AdminFlowMilestone(id: 'M-4', title: 'Testing Phase', date: '15 Nov 2025', status: 'Pending'),
      const AdminFlowMilestone(id: 'M-5', title: 'UAT & Bug Fixes', date: '01 Dec 2025', status: 'Pending'),
      const AdminFlowMilestone(id: 'M-6', title: 'Final Release', date: '31 Dec 2025', status: 'Pending'),
    ];

    final commonActivityLog = [
      const AdminFlowActivityItem(
        id: 'A-1',
        title: 'Task Handover completed for Signup Flow',
        timestamp: '15 Sep 2025, 02:30 PM',
        user: 'Rohit Verma',
        icon: Iconsax.refresh_2,
        iconColor: Color(0xFF3B206A),
      ),
      const AdminFlowActivityItem(
        id: 'A-2',
        title: 'Module Login API Integration marked Completed',
        timestamp: '10 Sep 2025, 06:15 PM',
        user: 'Aarav Sharma',
        icon: Iconsax.tick_circle,
        iconColor: Color(0xFF10B981),
      ),
      const AdminFlowActivityItem(
        id: 'A-3',
        title: 'Sprint 2 Milestones synced with Git repositories',
        timestamp: '05 Sep 2025, 11:00 AM',
        user: 'Pooja Kumari',
        icon: Iconsax.code,
        iconColor: Color(0xFF8B5CF6),
      ),
      const AdminFlowActivityItem(
        id: 'A-4',
        title: 'Figma Design review approved by Client',
        timestamp: '15 Aug 2025, 04:00 PM',
        user: 'Neha Singh',
        icon: Iconsax.document_text,
        iconColor: Color(0xFFF59E0B),
      ),
    ];

    // Rich Sample Tasks with allocated hours, actual hours (some exceeding time to show red badge!)
    final aaravTasks = [
      AdminFlowTask(
        id: 'TSK-01',
        title: 'Login API Integration',
        moduleTitle: 'User Authentication',
        status: 'Completed',
        assigneeName: 'Aarav Sharma',
        assigneeRole: 'Frontend Developer',
        allocatedHours: 6.0,
        actualHours: 5.5,
        estimatedTime: '6 hours',
        actualTime: '5.5 hours',
        startDate: '08 Sep 2025',
        dueDate: '10 Sep 2025',
        priority: 'High',
        description: 'Connect login endpoints with JWT token refresh and biometric validation.',
      ),
      AdminFlowTask(
        id: 'TSK-05',
        title: 'Product Catalog Grid & Filters',
        moduleTitle: 'Product Catalog',
        status: 'In Progress',
        assigneeName: 'Aarav Sharma',
        assigneeRole: 'Frontend Developer',
        allocatedHours: 8.0,
        actualHours: 11.5, // ⚠️ Exceeded by 3.5h!
        estimatedTime: '8 hours',
        actualTime: '11.5 hours',
        startDate: '12 Sep 2025',
        dueDate: '16 Sep 2025',
        priority: 'High',
        description: 'Multi-facet filtering, instant search debounce and responsive infinite scroll.',
      ),
      AdminFlowTask(
        id: 'TSK-08',
        title: 'Cart Items Local Hive Caching',
        moduleTitle: 'Cart & Checkout',
        status: 'Pending',
        assigneeName: 'Aarav Sharma',
        assigneeRole: 'Frontend Developer',
        allocatedHours: 5.0,
        actualHours: 2.0,
        estimatedTime: '5 hours',
        actualTime: '2 hours',
        startDate: '18 Sep 2025',
        dueDate: '22 Sep 2025',
        priority: 'Medium',
        description: 'Cache cart line items locally for offline resiliency.',
      ),
      AdminFlowTask(
        id: 'TSK-12',
        title: 'Razorpay SDK UI Callback Hooks',
        moduleTitle: 'Payment Integration',
        status: 'Pending',
        assigneeName: 'Aarav Sharma',
        assigneeRole: 'Frontend Developer',
        allocatedHours: 6.0,
        actualHours: 8.0, // ⚠️ Exceeded by 2h!
        estimatedTime: '6 hours',
        actualTime: '8 hours',
        startDate: '20 Sep 2025',
        dueDate: '25 Sep 2025',
        priority: 'High',
        description: 'Handle Razorpay webview callbacks, success/failure screens.',
      ),
    ];

    final snehaTasks = [
      AdminFlowTask(
        id: 'TSK-02',
        title: 'Signup Flow',
        moduleTitle: 'User Authentication',
        status: 'In Progress',
        assigneeName: 'Sneha Patel',
        assigneeRole: 'Backend Developer',
        allocatedHours: 8.0,
        actualHours: 11.0, // ⚠️ Exceeded by 3 hours!
        estimatedTime: '8 hours',
        actualTime: '11 hours',
        startDate: '12 Sep 2025',
        dueDate: '15 Sep 2025',
        priority: 'High',
        description: 'Implement user signup flow with email verification and telephone OTP fallback.',
        handoverHistory: [
          const AdminFlowHandoverRecord(
            id: 'HO-21',
            taskTitle: 'Signup Flow',
            timestamp: '12 Sep 2025 10:00 AM',
            fromUser: 'System Admin',
            toUser: 'Sneha Patel',
            reason: 'Initial assignment',
            status: 'Initial Assignment',
          ),
          const AdminFlowHandoverRecord(
            id: 'HO-22',
            taskTitle: 'Signup Flow',
            timestamp: '15 Sep 2025 02:30 PM',
            fromUser: 'Rohit Verma',
            toUser: 'Sneha Patel',
            reason: 'Workload balance',
            notes: 'Handover from Rohit Verma to Sneha Patel due to urgent patch release.',
            status: 'Handover',
          ),
        ],
      ),
      AdminFlowTask(
        id: 'TSK-03',
        title: 'Stripe Webhook Listener',
        moduleTitle: 'Payment Integration',
        status: 'In Progress',
        assigneeName: 'Sneha Patel',
        assigneeRole: 'Backend Developer',
        allocatedHours: 7.0,
        actualHours: 6.0,
        estimatedTime: '7 hours',
        actualTime: '6 hours',
        startDate: '14 Sep 2025',
        dueDate: '18 Sep 2025',
        priority: 'Medium',
        description: 'Validate Stripe signatures and trigger order fulfilment.',
      ),
    ];

    final rohitTasks = [
      AdminFlowTask(
        id: 'TSK-04',
        title: 'Password Reset',
        moduleTitle: 'User Authentication',
        status: 'Pending',
        assigneeName: 'Rohit Verma',
        assigneeRole: 'Flutter Developer',
        allocatedHours: 4.0,
        actualHours: 1.0,
        estimatedTime: '4 hours',
        actualTime: '1 hour',
        startDate: '16 Sep 2025',
        dueDate: '20 Sep 2025',
        priority: 'Medium',
        description: 'Implement password reset deep links and security questions fallback.',
      ),
      AdminFlowTask(
        id: 'TSK-09',
        title: 'Checkout Flow State Machine',
        moduleTitle: 'Cart & Checkout',
        status: 'In Progress',
        assigneeName: 'Rohit Verma',
        assigneeRole: 'Flutter Developer',
        allocatedHours: 10.0,
        actualHours: 14.0, // ⚠️ Exceeded by 4 hours!
        estimatedTime: '10 hours',
        actualTime: '14 hours',
        startDate: '10 Sep 2025',
        dueDate: '15 Sep 2025',
        priority: 'High',
        description: 'Manage shipping address, tax calc, promo code, and payment gateway handover.',
      ),
    ];

    final commonMembers = [
      AdminFlowMember(
        id: 'EMP-01',
        employeeId: 'EMP-2024-001',
        name: 'Aarav Sharma',
        role: 'Frontend Developer',
        department: 'Frontend Engineering',
        status: 'Working',
        progress: 0.60,
        assignedModulesCount: 4,
        email: 'aarav@company.com',
        mobile: '+91 98112 45901',
        fullAddress: 'Flat 402, Tower B, Supertech Ecociti, Sector 137',
        city: 'Noida',
        state: 'Uttar Pradesh',
        pincode: '201305',
        country: 'India',
        joinedOn: '15 Aug 2025',
        handoversGivenCount: 3,
        handoversReceivedCount: 2,
        assignedTasks: aaravTasks,
        assignedModules: [
          AdminFlowMemberModule(
            title: 'User Authentication',
            tasksCount: 1,
            progress: 1.0,
            tasks: [aaravTasks[0]],
          ),
          AdminFlowMemberModule(
            title: 'Product Catalog',
            tasksCount: 1,
            progress: 0.60,
            tasks: [aaravTasks[1]],
          ),
          AdminFlowMemberModule(
            title: 'Cart & Checkout',
            tasksCount: 1,
            progress: 0.50,
            tasks: [aaravTasks[2]],
          ),
          AdminFlowMemberModule(
            title: 'Payment Integration',
            tasksCount: 1,
            progress: 0.25,
            tasks: [aaravTasks[3]],
          ),
        ],
      ),
      AdminFlowMember(
        id: 'EMP-02',
        employeeId: 'EMP-2024-002',
        name: 'Sneha Patel',
        role: 'Backend Developer',
        department: 'Backend Systems',
        status: 'Working',
        progress: 0.45,
        assignedModulesCount: 2,
        email: 'sneha@company.com',
        mobile: '+91 98721 99341',
        fullAddress: 'B-14, Shivalik Residency, Near Vastrapur Lake',
        city: 'Ahmedabad',
        state: 'Gujarat',
        pincode: '380015',
        country: 'India',
        joinedOn: '01 Jul 2025',
        handoversGivenCount: 4,
        handoversReceivedCount: 3,
        assignedTasks: snehaTasks,
        assignedModules: [
          AdminFlowMemberModule(title: 'User Authentication', tasksCount: 1, progress: 0.70, tasks: [snehaTasks[0]]),
          AdminFlowMemberModule(title: 'Payment Integration', tasksCount: 1, progress: 0.40, tasks: [snehaTasks[1]]),
        ],
      ),
      AdminFlowMember(
        id: 'EMP-03',
        employeeId: 'EMP-2024-003',
        name: 'Rohit Verma',
        role: 'Flutter Developer',
        department: 'Mobile Development',
        status: 'Working',
        progress: 0.30,
        assignedModulesCount: 2,
        email: 'rohit@company.com',
        mobile: '+91 99345 61280',
        fullAddress: 'Plot 88, Green Glen Layout, Bellandur Outer Ring Road',
        city: 'Bengaluru',
        state: 'Karnataka',
        pincode: '560103',
        country: 'India',
        joinedOn: '10 Jan 2025',
        handoversGivenCount: 2,
        handoversReceivedCount: 1,
        assignedTasks: rohitTasks,
        assignedModules: [
          AdminFlowMemberModule(title: 'User Authentication', tasksCount: 1, progress: 0.30, tasks: [rohitTasks[0]]),
          AdminFlowMemberModule(title: 'Cart & Checkout', tasksCount: 1, progress: 0.30, tasks: [rohitTasks[1]]),
        ],
      ),
      const AdminFlowMember(
        id: 'EMP-04',
        employeeId: 'EMP-2024-004',
        name: 'Neha Singh',
        role: 'UI/UX Designer',
        department: 'Product & UX Design',
        status: 'On Leave',
        progress: 0.00,
        assignedModulesCount: 2,
        email: 'neha@company.com',
        mobile: '+91 98450 12764',
        fullAddress: 'Villa 12, Palm Meadows, Hiranandani Estate, Ghodbunder Rd',
        city: 'Thane',
        state: 'Maharashtra',
        pincode: '400607',
        country: 'India',
        joinedOn: '15 Mar 2025',
        handoversGivenCount: 1,
        handoversReceivedCount: 0,
        assignedModules: [
          AdminFlowMemberModule(title: 'User Authentication', tasksCount: 1, progress: 1.0),
          AdminFlowMemberModule(title: 'Admin Panel', tasksCount: 2, progress: 0.0),
        ],
      ),
      const AdminFlowMember(
        id: 'EMP-05',
        employeeId: 'EMP-2024-005',
        name: 'Vikash Yadav',
        role: 'QA Tester',
        department: 'Quality Assurance',
        status: 'Working',
        progress: 0.20,
        assignedModulesCount: 2,
        email: 'vikash@company.com',
        mobile: '+91 98104 55210',
        fullAddress: 'C-204, Sector 48, Sohna Road',
        city: 'Gurugram',
        state: 'Haryana',
        pincode: '122018',
        country: 'India',
        joinedOn: '01 Feb 2025',
        handoversGivenCount: 1,
        handoversReceivedCount: 1,
        assignedModules: [
          AdminFlowMemberModule(title: 'Product Catalog', tasksCount: 3, progress: 0.50),
          AdminFlowMemberModule(title: 'Cart & Checkout', tasksCount: 2, progress: 0.20),
        ],
      ),
      const AdminFlowMember(
        id: 'EMP-06',
        employeeId: 'EMP-2024-006',
        name: 'Pooja Kumari',
        role: 'DevOps',
        department: 'DevOps & Cloud Infrastructure',
        status: 'Working',
        progress: 0.10,
        assignedModulesCount: 2,
        email: 'pooja@company.com',
        mobile: '+91 97230 48921',
        fullAddress: 'H.No 15/A, 3rd Cross, Indiranagar 1st Stage',
        city: 'Bengaluru',
        state: 'Karnataka',
        pincode: '560038',
        country: 'India',
        joinedOn: '18 Nov 2024',
        handoversGivenCount: 0,
        handoversReceivedCount: 1,
        assignedModules: [
          AdminFlowMemberModule(title: 'Admin Panel', tasksCount: 4, progress: 0.10),
          AdminFlowMemberModule(title: 'Analytics & Reports', tasksCount: 2, progress: 0.10),
        ],
      ),
    ];

    final defaultModules = [
      AdminFlowModule(
        id: 'MOD-01',
        title: 'User Authentication',
        tasksCount: 3,
        progress: 0.73,
        status: 'In Progress',
        description: 'Authentication module with OAuth2, JWT, biometric lock and profile bootstrapping.',
        tasks: [aaravTasks[0], snehaTasks[0], rohitTasks[0]],
      ),
      AdminFlowModule(
        id: 'MOD-02',
        title: 'Product Catalog',
        tasksCount: 5,
        progress: 0.40,
        status: 'In Progress',
        description: 'Product listing, categories hierarchy, search filters, and inventory sync.',
        tasks: [
          aaravTasks[1],
          AdminFlowTask(
            id: 'TSK-06',
            title: 'Category Tree Backend API',
            moduleTitle: 'Product Catalog',
            status: 'Completed',
            assigneeName: 'Sneha Patel',
            allocatedHours: 6.0,
            actualHours: 5.0,
            estimatedTime: '6 hours',
            actualTime: '5 hours',
            startDate: '01 Sep 2025',
            dueDate: '05 Sep 2025',
            priority: 'Medium',
          ),
        ],
      ),
      AdminFlowModule(
        id: 'MOD-03',
        title: 'Cart & Checkout',
        tasksCount: 4,
        progress: 0.40,
        status: 'Pending',
        description: 'Shopping cart calculation, coupon discounts, shipping rates and multi-step checkout.',
        tasks: [aaravTasks[2], rohitTasks[1]],
      ),
      AdminFlowModule(
        id: 'MOD-04',
        title: 'Payment Integration',
        tasksCount: 3,
        progress: 0.25,
        status: 'Pending',
        description: 'Razorpay, Stripe, and Apple Pay payment gateway integrations.',
        tasks: [aaravTasks[3], snehaTasks[1]],
      ),
      const AdminFlowModule(
        id: 'MOD-05',
        title: 'Order Management',
        tasksCount: 2,
        progress: 0.00,
        status: 'Pending',
        description: 'Order placement, invoice generation, tracking status and cancellation workflows.',
      ),
      const AdminFlowModule(
        id: 'MOD-06',
        title: 'Notifications',
        tasksCount: 2,
        progress: 0.00,
        status: 'Pending',
        description: 'Push notifications via FCM, SMS notifications, and user inbox management.',
      ),
      const AdminFlowModule(
        id: 'MOD-07',
        title: 'Admin Panel',
        tasksCount: 4,
        progress: 0.00,
        status: 'Pending',
        description: 'Web dashboard for inventory control, customer support and analytics.',
      ),
      const AdminFlowModule(
        id: 'MOD-08',
        title: 'Analytics & Reports',
        tasksCount: 2,
        progress: 0.00,
        status: 'Pending',
        description: 'User conversion tracking, heatmaps, and weekly sales export reports.',
      ),
    ];

    return [
      AdminFlowProject(
        id: 'PRJ-001',
        code: 'PRJ-001',
        title: 'E-Commerce Mobile App',
        description: 'Build and maintain the E-commerce application for Android & iOS.',
        category: 'Mobile App',
        status: 'Active',
        startDate: '01 Sep 2025',
        endDate: '31 Dec 2025',
        deadline: '31 Dec 2025',
        duration: '4 Months',
        progress: 0.37,
        totalMembers: 6,
        totalModules: 8,
        completedModules: 3,
        pendingModules: 5,
        icon: Iconsax.mobile,
        themeColor: const Color(0xFF3B206A),
        iconBgColor: const Color(0xFFF5F0FB),
        members: commonMembers,
        modules: defaultModules,
        milestones: commonMilestones,
        activityLog: commonActivityLog,
        estimatedHours: 330,
        actualHours: 287,
        remainingHours: 33,
        completedTasksCount: 12,
        inProgressTasksCount: 14,
        pendingTasksCount: 6,
        overdueTasksCount: 2,
      ),
      AdminFlowProject(
        id: 'PRJ-002',
        code: 'PRJ-002',
        title: 'Company Website Redesign',
        description: 'Revamp marketing landing pages, SEO optimization and modern corporate branding.',
        category: 'Web Development',
        status: 'Active',
        startDate: '10 Aug 2025',
        endDate: '30 Nov 2025',
        deadline: '30 Nov 2025',
        duration: '3.5 Months',
        progress: 0.62,
        totalMembers: 5,
        totalModules: 6,
        completedModules: 4,
        pendingModules: 2,
        icon: Iconsax.global,
        themeColor: const Color(0xFFEC4899),
        iconBgColor: const Color(0xFFFDF2F8),
        members: commonMembers,
        modules: defaultModules.take(6).toList(),
        milestones: commonMilestones,
        activityLog: commonActivityLog,
      ),
      AdminFlowProject(
        id: 'PRJ-003',
        code: 'PRJ-003',
        title: 'HR Management System',
        description: 'Employee leaves, attendance geofencing, payroll automation and tax reports.',
        category: 'Enterprise SaaS',
        status: 'On Hold',
        startDate: '15 Jul 2025',
        endDate: '15 Oct 2025',
        deadline: '15 Oct 2025',
        duration: '3 Months',
        progress: 0.20,
        totalMembers: 4,
        totalModules: 5,
        completedModules: 1,
        pendingModules: 4,
        icon: Iconsax.profile_2user,
        themeColor: const Color(0xFFF59E0B),
        iconBgColor: const Color(0xFFFFFBEB),
        members: commonMembers,
        modules: defaultModules.take(5).toList(),
        milestones: commonMilestones,
        activityLog: commonActivityLog,
      ),
      AdminFlowProject(
        id: 'PRJ-004',
        code: 'PRJ-004',
        title: 'Mobile App (Internal)',
        description: 'Internal operations, field inspections, employee clock-in and asset inventory.',
        category: 'Internal Tools',
        status: 'Completed',
        startDate: '01 Jan 2025',
        endDate: '31 Mar 2025',
        deadline: '31 Mar 2025',
        duration: '3 Months',
        progress: 1.00,
        totalMembers: 6,
        totalModules: 6,
        completedModules: 6,
        pendingModules: 0,
        icon: Iconsax.box,
        themeColor: const Color(0xFF10B981),
        iconBgColor: const Color(0xFFECFDF5),
        members: commonMembers,
        modules: defaultModules.take(6).toList(),
        milestones: commonMilestones,
        activityLog: commonActivityLog,
      ),
      AdminFlowProject(
        id: 'PRJ-005',
        code: 'PRJ-005',
        title: 'Marketing Website',
        description: 'High-converting lead gen landing pages, CRM webhook triggers and blog CMS.',
        category: 'Web Development',
        status: 'Active',
        startDate: '05 Sep 2025',
        endDate: '20 Dec 2025',
        deadline: '20 Dec 2025',
        duration: '3.5 Months',
        progress: 0.45,
        totalMembers: 4,
        totalModules: 5,
        completedModules: 2,
        pendingModules: 3,
        icon: Iconsax.monitor,
        themeColor: const Color(0xFF06B6D4),
        iconBgColor: const Color(0xFFECFEFF),
        members: commonMembers,
        modules: defaultModules.take(5).toList(),
        milestones: commonMilestones,
        activityLog: commonActivityLog,
      ),
    ];
  }
}
