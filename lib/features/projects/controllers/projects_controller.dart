import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../role_permissions/models/role_permission_models.dart';
import '../models/project_model.dart';
import '../../tasks/controllers/tasks_controller.dart';

class ProjectsController extends GetxController {
  // Reactive projects list
  final RxList<Project> projects = <Project>[].obs;

  // Search & Filters
  final RxString searchQuery = ''.obs;
  final RxString selectedTab = 'All'.obs; // All, In Progress, Completed, On Hold, Not Started

  // Mock list of all system employees (matches DepartmentsController)
  final List<AppUser> allEmployees = const [
    AppUser(name: 'John Smith', email: 'john.smith@example.com', avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150'),
    AppUser(name: 'Sarah Johnson', email: 'sarah.johnson@example.com', avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150'),
    AppUser(name: 'Michael Brown', email: 'michael.brown@example.com', avatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150'),
    AppUser(name: 'David Wilson', email: 'david.wilson@example.com', avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150'),
    AppUser(name: 'Emily Davis', email: 'emily.davis@example.com', avatarUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150'),
    AppUser(name: 'James Anderson', email: 'james.anderson@example.com', avatarUrl: 'https://images.unsplash.com/photo-1463453091185-61582044d556?w=150'),
    AppUser(name: 'Alex Johnson', email: 'alex.johnson@example.com', avatarUrl: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=150'),
    AppUser(name: 'Lisa Anderson', email: 'lisa.anderson@example.com', avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150'),
    AppUser(name: 'Robert Taylor', email: 'robert.taylor@example.com', avatarUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=150'),
  ];

  // Form State Observables
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final RxString selectedCategory = 'Web Development'.obs;
  final RxString selectedStatus = 'Not Started'.obs;
  final Rx<DateTime> startDate = DateTime.now().obs;
  final Rx<DateTime> endDate = DateTime.now().add(const Duration(days: 30)).obs;
  final RxList<AppUser> selectedEmployees = <AppUser>[].obs;
  final RxList<ProjectFile> selectedFiles = <ProjectFile>[].obs;

  // Selected Project for details view
  final Rxn<Project> selectedProject = Rxn<Project>();
  
  // Project Details selected tab index
  final RxInt selectedDetailsTabIdx = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeDummyProjects();
  }

  void _initializeDummyProjects() {
    // Standard Project Modules for Website Redesign
    final p1Modules = [
      const ProjectModule(
        id: 'mod_1',
        name: 'UI/UX & Design System',
        description: 'Wireframes, visual components, typography and design tokens.',
        subModules: [
          ProjectSubModule(id: 'sub_1_1', name: 'Wireframes & Architecture', description: 'Low-fidelity layout blueprints'),
          ProjectSubModule(id: 'sub_1_2', name: 'Design Tokens & Theme', description: 'Color palette and typography specs'),
          ProjectSubModule(id: 'sub_1_3', name: 'Interactive Prototypes', description: 'Figma click-through validation'),
        ],
      ),
      const ProjectModule(
        id: 'mod_2',
        name: 'Frontend Development',
        description: 'Responsive user interface, state management, and asset rendering.',
        subModules: [
          ProjectSubModule(id: 'sub_2_1', name: 'Core Layout & Navigation', description: 'Scaffold, sidebars and headers'),
          ProjectSubModule(id: 'sub_2_2', name: 'Component Library', description: 'Reusable widgets and controls'),
          ProjectSubModule(id: 'sub_2_3', name: 'Form Validation', description: 'Input masks and error states'),
        ],
      ),
      const ProjectModule(
        id: 'mod_3',
        name: 'Backend & APIs',
        description: 'Authentication, database models, payment endpoints and webhooks.',
        subModules: [
          ProjectSubModule(id: 'sub_3_1', name: 'OAuth & Session Management', description: 'JWT authentication endpoints'),
          ProjectSubModule(id: 'sub_3_2', name: 'Database Schemas', description: 'PostgreSQL tables and migration scripts'),
          ProjectSubModule(id: 'sub_3_3', name: 'Payment Integrations', description: 'Stripe and Razorpay gateways'),
        ],
      ),
      const ProjectModule(
        id: 'mod_4',
        name: 'QA & Testing',
        description: 'Automated test suites, user acceptance and performance optimization.',
        subModules: [
          ProjectSubModule(id: 'sub_4_1', name: 'Regression Testing', description: 'End to end flow verification'),
          ProjectSubModule(id: 'sub_4_2', name: 'Load & Benchmark Testing', description: 'Stress tests under high traffic'),
        ],
      ),
    ];

    // Project 1: Website Redesign
    final proj1Tasks = [
      ProjectTask(
        id: 't1',
        title: 'Create wireframes and mockups',
        category: 'Design',
        status: 'Done',
        dueDate: DateTime(2024, 4, 12),
        assignee: allEmployees[0],
        moduleName: 'UI/UX & Design System',
        subModuleName: 'Wireframes & Architecture',
      ),
      ProjectTask(
        id: 't2',
        title: 'UI Design Implementation',
        category: 'Design',
        status: 'Done',
        dueDate: DateTime(2024, 4, 18),
        assignee: allEmployees[0],
        moduleName: 'UI/UX & Design System',
        subModuleName: 'Design Tokens & Theme',
      ),
      ProjectTask(
        id: 't3',
        title: 'Frontend Development',
        category: 'Development',
        status: 'In Progress',
        dueDate: DateTime(2024, 4, 22),
        assignee: allEmployees[1],
        moduleName: 'Frontend Development',
        subModuleName: 'Core Layout & Navigation',
      ),
      ProjectTask(
        id: 't4',
        title: 'Backend Integration',
        category: 'Development',
        status: 'In Progress',
        dueDate: DateTime(2024, 4, 28),
        assignee: allEmployees[2],
        moduleName: 'Backend & APIs',
        subModuleName: 'OAuth & Session Management',
      ),
      ProjectTask(
        id: 't5',
        title: 'Testing and Bug Fixing',
        category: 'Testing',
        status: 'To Do',
        dueDate: DateTime(2024, 5, 5),
        assignee: allEmployees[4],
        moduleName: 'QA & Testing',
        subModuleName: 'Regression Testing',
      ),
      ProjectTask(
        id: 't6',
        title: 'User Acceptance Testing',
        category: 'Testing',
        status: 'To Do',
        dueDate: DateTime(2024, 5, 8),
        assignee: allEmployees[3],
        moduleName: 'QA & Testing',
        subModuleName: 'Regression Testing',
      ),
      ProjectTask(
        id: 't7',
        title: 'Deployment and Launch',
        category: 'Development',
        status: 'To Do',
        dueDate: DateTime(2024, 5, 12),
        assignee: allEmployees[4],
        moduleName: 'Frontend Development',
        subModuleName: 'Core Layout & Navigation',
      ),
    ];
    // Additional tasks
    for (int i = 8; i <= 15; i++) {
      proj1Tasks.add(ProjectTask(
        id: 't$i',
        title: 'Asset Redesign Milestone #$i',
        category: 'Design',
        status: 'Done',
        dueDate: DateTime(2024, 4, 15),
        assignee: allEmployees[0],
        moduleName: 'UI/UX & Design System',
        subModuleName: 'Design Tokens & Theme',
      ));
    }
    for (int i = 16; i <= 21; i++) {
      proj1Tasks.add(ProjectTask(
        id: 't$i',
        title: 'Responsive UI Coding #$i',
        category: 'Development',
        status: 'In Progress',
        dueDate: DateTime(2024, 4, 25),
        assignee: allEmployees[1],
        moduleName: 'Frontend Development',
        subModuleName: 'Component Library',
      ));
    }
    for (int i = 22; i <= 24; i++) {
      proj1Tasks.add(ProjectTask(
        id: 't$i',
        title: 'Quality Assurance check #$i',
        category: 'Testing',
        status: 'To Do',
        dueDate: DateTime(2024, 5, 1),
        assignee: allEmployees[4],
        moduleName: 'QA & Testing',
        subModuleName: 'Regression Testing',
      ));
    }

    final proj1Timeline = [
      ProjectTimelineEvent(id: 'm1', title: 'Project Created', subtitle: '10 Apr 2024 • 10:30 AM', date: DateTime(2024, 4, 10), isCompleted: true),
      ProjectTimelineEvent(id: 'm2', title: 'Requirement Gathering', subtitle: '12 Apr 2024 • 02:00 PM', date: DateTime(2024, 4, 12), isCompleted: true),
      ProjectTimelineEvent(id: 'm3', title: 'Design Phase Completed', subtitle: '18 Apr 2024 • 11:15 AM', date: DateTime(2024, 4, 18), isCompleted: true),
      ProjectTimelineEvent(id: 'm4', title: 'Development Sprint #1 Started', subtitle: '22 Apr 2024 • 09:00 AM', date: DateTime(2024, 4, 22), isCompleted: true),
      ProjectTimelineEvent(id: 'm5', title: 'New Team Members Onboarded', subtitle: 'Full past project history access enabled', date: DateTime(2024, 4, 25), isCompleted: true),
      ProjectTimelineEvent(id: 'm6', title: 'Testing & QA Review', subtitle: 'In Progress • Expected by 05 May 2024', date: DateTime(2024, 5, 5), isCompleted: false),
      ProjectTimelineEvent(id: 'm7', title: 'Final Deployment', subtitle: 'Scheduled for 15 May 2024', date: DateTime(2024, 5, 15), isCompleted: false),
    ];

    final proj1Files = const [
      ProjectFile(id: 'f1', name: 'Project_Requirement.pdf', sizeMb: 2.4, type: 'PDF'),
      ProjectFile(id: 'f2', name: 'Design_System.fig', sizeMb: 5.7, type: 'FIG'),
    ];

    // Project 2: Mobile App Development
    final p2Modules = [
      const ProjectModule(
        id: 'p2_mod1',
        name: 'Flutter Architecture',
        description: 'Folder structure, routing, and GetX state bindings.',
        subModules: [
          ProjectSubModule(id: 'p2_s1', name: 'Dependency Injection', description: 'Core GetX bindings'),
          ProjectSubModule(id: 'p2_s2', name: 'Theme & Design System', description: 'Material3 and typography'),
        ],
      ),
      const ProjectModule(
        id: 'p2_mod2',
        name: 'API & Gateway',
        description: 'REST API client, caching, and offline support.',
        subModules: [
          ProjectSubModule(id: 'p2_s3', name: 'Dio Network Layer', description: 'Interceptors and token refresh'),
          ProjectSubModule(id: 'p2_s4', name: 'Payment SDKs', description: 'App Store and In-App purchases'),
        ],
      ),
    ];

    final proj2Tasks = [
      ProjectTask(id: 'pt1', title: 'Flutter App Setup', category: 'Development', status: 'Done', dueDate: DateTime(2024, 6, 1), assignee: allEmployees[1], moduleName: 'Flutter Architecture', subModuleName: 'Dependency Injection'),
      ProjectTask(id: 'pt2', title: 'State Management Integration', category: 'Development', status: 'Done', dueDate: DateTime(2024, 6, 4), assignee: allEmployees[2], moduleName: 'Flutter Architecture', subModuleName: 'Theme & Design System'),
      ProjectTask(id: 'pt3', title: 'API Integration', category: 'Development', status: 'In Progress', dueDate: DateTime(2024, 6, 8), assignee: allEmployees[3], moduleName: 'API & Gateway', subModuleName: 'Dio Network Layer'),
      ProjectTask(id: 'pt4', title: 'UX Optimization', category: 'Design', status: 'To Do', dueDate: DateTime(2024, 6, 10), assignee: allEmployees[0], moduleName: 'Flutter Architecture', subModuleName: 'Theme & Design System'),
      ProjectTask(id: 'pt5', title: 'App Store Guidelines Review', category: 'Testing', status: 'To Do', dueDate: DateTime(2024, 6, 12), assignee: allEmployees[4], moduleName: 'API & Gateway', subModuleName: 'Payment SDKs'),
    ];

    // Project 3: CRM Integration
    final proj3Tasks = [
      ProjectTask(id: 'ct1', title: 'Database Auditing', category: 'Testing', status: 'Done', dueDate: DateTime(2024, 4, 10), assignee: allEmployees[3], moduleName: 'Data Pipeline', subModuleName: 'Auditing'),
      ProjectTask(id: 'ct2', title: 'API Gateway Connector', category: 'Development', status: 'In Progress', dueDate: DateTime(2024, 4, 15), assignee: allEmployees[2], moduleName: 'Connector Engine', subModuleName: 'Sync Services'),
      ProjectTask(id: 'ct3', title: 'Contact synchronization', category: 'Development', status: 'To Do', dueDate: DateTime(2024, 4, 20), assignee: allEmployees[1], moduleName: 'Connector Engine', subModuleName: 'Sync Services'),
      ProjectTask(id: 'ct4', title: 'Sales Funnel mapping', category: 'Design', status: 'To Do', dueDate: DateTime(2024, 4, 22), assignee: allEmployees[0], moduleName: 'Funnel Logic', subModuleName: 'Visual Builder'),
    ];

    // Project 4: Marketing Campaign (Digital Marketing, Completed)
    final proj4Tasks = [
      ProjectTask(id: 'mt1', title: 'Ad Creative Design', category: 'Design', status: 'Done', dueDate: DateTime(2024, 2, 10), assignee: allEmployees[0], moduleName: 'Creatives', subModuleName: 'Banners'),
      ProjectTask(id: 'mt2', title: 'Copywriting Approvals', category: 'Design', status: 'Done', dueDate: DateTime(2024, 2, 15), assignee: allEmployees[1], moduleName: 'Copywriting', subModuleName: 'Headlines'),
      ProjectTask(id: 'mt3', title: 'Social Ads Campaign launch', category: 'Development', status: 'Done', dueDate: DateTime(2024, 2, 20), assignee: allEmployees[2], moduleName: 'Campaign Setup', subModuleName: 'Ad Manager'),
      ProjectTask(id: 'mt4', title: 'Weekly Reports collation', category: 'Testing', status: 'Done', dueDate: DateTime(2024, 3, 1), assignee: allEmployees[3], moduleName: 'Reporting', subModuleName: 'Roas Metrics'),
    ];

    // Project 5: E-commerce Platform (Web Development, Not Started)
    final proj5Tasks = [
      ProjectTask(id: 'et1', title: 'Define Information Architecture', category: 'Design', status: 'To Do', dueDate: DateTime(2024, 6, 15), assignee: allEmployees[0], moduleName: 'Catalog Architecture', subModuleName: 'Category Hierarchy'),
      ProjectTask(id: 'et2', title: 'Payment Gateway selection', category: 'Development', status: 'To Do', dueDate: DateTime(2024, 6, 20), assignee: allEmployees[2], moduleName: 'Checkout & Cart', subModuleName: 'Payment Flow'),
      ProjectTask(id: 'et3', title: 'Database Schema creation', category: 'Development', status: 'To Do', dueDate: DateTime(2024, 6, 25), assignee: allEmployees[1], moduleName: 'Backend & Data', subModuleName: 'Schemas'),
      ProjectTask(id: 'et4', title: 'Product catalog loading', category: 'Testing', status: 'To Do', dueDate: DateTime(2024, 6, 30), assignee: allEmployees[4], moduleName: 'Catalog Architecture', subModuleName: 'CSV Importer'),
    ];

    projects.addAll([
      Project(
        id: 'p1',
        name: 'Website Redesign',
        description: 'Redesign and develop the company website with new UI/UX, improve performance and ensure mobile responsiveness.',
        category: 'Web Development',
        status: 'In Progress',
        startDate: DateTime(2024, 4, 10),
        endDate: DateTime(2024, 5, 15),
        teamMembers: [allEmployees[0], allEmployees[1], allEmployees[2], allEmployees[3], allEmployees[4]],
        tasks: proj1Tasks,
        timeline: proj1Timeline,
        files: proj1Files,
        modules: p1Modules,
      ),
      Project(
        id: 'p2',
        name: 'Mobile App Development',
        description: 'Create a cross-platform mobile application utilizing Flutter to streamline client communication and booking systems.',
        category: 'Mobile Development',
        status: 'In Progress',
        startDate: DateTime(2024, 5, 1),
        endDate: DateTime(2024, 6, 10),
        teamMembers: [allEmployees[1], allEmployees[2], allEmployees[3], allEmployees[0], allEmployees[4], allEmployees[5]],
        tasks: proj2Tasks,
        timeline: [
          ProjectTimelineEvent(id: 'p2t1', title: 'Project Created', subtitle: '01 May 2024', date: DateTime(2024, 5, 1), isCompleted: true),
          ProjectTimelineEvent(id: 'p2t2', title: 'App Architecture Design', subtitle: '08 May 2024', date: DateTime(2024, 5, 8), isCompleted: true),
        ],
        files: const [
          ProjectFile(id: 'pf2_1', name: 'Mobile_Sitemap.pdf', sizeMb: 1.8, type: 'PDF'),
        ],
        modules: p2Modules,
      ),
      Project(
        id: 'p3',
        name: 'CRM Integration',
        description: 'Deploy and synchronize our sales pipelines with custom Salesforce integration modules to track client conversions.',
        category: 'Software Integration',
        status: 'On Hold',
        startDate: DateTime(2024, 3, 1),
        endDate: DateTime(2024, 4, 20),
        teamMembers: [allEmployees[2], allEmployees[3], allEmployees[0], allEmployees[1]],
        tasks: proj3Tasks,
        timeline: [
          ProjectTimelineEvent(id: 'p3t1', title: 'Integration Kickoff', subtitle: '01 Mar 2024', date: DateTime(2024, 3, 1), isCompleted: true),
        ],
        files: const [],
        modules: const [
          ProjectModule(id: 'crm_m1', name: 'Connector Engine', description: 'Pipeline sync', subModules: [
            ProjectSubModule(id: 'crm_s1', name: 'Sync Services', description: 'REST synchronizer'),
          ]),
        ],
      ),
      Project(
        id: 'p4',
        name: 'Marketing Campaign',
        description: 'Coordinate digital brand push on Google Ads, Meta Ads, and LinkedIn to generate enterprise software leads.',
        category: 'Digital Marketing',
        status: 'Completed',
        startDate: DateTime(2024, 1, 15),
        endDate: DateTime(2024, 3, 1),
        teamMembers: [allEmployees[0], allEmployees[1], allEmployees[2], allEmployees[3], allEmployees[4]],
        tasks: proj4Tasks,
        timeline: [
          ProjectTimelineEvent(id: 'p4t1', title: 'Campaign Setup', subtitle: '15 Jan 2024', date: DateTime(2024, 1, 15), isCompleted: true),
          ProjectTimelineEvent(id: 'p4t2', title: 'Campaign Completed', subtitle: '01 Mar 2024', date: DateTime(2024, 3, 1), isCompleted: true),
        ],
        files: const [
          ProjectFile(id: 'pf4_1', name: 'Marketing_Roas_Report.pdf', sizeMb: 4.1, type: 'PDF'),
        ],
        modules: const [],
      ),
      Project(
        id: 'p5',
        name: 'E-commerce Platform',
        description: 'Build a multi-vendor digital commerce store containing shopping baskets, product tags, and automated merchant payouts.',
        category: 'Web Development',
        status: 'Not Started',
        startDate: DateTime(2024, 5, 20),
        endDate: DateTime(2024, 6, 30),
        teamMembers: [allEmployees[0], allEmployees[2], allEmployees[1], allEmployees[4]],
        tasks: proj5Tasks,
        timeline: [
          ProjectTimelineEvent(id: 'p5t1', title: 'Platform Scoping', subtitle: 'Scheduled for 20 May 2024', date: DateTime(2024, 5, 20), isCompleted: false),
        ],
        files: const [],
        modules: const [],
      ),
    ]);
  }

  // Filtered projects feed
  List<Project> get filteredProjects {
    List<Project> results = projects;

    // Filter by tab status
    if (selectedTab.value != 'All') {
      results = results.where((p) => p.status == selectedTab.value).toList();
    }

    // Filter by search query
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      results = results.where((p) => p.name.toLowerCase().contains(q) || p.category.toLowerCase().contains(q)).toList();
    }

    return results;
  }

  // Clear creation form
  void clearForm() {
    nameController.clear();
    descriptionController.clear();
    selectedCategory.value = 'Web Development';
    selectedStatus.value = 'Not Started';
    startDate.value = DateTime.now();
    endDate.value = DateTime.now().add(const Duration(days: 30));
    selectedEmployees.clear();
    selectedFiles.clear();
  }

  // Populate form for editing
  void populateForm(Project p) {
    nameController.text = p.name;
    descriptionController.text = p.description;
    selectedCategory.value = p.category;
    selectedStatus.value = p.status;
    startDate.value = p.startDate;
    endDate.value = p.endDate;
    selectedEmployees.assignAll(p.teamMembers);
    selectedFiles.assignAll(p.files);
  }

  // Save new project
  void saveProject() {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Project Name is required!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    final newProj = Project(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: nameController.text.trim(),
      description: descriptionController.text.trim(),
      category: selectedCategory.value,
      status: selectedStatus.value,
      startDate: startDate.value,
      endDate: endDate.value,
      teamMembers: List<AppUser>.from(selectedEmployees),
      tasks: [
        // Automatically add standard kick-off tasks
        ProjectTask(
          id: 't_kickoff_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Initial Kickoff & Architecture Alignment',
          category: 'Design',
          status: selectedStatus.value == 'Completed' ? 'Done' : 'To Do',
          dueDate: endDate.value,
          assignee: selectedEmployees.isNotEmpty ? selectedEmployees.first : null,
        )
      ],
      timeline: [
        ProjectTimelineEvent(
          id: 'm_created_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Project Created',
          subtitle: 'System logged project initialization',
          date: startDate.value,
          isCompleted: true,
        ),
      ],
      files: List<ProjectFile>.from(selectedFiles),
    );

    projects.add(newProj);
    clearForm();
    Get.back();
    Get.snackbar(
      'Success',
      'Project created successfully!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
    );
  }

  // Update existing project
  void updateProject() {
    final current = selectedProject.value;
    if (current == null) return;

    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Project Name is required!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    final updated = current.copyWith(
      name: nameController.text.trim(),
      description: descriptionController.text.trim(),
      category: selectedCategory.value,
      status: selectedStatus.value,
      startDate: startDate.value,
      endDate: endDate.value,
      teamMembers: List<AppUser>.from(selectedEmployees),
      files: List<ProjectFile>.from(selectedFiles),
    );

    final idx = projects.indexWhere((p) => p.id == current.id);
    if (idx != -1) {
      projects[idx] = updated;
    }
    selectedProject.value = updated;

    clearForm();
    Get.back();
    Get.snackbar(
      'Updated',
      'Project details updated successfully!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF4F46E5),
      colorText: Colors.white,
    );
  }

  // Delete project
  void deleteProject(String id) {
    projects.removeWhere((p) => p.id == id);
    if (selectedProject.value?.id == id) {
      selectedProject.value = null;
    }
    Get.back(); // Dismiss dialog or sheet
    Get.back(); // Pop from screen details
    Get.snackbar(
      'Deleted',
      'Project has been removed successfully!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
    );
  }

  // Toggle checklist assignment of team members in bottom sheet form
  void toggleEmployeeSelection(AppUser emp) {
    if (selectedEmployees.contains(emp)) {
      selectedEmployees.remove(emp);
    } else {
      selectedEmployees.add(emp);
    }
  }

  // Add a task to the active project (Jira-style with module and submodule)
  void addTaskToProject(
    String title,
    String category,
    AppUser? assignee,
    DateTime due, {
    String moduleName = 'General',
    String subModuleName = 'Default',
  }) {
    final current = selectedProject.value;
    if (current == null) return;

    final newTask = ProjectTask(
      id: 'task_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      category: category,
      status: 'To Do',
      dueDate: due,
      assignee: assignee,
      moduleName: moduleName,
      subModuleName: subModuleName,
    );

    // Create a new tasks list and deep copy
    final updatedTasks = List<ProjectTask>.from(current.tasks)..add(newTask);
    final updated = current.copyWith(tasks: updatedTasks);

    // Update main database
    final idx = projects.indexWhere((p) => p.id == current.id);
    if (idx != -1) {
      projects[idx] = updated;
    }
    selectedProject.value = updated;

    Get.snackbar(
      'Task Added',
      'New task allocated to ${assignee?.name ?? "unassigned"} in [$moduleName]',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
    );
  }

  // Toggle/Change status of a task inside a project
  void changeTaskStatus(String taskId, String newStatus) {
    final current = selectedProject.value;
    if (current == null) return;

    final updatedTasks = current.tasks.map((task) {
      if (task.id == taskId) {
        return task.copyWith(status: newStatus);
      }
      return task;
    }).toList();

    // Auto-update project overall status based on tasks progress
    String projectOverallStatus = current.status;
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

    final updated = current.copyWith(tasks: updatedTasks, status: projectOverallStatus);

    final idx = projects.indexWhere((p) => p.id == current.id);
    if (idx != -1) {
      projects[idx] = updated;
    }
    selectedProject.value = updated;

    // Sync back to TasksController if registered
    if (Get.isRegistered<TasksController>()) {
      Get.find<TasksController>().syncStatusFromProject(taskId, newStatus);
    }
  }

  // Remove member from project details/edit screen
  void removeMember(AppUser emp) {
    final current = selectedProject.value;
    if (current == null) return;

    final updatedMembers = List<AppUser>.from(current.teamMembers)..remove(emp);
    final updated = current.copyWith(teamMembers: updatedMembers);

    final idx = projects.indexWhere((p) => p.id == current.id);
    if (idx != -1) {
      projects[idx] = updated;
    }
    selectedProject.value = updated;
  }

  // Add multiple members to active project - newly added members get access to all past tasks and project history!
  void assignMembersToProject(List<AppUser> members) {
    final current = selectedProject.value;
    if (current == null) return;

    final updatedMembers = Set<AppUser>.from(current.teamMembers)..addAll(members);
    
    // Add timeline milestone for newly onboarded member
    final newEvents = members.map((m) => ProjectTimelineEvent(
      id: 'onboard_${DateTime.now().millisecondsSinceEpoch}_${m.name.hashCode}',
      title: '${m.name} joined project team',
      subtitle: 'Granted full access to all past tasks, modules, and work history',
      date: DateTime.now(),
      isCompleted: true,
    )).toList();

    final updatedTimeline = List<ProjectTimelineEvent>.from(current.timeline)..addAll(newEvents);
    final updated = current.copyWith(
      teamMembers: updatedMembers.toList(),
      timeline: updatedTimeline,
    );

    final idx = projects.indexWhere((p) => p.id == current.id);
    if (idx != -1) {
      projects[idx] = updated;
    }
    selectedProject.value = updated;

    Get.snackbar(
      'Member Added',
      '${members.map((m) => m.name).join(", ")} added to project with full past work history.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
    );
  }

  // Add Jira Module to Project
  void addModuleToProject(String name, String description, List<String> subModuleNames) {
    final current = selectedProject.value;
    if (current == null) return;

    final subModules = subModuleNames.map((s) => ProjectSubModule(
      id: 'sub_${DateTime.now().millisecondsSinceEpoch}_${s.hashCode}',
      name: s.trim(),
    )).toList();

    final newModule = ProjectModule(
      id: 'mod_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      description: description.trim(),
      subModules: subModules,
    );

    final updatedModules = List<ProjectModule>.from(current.modules)..add(newModule);
    final updated = current.copyWith(modules: updatedModules);

    final idx = projects.indexWhere((p) => p.id == current.id);
    if (idx != -1) {
      projects[idx] = updated;
    }
    selectedProject.value = updated;

    Get.snackbar(
      'Module Created',
      'Module "$name" with ${subModules.length} sub-modules created successfully!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
    );
  }

  // Add sub-module to existing module
  void addSubModuleToModule(String moduleId, String subModuleName) {
    final current = selectedProject.value;
    if (current == null) return;

    final updatedModules = current.modules.map((m) {
      if (m.id == moduleId) {
        final newSub = ProjectSubModule(
          id: 'sub_${DateTime.now().millisecondsSinceEpoch}',
          name: subModuleName.trim(),
        );
        return m.copyWith(subModules: List<ProjectSubModule>.from(m.subModules)..add(newSub));
      }
      return m;
    }).toList();

    final updated = current.copyWith(modules: updatedModules);
    final idx = projects.indexWhere((p) => p.id == current.id);
    if (idx != -1) {
      projects[idx] = updated;
    }
    selectedProject.value = updated;
  }

  // Mock upload / attach file helper
  void addMockFile(String name, double size, String ext) {
    final file = ProjectFile(
      id: 'f_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      sizeMb: size,
      type: ext.toUpperCase(),
    );
    selectedFiles.add(file);
  }
}
