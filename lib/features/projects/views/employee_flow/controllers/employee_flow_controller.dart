import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../models/employee_flow_models.dart';

class EmployeeFlowController extends GetxController {
  static EmployeeFlowController get to => Get.find<EmployeeFlowController>();

  // Profile
  final Rx<EmployeeUserProfile> currentUser = const EmployeeUserProfile(
    name: 'Aarav Sharma',
    role: 'Frontend Developer',
    department: 'Engineering',
    employeeId: 'EMP-104',
  ).obs;

  // Navigation
  final RxInt selectedNavIndex = 0.obs; // 0: Home, 1: Tasks, 2: Projects, 3: Time Log

  // Projects filter & search
  final RxString projectFilter = 'Active'.obs; // 'Active', 'On Hold', 'Completed'
  final RxString projectSearchQuery = ''.obs;
  final TextEditingController projectSearchController = TextEditingController();

  // Tasks filter & search
  final RxString taskFilter = 'All'.obs; // 'All', 'In Progress', 'Completed', 'Pending'
  final RxString taskSearchQuery = ''.obs;
  final TextEditingController taskSearchController = TextEditingController();

  // Time Log period toggle
  final RxString timeLogPeriod = 'This Week'.obs; // 'This Week', 'This Month'

  // Data Collections
  final RxList<EmployeeFlowProject> projects = <EmployeeFlowProject>[].obs;
  late Rx<EmployeeFlowProject> selectedProject;
  final RxList<EmployeeFlowTask> allTasks = <EmployeeFlowTask>[].obs;
  final RxList<EmployeeFlowHandoverRecord> globalHandoverHistory = <EmployeeFlowHandoverRecord>[].obs;
  final RxList<ProjectFileItem> allProjectFiles = <ProjectFileItem>[].obs;

  // Active Running Task & Timer
  final Rxn<EmployeeFlowTask> activeRunningTask = Rxn<EmployeeFlowTask>();
  Timer? _liveTicker;

  @override
  void onInit() {
    super.onInit();
    _loadSampleData();
  }

  @override
  void onClose() {
    _liveTicker?.cancel();
    super.onClose();
  }

