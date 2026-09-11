import 'package:flutter/material.dart';

class ShiftModel {
  final String id;
  String name;
  String code;
  String type; // 'Fixed Shift', 'Flexible Shift', 'Night Shift', 'Rotational Shift'
  bool isActive;
  String description;
  String startTime;
  String endTime;
  bool crossMidnight;
  String workingHours;
  bool enableBreak;
  String breakType;
  String breakDuration;
  String gracePeriod;
  String lateAfter;
  String minWorkingHours;
  bool earlyLeavingAllowed;
  bool autoMarkLate;
  bool autoMarkHalfDay;
  String lateThreshold;
  String halfDayAfter;
  bool enableOvertime;
  String otStartsAfter;
  String minimumOT;
  String otCalculation;
  bool approvalRequired;
  int employeesCount;
  Color iconColor;
  IconData icon;
  List<String> assignedEmployeeNames;

  ShiftModel({
    required this.id,
    required this.name,
    required this.code,
    required this.type,
    required this.isActive,
    this.description = '',
    required this.startTime,
    required this.endTime,
    this.crossMidnight = false,
    required this.workingHours,
    this.enableBreak = true,
    this.breakType = 'Paid',
    this.breakDuration = '60 Minutes',
    this.gracePeriod = '15 Minutes',
    this.lateAfter = '15 Minutes',
    this.minWorkingHours = '08:00 Hours',
    this.earlyLeavingAllowed = false,
    this.autoMarkLate = true,
    this.autoMarkHalfDay = true,
    this.lateThreshold = '30 Minutes',
    this.halfDayAfter = '04:00 Hours',
    this.enableOvertime = true,
    this.otStartsAfter = '08:00 Hours',
    this.minimumOT = '30 Minutes',
    this.otCalculation = 'Hourly',
    this.approvalRequired = true,
    this.employeesCount = 0,
    this.iconColor = Colors.orange,
    this.icon = Icons.wb_sunny_outlined,
    this.assignedEmployeeNames = const [],
  });
}

class ShiftHistoryModel {
  final String date;
  final String userName;
  final String userRole;
  final String action; // 'Created', 'Updated', 'Assigned', 'Deactivated'
  final String details;
  final Color actionColor;

  ShiftHistoryModel({
    required this.date,
    required this.userName,
    this.userRole = 'Admin',
    required this.action,
    required this.details,
    this.actionColor = const Color(0xFF2563EB),
  });
}
