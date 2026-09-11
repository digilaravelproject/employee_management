import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../models/shift_model.dart';

class ShiftController extends GetxController {
  final RxList<ShiftModel> shifts = <ShiftModel>[].obs;
  final RxList<ShiftHistoryModel> historyList = <ShiftHistoryModel>[].obs;

  final RxString searchQuery = ''.obs;
  final RxString selectedType = 'All Types'.obs;
  final RxString selectedStatus = 'All Status'.obs;

  final List<String> typeFilterOptions = [
    'All Types',
    'Fixed Shift',
    'Flexible Shift',
    'Night Shift',
    'Rotational Shift',
  ];

  final List<String> statusFilterOptions = [
    'All Status',
    'Active',
    'Inactive',
  ];

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
  }

  void _loadInitialData() {
    shifts.assignAll([
      ShiftModel(
        id: '1',
        name: 'Morning Shift',
        code: 'MORNING',
        type: 'Fixed Shift',
        isActive: true,
        description: 'Morning working shift for sales and operations team.',
        startTime: '10:00 AM',
        endTime: '07:00 PM',
        workingHours: '9 Hours',
        breakType: 'Paid',
        breakDuration: '60 Minutes',
        gracePeriod: '15 Minutes',
        lateAfter: '15 Minutes',
        minWorkingHours: '08:00 Hours',
        employeesCount: 18,
        icon: Icons.wb_sunny_outlined,
        iconColor: Colors.orange,
        assignedEmployeeNames: ['Rahul Kumar', 'Amit Sharma', 'Pooja Verma', 'Vikram Joshi', 'Sameer Ali'],
      ),
      ShiftModel(
        id: '2',
        name: 'Evening Shift',
        code: 'EVENING',
        type: 'Fixed Shift',
        isActive: true,
        description: 'Mid-day and evening coverage for customer service operations.',
        startTime: '02:00 PM',
        endTime: '11:00 PM',
        workingHours: '9 Hours',
        breakType: 'Paid',
        breakDuration: '45 Minutes',
        gracePeriod: '15 Minutes',
        lateAfter: '15 Minutes',
        minWorkingHours: '08:00 Hours',
        employeesCount: 12,
        icon: Icons.wb_twilight,
        iconColor: Colors.purple,
        assignedEmployeeNames: ['Neha Singh', 'Arif Khan', 'Priya Sharma'],
      ),
      ShiftModel(
        id: '3',
        name: 'Night Shift',
        code: 'NIGHT',
        type: 'Night Shift',
        isActive: true,
        crossMidnight: true,
        description: 'Overnight technical infrastructure and monitoring team.',
        startTime: '10:00 PM',
        endTime: '07:00 AM',
        workingHours: '9 Hours',
        breakType: 'Paid',
        breakDuration: '60 Minutes',
        gracePeriod: '20 Minutes',
        lateAfter: '20 Minutes',
        minWorkingHours: '08:00 Hours',
        employeesCount: 8,
        icon: Icons.nightlight_outlined,
        iconColor: Colors.blue,
        assignedEmployeeNames: ['Sameer Khan', 'Deepak Verma'],
      ),
      ShiftModel(
        id: '4',
        name: 'General Shift',
        code: 'GENERAL',
        type: 'Fixed Shift',
        isActive: true,
        description: 'Corporate and administrative standard business hours.',
        startTime: '09:00 AM',
        endTime: '06:00 PM',
        workingHours: '9 Hours',
        breakType: 'Paid',
        breakDuration: '60 Minutes',
        gracePeriod: '15 Minutes',
        lateAfter: '15 Minutes',
        minWorkingHours: '08:00 Hours',
        employeesCount: 4,
        icon: Iconsax.clock,
        iconColor: Colors.teal,
        assignedEmployeeNames: ['Sonia Kapoor', 'Anil Deshmukh'],
      ),
      ShiftModel(
        id: '5',
        name: 'Flexible Shift',
        code: 'FLEXI',
        type: 'Flexible Shift',
        isActive: false,
        description: 'Remote and hybrid work model with flexible start times.',
        startTime: '09:00 AM',
        endTime: '06:00 PM',
        workingHours: '9 Hours',
        breakType: 'Unpaid',
        breakDuration: '60 Minutes',
        gracePeriod: '30 Minutes',
        lateAfter: '30 Minutes',
        minWorkingHours: '07:00 Hours',
        employeesCount: 3,
        icon: Iconsax.slider_horizontal,
        iconColor: Colors.redAccent,
        assignedEmployeeNames: ['Rohan Gupta'],
      ),
      ShiftModel(
        id: '6',
        name: 'Rotational Shift',
        code: 'ROTATE',
        type: 'Rotational Shift',
        isActive: true,
        description: 'Bi-weekly rotating shift schedule for 24/7 client support.',
        startTime: '10:00 AM',
        endTime: '07:00 PM',
        workingHours: '9 Hours',
        breakType: 'Paid',
        breakDuration: '60 Minutes',
        gracePeriod: '15 Minutes',
        lateAfter: '15 Minutes',
        minWorkingHours: '08:00 Hours',
        employeesCount: 5,
        icon: Iconsax.repeat,
        iconColor: Colors.green,
        assignedEmployeeNames: ['Manish Rao', 'Sunil Tiwari'],
      ),
    ]);

    historyList.assignAll([
      ShiftHistoryModel(
        date: '10 Sep 2026',
        userName: 'Firoz Mohammad',
        action: 'Updated',
        details: 'Grace Period: 10 min → 15 min',
        actionColor: Colors.blue,
      ),
      ShiftHistoryModel(
        date: '08 Sep 2026',
        userName: 'Admin',
        action: 'Assigned',
        details: '5 employees assigned to Morning Shift',
        actionColor: Colors.green,
      ),
      ShiftHistoryModel(
        date: '01 Sep 2026',
        userName: 'Firoz Mohammad',
        action: 'Created',
        details: 'Created Morning Shift (10:00 AM - 07:00 PM)',
        actionColor: Colors.purple,
      ),
      ShiftHistoryModel(
        date: '28 Aug 2026',
        userName: 'Admin',
        action: 'Updated',
        details: 'Break Time: 01:00 PM - 02:00 PM (Paid)',
        actionColor: Colors.blue,
      ),
      ShiftHistoryModel(
        date: '20 Aug 2026',
        userName: 'Firoz Mohammad',
        action: 'Updated',
        details: 'Overtime rule: Enabled (starts after 08:00 Hours)',
        actionColor: Colors.orange,
      ),
      ShiftHistoryModel(
        date: '15 Aug 2026',
        userName: 'Admin',
        action: 'Deactivated',
        details: 'Flexible Shift set to inactive',
        actionColor: Colors.redAccent,
      ),
    ]);
  }

  // Getters for Stats
  int get totalShifts => shifts.length;
  int get totalEmployees => shifts.fold<int>(0, (sum, s) => sum + s.employeesCount);
  int get activeShifts => shifts.where((s) => s.isActive).length;
  int get inactiveShifts => shifts.where((s) => !s.isActive).length;

  List<ShiftModel> get filteredShifts {
    final query = searchQuery.value.trim().toLowerCase();
    return shifts.where((shift) {
      final matchesQuery = query.isEmpty ||
          shift.name.toLowerCase().contains(query) ||
          shift.code.toLowerCase().contains(query);

      final matchesType = selectedType.value == 'All Types' ||
          shift.type.toLowerCase().contains(selectedType.value.toLowerCase().replaceAll(' shift', ''));

      final matchesStatus = selectedStatus.value == 'All Status' ||
          (selectedStatus.value == 'Active' ? shift.isActive : !shift.isActive);

      return matchesQuery && matchesType && matchesStatus;
    }).toList();
  }

  void addShift(ShiftModel newShift) {
    shifts.insert(0, newShift);
    historyList.insert(
      0,
      ShiftHistoryModel(
        date: 'Today',
        userName: 'Current Admin',
        action: 'Created',
        details: 'Created ${newShift.name} (${newShift.startTime} - ${newShift.endTime})',
        actionColor: Colors.purple,
      ),
    );
  }

  void toggleShiftStatus(ShiftModel shift) {
    shift.isActive = !shift.isActive;
    shifts.refresh();
    historyList.insert(
      0,
      ShiftHistoryModel(
        date: 'Today',
        userName: 'Current Admin',
        action: shift.isActive ? 'Updated' : 'Deactivated',
        details: '${shift.name} marked as ${shift.isActive ? "Active" : "Inactive"}',
        actionColor: shift.isActive ? Colors.green : Colors.redAccent,
      ),
    );
  }

  void duplicateShift(ShiftModel shift) {
    final copy = ShiftModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '${shift.name} (Copy)',
      code: '${shift.code}_COPY',
      type: shift.type,
      isActive: shift.isActive,
      description: shift.description,
      startTime: shift.startTime,
      endTime: shift.endTime,
      crossMidnight: shift.crossMidnight,
      workingHours: shift.workingHours,
      enableBreak: shift.enableBreak,
      breakType: shift.breakType,
      breakDuration: shift.breakDuration,
      gracePeriod: shift.gracePeriod,
      lateAfter: shift.lateAfter,
      minWorkingHours: shift.minWorkingHours,
      earlyLeavingAllowed: shift.earlyLeavingAllowed,
      autoMarkLate: shift.autoMarkLate,
      autoMarkHalfDay: shift.autoMarkHalfDay,
      lateThreshold: shift.lateThreshold,
      halfDayAfter: shift.halfDayAfter,
      enableOvertime: shift.enableOvertime,
      otStartsAfter: shift.otStartsAfter,
      minimumOT: shift.minimumOT,
      otCalculation: shift.otCalculation,
      approvalRequired: shift.approvalRequired,
      employeesCount: 0,
      icon: shift.icon,
      iconColor: shift.iconColor,
      assignedEmployeeNames: [],
    );
    addShift(copy);
  }
}