  void _loadSampleData() {
    // 1. Initial Handover History
    globalHandoverHistory.assignAll([
      const EmployeeFlowHandoverRecord(
        id: 'HO-01',
        taskTitle: 'User Authentication',
        timestamp: '15 Sep 2025, 02:00 PM',
        fromUser: 'Rohit Verma',
        fromUserRole: 'Senior Backend Engineer',
        toUser: 'Sneha Patel',
        toUserRole: 'Frontend Developer',
        reason: 'Workload balance',
        notes: 'Handed over auth token refresh logic and frontend validation.',
        status: 'Approved',
        progressAtHandover: 60.0,
      ),
      const EmployeeFlowHandoverRecord(
        id: 'HO-02',
        taskTitle: 'Design Login Screen',
        timestamp: '10 Sep 2025, 11:30 AM',
        fromUser: 'Sneha Patel',
        fromUserRole: 'UI/UX Designer',
        toUser: 'Neha Singh',
        toUserRole: 'Product Designer',
        reason: 'Leave',
        notes: 'Sneha went on personal leave. Neha finalized the Figma components.',
        status: 'Approved',
        progressAtHandover: 80.0,
      ),
    ]);

    // 2. Tasks List
    final sampleTasks = [
      EmployeeFlowTask(
        id: 'TSK-101',
        title: 'Design Login Screen',
        moduleTitle: 'UI/UX Design',
        projectId: 'PRJ-001',
        projectName: 'E-Commerce Mobile App',
        status: 'In Progress',
        priority: 'High',
        dueDate: '18 Sep 2025',
        startDate: '14 Sep 2025',
        allocatedHours: 8.0,
        initialSpentHours: 6.0,
        description: 'Design interactive, accessible login and register screens in Figma with dark and light theme tokens.',
        workSessions: [
          EmployeeWorkSession(
            id: 'SES-01',
            startTime: DateTime.now().subtract(const Duration(hours: 6)),
            endTime: DateTime.now().subtract(const Duration(hours: 3)),
            duration: const Duration(hours: 3),
          ),
          EmployeeWorkSession(
            id: 'SES-02',
            startTime: DateTime.now().subtract(const Duration(hours: 3)),
            endTime: DateTime.now().subtract(const Duration(hours: 2, minutes: 30)),
            isBreak: true,
            breakReason: 'Lunch Break',
            duration: const Duration(minutes: 30),
          ),
          EmployeeWorkSession(
            id: 'SES-03',
            startTime: DateTime.now().subtract(const Duration(hours: 2, minutes: 30)),
            endTime: DateTime.now().subtract(const Duration(minutes: 30)),
            duration: const Duration(hours: 2),
          ),
        ],
      ),
      EmployeeFlowTask(
        id: 'TSK-102',
        title: 'API Integration',
        moduleTitle: 'Backend',
        projectId: 'PRJ-001',
        projectName: 'E-Commerce Mobile App',
        status: 'In Progress',
        priority: 'High',
        dueDate: '20 Sep 2025',
        startDate: '16 Sep 2025',
        allocatedHours: 8.0,
        initialSpentHours: 4.0,
        description: 'Integrate catalog APIs with caching, retry logic and error state handling.',
        workSessions: [
          EmployeeWorkSession(
            id: 'SES-04',
            startTime: DateTime.now().subtract(const Duration(hours: 4)),
            endTime: DateTime.now().subtract(const Duration(hours: 1)),
            duration: const Duration(hours: 3),
          ),
        ],
      ),
      EmployeeFlowTask(
        id: 'TSK-103',
        title: 'User Authentication',
        moduleTitle: 'Backend',
        projectId: 'PRJ-001',
        projectName: 'E-Commerce Mobile App',
        status: 'Completed',
        priority: 'Medium',
        dueDate: '15 Sep 2025',
        startDate: '10 Sep 2025',
        allocatedHours: 8.0,
        initialSpentHours: 8.0,
        description: 'Completed JWT token management, biometric login check and auto logout on expiration.',
        handoverHistory: [globalHandoverHistory.first],
      ),
      EmployeeFlowTask(
        id: 'TSK-104',
        title: 'Payment Integration',
        moduleTitle: 'Backend',
        projectId: 'PRJ-001',
        projectName: 'E-Commerce Mobile App',
        status: 'Pending',
        priority: 'High',
        dueDate: '22 Sep 2025',
        startDate: '21 Sep 2025',
        allocatedHours: 6.0,
        initialSpentHours: 0.0,
        description: 'Connect Razorpay / Stripe gateway with webhook confirmation and invoice generation.',
      ),
      EmployeeFlowTask(
        id: 'TSK-105',
        title: 'Checkout Flow Redesign',
        moduleTitle: 'Checkout & Cart',
        projectId: 'PRJ-001',
        projectName: 'E-Commerce Mobile App',
        status: 'In Progress',
        priority: 'Medium',
        dueDate: '25 Sep 2025',
        startDate: '18 Sep 2025',
        allocatedHours: 7.0,
        initialSpentHours: 5.5,
        description: 'Create multi-step address picker, delivery slot selector and payment method switch.',
      ),
      EmployeeFlowTask(
        id: 'TSK-106',
        title: 'Push Notification Service',
        moduleTitle: 'Notifications',
        projectId: 'PRJ-001',
        projectName: 'E-Commerce Mobile App',
        status: 'In Progress',
        priority: 'Low',
        dueDate: '28 Sep 2025',
        startDate: '22 Sep 2025',
        allocatedHours: 5.0,
        initialSpentHours: 6.5, // Exceeded overtime task example!
        description: 'FCM push notification setup for order tracking and discount alerts.',
      ),
      // PRJ-002 Tasks
      EmployeeFlowTask(
        id: 'TSK-201',
        title: 'Landing Page Wireframes',
        moduleTitle: 'UX Design',
        projectId: 'PRJ-002',
        projectName: 'Company Website Redesign',
        status: 'Completed',
        priority: 'High',
        dueDate: '01 Sep 2025',
        startDate: '20 Aug 2025',
        allocatedHours: 12.0,
        initialSpentHours: 11.0,
        description: 'High fidelity wireframes for corporate home, about, services and contact pages.',
      ),
      EmployeeFlowTask(
        id: 'TSK-202',
        title: 'Hero Section 3D Animations',
        moduleTitle: 'Frontend Development',
        projectId: 'PRJ-002',
        projectName: 'Company Website Redesign',
        status: 'In Progress',
        priority: 'High',
        dueDate: '10 Oct 2025',
        startDate: '01 Oct 2025',
        allocatedHours: 16.0,
        initialSpentHours: 10.0,
        description: 'Spline 3D interactive embed with Three.js webgl performance tuning.',
      ),
      EmployeeFlowTask(
        id: 'TSK-203',
        title: 'Hubspot CRM Lead Capture',
        moduleTitle: 'Integrations',
        projectId: 'PRJ-002',
        projectName: 'Company Website Redesign',
        status: 'Pending',
        priority: 'Medium',
        dueDate: '20 Oct 2025',
        startDate: '12 Oct 2025',
        allocatedHours: 8.0,
        initialSpentHours: 0.0,
        description: 'Sync newsletter and contact submissions into Hubspot CRM pipeline.',
      ),
      // PRJ-003 Tasks
      EmployeeFlowTask(
        id: 'TSK-301',
        title: 'Leave Request Multi-level Approval',
        moduleTitle: 'Leave Engine',
        projectId: 'PRJ-003',
        projectName: 'HR Management System',
        status: 'In Progress',
        priority: 'High',
        dueDate: '15 Oct 2025',
        startDate: '01 Oct 2025',
        allocatedHours: 14.0,
        initialSpentHours: 8.5,
        description: 'Role-based approval routing for sick, casual and privilege leaves.',
      ),
    ];
    allTasks.assignAll(sampleTasks);

    // 3. Projects
    final sampleProjects = [
      EmployeeFlowProject(
        id: 'PRJ-001',
        code: 'PRJ-001',
        title: 'E-Commerce Mobile App',
        description: 'Build and maintain the E-Commerce application for Android & iOS.',
        status: 'Active',
        progress: 0.37,
        startDate: '01 Sep 2025',
        endDate: '31 Dec 2025',
        deadline: '31 Dec 2025',
        duration: '4 Months',
        daysLeft: 106,
        totalModules: 8,
        totalTasks: 24,
        myCompletedTasks: 8,
        myPendingTasks: 16,
        icon: Iconsax.shopping_cart,
        themeColor: const Color(0xFF3B206A),
        modules: [
          EmployeeFlowModule(
            id: 'MOD-01',
            projectId: 'PRJ-001',
            title: 'Authentication & Security',
            description: 'JWT Auth, biometric login, session store',
            totalTasks: 5,
            completedTasks: 4,
            progress: 0.80,
            status: 'In Progress',
            tasks: [sampleTasks[0], sampleTasks[2]],
          ),
          EmployeeFlowModule(
            id: 'MOD-02',
            projectId: 'PRJ-001',
            title: 'Product Catalog & Search',
            description: 'Category browsing, filter matrix, elastic search',
            totalTasks: 6,
            completedTasks: 2,
            progress: 0.35,
            status: 'In Progress',
            tasks: [sampleTasks[1]],
          ),
          EmployeeFlowModule(
            id: 'MOD-03',
            projectId: 'PRJ-001',
            title: 'Checkout & Payments',
            description: 'Payment gateway integration and cart checkout',
            totalTasks: 5,
            completedTasks: 1,
            progress: 0.20,
            status: 'In Progress',
            tasks: [sampleTasks[3], sampleTasks[4]],
          ),
          EmployeeFlowModule(
            id: 'MOD-04',
            projectId: 'PRJ-001',
            title: 'Push Notifications & Alerts',
            description: 'Order updates and promotional alerts',
            totalTasks: 4,
            completedTasks: 1,
            progress: 0.25,
            status: 'In Progress',
            tasks: [sampleTasks[5]],
          ),
        ],
        milestones: const [
          EmployeeFlowMilestone(
            id: 'MS-01',
            date: '01 Sep 2025',
            title: 'Project Started',
            status: 'Completed',
          ),
          EmployeeFlowMilestone(
            id: 'MS-02',
            date: '10 Sep 2025',
            title: 'Design Phase',
            status: 'Completed',
          ),
          EmployeeFlowMilestone(
            id: 'MS-03',
            date: '18 Sep 2025',
            title: 'Development Phase',
            status: 'In Progress',
          ),
          EmployeeFlowMilestone(
            id: 'MS-04',
            date: '01 Oct 2025',
            title: 'Testing Phase',
            status: 'Pending',
          ),
          EmployeeFlowMilestone(
            id: 'MS-05',
            date: '15 Oct 2025',
            title: 'UAT & Bug Fixes',
            status: 'Pending',
          ),
          EmployeeFlowMilestone(
            id: 'MS-06',
            date: '31 Dec 2025',
            title: 'Final Release',
            status: 'Pending',
          ),
        ],
      ),
      EmployeeFlowProject(
        id: 'PRJ-002',
        code: 'PRJ-002',
        title: 'Company Website Redesign',
        description: 'Revamping the public corporate website with modern React/Next.js frontend and CRM integration.',
        status: 'Active',
        progress: 0.62,
        startDate: '15 Aug 2025',
        endDate: '30 Nov 2025',
        deadline: '30 Nov 2025',
        duration: '3.5 Months',
        daysLeft: 75,
        totalModules: 5,
        totalTasks: 18,
        myCompletedTasks: 6,
        myPendingTasks: 4,
        icon: Iconsax.global,
        themeColor: const Color(0xFF3B206A),
        modules: [
          EmployeeFlowModule(
            id: 'MOD-201',
            projectId: 'PRJ-002',
            title: 'UI & Animation System',
            description: 'Figma to Tailwind token mapping and WebGL shaders',
            totalTasks: 6,
            completedTasks: 4,
            progress: 0.75,
            status: 'In Progress',
            tasks: [sampleTasks[6], sampleTasks[7]],
          ),
          EmployeeFlowModule(
            id: 'MOD-202',
            projectId: 'PRJ-002',
            title: 'Hubspot & Analytics Integration',
            description: 'Google Analytics 4, Hotjar and CRM forms',
            totalTasks: 4,
            completedTasks: 1,
            progress: 0.30,
            status: 'In Progress',
            tasks: [sampleTasks[8]],
          ),
        ],
        milestones: const [
          EmployeeFlowMilestone(
            id: 'MS-201',
            date: '15 Aug 2025',
            title: 'Discovery & IA Map',
            status: 'Completed',
          ),
          EmployeeFlowMilestone(
            id: 'MS-202',
            date: '01 Sep 2025',
            title: 'Wireframes & UI Kit',
            status: 'Completed',
          ),
          EmployeeFlowMilestone(
            id: 'MS-203',
            date: '25 Sep 2025',
            title: 'Frontend Page Builds',
            status: 'In Progress',
          ),
          EmployeeFlowMilestone(
            id: 'MS-204',
            date: '30 Nov 2025',
            title: 'Production Deployment',
            status: 'Pending',
          ),
        ],
      ),
      EmployeeFlowProject(
        id: 'PRJ-003',
        code: 'PRJ-003',
        title: 'HR Management System',
        description: 'Internal payroll, attendance tracking, and leave approvals platform.',
        status: 'On Hold',
        progress: 0.20,
        startDate: '01 Jun 2025',
        endDate: '15 Oct 2025',
        deadline: '15 Oct 2025',
        duration: '4.5 Months',
        daysLeft: 29,
        totalModules: 6,
        totalTasks: 15,
        myCompletedTasks: 2,
        myPendingTasks: 8,
        icon: Iconsax.profile_2user,
        themeColor: const Color(0xFFF59E0B),
        modules: [
          EmployeeFlowModule(
            id: 'MOD-301',
            projectId: 'PRJ-003',
            title: 'Leave & Attendance Tracking',
            description: 'Biometric device sync and leave credit recalculation',
            totalTasks: 5,
            completedTasks: 2,
            progress: 0.40,
            status: 'On Hold',
            tasks: [sampleTasks[9]],
          ),
        ],
        milestones: const [
          EmployeeFlowMilestone(
            id: 'MS-301',
            date: '01 Jun 2025',
            title: 'Requirements Freeze',
            status: 'Completed',
          ),
          EmployeeFlowMilestone(
            id: 'MS-302',
            date: '15 Jul 2025',
            title: 'DB Schema & API Architecture',
            status: 'Completed',
          ),
          EmployeeFlowMilestone(
            id: 'MS-303',
            date: '15 Oct 2025',
            title: 'Final Rollout (Pending Audit)',
            status: 'Pending',
          ),
        ],
      ),
    ];

    projects.assignAll(sampleProjects);
    selectedProject = Rx<EmployeeFlowProject>(sampleProjects.first);

    // 4. Project Files & Documents (Shared across projects)
    allProjectFiles.assignAll([
      const ProjectFileItem(
        id: 'FIL-01',
        projectId: 'PRJ-001',
        fileName: 'App_Requirements_Specification_v1.2.pdf',
        fileSize: '4.2 MB',
        fileExtension: 'pdf',
        uploadedBy: 'Admin (Vikram Malhotra)',
        uploadDate: '02 Sep 2025',
      ),
      const ProjectFileItem(
        id: 'FIL-02',
        projectId: 'PRJ-001',
        fileName: 'Figma_UI_Components_Kit.fig',
        fileSize: '18.5 MB',
        fileExtension: 'fig',
        uploadedBy: 'Sneha Patel (Employee)',
        uploadDate: '08 Sep 2025',
      ),
      const ProjectFileItem(
        id: 'FIL-03',
        projectId: 'PRJ-001',
        fileName: 'Catalog_Backend_APIs_v1.json',
        fileSize: '620 KB',
        fileExtension: 'docx',
        uploadedBy: 'Rohit Verma (Employee)',
        uploadDate: '14 Sep 2025',
      ),
      const ProjectFileItem(
        id: 'FIL-04',
        projectId: 'PRJ-001',
        fileName: 'Payment_Gateway_Webhook_Config.pdf',
        fileSize: '1.8 MB',
        fileExtension: 'pdf',
        uploadedBy: 'Admin (Vikram Malhotra)',
        uploadDate: '18 Sep 2025',
      ),
      const ProjectFileItem(
        id: 'FIL-05',
        projectId: 'PRJ-002',
        fileName: 'Brand_Guidelines_and_Logos.zip',
        fileSize: '12.4 MB',
        fileExtension: 'zip',
        uploadedBy: 'Admin (Vikram Malhotra)',
        uploadDate: '16 Aug 2025',
      ),
      const ProjectFileItem(
        id: 'FIL-06',
        projectId: 'PRJ-002',
        fileName: 'Landing_Page_Wireframes_Final.pdf',
        fileSize: '5.1 MB',
        fileExtension: 'pdf',
        uploadedBy: 'Sneha Patel (Employee)',
        uploadDate: '22 Aug 2025',
      ),
      const ProjectFileItem(
        id: 'FIL-07',
        projectId: 'PRJ-003',
        fileName: 'HRMS_Payroll_Formula_Rules.xlsx',
        fileSize: '2.3 MB',
        fileExtension: 'xlsx',
        uploadedBy: 'Admin (Vikram Malhotra)',
        uploadDate: '05 Jun 2025',
      ),
      const ProjectFileItem(
        id: 'FIL-08',
        projectId: 'PRJ-003',
        fileName: 'Attendance_Biometric_Protocol.pdf',
        fileSize: '3.7 MB',
        fileExtension: 'pdf',
        uploadedBy: 'Aarav Sharma (Employee)',
        uploadDate: '12 Jun 2025',
      ),
    ]);
  }

