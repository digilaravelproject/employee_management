import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';

class AssignShiftScreen extends StatefulWidget {
  const AssignShiftScreen({super.key});

  @override
  State<AssignShiftScreen> createState() => _AssignShiftScreenState();
}

class _AssignShiftScreenState extends State<AssignShiftScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _shifts = [
    {
      'name': 'Morning Shift',
      'time': '09:00 AM - 06:00 PM',
      'icon': Icons.wb_sunny_outlined,
      'color': Colors.orange,
    },
    {
      'name': 'Evening Shift',
      'time': '02:00 PM - 11:00 PM',
      'icon': Icons.wb_twilight,
      'color': Colors.purple,
    },
    {
      'name': 'Night Shift',
      'time': '10:00 PM - 07:00 AM',
      'icon': Icons.nightlight_outlined,
      'color': Colors.blue,
    },
    {
      'name': 'General Shift',
      'time': '10:00 AM - 07:00 PM',
      'icon': Icons.access_time_rounded,
      'color': Colors.teal,
    },
  ];

  late Map<String, dynamic> _selectedShift;

  final List<Map<String, dynamic>> _employees = [
    {'name': 'Rahul Sharma', 'designation': 'UI/UX Designer', 'department': 'Design', 'selected': true},
    {'name': 'Neha Singh', 'designation': 'HR Executive', 'department': 'Human Resources', 'selected': true},
    {'name': 'Amit Kumar', 'designation': 'Marketing Executive', 'department': 'Marketing', 'selected': false},
    {'name': 'Vikram Joshi', 'designation': 'Backend Developer', 'department': 'Engineering', 'selected': false},
    {'name': 'Sneha Patel', 'designation': 'Frontend Developer', 'department': 'Engineering', 'selected': false},
    {'name': 'Sameer Khan', 'designation': 'QA Engineer', 'department': 'Quality Assurance', 'selected': false},
    {'name': 'Pooja Verma', 'designation': 'Operations Lead', 'department': 'Operations', 'selected': false},
  ];

  @override
  void initState() {
    super.initState();
    _selectedShift = _shifts.first;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredEmployees {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _employees;
    return _employees.where((emp) {
      final name = (emp['name'] as String).toLowerCase();
      final desig = (emp['designation'] as String).toLowerCase();
      return name.contains(query) || desig.contains(query);
    }).toList();
  }

  int get _selectedCount => _employees.where((e) => e['selected'] as bool).length;

  void _showShiftSelectionModal() {
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
            ..._shifts.map((shift) {
              final isChosen = _selectedShift['name'] == shift['name'];
              final Color shiftColor = shift['color'] as Color;

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
                    child: Icon(shift['icon'] as IconData, color: shiftColor, size: 20),
                  ),
                  title: AppText(shift['name'] as String, fontSize: 14, fontWeight: FontWeight.bold),
                  subtitle: AppText(shift['time'] as String, fontSize: 12, color: AppColors.textColorSecondary),
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

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredEmployees;
    final allFilteredSelected = filtered.isNotEmpty && filtered.every((e) => e['selected'] as bool);
    final Color currentShiftColor = _selectedShift['color'] as Color;

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
                                child: Icon(_selectedShift['icon'] as IconData, color: currentShiftColor, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText(_selectedShift['name'] as String, fontSize: 13, fontWeight: FontWeight.bold),
                                  const SizedBox(height: 2),
                                  AppText(_selectedShift['time'] as String, fontSize: 11, color: AppColors.textColorSecondary),
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
                          e['selected'] = nextState;
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
                                  e['selected'] = val ?? false;
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
                      final isSelected = emp['selected'] as bool;
                      final name = emp['name'] as String;
                      final designation = emp['designation'] as String;
                      final department = emp['department'] as String? ?? 'General';

                      return InkWell(
                        onTap: () {
                          setState(() {
                            emp['selected'] = !isSelected;
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
                                    emp['selected'] = val ?? false;
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
                    onPressed: () {
                      if (_selectedCount == 0) {
                        Get.snackbar(
                          'No Employees Selected',
                          'Please select at least one employee to assign the shift.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.orange,
                          colorText: Colors.white,
                        );
                        return;
                      }

                      Get.back();
                      Get.snackbar(
                        'Success',
                        'Shift "${_selectedShift['name']}" assigned to $_selectedCount employees.',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: AppColors.successColor,
                        colorText: Colors.white,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const AppText('Assign Shift', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
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
