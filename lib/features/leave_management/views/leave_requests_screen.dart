import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import 'leave_approval_screen.dart';

class LeaveRequestsScreen extends StatefulWidget {
  const LeaveRequestsScreen({super.key});

  @override
  State<LeaveRequestsScreen> createState() => _LeaveRequestsScreenState();
}

class _LeaveRequestsScreenState extends State<LeaveRequestsScreen> {
  // Filter States
  String _selectedStatus = 'All';
  String _selectedDepartment = 'All';
  String _selectedRole = 'All';
  String _selectedDesignation = 'All';
  String _selectedLeaveType = 'All';
  String _selectedDatePreset = 'All Time';
  DateTimeRange? _selectedDateRange;

  final TextEditingController _searchController = TextEditingController();

  final List<String> _departments = [
    'All',
    'Design',
    'Development',
    'HR',
    'Marketing',
    'Sales',
  ];

  final List<String> _roles = [
    'All',
    'Admin',
    'Manager',
    'Team Lead',
    'Employee',
  ];

  final List<String> _designations = [
    'All',
    'UI/UX Designer',
    'Frontend Developer',
    'Backend Developer',
    'HR Executive',
    'Marketing Executive',
    'Sales Lead',
  ];

  final List<String> _leaveTypes = [
    'All',
    'Casual Leave',
    'Sick Leave',
    'Paid Leave',
    'Comp Off',
    'Paternity Leave',
  ];

  final List<String> _datePresets = [
    'All Time',
    'Today',
    'This Week',
    'This Month',
    'Last Month',
    'Custom Range',
  ];