  // ---------------------------------------------------------------------------
  // FILTERED GETTERS
  // ---------------------------------------------------------------------------
  List<EmployeeFlowProject> get filteredProjects {
    final query = projectSearchQuery.value.trim().toLowerCase();
    final filter = projectFilter.value;

    return projects.where((p) {
      if (filter == 'Active' && p.status != 'Active') return false;
      if (filter == 'On Hold' && p.status != 'On Hold') return false;
      if (filter == 'Completed' && p.status != 'Completed') return false;

      if (query.isNotEmpty) {
        final matchTitle = p.title.toLowerCase().contains(query);
        final matchCode = p.code.toLowerCase().contains(query);
        return matchTitle || matchCode;
      }
      return true;
    }).toList();
  }

  List<EmployeeFlowTask> get filteredTasks {
    final query = taskSearchQuery.value.trim().toLowerCase();
    final filter = taskFilter.value;

    return allTasks.where((t) {
      if (filter == 'In Progress' && t.status != 'In Progress') return false;
      if (filter == 'Completed' && t.status != 'Completed') return false;
      if (filter == 'Pending' && t.status != 'Pending') return false;

      if (query.isNotEmpty) {
        final matchTitle = t.title.toLowerCase().contains(query);
        final matchModule = t.moduleTitle.toLowerCase().contains(query);
        return matchTitle || matchModule;
      }
      return true;
    }).toList();
  }

