import 'package:get/get.dart';

class AdminReportEmployee {
  final String id;
  final String employeeId;
  final String name;
  final String designation;
  final String status; // 'Active', 'On Leave', 'Inactive'
  final String avatarUrl;
  final String email;

  // Overview stats for This Month (May 2024)
  final int presentDays;
  final int totalWorkingDays;
  final int totalLeaves;
  final double totalSales;
  final int totalLeads;
  final int tasksCompleted;
  final int totalTasks;
  final String performance; // 'Good', 'Excellent', 'Outstanding', 'Average'
  
  final List<AdminActivity> recentActivities;
  final Map<int, String> attendanceCalendar; // Map of day -> status ('Present', 'Absent', 'Late', 'Half Day')
  
  // Payroll stats
  final double basicSalary;
  final double hra;
  final double conveyance;
  final double performanceBonus;
  final double tds;
  final double pf;
  final double esi;
  final double otherDeductions;
  
  // Leave Balance
  final int casualLeaveUsed;
  final int casualLeaveTotal;
  final int sickLeaveUsed;
  final int sickLeaveTotal;
  final int earnedLeaveUsed;
  final int earnedLeaveTotal;
  final List<AdminLeaveRequest> leaveHistory;

  // Sales Stats
  final int leadsCount;
  final int convertedLeadsCount;
  final double salesTarget;
  final List<Map<String, dynamic>> topProducts;
  final Map<String, int> leadsOverview; // status -> count

  // Projects & Tasks
  final List<AdminProjectReport> projects;

  const AdminReportEmployee({
    required this.id,
    required this.employeeId,
    required this.name,
    required this.designation,
    required this.status,
    required this.avatarUrl,
    required this.email,
    required this.presentDays,
    required this.totalWorkingDays,
    required this.totalLeaves,
    required this.totalSales,
    required this.totalLeads,
    required this.tasksCompleted,
    required this.totalTasks,
    required this.performance,
    required this.recentActivities,
    required this.attendanceCalendar,
    required this.basicSalary,
    required this.hra,
    required this.conveyance,
    required this.performanceBonus,
    required this.tds,
    required this.pf,
    required this.esi,
    required this.otherDeductions,
    required this.casualLeaveUsed,
    required this.casualLeaveTotal,
    required this.sickLeaveUsed,
    required this.sickLeaveTotal,
    required this.earnedLeaveUsed,
    required this.earnedLeaveTotal,
    required this.leaveHistory,
    required this.leadsCount,
    required this.convertedLeadsCount,
    required this.salesTarget,
    required this.topProducts,
    required this.leadsOverview,
    required this.projects,
  });

  double get grossEarnings => basicSalary + hra + conveyance + performanceBonus;
  double get totalDeductions => tds + pf + esi + otherDeductions;
  double get netSalary => grossEarnings - totalDeductions;
  double get conversionRate => leadsCount > 0 ? (convertedLeadsCount / leadsCount) * 100 : 0.0;
}

class AdminActivity {
  final String title;
  final String time;
  final String meta;

  const AdminActivity({
    required this.title,
    required this.time,
    this.meta = '',
  });
}

class AdminLeaveRequest {
  final String date;
  final String type;
  final String duration;
  final String status; // 'Approved', 'Pending', 'Rejected'

  const AdminLeaveRequest({
    required this.date,
    required this.type,
    required this.duration,
    required this.status,
  });
}

class AdminProjectReport {
  final String name;
  final int progress; // percentage 0-100
  final String status; // 'In Progress', 'Completed', 'On Hold'
  final int totalTasks;
  final int completedTasks;
  final List<AdminProjectTask> tasksBreakdown;

  const AdminProjectReport({
    required this.name,
    required this.progress,
    required this.status,
    required this.totalTasks,
    required this.completedTasks,
    required this.tasksBreakdown,
  });
}

class AdminProjectTask {
  final String title;
  final String assignedTo;
  final String status; // 'Completed', 'In Progress', 'Pending'
  final String dueDate;
  final int progress;

  const AdminProjectTask({
    required this.title,
    required this.assignedTo,
    required this.status,
    required this.dueDate,
    required this.progress,
  });
}

