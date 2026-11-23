import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../../../core/widgets/app_text.dart';
import '../../departments/controllers/departments_controller.dart';
import '../../departments/repositories/department_repository.dart';
import '../../employee/designation/controllers/designation_controller.dart';
import '../../employee/designation/repositories/designation_repository.dart';
import '../../employee/management/controllers/employee_controller.dart';
import '../controllers/shift_controller.dart';
import '../models/create_shift_request_model.dart';
import '../models/shift_model.dart';
import '../models/shift_response_model.dart';

class BreakItem {
  String name;
  String type; // 'Paid' or 'Unpaid'
  String duration;
  TimeOfDay startTime;
  TimeOfDay endTime;

  BreakItem({
    required this.name,
    required this.type,
    required this.duration,
    required this.startTime,
    required this.endTime,
  });
}

class DaySchedule {
  final String dayName;
  bool isWorking;
  TimeOfDay startTime;
  TimeOfDay endTime;

  DaySchedule({
    required this.dayName,
    required this.isWorking,
    required this.startTime,
    required this.endTime,
  });
}

class EmployeeItem {
  final String id;
  final String name;
  final String department;
  final String designation;
  final String currentShift;
  final String status; // 'Assigned' or 'Available'
  bool isSelected;

  EmployeeItem({
    required this.id,
    required this.name,
    required this.department,
    required this.designation,
    required this.currentShift,
    required this.status,
    this.isSelected = false,
  });
}

class CreateShiftScreen extends StatefulWidget {
  final ShiftModel? shiftToEdit;
  final ShiftDataModel? shiftDataToEdit;

  const CreateShiftScreen({
    super.key,
    this.shiftToEdit,
    this.shiftDataToEdit,
  });

  @override
  State<CreateShiftScreen> createState() => _CreateShiftScreenState();
}

