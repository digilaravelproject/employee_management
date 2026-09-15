import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../departments/controllers/departments_controller.dart';
import '../../employee/designation/controllers/designation_controller.dart';
import '../../employee/management/controllers/employee_controller.dart';

class AudiencePickerItem {
  final String id;
  final String title;
  final String? subtitle;
  final String? avatarUrl;
  final IconData? icon;

  const AudiencePickerItem({
    required this.id,
    required this.title,
    this.subtitle,
    this.avatarUrl,
    this.icon,
  });
}

class AudienceDataHelper {
  static List<AudiencePickerItem> getDepartmentItems() {
    List<String> names = [];
    if (Get.isRegistered<DepartmentsController>()) {
      final deptCtrl = Get.find<DepartmentsController>();
      if (deptCtrl.departments.isNotEmpty) {
        names = deptCtrl.departments.map((d) => d.name).toList();
      }
    }
    if (names.isEmpty && Get.isRegistered<EmployeeController>()) {
      final empCtrl = Get.find<EmployeeController>();
      names = empCtrl.departmentsList.where((d) => d != 'All').toList();
    }
    if (names.isEmpty) {
      names = [
        'Engineering',
        'Human Resources',
        'Sales & Marketing',
        'Operations',
        'Finance & Accounts',
        'Design & Creative',
        'Customer Support',
        'Quality Assurance',
        'Product Management',
        'IT & Infrastructure',
      ];
    }

    return names
        .map((name) => AudiencePickerItem(
              id: name,
              title: name,
              icon: Iconsax.buildings,
            ))
        .toList();
  }

  static List<AudiencePickerItem> getDesignationItems() {
    List<String> names = [];
    if (Get.isRegistered<DesignationController>()) {
      final desigCtrl = Get.find<DesignationController>();
      if (desigCtrl.designations.isNotEmpty) {
        names = desigCtrl.designations.map((d) => d.name).toList();
      }
    }
    if (names.isEmpty && Get.isRegistered<EmployeeController>()) {
      final empCtrl = Get.find<EmployeeController>();
      names = empCtrl.designations;
    }
    if (names.isEmpty) {
      names = [
        'Senior Flutter Developer',
        'Backend Developer',
        'Frontend Developer',
        'UI/UX Designer',
        'HR Manager',
        'Project Manager',
        'QA Engineer',
        'Sales Executive',
        'Marketing Specialist',
        'Operations Lead',
        'Finance Manager',
        'Tech Lead',
      ];
    }

    return names
        .map((name) => AudiencePickerItem(
              id: name,
              title: name,
              icon: Iconsax.briefcase,
            ))
        .toList();
  }

  static List<AudiencePickerItem> getEmployeeItems() {
    if (Get.isRegistered<EmployeeController>()) {
      final empCtrl = Get.find<EmployeeController>();
      if (empCtrl.employees.isNotEmpty) {
        return empCtrl.employees
            .map((e) => AudiencePickerItem(
                  id: e.id,
                  title: e.name,
                  subtitle: '${e.designation} • ${e.department}',
                  avatarUrl: e.profilePic,
                  icon: Iconsax.user,
                ))
            .toList();
      }
    }

    if (Get.isRegistered<DepartmentsController>()) {
      final deptCtrl = Get.find<DepartmentsController>();
      if (deptCtrl.allEmployees.isNotEmpty) {
        return deptCtrl.allEmployees.asMap().entries.map((entry) {
          final u = entry.value;
          return AudiencePickerItem(
            id: 'emp_${entry.key}',
            title: u.name,
            subtitle: 'Staff • ${u.email}',
            avatarUrl: u.avatarUrl,
            icon: Iconsax.user,
          );
        }).toList();
      }
    }

    // Default mock employees
    final fallbackList = [
      {'id': '1', 'name': 'Rohit Sharma', 'role': 'Senior Flutter Developer', 'dept': 'Engineering'},
      {'id': '2', 'name': 'Sarah Johnson', 'role': 'UI/UX Designer', 'dept': 'Design & Creative'},
      {'id': '3', 'name': 'Michael Brown', 'role': 'HR Manager', 'dept': 'Human Resources'},
      {'id': '4', 'name': 'Ananya Roy', 'role': 'Director of HR', 'dept': 'Human Resources'},
      {'id': '5', 'name': 'Rajesh Verma', 'role': 'VP Engineering', 'dept': 'Engineering'},
      {'id': '6', 'name': 'David Wilson', 'role': 'Backend Developer', 'dept': 'Engineering'},
      {'id': '7', 'name': 'Lisa Anderson', 'role': 'Sales Executive', 'dept': 'Sales & Marketing'},
      {'id': '8', 'name': 'Emily Davis', 'role': 'Marketing Specialist', 'dept': 'Sales & Marketing'},
      {'id': '9', 'name': 'Priya Patel', 'role': 'QA Engineer', 'dept': 'Engineering'},
      {'id': '10', 'name': 'James Anderson', 'role': 'Operations Lead', 'dept': 'Operations'},
    ];

    return fallbackList
        .map((e) => AudiencePickerItem(
              id: e['id']!,
              title: e['name']!,
              subtitle: '${e['role']} • ${e['dept']}',
              icon: Iconsax.user,
            ))
        .toList();
  }
}