  int get totalTasksCount => allTasks.length;
  int get inProgressTasksCount => allTasks.where((t) => t.status == 'In Progress').length;
  int get completedTasksCount => allTasks.where((t) => t.status == 'Completed').length;
  int get pendingTasksCount => allTasks.where((t) => t.status == 'Pending').length;

  // ---------------------------------------------------------------------------
  // PROJECT-SCOPED GETTERS & HELPERS
  // ---------------------------------------------------------------------------
  List<EmployeeFlowTask> getTasksForProject(String projectId) {
    return allTasks.where((t) => t.projectId == projectId).toList();
  }

  List<EmployeeFlowTask> getFilteredTasksForProject(String projectId) {
    final query = taskSearchQuery.value.trim().toLowerCase();
    final filter = taskFilter.value;

    return allTasks.where((t) {
      if (t.projectId != projectId) return false;
      if (filter == 'In Progress' && t.status != 'In Progress') return false;
      if (filter == 'Completed' && t.status != 'Completed') return false;
      if (filter == 'Pending' && t.status != 'Pending') return false;

      if (query.isNotEmpty) {
        final matchTitle = t.title.toLowerCase().contains(query);
        final matchModule = t.moduleTitle.toLowerCase().contains(query);
        return matchTitle || matchModule;
      }
      return true;
    }).toList();
  }

