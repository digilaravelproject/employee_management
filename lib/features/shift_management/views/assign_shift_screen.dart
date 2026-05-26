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
  String _selectedTab = 'By Employees';
  
  final List<Map<String, dynamic>> _employees = [
    {'name': 'Rahul Sharma', 'designation': 'UI/UX Designer', 'selected': true},
    {'name': 'Neha Singh', 'designation': 'HR Executive', 'selected': true},
    {'name': 'Amit Kumar', 'designation': 'Marketing Executive', 'selected': false},
    {'name': 'Vikram Joshi', 'designation': 'Backend Developer', 'selected': false},
    {'name': 'Sneha Patel', 'designation': 'Frontend Developer', 'selected': false},
  ];

  int get _selectedCount => _employees.where((e) => e['selected'] as bool).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textColorPrimary),
          onPressed: () => Get.back(),
        ),
        title: const AppText('Assign Shift', fontSize: 18, fontWeight: FontWeight.bold),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.textColorPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Tabs
          Row(
            children: [
              Expanded(child: _buildTab('By Employees')),
              Expanded(child: _buildTab('By Department')),
            ],
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Select Shift'),
                  const SizedBox(height: 8),
                  Container(
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
                            const Icon(Icons.wb_sunny_outlined, color: Colors.orange, size: 20),
                            const SizedBox(width: 12),
                            const AppText('Morning Shift (09:00 AM - 06:00 PM)', fontSize: 13, fontWeight: FontWeight.w500),
                          ],
                        ),
                        const Icon(Icons.keyboard_arrow_down, color: AppColors.textColorSecondary),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  _buildLabel('Select Date'),
                  const SizedBox(height: 8),
                  Container(
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
                            const Icon(Iconsax.calendar_1, color: AppColors.textColorSecondary, size: 20),
                            const SizedBox(width: 12),
                            const AppText('20 May 2025', fontSize: 13, fontWeight: FontWeight.w500),
                          ],
                        ),
                        const Icon(Iconsax.clock, color: AppColors.textColorSecondary, size: 18),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  _buildLabel('Select Employees'),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Search employees',
                      hintStyle: const TextStyle(color: AppColors.textColorHint, fontSize: 13),
                      prefixIcon: const Icon(Iconsax.search_normal, color: AppColors.textColorSecondary, size: 18),
                      filled: true,
                      fillColor: AppColors.slate50,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Employee List
                  ..._employees.asMap().entries.map((e) {
                    int index = e.key;
                    Map<String, dynamic> emp = e.value;
                    bool isSelected = emp['selected'] as bool;
                    
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _employees[index]['selected'] = !isSelected;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 20,
                              backgroundColor: AppColors.slate200,
                              child: Icon(Icons.person, color: AppColors.slate400),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText(emp['name'], fontSize: 14, fontWeight: FontWeight.bold),
                                  AppText(emp['designation'], fontSize: 12, color: AppColors.textColorSecondary),
                                ],
                              ),
                            ),
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primaryColor : Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: isSelected ? AppColors.primaryColor : AppColors.slate300),
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          
          // Bottom Bar
          Container(
            padding: const EdgeInsets.all(20),
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
                        AppText('$_selectedCount Employees Selected', fontSize: 13, fontWeight: FontWeight.bold),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Get.back();
                      Get.snackbar(
                        'Success',
                        'Shift assigned successfully',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.green,
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

  Widget _buildTab(String label) {
    final isSelected = _selectedTab == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = label),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primaryColor : AppColors.slate200,
              width: 2,
            ),
          ),
        ),
        child: Center(
          child: AppText(
            label,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? AppColors.primaryColor : AppColors.textColorSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return AppText(text, fontSize: 13, fontWeight: FontWeight.bold);
  }
}