class _CreateShiftScreenState extends State<CreateShiftScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 6;

  final GlobalKey _shiftNameKey = GlobalKey();
  final GlobalKey _shiftCodeKey = GlobalKey();
  final GlobalKey _shiftTypeKey = GlobalKey();
  final GlobalKey _timingKey = GlobalKey();
  final GlobalKey _breaksKey = GlobalKey();
  final GlobalKey _scheduleKey = GlobalKey();

  final FocusNode _shiftNameFocusNode = FocusNode();
  final FocusNode _shiftCodeFocusNode = FocusNode();

  bool get _isEditing => widget.shiftToEdit != null || widget.shiftDataToEdit != null;
  String get _shiftId => widget.shiftToEdit?.id ?? widget.shiftDataToEdit?.id.toString() ?? '';

  // ----------------------------------------------------
  // Step 1: Basic Information (Panel 2)
  // ----------------------------------------------------
  late final TextEditingController _shiftNameController;
  late final TextEditingController _shiftCodeController;
  late final TextEditingController _descriptionController;
  late String _shiftType;
  final List<String> _shiftTypes = ['Fixed Shift', 'Flexible Shift', 'Rotational Shift', 'Night Shift', 'Split Shift'];
  late bool _isActive;

  // ----------------------------------------------------
  // Step 2: Shift Timing (Panel 3)
  // ----------------------------------------------------
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late bool _crossMidnight;

  // ----------------------------------------------------
  // Step 3: Break Settings (Panel 4)
  // ----------------------------------------------------
  late bool _enableBreak;
  final TextEditingController _breakNameController = TextEditingController();
  late String _breakType;
  late TimeOfDay _breakStartTime;
  late TimeOfDay _breakEndTime;

  late List<BreakItem> _breaks;

  // ----------------------------------------------------
  // Step 4: Attendance Rules (Panel 5)
  // ----------------------------------------------------
  late String _gracePeriod;
  late String _lateAfter;
  late String _minWorkingHours;
  late bool _earlyLeavingAllowed;
  late bool _autoMarkLate;
  late bool _autoMarkHalfDay;
  late String _lateThreshold;
  late String _halfDayAfter;

  final List<String> _gracePeriodOptions = ['5 Minutes', '10 Minutes', '15 Minutes', '20 Minutes', '30 Minutes'];
  final List<String> _lateAfterOptions = ['5 Minutes', '10 Minutes', '15 Minutes', '20 Minutes', '30 Minutes'];
  final List<String> _minHoursOptions = ['06:00 Hours', '07:00 Hours', '08:00 Hours', '09:00 Hours'];
  final List<String> _lateThresholdOptions = ['15 Minutes', '30 Minutes', '45 Minutes', '60 Minutes'];
  final List<String> _halfDayOptions = ['03:00 Hours', '04:00 Hours', '05:00 Hours', '06:00 Hours'];

  // ----------------------------------------------------
  // Step 5: Overtime Settings (Panel 6)
  // ----------------------------------------------------
  late bool _enableOvertime;
  final TextEditingController _otStartsAfterController = TextEditingController();
  final TextEditingController _minimumOTController = TextEditingController();
  late String _otCalculation;
  late bool _approvalRequired;

  final List<String> _otCalculationOptions = ['Hourly', 'Daily', '1.5x Hourly Rate', '2x Hourly Rate', 'Flat Stipend'];

  // ----------------------------------------------------
  // Step 6: Weekly Schedule (Panel 7)
  // ----------------------------------------------------
  late List<DaySchedule> _weeklySchedule;
  bool _enableAlternateOff = false;
  String _alternateOffDay = 'Saturday';
  final List<String> _alternateWeeks = ['2nd & 4th', '1st & 3rd'];
  String _selectedAlternateWeek = '2nd & 4th';
  final List<String> _weekDaysList = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  // ----------------------------------------------------
  // Step 6: Employee Assignment (Panel 7)
  // ----------------------------------------------------
  final TextEditingController _searchEmployeeController = TextEditingController();
  String _selectedDepartment = 'All';
  String _selectedDesignation = 'All';
  final List<String> _departments = ['All'];
  final List<String> _designations = ['All'];

  final List<EmployeeItem> _allEmployees = [];

  void _initEmployeeList() {
    final empCtrl = Get.isRegistered<EmployeeController>()
        ? Get.find<EmployeeController>()
        : Get.put(EmployeeController());

    final data = widget.shiftDataToEdit;
    final shift = widget.shiftToEdit;
    final assignedIds = (data != null && data.assignedEmployees.isNotEmpty)
        ? data.assignedEmployees.map((e) => e.id.toString()).toSet()
        : <String>{};
    final assignedNames = (data != null && data.assignedEmployees.isNotEmpty)
        ? data.assignedEmployees.map((e) => e.name.toLowerCase()).toSet()
        : (shift != null
            ? shift.assignedEmployeeNames.map((n) => n.toLowerCase()).toSet()
            : <String>{});

    _allEmployees.clear();

    if (empCtrl.employees.isNotEmpty) {
      for (final emp in empCtrl.employees) {
        final dept = emp.department.isNotEmpty ? emp.department : '';
        final desig = emp.designation.isNotEmpty ? emp.designation : '';

        final isPreSelected = assignedIds.contains(emp.id) ||
            assignedNames.contains(emp.name.toLowerCase());

        _allEmployees.add(
          EmployeeItem(
            id: emp.id,
            name: emp.name,
            department: dept,
            designation: desig,
            currentShift: emp.shift.isNotEmpty ? emp.shift : 'No Shift',
            status: emp.shift.isNotEmpty ? 'Assigned' : 'Available',
            isSelected: isPreSelected,
          ),
        );
      }
    }

    _loadDepartmentsAndDesignations();

    if (mounted) {
      setState(() {});
    }
  }

  void _loadDepartmentsAndDesignations() {
    final deptCtrl = Get.isRegistered<DepartmentsController>()
        ? Get.find<DepartmentsController>()
        : Get.put(DepartmentsController(
            repository: Get.isRegistered<DepartmentRepository>()
                ? Get.find<DepartmentRepository>()
                : DepartmentRepository(apiClient: Get.find<ApiClient>()),
          ));

    final desigCtrl = Get.isRegistered<DesignationController>()
        ? Get.find<DesignationController>()
        : Get.put(DesignationController(
            repository: Get.isRegistered<DesignationRepository>()
                ? Get.find<DesignationRepository>()
                : DesignationRepository(apiClient: Get.find<ApiClient>()),
          ));

    // 1. Departments list from DepartmentsController
    final deptList = <String>[];
    if (deptCtrl.apiDepartments.isNotEmpty) {
      deptList.addAll(deptCtrl.apiDepartments.map((d) => d.name.trim()).where((n) => n.isNotEmpty));
    } else if (deptCtrl.departments.isNotEmpty) {
      deptList.addAll(deptCtrl.departments.map((d) => d.name.trim()).where((n) => n.isNotEmpty));
    }

    _departments.clear();
    _departments.add('All');
    if (deptList.isNotEmpty) {
      _departments.addAll(deptList.toSet());
    }
    if (!_departments.contains(_selectedDepartment)) {
      _selectedDepartment = 'All';
    }

    // 2. Designations list from DesignationController
    final desigList = <String>[];
    if (desigCtrl.designations.isNotEmpty) {
      desigList.addAll(desigCtrl.designations.map((d) => d.name.trim()).where((n) => n.isNotEmpty));
    }

    _designations.clear();
    _designations.add('All');
    if (desigList.isNotEmpty) {
      _designations.addAll(desigList.toSet());
    }
    if (!_designations.contains(_selectedDesignation)) {
      _selectedDesignation = 'All';
    }
  }

  @override
  void initState() {
    super.initState();

    final data = widget.shiftDataToEdit;
    final shift = widget.shiftToEdit;

    // Step 1: Basic Info
    _shiftNameController = TextEditingController(
      text: data?.name ?? shift?.name ?? '',
    );
    _shiftCodeController = TextEditingController(
      text: data?.code ?? shift?.code ?? '',
    );
    _descriptionController = TextEditingController(
      text: data?.description ?? shift?.description ?? '',
    );

    final resolvedType = data?.shiftType ?? shift?.type ?? 'Fixed Shift';
    _shiftType = _shiftTypes.contains(resolvedType) ? resolvedType : _shiftTypes.first;

    if (data != null) {
      _isActive = data.status?.toLowerCase() == 'active';
    } else if (shift != null) {
      _isActive = shift.isActive;
    } else {
      _isActive = true;
    }

    // Step 2: Timings
    final startTimeStr = data?.startTime ?? shift?.startTime;
    final endTimeStr = data?.endTime ?? shift?.endTime;
    _startTime = _parseTimeToTimeOfDay(startTimeStr, defaultTime: const TimeOfDay(hour: 9, minute: 0));
    _endTime = _parseTimeToTimeOfDay(endTimeStr, defaultTime: const TimeOfDay(hour: 18, minute: 0));
    _crossMidnight = data?.crossMidnight ?? shift?.crossMidnight ?? false;

    // Step 3: Breaks
    _enableBreak = data?.breaksEnabled ?? shift?.enableBreak ?? false;
    _breakType = 'Paid';
    _breakStartTime = const TimeOfDay(hour: 13, minute: 0);
    _breakEndTime = const TimeOfDay(hour: 13, minute: 30);

    if (data != null && data.breaks.isNotEmpty) {
      _breaks = data.breaks.map((b) {
        return BreakItem(
          name: b.name.isNotEmpty ? b.name : 'Lunch Break',
          type: b.type.isNotEmpty ? b.type : 'Paid',
          duration: '${b.durationMinutes ?? 60} min',
          startTime: _parseTimeToTimeOfDay(b.startTime, defaultTime: const TimeOfDay(hour: 13, minute: 0)),
          endTime: _parseTimeToTimeOfDay(b.endTime, defaultTime: const TimeOfDay(hour: 14, minute: 0)),
        );
      }).toList();
    } else if (shift != null) {
      _breaks = [
        BreakItem(
          name: 'Lunch Break',
          type: 'Paid',
          duration: '60 min',
          startTime: const TimeOfDay(hour: 13, minute: 0),
          endTime: const TimeOfDay(hour: 14, minute: 0),
        ),
      ];
    } else {
      // Create mode: no prefilled breaks
      _breaks = [];
    }

    // Step 4: Attendance Rules
    final graceMins = data?.gracePeriodMinutes ?? (shift != null ? _parseDurationToMinutes(shift.gracePeriod, defaultValue: 15) : null);
    _gracePeriod = graceMins != null && _gracePeriodOptions.contains('$graceMins Minutes') ? '$graceMins Minutes' : _gracePeriodOptions.first;

    final lateMins = data?.lateAfterMinutes ?? (shift != null ? _parseDurationToMinutes(shift.lateAfter, defaultValue: 15) : null);
    _lateAfter = lateMins != null && _lateAfterOptions.contains('$lateMins Minutes') ? '$lateMins Minutes' : _lateAfterOptions.first;

    final minWorkMins = data?.minimumWorkingMinutes ?? (shift != null ? _parseDurationToMinutes(shift.minWorkingHours, defaultValue: 480) : null);
    final minWorkStr = minWorkMins != null ? '${(minWorkMins ~/ 60).toString().padLeft(2, '0')}:00 Hours' : '';
    _minWorkingHours = _minHoursOptions.contains(minWorkStr) ? minWorkStr : _minHoursOptions.first;

    _earlyLeavingAllowed = data?.earlyLeavingAllowed ?? shift?.earlyLeavingAllowed ?? false;
    _autoMarkLate = data?.autoMarkLate ?? shift?.autoMarkLate ?? false;
    _autoMarkHalfDay = data?.autoMarkHalfDay ?? shift?.autoMarkHalfDay ?? false;

    final lateThreshMins = data?.lateThresholdMinutes ?? (shift != null ? _parseDurationToMinutes(shift.lateThreshold, defaultValue: 30) : null);
    _lateThreshold = lateThreshMins != null && _lateThresholdOptions.contains('$lateThreshMins Minutes') ? '$lateThreshMins Minutes' : _lateThresholdOptions.first;

    final halfDayMins = data?.halfDayAfterMinutes ?? (shift != null ? _parseDurationToMinutes(shift.halfDayAfter, defaultValue: 240) : null);
    final halfDayStr = halfDayMins != null ? '${(halfDayMins ~/ 60).toString().padLeft(2, '0')}:00 Hours' : '';
    _halfDayAfter = _halfDayOptions.contains(halfDayStr) ? halfDayStr : _halfDayOptions.first;

    // Step 5: Overtime
    _enableOvertime = data?.overtimeEnabled ?? shift?.enableOvertime ?? false;

    // Default OT starts after = shift end time
    final defaultOtStarts = _formatTimeOfDay(_endTime);
    final otStartsMins = data?.overtimeStartsAfterMinutes ?? (shift != null ? _parseDurationToMinutes(shift.otStartsAfter, defaultValue: 0) : null);
    if (otStartsMins != null && otStartsMins > 0) {
      final hours = (otStartsMins ~/ 60).toString().padLeft(2, '0');
      final mins = (otStartsMins % 60).toString().padLeft(2, '0');
      _otStartsAfterController.text = '$hours:$mins';
    } else {
      _otStartsAfterController.text = defaultOtStarts;
    }

    final minOtMins = data?.minimumOvertimeMinutes ?? (shift != null ? _parseDurationToMinutes(shift.minimumOT, defaultValue: 0) : null);
    if (minOtMins != null && minOtMins > 0) {
      _minimumOTController.text = '$minOtMins';
    } else {
      _minimumOTController.text = '';
    }

    final otCalc = data?.overtimeCalculation ?? shift?.otCalculation;
    _otCalculation = otCalc != null && _otCalculationOptions.contains(otCalc) ? otCalc : _otCalculationOptions.first;

    _approvalRequired = data?.overtimeApprovalRequired ?? shift?.approvalRequired ?? false;

    // Step 6: Weekly Schedule
    if (data != null && data.workingDays.isNotEmpty) {
      _weeklySchedule = data.workingDays.map((d) {
        return DaySchedule(
          dayName: d.day,
          isWorking: d.enabled,
          startTime: _parseTimeToTimeOfDay(d.startTime, defaultTime: _startTime),
          endTime: _parseTimeToTimeOfDay(d.endTime, defaultTime: _endTime),
        );
      }).toList();
    } else if (shift != null) {
      // Edit mode (ShiftModel): Mon–Fri working by default
      _weeklySchedule = [
        DaySchedule(dayName: 'Monday', isWorking: true, startTime: _startTime, endTime: _endTime),
        DaySchedule(dayName: 'Tuesday', isWorking: true, startTime: _startTime, endTime: _endTime),
        DaySchedule(dayName: 'Wednesday', isWorking: true, startTime: _startTime, endTime: _endTime),
        DaySchedule(dayName: 'Thursday', isWorking: true, startTime: _startTime, endTime: _endTime),
        DaySchedule(dayName: 'Friday', isWorking: true, startTime: _startTime, endTime: _endTime),
        DaySchedule(dayName: 'Saturday', isWorking: false, startTime: _startTime, endTime: _endTime),
        DaySchedule(dayName: 'Sunday', isWorking: false, startTime: _startTime, endTime: _endTime),
      ];
    } else {
      // Create mode: all days off — user selects
      _weeklySchedule = [
        DaySchedule(dayName: 'Monday', isWorking: false, startTime: _startTime, endTime: _endTime),
        DaySchedule(dayName: 'Tuesday', isWorking: false, startTime: _startTime, endTime: _endTime),
        DaySchedule(dayName: 'Wednesday', isWorking: false, startTime: _startTime, endTime: _endTime),
        DaySchedule(dayName: 'Thursday', isWorking: false, startTime: _startTime, endTime: _endTime),
        DaySchedule(dayName: 'Friday', isWorking: false, startTime: _startTime, endTime: _endTime),
        DaySchedule(dayName: 'Saturday', isWorking: false, startTime: _startTime, endTime: _endTime),
        DaySchedule(dayName: 'Sunday', isWorking: false, startTime: _startTime, endTime: _endTime),
      ];
    }

    // Step 7: Pre-select employees and load live employee directory
    final empCtrl = Get.isRegistered<EmployeeController>()
        ? Get.find<EmployeeController>()
        : Get.put(EmployeeController());

    // Ensure departments & designations controllers are ready and fetch data if empty
    final deptCtrl = Get.isRegistered<DepartmentsController>()
        ? Get.find<DepartmentsController>()
        : Get.put(DepartmentsController(
            repository: Get.isRegistered<DepartmentRepository>()
                ? Get.find<DepartmentRepository>()
                : DepartmentRepository(apiClient: Get.find<ApiClient>()),
          ));

    final desigCtrl = Get.isRegistered<DesignationController>()
        ? Get.find<DesignationController>()
        : Get.put(DesignationController(
            repository: Get.isRegistered<DesignationRepository>()
                ? Get.find<DesignationRepository>()
                : DesignationRepository(apiClient: Get.find<ApiClient>()),
          ));

    if (deptCtrl.apiDepartments.isEmpty && deptCtrl.departments.isEmpty) {
      deptCtrl.fetchDepartments().then((_) {
        if (mounted) setState(() => _loadDepartmentsAndDesignations());
      });
    }
    if (desigCtrl.designations.isEmpty) {
      desigCtrl.fetchDesignations().then((_) {
        if (mounted) setState(() => _loadDepartmentsAndDesignations());
      });
    }

    _initEmployeeList();

    if (empCtrl.employees.isEmpty) {
      empCtrl.fetchEmployees(showLoader: false).then((_) {
        _initEmployeeList();
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _shiftNameController.dispose();
    _shiftCodeController.dispose();
    _shiftNameFocusNode.dispose();
    _shiftCodeFocusNode.dispose();
    _descriptionController.dispose();
    _breakNameController.dispose();
    _otStartsAfterController.dispose();
    _minimumOTController.dispose();
    _searchEmployeeController.dispose();
    super.dispose();
  }

  // ----------------------------------------------------
  // Helpers
  // ----------------------------------------------------
  TimeOfDay _parseTimeToTimeOfDay(String? timeStr, {TimeOfDay defaultTime = const TimeOfDay(hour: 10, minute: 0)}) {
    if (timeStr == null || timeStr.trim().isEmpty) return defaultTime;
    try {
      final trimmed = timeStr.trim();
      if (trimmed.toLowerCase().contains('am') || trimmed.toLowerCase().contains('pm')) {
        final parsed = DateFormat('hh:mm a').parse(trimmed);
        return TimeOfDay(hour: parsed.hour, minute: parsed.minute);
      }
      final parts = trimmed.split(':');
      if (parts.length >= 2) {
        final hour = int.tryParse(parts[0]) ?? defaultTime.hour;
        final minute = int.tryParse(parts[1].split(' ')[0]) ?? defaultTime.minute;
        return TimeOfDay(hour: hour, minute: minute);
      }
    } catch (_) {}
    return defaultTime;
  }
  int _parseDurationToMinutes(String text, {int defaultValue = 0}) {
    try {
      final trimmed = text.trim();
      if (trimmed.toLowerCase().contains('hour')) {
        final timeParts = trimmed.split(' ')[0].split(':');
        if (timeParts.length == 2) {
          final hours = int.tryParse(timeParts[0]) ?? 0;
          final minutes = int.tryParse(timeParts[1]) ?? 0;
          return (hours * 60) + minutes;
        } else if (timeParts.length == 1) {
          final hours = int.tryParse(timeParts[0]) ?? 0;
          return hours * 60;
        }
      }
      final match = RegExp(r'\d+').firstMatch(trimmed);
      if (match != null) {
        return int.tryParse(match.group(0)!) ?? defaultValue;
      }
    } catch (_) {}
    return defaultValue;
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('hh:mm a').format(dt);
  }

  String _calculateWorkingHours(TimeOfDay start, TimeOfDay end, bool crossMidnight) {
    int startMinutes = start.hour * 60 + start.minute;
    int endMinutes = end.hour * 60 + end.minute;

    if (crossMidnight || endMinutes < startMinutes) {
      endMinutes += 24 * 60;
    }

    int diffMinutes = endMinutes - startMinutes;
    if (diffMinutes < 0) diffMinutes = 0;

    int hours = diffMinutes ~/ 60;
    int mins = diffMinutes % 60;

    if (mins == 0) {
      return '$hours Hours';
    } else {
      return '$hours Hours $mins Mins';
    }
  }

  String _calculateBreakDuration(TimeOfDay start, TimeOfDay end) {
    int startMinutes = start.hour * 60 + start.minute;
    int endMinutes = end.hour * 60 + end.minute;

    if (endMinutes < startMinutes) {
      endMinutes += 24 * 60; // if passes midnight
    }

    int diffMinutes = endMinutes - startMinutes;
    if (diffMinutes < 0) diffMinutes = 0;

    int hours = diffMinutes ~/ 60;
    int mins = diffMinutes % 60;

    if (hours > 0 && mins > 0) {
      return '$hours hr $mins min';
    } else if (hours > 0) {
      return '$hours hr';
    } else {
      return '$mins min';
    }
  }

  void _scrollToAndFocusField({
    required int step,
    GlobalKey? fieldKey,
    FocusNode? focusNode,
  }) {
    final bool stepChanged = _currentStep != step;
    if (stepChanged) {
      _goToStep(step, validateBefore: false);
    }
    Future.delayed(Duration(milliseconds: stepChanged ? 350 : 60), () {
      if (!mounted) return;
      if (fieldKey?.currentContext != null) {
        Scrollable.ensureVisible(
          fieldKey!.currentContext!,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          alignment: 0.15,
        );
      }
      focusNode?.requestFocus();
    });
  }

  bool _validateShiftStep(int step) {
    if (step == 0) {
      if (_shiftNameController.text.trim().isEmpty) {
        CustomSnackbar.showError('Please enter shift name');
        _scrollToAndFocusField(step: 0, fieldKey: _shiftNameKey, focusNode: _shiftNameFocusNode);
        return false;
      }
      if (_shiftCodeController.text.trim().isEmpty) {
        CustomSnackbar.showError('Please enter shift code');
        _scrollToAndFocusField(step: 0, fieldKey: _shiftCodeKey, focusNode: _shiftCodeFocusNode);
        return false;
      }
      if (_shiftType.trim().isEmpty) {
        CustomSnackbar.showError('Please select shift type');
        _scrollToAndFocusField(step: 0, fieldKey: _shiftTypeKey);
        return false;
      }
      return true;
    } else if (step == 1) {
      if (!_crossMidnight && (_startTime.hour == _endTime.hour && _startTime.minute == _endTime.minute)) {
        CustomSnackbar.showError('Shift start time and end time cannot be identical');
        _scrollToAndFocusField(step: 1, fieldKey: _timingKey);
        return false;
      }
      return true;
    } else if (step == 2) {
      if (_enableBreak && _breaks.isEmpty) {
        CustomSnackbar.showError('Please add at least one break or disable breaks');
        _scrollToAndFocusField(step: 2, fieldKey: _breaksKey);
        return false;
      }
      return true;
    } else if (step == 4) {
      final hasWorkingDay = _weeklySchedule.any((d) => d.isWorking);
      if (!hasWorkingDay) {
        CustomSnackbar.showError('Please enable at least one working day in the weekly schedule');
        _scrollToAndFocusField(step: 4, fieldKey: _scheduleKey);
        return false;
      }
      return true;
    }
    return true;
  }

  bool _validateAllShiftSteps() {
    for (int i = 0; i < _totalSteps; i++) {
      if (!_validateShiftStep(i)) {
        return false;
      }
    }
    return true;
  }

  void _handleShiftApiError(String errorMsg) {
    final lower = errorMsg.toLowerCase();
    if (lower.contains('name')) {
      _scrollToAndFocusField(step: 0, fieldKey: _shiftNameKey, focusNode: _shiftNameFocusNode);
    } else if (lower.contains('code')) {
      _scrollToAndFocusField(step: 0, fieldKey: _shiftCodeKey, focusNode: _shiftCodeFocusNode);
    } else if (lower.contains('type')) {
      _scrollToAndFocusField(step: 0, fieldKey: _shiftTypeKey);
    } else if (lower.contains('time') || lower.contains('timing') || lower.contains('grace') || lower.contains('late') || lower.contains('half')) {
      _scrollToAndFocusField(step: 1, fieldKey: _timingKey);
    } else if (lower.contains('break')) {
      _scrollToAndFocusField(step: 2, fieldKey: _breaksKey);
    } else if (lower.contains('overtime') || lower.contains('ot')) {
      _scrollToAndFocusField(step: 3);
    } else if (lower.contains('working') || lower.contains('schedule') || lower.contains('day')) {
      _scrollToAndFocusField(step: 4, fieldKey: _scheduleKey);
    }
  }

  void _goToStep(int step, {bool validateBefore = true}) {
    if (step < 0 || step >= _totalSteps) return;
    if (validateBefore && step > _currentStep) {
      for (int i = _currentStep; i < step; i++) {
        if (!_validateShiftStep(i)) return;
      }
    }
    setState(() {
      _currentStep = step;
    });
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  List<EmployeeItem> get _filteredEmployees {
    final query = _searchEmployeeController.text.toLowerCase().trim();
    return _allEmployees.where((emp) {
      final matchesQuery = query.isEmpty ||
          emp.name.toLowerCase().contains(query) ||
          emp.department.toLowerCase().contains(query) ||
          emp.designation.toLowerCase().contains(query);
      final matchesDept = _selectedDepartment == 'All' || emp.department == _selectedDepartment;
      final matchesDesig = _selectedDesignation == 'All' || emp.designation == _selectedDesignation;
      return matchesQuery && matchesDept && matchesDesig;
    }).toList();
  }

  int get _selectedEmployeesCount => _allEmployees.where((e) => e.isSelected).length;

  // ----------------------------------------------------
  // Main Build
  // ----------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textColorPrimary, size: 20),
          onPressed: () {
            if (_currentStep > 0) {
              _goToStep(_currentStep - 1);
            } else {
              Get.back();
            }
          },
        ),
        title: AppText(_isEditing ? 'Edit Shift' : 'Create New Shift', fontSize: 18, fontWeight: FontWeight.bold),
        centerTitle: false,
        actions: [
          TextButton.icon(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.close, size: 18, color: AppColors.textColorSecondary),
            label: const AppText('Cancel', fontSize: 13, color: AppColors.textColorSecondary),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Clean Numbered Stepper (1 to 7)
          _buildStepperBar(),

          // Main Step Page Views
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep1BasicInfo(),
                _buildStep2ShiftTiming(),
                _buildStep3BreakSettings(),
                _buildStep5OvertimeSettings(),
                _buildStep6WeeklySchedule(),
                _buildStep7EmployeeAssignment(),
              ],
            ),
          ),

          // Bottom Navigation Buttons
          _buildBottomBar(),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // Stepper Header (Clean 1, 2, 3, 4, 5, 6, 7 Row)
  // ----------------------------------------------------
  Widget _buildStepperBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.slate200.withValues(alpha: 0.8))),
      ),
      child: Row(
        children: List.generate(_totalSteps * 2 - 1, (index) {
          if (index.isOdd) {
            final stepIndex = index ~/ 2;
            final isPassed = stepIndex < _currentStep;
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: 2.5,
                color: isPassed ? AppColors.primaryColor : AppColors.slate200,
              ),
            );
          }

          final stepIndex = index ~/ 2;
          final isPassed = stepIndex < _currentStep;
          final isCurrent = stepIndex == _currentStep;

          return GestureDetector(
            onTap: () => _goToStep(stepIndex),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isPassed
                    ? AppColors.primaryColor
                    : isCurrent
                        ? AppColors.primaryColor
                        : Colors.white,
                border: Border.all(
                  color: (isPassed || isCurrent) ? AppColors.primaryColor : AppColors.slate300,
                  width: isCurrent ? 2 : 1.5,
                ),
                boxShadow: isCurrent
                    ? [
                        BoxShadow(
                          color: AppColors.primaryColor.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: isPassed
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : AppText(
                        '${stepIndex + 1}',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isCurrent ? Colors.white : AppColors.textColorHint,
                      ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ----------------------------------------------------
  // Step Header (Rendered right above each form card)
  // ----------------------------------------------------
  Widget _buildStepHeader({
    required String stepNumber,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      AppText(
                        'STEP $stepNumber OF $_totalSteps',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryColor,
                        letterSpacing: 0.5,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                AppText(
                  title,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColorPrimary,
                ),
                const SizedBox(height: 2),
                AppText(
                  subtitle,
                  fontSize: 12,
                  color: AppColors.textColorSecondary,
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // STEP 1: Basic Information (Panel 2)
  // ----------------------------------------------------
  Widget _buildStep1BasicInfo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            stepNumber: '1',
            title: 'Basic Information',
            subtitle: 'Configure the primary identity and classification of this shift.',
          ),
          _buildCardContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFieldLabel('Shift Name', isRequired: true),
                const SizedBox(height: 8),
                _buildTextInput(
                  key: _shiftNameKey,
                  focusNode: _shiftNameFocusNode,
                  controller: _shiftNameController,
                  hint: 'e.g. Morning Shift',
                  prefixIcon: Iconsax.clock,
                ),

                const SizedBox(height: 20),

                _buildFieldLabel('Shift Code', isRequired: true),
                const SizedBox(height: 8),
                _buildTextInput(
                  key: _shiftCodeKey,
                  focusNode: _shiftCodeFocusNode,
                  controller: _shiftCodeController,
                  hint: 'e.g. MORNING or SHIFT-01',
                  prefixIcon: Iconsax.code,
                ),

                const SizedBox(height: 20),

                _buildFieldLabel('Shift Type', isRequired: true),
                const SizedBox(height: 8),
                _buildDropdownField<String>(
                  key: _shiftTypeKey,
                  value: _shiftType,
                  items: _shiftTypes,
                  onChanged: (val) {
                    if (val != null) setState(() => _shiftType = val);
                  },
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('Status', isRequired: false),
                          const SizedBox(height: 4),
                          const AppText(
                            'Shift will be active and assignable',
                            fontSize: 12,
                            color: AppColors.textColorHint,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _isActive ? AppColors.successColor.withValues(alpha: 0.1) : AppColors.slate100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 4,
                                backgroundColor: _isActive ? AppColors.successColor : AppColors.textColorHint,
                              ),
                              const SizedBox(width: 6),
                              AppText(
                                _isActive ? 'Active' : 'Inactive',
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _isActive ? AppColors.successColor : AppColors.textColorSecondary,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        CupertinoSwitch(
                          value: _isActive,
                          activeTrackColor: AppColors.primaryColor,
                          onChanged: (val) => setState(() => _isActive = val),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                _buildFieldLabel('Description', isRequired: false),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  style: const TextStyle(fontSize: 14, color: AppColors.textColorPrimary),
                  decoration: InputDecoration(
                    hintText: 'Morning working shift for sales and operations team...',
                    hintStyle: const TextStyle(color: AppColors.textColorHint, fontSize: 13),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.slate200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.slate200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // STEP 2: Shift Timing & Attendance Rules
  // ----------------------------------------------------
  Widget _buildStep2ShiftTiming() {
    final workingHoursText = _calculateWorkingHours(_startTime, _endTime, _crossMidnight);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            stepNumber: '2',
            title: 'Timing & Attendance Rules',
            subtitle: 'Define shift timings, punctuality rules, and working hours.',
          ),
          _buildCardContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  key: _timingKey,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('Start Time', isRequired: true),
                          const SizedBox(height: 8),
                          _buildTimePickerWidget(
                            time: _startTime,
                            onTimePicked: (newTime) {
                              setState(() {
                                _startTime = newTime;
                                for (var day in _weeklySchedule) {
                                  day.startTime = newTime;
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('End Time', isRequired: true),
                          const SizedBox(height: 8),
                          _buildTimePickerWidget(
                            time: _endTime,
                            onTimePicked: (newTime) {
                              setState(() {
                                _endTime = newTime;
                                for (var day in _weeklySchedule) {
                                  day.endTime = newTime;
                                }
                                _otStartsAfterController.text = _formatTimeOfDay(newTime);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Cross Midnight Checkbox/Switch
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.slate50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.slate200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Iconsax.moon, size: 20, color: AppColors.primaryColor),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  AppText('Cross Midnight', fontSize: 13, fontWeight: FontWeight.bold),
                                  AppText(
                                    'Shift extends to the next calendar day',
                                    fontSize: 11,
                                    color: AppColors.textColorHint,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      CupertinoSwitch(
                        value: _crossMidnight,
                        activeTrackColor: AppColors.primaryColor,
                        onChanged: (val) => setState(() => _crossMidnight = val),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Working Hours (Field with auto-calculated value)
                _buildFieldLabel('Working Hours', isRequired: false),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.slate50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.slate200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Iconsax.timer_1, size: 18, color: AppColors.primaryColor),
                      const SizedBox(width: 10),
                      AppText(
                        workingHoursText,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const AppText(
                          'Auto-Calculated',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                const Divider(color: AppColors.slate200, height: 1),
                const SizedBox(height: 20),

                // Attendance Rules Header inside Card
                const AppText(
                  'Attendance Rules & Punctuality',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColorPrimary,
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('Grace Period', isRequired: false),
                          const SizedBox(height: 8),
                          _buildDropdownField<String>(
                            value: _gracePeriod,
                            items: _gracePeriodOptions,
                            onChanged: (val) {
                              if (val != null) setState(() => _gracePeriod = val);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('Late After', isRequired: false),
                          const SizedBox(height: 8),
                          _buildDropdownField<String>(
                            value: _lateAfter,
                            items: _lateAfterOptions,
                            onChanged: (val) {
                              if (val != null) setState(() => _lateAfter = val);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Rule Toggles List
                _buildToggleRow(
                  title: 'Early Leaving Allowed',
                  subtitle: 'Permit employees to punch out slightly before shift ends',
                  value: _earlyLeavingAllowed,
                  onChanged: (val) => setState(() => _earlyLeavingAllowed = val),
                ),
                const Divider(height: 24, color: AppColors.slate200),

                _buildToggleRow(
                  title: 'Auto Mark Late',
                  subtitle: 'Automatically flag attendance as late if check-in exceeds grace time',
                  value: _autoMarkLate,
                  onChanged: (val) => setState(() => _autoMarkLate = val),
                ),
                const Divider(height: 24, color: AppColors.slate200),

                _buildToggleRow(
                  title: 'Auto Mark Half Day',
                  subtitle: 'Trigger half-day status if minimum work hours are not fulfilled',
                  value: _autoMarkHalfDay,
                  onChanged: (val) => setState(() => _autoMarkHalfDay = val),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('Late Threshold', isRequired: false),
                          const SizedBox(height: 8),
                          _buildDropdownField<String>(
                            value: _lateThreshold,
                            items: _lateThresholdOptions,
                            onChanged: (val) {
                              if (val != null) setState(() => _lateThreshold = val);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('Half Day After', isRequired: false),
                          const SizedBox(height: 8),
                          _buildDropdownField<String>(
                            value: _halfDayAfter,
                            items: _halfDayOptions,
                            onChanged: (val) {
                              if (val != null) setState(() => _halfDayAfter = val);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // STEP 3: Break Settings (Panel 4)
  // ----------------------------------------------------
  Widget _buildStep3BreakSettings() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            stepNumber: '3',
            title: 'Break Settings',
            subtitle: 'Configure allotted break periods, lunch durations, and paid/unpaid statuses.',
            trailing: Row(
              children: [
                const AppText('Enable Break', fontSize: 13, fontWeight: FontWeight.bold),
                const SizedBox(width: 8),
                CupertinoSwitch(
                  value: _enableBreak,
                  activeTrackColor: AppColors.primaryColor,
                  onChanged: (val) => setState(() => _enableBreak = val),
                ),
              ],
            ),
          ),
          _buildCardContainer(
            key: _breaksKey,
            child: _enableBreak
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Break Name & Break Type
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildFieldLabel('Break Name', isRequired: true),
                                const SizedBox(height: 8),
                                _buildTextInput(
                                  controller: _breakNameController,
                                  hint: 'e.g. Lunch Break / Tea Break',
                                  prefixIcon: Iconsax.coffee,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildFieldLabel('Break Type', isRequired: true),
                                const SizedBox(height: 8),
                                _buildDropdownField<String>(
                                  value: _breakType,
                                  items: const ['Paid', 'Unpaid'],
                                  onChanged: (val) {
                                    if (val != null) setState(() => _breakType = val);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // Break Start & End
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildFieldLabel('Break Start', isRequired: true),
                                const SizedBox(height: 8),
                                _buildTimePickerWidget(
                                  time: _breakStartTime,
                                  onTimePicked: (newTime) => setState(() => _breakStartTime = newTime),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildFieldLabel('Break End', isRequired: true),
                                const SizedBox(height: 8),
                                _buildTimePickerWidget(
                                  time: _breakEndTime,
                                  onTimePicked: (newTime) => setState(() => _breakEndTime = newTime),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Calculated duration display preview
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.slate50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.slate200),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Iconsax.timer_1, size: 16, color: AppColors.primaryColor),
                            const SizedBox(width: 6),
                            AppText(
                              'Calculated Duration: ${_calculateBreakDuration(_breakStartTime, _breakEndTime)}',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textColorSecondary,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Add Break Button
                      OutlinedButton.icon(
                        onPressed: () {
                          final name = _breakNameController.text.trim();
                          if (name.isEmpty) {
                            CustomSnackbar.showError('Please enter break name');
                            return;
                          }
                          final calculatedDuration = _calculateBreakDuration(_breakStartTime, _breakEndTime);
                          setState(() {
                            _breaks.add(
                              BreakItem(
                                name: name,
                                type: _breakType,
                                duration: calculatedDuration,
                                startTime: _breakStartTime,
                                endTime: _breakEndTime,
                              ),
                            );
                            _breakNameController.clear();
                          });
                          Get.snackbar(
                            'Break Added',
                            '$name ($calculatedDuration) added to this shift.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.black87,
                            colorText: Colors.white,
                            duration: const Duration(seconds: 2),
                          );
                        },
                        icon: const Icon(Icons.add_circle_outline, size: 18, color: AppColors.primaryColor),
                        label: const AppText('+ Add Break', fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          side: const BorderSide(color: AppColors.primaryColor),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Added Breaks List
                      if (_breaks.isNotEmpty) ...[
                        const AppText('Configured Breaks', fontSize: 13, fontWeight: FontWeight.bold),
                        const SizedBox(height: 12),
                        ..._breaks.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final b = entry.value;
                          final isPaid = b.type == 'Paid';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.slate50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.slate200),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isPaid ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Iconsax.coffee,
                                    size: 20,
                                    color: isPaid ? Colors.green : Colors.orange,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          AppText(b.name, fontSize: 13, fontWeight: FontWeight.bold),
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: isPaid ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: AppText(
                                              b.type,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: isPaid ? Colors.green : Colors.orange,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      AppText(
                                        '${_formatTimeOfDay(b.startTime)} - ${_formatTimeOfDay(b.endTime)} (${b.duration})',
                                        fontSize: 12,
                                        color: AppColors.textColorSecondary,
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Iconsax.trash, size: 18, color: Colors.redAccent),
                                  onPressed: () {
                                    setState(() {
                                      _breaks.removeAt(idx);
                                    });
                                  },
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ],
                  )
                : Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Column(
                        children: const [
                          Icon(Iconsax.info_circle, size: 36, color: AppColors.textColorHint),
                          SizedBox(height: 8),
                          AppText(
                            'Breaks are disabled for this shift.',
                            fontSize: 13,
                            color: AppColors.textColorHint,
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // STEP 4: Overtime Settings (Panel 5)
  // ----------------------------------------------------
  Widget _buildStep5OvertimeSettings() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            stepNumber: '4',
            title: 'Overtime Settings',
            subtitle: 'Define conditions and pay multipliers for additional hours worked beyond regular schedule.',
            trailing: Row(
              children: [
                const AppText('Enable Overtime', fontSize: 13, fontWeight: FontWeight.bold),
                const SizedBox(width: 8),
                CupertinoSwitch(
                  value: _enableOvertime,
                  activeTrackColor: AppColors.primaryColor,
                  onChanged: (val) => setState(() => _enableOvertime = val),
                ),
              ],
            ),
          ),
          _buildCardContainer(
            child: _enableOvertime
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildFieldLabel('OT Starts After', isRequired: true),
                                const SizedBox(height: 8),
                                _buildTextInput(
                                  controller: _otStartsAfterController,
                                  hint: 'e.g. 06:00 PM',
                                  prefixIcon: Iconsax.clock,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildFieldLabel('Minimum OT (Minutes)', isRequired: true),
                                const SizedBox(height: 8),
                                _buildTextInput(
                                  controller: _minimumOTController,
                                  hint: 'e.g. 30',
                                  prefixIcon: Iconsax.timer_1,
                                  keyboardType: TextInputType.number,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      _buildFieldLabel('OT Calculation', isRequired: true),
                      const SizedBox(height: 8),
                      _buildDropdownField<String>(
                        value: _otCalculation,
                        items: _otCalculationOptions,
                        onChanged: (val) {
                          if (val != null) setState(() => _otCalculation = val);
                        },
                      ),

                      const SizedBox(height: 20),

                      _buildToggleRow(
                        title: 'Approval Required',
                        subtitle: 'Overtime compensation requires team lead or manager sign-off',
                        value: _approvalRequired,
                        onChanged: (val) => setState(() => _approvalRequired = val),
                      ),
                    ],
                  )
                : Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Column(
                        children: const [
                          Icon(Iconsax.clock, size: 36, color: AppColors.textColorHint),
                          SizedBox(height: 8),
                          AppText(
                            'Overtime tracking is disabled for this shift.',
                            fontSize: 13,
                            color: AppColors.textColorHint,
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // STEP 5: Weekly Schedule (Panel 6)
  // ----------------------------------------------------
  Widget _buildStep6WeeklySchedule() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            stepNumber: '5',
            title: 'Weekly Schedule',
            subtitle: 'Specify active working days and customize timings for weekends or specific shifts.',
            trailing: TextButton.icon(
              onPressed: () {
                setState(() {
                  for (int i = 0; i < _weeklySchedule.length; i++) {
                    if (i < 5) {
                      _weeklySchedule[i].isWorking = true;
                      _weeklySchedule[i].startTime = _startTime;
                      _weeklySchedule[i].endTime = _endTime;
                    }
                  }
                });
                Get.snackbar(
                  'Applied',
                  'Standard shift timing applied to all weekdays (Mon-Fri).',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.black87,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 2),
                );
              },
              icon: const Icon(Iconsax.refresh, size: 14, color: AppColors.primaryColor),
              label: const AppText('Apply Weekdays', fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                backgroundColor: AppColors.primaryLight,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          _buildCardContainer(
            key: _scheduleKey,
            child: Column(
              children: [
                // Day Rows
                ..._weeklySchedule.map((schedule) {
                  final isWorking = schedule.isWorking;

                  final isAltOff = _enableAlternateOff && schedule.dayName == _alternateOffDay;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: isWorking ? Colors.white : AppColors.slate50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isAltOff
                            ? const Color(0xFFFDE68A)
                            : isWorking
                                ? AppColors.slate200
                                : AppColors.slate200.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Working Toggle
                            Transform.scale(
                              scale: 0.8,
                              child: CupertinoSwitch(
                                value: isWorking,
                                activeTrackColor: AppColors.primaryColor,
                                onChanged: (val) {
                                  setState(() {
                                    schedule.isWorking = val;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 6),

                            // Day Name
                            Expanded(
                              child: AppText(
                                schedule.dayName,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isWorking ? AppColors.textColorPrimary : AppColors.textColorHint,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),

                            // Status Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                              decoration: BoxDecoration(
                                color: isAltOff
                                    ? const Color(0xFFF59E0B).withValues(alpha: 0.12)
                                    : isWorking
                                        ? AppColors.successColor.withValues(alpha: 0.1)
                                        : AppColors.slate200,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: AppText(
                                isAltOff
                                    ? 'Alt Off ($_selectedAlternateWeek)'
                                    : isWorking
                                        ? 'Working'
                                        : 'Weekly Off',
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                color: isAltOff
                                    ? const Color(0xFFD97706)
                                    : isWorking
                                        ? AppColors.successColor
                                        : AppColors.textColorSecondary,
                              ),
                            ),
                          ],
                        ),

                        // Shift Timing Row (Clickable if working)
                        if (isWorking) ...[
                          const SizedBox(height: 8),
                          InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () async {
                              _showCustomDayTimingDialog(schedule);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.slate50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.slate200),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Iconsax.clock, size: 13, color: AppColors.primaryColor),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: AppText(
                                      '${_formatTimeOfDay(schedule.startTime)} - ${_formatTimeOfDay(schedule.endTime)}',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textColorPrimary,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.edit_outlined, size: 12, color: AppColors.textColorHint),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 16),
                const Divider(color: AppColors.slate200, height: 1),
                const SizedBox(height: 16),

                // ── Alternate Off Day Setting Card ──
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _enableAlternateOff ? const Color(0xFFFEF3C7).withValues(alpha: 0.3) : AppColors.slate50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _enableAlternateOff ? const Color(0xFFFDE68A) : AppColors.slate200,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _enableAlternateOff ? const Color(0xFFF59E0B).withValues(alpha: 0.15) : AppColors.slate200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Iconsax.calendar_tick,
                              size: 18,
                              color: _enableAlternateOff ? const Color(0xFFD97706) : AppColors.textColorSecondary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const AppText(
                                  'Alternate Off Day',
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                                const SizedBox(height: 2),
                                AppText(
                                  _enableAlternateOff
                                      ? '$_alternateOffDay is off on $_selectedAlternateWeek weeks'
                                      : 'Configure alternating weekly offs (e.g. 2nd & 4th Saturday)',
                                  fontSize: 11,
                                  color: AppColors.textColorHint,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Transform.scale(
                            scale: 0.85,
                            child: CupertinoSwitch(
                              value: _enableAlternateOff,
                              activeTrackColor: const Color(0xFFF59E0B),
                              onChanged: (val) {
                                setState(() {
                                  _enableAlternateOff = val;
                                  if (val) {
                                    // Automatically mark the alternate day as working base so it can be enabled
                                    final dayIdx = _weeklySchedule.indexWhere((d) => d.dayName == _alternateOffDay);
                                    if (dayIdx != -1) {
                                      _weeklySchedule[dayIdx].isWorking = true;
                                    }
                                  }
                                });
                              },
                            ),
                          ),
                        ],
                      ),

                      if (_enableAlternateOff) ...[
                        const SizedBox(height: 16),
                        const Divider(color: Color(0xFFFDE68A), height: 1),
                        const SizedBox(height: 14),

                        // Select Day Chips
                        const AppText('Select Day for Alternate Off:', fontSize: 12, fontWeight: FontWeight.bold),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _weekDaysList.map((day) {
                            final isSelected = _alternateOffDay == day;
                            return InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: () {
                                setState(() {
                                  _alternateOffDay = day;
                                  final dayIdx = _weeklySchedule.indexWhere((d) => d.dayName == day);
                                  if (dayIdx != -1) {
                                    _weeklySchedule[dayIdx].isWorking = true;
                                  }
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFFF59E0B) : Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFFF59E0B) : AppColors.slate300,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: const Color(0xFFF59E0B).withValues(alpha: 0.25),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: AppText(
                                  day,
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? Colors.white : AppColors.textColorPrimary,
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 16),

                        // Select Alternate Pattern (2nd & 4th vs 1st & 3rd)
                        const AppText('Alternate Off Pattern:', fontSize: 12, fontWeight: FontWeight.bold),
                        const SizedBox(height: 10),
                        Row(
                          children: _alternateWeeks.map((pattern) {
                            final isSelected = _selectedAlternateWeek == pattern;
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(10),
                                  onTap: () {
                                    setState(() {
                                      _selectedAlternateWeek = pattern;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                      color: isSelected ? const Color(0xFFF59E0B) : Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isSelected ? const Color(0xFFF59E0B) : AppColors.slate300,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: AppText(
                                      '$pattern Week Off',
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                      color: isSelected ? Colors.white : AppColors.textColorPrimary,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFFDE68A)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFFD97706)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: AppText(
                                  'Employees will work on odd weeks (1st, 3rd, 5th $_alternateOffDay) and get off on $_selectedAlternateWeek $_alternateOffDay.',
                                  fontSize: 11,
                                  color: const Color(0xFF92400E),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showCustomDayTimingDialog(DaySchedule schedule) {
    TimeOfDay tempStart = schedule.startTime;
    TimeOfDay tempEnd = schedule.endTime;

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText('Set Hours for ${schedule.dayName}', fontSize: 16, fontWeight: FontWeight.bold),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const AppText('Start Time', fontSize: 12, fontWeight: FontWeight.bold),
                          const SizedBox(height: 6),
                          _buildTimePickerWidget(
                            time: tempStart,
                            onTimePicked: (t) => setModalState(() => tempStart = t),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const AppText('End Time', fontSize: 12, fontWeight: FontWeight.bold),
                          const SizedBox(height: 6),
                          _buildTimePickerWidget(
                            time: tempEnd,
                            onTimePicked: (t) => setModalState(() => tempEnd = t),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        schedule.startTime = tempStart;
                        schedule.endTime = tempEnd;
                      });
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const AppText('Update Hours', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ----------------------------------------------------
  // STEP 6: Employee Assignment (Panel 7)
  // ----------------------------------------------------
  Widget _buildStep7EmployeeAssignment() {
    final filtered = _filteredEmployees;
    final allFilteredSelected = filtered.isNotEmpty && filtered.every((e) => e.isSelected);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            stepNumber: '6',
            title: 'Assign Employees',
            subtitle: 'Select workforce members to be initially assigned to this newly created shift.',
          ),
          _buildCardContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                _buildTextInput(
                  controller: _searchEmployeeController,
                  hint: 'Search employee by name or designation...',
                  prefixIcon: Iconsax.search_normal,
                  onChanged: (_) => setState(() {}),
                ),

                const SizedBox(height: 14),

                // Department & Designation Filters (Reactive with real data only)
                Obx(() {
                  final deptCtrl = Get.isRegistered<DepartmentsController>()
                      ? Get.find<DepartmentsController>()
                      : null;
                  final desigCtrl = Get.isRegistered<DesignationController>()
                      ? Get.find<DesignationController>()
                      : null;
                  // Observe list changes
                  final _ = (deptCtrl?.apiDepartments.length ?? 0) +
                      (deptCtrl?.departments.length ?? 0) +
                      (desigCtrl?.designations.length ?? 0);
                  _loadDepartmentsAndDesignations();

                  return Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const AppText('Department', fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textColorSecondary),
                            const SizedBox(height: 6),
                            _buildDropdownField<String>(
                              value: _selectedDepartment,
                              items: _departments,
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedDepartment = val);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const AppText('Designation', fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textColorSecondary),
                            const SizedBox(height: 6),
                            _buildDropdownField<String>(
                              value: _selectedDesignation,
                              items: _designations,
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedDesignation = val);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),

                const SizedBox(height: 20),

                // Select All Bar & Counter
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.slate50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.slate200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Checkbox(
                              value: allFilteredSelected,
                              activeColor: AppColors.primaryColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              onChanged: (val) {
                                setState(() {
                                  for (var e in filtered) {
                                    e.isSelected = val ?? false;
                                  }
                                });
                              },
                            ),
                            Flexible(
                              child: AppText(
                                'Select All (${filtered.length})',
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: AppText(
                          'Selected: $_selectedEmployeesCount',
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Employee List
                if (filtered.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: Center(
                      child: Column(
                        children: const [
                          Icon(Iconsax.user_search, size: 36, color: AppColors.textColorHint),
                          SizedBox(height: 8),
                          AppText('No matching employees found', fontSize: 13, color: AppColors.textColorHint),
                        ],
                      ),
                    ),
                  )
                else
                  ...filtered.map((emp) {
                    final isAssigned = emp.status == 'Assigned';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: emp.isSelected ? AppColors.primaryColor.withValues(alpha: 0.5) : AppColors.slate200,
                          width: emp.isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Checkbox(
                            value: emp.isSelected,
                            activeColor: AppColors.primaryColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            onChanged: (val) {
                              setState(() {
                                emp.isSelected = val ?? false;
                              });
                            },
                          ),
                          const SizedBox(width: 2),
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.primaryColor.withValues(alpha: 0.12),
                            child: AppText(
                              emp.name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join(),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AppText(
                                  emp.name,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Wrap(
                                  spacing: 4,
                                  runSpacing: 4,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    if (emp.department.isNotEmpty)
                                      Container(
                                        constraints: const BoxConstraints(maxWidth: 100),
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                        decoration: BoxDecoration(
                                          color: AppColors.slate100,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: AppText(
                                          emp.department,
                                          fontSize: 10,
                                          color: AppColors.textColorSecondary,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    if (emp.designation.isNotEmpty)
                                      Container(
                                        constraints: const BoxConstraints(maxWidth: 110),
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryLight,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: AppText(
                                          emp.designation,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primaryColor,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            constraints: const BoxConstraints(maxWidth: 80),
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                            decoration: BoxDecoration(
                              color: isAssigned ? Colors.green.withValues(alpha: 0.1) : AppColors.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: AppText(
                              emp.status,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              color: isAssigned ? Colors.green : AppColors.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // Bottom Action Bar
  // ----------------------------------------------------
  Widget _buildBottomBar() {
    final isLastStep = _currentStep == _totalSteps - 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (_currentStep > 0) ...[
              Expanded(
                flex: 1,
                child: OutlinedButton(
                  onPressed: () => _goToStep(_currentStep - 1),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppColors.slate300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const AppText('Back', fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textColorSecondary),
                ),
              ),
              const SizedBox(width: 14),
            ],
            Expanded(
              flex: 2,
              child: Obx(() {
                final ctrl = Get.isRegistered<ShiftController>()
                    ? Get.find<ShiftController>()
                    : Get.put(ShiftController());
                final isSubmitting = ctrl.isSubmitting.value;

                return ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (isLastStep) {
                            if (!_validateAllShiftSteps()) {
                              return;
                            }

                            final request = CreateShiftRequestModel(
                              name: _shiftNameController.text.trim(),
                              code: _shiftCodeController.text.trim().isNotEmpty
                                  ? _shiftCodeController.text.trim()
                                  : 'SHIFT',
                              shiftType: _shiftType,
                              status: _isActive,
                              description: _descriptionController.text.trim(),
                              startTime: _formatTimeOfDay(_startTime),
                              endTime: _formatTimeOfDay(_endTime),
                              crossMidnight: _crossMidnight,
                              breaksEnabled: _enableBreak,
                              breaks: _breaks
                                  .map((b) => ShiftBreakRequestModel(
                                        name: b.name,
                                        type: b.type,
                                        startTime: _formatTimeOfDay(b.startTime),
                                        endTime: _formatTimeOfDay(b.endTime),
                                      ))
                                  .toList(),
                              gracePeriodMinutes: _parseDurationToMinutes(_gracePeriod, defaultValue: 15),
                              lateAfterMinutes: _parseDurationToMinutes(_lateAfter, defaultValue: 15),
                              minimumWorkingMinutes: _parseDurationToMinutes(_minWorkingHours, defaultValue: 480),
                              earlyLeavingAllowed: _earlyLeavingAllowed,
                              autoMarkLate: _autoMarkLate,
                              autoMarkHalfDay: _autoMarkHalfDay,
                              lateThresholdMinutes: _parseDurationToMinutes(_lateThreshold, defaultValue: 30),
                              halfDayAfterMinutes: _parseDurationToMinutes(_halfDayAfter, defaultValue: 240),
                              overtimeEnabled: _enableOvertime,
                              overtimeStartsAfterMinutes: _parseDurationToMinutes(_otStartsAfterController.text.trim(), defaultValue: _parseDurationToMinutes(_formatTimeOfDay(_endTime), defaultValue: 480)),
                              minimumOvertimeMinutes: _parseDurationToMinutes(_minimumOTController.text.trim(), defaultValue: 30),
                              overtimeCalculation: _otCalculation,
                              overtimeApprovalRequired: _approvalRequired,
                              workingDays: _weeklySchedule
                                  .map((d) => ShiftWorkingDayRequestModel(
                                        day: d.dayName,
                                        enabled: d.isWorking,
                                        startTime:
                                            '${d.startTime.hour.toString().padLeft(2, '0')}:${d.startTime.minute.toString().padLeft(2, '0')}',
                                        endTime:
                                            '${d.endTime.hour.toString().padLeft(2, '0')}:${d.endTime.minute.toString().padLeft(2, '0')}',
                                      ))
                                  .toList(),
                              employeeIds: _allEmployees
                                  .where((e) => e.isSelected)
                                  .map((e) => int.tryParse(e.id) ?? 0)
                                  .where((id) => id > 0)
                                  .toList(),
                            );

                            if (_isEditing && _shiftId.isNotEmpty) {
                              final res = await ctrl.updateShiftApi(_shiftId, request);
                              if (res.status) {
                                Get.back(result: true);
                                CustomSnackbar.showSuccess(
                                  res.message.isNotEmpty ? res.message : 'Shift updated successfully.',
                                );
                              } else {
                                final err = res.message.isNotEmpty ? res.message : 'Failed to update shift.';
                                CustomSnackbar.showError(err);
                                _handleShiftApiError(err);
                              }
                            } else {
                              final res = await ctrl.createShiftApi(request);
                              if (res.status) {
                                Get.back(result: true);
                                CustomSnackbar.showSuccess(
                                  res.message.isNotEmpty ? res.message : 'Shift created successfully.',
                                );
                              } else {
                                final err = res.message.isNotEmpty ? res.message : 'Failed to create shift.';
                                CustomSnackbar.showError(err);
                                _handleShiftApiError(err);
                              }
                            }
                          } else {
                            if (!_validateShiftStep(_currentStep)) {
                              return;
                            }
                            _goToStep(_currentStep + 1);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AppText(
                              isLastStep
                                  ? (_isEditing ? 'Save & Update Shift' : 'Save & Create Shift')
                                  : 'Save & Continue',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              isLastStep ? Icons.check_circle_outline : Icons.arrow_forward_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                          ],
                        ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // Reusable UI Components
  // ----------------------------------------------------
  Widget _buildCardContainer({
    Key? key,
    required Widget child,
  }) {
    return Container(
      key: key,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: child,
    );
  }

  Widget _buildFieldLabel(String text, {bool isRequired = false}) {
    return Row(
      children: [
        AppText(text, fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
        if (isRequired) ...[
          const SizedBox(width: 4),
          const AppText('*', fontSize: 13, fontWeight: FontWeight.bold, color: Colors.red),
        ],
      ],
    );
  }

  Widget _buildTextInput({
    Key? key,
    FocusNode? focusNode,
    required TextEditingController controller,
    required String hint,
    IconData? prefixIcon,
    ValueChanged<String>? onChanged,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      key: key,
      focusNode: focusNode,
      controller: controller,
      onChanged: onChanged,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textColorPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textColorHint, fontSize: 13),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 18, color: AppColors.textColorSecondary) : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.slate200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.slate200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildDropdownField<T>({
    Key? key,
    required T? value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    String? hintText,
  }) {
    final hasItems = items.isNotEmpty;
    final validValue = items.contains(value) ? value : (hasItems ? items.first : null);
    final effectiveHint = hintText ?? (hasItems ? 'Select' : 'No options available');

    return Container(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.slate200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: validValue,
          isExpanded: true,
          hint: Text(effectiveHint, style: const TextStyle(fontSize: 13, color: AppColors.textColorHint)),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textColorSecondary),
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textColorPrimary),
          onChanged: hasItems ? onChanged : null,
          items: items.map((T item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(
                item.toString(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTimePickerWidget({
    required TimeOfDay time,
    required ValueChanged<TimeOfDay> onTimePicked,
  }) {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time,
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: AppColors.primaryColor,
                  onPrimary: Colors.white,
                  onSurface: AppColors.textColorPrimary,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          onTimePicked(picked);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.slate200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppText(_formatTimeOfDay(time), fontSize: 13, fontWeight: FontWeight.w600),
            const Icon(Iconsax.clock, color: AppColors.primaryColor, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleRow({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(title, fontSize: 13, fontWeight: FontWeight.bold),
              const SizedBox(height: 2),
              AppText(subtitle, fontSize: 11, color: AppColors.textColorSecondary),
            ],
          ),
        ),
        const SizedBox(width: 12),
        CupertinoSwitch(
          value: value,
          activeTrackColor: AppColors.primaryColor,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
