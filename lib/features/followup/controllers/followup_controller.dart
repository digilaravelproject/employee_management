import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../clients/controllers/clients_controller.dart';
import '../../employee/management/controllers/employee_controller.dart';
import '../../leads/controllers/admin_leads_hub_controller.dart';
import '../../leads/controllers/leads_controller.dart';
import '../models/followup_model.dart';

class FollowupController extends GetxController {
  // Role switcher state
  var selectedRole = 'Employee'.obs; // 'Employee' or 'Admin'

  // Call Logs state
  var callLogs = <CallLog>[].obs;
  var selectedCallFilter = 'All'.obs; // All, Outgoing, Incoming, Missed
  var searchCallQuery = ''.obs;

  // Meetings state
  var meetings = <FollowupMeeting>[].obs;
  var selectedMeetingTab = 'Upcoming'.obs; // Upcoming, Completed
  var selectedMeetingDate = DateTime.now().obs;

  // Reminders state
  var reminders = <FollowupReminder>[].obs;
  var selectedReminderFilter = 'All'.obs; // All, Call, Meeting, Task, Follow-up

  // Notes state
  var notes = <ActivityNote>[].obs;
  var searchNotesQuery = ''.obs;

  // Admin Search & Filters
  var adminSelectedMonth = 'This Month'.obs;
  var adminSelectedEmployee = 'All Employees'.obs;
  var searchAdminCallQuery = ''.obs;

  // Predefined Dropdown Lists
  final List<String> months = ['This Month', 'Previous Month', 'Last 15 Days'];
  
  List<String> get employees {
    final list = <String>['All Employees'];
    if (Get.isRegistered<EmployeeController>()) {
      final empCtrl = Get.find<EmployeeController>();
      list.addAll(empCtrl.employees.map((e) => e.name).where((n) => n.isNotEmpty));
    }
    return list;
  }

  List<String> get clientNames {
    final set = <String>{};
    if (Get.isRegistered<ClientsController>()) {
      final clientCtrl = Get.find<ClientsController>();
      set.addAll(clientCtrl.clients.map((c) => c.name).where((n) => n.isNotEmpty));
    }
    if (Get.isRegistered<AdminLeadsHubController>()) {
      final leadsCtrl = Get.find<AdminLeadsHubController>();
      set.addAll(
        leadsCtrl.leadsList
            .map((l) => (l.fullName?.trim().isNotEmpty ?? false)
                ? l.fullName!.trim()
                : (l.companyName?.trim().isNotEmpty ?? false)
                    ? l.companyName!.trim()
                    : '')
            .where((n) => n.isNotEmpty),
      );
    } else if (Get.isRegistered<LeadsController>()) {
      final leadsCtrl = Get.find<LeadsController>();
      set.addAll(leadsCtrl.leads.map((l) => l.name).where((n) => n.isNotEmpty));
    }
    return set.toList();
  }

  @override
  void onInit() {
    super.onInit();
    _seedDummyData();
  }

  void _seedDummyData() {
    callLogs.clear();
    meetings.clear();
    reminders.clear();
    notes.clear();
  }

  // Getters - Filtered Call Logs
  List<CallLog> get filteredCallLogs {
    // Filter by type chip
    List<CallLog> list = callLogs;
    if (selectedCallFilter.value != 'All') {
      list = list.where((c) => c.type == selectedCallFilter.value).toList();
    }
    // Filter by search query
    if (searchCallQuery.value.isNotEmpty) {
      final q = searchCallQuery.value.toLowerCase();
      list = list.where((c) => c.clientName.toLowerCase().contains(q) || c.employeeName.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  // Getters - Filtered Meetings
  List<FollowupMeeting> get filteredMeetings {
    final now = DateTime.now();
    
    // Sort by tab (Upcoming/Completed)
    if (selectedMeetingTab.value == 'Upcoming') {
      return meetings.where((m) => m.dateTime.isAfter(now) || DateUtils.isSameDay(m.dateTime, now)).toList();
    } else {
      return meetings.where((m) => m.dateTime.isBefore(now) && !DateUtils.isSameDay(m.dateTime, now)).toList();
    }
  }

  // Getters - Filtered Reminders
  List<FollowupReminder> get filteredReminders {
    List<FollowupReminder> list = reminders;
    if (selectedReminderFilter.value != 'All') {
      list = list.where((r) => r.category == selectedReminderFilter.value).toList();
    }
    return list;
  }

  // Getters - Filtered Notes
  List<ActivityNote> get filteredNotes {
    List<ActivityNote> list = notes;
    if (searchNotesQuery.value.isNotEmpty) {
      final q = searchNotesQuery.value.toLowerCase();
      list = list.where((n) => n.clientName.toLowerCase().contains(q) || n.title.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  // Admin Dashboard - Filtered Call Logs
  List<CallLog> get adminFilteredCallLogs {
    List<CallLog> list = callLogs;
    
    // Filter by selected employee
    if (adminSelectedEmployee.value != 'All Employees') {
      list = list.where((c) => c.employeeName == adminSelectedEmployee.value).toList();
    }
    
    // Filter by search query
    if (searchAdminCallQuery.value.isNotEmpty) {
      final q = searchAdminCallQuery.value.toLowerCase();
      list = list.where((c) => c.clientName.toLowerCase().contains(q)).toList();
    }

    return list;
  }

  // Actions
  void changeRole(String role) {
    selectedRole.value = role;
  }

  void toggleReminder(String id) {
    final idx = reminders.indexWhere((r) => r.id == id);
    if (idx != -1) {
      final rem = reminders[idx];
      reminders[idx] = rem.copyWith(isCompleted: !rem.isCompleted);
      
      Get.snackbar(
        'Reminder Updated',
        'Reminder mark is changed successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  void addMeeting(FollowupMeeting meeting) {
    meetings.insert(0, meeting);
    
    // Insert a matching reminder automatically!
    reminders.insert(0, FollowupReminder(
      id: 'rem_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Meeting: ${meeting.title} with ${meeting.clientName}',
      category: 'Meeting',
      dateTime: meeting.dateTime,
      employeeName: meeting.employeeName,
    ));

    Get.snackbar(
      'Meeting Scheduled',
      'Meeting "${meeting.title}" added successfully!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  void addNote(ActivityNote note, {bool setReminderFlag = false}) {
    notes.insert(0, note);

    if (setReminderFlag) {
      reminders.insert(0, FollowupReminder(
        id: 'rem_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Followup task: ${note.clientName}',
        category: 'Follow-up',
        dateTime: note.dateTime.add(const Duration(days: 2)),
        employeeName: note.employeeName,
      ));
    }

    Get.snackbar(
      'Note Recorded',
      'Interaction activity saved to the timeline ledger.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }
}
