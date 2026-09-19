import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../employee/management/controllers/employee_controller.dart';
import '../controllers/shift_controller.dart';
import '../models/shift_model.dart';
import '../models/shift_response_model.dart';

class AssignShiftScreen extends StatefulWidget {
  final ShiftModel? preSelectedShift;
  final ShiftDataModel? preSelectedShiftData;

  const AssignShiftScreen({
    super.key,
    this.preSelectedShift,
    this.preSelectedShiftData,
  });

  @override
  State<AssignShiftScreen> createState() => _AssignShiftScreenState();
}

class _AssignShiftScreenItem {
  final int id;
  final String name;
  final String designation;
  final String department;
  bool isSelected;

  _AssignShiftScreenItem({
    required this.id,
    required this.name,
    required this.designation,
    required this.department,
    this.isSelected = false,
  });
}

class _AssignShiftScreenState extends State<AssignShiftScreen> {
  final TextEditingController _searchController = TextEditingController();
  late final ShiftController _shiftController;

  ShiftModel? _selectedShift;
  List<_AssignShiftScreenItem> _employees = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _shiftController = Get.isRegistered<ShiftController>()
        ? Get.find<ShiftController>()
        : Get.put(ShiftController());

    _initShift();
    _initEmployees();
  }

  void _initShift() {
    if (widget.preSelectedShift != null) {
      _selectedShift = widget.preSelectedShift;
    } else if (widget.preSelectedShiftData != null) {
      _selectedShift = ShiftModel.fromDataModel(widget.preSelectedShiftData!);
    } else if (_shiftController.shifts.isNotEmpty) {
      _selectedShift = _shiftController.shifts.first;
    } else {
      _selectedShift = ShiftModel(
        id: '2',
        name: 'Morning Shift',
        code: 'MORNING',
        type: 'Fixed Shift',
        isActive: true,
        description: 'Morning working shift for sales and operations team.',
        startTime: '10:00 AM',
        endTime: '07:00 PM',
        crossMidnight: false,
        workingHours: '8h 00m',
        enableBreak: true,
        breakType: 'Paid',
        breakDuration: '01:00',
        gracePeriod: '15 min',
        lateAfter: '15 min',
        minWorkingHours: '8h 00m',
        earlyLeavingAllowed: false,
        autoMarkLate: true,
        autoMarkHalfDay: true,
        lateThreshold: '45 min',
        halfDayAfter: '4h 00m',
        enableOvertime: true,
        otStartsAfter: '8h 00m',
        minimumOT: '30 min',
        otCalculation: 'Hourly',
        approvalRequired: true,
        employeesCount: 0,
        icon: Icons.wb_sunny_outlined,
        iconColor: Colors.orange,
        assignedEmployeeNames: [],
      );
    }
  }

  void _initEmployees() {
    final List<_AssignShiftScreenItem> list = [];

    // Check if EmployeeController is registered with real/mock employees
    if (Get.isRegistered<EmployeeController>()) {
      final empCtrl = Get.find<EmployeeController>();
      if (empCtrl.employees.isNotEmpty) {
        for (var i = 0; i < empCtrl.employees.length; i++) {
          final emp = empCtrl.employees[i];
          final parsedId = int.tryParse(emp.id) ?? (i + 1);
          list.add(
            _AssignShiftScreenItem(
              id: parsedId,
              name: emp.name,
              designation: emp.designation,
              department: emp.department,
              isSelected: _isEmployeePreAssigned(parsedId, emp.name),
            ),
          );
        }
      }
    }

    // Default fallback employee list if empty
    if (list.isEmpty) {
      final defaults = [
        {'id': 1, 'name': 'Rahul Sharma', 'designation': 'UI/UX Designer', 'department': 'Design', 'selected': true},
        {'id': 2, 'name': 'Neha Singh', 'designation': 'HR Executive', 'department': 'Human Resources', 'selected': true},
        {'id': 3, 'name': 'Amit Kumar', 'designation': 'Marketing Executive', 'department': 'Marketing', 'selected': false},
        {'id': 4, 'name': 'Vikram Joshi', 'designation': 'Backend Developer', 'department': 'Engineering', 'selected': false},
        {'id': 5, 'name': 'Sneha Patel', 'designation': 'Frontend Developer', 'department': 'Engineering', 'selected': false},
        {'id': 6, 'name': 'Sameer Khan', 'designation': 'QA Engineer', 'department': 'Quality Assurance', 'selected': false},
        {'id': 7, 'name': 'Pooja Verma', 'designation': 'Operations Lead', 'department': 'Operations', 'selected': false},
      ];

      for (final d in defaults) {
        final id = d['id'] as int;
        final name = d['name'] as String;
        list.add(
          _AssignShiftScreenItem(
            id: id,
            name: name,
            designation: d['designation'] as String,
            department: d['department'] as String,
            isSelected: _isEmployeePreAssigned(id, name) || (d['selected'] as bool),
          ),
        );
      }
    }

    setState(() {
      _employees = list;
    });
  }

  bool _isEmployeePreAssigned(int id, String name) {
    if (widget.preSelectedShiftData != null && widget.preSelectedShiftData!.assignedEmployees.isNotEmpty) {
      final exists = widget.preSelectedShiftData!.assignedEmployees.any(
        (emp) => emp.id == id || emp.name.toLowerCase() == name.toLowerCase(),
      );
      if (exists) return true;
    }
    if (widget.preSelectedShift != null && widget.preSelectedShift!.assignedEmployeeNames.isNotEmpty) {
      return widget.preSelectedShift!.assignedEmployeeNames.contains(name);
    }
    return false;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_AssignShiftScreenItem> get _filteredEmployees {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _employees;
    return _employees.where((emp) {
      final name = emp.name.toLowerCase();
      final desig = emp.designation.toLowerCase();
      final dept = emp.department.toLowerCase();
      return name.contains(query) || desig.contains(query) || dept.contains(query);
    }).toList();
  }

  int get _selectedCount => _employees.where((e) => e.isSelected).length;

  void _showShiftSelectionModal() {
    final availableShifts = _shiftController.shifts.isNotEmpty
        ? _shiftController.shifts.toList()
        : (_selectedShift != null ? [_selectedShift!] : <ShiftModel>[]);

    Get.bottomSheet(
      Container(
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
                const AppText('Select Shift to Assign', fontSize: 16, fontWeight: FontWeight.bold),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (availableShifts.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: AppText('No shifts available', fontSize: 13, color: AppColors.textColorHint),
                ),
              )
            else
              ...availableShifts.map((shift) {
                final isChosen = _selectedShift?.id == shift.id;
                final Color shiftColor = shift.iconColor;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: isChosen ? shiftColor.withValues(alpha: 0.08) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isChosen ? shiftColor : AppColors.slate200,
                      width: isChosen ? 1.5 : 1,
                    ),
                  ),
                  child: ListTile(
                    onTap: () {
                      setState(() => _selectedShift = shift);
                      Get.back();
                    },
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: shiftColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(shift.icon, color: shiftColor, size: 20),
                    ),
                    title: AppText(shift.name, fontSize: 14, fontWeight: FontWeight.bold),
                    subtitle: AppText('${shift.startTime} - ${shift.endTime}', fontSize: 12, color: AppColors.textColorSecondary),
                    trailing: isChosen
                        ? Icon(Icons.check_circle, color: shiftColor, size: 20)
                        : null,
                  ),
                );
              }),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAssignShift() async {
    if (_selectedShift == null) {
      Get.snackbar(
        'No Shift Selected',
        'Please select a shift first.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    final selectedEmployeeIds = _employees
        .where((e) => e.isSelected)
        .map((e) => e.id)
        .toList();

    setState(() => _isLoading = true);

    try {
      final response = await _shiftController.assignShiftApi(
        _selectedShift!.id,
        selectedEmployeeIds,
      );

      if (response.status) {
        Get.back(result: true);
        Get.snackbar(
          'Shift Assigned',
          response.message.isNotEmpty
              ? response.message
              : 'Shift "${_selectedShift!.name}" assigned to ${selectedEmployeeIds.length} employee(s).',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.successColor,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      } else {
        Get.snackbar(
          'Assignment Failed',
          response.message.isNotEmpty ? response.message : 'Could not assign shift. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.errorColor,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredEmployees;
    final allFilteredSelected = filtered.isNotEmpty && filtered.every((e) => e.isSelected);
    final Color currentShiftColor = _selectedShift?.iconColor ?? AppColors.primaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textColorPrimary, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const AppText('Assign Shift', fontSize: 18, fontWeight: FontWeight.bold),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Select Shift Section
                  _buildLabel('Select Shift'),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _showShiftSelectionModal,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.slate200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: currentShiftColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  _selectedShift?.icon ?? Icons.access_time_rounded,
                                  color: currentShiftColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText(
                                    _selectedShift?.name ?? 'Select a shift',
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  const SizedBox(height: 2),
                                  AppText(
                                    _selectedShift != null
                                        ? '${_selectedShift!.startTime} - ${_selectedShift!.endTime}'
                                        : 'Tap to choose',
                                    fontSize: 11,
                                    color: AppColors.textColorSecondary,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textColorSecondary),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Select Employees Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildLabel('Select Employees'),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: AppText(
                          'Selected: $_selectedCount',
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Search Employees
                  TextFormField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(fontSize: 13, color: AppColors.textColorPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search employees by name or designation...',
                      hintStyle: const TextStyle(color: AppColors.textColorHint, fontSize: 13),
                      prefixIcon: const Icon(Iconsax.search_normal, color: AppColors.textColorSecondary, size: 18),
                      filled: true,
                      fillColor: AppColors.slate50,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
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
                        borderSide: const BorderSide(color: AppColors.primaryColor),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Select All Option
                  InkWell(
                    onTap: () {
                      setState(() {
                        final nextState = !allFilteredSelected;
                        for (var e in filtered) {
                          e.isSelected = nextState;
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.slate50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.slate200),
                      ),
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
                          AppText(
                            'Select All (${filtered.length} Employees)',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Employee List
                  if (filtered.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
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
                      final isSelected = emp.isSelected;
                      final name = emp.name;
                      final designation = emp.designation;
                      final department = emp.department;

                      return InkWell(
                        onTap: () {
                          setState(() {
                            emp.isSelected = !isSelected;
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primaryLight.withValues(alpha: 0.4) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? AppColors.primaryColor.withValues(alpha: 0.5) : AppColors.slate200,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
                                child: AppText(
                                  name.split(' ').map((n) => n.isNotEmpty ? n[0] : '').take(2).join(),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppText(name, fontSize: 14, fontWeight: FontWeight.bold),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        AppText(designation, fontSize: 11, color: AppColors.textColorSecondary),
                                        const SizedBox(width: 6),
                                        Container(
                                          width: 3,
                                          height: 3,
                                          decoration: const BoxDecoration(
                                            color: AppColors.textColorHint,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        AppText(department, fontSize: 11, color: AppColors.textColorHint),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Checkbox(
                                value: isSelected,
                                activeColor: AppColors.primaryColor,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                onChanged: (val) {
                                  setState(() {
                                    emp.isSelected = val ?? false;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // Bottom Bar
          Container(
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
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Iconsax.profile_2user, color: AppColors.textColorPrimary, size: 20),
                        const SizedBox(width: 8),
                        AppText('$_selectedCount Selected', fontSize: 13, fontWeight: FontWeight.bold),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleAssignShift,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      disabledBackgroundColor: AppColors.primaryColor.withValues(alpha: 0.6),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const AppText('Assign Shift', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return AppText(text, fontSize: 13, fontWeight: FontWeight.bold);
  }
}