class AudiencePickerBottomSheet extends StatefulWidget {
  final String title;
  final String searchHint;
  final List<AudiencePickerItem> items;
  final List<String> initialSelected;

  const AudiencePickerBottomSheet({
    super.key,
    required this.title,
    required this.searchHint,
    required this.items,
    required this.initialSelected,
  });

  static Future<List<String>?> show({
    required BuildContext context,
    required String title,
    required String searchHint,
    required List<AudiencePickerItem> items,
    required List<String> initialSelected,
  }) {
    return showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AudiencePickerBottomSheet(
        title: title,
        searchHint: searchHint,
        items: items,
        initialSelected: initialSelected,
      ),
    );
  }

  @override
  State<AudiencePickerBottomSheet> createState() => _AudiencePickerBottomSheetState();
}

class _AudiencePickerBottomSheetState extends State<AudiencePickerBottomSheet> {
  late Set<String> _selectedIds;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedIds = widget.initialSelected.toSet();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AudiencePickerItem> get _filteredItems {
    if (_searchQuery.trim().isEmpty) return widget.items;
    final query = _searchQuery.toLowerCase().trim();
    return widget.items.where((item) {
      final matchTitle = item.title.toLowerCase().contains(query);
      final matchSub = item.subtitle?.toLowerCase().contains(query) ?? false;
      return matchTitle || matchSub;
    }).toList();
  }

  void _toggleItem(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _selectAll() {
    setState(() {
      _selectedIds.addAll(_filteredItems.map((e) => e.id));
    });
  }

  void _clearAll() {
    setState(() {
      _selectedIds.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredItems;
    final isAllFilteredSelected =
        filtered.isNotEmpty && filtered.every((item) => _selectedIds.contains(item.id));

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.78,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.slate300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        widget.title,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColorPrimary,
                      ),
                      const SizedBox(height: 2),
                      AppText(
                        '${_selectedIds.length} of ${widget.items.length} selected',
                        fontSize: 12,
                        color: AppColors.textColorSecondary,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textColorSecondary),
                  onPressed: () => Navigator.pop(context, widget.initialSelected),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Search Box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.slate50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.slate200),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                decoration: InputDecoration(
                  hintText: widget.searchHint,
                  hintStyle: const TextStyle(color: AppColors.textColorHint, fontSize: 13),
                  prefixIcon: const Icon(Iconsax.search_normal_1, color: AppColors.textColorSecondary, size: 18),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 16, color: AppColors.textColorSecondary),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Quick Action Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: isAllFilteredSelected
                      ? () {
                          setState(() {
                            for (var item in filtered) {
                              _selectedIds.remove(item.id);
                            }
                          });
                        }
                      : _selectAll,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: AppText(
                      isAllFilteredSelected ? 'Deselect All' : 'Select All',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
                if (_selectedIds.isNotEmpty)
                  GestureDetector(
                    onTap: _clearAll,
                    child: const AppText(
                      'Clear Selection',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.redAccent,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: AppColors.slate200),

          // List Items
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Iconsax.search_status, size: 40, color: AppColors.slate300),
                        const SizedBox(height: 8),
                        const AppText('No results found', fontSize: 14, color: AppColors.textColorSecondary),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filtered.length,
                    separatorBuilder: (_, index) => const Divider(height: 1, color: AppColors.slate100),
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      final isSelected = _selectedIds.contains(item.id);

                      return InkWell(
                        onTap: () => _toggleItem(item.id),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primaryLight.withValues(alpha: 0.35) : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              // Leading Icon / Avatar
                              _buildLeading(item),
                              const SizedBox(width: 12),

                              // Text details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppText(
                                      item.title,
                                      fontSize: 13,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                      color: isSelected ? AppColors.primaryColor : AppColors.textColorPrimary,
                                    ),
                                    if (item.subtitle != null) ...[
                                      const SizedBox(height: 2),
                                      AppText(
                                        item.subtitle!,
                                        fontSize: 11,
                                        color: AppColors.textColorSecondary,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),

                              // Checkbox
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.primaryColor : Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? AppColors.primaryColor : AppColors.slate300,
                                    width: 1.5,
                                  ),
                                ),
                                child: isSelected
                                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppText(
                          '${_selectedIds.length} Selected',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColorPrimary,
                        ),
                        AppText(
                          _selectedIds.isEmpty ? 'None chosen' : 'Ready to apply',
                          fontSize: 11,
                          color: AppColors.textColorSecondary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, _selectedIds.toList());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const AppText(
                      'Done',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeading(AudiencePickerItem item) {
    if (item.avatarUrl != null && item.avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 18,
        backgroundImage: NetworkImage(item.avatarUrl!),
        backgroundColor: AppColors.slate200,
      );
    }

    if (item.subtitle != null) {
      // Generate initials for employees
      final parts = item.title.trim().split(' ');
      String initials = '';
      if (parts.isNotEmpty && parts[0].isNotEmpty) {
        initials += parts[0][0];
      }
      if (parts.length > 1 && parts[1].isNotEmpty) {
        initials += parts[1][0];
      }
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: AppText(
          initials.toUpperCase(),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryColor,
        ),
      );
    }

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.slate100,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Icon(item.icon ?? Iconsax.element_3, size: 18, color: AppColors.primaryColor),
    );
  }
}
