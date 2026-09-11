import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'dart:math';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../models/performance_model.dart';
import '../../chat/controllers/chat_controller.dart';
import '../../chat/views/chat_room_screen.dart';
import '../../chat/models/chat_models.dart';
import '../../attendance/views/attendance_history_screen.dart';
import '../../attendance/controllers/attendance_history_controller.dart';

class TeamMemberPerformanceScreen extends StatefulWidget {
  final EmployeePerformance emp;

  const TeamMemberPerformanceScreen({super.key, required this.emp});

  @override
  State<TeamMemberPerformanceScreen> createState() => _TeamMemberPerformanceScreenState();
}

class _TeamMemberPerformanceScreenState extends State<TeamMemberPerformanceScreen> {
  String _selectedMonth = 'May 2024';
  final List<String> _months = [
    'May 2024',
    'Apr 2024',
    'Mar 2024',
    'Feb 2024',
    'Jan 2024',
  ];

  // Map month name to DateTime
  DateTime _getDateTimeForMonth(String monthStr) {
    switch (monthStr) {
      case 'May 2024':
        return DateTime(2024, 5, 1);
      case 'Apr 2024':
        return DateTime(2024, 4, 1);
      case 'Mar 2024':
        return DateTime(2024, 3, 1);
      case 'Feb 2024':
        return DateTime(2024, 2, 1);
      case 'Jan 2024':
        return DateTime(2024, 1, 1);
      default:
        return DateTime(2024, 5, 1);
    }
  }