  int getProjectTotalTasksCount(String projectId) =>
      allTasks.where((t) => t.projectId == projectId).length;
  int getProjectInProgressTasksCount(String projectId) =>
      allTasks.where((t) => t.projectId == projectId && t.status == 'In Progress').length;
  int getProjectCompletedTasksCount(String projectId) =>
      allTasks.where((t) => t.projectId == projectId && t.status == 'Completed').length;
  int getProjectPendingTasksCount(String projectId) =>
      allTasks.where((t) => t.projectId == projectId && t.status == 'Pending').length;

  List<EmployeeFlowHandoverRecord> getHandoversForProject(String projectId) {
    return globalHandoverHistory.where((h) => h.projectId == projectId).toList();
  }

  // ---------------------------------------------------------------------------
  // PROJECT FILES MANAGEMENT (ADMIN & EMPLOYEE UPLOADS)
  // ---------------------------------------------------------------------------
  List<ProjectFileItem> getFilesForProject(String projectId) {
    return allProjectFiles.where((f) => f.projectId == projectId).toList();
  }

  void addFileToProject({
    required String projectId,
    required String fileName,
    required String fileSize,
    required String fileExtension,
    required String uploadedBy,
  }) {
    final cleanExt = fileExtension.toLowerCase().replaceAll('.', '').trim();
    final newFile = ProjectFileItem(
      id: 'FIL-${DateTime.now().millisecondsSinceEpoch}',
      projectId: projectId,
      fileName: fileName,
      fileSize: fileSize.isNotEmpty ? fileSize : '2.1 MB',
      fileExtension: cleanExt.isNotEmpty ? cleanExt : 'pdf',
      uploadedBy: uploadedBy,
      uploadDate: '23 Oct 2026',
    );
    allProjectFiles.insert(0, newFile);

    Get.snackbar(
      'File Uploaded',
      '"$fileName" added to project files successfully.',
      backgroundColor: const Color(0xFF3B206A),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    );
  }

