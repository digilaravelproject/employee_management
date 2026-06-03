import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginHistoryEntry {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final String ipAddress;
  final String status; // 'Success', 'Failed'
  final String time;
  final String device;
  final String location;
  final String dateTag; // 'Today', 'Yesterday', 'This Week'

  const LoginHistoryEntry({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.ipAddress,
    required this.status,
    required this.time,
    required this.device,
    required this.location,
    required this.dateTag,
  });
}

class ActivityLogEntry {
  final String id;
  final String name;
  final String avatarUrl;
  final String action;
  final String time;
  final String dateHeader; // 'Today - 24 May 2024', 'Yesterday - 23 May 2024'
  final String category; // 'User Activities', 'Data Changes', 'Actions'

  const ActivityLogEntry({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.action,
    required this.time,
    required this.dateHeader,
    required this.category,
  });
}

class BackupEntry {
  final String id;
  final String date;
  final String size;
  final String status; // 'Success', 'Failed'

  const BackupEntry({
    required this.id,
    required this.date,
    required this.size,
    required this.status,
  });
}

class AlertEntry {
  final String id;
  final String title;
  final String time;
  final String ipOrUser;
  final bool isHighRisk;

  const AlertEntry({
    required this.id,
    required this.title,
    required this.time,
    required this.ipOrUser,
    required this.isHighRisk,
  });
}

class ActiveSession {
  final String id;
  final String name;
  final String avatarUrl;
  final String device;
  final String location;
  final String status; // 'Active Now', '5 min ago', '15 min ago'

  const ActiveSession({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.device,
    required this.location,
    required this.status,
  });
}

class SecurityController extends GetxController {
  // Observables for Stats
  final totalLogins = 128.obs;
  final activeUsers = 86.obs;
  final failedLogins = 8.obs;
  final suspiciousActivities = 2.obs;

  // Active state lists
  final loginHistory = <LoginHistoryEntry>[].obs;
  final filteredLoginHistory = <LoginHistoryEntry>[].obs;
  final loginSearchQuery = ''.obs;
  final selectedLoginTab = 'Today'.obs; // 'Today', 'Yesterday', 'This Week', 'Custom'

  final activityLogs = <ActivityLogEntry>[].obs;
  final filteredActivityLogs = <ActivityLogEntry>[].obs;
  final activitySearchQuery = ''.obs;
  final selectedActivityTab = 'All'.obs; // 'All', 'User Activities', 'Data Changes', 'Actions'

  final backupHistory = <BackupEntry>[].obs;
  final recentAlerts = <AlertEntry>[].obs;
  final activeSessions = <ActiveSession>[].obs;

  // Loading indicator for backup trigger
  final isBackupCreating = false.obs;
  final isRestoring = false.obs;

  @override
  void onInit() {
    super.onInit();
    _seedMockData();
    filteredLoginHistory.assignAll(loginHistory);
    filteredActivityLogs.assignAll(activityLogs);
  }

  // ── FILTER ACTIONS ──
  void filterLoginHistoryList(String query) {
    loginSearchQuery.value = query;
    _applyLoginFilters();
  }

  void changeLoginTab(String tab) {
    selectedLoginTab.value = tab;
    _applyLoginFilters();
  }

  void _applyLoginFilters() {
    List<LoginHistoryEntry> temp = List.from(loginHistory);

    // Filter by Tab (DateTag)
    if (selectedLoginTab.value != 'Custom') {
      temp = temp.where((l) {
        if (selectedLoginTab.value == 'Today') return l.dateTag == 'Today';
        if (selectedLoginTab.value == 'Yesterday') return l.dateTag == 'Yesterday';
        // 'This Week' encompasses both Today & Yesterday & This Week
        return true;
      }).toList();
    }

    // Filter by Search Query
    if (loginSearchQuery.value.isNotEmpty) {
      final q = loginSearchQuery.value.toLowerCase();
      temp = temp.where((l) =>
        l.name.toLowerCase().contains(q) ||
        l.email.toLowerCase().contains(q) ||
        l.ipAddress.toLowerCase().contains(q) ||
        l.device.toLowerCase().contains(q) ||
        l.location.toLowerCase().contains(q)
      ).toList();
    }

    filteredLoginHistory.assignAll(temp);
  }