  final List<Map<String, dynamic>> _allRequests = [
    {
      'name': 'Rahul Sharma',
      'role': 'Employee',
      'designation': 'UI/UX Designer',
      'department': 'Design',
      'image': 'assets/images/user1.png',
      'type': 'Casual Leave',
      'status': 'Pending',
      'startDate': DateTime(2025, 5, 20),
      'endDate': DateTime(2025, 5, 22),
      'dates': '20 May - 22 May 2025',
      'duration': '3 Days',
      'appliedOn': '18 May 2025',
    },
    {
      'name': 'Neha Singh',
      'role': 'Employee',
      'designation': 'HR Executive',
      'department': 'HR',
      'image': 'assets/images/user2.png',
      'type': 'Sick Leave',
      'status': 'Pending',
      'startDate': DateTime(2025, 5, 19),
      'endDate': DateTime(2025, 5, 19),
      'dates': '19 May 2025',
      'duration': '1 Day',
      'appliedOn': '17 May 2025',
    },
    {
      'name': 'Amit Kumar',
      'role': 'Employee',
      'designation': 'Marketing Executive',
      'department': 'Marketing',
      'image': 'assets/images/user3.png',
      'type': 'Paid Leave',
      'status': 'Pending',
      'startDate': DateTime(2025, 5, 23),
      'endDate': DateTime(2025, 5, 26),
      'dates': '23 May - 26 May 2025',
      'duration': '4 Days',
      'appliedOn': '19 May 2025',
    },
    {
      'name': 'Vikram Joshi',
      'role': 'Team Lead',
      'designation': 'Backend Developer',
      'department': 'Development',
      'image': 'assets/images/user4.png',
      'type': 'Casual Leave',
      'status': 'Approved',
      'startDate': DateTime(2025, 5, 27),
      'endDate': DateTime(2025, 5, 28),
      'dates': '27 May - 28 May 2025',
      'duration': '2 Days',
      'appliedOn': '20 May 2025',
    },
    {
      'name': 'Sneha Patel',
      'role': 'Employee',
      'designation': 'Frontend Developer',
      'department': 'Development',
      'image': 'assets/images/user5.png',
      'type': 'Sick Leave',
      'status': 'Rejected',
      'startDate': DateTime(2025, 5, 21),
      'endDate': DateTime(2025, 5, 23),
      'dates': '21 May - 23 May 2025',
      'duration': '3 Days',
      'appliedOn': '18 May 2025',
    },
    {
      'name': 'Rohan Gupta',
      'role': 'Manager',
      'designation': 'Sales Lead',
      'department': 'Sales',
      'image': 'assets/images/user1.png',
      'type': 'Comp Off',
      'status': 'Approved',
      'startDate': DateTime(2025, 5, 15),
      'endDate': DateTime(2025, 5, 16),
      'dates': '15 May - 16 May 2025',
      'duration': '2 Days',
      'appliedOn': '12 May 2025',
    },
    {
      'name': 'Ananya Roy',
      'role': 'Employee',
      'designation': 'UI/UX Designer',
      'department': 'Design',
      'image': 'assets/images/user2.png',
      'type': 'Paid Leave',
      'status': 'Approved',
      'startDate': DateTime(2025, 5, 10),
      'endDate': DateTime(2025, 5, 12),
      'dates': '10 May - 12 May 2025',
      'duration': '3 Days',
      'appliedOn': '05 May 2025',
    },
    {
      'name': 'Karan Verma',
      'role': 'Employee',
      'designation': 'Frontend Developer',
      'department': 'Development',
      'image': 'assets/images/user3.png',
      'type': 'Casual Leave',
      'status': 'Pending',
      'startDate': DateTime(2025, 5, 29),
      'endDate': DateTime(2025, 5, 30),
      'dates': '29 May - 30 May 2025',
      'duration': '2 Days',
      'appliedOn': '24 May 2025',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasActiveFilters {
    return _selectedDepartment != 'All' ||
        _selectedRole != 'All' ||
        _selectedDesignation != 'All' ||
        _selectedLeaveType != 'All' ||
        _selectedDatePreset != 'All Time' ||
        _selectedDateRange != null;
  }

  int get _activeFilterCount {
    int count = 0;
    if (_selectedDepartment != 'All') count++;
    if (_selectedRole != 'All') count++;
    if (_selectedDesignation != 'All') count++;
    if (_selectedLeaveType != 'All') count++;
    if (_selectedDatePreset != 'All Time' || _selectedDateRange != null) count++;
    return count;
  }

  void _resetAllFilters() {
    setState(() {
      _selectedStatus = 'All';
      _selectedDepartment = 'All';
      _selectedRole = 'All';
      _selectedDesignation = 'All';
      _selectedLeaveType = 'All';
      _selectedDatePreset = 'All Time';
      _selectedDateRange = null;
      _searchController.clear();
    });
  }

  List<Map<String, dynamic>> get _filteredRequests {
    return _allRequests.where((req) {
      // 1. Status Filter
      if (_selectedStatus != 'All' && req['status'] != _selectedStatus) {
        return false;
      }

      // 2. Department Filter
      if (_selectedDepartment != 'All' && req['department'] != _selectedDepartment) {
        return false;
      }

      // 3. Role Filter
      if (_selectedRole != 'All' && req['role'] != _selectedRole) {
        return false;
      }

      // 4. Designation Filter
      if (_selectedDesignation != 'All' && req['designation'] != _selectedDesignation) {
        return false;
      }

      // 5. Leave Type Filter
      if (_selectedLeaveType != 'All' && req['type'] != _selectedLeaveType) {
        return false;
      }

      // 6. Date Range Filter
      if (_selectedDateRange != null) {
        final reqStart = req['startDate'] as DateTime;
        final reqEnd = req['endDate'] as DateTime;
        final rangeStart = DateTime(_selectedDateRange!.start.year, _selectedDateRange!.start.month, _selectedDateRange!.start.day);
        final rangeEnd = DateTime(_selectedDateRange!.end.year, _selectedDateRange!.end.month, _selectedDateRange!.end.day, 23, 59, 59);

        final overlaps = reqStart.isBefore(rangeEnd) && reqEnd.isAfter(rangeStart.subtract(const Duration(seconds: 1)));
        if (!overlaps) return false;
      }

      // 6. Search Query Filter
      final query = _searchController.text.trim().toLowerCase();
      if (query.isNotEmpty) {
        final name = (req['name'] as String? ?? '').toLowerCase();
        final desig = (req['designation'] as String? ?? '').toLowerCase();
        final type = (req['type'] as String? ?? '').toLowerCase();
        final dept = (req['department'] as String? ?? '').toLowerCase();
        final dates = (req['dates'] as String? ?? '').toLowerCase();

        if (!name.contains(query) &&
            !desig.contains(query) &&
            !type.contains(query) &&
            !dept.contains(query) &&
            !dates.contains(query)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  int _countForStatus(String status) {
    if (status == 'All') return _allRequests.length;
    return _allRequests.where((r) => r['status'] == status).length;
  }

  void _showFilterBottomSheet() {
    String tempDepartment = _selectedDepartment;
    String tempRole = _selectedRole;
    String tempDesignation = _selectedDesignation;
    String tempLeaveType = _selectedLeaveType;
    String tempStatus = _selectedStatus;
    String tempDatePreset = _selectedDatePreset;
    DateTimeRange? tempDateRange = _selectedDateRange;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.88,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.slate300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Iconsax.filter_search, color: AppColors.primaryColor, size: 22),
                            const SizedBox(width: 8),
                            const AppText(
                              'Filter Leave Requests',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColorPrimary,
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            setSheetState(() {
                              tempDepartment = 'All';
                              tempRole = 'All';
                              tempDesignation = 'All';
                              tempLeaveType = 'All';
                              tempStatus = 'All';
                              tempDatePreset = 'All Time';
                              tempDateRange = null;
                            });
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          ),
                          child: const AppText(
                            'Reset All',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.errorColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: AppColors.borderColor, height: 1),

                  // Filter Content Body
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Date Range Section
                          _buildSectionTitle(Iconsax.calendar_1, 'Date Range'),
                          const SizedBox(height: 10),

                          // Quick Presets
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _datePresets.map((preset) {
                              final isSelected = tempDatePreset == preset;
                              return ChoiceChip(
                                label: Text(preset),
                                labelStyle: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                  color: isSelected ? Colors.white : AppColors.textColorPrimary,
                                ),
                                selected: isSelected,
                                selectedColor: AppColors.primaryColor,
                                backgroundColor: AppColors.slate100,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: isSelected ? AppColors.primaryColor : AppColors.borderColor,
                                  ),
                                ),
                                onSelected: (val) {
                                  setSheetState(() {
                                    tempDatePreset = preset;
                                    final now = DateTime.now();
                                    if (preset == 'Today') {
                                      tempDateRange = DateTimeRange(
                                        start: DateTime(now.year, now.month, now.day),
                                        end: DateTime(now.year, now.month, now.day),
                                      );
                                    } else if (preset == 'This Week') {
                                      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
                                      tempDateRange = DateTimeRange(
                                        start: DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
                                        end: DateTime(now.year, now.month, now.day),
                                      );
                                    } else if (preset == 'This Month') {
                                      tempDateRange = DateTimeRange(
                                        start: DateTime(now.year, now.month, 1),
                                        end: DateTime(now.year, now.month + 1, 0),
                                      );
                                    } else if (preset == 'Last Month') {
                                      tempDateRange = DateTimeRange(
                                        start: DateTime(now.year, now.month - 1, 1),
                                        end: DateTime(now.year, now.month, 0),
                                      );
                                    } else if (preset == 'Custom Range') {
                                      // Retain existing date range or keep ready for picker
                                    } else {
                                      tempDateRange = null; // All Time
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 12),

                          // Date From & To Date Selection Fields
                          Row(
                            children: [
                              Expanded(
                                child: _buildDateInputCard(
                                  label: 'Date From',
                                  icon: Iconsax.calendar_1,
                                  date: tempDateRange?.start,
                                  onTap: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: tempDateRange?.start ?? DateTime.now(),
                                      firstDate: DateTime(2024),
                                      lastDate: DateTime(2027),
                                      builder: (ctx, child) => _buildDatePickerTheme(child!),
                                    );
                                    if (picked != null) {
                                      setSheetState(() {
                                        tempDatePreset = 'Custom Range';
                                        if (tempDateRange?.end != null && tempDateRange!.end.isBefore(picked)) {
                                          tempDateRange = DateTimeRange(start: picked, end: picked);
                                        } else {
                                          tempDateRange = DateTimeRange(
                                            start: picked,
                                            end: tempDateRange?.end ?? picked,
                                          );
                                        }
                                      });
                                    }
                                  },
                                  onClear: tempDateRange != null
                                      ? () {
                                          setSheetState(() {
                                            tempDateRange = null;
                                            tempDatePreset = 'All Time';
                                          });
                                        }
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildDateInputCard(
                                  label: 'To Date',
                                  icon: Iconsax.calendar_tick,
                                  date: tempDateRange?.end,
                                  onTap: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: tempDateRange?.end ?? tempDateRange?.start ?? DateTime.now(),
                                      firstDate: tempDateRange?.start ?? DateTime(2024),
                                      lastDate: DateTime(2027),
                                      builder: (ctx, child) => _buildDatePickerTheme(child!),
                                    );
                                    if (picked != null) {
                                      setSheetState(() {
                                        tempDatePreset = 'Custom Range';
                                        if (tempDateRange?.start != null && picked.isBefore(tempDateRange!.start)) {
                                          tempDateRange = DateTimeRange(start: picked, end: picked);
                                        } else {
                                          tempDateRange = DateTimeRange(
                                            start: tempDateRange?.start ?? picked,
                                            end: picked,
                                          );
                                        }
                                      });
                                    }
                                  },
                                  onClear: tempDateRange != null
                                      ? () {
                                          setSheetState(() {
                                            tempDateRange = null;
                                            tempDatePreset = 'All Time';
                                          });
                                        }
                                      : null,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),
                          const Divider(color: AppColors.borderColor, height: 1),
                          const SizedBox(height: 16),

                          // 2. Department Dropdown
                          _buildSectionTitle(Iconsax.building, 'Department'),
                          const SizedBox(height: 8),
                          _buildFilterDropdown<String>(
                            value: tempDepartment,
                            items: _departments,
                            prefixIcon: Iconsax.building,
                            onChanged: (val) {
                              if (val != null) setSheetState(() => tempDepartment = val);
                            },
                          ),

                          const SizedBox(height: 20),
                          const Divider(color: AppColors.borderColor, height: 1),
                          const SizedBox(height: 16),

                          // 3. Role Dropdown
                          _buildSectionTitle(Iconsax.shield_security, 'Role'),
                          const SizedBox(height: 8),
                          _buildFilterDropdown<String>(
                            value: tempRole,
                            items: _roles,
                            prefixIcon: Iconsax.shield_security,
                            onChanged: (val) {
                              if (val != null) setSheetState(() => tempRole = val);
                            },
                          ),

                          const SizedBox(height: 20),
                          const Divider(color: AppColors.borderColor, height: 1),
                          const SizedBox(height: 16),

                          // 4. Designation Dropdown
                          _buildSectionTitle(Iconsax.user_square, 'Designation'),
                          const SizedBox(height: 8),
                          _buildFilterDropdown<String>(
                            value: tempDesignation,
                            items: _designations,
                            prefixIcon: Iconsax.user_square,
                            onChanged: (val) {
                              if (val != null) setSheetState(() => tempDesignation = val);
                            },
                          ),

                          const SizedBox(height: 20),
                          const Divider(color: AppColors.borderColor, height: 1),
                          const SizedBox(height: 16),

                          // 5. Leave Type Filter
                          _buildSectionTitle(Iconsax.category_2, 'Leave Type'),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _leaveTypes.map((type) {
                              final isSelected = tempLeaveType == type;
                              return ChoiceChip(
                                label: Text(type),
                                labelStyle: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                  color: isSelected ? Colors.white : AppColors.textColorPrimary,
                                ),
                                selected: isSelected,
                                selectedColor: AppColors.primaryColor,
                                backgroundColor: AppColors.slate100,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: isSelected ? AppColors.primaryColor : AppColors.borderColor,
                                  ),
                                ),
                                onSelected: (val) {
                                  setSheetState(() => tempLeaveType = type);
                                },
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 20),
                          const Divider(color: AppColors.borderColor, height: 1),
                          const SizedBox(height: 16),

                          // 6. Status Filter
                          _buildSectionTitle(Iconsax.tick_circle, 'Status'),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: ['All', 'Pending', 'Approved', 'Rejected'].map((status) {
                              final isSelected = tempStatus == status;
                              Color chipColor = AppColors.primaryColor;
                              if (status == 'Approved') chipColor = Colors.green;
                              if (status == 'Rejected') chipColor = Colors.red;
                              if (status == 'Pending') chipColor = Colors.orange;

                              return ChoiceChip(
                                label: Text(status),
                                labelStyle: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                  color: isSelected ? Colors.white : AppColors.textColorPrimary,
                                ),
                                selected: isSelected,
                                selectedColor: chipColor,
                                backgroundColor: AppColors.slate100,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: isSelected ? chipColor : AppColors.borderColor,
                                  ),
                                ),
                                onSelected: (val) {
                                  setSheetState(() => tempStatus = status);
                                },
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Action Buttons
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Get.back();
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                side: const BorderSide(color: AppColors.borderColor),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const AppText(
                                'Cancel',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textColorSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedDepartment = tempDepartment;
                                  _selectedRole = tempRole;
                                  _selectedDesignation = tempDesignation;
                                  _selectedLeaveType = tempLeaveType;
                                  _selectedStatus = tempStatus;
                                  _selectedDatePreset = tempDatePreset;
                                  _selectedDateRange = tempDateRange;
                                });
                                Get.back();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const AppText(
                                'Apply Filters',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildDatePickerTheme(Widget child) {
    return Theme(
      data: ThemeData.light().copyWith(
        colorScheme: const ColorScheme.light(
          primary: AppColors.primaryColor,
          onPrimary: Colors.white,
          surface: Colors.white,
          onSurface: AppColors.textColorPrimary,
        ),
      ),
      child: child,
    );
  }

  Widget _buildDateInputCard({
    required String label,
    required IconData icon,
    required DateTime? date,
    required VoidCallback onTap,
    VoidCallback? onClear,
  }) {
    final hasDate = date != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          label,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textColorSecondary,
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: hasDate ? AppColors.primaryLight.withValues(alpha: 0.5) : AppColors.slate50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasDate ? AppColors.primaryColor.withValues(alpha: 0.6) : AppColors.borderColor,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: hasDate ? AppColors.primaryColor : AppColors.textColorSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppText(
                    hasDate ? DateFormat('dd MMM yyyy').format(date) : 'DD/MM/YYYY',
                    fontSize: 12,
                    fontWeight: hasDate ? FontWeight.w600 : FontWeight.normal,
                    color: hasDate ? AppColors.textColorPrimary : AppColors.textColorHint,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (hasDate && onClear != null)
                  GestureDetector(
                    onTap: onClear,
                    child: const Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: Icon(Icons.close, size: 16, color: AppColors.textColorSecondary),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterDropdown<T>({
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    IconData? prefixIcon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.slate50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          if (prefixIcon != null) ...[
            Icon(prefixIcon, size: 18, color: AppColors.primaryColor),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: value,
                isExpanded: true,
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(12),
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textColorSecondary, size: 20),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textColorPrimary),
                onChanged: onChanged,
                items: items.map((T item) {
                  final isSelected = item == value;
                  return DropdownMenuItem<T>(
                    value: item,
                    child: AppText(
                      item.toString(),
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? AppColors.primaryColor : AppColors.textColorPrimary,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textColorSecondary),
        const SizedBox(width: 6),
        AppText(
          title,
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: AppColors.textColorPrimary,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _filteredRequests;

    final filterTabs = [
      {'label': 'All', 'count': _countForStatus('All'), 'color': AppColors.primaryColor},
      {'label': 'Pending', 'count': _countForStatus('Pending'), 'color': Colors.orange},
      {'label': 'Approved', 'count': _countForStatus('Approved'), 'color': Colors.green},
      {'label': 'Rejected', 'count': _countForStatus('Rejected'), 'color': Colors.red},
    ];

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_outlined, color: AppColors.textColorPrimary),
          onPressed: () => Get.back(),
        ),
        title: const AppText('Leave Requests', fontSize: 18, fontWeight: FontWeight.bold),
        centerTitle: false,
        actions: [
          // Filter Icon with active indicator & count
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(
                  _hasActiveFilters ? Iconsax.filter_edit : Iconsax.filter,
                  color: _hasActiveFilters ? AppColors.primaryColor : AppColors.textColorPrimary,
                ),
                onPressed: _showFilterBottomSheet,
              ),
              if (_hasActiveFilters)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Center(
                      child: Text(
                        '$_activeFilterCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs (Status)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: filterTabs.map((filter) {
                final isSelected = _selectedStatus == filter['label'];
                return GestureDetector(
                  onTap: () => setState(() => _selectedStatus = filter['label'] as String),
                  child: Container(
                    margin: const EdgeInsets.only(right: 16),
                    padding: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isSelected ? AppColors.primaryColor : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        AppText(
                          filter['label'] as String,
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? AppColors.textColorPrimary : AppColors.textColorSecondary,
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: (filter['color'] as Color).withValues(alpha: isSelected ? 0.2 : 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: AppText(
                            '${filter['count']}',
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: filter['color'] as Color,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 12),

          // Search Bar & Filter trigger button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderColor),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() {}),
                      style: const TextStyle(fontSize: 14, color: AppColors.textColorPrimary),
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        isDense: true,
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        prefixIcon: const Icon(
                          Iconsax.search_normal,
                          color: AppColors.textColorSecondary,
                          size: 18,
                        ),
                        hintText: 'Search by name, role, type...',
                        hintStyle: const TextStyle(color: AppColors.textColorHint, fontSize: 13),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close, size: 16, color: AppColors.textColorSecondary),
                                splashRadius: 18,
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Quick filter button
                InkWell(
                  onTap: _showFilterBottomSheet,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _hasActiveFilters ? AppColors.primaryColor : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _hasActiveFilters ? AppColors.primaryColor : AppColors.borderColor,
                      ),
                    ),
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Iconsax.setting_4,
                            color: _hasActiveFilters ? Colors.white : AppColors.textColorPrimary,
                            size: 20,
                          ),
                          if (_hasActiveFilters)
                            Positioned(
                              top: 6,
                              right: 6,
                              child: Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Active Filter Chips Row
          if (_hasActiveFilters) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                height: 32,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    // Clear All Chip
                    GestureDetector(
                      onTap: _resetAllFilters,
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.errorColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.errorColor.withValues(alpha: 0.3)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.refresh, size: 14, color: AppColors.errorColor),
                            SizedBox(width: 4),
                            AppText('Clear All', fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.errorColor),
                          ],
                        ),
                      ),
                    ),

                    // Department Chip
                    if (_selectedDepartment != 'All')
                      _buildActiveFilterPill(
                        'Dept: $_selectedDepartment',
                        () => setState(() => _selectedDepartment = 'All'),
                      ),

                    // Role Chip
                    if (_selectedRole != 'All')
                      _buildActiveFilterPill(
                        'Role: $_selectedRole',
                        () => setState(() => _selectedRole = 'All'),
                      ),

                    // Designation Chip
                    if (_selectedDesignation != 'All')
                      _buildActiveFilterPill(
                        'Desig: $_selectedDesignation',
                        () => setState(() => _selectedDesignation = 'All'),
                      ),

                    // Leave Type Chip
                    if (_selectedLeaveType != 'All')
                      _buildActiveFilterPill(
                        'Type: $_selectedLeaveType',
                        () => setState(() => _selectedLeaveType = 'All'),
                      ),

                    // Date Range Chip
                    if (_selectedDatePreset != 'All Time' || _selectedDateRange != null)
                      _buildActiveFilterPill(
                        _selectedDatePreset == 'Custom Range' && _selectedDateRange != null
                            ? '${DateFormat('dd MMM').format(_selectedDateRange!.start)} - ${DateFormat('dd MMM').format(_selectedDateRange!.end)}'
                            : _selectedDatePreset,
                        () => setState(() {
                          _selectedDatePreset = 'All Time';
                          _selectedDateRange = null;
                        }),
                      ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Requests List
          Expanded(
            child: filteredList.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      return _buildRequestCard(filteredList[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilterPill(String label, VoidCallback onRemove) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText(label, fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primaryColor),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, size: 14, color: AppColors.primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.slate100,
                shape: BoxShape.circle,
              ),
              child: const Icon(Iconsax.document_filter, size: 48, color: AppColors.slate400),
            ),
            const SizedBox(height: 16),
            const AppText(
              'No Leave Requests Found',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textColorPrimary,
            ),
            const SizedBox(height: 8),
            const AppText(
              'No requests match the selected filters or search query. Try resetting filters.',
              fontSize: 12,
              color: AppColors.textColorSecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _resetAllFilters,
              icon: const Icon(Icons.refresh, size: 16, color: Colors.white),
              label: const AppText('Reset Filters', fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> req) {
    Color statusColor;
    if (req['status'] == 'Approved') {
      statusColor = Colors.green;
    } else if (req['status'] == 'Rejected') {
      statusColor = Colors.red;
    } else {
      statusColor = Colors.orange;
    }

    return GestureDetector(
      onTap: () => Get.to(() => LeaveApprovalScreen(requestData: req)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.slate200,
                  child: const Icon(Icons.person, color: AppColors.slate400),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(req['name'], fontSize: 14, fontWeight: FontWeight.bold),
                      Row(
                        children: [
                          AppText(req['designation'], fontSize: 12, color: AppColors.textColorSecondary),
                          if (req['department'] != null) ...[
                            const SizedBox(width: 6),
                            Container(
                              width: 3,
                              height: 3,
                              decoration: const BoxDecoration(
                                color: AppColors.textColorSecondary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            AppText(req['department'], fontSize: 11, color: AppColors.primaryColor, fontWeight: FontWeight.w600),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: AppText(req['type'], fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Iconsax.calendar_1, color: AppColors.textColorSecondary, size: 16),
                    const SizedBox(width: 8),
                    AppText(req['dates'], fontSize: 12, fontWeight: FontWeight.w600),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.slate100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: AppText(req['duration'], fontSize: 11, color: AppColors.textColorSecondary),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: AppText(req['status'], fontSize: 11, fontWeight: FontWeight.bold, color: statusColor),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(color: AppColors.borderColor, height: 1),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText('Applied on ${req['appliedOn']}', fontSize: 11, color: AppColors.textColorSecondary),
                const Icon(Icons.keyboard_arrow_right, color: AppColors.textColorSecondary, size: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