  // Monthly Data Generator
  Map<String, dynamic> _getMonthData(String month) {
    final baseScore = widget.emp.performanceScore;
    switch (month) {
      case 'May 2024':
        return {
          'score': baseScore,
          'ratingLabel': widget.emp.ratingLabel,
          'rank': widget.emp.rank,
          'attendanceProgress': max(0.4, min(1.0, baseScore / 100.0 + 0.1)),
          'attendanceLabel': '26 / 26 Days',
          'leaveProgress': baseScore < 75 ? 0.3 : 0.8,
          'leaveLabel': '${baseScore < 75 ? 3 : 1} / 2 Days',
          'taskCompletionProgress': baseScore / 100.0,
          'taskCompletionLabel': '${(baseScore / 100.0 * 20).round()} / 20 Tasks',
          'timelyProgress': max(0.3, baseScore / 100.0 - 0.05),
          'timelyLabel': '${(max(0.3, baseScore / 100.0 - 0.05) * 12).round()} / 12 Tasks',
          'qualityProgress': max(0.4, min(1.0, baseScore / 100.0 + 0.04)),
          'qualityLabel': '${(max(0.4, min(1.0, baseScore / 100.0 + 0.04)) * 5).toStringAsFixed(1)} / 5.0 Rating',
          'totalTasks': '20',
          'completedTasks': '${(baseScore / 100.0 * 18).round()}',
          'inProgressTasks': '2',
          'onTimeRate': '95%',
          'annualAllotted': '18 Days',
          'leavesTaken': baseScore < 75 ? '3 Days' : '1 Day',
          'balanceLeft': baseScore < 75 ? '15 Days' : '17 Days',
          'tasks': [
            {
              'title': 'Implement Push Notification & FCM Handling',
              'project': 'DigiEmployee Mobile App',
              'priority': 'High',
              'status': 'Completed',
              'assignedDate': '02 May 2024, 10:15 AM',
              'assignedBy': 'Rajesh Verma (VP Engineering)',
              'deadline': '08 May 2024, 06:00 PM',
              'completedDate': '07 May 2024, 04:30 PM',
              'timeliness': 'Delivered 1 day early (On Time)',
              'isEarly': true,
              'subtasks': '4 of 4 sub-tasks completed',
              'description': 'Setup background message handler, token refresh service, and local notification display for check-in reminders.',
            },
            {
              'title': 'Authentication Flow & Biometric PIN Lock',
              'project': 'DigiEmployee Mobile App',
              'priority': 'High',
              'status': 'Completed',
              'assignedDate': '08 May 2024, 11:00 AM',
              'assignedBy': 'Rajesh Verma (VP Engineering)',
              'deadline': '15 May 2024, 06:00 PM',
              'completedDate': '14 May 2024, 05:20 PM',
              'timeliness': 'Delivered 1 day early (On Time)',
              'isEarly': true,
              'subtasks': '5 of 5 sub-tasks completed',
              'description': 'Biometric fingerprint and Face ID authentication integration with SecureStorage and JWT automatic session renewal.',
            },
            {
              'title': 'Employee Attendance History & Calendar Grid',
              'project': 'DigiEmployee Mobile App',
              'priority': 'Medium',
              'status': 'Completed',
              'assignedDate': '15 May 2024, 09:30 AM',
              'assignedBy': 'Ananya Roy (Product Lead)',
              'deadline': '22 May 2024, 06:00 PM',
              'completedDate': '21 May 2024, 03:45 PM',
              'timeliness': 'Completed on schedule',
              'isEarly': true,
              'subtasks': '3 of 3 sub-tasks completed',
              'description': 'Built interactive monthly calendar with color-coded day markers, attendance overview, and day punch modal.',
            },
            {
              'title': 'Leave Request & Manager Approval Actions',
              'project': 'HRMS Core Module',
              'priority': 'Medium',
              'status': 'Completed',
              'assignedDate': '22 May 2024, 02:00 PM',
              'assignedBy': 'Neha Gupta (HR Lead)',
              'deadline': '28 May 2024, 06:00 PM',
              'completedDate': '27 May 2024, 06:10 PM',
              'timeliness': 'Delivered on-time',
              'isEarly': true,
              'subtasks': '4 of 4 sub-tasks completed',
              'description': 'Allowed employees to request casual/sick leaves, multi-level approvals, and automated balance calculation.',
            },
            {
              'title': 'Payroll Calculation & Payslip PDF Generator',
              'project': 'Payroll Suite v2',
              'priority': 'High',
              'status': 'In Progress',
              'assignedDate': '28 May 2024, 10:00 AM',
              'assignedBy': 'Rajesh Verma (VP Operations)',
              'deadline': '05 Jun 2024, 06:00 PM',
              'completedDate': 'Pending (85% Completed)',
              'timeliness': 'On Track (Est. 02 Jun)',
              'isEarly': false,
              'subtasks': '3 of 4 sub-tasks completed',
              'description': 'Salary slip generator, deduction breakdown (PF, ESI, TDS), and clean PDF downloadable format.',
            },
          ],
          'leaves': [
            {
              'type': 'Sick Leave',
              'dates': '14 May 2024 (1 Day)',
              'appliedDate': '13 May 2024, 08:30 PM',
              'approvedDate': '14 May 2024, 09:00 AM',
              'approvedBy': 'Rajesh Verma (VP Operations)',
              'reason': 'Severe seasonal viral fever & physician visit',
              'status': 'Approved',
            },
            {
              'type': 'Casual Leave',
              'dates': '03 May 2024 - 04 May 2024 (2 Days)',
              'appliedDate': '28 Apr 2024, 11:20 AM',
              'approvedDate': '29 Apr 2024, 02:15 PM',
              'approvedBy': 'Neha Gupta (HR Manager)',
              'reason': 'Family religious ceremony in hometown',
              'status': 'Approved',
            },
          ],
          'qualityFeedback': {
            'author': 'Rajesh Verma (VP Engineering)',
            'date': 'Reviewed on 28 May 2024',
            'comment': '"Consistently delivers clean, decoupled components on time. High quality test coverage and zero regression issues reported in production."',
            'accuracy': 0.98,
            'timeliness': 0.95,
            'qaPass': 0.96,
            'collaboration': 0.94,
          },
        };

      case 'Apr 2024':
        final aprScore = (baseScore * 0.94).round().clamp(58, 98);
        return {
          'score': aprScore,
          'ratingLabel': aprScore >= 80 ? 'Very Good' : 'Good',
          'rank': max(1, widget.emp.rank + 1),
          'attendanceProgress': 0.96,
          'attendanceLabel': '24 / 25 Days',
          'leaveProgress': 0.6,
          'leaveLabel': '2 / 2 Days',
          'taskCompletionProgress': 0.88,
          'taskCompletionLabel': '16 / 18 Tasks',
          'timelyProgress': 0.85,
          'timelyLabel': '10 / 12 Tasks',
          'qualityProgress': 0.92,
          'qualityLabel': '4.6 / 5.0 Rating',
          'totalTasks': '18',
          'completedTasks': '16',
          'inProgressTasks': '1',
          'onTimeRate': '92%',
          'annualAllotted': '18 Days',
          'leavesTaken': '2 Days',
          'balanceLeft': '16 Days',
          'tasks': [
            {
              'title': 'Geofence Check-in & GPS Coordinates Validation',
              'project': 'DigiEmployee Mobile App',
              'priority': 'High',
              'status': 'Completed',
              'assignedDate': '04 Apr 2024, 09:30 AM',
              'assignedBy': 'Rajesh Verma (VP Engineering)',
              'deadline': '10 Apr 2024, 06:00 PM',
              'completedDate': '09 Apr 2024, 05:15 PM',
              'timeliness': 'Delivered 1 day early (On Time)',
              'isEarly': true,
              'subtasks': '4 of 4 sub-tasks completed',
              'description': 'Configured geofencing radius polygon calculation and mock location detection for accurate punch-in verification.',
            },
            {
              'title': 'Shift Roster Management & Schedule View',
              'project': 'HRMS Core Module',
              'priority': 'Medium',
              'status': 'Completed',
              'assignedDate': '11 Apr 2024, 11:00 AM',
              'assignedBy': 'Ananya Roy (Product Lead)',
              'deadline': '18 Apr 2024, 06:00 PM',
              'completedDate': '17 Apr 2024, 04:45 PM',
              'timeliness': 'Completed on schedule',
              'isEarly': true,
              'subtasks': '3 of 3 sub-tasks completed',
              'description': 'Built day/night rotation schedules, department-level assignment, and shift change request flow.',
            },
            {
              'title': 'Dynamic Form Validation for Onboarding Stepper',
              'project': 'DigiEmployee Mobile App',
              'priority': 'Medium',
              'status': 'Completed',
              'assignedDate': '18 Apr 2024, 02:00 PM',
              'assignedBy': 'Neha Gupta (HR Lead)',
              'deadline': '24 Apr 2024, 06:00 PM',
              'completedDate': '23 Apr 2024, 06:30 PM',
              'timeliness': 'Delivered on-time',
              'isEarly': true,
              'subtasks': '5 of 5 sub-tasks completed',
              'description': 'Implemented regex-based validation for IFSC, Bank Account, Mobile, PAN, and Aadhaar numbers.',
            },
            {
              'title': 'Profile Image Compression & Caching Service',
              'project': 'DigiEmployee Mobile App',
              'priority': 'Low',
              'status': 'Completed',
              'assignedDate': '25 Apr 2024, 10:30 AM',
              'assignedBy': 'Rajesh Verma (VP Engineering)',
              'deadline': '30 Apr 2024, 06:00 PM',
              'completedDate': '29 Apr 2024, 03:20 PM',
              'timeliness': 'Delivered 1 day early',
              'isEarly': true,
              'subtasks': '2 of 2 sub-tasks completed',
              'description': 'Optimized avatar uploads using FlutterImageCompress and cached network images with placeholder avatars.',
            },
          ],
          'leaves': [
            {
              'type': 'Casual Leave',
              'dates': '12 Apr 2024 (1 Day)',
              'appliedDate': '09 Apr 2024, 10:00 AM',
              'approvedDate': '10 Apr 2024, 11:30 AM',
              'approvedBy': 'Neha Gupta (HR Manager)',
              'reason': 'Personal household documentation work',
              'status': 'Approved',
            },
            {
              'type': 'Sick Leave',
              'dates': '22 Apr 2024 (1 Day)',
              'appliedDate': '21 Apr 2024, 09:00 PM',
              'approvedDate': '22 Apr 2024, 08:30 AM',
              'approvedBy': 'Rajesh Verma (VP Operations)',
              'reason': 'Doctor appointment and health checkup',
              'status': 'Approved',
            },
          ],
          'qualityFeedback': {
            'author': 'Rajesh Verma (VP Engineering)',
            'date': 'Reviewed on 28 Apr 2024',
            'comment': '"Solid delivery of geofencing and roster modules. Great attention to edge cases and battery-efficient location tracking."',
            'accuracy': 0.94,
            'timeliness': 0.92,
            'qaPass': 0.93,
            'collaboration': 0.91,
          },
        };

      case 'Mar 2024':
        final marScore = (baseScore * 0.97).round().clamp(60, 99);
        return {
          'score': marScore,
          'ratingLabel': 'Very Good',
          'rank': widget.emp.rank,
          'attendanceProgress': 0.96,
          'attendanceLabel': '25 / 26 Days',
          'leaveProgress': 1.0,
          'leaveLabel': '0 / 2 Days',
          'taskCompletionProgress': 0.95,
          'taskCompletionLabel': '21 / 22 Tasks',
          'timelyProgress': 1.0,
          'timelyLabel': '12 / 12 Tasks',
          'qualityProgress': 0.98,
          'qualityLabel': '4.9 / 5.0 Rating',
          'totalTasks': '22',
          'completedTasks': '21',
          'inProgressTasks': '1',
          'onTimeRate': '98%',
          'annualAllotted': '18 Days',
          'leavesTaken': '0 Days',
          'balanceLeft': '18 Days',
          'tasks': [
            {
              'title': 'Export Attendance Data to Excel & PDF',
              'project': 'HRMS Reporting Suite',
              'priority': 'High',
              'status': 'Completed',
              'assignedDate': '03 Mar 2024, 10:00 AM',
              'assignedBy': 'Rajesh Verma (VP Operations)',
              'deadline': '10 Mar 2024, 06:00 PM',
              'completedDate': '08 Mar 2024, 04:00 PM',
              'timeliness': 'Delivered 2 days early (On Time)',
              'isEarly': true,
              'subtasks': '4 of 4 sub-tasks completed',
              'description': 'Integrated syncfusion excel writer and pdf generator with custom header formatting and date filtering.',
            },
            {
              'title': 'Role-based Access Control (Admin/Employee)',
              'project': 'Security Architecture',
              'priority': 'High',
              'status': 'Completed',
              'assignedDate': '10 Mar 2024, 11:30 AM',
              'assignedBy': 'Rajesh Verma (VP Engineering)',
              'deadline': '18 Mar 2024, 06:00 PM',
              'completedDate': '16 Mar 2024, 05:40 PM',
              'timeliness': 'Delivered 2 days early (On Time)',
              'isEarly': true,
              'subtasks': '5 of 5 sub-tasks completed',
              'description': 'Created granular permissions matrix guarding sensitive HR features, salary slips, and asset management.',
            },
            {
              'title': 'Department & Designation Management Screens',
              'project': 'DigiEmployee Mobile App',
              'priority': 'Medium',
              'status': 'Completed',
              'assignedDate': '17 Mar 2024, 02:15 PM',
              'assignedBy': 'Neha Gupta (HR Lead)',
              'deadline': '24 Mar 2024, 06:00 PM',
              'completedDate': '23 Mar 2024, 03:10 PM',
              'timeliness': 'Delivered on-time',
              'isEarly': true,
              'subtasks': '3 of 3 sub-tasks completed',
              'description': 'CRUD operations for departments and designations with real-time employee counter badges.',
            },
          ],
          'leaves': [],
          'qualityFeedback': {
            'author': 'Rajesh Verma (VP Engineering)',
            'date': 'Reviewed on 29 Mar 2024',
            'comment': '"Outstanding velocity on the RBAC security engine and export utility. Zero defect turnaround."',
            'accuracy': 0.99,
            'timeliness': 0.98,
            'qaPass': 0.97,
            'collaboration': 0.96,
          },
        };

      case 'Feb 2024':
        final febScore = (baseScore * 0.90).round().clamp(55, 95);
        return {
          'score': febScore,
          'ratingLabel': 'Good',
          'rank': widget.emp.rank + 1,
          'attendanceProgress': 0.91,
          'attendanceLabel': '22 / 24 Days',
          'leaveProgress': 0.5,
          'leaveLabel': '1 / 2 Days',
          'taskCompletionProgress': 0.93,
          'taskCompletionLabel': '15 / 16 Tasks',
          'timelyProgress': 0.82,
          'timelyLabel': '9 / 11 Tasks',
          'qualityProgress': 0.90,
          'qualityLabel': '4.5 / 5.0 Rating',
          'totalTasks': '16',
          'completedTasks': '15',
          'inProgressTasks': '1',
          'onTimeRate': '90%',
          'annualAllotted': '18 Days',
          'leavesTaken': '1 Day',
          'balanceLeft': '17 Days',
          'tasks': [
            {
              'title': 'Initial App Architecture & State Management Setup',
              'project': 'DigiEmployee Mobile App',
              'priority': 'High',
              'status': 'Completed',
              'assignedDate': '02 Feb 2024, 09:30 AM',
              'assignedBy': 'Rajesh Verma (VP Engineering)',
              'deadline': '10 Feb 2024, 06:00 PM',
              'completedDate': '09 Feb 2024, 04:20 PM',
              'timeliness': 'Delivered 1 day early (On Time)',
              'isEarly': true,
              'subtasks': '4 of 4 sub-tasks completed',
              'description': 'Modular folder structure, GetX bindings, dependency injection, and clean architecture foundation.',
            },
            {
              'title': 'API Client Setup with Dio & Interceptors',
              'project': 'Core Network Layer',
              'priority': 'High',
              'status': 'Completed',
              'assignedDate': '12 Feb 2024, 10:00 AM',
              'assignedBy': 'Rajesh Verma (VP Engineering)',
              'deadline': '18 Feb 2024, 06:00 PM',
              'completedDate': '17 Feb 2024, 05:00 PM',
              'timeliness': 'Delivered on-time',
              'isEarly': true,
              'subtasks': '3 of 3 sub-tasks completed',
              'description': 'Configured automated bearer token insertion, error interceptors, and network retry logic.',
            },
          ],
          'leaves': [
            {
              'type': 'Casual Leave',
              'dates': '16 Feb 2024 (1 Day)',
              'appliedDate': '13 Feb 2024, 11:00 AM',
              'approvedDate': '14 Feb 2024, 12:00 PM',
              'approvedBy': 'Neha Gupta (HR Manager)',
              'reason': 'Family event attendance',
              'status': 'Approved',
            },
          ],
          'qualityFeedback': {
            'author': 'Ananya Roy (Product Lead)',
            'date': 'Reviewed on 27 Feb 2024',
            'comment': '"Solid engineering setup and clean, maintainable code architecture. Ready for feature scaling."',
            'accuracy': 0.92,
            'timeliness': 0.88,
            'qaPass': 0.91,
            'collaboration': 0.89,
          },
        };

      case 'Jan 2024':
      default:
        final janScore = (baseScore * 0.92).round().clamp(55, 95);
        return {
          'score': janScore,
          'ratingLabel': 'Good',
          'rank': widget.emp.rank + 1,
          'attendanceProgress': 0.92,
          'attendanceLabel': '23 / 25 Days',
          'leaveProgress': 0.5,
          'leaveLabel': '2 / 2 Days',
          'taskCompletionProgress': 0.95,
          'taskCompletionLabel': '19 / 20 Tasks',
          'timelyProgress': 0.91,
          'timelyLabel': '11 / 12 Tasks',
          'qualityProgress': 0.94,
          'qualityLabel': '4.7 / 5.0 Rating',
          'totalTasks': '20',
          'completedTasks': '19',
          'inProgressTasks': '0',
          'onTimeRate': '94%',
          'annualAllotted': '18 Days',
          'leavesTaken': '2 Days',
          'balanceLeft': '16 Days',
          'tasks': [
            {
              'title': 'Project Kickoff & Technical Requirements Documentation',
              'project': 'DigiEmployee Mobile App',
              'priority': 'High',
              'status': 'Completed',
              'assignedDate': '05 Jan 2024, 10:00 AM',
              'assignedBy': 'Rajesh Verma (VP Engineering)',
              'deadline': '12 Jan 2024, 06:00 PM',
              'completedDate': '11 Jan 2024, 03:30 PM',
              'timeliness': 'Delivered 1 day early (On Time)',
              'isEarly': true,
              'subtasks': '3 of 3 sub-tasks completed',
              'description': 'Defined Flutter technology stack, API contracts, design mockups review, and sprint timeline.',
            },
            {
              'title': 'Design System & Reusable UI Component Kit',
              'project': 'UI Kit & Design Tokens',
              'priority': 'Medium',
              'status': 'Completed',
              'assignedDate': '15 Jan 2024, 09:30 AM',
              'assignedBy': 'Ananya Roy (Product Lead)',
              'deadline': '22 Jan 2024, 06:00 PM',
              'completedDate': '21 Jan 2024, 05:00 PM',
              'timeliness': 'Delivered on-time',
              'isEarly': true,
              'subtasks': '5 of 5 sub-tasks completed',
              'description': 'Built typography styles, custom buttons, inputs, badge indicators, and consistent color palettes.',
            },
          ],
          'leaves': [
            {
              'type': 'Privilege Leave',
              'dates': '08 Jan 2024 - 09 Jan 2024 (2 Days)',
              'appliedDate': '02 Jan 2024, 10:00 AM',
              'approvedDate': '03 Jan 2024, 04:00 PM',
              'approvedBy': 'Neha Gupta (HR Manager)',
              'reason': 'Extended New Year holidays',
              'status': 'Approved',
            },
          ],
          'qualityFeedback': {
            'author': 'Rajesh Verma (VP Engineering)',
            'date': 'Reviewed on 30 Jan 2024',
            'comment': '"Commendable work setting up the baseline design tokens and technical architecture specs."',
            'accuracy': 0.95,
            'timeliness': 0.94,
            'qaPass': 0.93,
            'collaboration': 0.94,
          },
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentMonthData = _getMonthData(_selectedMonth);
    final score = currentMonthData['score'] as int;
    final ratingLabel = currentMonthData['ratingLabel'] as String;
    final rank = currentMonthData['rank'] as int;

    final attendanceProgress = currentMonthData['attendanceProgress'] as double;
    final leaveProgress = currentMonthData['leaveProgress'] as double;
    final taskCompletionProgress = currentMonthData['taskCompletionProgress'] as double;
    final timelySubmissionProgress = currentMonthData['timelyProgress'] as double;
    final qualityProgress = currentMonthData['qualityProgress'] as double;

    final metrics = [
      PerformanceMetric(
        name: 'Attendance',
        label: currentMonthData['attendanceLabel'] as String,
        progress: attendanceProgress,
        icon: Iconsax.calendar,
        accentColor: attendanceProgress > 0.8 ? AppColors.successColor : AppColors.warningColor,
        bgLightColor: attendanceProgress > 0.8 ? const Color(0xFFEAFAF1) : const Color(0xFFFEF9EC),
      ),
      PerformanceMetric(
        name: 'Leave',
        label: currentMonthData['leaveLabel'] as String,
        progress: leaveProgress,
        icon: Iconsax.sun_1,
        accentColor: leaveProgress > 0.5 ? AppColors.successColor : AppColors.warningColor,
        bgLightColor: leaveProgress > 0.5 ? const Color(0xFFEAFAF1) : const Color(0xFFFEF9EC),
      ),
      PerformanceMetric(
        name: 'Task Completion',
        label: currentMonthData['taskCompletionLabel'] as String,
        progress: taskCompletionProgress,
        icon: Iconsax.task_square,
        accentColor: taskCompletionProgress > 0.75 ? AppColors.successColor : AppColors.warningColor,
        bgLightColor: taskCompletionProgress > 0.75 ? const Color(0xFFEAFAF1) : const Color(0xFFFEF9EC),
      ),
      PerformanceMetric(
        name: 'Timely Submissions',
        label: currentMonthData['timelyLabel'] as String,
        progress: timelySubmissionProgress,
        icon: Iconsax.clock,
        accentColor: timelySubmissionProgress > 0.75 ? AppColors.primaryColor : AppColors.warningColor,
        bgLightColor: timelySubmissionProgress > 0.75 ? const Color(0xFFEFF6FF) : const Color(0xFFFEF9EC),
      ),
      PerformanceMetric(
        name: 'Quality of Work',
        label: currentMonthData['qualityLabel'] as String,
        progress: qualityProgress,
        icon: Iconsax.star,
        accentColor: const Color(0xFFF43F5E),
        bgLightColor: const Color(0xFFFFF1F2),
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textColorPrimary, size: 18),
          onPressed: () => Get.back(),
        ),
        title: AppText(
          '${widget.emp.name}\'s Overview',
          fontSize: 17,
          fontWeight: FontWeight.w800,
          color: AppColors.textColorPrimary,
        ),
        centerTitle: true,
        actions: [
          // Month Selector in AppBar
          PopupMenuButton<String>(
            initialValue: _selectedMonth,
            onSelected: (month) {
              setState(() {
                _selectedMonth = month;
              });
            },
            tooltip: 'Select Month',
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            itemBuilder: (ctx) => _months.map((m) {
              final isSelected = m == _selectedMonth;
              return PopupMenuItem<String>(
                value: m,
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                      size: 16,
                      color: isSelected ? AppColors.primaryColor : AppColors.textColorHint,
                    ),
                    const SizedBox(width: 8),
                    AppText(
                      m,
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? AppColors.primaryColor : AppColors.textColorPrimary,
                    ),
                  ],
                ),
              );
            }).toList(),
            child: Container(
              margin: const EdgeInsets.only(right: 14),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Iconsax.calendar_1, size: 14, color: AppColors.primaryColor),
                  const SizedBox(width: 5),
                  AppText(
                    _selectedMonth,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.keyboard_arrow_down, size: 14, color: AppColors.primaryColor),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Employee Info Header
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: (widget.emp.imageUrl.isNotEmpty && widget.emp.imageUrl.startsWith('http'))
                      ? NetworkImage(widget.emp.imageUrl)
                      : null,
                  backgroundColor: AppColors.primaryLight,
                  child: (widget.emp.imageUrl.isEmpty || !widget.emp.imageUrl.startsWith('http'))
                      ? AppText(
                          widget.emp.name.isNotEmpty ? widget.emp.name[0].toUpperCase() : 'E',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(widget.emp.name, fontSize: 18, fontWeight: FontWeight.bold),
                      const SizedBox(height: 4),
                      AppText('${widget.emp.designation} • ${widget.emp.department}', fontSize: 13, color: AppColors.textColorSecondary),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Filter Banner Indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(Iconsax.filter_edit, size: 16, color: AppColors.primaryColor),
                  const SizedBox(width: 8),
                  const AppText('Filter Period:', fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textColorSecondary),
                  const SizedBox(width: 4),
                  AppText(_selectedMonth, fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primaryColor),
                  const Spacer(),
                  // Horizontal quick switch pills
                  GestureDetector(
                    onTap: () => _showMonthPickerSheet(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppText('Change Month', fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                          SizedBox(width: 2),
                          Icon(Icons.arrow_forward_ios_rounded, size: 8, color: AppColors.primaryColor),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Performance Card
            _buildPerformanceCard(score: score, ratingLabel: ratingLabel, rank: rank),
            const SizedBox(height: 24),

            // Key Metrics
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const AppText(
                  'Detailed Metrics',
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textColorPrimary,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const AppText('Tap card for details ›', fontSize: 10, color: AppColors.primaryColor, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...metrics.map((m) => _buildMetricItem(context, m)),

            const SizedBox(height: 28),

            // Warning / Message Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openChatWithEmployee(),
                icon: Icon(score < 75 ? Icons.warning_amber_rounded : Iconsax.message, color: Colors.white),
                label: AppText(
                  score < 75 ? 'Send Warning Message' : 'Send Message',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: score < 75 ? Colors.red : AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showMonthPickerSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const AppText('Filter by Month', fontSize: 16, fontWeight: FontWeight.bold),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ..._months.map((m) {
                  final isSelected = m == _selectedMonth;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: AppText(
                      m,
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? AppColors.primaryColor : AppColors.textColorPrimary,
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: AppColors.primaryColor)
                        : const Icon(Icons.circle_outlined, color: AppColors.textColorHint),
                    onTap: () {
                      setState(() {
                        _selectedMonth = m;
                      });
                      Navigator.pop(ctx);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPerformanceCard({required int score, required String ratingLabel, required int rank}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: score < 75 
              ? [const Color(0xFFEF4444), const Color(0xFFF87171)] 
              : [const Color(0xFF4F46E5), const Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (score < 75 ? const Color(0xFFEF4444) : const Color(0xFF4F46E5)).withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AppText(
                'Overall Performance',
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
              GestureDetector(
                onTap: () => _showMonthPickerSheet(context),
                child: Container(
                  height: 28,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Iconsax.calendar_1, size: 12, color: Colors.white),
                      const SizedBox(width: 5),
                      AppText(_selectedMonth, color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      const SizedBox(width: 3),
                      const Icon(Icons.keyboard_arrow_down, size: 14, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: CustomPaint(
                  painter: _PerformanceRingPainter(
                    score: score.toDouble(),
                    label: ratingLabel,
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        _buildMiniGridItem('Rank', '#$rank'),
                        const SizedBox(width: 12),
                        _buildMiniGridItem('Score', '$score%'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildMiniGridItem('Period', _selectedMonth.split(' ')[0]),
                        const SizedBox(width: 12),
                        _buildMiniGridItem('Evaluation', ratingLabel),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniGridItem(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(label, fontSize: 9, color: Colors.white70, fontWeight: FontWeight.w600),
            const SizedBox(height: 2),
            AppText(value, fontSize: 14, color: Colors.white, fontWeight: FontWeight.w900),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(BuildContext context, PerformanceMetric metric) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleMetricClick(context, metric.name),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.slate200),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: metric.bgLightColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(metric.icon, color: metric.accentColor, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            AppText(metric.name, fontSize: 13, fontWeight: FontWeight.w700),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: metric.accentColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: AppText('View ›', fontSize: 9, fontWeight: FontWeight.bold, color: metric.accentColor),
                            ),
                          ],
                        ),
                        AppText(
                          metric.label,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textColorSecondary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Stack(
                      children: [
                        Container(
                          height: 6,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.slate100,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: metric.progress,
                          child: Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: metric.accentColor,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.slate300),
            ],
          ),
        ),
      ),
    );
  }

  void _handleMetricClick(BuildContext context, String metricName) {
    if (metricName == 'Attendance') {
      final attendanceCtrl = Get.put(AttendanceHistoryController());
      // Sync the attendance controller's selected month with the current performance screen month
      attendanceCtrl.selectedMonth.value = _getDateTimeForMonth(_selectedMonth);

      Get.to(() => AttendanceHistoryScreen(
        showBackButton: true,
        employeeName: widget.emp.name,
        employeeId: widget.emp.id,
        employeeDesignation: widget.emp.designation,
      ));
    } else if (metricName == 'Leave') {
      _showLeaveDetailsBottomSheet(context);
    } else if (metricName == 'Task Completion' || metricName == 'Timely Submissions') {
      _showTaskDetailsBottomSheet(context);
    } else if (metricName == 'Quality of Work') {
      _showQualityDetailsBottomSheet(context);
    }
  }

  // ----------------------------------------------------
  // Task Details Bottom Sheet (Filtered by Month)
  // ----------------------------------------------------
  void _showTaskDetailsBottomSheet(BuildContext context) {
    String sheetMonth = _selectedMonth;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (bottomSheetContext, setModalState) {
            final monthData = _getMonthData(sheetMonth);
            final List<dynamic> tasksList = monthData['tasks'] as List<dynamic>;

            return Container(
              height: MediaQuery.of(context).size.height * 0.90,
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  // Header Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Iconsax.task_square, color: AppColors.primaryColor, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                "${widget.emp.name}'s Tasks & Assignments",
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                              const SizedBox(height: 2),
                              const AppText(
                                'Assigned dates, deadlines, completion history & timeliness',
                                fontSize: 11,
                                color: AppColors.textColorSecondary,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: AppColors.textColorSecondary),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),

                  // Month Filter Chips inside Bottom Sheet
                  Container(
                    height: 38,
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _months.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 8),
                      itemBuilder: (context, idx) {
                        final m = _months[idx];
                        final isSel = m == sheetMonth;
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              sheetMonth = m;
                            });
                            // Also update parent state
                            setState(() {
                              _selectedMonth = m;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSel ? AppColors.primaryColor : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSel ? AppColors.primaryColor : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Iconsax.calendar,
                                  size: 13,
                                  color: isSel ? Colors.white : AppColors.textColorSecondary,
                                ),
                                const SizedBox(width: 6),
                                AppText(
                                  m,
                                  fontSize: 11,
                                  fontWeight: isSel ? FontWeight.bold : FontWeight.w600,
                                  color: isSel ? Colors.white : AppColors.textColorSecondary,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Summary stats counter for selected month
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildTaskMiniStat('Total Tasks', monthData['totalTasks'] as String, const Color(0xFF1E293B)),
                        _buildDivider(),
                        _buildTaskMiniStat('Completed', monthData['completedTasks'] as String, const Color(0xFF16A34A)),
                        _buildDivider(),
                        _buildTaskMiniStat('In Progress', monthData['inProgressTasks'] as String, const Color(0xFF0284C7)),
                        _buildDivider(),
                        _buildTaskMiniStat('On Time', monthData['onTimeRate'] as String, const Color(0xFF9333EA)),
                      ],
                    ),
                  ),

                  const Divider(height: 1, color: Color(0xFFE2E8F0)),

                  // Scrollable Task List
                  Expanded(
                    child: tasksList.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Iconsax.task, size: 40, color: AppColors.textColorHint),
                                const SizedBox(height: 8),
                                AppText('No tasks recorded for $sheetMonth', color: AppColors.textColorSecondary, fontSize: 13),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(20),
                            physics: const BouncingScrollPhysics(),
                            itemCount: tasksList.length,
                            itemBuilder: (context, index) {
                              final item = tasksList[index] as Map<String, dynamic>;
                              final isCompleted = item['status'] == 'Completed';

                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.02),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Project & Badges Row
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF1F5F9),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: AppText(
                                            item['project'] as String,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF475569),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            // Priority Badge
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: item['priority'] == 'High'
                                                    ? Colors.red.withValues(alpha: 0.1)
                                                    : Colors.orange.withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: AppText(
                                                '${item['priority']} Priority',
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: item['priority'] == 'High' ? Colors.red : Colors.orange.shade800,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            // Status Badge
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: isCompleted
                                                    ? const Color(0xFFDCFCE7)
                                                    : const Color(0xFFE0F2FE),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    isCompleted ? Icons.check_circle : Icons.timelapse_rounded,
                                                    size: 12,
                                                    color: isCompleted ? const Color(0xFF16A34A) : const Color(0xFF0284C7),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  AppText(
                                                    item['status'] as String,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w800,
                                                    color: isCompleted ? const Color(0xFF15803D) : const Color(0xFF0369A1),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),

                                    // Task Title
                                    AppText(
                                      item['title'] as String,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF1E293B),
                                    ),
                                    const SizedBox(height: 4),
                                    AppText(
                                      item['description'] as String,
                                      fontSize: 11,
                                      color: AppColors.textColorSecondary,
                                    ),
                                    const SizedBox(height: 12),

                                    // Timeline Box: Assigned date, deadline, completion date (in 100% English)
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: const Color(0xFFE2E8F0)),
                                      ),
                                      child: Column(
                                        children: [
                                          // Assigned Row
                                          Row(
                                            children: [
                                              const Icon(Iconsax.calendar_add, size: 15, color: Color(0xFF0284C7)),
                                              const SizedBox(width: 8),
                                              const AppText('Assigned On: ', fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                                              Expanded(
                                                child: AppText(
                                                  item['assignedDate'] as String,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                  color: const Color(0xFF0284C7),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),

                                          // Deadline Row
                                          Row(
                                            children: [
                                              const Icon(Iconsax.timer, size: 15, color: Color(0xFFE11D48)),
                                              const SizedBox(width: 8),
                                              const AppText('Deadline: ', fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                                              Expanded(
                                                child: AppText(
                                                  item['deadline'] as String,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: const Color(0xFFE11D48),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),

                                          // Completed Row
                                          Row(
                                            children: [
                                              Icon(
                                                isCompleted ? Iconsax.tick_circle : Iconsax.clock,
                                                size: 15,
                                                color: isCompleted ? const Color(0xFF16A34A) : const Color(0xFFF59E0B),
                                              ),
                                              const SizedBox(width: 8),
                                              const AppText('Completed On: ', fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                                              Expanded(
                                                child: AppText(
                                                  item['completedDate'] as String,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w800,
                                                  color: isCompleted ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),

                                          // Assigned By Row
                                          Row(
                                            children: [
                                              const Icon(Iconsax.user, size: 15, color: Color(0xFF64748B)),
                                              const SizedBox(width: 8),
                                              const AppText('Assigned By: ', fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                                              Expanded(
                                                child: AppText(
                                                  item['assignedBy'] as String,
                                                  fontSize: 11,
                                                  color: const Color(0xFF475569),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    // Timeliness Tag & Subtasks row
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: (item['isEarly'] as bool)
                                                ? const Color(0xFFF0FDF4)
                                                : const Color(0xFFEFF6FF),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: (item['isEarly'] as bool)
                                                  ? const Color(0xFFBBF7D0)
                                                  : const Color(0xFFBFDBFE),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                (item['isEarly'] as bool) ? Icons.electric_bolt_rounded : Icons.info_outline,
                                                size: 13,
                                                color: (item['isEarly'] as bool) ? const Color(0xFF16A34A) : const Color(0xFF2563EB),
                                              ),
                                              const SizedBox(width: 4),
                                              AppText(
                                                item['timeliness'] as String,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: (item['isEarly'] as bool) ? const Color(0xFF15803D) : const Color(0xFF1D4ED8),
                                              ),
                                            ],
                                          ),
                                        ),
                                        AppText(
                                          item['subtasks'] as String,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textColorSecondary,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ----------------------------------------------------
  // Leave Details Bottom Sheet (Filtered by Month)
  // ----------------------------------------------------
  void _showLeaveDetailsBottomSheet(BuildContext context) {
    String sheetMonth = _selectedMonth;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (bottomSheetContext, setModalState) {
            final monthData = _getMonthData(sheetMonth);
            final List<dynamic> leaveList = monthData['leaves'] as List<dynamic>;

            return Container(
              height: MediaQuery.of(context).size.height * 0.80,
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Iconsax.sun_1, color: Colors.amber, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                "${widget.emp.name}'s Leave Breakdown",
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                              const SizedBox(height: 2),
                              const AppText(
                                'Leave entitlement, requests and approval history',
                                fontSize: 11,
                                color: AppColors.textColorSecondary,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: AppColors.textColorSecondary),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),

                  // Month Filter Chips inside Bottom Sheet
                  Container(
                    height: 38,
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _months.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 8),
                      itemBuilder: (context, idx) {
                        final m = _months[idx];
                        final isSel = m == sheetMonth;
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              sheetMonth = m;
                            });
                            setState(() {
                              _selectedMonth = m;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSel ? AppColors.primaryColor : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSel ? AppColors.primaryColor : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Iconsax.calendar,
                                  size: 13,
                                  color: isSel ? Colors.white : AppColors.textColorSecondary,
                                ),
                                const SizedBox(width: 6),
                                AppText(
                                  m,
                                  fontSize: 11,
                                  fontWeight: isSel ? FontWeight.bold : FontWeight.w600,
                                  color: isSel ? Colors.white : AppColors.textColorSecondary,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Summary cards for the month
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildTaskMiniStat('Annual Allotted', monthData['annualAllotted'] as String, const Color(0xFF1E293B)),
                        _buildDivider(),
                        _buildTaskMiniStat('Leaves Taken', monthData['leavesTaken'] as String, const Color(0xFFE11D48)),
                        _buildDivider(),
                        _buildTaskMiniStat('Balance Left', monthData['balanceLeft'] as String, const Color(0xFF16A34A)),
                      ],
                    ),
                  ),

                  const Divider(height: 1, color: Color(0xFFE2E8F0)),

                  Expanded(
                    child: leaveList.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Iconsax.sun_1, size: 40, color: AppColors.textColorHint),
                                const SizedBox(height: 8),
                                AppText('No leaves recorded in $sheetMonth', color: AppColors.textColorSecondary, fontSize: 13),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(20),
                            physics: const BouncingScrollPhysics(),
                            itemCount: leaveList.length,
                            itemBuilder: (context, index) {
                              final item = leaveList[index] as Map<String, dynamic>;
                              final isApproved = item['status'] == 'Approved';

                              return Container(
                                margin: const EdgeInsets.only(bottom: 14),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        AppText(
                                          item['type'] as String,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF1E293B),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: isApproved ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: AppText(
                                            item['status'] as String,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: isApproved ? const Color(0xFF15803D) : const Color(0xFFB45309),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),

                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: const Color(0xFFE2E8F0)),
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(Iconsax.calendar_1, size: 14, color: AppColors.textColorSecondary),
                                              const SizedBox(width: 8),
                                              const AppText('Dates: ', fontSize: 11, fontWeight: FontWeight.bold),
                                              AppText(item['dates'] as String, fontSize: 11, color: const Color(0xFF334155), fontWeight: FontWeight.w600),
                                            ],
                                          ),
                                          const SizedBox(height: 5),
                                          Row(
                                            children: [
                                              const Icon(Iconsax.clock, size: 14, color: AppColors.textColorSecondary),
                                              const SizedBox(width: 8),
                                              const AppText('Applied: ', fontSize: 11, fontWeight: FontWeight.bold),
                                              AppText(item['appliedDate'] as String, fontSize: 11, color: const Color(0xFF64748B)),
                                            ],
                                          ),
                                          const SizedBox(height: 5),
                                          Row(
                                            children: [
                                              const Icon(Iconsax.user_tick, size: 14, color: Color(0xFF16A34A)),
                                              const SizedBox(width: 8),
                                              const AppText('Approved By: ', fontSize: 11, fontWeight: FontWeight.bold),
                                              Expanded(
                                                child: AppText(
                                                  '${item['approvedBy']} (${item['approvedDate']})',
                                                  fontSize: 11,
                                                  color: const Color(0xFF16A34A),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const AppText('Reason: ', fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textColorSecondary),
                                        Expanded(
                                          child: AppText(item['reason'] as String, fontSize: 11, color: const Color(0xFF475569)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ----------------------------------------------------
  // Quality of Work Details Bottom Sheet (Filtered by Month)
  // ----------------------------------------------------
  void _showQualityDetailsBottomSheet(BuildContext context) {
    String sheetMonth = _selectedMonth;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (bottomSheetContext, setModalState) {
            final monthData = _getMonthData(sheetMonth);
            final feedback = monthData['qualityFeedback'] as Map<String, dynamic>;

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF1F2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Iconsax.star, color: Color(0xFFF43F5E), size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                "${widget.emp.name}'s Quality Assessment",
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                              const SizedBox(height: 2),
                              const AppText(
                                'Code review, bug density & stakeholder feedback',
                                fontSize: 11,
                                color: AppColors.textColorSecondary,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: AppColors.textColorSecondary),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),

                  // Month Filter Chips inside Bottom Sheet
                  Container(
                    height: 38,
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _months.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 8),
                      itemBuilder: (context, idx) {
                        final m = _months[idx];
                        final isSel = m == sheetMonth;
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              sheetMonth = m;
                            });
                            setState(() {
                              _selectedMonth = m;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSel ? AppColors.primaryColor : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSel ? AppColors.primaryColor : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Iconsax.calendar,
                                  size: 13,
                                  color: isSel ? Colors.white : AppColors.textColorSecondary,
                                ),
                                const SizedBox(width: 6),
                                AppText(
                                  m,
                                  fontSize: 11,
                                  fontWeight: isSel ? FontWeight.bold : FontWeight.w600,
                                  color: isSel ? Colors.white : AppColors.textColorSecondary,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),

                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      physics: const BouncingScrollPhysics(),
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const AppText('Quality Criteria Breakdown', fontSize: 13, fontWeight: FontWeight.bold),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: AppText(sheetMonth, fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textColorSecondary),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              _buildQualityBar('Code / Deliverable Accuracy', feedback['accuracy'] as double, '${((feedback['accuracy'] as double) * 100).round()}%'),
                              const SizedBox(height: 10),
                              _buildQualityBar('Timely Adherence & Deadlines', feedback['timeliness'] as double, '${((feedback['timeliness'] as double) * 100).round()}%'),
                              const SizedBox(height: 10),
                              _buildQualityBar('Defect Prevention (QA Pass)', feedback['qaPass'] as double, '${((feedback['qaPass'] as double) * 100).round()}%'),
                              const SizedBox(height: 10),
                              _buildQualityBar('Team Collaboration & Feedback', feedback['collaboration'] as double, '${((feedback['collaboration'] as double) * 100).round()}%'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        const AppText('Lead & Peer Feedback Notes', fontSize: 13, fontWeight: FontWeight.bold),
                        const SizedBox(height: 10),

                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const CircleAvatar(
                                    radius: 14,
                                    backgroundColor: AppColors.primaryLight,
                                    child: Icon(Icons.person, size: 16, color: AppColors.primaryColor),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        AppText(feedback['author'] as String, fontSize: 12, fontWeight: FontWeight.bold),
                                        AppText(feedback['date'] as String, fontSize: 10, color: AppColors.textColorSecondary),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                feedback['comment'] as String,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF475569),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildQualityBar(String label, double val, String percent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppText(label, fontSize: 11, color: const Color(0xFF475569), fontWeight: FontWeight.w600),
            AppText(percent, fontSize: 11, color: AppColors.primaryColor, fontWeight: FontWeight.bold),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: val,
            minHeight: 6,
            backgroundColor: const Color(0xFFF1F5F9),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskMiniStat(String label, String value, Color color) {
    return Column(
      children: [
        AppText(value, fontSize: 16, fontWeight: FontWeight.w900, color: color),
        const SizedBox(height: 2),
        AppText(label, fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textColorSecondary),
      ],
    );
  }

  Widget _buildDivider() => Container(width: 1, height: 26, color: const Color(0xFFE2E8F0));

  void _openChatWithEmployee() {
    final chatCtrl = Get.put(ChatController());
    final existingIdx = chatCtrl.conversations.indexWhere((c) => c.id == widget.emp.id);
    if (existingIdx == -1) {
      chatCtrl.conversations.insert(0, ChatConversation(
        id: widget.emp.id,
        name: widget.emp.name,
        avatarUrl: widget.emp.imageUrl,
        designation: widget.emp.designation,
        lastMessage: '',
        lastMessageTime: DateTime.now(),
      ));
    }
    chatCtrl.selectConversation(widget.emp.id);
    Get.to(() => const ChatRoomScreen());
  }
}

class _PerformanceRingPainter extends CustomPainter {
  final double score;
  final String label;

  _PerformanceRingPainter({required this.score, required this.label});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2);
    const strokeWidth = 8.0;

    final trackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius - strokeWidth / 2, trackPaint);

    final progressPaint = Paint()
      ..shader = const SweepGradient(
        colors: [Color(0xFFFEF08A), Color(0xFF10B981), Color(0xFFFEF08A)],
        startAngle: 0,
        endAngle: pi * 2,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    final sweepAngle = (score / 100.0) * pi * 2;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    final scoreSpan = TextSpan(
      style: const TextStyle(
        fontFamily: 'Inter',
        color: Colors.white,
        fontWeight: FontWeight.w900,
        fontSize: 18,
        height: 1.1,
      ),
      text: '${score.round()}%\n',
      children: [
        TextSpan(
          text: label,
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w700,
            fontSize: 7.5,
          ),
        ),
      ],
    );

    textPainter.text = scoreSpan;
    textPainter.layout(minWidth: 0, maxWidth: size.width);
    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