  void filterActivityLogsList(String query) {
    activitySearchQuery.value = query;
    _applyActivityFilters();
  }

  void changeActivityCategoryTab(String tab) {
    selectedActivityTab.value = tab;
    _applyActivityFilters();
  }

  void _applyActivityFilters() {
    List<ActivityLogEntry> temp = List.from(activityLogs);

    // Filter by Category
    if (selectedActivityTab.value != 'All') {
      temp = temp.where((log) => log.category.toLowerCase() == selectedActivityTab.value.toLowerCase()).toList();
    }

    // Filter by Search query
    if (activitySearchQuery.value.isNotEmpty) {
      final q = activitySearchQuery.value.toLowerCase();
      temp = temp.where((log) =>
        log.name.toLowerCase().contains(q) ||
        log.action.toLowerCase().contains(q)
      ).toList();
    }

    filteredActivityLogs.assignAll(temp);
  }

  // ── BACKUP & RESTORE TRIGGERS ──
  Future<void> createBackup() async {
    isBackupCreating.value = true;
    
    // Mock network lag
    await Future.delayed(const Duration(seconds: 2));

    final newBackup = BackupEntry(
      id: 'B00${backupHistory.length + 1}',
      date: '${DateTime.now().day} May 2024, 12:59 PM',
      size: '266.8 MB',
      status: 'Success',
    );

    backupHistory.insert(0, newBackup);
    isBackupCreating.value = false;

    Get.snackbar(
      'Backup Created successfully 🛡️',
      'Database snapshot B00${backupHistory.length} compressed and stored.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      borderRadius: 16,
    );
  }

  Future<void> restoreSelectedBackup(BackupEntry backup) async {
    isRestoring.value = true;

    // Mock network lag
    await Future.delayed(const Duration(milliseconds: 2500));
    isRestoring.value = false;

    // Return back from Restore Data page to Backup dashboard
    Get.back();

    Get.snackbar(
      'System Restored Successfully 🎉',
      'Database loaded state from backup ${backup.date}.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      borderRadius: 16,
    );
  }

