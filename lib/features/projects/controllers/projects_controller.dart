import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../role_permissions/models/role_permission_models.dart';
import '../models/project_model.dart';

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
    // Project 1: Website Redesign
    final proj1Tasks = [
      ProjectTask(id: 't1', title: 'Create wireframes and mockups', category: 'Design', status: 'Done', dueDate: DateTime(2024, 4, 12), assignee: allEmployees[0]),
      ProjectTask(id: 't2', title: 'UI Design Implementation', category: 'Design', status: 'Done', dueDate: DateTime(2024, 4, 18), assignee: allEmployees[0]),
      ProjectTask(id: 't3', title: 'Frontend Development', category: 'Development', status: 'In Progress', dueDate: DateTime(2024, 4, 22), assignee: allEmployees[1]),
      ProjectTask(id: 't4', title: 'Backend Integration', category: 'Development', status: 'In Progress', dueDate: DateTime(2024, 4, 28), assignee: allEmployees[2]),
      ProjectTask(id: 't5', title: 'Testing and Bug Fixing', category: 'Testing', status: 'To Do', dueDate: DateTime(2024, 5, 5), assignee: allEmployees[4]),
      ProjectTask(id: 't6', title: 'User Acceptance Testing', category: 'Testing', status: 'To Do', dueDate: DateTime(2024, 5, 8), assignee: allEmployees[3]),
      ProjectTask(id: 't7', title: 'Deployment and Launch', category: 'Development', status: 'To Do', dueDate: DateTime(2024, 5, 12), assignee: allEmployees[4]),
    ];
    // Pad to match "24 tasks" metric in the mockup: 10 Done, 8 In Progress, 6 Pending (To Do)
    for (int i = 8; i <= 15; i++) {
      proj1Tasks.add(ProjectTask(id: 't$i', title: 'Asset Redesign Milestone #$i', category: 'Design', status: 'Done', dueDate: DateTime(2024, 4, 15), assignee: allEmployees[0]));
    }
    for (int i = 16; i <= 21; i++) {
      proj1Tasks.add(ProjectTask(id: 't$i', title: 'Responsive UI Coding #$i', category: 'Development', status: 'In Progress', dueDate: DateTime(2024, 4, 25), assignee: allEmployees[1]));
    }
    for (int i = 22; i <= 24; i++) {
      proj1Tasks.add(ProjectTask(id: 't$i', title: 'Quality Assurance check #$i', category: 'Testing', status: 'To Do', dueDate: DateTime(2024, 5, 1), assignee: allEmployees[4]));
    }

    final proj1Timeline = [
      ProjectTimelineEvent(id: 'm1', title: 'Project Created', subtitle: '10 Apr 2024 • 10:30 AM', date: DateTime(2024, 4, 10), isCompleted: true),
      ProjectTimelineEvent(id: 'm2', title: 'Requirement Gathering', subtitle: '12 Apr 2024 • 02:00 PM', date: DateTime(2024, 4, 12), isCompleted: true),
      ProjectTimelineEvent(id: 'm3', title: 'Design Phase', subtitle: '18 Apr 2024 • 11:15 AM', date: DateTime(2024, 4, 18), isCompleted: true),
      ProjectTimelineEvent(id: 'm4', title: 'Development Phase', subtitle: '22 Apr 2024 • 09:00 AM', date: DateTime(2024, 4, 22), isCompleted: true),
      ProjectTimelineEvent(id: 'm5', title: 'Testing Phase', subtitle: 'In Progress • Expected by 05 May 2024', date: DateTime(2024, 5, 5), isCompleted: false),
      ProjectTimelineEvent(id: 'm6', title: 'Review & Feedback', subtitle: 'Scheduled', date: DateTime(2024, 5, 10), isCompleted: false),
      ProjectTimelineEvent(id: 'm7', title: 'Project Completed', subtitle: 'Scheduled', date: DateTime(2024, 5, 15), isCompleted: false),
    ];

    final proj1Files = const [
      ProjectFile(id: 'f1', name: 'Project_Requirement.pdf', sizeMb: 2.4, type: 'PDF'),
      ProjectFile(id: 'f2', name: 'Design_System.fig', sizeMb: 5.7, type: 'FIG'),
    ];

    // Project 2: Mobile App Development
    final proj2Tasks = [
      ProjectTask(id: 'pt1', title: 'Flutter App Setup', category: 'Development', status: 'Done', dueDate: DateTime(2024, 6, 1), assignee: allEmployees[1]),
      ProjectTask(id: 'pt2', title: 'State Management Integration', category: 'Development', status: 'Done', dueDate: DateTime(2024, 6, 4), assignee: allEmployees[2]),
      ProjectTask(id: 'pt3', title: 'API Integration', category: 'Development', status: 'In Progress', dueDate: DateTime(2024, 6, 8), assignee: allEmployees[3]),
      ProjectTask(id: 'pt4', title: 'UX Optimization', category: 'Design', status: 'To Do', dueDate: DateTime(2024, 6, 10), assignee: allEmployees[0]),
      ProjectTask(id: 'pt5', title: 'App Store Guidelines Review', category: 'Testing', status: 'To Do', dueDate: DateTime(2024, 6, 12), assignee: allEmployees[4]),
    ];

    // Project 3: CRM Integration
    final proj3Tasks = [
      ProjectTask(id: 'ct1', title: 'Database Auditing', category: 'Testing', status: 'Done', dueDate: DateTime(2024, 4, 10), assignee: allEmployees[3]),
      ProjectTask(id: 'ct2', title: 'API Gateway Connector', category: 'Development', status: 'In Progress', dueDate: DateTime(2024, 4, 15), assignee: allEmployees[2]),
      ProjectTask(id: 'ct3', title: 'Contact synchronization', category: 'Development', status: 'To Do', dueDate: DateTime(2024, 4, 20), assignee: allEmployees[1]),
      ProjectTask(id: 'ct4', title: 'Sales Funnel mapping', category: 'Design', status: 'To Do', dueDate: DateTime(2024, 4, 22), assignee: allEmployees[0]),
    ];

    // Project 4: Marketing Campaign (Digital Marketing, Completed)
    final proj4Tasks = [
      ProjectTask(id: 'mt1', title: 'Ad Creative Design', category: 'Design', status: 'Done', dueDate: DateTime(2024, 2, 10), assignee: allEmployees[0]),
      ProjectTask(id: 'mt2', title: 'Copywriting Approvals', category: 'Design', status: 'Done', dueDate: DateTime(2024, 2, 15), assignee: allEmployees[1]),
      ProjectTask(id: 'mt3', title: 'Social Ads Campaign launch', category: 'Development', status: 'Done', dueDate: DateTime(2024, 2, 20), assignee: allEmployees[2]),
      ProjectTask(id: 'mt4', title: 'Weekly Reports collation', category: 'Testing', status: 'Done', dueDate: DateTime(2024, 3, 1), assignee: allEmployees[3]),
    ];

    // Project 5: E-commerce Platform (Web Development, Not Started)
    final proj5Tasks = [
      ProjectTask(id: 'et1', title: 'Define Information Architecture', category: 'Design', status: 'To Do', dueDate: DateTime(2024, 6, 15), assignee: allEmployees[0]),
      ProjectTask(id: 'et2', title: 'Payment Gateway selection', category: 'Development', status: 'To Do', dueDate: DateTime(2024, 6, 20), assignee: allEmployees[2]),
      ProjectTask(id: 'et3', title: 'Database Schema creation', category: 'Development', status: 'To Do', dueDate: DateTime(2024, 6, 25), assignee: allEmployees[1]),
      ProjectTask(id: 'et4', title: 'Product catalog loading', category: 'Testing', status: 'To Do', dueDate: DateTime(2024, 6, 30), assignee: allEmployees[4]),
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

  // Add a task to the active project
  void addTaskToProject(String title, String category, AppUser? assignee, DateTime due) {
    final current = selectedProject.value;
    if (current == null) return;

    final newTask = ProjectTask(
      id: 'task_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      category: category,
      status: 'To Do',
      dueDate: due,
      assignee: assignee,
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
      'New task assigned to ${assignee?.name ?? "unassigned"}',
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

    final updated = current.copyWith(tasks: updatedTasks);

    final idx = projects.indexWhere((p) => p.id == current.id);
    if (idx != -1) {
      projects[idx] = updated;
    }
    selectedProject.value = updated;
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

  // Add multiple members to active project
  void assignMembersToProject(List<AppUser> members) {
    final current = selectedProject.value;
    if (current == null) return;

    final updatedMembers = Set<AppUser>.from(current.teamMembers)..addAll(members);
    final updated = current.copyWith(teamMembers: updatedMembers.toList());

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