class AdminReportsController extends GetxController {
  final employees = <AdminReportEmployee>[].obs;
  final filteredEmployees = <AdminReportEmployee>[].obs;

  final selectedEmployee = Rxn<AdminReportEmployee>();
  final activeMonth = 'May 2024'.obs;
  final availableMonths = const ['May 2024', 'April 2024', 'March 2024', 'February 2024', 'January 2024'];
  
  void changeActiveMonth(String month) {
    activeMonth.value = month;
  }
  
  // Search and Filter tabs
  final searchQuery = ''.obs;
  final activeFilterTab = 'All'.obs; // 'All', 'Active', 'On Leave', 'Inactive'

  @override
  void onInit() {
    super.onInit();
    _seedMockData();
    filteredEmployees.assignAll(employees);
    // Select first employee by default
    if (employees.isNotEmpty) {
      selectedEmployee.value = employees[0];
    }
  }

  void filterEmployees(String query) {
    searchQuery.value = query;
    _applyFilter();
  }

  void setFilterTab(String tab) {
    activeFilterTab.value = tab;
    _applyFilter();
  }

  void selectEmployee(AdminReportEmployee emp) {
    selectedEmployee.value = emp;
  }

  void _applyFilter() {
    List<AdminReportEmployee> temp = List.from(employees);

    // Filter by tab
    if (activeFilterTab.value != 'All') {
      temp = temp.where((e) => e.status.toLowerCase() == activeFilterTab.value.toLowerCase()).toList();
    }

    // Filter by search query
    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      temp = temp.where((e) => e.name.toLowerCase().contains(q) || e.designation.toLowerCase().contains(q)).toList();
    }

