import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../role_permissions/models/role_permission_models.dart';
import '../../tasks/controllers/tasks_controller.dart';
import '../controllers/projects_controller.dart';
import '../models/project_model.dart';
import 'project_details_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 🌟 DATA MODELS FOR ADMIN PROJECT WORK TRACKING & HANDOVER AUDIT
// ─────────────────────────────────────────────────────────────────────────────

class HandoverAuditRecord {
  final String id;
  final String taskTitle;
  final String moduleName;
  final String projectName;
  final AppUser fromUser;
  final AppUser toUser;
  final DateTime handoverTimestamp;
  final int durationWorkedMinutesBeforeHandover; // Kitni der tak pehle kaam kiya
  final String handoverReason;
  final int allocatedHoursToNewAssignee;
  final int actualHoursTakenByNewAssignee;
  final String status; // Completed, In Progress, Blocked
  final String? resolutionNote;

  const HandoverAuditRecord({
    required this.id,
    required this.taskTitle,
    required this.moduleName,
    required this.projectName,
    required this.fromUser,
    required this.toUser,
    required this.handoverTimestamp,
    required this.durationWorkedMinutesBeforeHandover,
    required this.handoverReason,
    required this.allocatedHoursToNewAssignee,
    required this.actualHoursTakenByNewAssignee,
    required this.status,
    this.resolutionNote,
  });

  bool get isOverdue =>
      status == 'Completed' && actualHoursTakenByNewAssignee > allocatedHoursToNewAssignee;

  int get varianceHours => actualHoursTakenByNewAssignee - allocatedHoursToNewAssignee;

  String get formattedWorkedTime {
    final h = durationWorkedMinutesBeforeHandover ~/ 60;
    final m = durationWorkedMinutesBeforeHandover % 60;
    if (h > 0) {
      return '${h}h ${m}m';
    }
    return '${m}m';
  }
}

class ModuleWorkTrackerItem {
  final String id;
  final String name;
  final String description;
  final String projectName;
  final String status; // Completed, In Progress, Pending, Delayed
  final double progress; // 0.0 to 1.0
  final int totalTasks;
  final int completedTasks;
  final int allocatedHours;
  final int actualHoursSpent;
  final String? completedAt;
  final List<TaskWorkTrackerItem> tasks;

  const ModuleWorkTrackerItem({
    required this.id,
    required this.name,
    required this.description,
    required this.projectName,
    required this.status,
    required this.progress,
    required this.totalTasks,
    required this.completedTasks,
    required this.allocatedHours,
    required this.actualHoursSpent,
    this.completedAt,
    this.tasks = const [],
  });

  int get undoneTasks => totalTasks - completedTasks;
  bool get isOverdue => actualHoursSpent > allocatedHours;
  int get varianceHours => actualHoursSpent - allocatedHours;
}

class TaskWorkTrackerItem {
  final String id;
  final String title;
  final String moduleName;
  final String priority;
  final String status; // Completed, In Progress, Review, Blocked, To Do
  final AppUser assignee;
  final int allocatedHours;
  final int actualHoursSpent;
  final DateTime dueDate;
  final DateTime? completedDate;
  final bool isHandedOver;
  final String? lastHandoverFrom;
  final String? handoverReason;

  const TaskWorkTrackerItem({
    required this.id,
    required this.title,
    required this.moduleName,
    required this.priority,
    required this.status,
    required this.assignee,
    required this.allocatedHours,
    required this.actualHoursSpent,
    required this.dueDate,
    this.completedDate,
    this.isHandedOver = false,
    this.lastHandoverFrom,
    this.handoverReason,
  });

  bool get isOverdue =>
      (status == 'Completed' && actualHoursSpent > allocatedHours) ||
      (status != 'Completed' && DateTime.now().isAfter(dueDate));

  int get varianceHours => actualHoursSpent - allocatedHours;
}

class TeamMemberWorkSummary {
  final AppUser user;
  final String projectName;
  final List<String> assignedModules;
  final int totalTasks;
  final int completedTasks;
  final int inProgressTasks;
  final int allocatedHours;
  final int actualHoursSpent;
  final int handoversGivenCount;
  final int handoversReceivedCount;

  const TeamMemberWorkSummary({
    required this.user,
    required this.projectName,
    required this.assignedModules,
    required this.totalTasks,
    required this.completedTasks,
    required this.inProgressTasks,
    required this.allocatedHours,
    required this.actualHoursSpent,
    required this.handoversGivenCount,
    required this.handoversReceivedCount,
  });

  bool get isExceeded => actualHoursSpent > allocatedHours;
  int get varianceHours => actualHoursSpent - allocatedHours;
  double get completionRate => totalTasks > 0 ? (completedTasks / totalTasks) : 0.0;
}

// ─────────────────────────────────────────────────────────────────────────────
// 🚀 MAIN ADMIN PROJECT WORK TRACKING SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class AdminProjectWorkTrackingScreen extends StatefulWidget {
  final String? initialProjectId;
  final String? initialProjectName;
  final Project? initialProject;

  const AdminProjectWorkTrackingScreen({
    super.key,
    this.initialProjectId,
    this.initialProjectName,
    this.initialProject,
  });

  @override
  State<AdminProjectWorkTrackingScreen> createState() => _AdminProjectWorkTrackingScreenState();
}

