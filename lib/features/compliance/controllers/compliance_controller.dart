import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/compliance_models.dart';

class ComplianceController extends GetxController {
  // --- Toggles & Filters ---
  final isAdminMode = true.obs;
  
  final selectedTrackingFilter = 'All'.obs;
  final trackingSearchQuery = ''.obs;

  final selectedAuditFilter = 'All'.obs;

  final selectedEmployeeFilter = 'All'.obs; // All, To Acknowledge, Acknowledged

  // --- Dynamic Stats / Flags ---
  final isPublishing = false.obs;
  final isAcknowledging = false.obs;

  // --- Mock Database Arrays ---
  final adminPolicies = <PolicyItem>[].obs;
  final employeePolicies = <PolicyItem>[].obs;
  final acknowledgements = <EmployeeAcknowledgement>[].obs;
  final auditLogs = <ComplianceAuditLog>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadMockData();
  }

  // --- Fetch Stats ---
  int get totalPolicies => adminPolicies.length;
  int get publishedCount => adminPolicies.where((p) => p.status == 'Published').length;
  int get pendingCount => adminPolicies.where((p) => p.status == 'Pending').length;
  int get overdueCount => adminPolicies.where((p) => p.status == 'Overdue').length;

  double get employeeComplianceScore {
    if (employeePolicies.isEmpty) return 0.0;
    int acked = employeePolicies.where((p) => p.isAcknowledged).length;
    return (acked / employeePolicies.length) * 100.0;
  }

  int get employeeTotalPolicies => employeePolicies.length;
  int get employeeAcknowledgedCount => employeePolicies.where((p) => p.isAcknowledged).length;
  int get employeePendingCount => employeePolicies.where((p) => !p.isAcknowledged && p.status != 'Overdue').length;
  int get employeeOverdueCount => employeePolicies.where((p) => !p.isAcknowledged && p.status == 'Overdue').length;

  // --- Filtered Lists ---
  List<EmployeeAcknowledgement> get filteredAcknowledgements {
    final query = trackingSearchQuery.value.trim().toLowerCase();
    final filter = selectedTrackingFilter.value;

    return acknowledgements.where((ack) {
      final matchesSearch = ack.employeeName.toLowerCase().contains(query) ||
          ack.designation.toLowerCase().contains(query);
      
      if (!matchesSearch) return false;
      if (filter == 'All') return true;
      return ack.status == filter;
    }).toList();
  }

  List<ComplianceAuditLog> get filteredAuditLogs {
    final filter = selectedAuditFilter.value;
    if (filter == 'All') return auditLogs;
    return auditLogs.where((log) => log.activity == filter).toList();
  }

  List<PolicyItem> get filteredEmployeePolicies {
    final filter = selectedEmployeeFilter.value;
    if (filter == 'All') return employeePolicies;
    if (filter == 'To Acknowledge') {
      return employeePolicies.where((p) => !p.isAcknowledged).toList();
    }
    // Acknowledged
    return employeePolicies.where((p) => p.isAcknowledged).toList();
  }

  // --- Actions ---

  // Upload/Publish New Policy
  Future<bool> publishPolicy({
    required String title,
    required String category,
    required String version,
    required DateTime reviewDate,
    required String summary,
    required String description,
  }) async {
    isPublishing.value = true;
    
    // Simulate compilation network delay
    await Future.delayed(const Duration(milliseconds: 1500));

    final newId = 'pol_${DateTime.now().millisecondsSinceEpoch}';
    final newPolicy = PolicyItem(
      id: newId,
      title: title,
      category: category,
      version: version,
      updatedDate: DateTime.now(),
      reviewDate: reviewDate,
      summary: summary,
      description: description,
      status: 'Published',
      isAcknowledged: false,
    );

    // Add to Admin general list
    adminPolicies.insert(0, newPolicy);

    // Also auto-assign to employee as "Pending" (for state demonstration)
    employeePolicies.insert(0, newPolicy.copyWith(isAcknowledged: false));

    // Append to Audit Logs
    auditLogs.insert(
      0,
      ComplianceAuditLog(
        id: 'log_${DateTime.now().millisecondsSinceEpoch}',
        dateTime: DateTime.now(),
        activity: 'Policy Created',
        policyTitle: title,
        performedBy: 'Admin',
        details: 'New policy "$title" (v$version) created and published.',
      ),
    );

    // Append to tracking
    acknowledgements.insert(
      0,
      EmployeeAcknowledgement(
        employeeName: 'Pooja Mehta',
        designation: 'HR Executive',
        avatarUrl: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150',
        status: 'Pending',
      ),
    );

    isPublishing.value = false;
    return true;
  }

  // Acknowledge Policy (Employee side)
  Future<bool> acknowledgePolicy(String policyId) async {
    isAcknowledging.value = true;

    // Simulate acknowledgement processing delay
    await Future.delayed(const Duration(milliseconds: 1200));

    final index = employeePolicies.indexWhere((p) => p.id == policyId);
    if (index != -1) {
      final p = employeePolicies[index];
      
      // Update employee status
      employeePolicies[index] = p.copyWith(
        isAcknowledged: true,
        acknowledgedDate: DateTime.now(),
      );

      // Add to admin audit logs
      auditLogs.insert(
        0,
        ComplianceAuditLog(
          id: 'log_${DateTime.now().millisecondsSinceEpoch}',
          dateTime: DateTime.now(),
          activity: 'Acknowledgement',
          policyTitle: p.title,
          performedBy: 'Rahul Sharma', // Simulated employee user
          details: 'Employee Rahul Sharma acknowledged policy "${p.title}" (v${p.version}).',
        ),
      );

      // Update Rahul Sharma's status in the general Admin tracking lists
      final trackIndex = acknowledgements.indexWhere((ack) => ack.employeeName == 'Rahul Sharma');
      if (trackIndex != -1) {
        acknowledgements[trackIndex] = EmployeeAcknowledgement(
          employeeName: 'Rahul Sharma',
          designation: 'Developer',
          avatarUrl: acknowledgements[trackIndex].avatarUrl,
          status: 'Acknowledged',
          acknowledgedTime: 'Just Now',
        );
      }
    }

    isAcknowledging.value = false;
    return true;
  }

  // Notify/Send Reminder to Employee
  void triggerReminder(EmployeeAcknowledgement ack, String policyTitle) {
    Get.snackbar(
      'Reminder Dispatched 🔔',
      'Compliance notification sent to ${ack.employeeName} for policy "$policyTitle".',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF6366F1),
      colorText: Colors.white,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      borderRadius: 16,
    );

    // Append to audit logs
    auditLogs.insert(
      0,
      ComplianceAuditLog(
        id: 'log_${DateTime.now().millisecondsSinceEpoch}',
        dateTime: DateTime.now(),
        activity: 'Reminder Sent',
        policyTitle: policyTitle,
        performedBy: 'Admin',
        details: 'System compliance reminder sent to ${ack.employeeName} (${ack.designation}).',
      ),
    );
  }

  // --- Load Mock Data ---
  void _loadMockData() {
    // Standard mock policies
    final basePolicies = [
      PolicyItem(
        id: '1',
        title: 'Code of Conduct Policy',
        category: 'HR Policies',
        version: '2.1',
        updatedDate: DateTime(2024, 5, 20),
        reviewDate: DateTime(2025, 5, 20),
        status: 'Published',
        summary: 'Outlines standard ethical conducts, workplace expectations, and corporate responsibilities.',
        description: '1. Purpose\nThis policy defines standard workplace behavior for all personnel. We are committed to fostering a professional, respectful, and safe environment.\n\n2. Ethical Core Values\n- Integrity: Always act honestly and transparently.\n- Respect: Treat colleagues, clients, and partners with dignity.\n- Inclusion: Celebrate diverse perspectives and avoid discrimination.\n\n3. General Rules\nAll employees must avoid conflicts of interest, protect proprietary data, and respect intellectual property.\n\n4. Reporting Issues\nReport harassment or compliance issues immediately to hr@company.com.',
        isAcknowledged: true,
        acknowledgedDate: DateTime(2024, 5, 20, 10, 30),
      ),
      PolicyItem(
        id: '2',
        title: 'Leave Policy',
        category: 'Leave Policies',
        version: '1.3',
        updatedDate: DateTime(2024, 5, 15),
        reviewDate: DateTime(2025, 5, 15),
        status: 'Published',
        summary: 'Details casual, sick, earned, and parental leave entitlements and approval processes.',
        description: '1. Purpose\nThis policy defines the leave types, eligibility, and process applicable to all full-time employees.\n\n2. Types of Leave\n- Casual Leave: For unexpected personal work. 12 days per year.\n- Sick Leave: For medical rest. 10 days per year.\n- Privilege/Earned Leave: Accrued monthly. 15 days per year.\n- Maternity/Paternity Leave: Standard paid leaves for new parents.\n- Unpaid Leave: Requires special executive approval.\n\n3. General Guidelines\n- Leave must be applied for in advance via the HR portal.\n- Sudden sick leaves must be reported within 24 hours.\n\n4. Approval\nLeave is subject to manager approval based on project workloads.',
        isAcknowledged: false,
      ),
      PolicyItem(
        id: '3',
        title: 'Data Security Policy',
        category: 'IT & Security',
        version: '1.0',
        updatedDate: DateTime(2024, 5, 10),
        reviewDate: DateTime(2025, 5, 10),
        status: 'Published',
        summary: 'Outlines specifications for data privacy, encryption keys, and password guidelines.',
        description: '1. Purpose\nProtects corporate client data and intellectual property from leakage or hacking threat.\n\n2. Device Security\n- Work laptops must use full disk encryption.\n- Passwords must contain numbers, specials, and capitalizations.\n- Screens must be locked immediately when leaving desks.\n\n3. Network Use\nAlways connect to corporate VPN when accessing servers remotely.\n\n4. Auditing\nIT team will perform regular vulnerability analysis scans.',
        isAcknowledged: true,
        acknowledgedDate: DateTime(2024, 5, 10, 14, 15),
      ),
      PolicyItem(
        id: '4',
        title: 'IT Usage Policy',
        category: 'IT & Security',
        version: '1.1',
        updatedDate: DateTime(2024, 5, 5),
        reviewDate: DateTime(2025, 5, 5),
        status: 'Published',
        summary: 'Defines acceptable use protocols for systems, hardware, networks, and communication tools.',
        description: '1. Purpose\nEnsures corporate IT infrastructure is utilized ethically and productively.\n\n2. Acceptable Use\n- Hardware is strictly for corporate tasks.\n- Do not install unauthorized external applications.\n- Use designated tools like Slack/Teams for communications.\n\n3. Prohibited Uses\n- Accessing restricted or illegal websites.\n- Cryptomining on company servers.\n\n4. Revocation\nNon-compliance may trigger immediate access suspensions.',
        isAcknowledged: false,
      ),
      PolicyItem(
        id: '5',
        title: 'POSH Policy',
        category: 'HR Policies',
        version: '1.0',
        updatedDate: DateTime(2024, 5, 1),
        reviewDate: DateTime(2025, 5, 1),
        status: 'Published',
        summary: 'Prevention of Sexual Harassment guidelines, reporting structures, and internal grievance channels.',
        description: '1. Purpose\nEnsures a safe, secure, and professional working environment free of harassment.\n\n2. Definitions\nDefines explicit or implicit harassment, verbal remarks, and gestures as violations.\n\n3. Reporting Mechanisms\nAny aggrieved employee can register a formal complaint with the Internal Complaints Committee (ICC).\n\n4. Strict Confidentiality\nAll inquiries remain 100% confidential. Strict disciplinary action will be taken against violators.',
        isAcknowledged: true,
        acknowledgedDate: DateTime(2024, 5, 1, 9, 20),
      ),
      PolicyItem(
        id: '6',
        title: 'Remote Work Policy',
        category: 'Work Policies',
        version: '1.0',
        updatedDate: DateTime(2024, 4, 25),
        reviewDate: DateTime(2025, 4, 25),
        status: 'Published',
        summary: 'Stipulates productivity standards, remote setups, core hours, and communication rules.',
        description: '1. Purpose\nEstablishes parameters for working from locations outside standard office headquarters.\n\n2. Work Hours\nRemote employees must remain active during standard core business hours.\n\n3. Workspace setup\nMust have a quiet background environment and high-speed internet link.\n\n4. Meetings\nVideo cameras should remain active in all group sync meetings.',
        isAcknowledged: true,
        acknowledgedDate: DateTime(2024, 4, 25, 11, 40),
      ),
    ];

    // Admin general catalog
    adminPolicies.addAll(basePolicies);

    // Employee personal assignments
    // Simulating that the current logged in employee (e.g. Rahul) has 12 assigned policies,
    // 10 are acknowledged, 2 are pending (Leave Policy & IT Usage Policy).
    // Let's seed 12 policies for the employee to match the donut mockup numbers perfectly (12 total, 10 ack, 2 pending).
    employeePolicies.addAll(basePolicies);
    // Add 6 more acknowledged policies to reach exactly 12 total, 10 acknowledged, 2 pending
    for (int i = 1; i <= 6; i++) {
      employeePolicies.add(
        PolicyItem(
          id: 'emp_pol_${i + 10}',
          title: _getExtraPolicyTitle(i),
          category: 'Work Policies',
          version: '1.0',
          updatedDate: DateTime(2024, 3, 10 + i),
          reviewDate: DateTime(2025, 3, 10 + i),
          status: 'Published',
          summary: 'Corporate policy guidelines regarding general work guidelines and operations.',
          description: 'This is the policy document statement applicable to corporate operations.',
          isAcknowledged: true,
          acknowledgedDate: DateTime(2024, 3, 15 + i),
        ),
      );
    }

    // Set admin policies to have 24 total to match the 24 policies count in mockup overview
    for (int i = 1; i <= 18; i++) {
      if (adminPolicies.length >= 24) break;
      adminPolicies.add(
        PolicyItem(
          id: 'admin_pol_${i + 20}',
          title: 'Internal Policy Standard #$i',
          category: i % 2 == 0 ? 'HR Policies' : 'Work Policies',
          version: '1.0',
          updatedDate: DateTime(2024, 4, i),
          reviewDate: DateTime(2025, 4, i),
          status: i == 1 ? 'Overdue' : i <= 5 ? 'Pending' : 'Published',
          summary: 'Internal administrative standards.',
          description: 'Detailed internal guidelines.',
        ),
      );
    }

    // Prepopulate employee tracking list
    acknowledgements.addAll([
      EmployeeAcknowledgement(
        employeeName: 'Rahul Sharma',
        designation: 'Developer',
        avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        status: 'Acknowledged',
        acknowledgedTime: '20 May 2024, 10:30 AM',
      ),
      EmployeeAcknowledgement(
        employeeName: 'Neha Kapoor',
        designation: 'Designer',
        avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
        status: 'Acknowledged',
        acknowledgedTime: '20 May 2024, 10:28 AM',
      ),
      EmployeeAcknowledgement(
        employeeName: 'Amit Singh',
        designation: 'Team Lead',
        avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
        status: 'Acknowledged',
        acknowledgedTime: '20 May 2024, 10:21 AM',
      ),
      EmployeeAcknowledgement(
        employeeName: 'Pooja Mehta',
        designation: 'HR Executive',
        avatarUrl: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150',
        status: 'Pending',
      ),
      EmployeeAcknowledgement(
        employeeName: 'Vikas Yadav',
        designation: 'Sales Executive',
        avatarUrl: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=150',
        status: 'Pending',
      ),
      EmployeeAcknowledgement(
        employeeName: 'Sneha Patel',
        designation: 'Accountant',
        avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
        status: 'Pending',
      ),
      EmployeeAcknowledgement(
        employeeName: 'Rohan Sharma',
        designation: 'Operations Analyst',
        avatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
        status: 'Overdue',
      ),
    ]);

    // Prepopulate Audit Logs matching the mockup
    auditLogs.addAll([
      ComplianceAuditLog(
        id: '1',
        dateTime: DateTime(2024, 5, 20, 10, 30),
        activity: 'Policy Published',
        policyTitle: 'Code of Conduct Policy',
        performedBy: 'Admin',
        details: 'Policy published for all active company employees.',
      ),
      ComplianceAuditLog(
        id: '2',
        dateTime: DateTime(2024, 5, 20, 10, 28),
        activity: 'Acknowledgement',
        policyTitle: 'Code of Conduct Policy',
        performedBy: 'Rahul Sharma',
        details: 'Policy successfully read and acknowledged by employee.',
      ),
      ComplianceAuditLog(
        id: '3',
        dateTime: DateTime(2024, 5, 20, 10, 25),
        activity: 'Reminder Sent',
        policyTitle: 'Leave Policy',
        performedBy: 'System',
        details: 'Automatic system reminder sent to 24 employees with pending status.',
      ),
      ComplianceAuditLog(
        id: '4',
        dateTime: DateTime(2024, 5, 19, 16, 15),
        activity: 'Policy Updated',
        policyTitle: 'Data Security Policy',
        performedBy: 'Admin',
        details: 'Policy updated to v1.1 and republished for re-acknowledgement.',
      ),
      ComplianceAuditLog(
        id: '5',
        dateTime: DateTime(2024, 5, 18, 11, 10),
        activity: 'Policy Created',
        policyTitle: 'IT Usage Policy',
        performedBy: 'Admin',
        details: 'New policy draft created and queued for review.',
      ),
    ]);
  }

  String _getExtraPolicyTitle(int index) {
    switch (index) {
      case 1:
        return 'Intellectual Property Policy';
      case 2:
        return 'Social Media Guidelines';
      case 3:
        return 'Travel Expense Policy';
      case 4:
        return 'Conflict of Interest Policy';
      case 5:
        return 'Anti-Bribery & Corruption';
      case 6:
        return 'Performance Review Policy';
      default:
        return 'Internal Corporate Standard #$index';
    }
  }
}