    filteredEmployees.assignAll(temp);
  }

  void _seedMockData() {
    // Standard mock calendar of attendance for May 2024
    // 1-31: Present, Late, Absent, Half Day, Weekend (Saturdays & Sundays are weekly offs)
    // Sundays: 5, 12, 19, 26. Saturdays: 4, 11, 18, 25.
    Map<int, String> getCalendarFor(String type) {
      final Map<int, String> cal = {};
      for (int i = 1; i <= 31; i++) {
        final dayOfWeek = DateTime(2024, 5, i).weekday;
        if (dayOfWeek == DateTime.saturday || dayOfWeek == DateTime.sunday) {
          cal[i] = 'Weekend';
        } else {
          cal[i] = 'Present';
        }
      }
      
      if (type == 'Sales') {
        cal[3] = 'Late';
        cal[9] = 'Late';
        cal[17] = 'Absent';
        cal[21] = 'Half Day';
      } else if (type == 'Dev') {
        cal[8] = 'Absent';
        cal[15] = 'Late';
        cal[22] = 'Half Day';
      } else if (type == 'HR') {
        cal[10] = 'Half Day';
        cal[24] = 'Late';
      } else {
        cal[6] = 'Late';
        cal[13] = 'Absent';
        cal[27] = 'Half Day';
      }
      return cal;
    }

    employees.addAll([
      AdminReportEmployee(
        id: '1',
        employeeId: 'EMP001',
        name: 'Rahul Sharma',
        designation: 'Sales Executive',
        status: 'Active',
        avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&auto=format&fit=crop&q=80',
        email: 'rahul.sharma@company.com',
        presentDays: 22,
        totalWorkingDays: 26,
        totalLeaves: 1,
        totalSales: 180000.0,
        totalLeads: 28,
        tasksCompleted: 18,
        totalTasks: 25,
        performance: 'Good',
        recentActivities: const [
          AdminActivity(title: 'Closed deal with Tech Solutions', time: '15 May 2024', meta: '₹45,000'),
          AdminActivity(title: 'Follow-up with ABC Pvt Ltd', time: '14 May 2024'),
          AdminActivity(title: 'Meeting with Neha Kapoor', time: '12 May 2024'),
          AdminActivity(title: 'Proposal sent to Bright Marketing', time: '10 May 2024'),
        ],
        attendanceCalendar: getCalendarFor('Sales'),
        basicSalary: 30000.0,
        hra: 8000.0,
        conveyance: 2000.0,
        performanceBonus: 5000.0,
        tds: 3000.0,
        pf: 2000.0,
        esi: 500.0,
        otherDeductions: 1500.0,
        casualLeaveUsed: 6,
        casualLeaveTotal: 10,
        sickLeaveUsed: 4,
        sickLeaveTotal: 8,
        earnedLeaveUsed: 10,
        earnedLeaveTotal: 15,
        leaveHistory: const [
          AdminLeaveRequest(date: '24 May 2024', type: 'Casual Leave', duration: '1 Day', status: 'Approved'),
          AdminLeaveRequest(date: '15 May 2024', type: 'Sick Leave', duration: '1 Day', status: 'Approved'),
          AdminLeaveRequest(date: '02 May 2024', type: 'Earned Leave', duration: '2 Days', status: 'Approved'),
          AdminLeaveRequest(date: '18 Apr 2024', type: 'Casual Leave', duration: '1 Day', status: 'Approved'),
          AdminLeaveRequest(date: '05 Apr 2024', type: 'Sick Leave', duration: '1 Day', status: 'Rejected'),
        ],
        leadsCount: 28,
        convertedLeadsCount: 12,
        salesTarget: 250000.0,
        topProducts: const [
          {'name': 'Product A', 'value': 80000.0},
          {'name': 'Product B', 'value': 60000.0},
          {'name': 'Service C', 'value': 40000.0},
        ],
        leadsOverview: const {
          'New': 10,
          'Contacted': 8,
          'Converted': 12,
          'Lost': 2,
        },
        projects: const [
          AdminProjectReport(
            name: 'CRM Development',
            progress: 68,
            status: 'In Progress',
            totalTasks: 10,
            completedTasks: 7,
            tasksBreakdown: [
              AdminProjectTask(title: 'Requirement Analysis', assignedTo: 'Rahul Sharma', status: 'Completed', dueDate: '05 May 2024', progress: 100),
              AdminProjectTask(title: 'Database Design', assignedTo: 'Rahul Sharma', status: 'Completed', dueDate: '15 May 2024', progress: 100),
              AdminProjectTask(title: 'API Development', assignedTo: 'Rahul Sharma', status: 'In Progress', dueDate: '25 May 2024', progress: 60),
            ],
          ),
          AdminProjectReport(
            name: 'Website Redesign',
            progress: 80,
            status: 'Completed',
            totalTasks: 5,
            completedTasks: 5,
            tasksBreakdown: [],
          ),
          AdminProjectReport(
            name: 'Mobile App',
            progress: 35,
            status: 'In Progress',
            totalTasks: 15,
            completedTasks: 4,
            tasksBreakdown: [],
          ),
          AdminProjectReport(
            name: 'Dashboard Design',
            progress: 100,
            status: 'Completed',
            totalTasks: 4,
            completedTasks: 4,
            tasksBreakdown: [],
          ),
          AdminProjectReport(
            name: 'SEO Optimization',
            progress: 20,
            status: 'On Hold',
            totalTasks: 8,
            completedTasks: 1,
            tasksBreakdown: [],
          ),
        ],
      ),
      AdminReportEmployee(
        id: '2',
        employeeId: 'EMP002',
        name: 'Neha Kapoor',
        designation: 'Business Developer',
        status: 'Active',
        avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&auto=format&fit=crop&q=80',
        email: 'neha.kapoor@company.com',
        presentDays: 24,
        totalWorkingDays: 26,
        totalLeaves: 0,
        totalSales: 250000.0,
        totalLeads: 35,
        tasksCompleted: 22,
        totalTasks: 25,
        performance: 'Excellent',
        recentActivities: const [
          AdminActivity(title: 'Signed MOU with Global Trade', time: '20 May 2024', meta: '₹1,50,000'),
          AdminActivity(title: 'Pitched corporate onboarding suite', time: '18 May 2024'),
          AdminActivity(title: 'Followed-up with Alpha Systems', time: '17 May 2024'),
        ],
        attendanceCalendar: getCalendarFor('Sales'),
        basicSalary: 35000.0,
        hra: 9000.0,
        conveyance: 2000.0,
        performanceBonus: 8000.0,
        tds: 4000.0,
        pf: 2500.0,
        esi: 500.0,
        otherDeductions: 500.0,
        casualLeaveUsed: 3,
        casualLeaveTotal: 10,
        sickLeaveUsed: 2,
        sickLeaveTotal: 8,
        earnedLeaveUsed: 4,
        earnedLeaveTotal: 15,
        leaveHistory: const [
          AdminLeaveRequest(date: '10 Apr 2024', type: 'Casual Leave', duration: '1 Day', status: 'Approved'),
        ],
        leadsCount: 35,
        convertedLeadsCount: 18,
        salesTarget: 300000.0,
        topProducts: const [
          {'name': 'Enterprise Pack', 'value': 150000.0},
          {'name': 'Product A', 'value': 100000.0},
        ],
        leadsOverview: const {
          'New': 12,
          'Contacted': 5,
          'Converted': 18,
          'Lost': 0,
        },
        projects: const [
          AdminProjectReport(
            name: 'Website Redesign',
            progress: 95,
            status: 'In Progress',
            totalTasks: 8,
            completedTasks: 7,
            tasksBreakdown: [],
          ),
        ],
      ),
      AdminReportEmployee(
        id: '3',
        employeeId: 'EMP003',
        name: 'Amit Singh',
        designation: 'Project Manager',
        status: 'Active',
        avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&auto=format&fit=crop&q=80',
        email: 'amit.singh@company.com',
        presentDays: 23,
        totalWorkingDays: 26,
        totalLeaves: 2,
        totalSales: 0.0,
        totalLeads: 0,
        tasksCompleted: 24,
        totalTasks: 28,
        performance: 'Outstanding',
        recentActivities: const [
          AdminActivity(title: 'Sprint planning CRM Development completed', time: '22 May 2024'),
          AdminActivity(title: 'Approved Database layout changes', time: '19 May 2024'),
          AdminActivity(title: 'Milestone delivery Website Redesign', time: '15 May 2024'),
        ],
        attendanceCalendar: getCalendarFor('Dev'),
        basicSalary: 60000.0,
        hra: 15000.0,
        conveyance: 3000.0,
        performanceBonus: 10000.0,
        tds: 8000.0,
        pf: 4500.0,
        esi: 500.0,
        otherDeductions: 0.0,
        casualLeaveUsed: 5,
        casualLeaveTotal: 10,
        sickLeaveUsed: 3,
        sickLeaveTotal: 8,
        earnedLeaveUsed: 6,
        earnedLeaveTotal: 15,
        leaveHistory: const [
          AdminLeaveRequest(date: '08 May 2024', type: 'Sick Leave', duration: '1 Day', status: 'Approved'),
          AdminLeaveRequest(date: '22 Apr 2024', type: 'Casual Leave', duration: '1 Day', status: 'Approved'),
        ],
        leadsCount: 0,
        convertedLeadsCount: 0,
        salesTarget: 0.0,
        topProducts: const [],
        leadsOverview: const {},
        projects: const [
          AdminProjectReport(
            name: 'CRM Development',
            progress: 68,
            status: 'In Progress',
            totalTasks: 20,
            completedTasks: 14,
            tasksBreakdown: [],
          ),
          AdminProjectReport(
            name: 'Website Redesign',
            progress: 100,
            status: 'Completed',
            totalTasks: 12,
            completedTasks: 12,
            tasksBreakdown: [],
          ),
        ],
      ),
      AdminReportEmployee(
        id: '4',
        employeeId: 'EMP004',
        name: 'Pooja Mehta',
        designation: 'HR Executive',
        status: 'Active',
        avatarUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150&auto=format&fit=crop&q=80',
        email: 'pooja.mehta@company.com',
        presentDays: 24,
        totalWorkingDays: 26,
        totalLeaves: 1,
        totalSales: 0.0,
        totalLeads: 0,
        tasksCompleted: 15,
        totalTasks: 16,
        performance: 'Good',
        recentActivities: const [
          AdminActivity(title: 'Organized employee engagement drive', time: '21 May 2024'),
          AdminActivity(title: 'Processed monthly salary sheets', time: '20 May 2024'),
          AdminActivity(title: 'Resolved standard grievance ticket', time: '17 May 2024'),
        ],
        attendanceCalendar: getCalendarFor('HR'),
        basicSalary: 28000.0,
        hra: 7000.0,
        conveyance: 2000.0,
        performanceBonus: 3000.0,
        tds: 2000.0,
        pf: 1800.0,
        esi: 500.0,
        otherDeductions: 0.0,
        casualLeaveUsed: 4,
        casualLeaveTotal: 10,
        sickLeaveUsed: 2,
        sickLeaveTotal: 8,
        earnedLeaveUsed: 5,
        earnedLeaveTotal: 15,
        leaveHistory: const [
          AdminLeaveRequest(date: '10 May 2024', type: 'Casual Leave', duration: '1 Day', status: 'Approved'),
        ],
        leadsCount: 0,
        convertedLeadsCount: 0,
        salesTarget: 0.0,
        topProducts: const [],
        leadsOverview: const {},
        projects: const [],
      ),
      AdminReportEmployee(
        id: '5',
        employeeId: 'EMP005',
        name: 'Vikas Yadav',
        designation: 'Marketing Executive',
        status: 'Active',
        avatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&auto=format&fit=crop&q=80',
        email: 'vikas.yadav@company.com',
        presentDays: 23,
        totalWorkingDays: 26,
        totalLeaves: 3,
        totalSales: 95000.0,
        totalLeads: 40,
        tasksCompleted: 10,
        totalTasks: 14,
        performance: 'Average',
        recentActivities: const [
          AdminActivity(title: 'Launched summer digital promo', time: '18 May 2024', meta: '₹12,000 budget'),
          AdminActivity(title: 'Analytics report Google Ads submitted', time: '15 May 2024'),
        ],
        attendanceCalendar: getCalendarFor('Sales'),
        basicSalary: 25000.0,
        hra: 6000.0,
        conveyance: 2000.0,
        performanceBonus: 2000.0,
        tds: 1500.0,
        pf: 1600.0,
        esi: 500.0,
        otherDeductions: 1000.0,
        casualLeaveUsed: 7,
        casualLeaveTotal: 10,
        sickLeaveUsed: 3,
        sickLeaveTotal: 8,
        earnedLeaveUsed: 8,
        earnedLeaveTotal: 15,
        leaveHistory: const [
          AdminLeaveRequest(date: '12 May 2024', type: 'Casual Leave', duration: '2 Days', status: 'Approved'),
          AdminLeaveRequest(date: '03 May 2024', type: 'Sick Leave', duration: '1 Day', status: 'Approved'),
        ],
        leadsCount: 40,
        convertedLeadsCount: 15,
        salesTarget: 150000.0,
        topProducts: const [
          {'name': 'Product B', 'value': 55000.0},
          {'name': 'Service C', 'value': 40000.0},
        ],
        leadsOverview: const {
          'New': 18,
          'Contacted': 7,
          'Converted': 15,
          'Lost': 0,
        },
        projects: const [
          AdminProjectReport(
            name: 'SEO Optimization',
            progress: 40,
            status: 'In Progress',
            totalTasks: 10,
            completedTasks: 4,
            tasksBreakdown: [],
          ),
        ],
      ),
      AdminReportEmployee(
        id: '6',
        employeeId: 'EMP006',
        name: 'Sneha Joshi',
        designation: 'Accountant',
        status: 'Active',
        avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&auto=format&fit=crop&q=80',
        email: 'sneha.joshi@company.com',
        presentDays: 24,
        totalWorkingDays: 26,
        totalLeaves: 1,
        totalSales: 0.0,
        totalLeads: 0,
        tasksCompleted: 14,
        totalTasks: 15,
        performance: 'Good',
        recentActivities: const [
          AdminActivity(title: 'Tax returns Q1 filing validated', time: '22 May 2024'),
          AdminActivity(title: 'Audited corporate ledger reports', time: '19 May 2024'),
        ],
        attendanceCalendar: getCalendarFor('HR'),
        basicSalary: 32000.0,
        hra: 8000.0,
        conveyance: 2000.0,
        performanceBonus: 4000.0,
        tds: 2500.0,
        pf: 2100.0,
        esi: 500.0,
        otherDeductions: 0.0,
        casualLeaveUsed: 4,
        casualLeaveTotal: 10,
        sickLeaveUsed: 3,
        sickLeaveTotal: 8,
        earnedLeaveUsed: 2,
        earnedLeaveTotal: 15,
        leaveHistory: const [
          AdminLeaveRequest(date: '14 May 2024', type: 'Casual Leave', duration: '1 Day', status: 'Approved'),
        ],
        leadsCount: 0,
        convertedLeadsCount: 0,
        salesTarget: 0.0,
        topProducts: const [],
        leadsOverview: const {},
        projects: const [],
      ),
      AdminReportEmployee(
        id: '7',
        employeeId: 'EMP007',
        name: 'Rohit Verma',
        designation: 'Support Executive',
        status: 'Active',
        avatarUrl: 'https://images.unsplash.com/photo-1463453091185-61582044d556?w=150&auto=format&fit=crop&q=80',
        email: 'rohit.verma@company.com',
        presentDays: 22,
        totalWorkingDays: 26,
        totalLeaves: 3,
        totalSales: 0.0,
        totalLeads: 0,
        tasksCompleted: 45,
        totalTasks: 50,
        performance: 'Excellent',
        recentActivities: const [
          AdminActivity(title: 'Resolved critical client database crash', time: '24 May 2024'),
          AdminActivity(title: 'Updated support knowledge database', time: '20 May 2024'),
        ],
        attendanceCalendar: getCalendarFor('Sales'),
        basicSalary: 22000.0,
        hra: 5500.0,
        conveyance: 1500.0,
        performanceBonus: 2500.0,
        tds: 1000.0,
        pf: 1400.0,
        esi: 500.0,
        otherDeductions: 500.0,
        casualLeaveUsed: 5,
        casualLeaveTotal: 10,
        sickLeaveUsed: 4,
        sickLeaveTotal: 8,
        earnedLeaveUsed: 6,
        earnedLeaveTotal: 15,
        leaveHistory: const [
          AdminLeaveRequest(date: '10 May 2024', type: 'Sick Leave', duration: '2 Days', status: 'Approved'),
          AdminLeaveRequest(date: '02 May 2024', type: 'Casual Leave', duration: '1 Day', status: 'Approved'),
        ],
        leadsCount: 0,
        convertedLeadsCount: 0,
        salesTarget: 0.0,
        topProducts: const [],
        leadsOverview: const {},
        projects: const [],
      ),
      AdminReportEmployee(
        id: '8',
        employeeId: 'EMP008',
        name: 'Priya Patel',
        designation: 'Sales Executive',
        status: 'Active',
        avatarUrl: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=150&auto=format&fit=crop&q=80',
        email: 'priya.patel@company.com',
        presentDays: 25,
        totalWorkingDays: 26,
        totalLeaves: 1,
        totalSales: 220000.0,
        totalLeads: 30,
        tasksCompleted: 19,
        totalTasks: 22,
        performance: 'Outstanding',
        recentActivities: const [
          AdminActivity(title: 'Closed deals with three prospects', time: '23 May 2024', meta: '₹1,20,000'),
          AdminActivity(title: 'Held product demo session', time: '21 May 2024'),
        ],
        attendanceCalendar: getCalendarFor('Sales'),
        basicSalary: 31000.0,
        hra: 8000.0,
        conveyance: 2000.0,
        performanceBonus: 6000.0,
        tds: 3000.0,
        pf: 2000.0,
        esi: 500.0,
        otherDeductions: 0.0,
        casualLeaveUsed: 3,
        casualLeaveTotal: 10,
        sickLeaveUsed: 1,
        sickLeaveTotal: 8,
        earnedLeaveUsed: 7,
        earnedLeaveTotal: 15,
        leaveHistory: const [
          AdminLeaveRequest(date: '17 May 2024', type: 'Casual Leave', duration: '1 Day', status: 'Approved'),
        ],
        leadsCount: 30,
        convertedLeadsCount: 16,
        salesTarget: 200000.0,
        topProducts: const [
          {'name': 'Product A', 'value': 120000.0},
          {'name': 'Service C', 'value': 100000.0},
        ],
        leadsOverview: const {
          'New': 8,
          'Contacted': 6,
          'Converted': 16,
          'Lost': 0,
        },
        projects: const [],
      ),
      AdminReportEmployee(
        id: '9',
        employeeId: 'EMP009',
        name: 'Karan Malhotra',
        designation: 'UI/UX Designer',
        status: 'Active',
        avatarUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=150&auto=format&fit=crop&q=80',
        email: 'karan.malhotra@company.com',
        presentDays: 23,
        totalWorkingDays: 26,
        totalLeaves: 2,
        totalSales: 0.0,
        totalLeads: 0,
        tasksCompleted: 15,
        totalTasks: 18,
        performance: 'Good',
        recentActivities: const [
          AdminActivity(title: 'Dashboard wireframes submitted', time: '16 May 2024'),
          AdminActivity(title: 'New icon pack designs finalized', time: '14 May 2024'),
        ],
        attendanceCalendar: getCalendarFor('Dev'),
        basicSalary: 38000.0,
        hra: 9000.0,
        conveyance: 2000.0,
        performanceBonus: 4000.0,
        tds: 2500.0,
        pf: 2400.0,
        esi: 500.0,
        otherDeductions: 0.0,
        casualLeaveUsed: 6,
        casualLeaveTotal: 10,
        sickLeaveUsed: 2,
        sickLeaveTotal: 8,
        earnedLeaveUsed: 5,
        earnedLeaveTotal: 15,
        leaveHistory: const [
          AdminLeaveRequest(date: '08 May 2024', type: 'Casual Leave', duration: '2 Days', status: 'Approved'),
        ],
        leadsCount: 0,
        convertedLeadsCount: 0,
        salesTarget: 0.0,
        topProducts: const [],
        leadsOverview: const {},
        projects: const [
          AdminProjectReport(
            name: 'CRM Development',
            progress: 68,
            status: 'In Progress',
            totalTasks: 4,
            completedTasks: 3,
            tasksBreakdown: [
              AdminProjectTask(title: 'UI/UX Design', assignedTo: 'Karan Malhotra', status: 'Completed', dueDate: '10 May 2024', progress: 100),
            ],
          ),
        ],
      ),
      AdminReportEmployee(
        id: '10',
        employeeId: 'EMP010',
        name: 'Anjali Desai',
        designation: 'QA Engineer',
        status: 'On Leave',
        avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&auto=format&fit=crop&q=80',
        email: 'anjali.desai@company.com',
        presentDays: 15,
        totalWorkingDays: 26,
        totalLeaves: 8,
        totalSales: 0.0,
        totalLeads: 0,
        tasksCompleted: 25,
        totalTasks: 30,
        performance: 'Good',
        recentActivities: const [
          AdminActivity(title: 'Regression test reports CRM compiled', time: '13 May 2024'),
          AdminActivity(title: 'Identified 5 critical API sync errors', time: '12 May 2024'),
        ],
        attendanceCalendar: getCalendarFor('Dev'),
        basicSalary: 34000.0,
        hra: 8000.0,
        conveyance: 2000.0,
        performanceBonus: 3000.0,
        tds: 2000.0,
        pf: 2100.0,
        esi: 500.0,
        otherDeductions: 4000.0, // unpaid leave deduction
        casualLeaveUsed: 9,
        casualLeaveTotal: 10,
        sickLeaveUsed: 6,
        sickLeaveTotal: 8,
        earnedLeaveUsed: 12,
        earnedLeaveTotal: 15,
        leaveHistory: const [
          AdminLeaveRequest(date: '15 May 2024', type: 'Casual Leave', duration: '8 Days', status: 'Approved'),
        ],
        leadsCount: 0,
        convertedLeadsCount: 0,
        salesTarget: 0.0,
        topProducts: const [],
        leadsOverview: const {},
        projects: const [
          AdminProjectReport(
            name: 'CRM Development',
            progress: 68,
            status: 'In Progress',
            totalTasks: 6,
            completedTasks: 4,
            tasksBreakdown: [
              AdminProjectTask(title: 'Testing and Bug Verifications', assignedTo: 'Anjali Desai', status: 'In Progress', dueDate: '28 May 2024', progress: 60),
            ],
          ),
        ],
      ),
    ]);
  }
}
