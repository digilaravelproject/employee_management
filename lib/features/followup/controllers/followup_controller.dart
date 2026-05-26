import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  final List<String> employees = [
    'All Employees',
    'Rahul Sharma',
    'Neha Kapoor',
    'Vikash Yadav',
    'Amit Singh'
  ];

  final List<String> clientNames = [
    'R K Enterprises',
    'Tech Solutions',
    'Bright Marketing',
    'Future Soft',
    'Digital India Pvt Ltd'
  ];

  @override
  void onInit() {
    super.onInit();
    _seedDummyData();
  }

  void _seedDummyData() {
    // 1. Seed Call Logs
    callLogs.assignAll([
      CallLog(
        id: 'call_1',
        clientName: 'R K Enterprises',
        type: 'Outgoing',
        employeeName: 'Rahul Sharma',
        timeStr: 'Today, 11:00 AM',
        durationStr: '09:23',
      ),
      CallLog(
        id: 'call_2',
        clientName: 'Tech Solutions',
        type: 'Incoming',
        employeeName: 'Neha Kapoor',
        timeStr: 'Today, 10:15 AM',
        durationStr: '07:45',
      ),
      CallLog(
        id: 'call_3',
        clientName: 'Bright Marketing',
        type: 'Outgoing',
        employeeName: 'Amit Singh',
        timeStr: 'Yesterday, 04:30 PM',
        durationStr: '03:12',
      ),
      CallLog(
        id: 'call_4',
        clientName: 'Future Soft',
        type: 'Missed',
        employeeName: 'Vikash Yadav',
        timeStr: 'Yesterday, 03:10 PM',
        durationStr: '00:00',
      ),
      CallLog(
        id: 'call_5',
        clientName: 'Digital India Pvt Ltd',
        type: 'Incoming',
        employeeName: 'Rahul Sharma',
        timeStr: 'Yesterday, 11:20 AM',
        durationStr: '06:18',
      ),
      CallLog(
        id: 'call_6',
        clientName: 'R K Enterprises',
        type: 'Incoming',
        employeeName: 'Neha Kapoor',
        timeStr: '22 May, 03:45 PM',
        durationStr: '12:05',
      ),
      CallLog(
        id: 'call_7',
        clientName: 'Future Soft',
        type: 'Outgoing',
        employeeName: 'Rahul Sharma',
        timeStr: '22 May, 11:00 AM',
        durationStr: '04:50',
      ),
    ]);

    // 2. Seed Meetings
    meetings.assignAll([
      FollowupMeeting(
        id: 'meet_1',
        title: 'Project Discussion',
        clientName: 'R K Enterprises',
        employeeName: 'Rahul Sharma',
        dateTime: DateTime.now().add(const Duration(hours: 2)),
        duration: '1 Hour',
        mode: 'Office',
        notes: 'Discuss project requirements, sprint timeline, and initial wireframes layout.',
      ),
      FollowupMeeting(
        id: 'meet_2',
        title: 'Requirement Discussion',
        clientName: 'Tech Solutions',
        employeeName: 'Neha Kapoor',
        dateTime: DateTime.now().add(const Duration(hours: 5)),
        duration: '45 Mins',
        mode: 'Online',
        notes: 'Review api documentation, database schema definitions, and secure access protocols.',
      ),
      FollowupMeeting(
        id: 'meet_3',
        title: 'Proposal Presentation',
        clientName: 'Bright Marketing',
        employeeName: 'Amit Singh',
        dateTime: DateTime.now().add(const Duration(days: 1)),
        duration: '1 Hour',
        mode: 'Office',
        notes: 'Present pricing quotation slides, service level agreement criteria, and onboarding stages.',
      ),
      FollowupMeeting(
        id: 'meet_4',
        title: 'Follow-up Meeting',
        clientName: 'Future Soft',
        employeeName: 'Vikash Yadav',
        dateTime: DateTime.now().subtract(const Duration(days: 1)),
        duration: '30 Mins',
        mode: 'Online',
        notes: 'Provide demo walkthrough of payroll feature updates and salary breakups customization.',
      ),
    ]);

    // 3. Seed Reminders
    reminders.assignAll([
      FollowupReminder(
        id: 'rem_1',
        title: 'Follow up with R K Enterprises',
        category: 'Call',
        dateTime: DateTime.now().add(const Duration(hours: 1)),
        employeeName: 'Rahul Sharma',
        isCompleted: false,
      ),
      FollowupReminder(
        id: 'rem_2',
        title: 'Meeting with Tech Solutions',
        category: 'Meeting',
        dateTime: DateTime.now().add(const Duration(hours: 4)),
        employeeName: 'Neha Kapoor',
        isCompleted: false,
      ),
      FollowupReminder(
        id: 'rem_3',
        title: 'Send Proposal to Bright Marketing',
        category: 'Task',
        dateTime: DateTime.now().add(const Duration(days: 1)),
        employeeName: 'Amit Singh',
        isCompleted: false,
      ),
      FollowupReminder(
        id: 'rem_4',
        title: 'Follow up with Future Soft',
        category: 'Call',
        dateTime: DateTime.now().add(const Duration(days: 2)),
        employeeName: 'Rahul Sharma',
        isCompleted: false,
      ),
      FollowupReminder(
        id: 'rem_5',
        title: 'Wellness webinar planning',
        category: 'Task',
        dateTime: DateTime.now().subtract(const Duration(days: 1)),
        employeeName: 'Vikash Yadav',
        isCompleted: true,
      ),
    ]);

    // 4. Seed Notes
    notes.assignAll([
      ActivityNote(
        id: 'note_1',
        clientName: 'R K Enterprises',
        title: 'Project Discussion',
        note: 'Had a detailed discussion about project scope, deadlines, and milestone deliverables.',
        dateTime: DateTime.now().subtract(const Duration(hours: 3)),
        employeeName: 'Rahul Sharma',
      ),
      ActivityNote(
        id: 'note_2',
        clientName: 'Tech Solutions',
        title: 'Requirement Notes',
        note: 'Client needs custom CRM integration with dynamic reports generation and ledger spreadsheets export.',
        dateTime: DateTime.now().subtract(const Duration(hours: 6)),
        employeeName: 'Neha Kapoor',
      ),
      ActivityNote(
        id: 'note_3',
        clientName: 'Bright Marketing',
        title: 'Proposal Notes',
        note: 'Shared proposal slides and pricing details. Awaiting budget approvals from their finance head.',
        dateTime: DateTime.now().subtract(const Duration(days: 1)),
        employeeName: 'Amit Singh',
      ),
      ActivityNote(
        id: 'note_4',
        clientName: 'Future Soft',
        title: 'Follow-up Notes',
        note: 'Demo presented. Waiting for feedback on the new shifts schedule screen design.',
        dateTime: DateTime.now().subtract(const Duration(days: 2)),
        employeeName: 'Rahul Sharma',
      ),
    ]);
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