  void deleteProjectFile(String fileId) {
    allProjectFiles.removeWhere((f) => f.id == fileId);
    Get.snackbar(
      'File Removed',
      'The file has been deleted from this project.',
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );
  }

  // ---------------------------------------------------------------------------
  // LIVE TIMER WORK TRACKING (START, PAUSE, RESUME, STOP)
  // ---------------------------------------------------------------------------

  void startTaskTimer(EmployeeFlowTask task) {
    // If another task is currently running, pause it first
    if (activeRunningTask.value != null && activeRunningTask.value!.id != task.id) {
      pauseTaskTimer(reason: 'Switched to ${task.title}');
    }

    task.isRunning = true;
    task.isPaused = false;
    task.status = 'In Progress';
    task.currentSessionStartTime = DateTime.now();
    task.lastStartTime = DateTime.now();

    activeRunningTask.value = task;

    _liveTicker?.cancel();
    _liveTicker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (activeRunningTask.value != null &&
          activeRunningTask.value!.isRunning &&
          !activeRunningTask.value!.isPaused) {
        activeRunningTask.value!.spentSeconds += 1;
        activeRunningTask.refresh();
        allTasks.refresh();
      }
    });

    Get.snackbar(
      'Work Timer Started',
      'Timing started for "${task.title}". Time limit: ${task.allocatedHours.toStringAsFixed(0)}h.',
      backgroundColor: const Color(0xFF3B206A),
      colorText: Colors.white,
      icon: const Icon(Icons.timer, color: Colors.white),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    );
  }

  void pauseTaskTimer({String reason = 'Break'}) {
    final task = activeRunningTask.value;
    if (task == null) return;

    task.isPaused = true;
    if (task.currentSessionStartTime != null) {
      final now = DateTime.now();
      task.workSessions.add(
        EmployeeWorkSession(
          id: 'SES-${DateTime.now().millisecondsSinceEpoch}',
          startTime: task.currentSessionStartTime!,
          endTime: now,
          duration: now.difference(task.currentSessionStartTime!),
          isBreak: false,
        ),
      );
    }
    // Add break session marker
    task.workSessions.add(
      EmployeeWorkSession(
        id: 'BRK-${DateTime.now().millisecondsSinceEpoch}',
        startTime: DateTime.now(),
        isBreak: true,
        breakReason: reason,
      ),
    );

    task.currentSessionStartTime = null;
    activeRunningTask.refresh();
    allTasks.refresh();

    Get.snackbar(
      'Timer Paused',
      'Work paused for "$reason". Take your break!',
      backgroundColor: const Color(0xFFD97706),
      colorText: Colors.white,
      icon: const Icon(Icons.pause_circle_filled, color: Colors.white),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    );
  }

  void resumeTaskTimer() {
    final task = activeRunningTask.value;
    if (task == null) return;

    // End the latest break session
    if (task.workSessions.isNotEmpty && task.workSessions.last.isBreak && task.workSessions.last.endTime == null) {
      task.workSessions.last.endTime = DateTime.now();
      task.workSessions.last.duration = DateTime.now().difference(task.workSessions.last.startTime);
    }

    task.isPaused = false;
    task.currentSessionStartTime = DateTime.now();
    activeRunningTask.refresh();
    allTasks.refresh();

    Get.snackbar(
      'Timer Resumed',
      'Welcome back! Resumed tracking for "${task.title}".',
      backgroundColor: const Color(0xFF3B206A),
      colorText: Colors.white,
      icon: const Icon(Icons.play_circle_fill, color: Colors.white),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );
  }

  void stopTaskTimer({bool markCompleted = false}) {
    final task = activeRunningTask.value;
    if (task == null) return;

    _liveTicker?.cancel();

    if (task.currentSessionStartTime != null) {
      final now = DateTime.now();
      task.workSessions.add(
        EmployeeWorkSession(
          id: 'SES-${DateTime.now().millisecondsSinceEpoch}',
          startTime: task.currentSessionStartTime!,
          endTime: now,
          duration: now.difference(task.currentSessionStartTime!),
        ),
      );
    }

    task.isRunning = false;
    task.isPaused = false;
    task.currentSessionStartTime = null;

    if (markCompleted) {
      task.status = 'Completed';
    }

    activeRunningTask.value = null;
    allTasks.refresh();

    Get.snackbar(
      markCompleted ? 'Task Completed! 🎉' : 'Work Session Saved',
      markCompleted
          ? 'Great job! "${task.title}" has been marked as Completed.'
          : 'Total logged: ${task.formattedSpentTime} on "${task.title}".',
      backgroundColor: markCompleted ? const Color(0xFF16A34A) : const Color(0xFF1E293B),
      colorText: Colors.white,
      icon: Icon(markCompleted ? Icons.check_circle : Icons.save, color: Colors.white),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    );
  }

  // ---------------------------------------------------------------------------
  // HANDOVER REQUEST CREATION
  // ---------------------------------------------------------------------------

  void requestHandover({
    required EmployeeFlowTask task,
    required String toUser,
    required String toUserRole,
    required String reason,
    required String notes,
    required double progressAtHandover,
    String? attachmentName,
  }) {
    final record = EmployeeFlowHandoverRecord(
      id: 'HO-${DateTime.now().millisecondsSinceEpoch}',
      taskTitle: task.title,
      timestamp: '${DateTime.now().day} ${_monthName(DateTime.now().month)} ${DateTime.now().year}, 03:30 PM',
      fromUser: currentUser.value.name,
      fromUserRole: currentUser.value.role,
      toUser: toUser,
      toUserRole: toUserRole,
      reason: reason,
      notes: notes,
      status: 'Requested',
      progressAtHandover: progressAtHandover,
      attachmentName: attachmentName,
    );

    task.handoverHistory.insert(0, record);
    globalHandoverHistory.insert(0, record);

    allTasks.refresh();
    globalHandoverHistory.refresh();

    Get.back(); // close handover screen

    Get.snackbar(
      'Handover Requested! 🚀',
      'Task "${task.title}" has been submitted for handover to $toUser.',
      backgroundColor: const Color(0xFF16A34A),
      colorText: Colors.white,
      icon: const Icon(Icons.swap_horiz_rounded, color: Colors.white),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    );
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  // ---------------------------------------------------------------------------
  // TIME LOG METRICS
  // ---------------------------------------------------------------------------

  List<EmployeeFlowTimeLogItem> get timeLogItems {
    return const [
      EmployeeFlowTimeLogItem(
        taskTitle: 'User Authentication',
        allocatedHours: 7.0,
        actualHours: 8.0,
        diffHours: -1.0,
        isOvertime: true,
      ),
      EmployeeFlowTimeLogItem(
        taskTitle: 'API Integration',
        allocatedHours: 5.0,
        actualHours: 6.0,
        diffHours: -1.0,
        isOvertime: true,
      ),
      EmployeeFlowTimeLogItem(
        taskTitle: 'UI Design',
        allocatedHours: 8.0,
        actualHours: 8.0,
        diffHours: 0.0,
        isOvertime: false,
      ),
      EmployeeFlowTimeLogItem(
        taskTitle: 'Testing',
        allocatedHours: 5.0,
        actualHours: 6.0,
        diffHours: -1.0,
        isOvertime: true,
      ),
      EmployeeFlowTimeLogItem(
        taskTitle: 'Deployment',
        allocatedHours: 3.0,
        actualHours: 4.0,
        diffHours: -1.0,
        isOvertime: true,
      ),
    ];
  }

  List<EmployeeFlowTimeLogItem> getTimeLogItemsForProject(String projectId) {
    final projectTasks = allTasks.where((t) => t.projectId == projectId).toList();
    if (projectTasks.isEmpty) {
      return timeLogItems;
    }
    return projectTasks.map((t) {
      final actualH = t.spentHours > 0 ? (t.spentHours * 10).round() / 10 : 0.0;
      final diff = (t.allocatedHours - actualH) * 10 / 10;
      return EmployeeFlowTimeLogItem(
        taskTitle: t.title,
        allocatedHours: t.allocatedHours,
        actualHours: actualH,
        diffHours: diff,
        isOvertime: t.isTimeExceeded,
      );
    }).toList();
  }
}