class _AdminProjectWorkTrackingScreenState extends State<AdminProjectWorkTrackingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ProjectsController _projectsController = Get.isRegistered<ProjectsController>()
      ? Get.find<ProjectsController>()
      : Get.put(ProjectsController());
  final TasksController _tasksController = Get.isRegistered<TasksController>()
      ? Get.find<TasksController>()
      : Get.put(TasksController());

  // Filter state
  String _selectedProjectFilter = 'All Active Projects';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  String _moduleStatusFilter = 'All'; // 'All', 'Completed', 'In Progress', 'Overdue'
  bool _showSearch = false;

  // Expanded card state
  final Set<String> _expandedModuleIds = <String>{};

  // Live mutable list of handovers for instant UI updates when user transfers a task
  late List<HandoverAuditRecord> _handoversList;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _initializeData() {
    // Default initial project filter if passed
    if (widget.initialProject != null && widget.initialProject!.name.isNotEmpty) {
      _selectedProjectFilter = widget.initialProject!.name;
    } else if (widget.initialProjectName != null && widget.initialProjectName!.isNotEmpty) {
      _selectedProjectFilter = widget.initialProjectName!;
    } else if (widget.initialProjectId != null && widget.initialProjectId!.isNotEmpty) {
      Project? matching;
      for (final p in _projectsController.projects) {
        if (p.id == widget.initialProjectId) {
          matching = p;
          break;
        }
      }
      if (matching != null) {
        _selectedProjectFilter = matching.name;
      }
    }

    // Default rich sample handover audit trail
    _handoversList = [
      HandoverAuditRecord(
        id: 'HO-101',
        taskTitle: 'BLE Geofencing & Hardware Beacon Integration',
        moduleName: 'Attendance & Geofencing Module',
        projectName: 'Digi Attendance Tracking Suite',
        fromUser: const AppUser(
          id: 12,
          name: 'Vicky Kumar',
          email: 'vicky@digiemperor.com',
          avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
          designation: 'Junior Mobile Developer',
        ),
        toUser: const AppUser(
          id: 19,
          name: 'Rahul Sharma',
          email: 'rahul.sharma@digiemperor.com',
          avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
          designation: 'Senior Mobile Lead',
        ),
        handoverTimestamp: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
        durationWorkedMinutesBeforeHandover: 330, // 5 hours 30 mins
        handoverReason:
            'Background Bluetooth peripheral scanning was crashing on Android 14; reassigned to Senior Native Lead for BLE service refactor.',
        allocatedHoursToNewAssignee: 8,
        actualHoursTakenByNewAssignee: 6,
        status: 'Completed',
        resolutionNote: 'Refactored foreground service notification channel; tested and working 100%.',
      ),
      HandoverAuditRecord(
        id: 'HO-102',
        taskTitle: 'Stripe & Razorpay Webhook Signature Verification',
        moduleName: 'Payment Gateway & Invoicing',
        projectName: 'Digi Attendance Tracking Suite',
        fromUser: const AppUser(
          id: 14,
          name: 'Neha Gupta',
          email: 'neha.g@digiemperor.com',
          avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
          designation: 'Backend Developer',
        ),
        toUser: const AppUser(
          id: 17,
          name: 'Aman Verma',
          email: 'aman.v@digiemperor.com',
          avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
          designation: 'Lead DevOps & Backend Architect',
        ),
        handoverTimestamp: DateTime.now().subtract(const Duration(hours: 18)),
        durationWorkedMinutesBeforeHandover: 210, // 3 hours 30 mins
        handoverReason:
            'Employee had to take sudden emergency medical leave; task reassigned to keep release deadline intact.',
        allocatedHoursToNewAssignee: 5,
        actualHoursTakenByNewAssignee: 7,
        status: 'Completed',
        resolutionNote: 'Completed payload validation and webhook replay attack prevention.',
      ),
      HandoverAuditRecord(
        id: 'HO-103',
        taskTitle: 'Executive CRM Tele-Calling Analytics Charts',
        moduleName: 'Admin CRM & Tele-Marketing',
        projectName: 'Sales CRM & Tele-Caller Engine',
        fromUser: const AppUser(
          id: 18,
          name: 'Karan Mehra',
          email: 'karan@digiemperor.com',
          avatarUrl: 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=150',
          designation: 'Frontend Engineer',
        ),
        toUser: const AppUser(
          id: 15,
          name: 'Priya Patel',
          email: 'priya.p@digiemperor.com',
          avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
          designation: 'Senior UI/UX & Flutter Specialist',
        ),
        handoverTimestamp: DateTime.now().subtract(const Duration(hours: 5)),
        durationWorkedMinutesBeforeHandover: 180, // 3 hours
        handoverReason:
            'FL Chart animation stutter on low-end devices; handed over to UI/UX specialist for shader optimization.',
        allocatedHoursToNewAssignee: 6,
        actualHoursTakenByNewAssignee: 4,
        status: 'In Progress',
        resolutionNote: null,
      ),
    ];
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 📊 COMPUTED DATA HELPERS
  // ───────────────────────────────────────────────────────────────────────────

  List<String> _getAvailableProjectNames() {
    final list = <String>['All Active Projects'];
    if (widget.initialProject != null && !list.contains(widget.initialProject!.name)) {
      list.add(widget.initialProject!.name);
    }
    if (_selectedProjectFilter != 'All Active Projects' && !list.contains(_selectedProjectFilter)) {
      list.add(_selectedProjectFilter);
    }
    for (final p in _projectsController.projects) {
      if (p.name.isNotEmpty && !list.contains(p.name)) {
        list.add(p.name);
      }
    }
    if (list.length == 1) {
      list.addAll(['Digi Attendance Tracking Suite', 'Sales CRM & Tele-Caller Engine', 'HRMS Enterprise Payroll']);
    }
    return list;
  }

  List<ModuleWorkTrackerItem> _getModulesData() {
    final List<ModuleWorkTrackerItem> sampleModules = [
      ModuleWorkTrackerItem(
        id: 'MOD-1',
        name: 'Attendance & Geofencing Module',
        description: 'GPS boundary check, WiFi MAC validation & check-in window restrictions',
        projectName: 'Digi Attendance Tracking Suite',
        status: 'Completed',
        progress: 1.0,
        totalTasks: 4,
        completedTasks: 4,
        allocatedHours: 40,
        actualHoursSpent: 36, // Under budget!
        completedAt: '18 Oct 2026, 05:40 PM',
        tasks: [
          TaskWorkTrackerItem(
            id: 'TSK-101',
            title: 'GPS Polygon Math & Radius Checking Engine',
            moduleName: 'Attendance & Geofencing Module',
            priority: 'High',
            status: 'Completed',
            assignee: const AppUser(name: 'Rahul Sharma', email: 'rahul@digi.com', avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150', designation: 'Senior Mobile Lead'),
            allocatedHours: 12,
            actualHoursSpent: 10,
            dueDate: DateTime.now().subtract(const Duration(days: 4)),
            completedDate: DateTime.now().subtract(const Duration(days: 4)),
          ),
          TaskWorkTrackerItem(
            id: 'TSK-102',
            title: 'Auto Check-Out when leaving office radius',
            moduleName: 'Attendance & Geofencing Module',
            priority: 'Medium',
            status: 'Completed',
            assignee: const AppUser(name: 'Vicky Kumar', email: 'vicky@digi.com', avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150', designation: 'Junior Mobile Developer'),
            allocatedHours: 8,
            actualHoursSpent: 7,
            dueDate: DateTime.now().subtract(const Duration(days: 3)),
            completedDate: DateTime.now().subtract(const Duration(days: 3)),
          ),
          TaskWorkTrackerItem(
            id: 'TSK-103',
            title: 'BLE Geofencing & Hardware Beacon Integration',
            moduleName: 'Attendance & Geofencing Module',
            priority: 'Critical',
            status: 'Completed',
            assignee: const AppUser(name: 'Rahul Sharma', email: 'rahul@digi.com', avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150', designation: 'Senior Mobile Lead'),
            allocatedHours: 8,
            actualHoursSpent: 6,
            dueDate: DateTime.now().subtract(const Duration(days: 1)),
            completedDate: DateTime.now().subtract(const Duration(days: 1)),
            isHandedOver: true,
            lastHandoverFrom: 'Vicky Kumar',
            handoverReason: 'Encountered background BLE crash on Android 14.',
          ),
          TaskWorkTrackerItem(
            id: 'TSK-104',
            title: 'Offline Attendance Sync with local SQLite cache',
            moduleName: 'Attendance & Geofencing Module',
            priority: 'High',
            status: 'Completed',
            assignee: const AppUser(name: 'Aman Verma', email: 'aman@digi.com', avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150', designation: 'Lead DevOps'),
            allocatedHours: 12,
            actualHoursSpent: 13, // Overdue by 1h
            dueDate: DateTime.now().subtract(const Duration(days: 2)),
            completedDate: DateTime.now().subtract(const Duration(days: 2)),
          ),
        ],
      ),
      ModuleWorkTrackerItem(
        id: 'MOD-2',
        name: 'Shift Roster & Automated Overtime Rules',
        description: 'Night shifts, grace periods, half-day deduction logic & leave approval workflow',
        projectName: 'Digi Attendance Tracking Suite',
        status: 'In Progress',
        progress: 0.70,
        totalTasks: 5,
        completedTasks: 3,
        allocatedHours: 35,
        actualHoursSpent: 38, // OVERDUE by 3 hours!
        completedAt: null,
        tasks: [
          TaskWorkTrackerItem(
            id: 'TSK-201',
            title: 'Dynamic Shift Assignment API endpoint',
            moduleName: 'Shift Roster & Automated Overtime Rules',
            priority: 'High',
            status: 'Completed',
            assignee: const AppUser(name: 'Neha Gupta', email: 'neha@digi.com', avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150', designation: 'Backend Developer'),
            allocatedHours: 10,
            actualHoursSpent: 8,
            dueDate: DateTime.now().subtract(const Duration(days: 3)),
            completedDate: DateTime.now().subtract(const Duration(days: 3)),
          ),
          TaskWorkTrackerItem(
            id: 'TSK-202',
            title: 'Grace Period & Late Flag Calculation logic',
            moduleName: 'Shift Roster & Automated Overtime Rules',
            priority: 'High',
            status: 'Completed',
            assignee: const AppUser(name: 'Neha Gupta', email: 'neha@digi.com', avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150', designation: 'Backend Developer'),
            allocatedHours: 6,
            actualHoursSpent: 9, // Time se zyada ho gaya! +3h
            dueDate: DateTime.now().subtract(const Duration(days: 1)),
            completedDate: DateTime.now().subtract(const Duration(days: 1)),
          ),
          TaskWorkTrackerItem(
            id: 'TSK-203',
            title: 'Overtime hour compensation rule calculator',
            moduleName: 'Shift Roster & Automated Overtime Rules',
            priority: 'Medium',
            status: 'In Progress',
            assignee: const AppUser(name: 'Karan Mehra', email: 'karan@digi.com', avatarUrl: 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=150', designation: 'Frontend Engineer'),
            allocatedHours: 8,
            actualHoursSpent: 11, // Already exceeded! +3h
            dueDate: DateTime.now().add(const Duration(days: 1)),
          ),
          TaskWorkTrackerItem(
            id: 'TSK-204',
            title: 'Weekly off automatic substitution system',
            moduleName: 'Shift Roster & Automated Overtime Rules',
            priority: 'Medium',
            status: 'In Progress',
            assignee: const AppUser(name: 'Vicky Kumar', email: 'vicky@digi.com', avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150', designation: 'Junior Mobile Developer'),
            allocatedHours: 6,
            actualHoursSpent: 5,
            dueDate: DateTime.now().add(const Duration(days: 2)),
          ),
          TaskWorkTrackerItem(
            id: 'TSK-205',
            title: 'Employee shift swap request notification',
            moduleName: 'Shift Roster & Automated Overtime Rules',
            priority: 'Low',
            status: 'To Do',
            assignee: const AppUser(name: 'Priya Patel', email: 'priya@digi.com', avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150', designation: 'UI/UX Specialist'),
            allocatedHours: 5,
            actualHoursSpent: 0,
            dueDate: DateTime.now().add(const Duration(days: 4)),
          ),
        ],
      ),
      ModuleWorkTrackerItem(
        id: 'MOD-3',
        name: 'Admin CRM & Tele-Marketing Hub',
        description: 'Lead assignment, call logs, conversion pipeline & dynamic lead status tracker',
        projectName: 'Sales CRM & Tele-Caller Engine',
        status: 'In Progress',
        progress: 0.85,
        totalTasks: 4,
        completedTasks: 3,
        allocatedHours: 32,
        actualHoursSpent: 28, // On track!
        completedAt: null,
        tasks: [
          TaskWorkTrackerItem(
            id: 'TSK-301',
            title: 'Dynamic Lead Status API Integration (/api/admin/lead-statuses)',
            moduleName: 'Admin CRM & Tele-Marketing Hub',
            priority: 'Critical',
            status: 'Completed',
            assignee: const AppUser(name: 'Rahul Sharma', email: 'rahul@digi.com', avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150', designation: 'Senior Mobile Lead'),
            allocatedHours: 6,
            actualHoursSpent: 5,
            dueDate: DateTime.now().subtract(const Duration(days: 1)),
            completedDate: DateTime.now().subtract(const Duration(days: 1)),
          ),
          TaskWorkTrackerItem(
            id: 'TSK-302',
            title: 'Lead Conversion to Project Creation handover screen',
            moduleName: 'Admin CRM & Tele-Marketing Hub',
            priority: 'High',
            status: 'Completed',
            assignee: const AppUser(name: 'Priya Patel', email: 'priya@digi.com', avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150', designation: 'UI/UX Specialist'),
            allocatedHours: 8,
            actualHoursSpent: 7,
            dueDate: DateTime.now().subtract(const Duration(days: 2)),
            completedDate: DateTime.now().subtract(const Duration(days: 2)),
          ),
          TaskWorkTrackerItem(
            id: 'TSK-303',
            title: 'Executive CRM Tele-Calling Analytics Charts',
            moduleName: 'Admin CRM & Tele-Marketing Hub',
            priority: 'High',
            status: 'In Progress',
            assignee: const AppUser(name: 'Priya Patel', email: 'priya@digi.com', avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150', designation: 'UI/UX Specialist'),
            allocatedHours: 6,
            actualHoursSpent: 4,
            dueDate: DateTime.now().add(const Duration(days: 1)),
            isHandedOver: true,
            lastHandoverFrom: 'Karan Mehra',
            handoverReason: 'Shader & frame-drop optimization needed on low-end devices.',
          ),
          TaskWorkTrackerItem(
            id: 'TSK-304',
            title: 'Direct Tele-caller SIM Call Recording integration audit',
            moduleName: 'Admin CRM & Tele-Marketing Hub',
            priority: 'Medium',
            status: 'Completed',
            assignee: const AppUser(name: 'Vicky Kumar', email: 'vicky@digi.com', avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150', designation: 'Junior Mobile Developer'),
            allocatedHours: 12,
            actualHoursSpent: 12,
            dueDate: DateTime.now().subtract(const Duration(days: 1)),
            completedDate: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ],
      ),
      ModuleWorkTrackerItem(
        id: 'MOD-4',
        name: 'Payroll Engine & Automated Payslip PDF',
        description: 'TDS calculations, attendance deductions, statutory PF/ESI & PDF generation engine',
        projectName: 'HRMS Enterprise Payroll',
        status: 'In Progress',
        progress: 0.40,
        totalTasks: 4,
        completedTasks: 1,
        allocatedHours: 36,
        actualHoursSpent: 30,
        completedAt: null,
        tasks: [
          TaskWorkTrackerItem(
            id: 'TSK-401',
            title: 'Attendance to Net Salary Deduction Calculator',
            moduleName: 'Payroll Engine & Automated Payslip PDF',
            priority: 'High',
            status: 'Completed',
            assignee: const AppUser(name: 'Aman Verma', email: 'aman@digi.com', avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150', designation: 'Lead DevOps'),
            allocatedHours: 12,
            actualHoursSpent: 10,
            dueDate: DateTime.now().subtract(const Duration(days: 2)),
            completedDate: DateTime.now().subtract(const Duration(days: 2)),
          ),
          TaskWorkTrackerItem(
            id: 'TSK-402',
            title: 'Government PF & ESI Slab validation',
            moduleName: 'Payroll Engine & Automated Payslip PDF',
            priority: 'Medium',
            status: 'In Progress',
            assignee: const AppUser(name: 'Neha Gupta', email: 'neha@digi.com', avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150', designation: 'Backend Developer'),
            allocatedHours: 8,
            actualHoursSpent: 11, // Overdue! +3h
            dueDate: DateTime.now().add(const Duration(days: 1)),
          ),
          TaskWorkTrackerItem(
            id: 'TSK-403',
            title: 'Automated Multi-lingual Payslip PDF Generator',
            moduleName: 'Payroll Engine & Automated Payslip PDF',
            priority: 'High',
            status: 'To Do',
            assignee: const AppUser(name: 'Karan Mehra', email: 'karan@digi.com', avatarUrl: 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=150', designation: 'Frontend Engineer'),
            allocatedHours: 10,
            actualHoursSpent: 5,
            dueDate: DateTime.now().add(const Duration(days: 3)),
          ),
          TaskWorkTrackerItem(
            id: 'TSK-404',
            title: 'Bank IMPS/NEFT Batch Salary Payout File Format',
            moduleName: 'Payroll Engine & Automated Payslip PDF',
            priority: 'Critical',
            status: 'To Do',
            assignee: const AppUser(name: 'Aman Verma', email: 'aman@digi.com', avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150', designation: 'Lead DevOps'),
            allocatedHours: 6,
            actualHoursSpent: 4,
            dueDate: DateTime.now().add(const Duration(days: 5)),
          ),
        ],
      ),
    ];

    // Filter by project if not "All"
    List<ModuleWorkTrackerItem> filtered = sampleModules;
    if (_selectedProjectFilter != 'All Active Projects') {
      filtered = filtered
          .where((m) => m.projectName.toLowerCase() == _selectedProjectFilter.toLowerCase())
          .toList();

      if (filtered.isEmpty) {
        final pName = _selectedProjectFilter;
        filtered = [
          ModuleWorkTrackerItem(
            id: 'MOD-${pName.hashCode.abs() % 1000}-1',
            name: 'Core Architecture & API Integrations',
            description: 'High-availability backend endpoints, database schema & JWT auth security for $pName',
            projectName: pName,
            status: 'Completed',
            progress: 1.0,
            totalTasks: 4,
            completedTasks: 4,
            allocatedHours: 32,
            actualHoursSpent: 28,
            completedAt: 'Recent',
            tasks: [
              TaskWorkTrackerItem(
                id: 'TSK-${pName.hashCode.abs() % 1000}-101',
                title: 'Database Schema Design & Migration Scripts',
                moduleName: 'Core Architecture & API Integrations',
                priority: 'High',
                status: 'Completed',
                assignee: const AppUser(name: 'Rahul Sharma', email: 'rahul@digi.com', avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150', designation: 'Senior Mobile Lead'),
                allocatedHours: 10,
                actualHoursSpent: 8,
                dueDate: DateTime.now().subtract(const Duration(days: 3)),
                completedDate: DateTime.now().subtract(const Duration(days: 3)),
              ),
              TaskWorkTrackerItem(
                id: 'TSK-${pName.hashCode.abs() % 1000}-102',
                title: 'REST API Authentication & Token Refresh Flow',
                moduleName: 'Core Architecture & API Integrations',
                priority: 'Critical',
                status: 'Completed',
                assignee: const AppUser(name: 'Neha Gupta', email: 'neha@digi.com', avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150', designation: 'Backend Developer'),
                allocatedHours: 12,
                actualHoursSpent: 11,
                dueDate: DateTime.now().subtract(const Duration(days: 2)),
                completedDate: DateTime.now().subtract(const Duration(days: 2)),
              ),
              TaskWorkTrackerItem(
                id: 'TSK-${pName.hashCode.abs() % 1000}-103',
                title: 'Push Notifications & Webhook Handler',
                moduleName: 'Core Architecture & API Integrations',
                priority: 'Medium',
                status: 'Completed',
                assignee: const AppUser(name: 'Aman Verma', email: 'aman@digi.com', avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150', designation: 'Lead DevOps'),
                allocatedHours: 10,
                actualHoursSpent: 9,
                dueDate: DateTime.now().subtract(const Duration(days: 1)),
                completedDate: DateTime.now().subtract(const Duration(days: 1)),
              ),
            ],
          ),
          ModuleWorkTrackerItem(
            id: 'MOD-${pName.hashCode.abs() % 1000}-2',
            name: 'Client Application & Responsive UI',
            description: 'UI components, state management controllers & interactive dashboards for $pName',
            projectName: pName,
            status: 'In Progress',
            progress: 0.65,
            totalTasks: 5,
            completedTasks: 3,
            allocatedHours: 40,
            actualHoursSpent: 43, // Overdue +3h
            completedAt: null,
            tasks: [
              TaskWorkTrackerItem(
                id: 'TSK-${pName.hashCode.abs() % 1000}-201',
                title: 'Interactive Dashboard Widgets & Metric Tiles',
                moduleName: 'Client Application & Responsive UI',
                priority: 'High',
                status: 'Completed',
                assignee: const AppUser(name: 'Priya Patel', email: 'priya@digi.com', avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150', designation: 'Senior UI/UX Specialist'),
                allocatedHours: 14,
                actualHoursSpent: 12,
                dueDate: DateTime.now().subtract(const Duration(days: 1)),
                completedDate: DateTime.now().subtract(const Duration(days: 1)),
              ),
              TaskWorkTrackerItem(
                id: 'TSK-${pName.hashCode.abs() % 1000}-202',
                title: 'Offline Sync & Local SQLite Caching',
                moduleName: 'Client Application & Responsive UI',
                priority: 'High',
                status: 'In Progress',
                assignee: const AppUser(name: 'Karan Mehra', email: 'karan@digi.com', avatarUrl: 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=150', designation: 'Frontend Engineer'),
                allocatedHours: 10,
                actualHoursSpent: 13, // Overdue by +3h
                dueDate: DateTime.now().add(const Duration(days: 1)),
                isHandedOver: true,
                lastHandoverFrom: 'Vicky Kumar',
                handoverReason: 'Complex state machine and sync conflicts; reassigned to Senior Engineer.',
              ),
              TaskWorkTrackerItem(
                id: 'TSK-${pName.hashCode.abs() % 1000}-203',
                title: 'Form Validation & Realtime Form State',
                moduleName: 'Client Application & Responsive UI',
                priority: 'Medium',
                status: 'Completed',
                assignee: const AppUser(name: 'Rahul Sharma', email: 'rahul@digi.com', avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150', designation: 'Senior Mobile Lead'),
                allocatedHours: 8,
                actualHoursSpent: 7,
                dueDate: DateTime.now().subtract(const Duration(days: 2)),
                completedDate: DateTime.now().subtract(const Duration(days: 2)),
              ),
              TaskWorkTrackerItem(
                id: 'TSK-${pName.hashCode.abs() % 1000}-204',
                title: 'Unit Testing & End-to-End User Journeys',
                moduleName: 'Client Application & Responsive UI',
                priority: 'Medium',
                status: 'To Do',
                assignee: const AppUser(name: 'Vicky Kumar', email: 'vicky@digi.com', avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150', designation: 'Junior Mobile Developer'),
                allocatedHours: 8,
                actualHoursSpent: 5,
                dueDate: DateTime.now().add(const Duration(days: 3)),
              ),
            ],
          ),
          ModuleWorkTrackerItem(
            id: 'MOD-${pName.hashCode.abs() % 1000}-3',
            name: 'Security Audit, QA & Production Deployment',
            description: 'Automated CI/CD pipelines, penetration testing & final client signoff for $pName',
            projectName: pName,
            status: 'In Progress',
            progress: 0.35,
            totalTasks: 3,
            completedTasks: 1,
            allocatedHours: 25,
            actualHoursSpent: 18,
            completedAt: null,
            tasks: [
              TaskWorkTrackerItem(
                id: 'TSK-${pName.hashCode.abs() % 1000}-301',
                title: 'Docker Containerization & Multi-stage Build',
                moduleName: 'Security Audit, QA & Production Deployment',
                priority: 'High',
                status: 'Completed',
                assignee: const AppUser(name: 'Aman Verma', email: 'aman@digi.com', avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150', designation: 'Lead DevOps'),
                allocatedHours: 8,
                actualHoursSpent: 7,
                dueDate: DateTime.now().subtract(const Duration(days: 2)),
                completedDate: DateTime.now().subtract(const Duration(days: 2)),
              ),
              TaskWorkTrackerItem(
                id: 'TSK-${pName.hashCode.abs() % 1000}-302',
                title: 'Vulnerability Scan & API Rate Limiting Tests',
                moduleName: 'Security Audit, QA & Production Deployment',
                priority: 'Critical',
                status: 'In Progress',
                assignee: const AppUser(name: 'Aman Verma', email: 'aman@digi.com', avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150', designation: 'Lead DevOps'),
                allocatedHours: 10,
                actualHoursSpent: 8,
                dueDate: DateTime.now().add(const Duration(days: 2)),
              ),
            ],
          ),
        ];
      }
    }

    // Filter by search query
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase().trim();
      filtered = filtered.where((m) {
        final matchMod = m.name.toLowerCase().contains(q) || m.description.toLowerCase().contains(q);
        final matchTask = m.tasks.any((t) =>
            t.title.toLowerCase().contains(q) ||
            t.assignee.name.toLowerCase().contains(q) ||
            (t.handoverReason != null && t.handoverReason!.toLowerCase().contains(q)));
        return matchMod || matchTask;
      }).toList();
    }

    return filtered;
  }

  List<ModuleWorkTrackerItem> _getFilteredModulesByStatus() {
    final all = _getModulesData();
    if (_moduleStatusFilter == 'Completed') {
      return all.where((m) => m.status == 'Completed').toList();
    } else if (_moduleStatusFilter == 'In Progress') {
      return all.where((m) => m.status == 'In Progress' && !m.isOverdue).toList();
    } else if (_moduleStatusFilter == 'Overdue') {
      return all.where((m) => m.isOverdue).toList();
    }
    return all;
  }

  List<TeamMemberWorkSummary> _getTeamMembersData() {
    final modules = _getModulesData();
    final Map<String, List<TaskWorkTrackerItem>> userTasksMap = {};
    final Map<String, AppUser> userMap = {};

    for (final mod in modules) {
      for (final t in mod.tasks) {
        userMap[t.assignee.name] = t.assignee;
        userTasksMap.putIfAbsent(t.assignee.name, () => []).add(t);
      }
    }

    final List<TeamMemberWorkSummary> team = [];

    userTasksMap.forEach((userName, tasks) {
      final user = userMap[userName]!;
      final assignedMods = tasks.map((t) => t.moduleName).toSet().toList();
      final total = tasks.length;
      final completed = tasks.where((t) => t.status == 'Completed').length;
      final inProgress = tasks.where((t) => t.status == 'In Progress').length;
      final allocated = tasks.fold<int>(0, (sum, t) => sum + t.allocatedHours);
      final spent = tasks.fold<int>(0, (sum, t) => sum + t.actualHoursSpent);

      final handoversGiven = _handoversList.where((h) => h.fromUser.name == userName).length;
      final handoversReceived = _handoversList.where((h) => h.toUser.name == userName).length;

      team.add(TeamMemberWorkSummary(
        user: user,
        projectName: _selectedProjectFilter,
        assignedModules: assignedMods,
        totalTasks: total,
        completedTasks: completed,
        inProgressTasks: inProgress,
        allocatedHours: allocated,
        actualHoursSpent: spent,
        handoversGivenCount: handoversGiven,
        handoversReceivedCount: handoversReceived,
      ));
    });

    // Sort by most tasks assigned
    team.sort((a, b) => b.totalTasks.compareTo(a.totalTasks));
    return team;
  }

  List<HandoverAuditRecord> _getFilteredHandovers() {
    List<HandoverAuditRecord> list = _handoversList;
    if (_selectedProjectFilter != 'All Active Projects') {
      list = list.where((h) => h.projectName.toLowerCase() == _selectedProjectFilter.toLowerCase()).toList();
    }
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase().trim();
      list = list.where((h) =>
          h.taskTitle.toLowerCase().contains(q) ||
          h.fromUser.name.toLowerCase().contains(q) ||
          h.toUser.name.toLowerCase().contains(q) ||
          h.handoverReason.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 🔄 INTERACTIVE TASK HANDOVER MODAL (काम हैंडओवर करने का सिस्टम)
  // ───────────────────────────────────────────────────────────────────────────
  void _openHandoverDialog({TaskWorkTrackerItem? preselectedTask}) {
    final modules = _getModulesData();
    final allTasks = modules.expand((m) => m.tasks).toList();
    if (allTasks.isEmpty) {
      Get.snackbar('No Tasks', 'No active tasks available to handover.', backgroundColor: AppColors.errorColor, colorText: Colors.white);
      return;
    }

    TaskWorkTrackerItem selectedTask = preselectedTask ?? allTasks.first;
    final team = _getTeamMembersData();
    AppUser? targetAssignee;
    for (final t in team) {
      if (t.user.name != selectedTask.assignee.name) {
        targetAssignee = t.user;
        break;
      }
    }
    targetAssignee ??= team.isNotEmpty ? team.first.user : null;

    final reasonController = TextEditingController();
    final newAllocatedHoursController = TextEditingController(text: '${selectedTask.allocatedHours}');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(modalCtx).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle Bar
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.slate200,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Iconsax.repeat, color: Color(0xFFD97706), size: 20),
                            ),
                            const SizedBox(width: 10),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText('Handover Task (काम हैंडओवर)', fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                                SizedBox(height: 2),
                                AppText('Transfer stuck or pending work to another team member', fontSize: 11, color: Color(0xFF64748B)),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF64748B)),
                          onPressed: () => Navigator.pop(modalCtx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 1. Select Task to Handover
                    const AppText('Select Task to Handover *', fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.slate200),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: selectedTask.id,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                          items: allTasks.map((t) {
                            return DropdownMenuItem<String>(
                              value: t.id,
                              child: Text(
                                '${t.title} (${t.moduleName})',
                                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setModalState(() {
                                selectedTask = allTasks.firstWhere((t) => t.id == val);
                                newAllocatedHoursController.text = '${selectedTask.allocatedHours}';
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 2. Current Assignee & Work Time Spent Banner
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundImage: NetworkImage(selectedTask.assignee.avatarUrl),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text('Currently With: ', style: TextStyle(fontSize: 10.5, color: Color(0xFF1E40AF))),
                                    Text(selectedTask.assignee.name, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Time Spent So Far: ${selectedTask.actualHoursSpent} hrs / Allocated: ${selectedTask.allocatedHours} hrs',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: selectedTask.isOverdue ? const Color(0xFFDC2626) : const Color(0xFF1D4ED8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF93C5FD)),
                            ),
                            child: Text(
                              selectedTask.status,
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 3. New Assignee Dropdown
                    const AppText('Handover To (Kisko Dena Hai) *', fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.slate200),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: targetAssignee?.name,
                          hint: const Text('Select team member', style: TextStyle(fontSize: 12)),
                          icon: const Icon(Icons.person_add_alt_1_rounded, color: Color(0xFF64748B), size: 18),
                          items: team.map((tm) {
                            return DropdownMenuItem<String>(
                              value: tm.user.name,
                              child: Row(
                                children: [
                                  CircleAvatar(radius: 12, backgroundImage: NetworkImage(tm.user.avatarUrl)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${tm.user.name} (${tm.user.designation ?? "Developer"})',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setModalState(() {
                                targetAssignee = team.firstWhere((t) => t.user.name == val).user;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 4. Allocated Hours for New Assignee
                    const AppText('Allocated Hours to New Assignee *', fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: newAllocatedHoursController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'E.g., 8 hours',
                        suffixText: 'hours',
                        suffixStyle: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.slate200)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 5. Handover Reason (Kyu Handover Kiya)
                    const AppText('Handover Reason / Blocker Note (Kyu Diya) *', fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: reasonController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Describe why task could not be completed, blockers faced, and instructions for new assignee...',
                        hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.slate200)),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Iconsax.repeat, color: Colors.white, size: 18),
                        label: const Text('Confirm Task Handover 🔄', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD97706),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        onPressed: () {
                          final reason = reasonController.text.trim();
                          if (reason.isEmpty) {
                            Get.snackbar('Reason Required', 'Please enter reason for handing over this task.', backgroundColor: AppColors.errorColor, colorText: Colors.white);
                            return;
                          }
                          if (targetAssignee == null) {
                            Get.snackbar('Assignee Required', 'Please select a new team member.', backgroundColor: AppColors.errorColor, colorText: Colors.white);
                            return;
                          }

                          final newAllocHours = int.tryParse(newAllocatedHoursController.text.trim()) ?? selectedTask.allocatedHours;

                          // Create audit record
                          final newRecord = HandoverAuditRecord(
                            id: 'HO-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                            taskTitle: selectedTask.title,
                            moduleName: selectedTask.moduleName,
                            projectName: _selectedProjectFilter == 'All Active Projects' ? 'Digi Attendance Tracking Suite' : _selectedProjectFilter,
                            fromUser: selectedTask.assignee,
                            toUser: targetAssignee!,
                            handoverTimestamp: DateTime.now(),
                            durationWorkedMinutesBeforeHandover: selectedTask.actualHoursSpent * 60,
                            handoverReason: reason,
                            allocatedHoursToNewAssignee: newAllocHours,
                            actualHoursTakenByNewAssignee: 0,
                            status: 'In Progress',
                            resolutionNote: 'Handed over by Admin via Live Operations Hub.',
                          );

                          setState(() {
                            _handoversList.insert(0, newRecord);
                          });

                          // Call TasksController if available
                          _tasksController.handoverTask(
                            taskId: selectedTask.id,
                            toUser: targetAssignee!,
                            reason: reason,
                            type: 'Handover',
                          );

                          Navigator.pop(modalCtx);

                          Get.snackbar(
                            'Task Handed Over 🎉',
                            '${selectedTask.title} reassigned to ${targetAssignee!.name}. Audit log updated.',
                            backgroundColor: const Color(0xFF10B981),
                            colorText: Colors.white,
                            snackPosition: SnackPosition.BOTTOM,
                            icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
                            margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                            borderRadius: 14,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 🎨 UI BUILD METHOD
  // ───────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final modules = _getModulesData();
    final team = _getTeamMembersData();
    final handovers = _getFilteredHandovers();

    // Summary calculations
    final totalModules = modules.length;
    final completedModules = modules.where((m) => m.status == 'Completed').length;
    final totalTasks = modules.fold<int>(0, (sum, m) => sum + m.totalTasks);
    final completedTasks = modules.fold<int>(0, (sum, m) => sum + m.completedTasks);
    final totalAllocatedHours = modules.fold<int>(0, (sum, m) => sum + m.allocatedHours);
    final totalActualHours = modules.fold<int>(0, (sum, m) => sum + m.actualHoursSpent);
    final overdueTasksCount = modules.expand((m) => m.tasks).where((t) => t.isOverdue).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.slate100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textColorPrimary, size: 18),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              'Project Operations Hub',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
            SizedBox(height: 2),
            AppText(
              'Module progress, team allocation & handover tracking',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ],
        ),
        actions: [
          // Search Toggle Button
          IconButton(
            tooltip: 'Search Work / Tasks',
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _showSearch ? AppColors.primaryColor.withValues(alpha: 0.12) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Iconsax.search_normal,
                color: _showSearch ? AppColors.primaryColor : const Color(0xFF64748B),
                size: 18,
              ),
            ),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
              });
            },
          ),
          // Project Full Details & Files Action Button
          IconButton(
            tooltip: 'Project Overview & Files',
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Iconsax.info_circle, color: Color(0xFF475569), size: 18),
            ),
            onPressed: () {
              Project? p = widget.initialProject;
              if (p == null) {
                for (final item in _projectsController.projects) {
                  if (item.name == _selectedProjectFilter || item.id == widget.initialProjectId) {
                    p = item;
                    break;
                  }
                }
              }
              if (p != null) {
                _projectsController.selectedProject.value = p;
                _projectsController.fetchProjectDetails(p.id);
                Get.to(() => ProjectDetailsScreen(projectId: p?.id));
              }
            },
          ),
          // Reassign / Handover Action Button
          IconButton(
            tooltip: 'Initiate Handover',
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: const Icon(Iconsax.repeat, color: Color(0xFFD97706), size: 18),
            ),
            onPressed: () => _openHandoverDialog(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // ── Top Project Selection Card & Optional Search ──
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              children: [
                // Project Selector Row
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Iconsax.folder_2, color: AppColors.primaryColor, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedProjectFilter,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                            isExpanded: true,
                            items: _getAvailableProjectNames().map((name) {
                              return DropdownMenuItem<String>(
                                value: name,
                                child: Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F172A),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedProjectFilter = val;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Handover Quick Pill
                      InkWell(
                        onTap: () => _openHandoverDialog(),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFBEB),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFFDE68A)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Iconsax.repeat, size: 12, color: Color(0xFFD97706)),
                              SizedBox(width: 4),
                              Text('Handover', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFD97706))),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Collapsible Search Input
                if (_showSearch) ...[
                  const SizedBox(height: 10),
                  TextField(
                    controller: _searchController,
                    autofocus: true,
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search module, task, engineer, or handover reason...',
                      hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                      prefixIcon: const Icon(Iconsax.search_normal, size: 16, color: Color(0xFF94A3B8)),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 16, color: Color(0xFF94A3B8)),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: const Color(0xFFF1F5F9),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── Executive 4-Card Summary Grid (Everything Clear & Separated) ──
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Row(
              children: [
                // Card 1: Modules Progress
                Expanded(
                  child: _buildMetricTile(
                    title: 'Modules',
                    value: '$completedModules / $totalModules',
                    statusText: '${totalModules - completedModules} Left',
                    icon: Iconsax.box_1,
                    color: AppColors.primaryColor,
                    bgColor: const Color(0xFFEFF6FF),
                  ),
                ),
                const SizedBox(width: 8),

                // Card 2: Tasks Status
                Expanded(
                  child: _buildMetricTile(
                    title: 'Tasks',
                    value: '$completedTasks / $totalTasks',
                    statusText: overdueTasksCount > 0 ? '$overdueTasksCount Overdue ⚠️' : '${totalTasks - completedTasks} Pending',
                    icon: Iconsax.task_square,
                    color: const Color(0xFF0D9488),
                    bgColor: const Color(0xFFF0FDFA),
                  ),
                ),
                const SizedBox(width: 8),

                // Card 3: Time Audit
                Expanded(
                  child: _buildMetricTile(
                    title: 'Time Audit',
                    value: '${totalActualHours}h / ${totalAllocatedHours}h',
                    statusText: totalActualHours > totalAllocatedHours
                        ? '+${totalActualHours - totalAllocatedHours}h Overdue'
                        : 'On-Track 🚀',
                    icon: Iconsax.timer_1,
                    color: totalActualHours > totalAllocatedHours ? const Color(0xFFDC2626) : const Color(0xFF059669),
                    bgColor: totalActualHours > totalAllocatedHours ? const Color(0xFFFEF2F2) : const Color(0xFFECFDF5),
                  ),
                ),
                const SizedBox(width: 8),

                // Card 4: Handover Events
                Expanded(
                  child: _buildMetricTile(
                    title: 'Handovers',
                    value: '${_handoversList.length}',
                    statusText: 'Audited',
                    icon: Iconsax.repeat,
                    color: const Color(0xFFD97706),
                    bgColor: const Color(0xFFFFFBEB),
                  ),
                ),
              ],
            ),
          ),

          // ── Clean Tabs Header with Count Badges ──
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primaryColor,
              unselectedLabelColor: const Color(0xFF64748B),
              indicatorColor: AppColors.primaryColor,
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Iconsax.hierarchy_2, size: 15),
                      const SizedBox(width: 5),
                      Text('Modules ($totalModules)'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Iconsax.profile_2user, size: 15),
                      const SizedBox(width: 5),
                      Text('Team (${team.length})'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Iconsax.repeat, size: 15),
                      const SizedBox(width: 5),
                      Text('Handovers (${handovers.length})'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Tab Views ──
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // TAB 1: MODULES & TASKS
                _buildModulesTabView(modules),

                // TAB 2: ASSIGNED TEAM WORKLOAD
                _buildTeamTabView(team),

                // TAB 3: HANDOVER & REASSIGNMENT AUDIT TRAIL
                _buildHandoversTabView(handovers),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required String statusText,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 13),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: color),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: statusText.contains('Overdue') ? const Color(0xFFDC2626) : const Color(0xFF64748B),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 📦 TAB 1: MODULE-WISE VIEW (KITNA HUA, KITNA BACHA, KITNE TIME ME KIYA)
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildModulesTabView(List<ModuleWorkTrackerItem> allModules) {
    final modules = _getFilteredModulesByStatus();

    final completedCount = allModules.where((m) => m.status == 'Completed').length;
    final inProgressCount = allModules.where((m) => m.status == 'In Progress' && !m.isOverdue).length;
    final overdueCount = allModules.where((m) => m.isOverdue).length;

    return Column(
      children: [
        // ── Quick Filter Chips (All, Completed, In Progress, Overdue) ──
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildStatusFilterChip('All', 'All (${allModules.length})', Iconsax.category),
                const SizedBox(width: 8),
                _buildStatusFilterChip('In Progress', 'In Progress ($inProgressCount)', Iconsax.clock, activeColor: const Color(0xFF2563EB)),
                const SizedBox(width: 8),
                _buildStatusFilterChip('Overdue', 'Overdue ⚠️ ($overdueCount)', Iconsax.warning_2, activeColor: const Color(0xFFDC2626)),
                const SizedBox(width: 8),
                _buildStatusFilterChip('Completed', 'Completed 🎉 ($completedCount)', Icons.check_circle_outline_rounded, activeColor: const Color(0xFF059669)),
              ],
            ),
          ),
        ),

        // ── Modules List ──
        Expanded(
          child: modules.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Iconsax.hierarchy_2, size: 48, color: AppColors.slate300),
                      const SizedBox(height: 12),
                      const AppText('No modules found matching this filter', fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _moduleStatusFilter = 'All';
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                        child: const Text('Reset Filters', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryColor)),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: modules.length,
                  itemBuilder: (context, index) {
                    final mod = modules[index];
                    final isExpanded = _expandedModuleIds.contains(mod.id);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: mod.isOverdue ? const Color(0xFFFCA5A5) : const Color(0xFFE2E8F0),
                          width: mod.isOverdue ? 1.5 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Top Header of Module Card ──
                          Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Module Category Icon
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: mod.status == 'Completed'
                                            ? const Color(0xFFECFDF5)
                                            : (mod.isOverdue ? const Color(0xFFFEF2F2) : AppColors.primaryColor.withValues(alpha: 0.1)),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        mod.status == 'Completed'
                                            ? Icons.check_circle_rounded
                                            : (mod.isOverdue ? Iconsax.warning_2 : Iconsax.box_1),
                                        color: mod.status == 'Completed'
                                            ? const Color(0xFF059669)
                                            : (mod.isOverdue ? const Color(0xFFDC2626) : AppColors.primaryColor),
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 10),

                                    // Module Title and Project
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            mod.name,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFF0F172A),
                                              height: 1.25,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFF1F5F9),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  mod.projectName,
                                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Prominent Status Badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: mod.status == 'Completed'
                                            ? const Color(0xFFDCFCE7)
                                            : (mod.isOverdue ? const Color(0xFFFEE2E2) : const Color(0xFFFEF3C7)),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: mod.status == 'Completed'
                                              ? const Color(0xFF86EFAC)
                                              : (mod.isOverdue ? const Color(0xFFFCA5A5) : const Color(0xFFFDE68A)),
                                        ),
                                      ),
                                      child: Text(
                                        mod.status == 'Completed'
                                            ? 'Completed 🎉'
                                            : (mod.isOverdue ? 'Overdue (+${mod.varianceHours}h) ⚠️' : 'In Progress ⏳'),
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.bold,
                                          color: mod.status == 'Completed'
                                              ? const Color(0xFF166534)
                                              : (mod.isOverdue ? const Color(0xFFB91C1C) : const Color(0xFFB45309)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 8),
                                Text(
                                  mod.description,
                                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B), height: 1.3),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),

                                const SizedBox(height: 14),

                                // ── 2 Side-by-Side Clean Breakdown Boxes (Tasks Status + Time Tracker) ──
                                Row(
                                  children: [
                                    // Box A: Tasks Progress
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF8FAFC),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: const Color(0xFFE2E8F0)),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Row(
                                              children: [
                                                Icon(Iconsax.task_square, size: 12, color: Color(0xFF64748B)),
                                                SizedBox(width: 4),
                                                Text('TASKS SUMMARY', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${mod.completedTasks} Done',
                                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                                            ),
                                            const SizedBox(height: 1),
                                            Text(
                                              '${mod.undoneTasks} Pending (${mod.totalTasks} Total)',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: mod.undoneTasks > 0 ? const Color(0xFFD97706) : const Color(0xFF059669),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),

                                    // Box B: Time Given vs Taken
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: mod.isOverdue ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: mod.isOverdue ? const Color(0xFFFECACA) : const Color(0xFFBBF7D0),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Iconsax.timer_1,
                                                  size: 12,
                                                  color: mod.isOverdue ? const Color(0xFFDC2626) : const Color(0xFF059669),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'TIME AUDIT',
                                                  style: TextStyle(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.bold,
                                                    color: mod.isOverdue ? const Color(0xFFDC2626) : const Color(0xFF059669),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${mod.actualHoursSpent}h / ${mod.allocatedHours}h',
                                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                                            ),
                                            const SizedBox(height: 1),
                                            Text(
                                              mod.status == 'Completed'
                                                  ? (mod.actualHoursSpent <= mod.allocatedHours
                                                      ? 'Saved ${mod.allocatedHours - mod.actualHoursSpent}h ✅'
                                                      : '+${mod.varianceHours}h Extra ⚠️')
                                                  : (mod.allocatedHours - mod.actualHoursSpent > 0
                                                      ? '${mod.allocatedHours - mod.actualHoursSpent}h Left'
                                                      : '+${mod.varianceHours}h Overdue ⚠️'),
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: mod.isOverdue ? const Color(0xFFDC2626) : const Color(0xFF059669),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                // Progress Indicator Bar
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Completion: ${(mod.progress * 100).toInt()}% Done',
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
                                    ),
                                    Text(
                                      mod.progress == 1.0 ? '100% Complete' : '${((1 - mod.progress) * 100).toInt()}% Remaining',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w600,
                                        color: mod.progress == 1.0 ? const Color(0xFF059669) : const Color(0xFF94A3B8),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    value: mod.progress,
                                    minHeight: 6,
                                    backgroundColor: const Color(0xFFE2E8F0),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      mod.progress == 1.0 ? const Color(0xFF10B981) : AppColors.primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // ── Explicit Expand / Collapse Action Button ──
                          InkWell(
                            onTap: () {
                              setState(() {
                                if (isExpanded) {
                                  _expandedModuleIds.remove(mod.id);
                                } else {
                                  _expandedModuleIds.add(mod.id);
                                }
                              });
                            },
                            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                              decoration: BoxDecoration(
                                color: isExpanded ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
                                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
                                border: const Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                                    size: 16,
                                    color: isExpanded ? AppColors.primaryColor : const Color(0xFF64748B),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    isExpanded
                                        ? 'Hide Tasks & Engineers'
                                        : 'View ${mod.tasks.length} Tasks & Assigned Engineers',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: isExpanded ? AppColors.primaryColor : const Color(0xFF475569),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // ── Expanded Tasks List ──
                          if (isExpanded) ...[
                            Container(
                              color: const Color(0xFFF8FAFC),
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const AppText(
                                        'Task Breakdown & Employee Time Tracking:',
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF475569),
                                      ),
                                      AppText('${mod.tasks.length} items', fontSize: 10.5, color: const Color(0xFF94A3B8)),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  ...mod.tasks.map((task) => _buildTaskItemCard(task)),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildStatusFilterChip(String key, String label, IconData icon, {Color? activeColor}) {
    final isSelected = _moduleStatusFilter == key;
    final color = activeColor ?? AppColors.primaryColor;

    return InkWell(
      onTap: () {
        setState(() {
          _moduleStatusFilter = key;
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.12) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: isSelected ? color : const Color(0xFF64748B)),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? color : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskItemCard(TaskWorkTrackerItem task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: task.isOverdue ? const Color(0xFFFECACA) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top: Title, Priority & Status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Priority Indicator
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: task.priority == 'Critical'
                      ? const Color(0xFFFEE2E2)
                      : (task.priority == 'High' ? const Color(0xFFFEF3C7) : const Color(0xFFF1F5F9)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  task.priority.toUpperCase(),
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    color: task.priority == 'Critical'
                        ? const Color(0xFFDC2626)
                        : (task.priority == 'High' ? const Color(0xFFB45309) : const Color(0xFF475569)),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Title
              Expanded(
                child: Text(
                  task.title,
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
              ),
              const SizedBox(width: 8),

              // Status Tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: task.status == 'Completed'
                      ? const Color(0xFFDCFCE7)
                      : (task.status == 'In Progress' ? const Color(0xFFEFF6FF) : const Color(0xFFF1F5F9)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  task.status,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    color: task.status == 'Completed'
                        ? const Color(0xFF166534)
                        : (task.status == 'In Progress' ? const Color(0xFF1D4ED8) : const Color(0xFF475569)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Assignee & Handover Action Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundImage: NetworkImage(task.assignee.avatarUrl),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.assignee.name,
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        task.assignee.designation ?? "Software Engineer",
                        style: const TextStyle(fontSize: 9.5, color: Color(0xFF64748B)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Reassign / Handover Button
                InkWell(
                  onTap: () => _openHandoverDialog(preselectedTask: task),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Iconsax.repeat, size: 11, color: Color(0xFFB45309)),
                        SizedBox(width: 4),
                        Text('Handover', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFB45309))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Time Details (Allocated vs Spent with Clear Outcome)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: task.isOverdue ? const Color(0xFFFEF2F2) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('Time Given: ', style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
                    Text('${task.allocatedHours} hrs', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  ],
                ),
                Row(
                  children: [
                    const Text('Time Spent: ', style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
                    Text('${task.actualHoursSpent} hrs', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  ],
                ),
                Text(
                  task.actualHoursSpent > task.allocatedHours
                      ? '+${task.varianceHours}h Overdue ⚠️'
                      : (task.status == 'Completed'
                          ? 'Saved ${task.allocatedHours - task.actualHoursSpent}h ✅'
                          : 'On-Track 🚀'),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: task.actualHoursSpent > task.allocatedHours ? const Color(0xFFDC2626) : const Color(0xFF059669),
                  ),
                ),
              ],
            ),
          ),

          // Handover Audit Callout (Agar kisi se handover hua tha)
          if (task.isHandedOver) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Iconsax.info_circle, size: 12, color: Color(0xFFB45309)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Reassigned from ${task.lastHandoverFrom}: "${task.handoverReason}"',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF92400E), height: 1.2),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 👥 TAB 2: ASSIGNED TEAM VIEW (KAUN KITNA KAAM KAR RHA)
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildTeamTabView(List<TeamMemberWorkSummary> team) {
    if (team.isEmpty) {
      return const Center(
        child: AppText('No team members assigned to selected project', fontSize: 13, color: Color(0xFF64748B)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: team.length,
      itemBuilder: (context, index) {
        final member = team[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: member.isExceeded ? const Color(0xFFFECACA) : AppColors.slate200,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Employee info header
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundImage: NetworkImage(member.user.avatarUrl),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          member.user.name,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          member.user.designation ?? 'Software Engineer',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: member.isExceeded ? const Color(0xFFFEE2E2) : const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      member.isExceeded
                          ? 'Overdue (+${member.varianceHours}h) ⚠️'
                          : 'On Time (Saved ${member.allocatedHours - member.actualHoursSpent}h) 🚀',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: member.isExceeded ? const Color(0xFFDC2626) : const Color(0xFF059669),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Assigned Modules tags
              const AppText('Assigned Modules:', fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: member.assignedModules.map((modName) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      modName,
                      style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              // Tasks Stats Grid
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCol('Total Tasks', '${member.totalTasks}', const Color(0xFF0F172A)),
                    _buildStatCol('Completed', '${member.completedTasks}', const Color(0xFF059669)),
                    _buildStatCol('In Progress', '${member.inProgressTasks}', const Color(0xFF2563EB)),
                    _buildStatCol('Handovers', '${member.handoversGivenCount} Given', const Color(0xFFD97706)),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Allocated vs Actual Time Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Time Efficiency: ${(member.completionRate * 100).toInt()}% Done',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                  ),
                  Text(
                    'Spent: ${member.actualHoursSpent}h / Allocated: ${member.allocatedHours}h',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: member.isExceeded ? const Color(0xFFDC2626) : const Color(0xFF059669),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: member.allocatedHours > 0
                      ? (member.actualHoursSpent / member.allocatedHours).clamp(0.0, 1.0)
                      : 0.0,
                  minHeight: 6,
                  backgroundColor: const Color(0xFFE2E8F0),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    member.isExceeded ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCol(String title, String val, Color color) {
    return Column(
      children: [
        Text(val, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(height: 2),
        Text(title, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 🔄 TAB 3: HANDOVER & AUDIT TRAIL (PURA HANDOVER KA DETAIL)
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildHandoversTabView(List<HandoverAuditRecord> handovers) {
    if (handovers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Iconsax.repeat, size: 48, color: Color(0xFFCBD5E1)),
            const SizedBox(height: 12),
            const AppText('No handover events logged yet', fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Iconsax.repeat, size: 14, color: Colors.white),
              label: const Text('Initiate Handover', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD97706),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => _openHandoverDialog(),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: handovers.length,
      itemBuilder: (context, index) {
        final item = handovers[index];
        final timeStr = DateFormat('dd MMM yyyy, hh:mm a').format(item.handoverTimestamp);

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFFDE68A)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top record ID and Timestamp (Kab Diya)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFFCD34D)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Iconsax.repeat, size: 12, color: Color(0xFFB45309)),
                        const SizedBox(width: 4),
                        Text(item.id, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFB45309))),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Iconsax.calendar_1, size: 12, color: Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      Text(timeStr, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Task and Module
              Text(
                item.taskTitle,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 3),
              Text(
                'Module: ${item.moduleName} • ${item.projectName}',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 12),

              // Flow Diagram: [From User] ──> [To User]
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    // From User
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Handed Over By (Kisne Diya):', style: TextStyle(fontSize: 9.5, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              CircleAvatar(radius: 13, backgroundImage: NetworkImage(item.fromUser.avatarUrl)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  item.fromUser.name,
                                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Worked for: ${item.formattedWorkedTime}',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFD97706)),
                          ),
                        ],
                      ),
                    ),

                    // Arrow
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFEF3C7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_forward_rounded, size: 16, color: Color(0xFFB45309)),
                    ),
                    const SizedBox(width: 8),

                    // To User
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Assigned To (Kisko Diya):', style: TextStyle(fontSize: 9.5, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              CircleAvatar(radius: 13, backgroundImage: NetworkImage(item.toUser.avatarUrl)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  item.toUser.name,
                                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Allocated: ${item.allocatedHoursToNewAssignee} hrs',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Reason Note (Kyu Diya)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Iconsax.info_circle, size: 14, color: Color(0xFFB45309)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Handover Reason (क्यो हैंडओवर किया):', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF92400E))),
                          const SizedBox(height: 2),
                          Text(
                            item.handoverReason,
                            style: const TextStyle(fontSize: 11, color: Color(0xFF78350F), height: 1.3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Status & Completion Outcome
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text('Current Status: ', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: item.status == 'Completed' ? const Color(0xFFDCFCE7) : const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.status,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: item.status == 'Completed' ? const Color(0xFF166534) : const Color(0xFF1D4ED8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (item.status == 'Completed')
                    Text(
                      item.isOverdue
                          ? 'Completed with +${item.varianceHours}h Overdue ⚠️'
                          : 'Completed in ${item.actualHoursTakenByNewAssignee}h (On Time ✅)',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: item.isOverdue ? const Color(0xFFDC2626) : const Color(0xFF059669),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
