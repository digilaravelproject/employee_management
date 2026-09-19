import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'shift_response_model.dart';

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

  factory ShiftModel.fromDataModel(ShiftDataModel data) {
    final type = data.shiftType.isNotEmpty ? data.shiftType : 'Fixed Shift';
    final isNight = type.toLowerCase().contains('night');
    final isFlexi = type.toLowerCase().contains('flex');
    final isRotate = type.toLowerCase().contains('rotat');

    IconData icon = Icons.wb_sunny_outlined;
    Color iconColor = Colors.orange;

    if (isNight) {
      icon = Icons.nightlight_outlined;
      iconColor = Colors.blue;
    } else if (isFlexi) {
      icon = Iconsax.slider_horizontal;
      iconColor = Colors.redAccent;
    } else if (isRotate) {
      icon = Iconsax.repeat;
      iconColor = Colors.green;
    } else if (type.toLowerCase().contains('evening')) {
      icon = Icons.wb_twilight;
      iconColor = Colors.purple;
    }

    final assignedNames = data.assignedEmployees.map((e) => e.name).toList();

    return ShiftModel(
      id: data.id.toString(),
      name: data.name,
      code: data.code,
      type: type,
      isActive: data.status?.toLowerCase() == 'active',
      description: data.description ?? '',
      startTime: data.startTime,
      endTime: data.endTime,
      crossMidnight: data.crossMidnight,
      workingHours: data.totalDuration ?? data.netWorkingDuration ?? data.grossDuration ?? '8h 00m',
      enableBreak: data.breaksEnabled,
      breakType: data.breaks.isNotEmpty ? data.breaks.first.type : 'Paid',
      breakDuration: data.breakDuration ?? '01:00',
      gracePeriod: '${data.gracePeriodMinutes ?? 15} Minutes',
      lateAfter: '${data.lateAfterMinutes ?? 15} Minutes',
      minWorkingHours: '${(data.minimumWorkingMinutes ?? 480) ~/ 60}:00 Hours',
      earlyLeavingAllowed: data.earlyLeavingAllowed ?? false,
      autoMarkLate: data.autoMarkLate ?? true,
      autoMarkHalfDay: data.autoMarkHalfDay ?? true,
      lateThreshold: '${data.lateThresholdMinutes ?? 30} Minutes',
      halfDayAfter: '${(data.halfDayAfterMinutes ?? 240) ~/ 60}:00 Hours',
      enableOvertime: data.overtimeEnabled ?? true,
      otStartsAfter: '${(data.overtimeStartsAfterMinutes ?? 480) ~/ 60}:00 Hours',
      minimumOT: '${data.minimumOvertimeMinutes ?? 30} Minutes',
      otCalculation: data.overtimeCalculation ?? 'Hourly',
      approvalRequired: data.overtimeApprovalRequired ?? true,
      employeesCount: data.assignedEmployeesCount > 0 ? data.assignedEmployeesCount : data.assignedEmployees.length,
      iconColor: iconColor,
      icon: icon,
      assignedEmployeeNames: assignedNames,
    );
  }
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