  // ── MOCK DATA SEEDER ──
  void _seedMockData() {
    loginHistory.assignAll([
      const LoginHistoryEntry(
        id: '1',
        name: 'Rahul Sharma',
        email: 'rahul@example.com',
        avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        ipAddress: '192.168.1.45',
        status: 'Success',
        time: '09:30 AM',
        device: 'Android • Chrome',
        location: 'New Delhi, India',
        dateTag: 'Today',
      ),
      const LoginHistoryEntry(
        id: '2',
        name: 'Neha Kapoor',
        email: 'neha@example.com',
        avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
        ipAddress: '192.168.1.12',
        status: 'Success',
        time: '09:12 AM',
        device: 'iPhone • Safari',
        location: 'Mumbai, India',
        dateTag: 'Today',
      ),
      const LoginHistoryEntry(
        id: '3',
        name: 'Amit Singh',
        email: 'amit@example.com',
        avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
        ipAddress: '192.168.1.33',
        status: 'Failed',
        time: '09:05 AM',
        device: 'Windows • Chrome',
        location: 'Bangalore, India',
        dateTag: 'Today',
      ),
      const LoginHistoryEntry(
        id: '4',
        name: 'Pooja Mehta',
        email: 'pooja@example.com',
        avatarUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150',
        ipAddress: '192.168.1.21',
        status: 'Success',
        time: '08:50 AM',
        device: 'Android • Chrome',
        location: 'Hyderabad, India',
        dateTag: 'Today',
      ),
      const LoginHistoryEntry(
        id: '5',
        name: 'Vikas Yadav',
        email: 'vikas@example.com',
        avatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
        ipAddress: '192.168.1.78',
        status: 'Success',
        time: '08:30 AM',
        device: 'Mac • Safari',
        location: 'Pune, India',
        dateTag: 'Today',
      ),
      const LoginHistoryEntry(
        id: '6',
        name: 'Rahul Sharma',
        email: 'rahul@example.com',
        avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        ipAddress: '192.168.1.45',
        status: 'Success',
        time: '05:30 PM',
        device: 'Android • Chrome',
        location: 'New Delhi, India',
        dateTag: 'Yesterday',
      ),
    ]);

    activityLogs.assignAll([
      const ActivityLogEntry(
        id: 'act1',
        name: 'Rahul Sharma',
        avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        action: 'Created Project "CRM Redesign"',
        time: '09:45 AM',
        dateHeader: 'Today - 24 May 2024',
        category: 'Data Changes',
      ),
      const ActivityLogEntry(
        id: 'act2',
        name: 'Neha Kapoor',
        avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
        action: 'Updated Lead "ABC Pvt Ltd"',
        time: '09:30 AM',
        dateHeader: 'Today - 24 May 2024',
        category: 'Data Changes',
      ),
      const ActivityLogEntry(
        id: 'act3',
        name: 'Amit Singh',
        avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
        action: 'Deleted Task "Follow up Call"',
        time: '09:15 AM',
        dateHeader: 'Today - 24 May 2024',
        category: 'Actions',
      ),
      const ActivityLogEntry(
        id: 'act4',
        name: 'Pooja Mehta',
        avatarUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150',
        action: 'Generated Payslip for May 2024',
        time: '09:00 AM',
        dateHeader: 'Today - 24 May 2024',
        category: 'Actions',
      ),
      const ActivityLogEntry(
        id: 'act5',
        name: 'Vikas Yadav',
        avatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
        action: 'Exported Attendance Report',
        time: '08:50 AM',
        dateHeader: 'Today - 24 May 2024',
        category: 'User Activities',
      ),
      const ActivityLogEntry(
        id: 'act6',
        name: 'Rahul Sharma',
        avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        action: 'Logged In to the system',
        time: '05:30 PM',
        dateHeader: 'Yesterday - 23 May 2024',
        category: 'User Activities',
      ),
      const ActivityLogEntry(
        id: 'act7',
        name: 'Neha Kapoor',
        avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
        action: 'Created Lead "XYZ Solutions"',
        time: '05:15 PM',
        dateHeader: 'Yesterday - 23 May 2024',
        category: 'Data Changes',
      ),
      const ActivityLogEntry(
        id: 'act8',
        name: 'Amit Singh',
        avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
        action: 'Updated Employee "Rohit Verma"',
        time: '05:00 PM',
        dateHeader: 'Yesterday - 23 May 2024',
        category: 'Data Changes',
      ),
    ]);

    backupHistory.assignAll([
      const BackupEntry(id: '1', date: '24 May 2024, 02:30 AM', size: '256.8 MB', status: 'Success'),
      const BackupEntry(id: '2', date: '23 May 2024, 02:30 AM', size: '248.3 MB', status: 'Success'),
      const BackupEntry(id: '3', date: '22 May 2024, 02:30 AM', size: '240.1 MB', status: 'Success'),
      const BackupEntry(id: '4', date: '21 May 2024, 02:30 AM', size: '240.7 MB', status: 'Success'),
    ]);

    recentAlerts.assignAll([
      const AlertEntry(
        id: 'al1',
        title: 'Unusual login detected',
        time: '2 min ago',
        ipOrUser: 'IP: 192.168.1.45',
        isHighRisk: false,
      ),
      const AlertEntry(
        id: 'al2',
        title: 'Multiple failed login attempts',
        time: '15 min ago',
        ipOrUser: 'User: Amit Singh',
        isHighRisk: true,
      ),
      const AlertEntry(
        id: 'al3',
        title: 'Login from unknown device',
        time: '45 min ago',
        ipOrUser: 'User: Neha Kapoor',
        isHighRisk: false,
      ),
    ]);

    activeSessions.assignAll([
      const ActiveSession(
        id: 'sess1',
        name: 'Rahul Sharma',
        avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        device: 'Android • Chrome',
        location: 'New Delhi, India',
        status: 'Active Now',
      ),
      const ActiveSession(
        id: 'sess2',
        name: 'Neha Kapoor',
        avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
        device: 'iPhone • Safari',
        location: 'Mumbai, India',
        status: '5 min ago',
      ),
      const ActiveSession(
        id: 'sess3',
        name: 'Amit Singh',
        avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
        device: 'Windows • Chrome',
        location: 'Bangalore, India',
        status: '15 min ago',
      ),
    ]);
  }
}
