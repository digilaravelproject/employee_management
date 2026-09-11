import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/shift_controller.dart';
import '../models/shift_model.dart';

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
  final String team;
  final String currentShift;
  final String status; // 'Assigned' or 'Available'
  bool isSelected;

  EmployeeItem({
    required this.id,
    required this.name,
    required this.department,
    required this.team,
    required this.currentShift,
    required this.status,
    this.isSelected = false,
  });
}

class CreateShiftScreen extends StatefulWidget {
  const CreateShiftScreen({super.key});

  @override
  State<CreateShiftScreen> createState() => _CreateShiftScreenState();
}

class _CreateShiftScreenState extends State<CreateShiftScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 7;

  // ----------------------------------------------------
  // Step 1: Basic Information (Panel 2)
  // ----------------------------------------------------
  final TextEditingController _shiftNameController = TextEditingController(text: 'Morning Shift');
  final TextEditingController _shiftCodeController = TextEditingController(text: 'MORNING');
  final TextEditingController _descriptionController = TextEditingController(
    text: 'Morning working shift for sales and operations team...',
  );
  String _shiftType = 'Fixed Shift';
  final List<String> _shiftTypes = ['Fixed Shift', 'Flexible Shift', 'Rotational Shift', 'Night Shift', 'Split Shift'];
  bool _isActive = true;

  // ----------------------------------------------------
  // Step 2: Shift Timing (Panel 3)
  // ----------------------------------------------------
  TimeOfDay _startTime = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 19, minute: 0);
  bool _crossMidnight = false;

  // ----------------------------------------------------
  // Step 3: Break Settings (Panel 4)
  // ----------------------------------------------------
  bool _enableBreak = true;
  final String _newBreakName = 'Lunch Break';
  String _breakType = 'Paid';
  String _breakDuration = '60 Minutes';
  TimeOfDay _breakStartTime = const TimeOfDay(hour: 13, minute: 0);
  TimeOfDay _breakEndTime = const TimeOfDay(hour: 14, minute: 0);
  final List<String> _breakDurations = ['15 Minutes', '30 Minutes', '45 Minutes', '60 Minutes', '90 Minutes'];

  final List<BreakItem> _breaks = [
    BreakItem(
      name: 'Lunch Break',
      type: 'Paid',
      duration: '60 min',
      startTime: const TimeOfDay(hour: 13, minute: 0),
      endTime: const TimeOfDay(hour: 14, minute: 0),
    ),
  ];

  // ----------------------------------------------------
  // Step 4: Attendance Rules (Panel 5)
  // ----------------------------------------------------
  String _gracePeriod = '15 Minutes';
  String _lateAfter = '15 Minutes';
  String _minWorkingHours = '08:00 Hours';
  bool _earlyLeavingAllowed = false;
  bool _autoMarkLate = true;
  bool _autoMarkHalfDay = true;
  String _lateThreshold = '30 Minutes';
  String _halfDayAfter = '04:00 Hours';

  final List<String> _gracePeriodOptions = ['5 Minutes', '10 Minutes', '15 Minutes', '20 Minutes', '30 Minutes'];
  final List<String> _lateAfterOptions = ['5 Minutes', '10 Minutes', '15 Minutes', '20 Minutes', '30 Minutes'];
  final List<String> _minHoursOptions = ['06:00 Hours', '07:00 Hours', '08:00 Hours', '09:00 Hours'];
  final List<String> _lateThresholdOptions = ['15 Minutes', '30 Minutes', '45 Minutes', '60 Minutes'];
  final List<String> _halfDayOptions = ['03:00 Hours', '04:00 Hours', '05:00 Hours', '06:00 Hours'];

  // ----------------------------------------------------
  // Step 5: Overtime Settings (Panel 6)
  // ----------------------------------------------------
  bool _enableOvertime = true;
  String _otStartsAfter = '08:00 Hours';
  String _minimumOT = '30 Minutes';
  String _otCalculation = 'Hourly';
  bool _approvalRequired = true;

  final List<String> _otStartsOptions = ['08:00 Hours', '08:30 Hours', '09:00 Hours', '10:00 Hours'];
  final List<String> _minOtOptions = ['15 Minutes', '30 Minutes', '45 Minutes', '60 Minutes'];
  final List<String> _otCalculationOptions = ['Hourly', 'Daily', '1.5x Hourly Rate', '2x Hourly Rate', 'Flat Stipend'];

  // ----------------------------------------------------
  // Step 6: Weekly Schedule (Panel 7)
  // ----------------------------------------------------
  late List<DaySchedule> _weeklySchedule;

  // ----------------------------------------------------
  // Step 7: Employee Assignment (Panel 8)
  // ----------------------------------------------------
  final TextEditingController _searchEmployeeController = TextEditingController();
  String _selectedDepartment = 'All';
  String _selectedTeam = 'All';
  final List<String> _departments = ['All', 'Sales', 'Support', 'HR', 'Engineering', 'Marketing'];
  final List<String> _teams = ['All', 'Team Alpha', 'Team Beta', 'Core Operations'];

  final List<EmployeeItem> _allEmployees = [
    EmployeeItem(
      id: '1',
      name: 'Rahul Kumar',
      department: 'Sales',
      team: 'Team Alpha',
      currentShift: 'Morning Shift',
      status: 'Assigned',
      isSelected: true,
    ),
    EmployeeItem(
      id: '2',
      name: 'Amit Sharma',
      department: 'Sales',
      team: 'Team Alpha',
      currentShift: 'Morning Shift',
      status: 'Assigned',
      isSelected: true,
    ),
    EmployeeItem(
      id: '3',
      name: 'Arif Khan',
      department: 'Support',
      team: 'Team Beta',
      currentShift: 'No Shift',
      status: 'Available',
      isSelected: false,
    ),
    EmployeeItem(
      id: '4',
      name: 'Sameer Ali',
      department: 'Sales',
      team: 'Team Alpha',
      currentShift: 'Morning Shift',
      status: 'Assigned',
      isSelected: false,
    ),
    EmployeeItem(
      id: '5',
      name: 'Neha Singh',
      department: 'HR',
      team: 'Core Operations',
      currentShift: 'No Shift',
      status: 'Available',
      isSelected: false,
    ),
    EmployeeItem(
      id: '6',
      name: 'Priya Sharma',
      department: 'Engineering',
      team: 'Core Operations',
      currentShift: 'General Shift',
      status: 'Assigned',
      isSelected: false,
    ),
    EmployeeItem(
      id: '7',
      name: 'Vikram Mehta',
      department: 'Support',
      team: 'Team Beta',
      currentShift: 'No Shift',
      status: 'Available',
      isSelected: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _weeklySchedule = [
      DaySchedule(dayName: 'Monday', isWorking: true, startTime: _startTime, endTime: _endTime),
      DaySchedule(dayName: 'Tuesday', isWorking: true, startTime: _startTime, endTime: _endTime),
      DaySchedule(dayName: 'Wednesday', isWorking: true, startTime: _startTime, endTime: _endTime),
      DaySchedule(dayName: 'Thursday', isWorking: true, startTime: _startTime, endTime: _endTime),
      DaySchedule(dayName: 'Friday', isWorking: true, startTime: _startTime, endTime: _endTime),
      DaySchedule(dayName: 'Saturday', isWorking: true, startTime: _startTime, endTime: _endTime),
      DaySchedule(dayName: 'Sunday', isWorking: false, startTime: _startTime, endTime: _endTime),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    _shiftNameController.dispose();
    _shiftCodeController.dispose();
    _descriptionController.dispose();
    _searchEmployeeController.dispose();
    super.dispose();
  }

  // ----------------------------------------------------
  // Helpers
  // ----------------------------------------------------
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

  void _goToStep(int step) {
    if (step < 0 || step >= _totalSteps) return;
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
          emp.department.toLowerCase().contains(query);
      final matchesDept = _selectedDepartment == 'All' || emp.department == _selectedDepartment;
      final matchesTeam = _selectedTeam == 'All' || emp.team == _selectedTeam;
      return matchesQuery && matchesDept && matchesTeam;
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
        title: const AppText('Create New Shift', fontSize: 18, fontWeight: FontWeight.bold),
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
                _buildStep4AttendanceRules(),
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
                  controller: _shiftNameController,
                  hint: 'e.g. Morning Shift',
                  prefixIcon: Iconsax.clock,
                ),

                const SizedBox(height: 20),

                _buildFieldLabel('Shift Code', isRequired: true),
                const SizedBox(height: 8),
                _buildTextInput(
                  controller: _shiftCodeController,
                  hint: 'e.g. MORNING or SHIFT-01',
                  prefixIcon: Iconsax.code,
                ),

                const SizedBox(height: 20),

                _buildFieldLabel('Shift Type', isRequired: true),
                const SizedBox(height: 8),
                _buildDropdownField<String>(
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
                    Column(
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
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _isActive ? AppColors.successColor.withValues(alpha: 0.1) : AppColors.slate100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
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
  // STEP 2: Shift Timing (Panel 3)
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
            title: 'Shift Timing',
            subtitle: 'Define the operational start and end hours for this work shift.',
          ),
          _buildCardContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.indigo.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Iconsax.moon, size: 20, color: Colors.indigo),
                          ),
                          const SizedBox(width: 12),
                          Column(
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
                        ],
                      ),
                      CupertinoSwitch(
                        value: _crossMidnight,
                        activeTrackColor: AppColors.primaryColor,
                        onChanged: (val) => setState(() => _crossMidnight = val),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Working Hours (Auto Calculated) Stat Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryColor.withValues(alpha: 0.08),
                        AppColors.primaryColor.withValues(alpha: 0.02),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryColor.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Iconsax.timer_1, color: Colors.white, size: 26),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const AppText(
                              'Working Hours (Auto Calculated)',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textColorSecondary,
                            ),
                            const SizedBox(height: 4),
                            AppText(
                              workingHoursText,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryColor,
                            ),
                            const SizedBox(height: 2),
                            AppText(
                              '${_formatTimeOfDay(_startTime)} to ${_formatTimeOfDay(_endTime)}${_crossMidnight ? ' (+1 day)' : ''}',
                              fontSize: 11,
                              color: AppColors.textColorHint,
                            ),
                          ],
                        ),
                      ),
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
            child: _enableBreak
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Break Type & Duration
                      Row(
                        children: [
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
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildFieldLabel('Duration', isRequired: true),
                                const SizedBox(height: 8),
                                _buildDropdownField<String>(
                                  value: _breakDuration,
                                  items: _breakDurations,
                                  onChanged: (val) {
                                    if (val != null) setState(() => _breakDuration = val);
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

                      const SizedBox(height: 18),

                      // Add Break Button
                      OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _breaks.add(
                              BreakItem(
                                name: _newBreakName.isEmpty ? 'Break ${_breaks.length + 1}' : _newBreakName,
                                type: _breakType,
                                duration: _breakDuration,
                                startTime: _breakStartTime,
                                endTime: _breakEndTime,
                              ),
                            );
                          });
                          Get.snackbar(
                            'Break Added',
                            'New break period added to this shift.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.black87,
                            colorText: Colors.white,
                            duration: const Duration(seconds: 2),
                          );
                        },
                        icon: const Icon(Icons.add_circle_outline, size: 18, color: AppColors.primaryColor),
                        label: const AppText('+ Add Another Break', fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
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
  // STEP 4: Attendance Rules (Panel 5)
  // ----------------------------------------------------
  Widget _buildStep4AttendanceRules() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            stepNumber: '4',
            title: 'Attendance Rules',
            subtitle: 'Establish strict or flexible policies for punctuality, grace times, and half-day deductions.',
          ),
          _buildCardContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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

                _buildFieldLabel('Minimum Working Hours', isRequired: false),
                const SizedBox(height: 8),
                _buildDropdownField<String>(
                  value: _minWorkingHours,
                  items: _minHoursOptions,
                  onChanged: (val) {
                    if (val != null) setState(() => _minWorkingHours = val);
                  },
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
  // STEP 5: Overtime Settings (Panel 6)
  // ----------------------------------------------------
  Widget _buildStep5OvertimeSettings() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            stepNumber: '5',
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
                                _buildDropdownField<String>(
                                  value: _otStartsAfter,
                                  items: _otStartsOptions,
                                  onChanged: (val) {
                                    if (val != null) setState(() => _otStartsAfter = val);
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
                                _buildFieldLabel('Minimum OT', isRequired: true),
                                const SizedBox(height: 8),
                                _buildDropdownField<String>(
                                  value: _minimumOT,
                                  items: _minOtOptions,
                                  onChanged: (val) {
                                    if (val != null) setState(() => _minimumOT = val);
                                  },
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
  // STEP 6: Weekly Schedule (Panel 7)
  // ----------------------------------------------------
  Widget _buildStep6WeeklySchedule() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            stepNumber: '6',
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
            child: Column(
              children: [
                // Day Rows
                ..._weeklySchedule.map((schedule) {
                  final isWorking = schedule.isWorking;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isWorking ? Colors.white : AppColors.slate50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isWorking ? AppColors.slate200 : AppColors.slate200.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Working Toggle
                        CupertinoSwitch(
                          value: isWorking,
                          activeTrackColor: AppColors.primaryColor,
                          onChanged: (val) {
                            setState(() {
                              schedule.isWorking = val;
                            });
                          },
                        ),
                        const SizedBox(width: 12),

                        // Day Name
                        SizedBox(
                          width: 80,
                          child: AppText(
                            schedule.dayName,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isWorking ? AppColors.textColorPrimary : AppColors.textColorHint,
                          ),
                        ),

                        // Shift Timing (Clickable to edit if working)
                        Expanded(
                          child: isWorking
                              ? InkWell(
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
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Iconsax.clock, size: 14, color: AppColors.primaryColor),
                                        const SizedBox(width: 6),
                                        Flexible(
                                          child: AppText(
                                            '${_formatTimeOfDay(schedule.startTime)} - ${_formatTimeOfDay(schedule.endTime)}',
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(Icons.edit_outlined, size: 12, color: AppColors.textColorHint),
                                      ],
                                    ),
                                  ),
                                )
                              : const Center(
                                  child: AppText(
                                    'No hours assigned',
                                    fontSize: 12,
                                    color: AppColors.textColorHint,
                                  ),
                                ),
                        ),

                        const SizedBox(width: 10),

                        // Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isWorking ? AppColors.successColor.withValues(alpha: 0.1) : AppColors.slate200,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: AppText(
                            isWorking ? 'Working' : 'Weekly Off',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isWorking ? AppColors.successColor : AppColors.textColorSecondary,
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
  // STEP 7: Employee Assignment (Panel 8)
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
            stepNumber: '7',
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

                // Department & Team Filters
                Row(
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
                          const AppText('Team', fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textColorSecondary),
                          const SizedBox(height: 6),
                          _buildDropdownField<String>(
                            value: _selectedTeam,
                            items: _teams,
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedTeam = val);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

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
                      Row(
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
                            'Select All (${filtered.length})',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: AppText(
                          'Selected: $_selectedEmployeesCount Employees',
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
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                          const SizedBox(width: 4),
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.primaryColor.withValues(alpha: 0.12),
                            child: AppText(
                              emp.name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join(),
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
                                AppText(emp.name, fontSize: 13, fontWeight: FontWeight.bold),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: AppColors.slate100,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: AppText(emp.department, fontSize: 10, color: AppColors.textColorSecondary),
                                    ),
                                    const SizedBox(width: 6),
                                    AppText(
                                      'Current: ${emp.currentShift}',
                                      fontSize: 11,
                                      color: AppColors.textColorHint,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isAssigned ? Colors.green.withValues(alpha: 0.1) : Colors.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: AppText(
                              emp.status,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isAssigned ? Colors.green : Colors.blue,
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
              child: ElevatedButton(
                onPressed: () {
                  if (isLastStep) {
                    if (Get.isRegistered<ShiftController>()) {
                      final ctrl = Get.find<ShiftController>();
                      final assignedNames = _allEmployees.where((e) => e.isSelected).map((e) => e.name).toList();
                      final newShift = ShiftModel(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: _shiftNameController.text.trim().isEmpty ? 'New Shift' : _shiftNameController.text.trim(),
                        code: _shiftCodeController.text.trim().isEmpty ? 'SHIFT' : _shiftCodeController.text.trim(),
                        type: _shiftType,
                        isActive: _isActive,
                        description: _descriptionController.text.trim(),
                        startTime: _formatTimeOfDay(_startTime),
                        endTime: _formatTimeOfDay(_endTime),
                        crossMidnight: _crossMidnight,
                        workingHours: _calculateWorkingHours(_startTime, _endTime, _crossMidnight),
                        enableBreak: _enableBreak,
                        breakType: _breakType,
                        breakDuration: _breakDuration,
                        gracePeriod: _gracePeriod,
                        lateAfter: _lateAfter,
                        minWorkingHours: _minWorkingHours,
                        earlyLeavingAllowed: _earlyLeavingAllowed,
                        autoMarkLate: _autoMarkLate,
                        autoMarkHalfDay: _autoMarkHalfDay,
                        lateThreshold: _lateThreshold,
                        halfDayAfter: _halfDayAfter,
                        enableOvertime: _enableOvertime,
                        otStartsAfter: _otStartsAfter,
                        minimumOT: _minimumOT,
                        otCalculation: _otCalculation,
                        approvalRequired: _approvalRequired,
                        employeesCount: _selectedEmployeesCount,
                        assignedEmployeeNames: assignedNames,
                        icon: _shiftType.contains('Night')
                            ? Icons.nightlight_outlined
                            : _shiftType.contains('Flexible')
                                ? Iconsax.slider_horizontal
                                : Icons.wb_sunny_outlined,
                        iconColor: _shiftType.contains('Night')
                            ? Colors.blue
                            : _shiftType.contains('Flexible')
                                ? Colors.redAccent
                                : Colors.orange,
                      );
                      ctrl.addShift(newShift);
                    }
                    Get.back();
                    Get.snackbar(
                      'Shift Created Successfully!',
                      'Shift "${_shiftNameController.text}" with $_selectedEmployeesCount assigned employees has been saved.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: AppColors.successColor,
                      colorText: Colors.white,
                      duration: const Duration(seconds: 3),
                    );
                  } else {
                    _goToStep(_currentStep + 1);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppText(
                      isLastStep ? 'Save & Create Shift' : 'Save & Continue',
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
              ),
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
    required Widget child,
  }) {
    return Container(
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
    required TextEditingController controller,
    required String hint,
    IconData? prefixIcon,
    ValueChanged<String>? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
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
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.slate200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textColorSecondary),
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textColorPrimary),
          onChanged: onChanged,
          items: items.map((T item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(item.toString()),
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
