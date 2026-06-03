import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';

class RotationEmployee {
  final String id;
  final String name;
  final String role;
  final String email;
  final String avatarUrl;
  final String shiftName;

  RotationEmployee({
    required this.id,
    required this.name,
    required this.role,
    required this.email,
    required this.avatarUrl,
    required this.shiftName,
  });
}

class RotationSchedule {
  final String id;
  final String title;
  final String dates;
  final int shiftsCount;
  final String status; // 'Active', 'Completed', 'Upcoming'
  final List<RotationEmployee> assignedEmployees;

  RotationSchedule({
    required this.id,
    required this.title,
    required this.dates,
    required this.shiftsCount,
    required this.status,
    required this.assignedEmployees,
  });

  int get employeeCount => assignedEmployees.length;

  Color getStatusColor() {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'active':
        return AppColors.primaryColor;
      case 'upcoming':
      default:
        return Colors.orange;
    }
  }
}

class ShiftRotationScreen extends StatefulWidget {
  const ShiftRotationScreen({super.key});

  @override
  State<ShiftRotationScreen> createState() => _ShiftRotationScreenState();
}

class _ShiftRotationScreenState extends State<ShiftRotationScreen> {
  final List<RotationSchedule> _rotationsList = [];

  // Complete corporate directory of employees to simulate assignment search
  final List<RotationEmployee> _companyDirectory = [
    RotationEmployee(id: 'emp1', name: 'Rahul Sharma', role: 'Software Engineer', email: 'rahul@example.com', avatarUrl: 'https://i.pravatar.cc/150?u=emp1', shiftName: 'Morning Shift'),
    RotationEmployee(id: 'emp2', name: 'Neha Kapoor', role: 'HR Specialist', email: 'neha@example.com', avatarUrl: 'https://i.pravatar.cc/150?u=emp2', shiftName: 'General Shift'),
    RotationEmployee(id: 'emp3', name: 'Amit Singh', role: 'Project Manager', email: 'amit@example.com', avatarUrl: 'https://i.pravatar.cc/150?u=emp3', shiftName: 'Morning Shift'),
    RotationEmployee(id: 'emp4', name: 'Vikas Yadav', role: 'QA Lead', email: 'vikas@example.com', avatarUrl: 'https://i.pravatar.cc/150?u=emp4', shiftName: 'Evening Shift'),
    RotationEmployee(id: 'emp5', name: 'Priya Patel', role: 'UX Designer', email: 'priya@example.com', avatarUrl: 'https://i.pravatar.cc/150?u=emp5', shiftName: 'General Shift'),
    RotationEmployee(id: 'emp6', name: 'Rajesh Kumar', role: 'Support Engineer', email: 'rajesh@example.com', avatarUrl: 'https://i.pravatar.cc/150?u=emp6', shiftName: 'Night Shift'),
    RotationEmployee(id: 'emp7', name: 'Sunil Verma', role: 'DevOps Engineer', email: 'sunil@example.com', avatarUrl: 'https://i.pravatar.cc/150?u=emp7', shiftName: 'Night Shift'),
    RotationEmployee(id: 'emp8', name: 'Kiran Rao', role: 'Security Analyst', email: 'kiran@example.com', avatarUrl: 'https://i.pravatar.cc/150?u=emp8', shiftName: 'Evening Shift'),
    RotationEmployee(id: 'emp9', name: 'Deepika Sen', role: 'Product Manager', email: 'deepika@example.com', avatarUrl: 'https://i.pravatar.cc/150?u=emp9', shiftName: 'General Shift'),
    RotationEmployee(id: 'emp10', name: 'Rohan Deshmukh', role: 'Database Administrator', email: 'rohan@example.com', avatarUrl: 'https://i.pravatar.cc/150?u=emp10', shiftName: 'Night Shift'),
  ];

  @override
  void initState() {
    super.initState();
    _initializeMockData();
  }

  void _initializeMockData() {
    _rotationsList.addAll([
      RotationSchedule(
        id: 'r1',
        title: 'Rotation - May 2025 - Week 1',
        dates: '28 Apr - 04 May 2025',
        shiftsCount: 3,
        status: 'Completed',
        assignedEmployees: [
          _companyDirectory[0], // Rahul
          _companyDirectory[1], // Neha
          _companyDirectory[2], // Amit
          _companyDirectory[3], // Vikas
          _companyDirectory[4], // Priya
        ],
      ),
      RotationSchedule(
        id: 'r2',
        title: 'Rotation - May 2025 - Week 2',
        dates: '05 May - 11 May 2025',
        shiftsCount: 3,
        status: 'Completed',
        assignedEmployees: [
          _companyDirectory[0], // Rahul
          _companyDirectory[1], // Neha
          _companyDirectory[3], // Vikas
          _companyDirectory[5], // Rajesh
        ],
      ),
      RotationSchedule(
        id: 'r3',
        title: 'Rotation - May 2025 - Week 3',
        dates: '12 May - 18 May 2025',
        shiftsCount: 3,
        status: 'Active',
        assignedEmployees: [
          _companyDirectory[2], // Amit
          _companyDirectory[3], // Vikas
          _companyDirectory[4], // Priya
          _companyDirectory[5], // Rajesh
          _companyDirectory[6], // Sunil
        ],
      ),
      RotationSchedule(
        id: 'r4',
        title: 'Rotation - May 2025 - Week 4',
        dates: '19 May - 25 May 2025',
        shiftsCount: 3,
        status: 'Upcoming',
        assignedEmployees: [
          _companyDirectory[0], // Rahul
          _companyDirectory[4], // Priya
          _companyDirectory[5], // Rajesh
          _companyDirectory[6], // Sunil
        ],
      ),
    ]);
  }

  // Helper getters to calculate stats dynamically
  int get _totalRotations => _rotationsList.length;
  int get _activeCount => _rotationsList.where((r) => r.status.toLowerCase() == 'active').length;
  int get _completedCount => _rotationsList.where((r) => r.status.toLowerCase() == 'completed').length;
  int get _upcomingCount => _rotationsList.where((r) => r.status.toLowerCase() == 'upcoming').length;

  // Total unique assigned employee stats across active rotation
  int get _totalAssignedEmployees {
    final Set<String> uniqueIds = {};
    for (var rotation in _rotationsList) {
      for (var emp in rotation.assignedEmployees) {
        uniqueIds.add(emp.id);
      }
    }
    return uniqueIds.length;
  }

  void _addRotation(String title, String dates, int shiftsCount, List<RotationEmployee> initialEmployees, String status) {
    setState(() {
      _rotationsList.insert(
        0,
        RotationSchedule(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title,
          dates: dates,
          shiftsCount: shiftsCount,
          status: status,
          assignedEmployees: initialEmployees,
        ),
      );
    });

    Get.snackbar(
      'Rotation Scheduled',
      'Successfully scheduled "$title" rotation cycle with ${initialEmployees.length} employees.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  void _deleteRotation(String id) {
    final item = _rotationsList.firstWhere((r) => r.id == id);
    setState(() {
      _rotationsList.removeWhere((r) => r.id == id);
    });

    Get.snackbar(
      'Rotation Deleted',
      'Successfully removed "${item.title}" rotation.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textColorPrimary, size: 18),
          onPressed: () => Get.back(),
        ),
        title: const AppText('Shift Rotation', fontSize: 18, fontWeight: FontWeight.bold),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.textColorPrimary),
            onPressed: () {},
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateRotationSheet(context),
        backgroundColor: AppColors.primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          // Month Selector Banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_left, color: AppColors.textColorPrimary),
                  onPressed: () {},
                ),
                const AppText('May 2025', fontSize: 16, fontWeight: FontWeight.bold),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.keyboard_arrow_right, color: AppColors.slate300),
                      onPressed: () {},
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.borderColor),
                      ),
                      child: const Icon(Iconsax.calendar, size: 18, color: AppColors.textColorPrimary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Stats Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(child: _buildStatCard('Total Rotations', '$_totalRotations', Colors.blue)),
                const SizedBox(width: 8),
                Expanded(child: _buildStatCard('Active', '$_activeCount', Colors.green)),
                const SizedBox(width: 8),
                Expanded(child: _buildStatCard('Completed', '$_completedCount', Colors.grey)),
                const SizedBox(width: 8),
                Expanded(child: _buildStatCard('Unique Staff', '$_totalAssignedEmployees', Colors.orange)),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // List Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const AppText('Rotation List', fontSize: 14, fontWeight: FontWeight.bold),
                AppText('View Calendar', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryColor),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Rotation Schedules List
          Expanded(
            child: _rotationsList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Iconsax.repeate_music, size: 48, color: AppColors.textColorHint.withValues(alpha: 0.3)),
                        const SizedBox(height: 12),
                        const AppText('No rotation schedules created yet.', fontSize: 13, color: AppColors.textColorHint),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    physics: const BouncingScrollPhysics(),
                    itemCount: _rotationsList.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = _rotationsList[index];
                      return _buildRotationItem(item);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          AppText(label, fontSize: 9, color: AppColors.textColorSecondary, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          AppText(value, fontSize: 20, fontWeight: FontWeight.bold, color: color),
        ],
      ),
    );
  }

  Widget _buildRotationItem(RotationSchedule item) {
    final statusColor = item.getStatusColor();

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 24),
      ),
      onDismissed: (direction) => _deleteRotation(item.id),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showAssignedEmployeesBottomSheet(context, item),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: AppText(item.title, fontSize: 14, fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: AppText(item.status, fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                          ),
                          const SizedBox(width: 4),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, size: 16, color: AppColors.textColorHint),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onSelected: (val) {
                              if (val == 'delete') {
                                _deleteRotation(item.id);
                              } else if (val == 'details') {
                                _showAssignedEmployeesBottomSheet(context, item);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'details',
                                child: AppText('View Assigned Employees', fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                              const PopupMenuDivider(),
                              const PopupMenuItem(
                                value: 'delete',
                                child: AppText('Delete Rotation', fontSize: 12, color: Colors.redAccent, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Iconsax.calendar_1, size: 12, color: AppColors.textColorHint),
                      const SizedBox(width: 6),
                      AppText(item.dates, fontSize: 12, color: AppColors.textColorSecondary),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Iconsax.clock, size: 12, color: AppColors.textColorHint),
                      const SizedBox(width: 6),
                      AppText('${item.shiftsCount} Shifts Included • ', fontSize: 11, color: AppColors.textColorSecondary),
                      AppText('${item.employeeCount} Employees Assigned 👤', fontSize: 11, color: AppColors.primaryColor, fontWeight: FontWeight.w800),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── ASSIGNED EMPLOYEES DETAILS BOTTOM SHEET ───────────────────────────────────
  void _showAssignedEmployeesBottomSheet(BuildContext context, RotationSchedule rotation) {
    String employeeSearchQuery = '';
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDetailsState) {
            // Filter current rotation employees locally
            final activeEmployeesList = rotation.assignedEmployees.where((emp) {
              return emp.name.toLowerCase().contains(employeeSearchQuery.toLowerCase()) ||
                     emp.role.toLowerCase().contains(employeeSearchQuery.toLowerCase());
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.slate200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(rotation.title, fontSize: 16, fontWeight: FontWeight.bold),
                            const SizedBox(height: 4),
                            AppText('Dates: ${rotation.dates}', fontSize: 11, color: AppColors.textColorSecondary),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: rotation.getStatusColor().withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: AppText(
                          rotation.status, 
                          fontSize: 11, 
                          fontWeight: FontWeight.bold, 
                          color: rotation.getStatusColor(),
                        ),
                      ),
                    ],
                  ),
                  
                  const Divider(height: 24, color: AppColors.borderColor),

                  // Search Bar and Add Button
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.slate50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: TextField(
                            onChanged: (val) {
                              setDetailsState(() {
                                employeeSearchQuery = val;
                              });
                            },
                            decoration: const InputDecoration(
                              hintText: 'Search assigned staff...',
                              hintStyle: TextStyle(color: AppColors.textColorHint, fontSize: 12),
                              prefixIcon: Icon(Iconsax.search_normal, color: AppColors.textColorHint, size: 16),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          elevation: 0,
                        ),
                        onPressed: () => _showAddStaffToRotationOverlay(context, rotation, () {
                          // Trigger parent state update so main screen counts reflect changes
                          setState(() {});
                          setDetailsState(() {});
                        }),
                        child: const Row(
                          children: [
                            Icon(Icons.add, size: 16, color: Colors.white),
                            SizedBox(width: 4),
                            AppText('Assign', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const AppText('Assigned Employees', fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorSecondary),
                      AppText('${rotation.employeeCount} Total staff', fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textColorHint),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Employees List
                  Expanded(
                    child: activeEmployeesList.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Iconsax.profile_2user, size: 36, color: AppColors.textColorHint.withValues(alpha: 0.2)),
                                const SizedBox(height: 8),
                                const AppText('No staff members match search.', fontSize: 12, color: AppColors.textColorHint),
                              ],
                            ),
                          )
                        : ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            itemCount: activeEmployeesList.length,
                            separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.borderColor),
                            itemBuilder: (context, index) {
                              final emp = activeEmployeesList[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundImage: NetworkImage(emp.avatarUrl),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          AppText(emp.name, fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
                                          const SizedBox(height: 2),
                                          AppText(emp.role, fontSize: 11, color: AppColors.textColorHint),
                                          const SizedBox(height: 3),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFEFF6FF),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: AppText(
                                              emp.shiftName, 
                                              fontSize: 9, 
                                              fontWeight: FontWeight.bold, 
                                              color: AppColors.primaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.redAccent, size: 20),
                                      onPressed: () {
                                        setDetailsState(() {
                                          rotation.assignedEmployees.removeWhere((e) => e.id == emp.id);
                                        });
                                        // Update outer list state
                                        setState(() {});
                                        Get.snackbar(
                                          'Assignment Revoked',
                                          'Successfully removed ${emp.name} from rotation.',
                                          snackPosition: SnackPosition.BOTTOM,
                                          backgroundColor: const Color(0xFF1E293B),
                                          colorText: Colors.white,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
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

  // ── ASSIGN MORE STAFF OVERLAY DIRECTORY ───────────────────────────────────────
  void _showAddStaffToRotationOverlay(BuildContext context, RotationSchedule rotation, VoidCallback onStaffAssigned) {
    String directorySearchQuery = '';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Find employees in directory who are not already assigned to this rotation
            final availableEmployees = _companyDirectory.where((emp) {
              final isAlreadyAssigned = rotation.assignedEmployees.any((e) => e.id == emp.id);
              final matchesSearch = emp.name.toLowerCase().contains(directorySearchQuery.toLowerCase()) ||
                                    emp.role.toLowerCase().contains(directorySearchQuery.toLowerCase());
              return !isAlreadyAssigned && matchesSearch;
            }).toList();

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const AppText('Assign Employee to Rotation', fontSize: 16, fontWeight: FontWeight.bold),
              content: SizedBox(
                width: double.maxFinite,
                height: 350,
                child: Column(
                  children: [
                    // Search box
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.slate50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: TextField(
                        onChanged: (val) {
                          setDialogState(() {
                            directorySearchQuery = val;
                          });
                        },
                        decoration: const InputDecoration(
                          hintText: 'Search corporate directory...',
                          hintStyle: TextStyle(color: AppColors.textColorHint, fontSize: 12),
                          prefixIcon: Icon(Iconsax.search_normal, color: AppColors.textColorHint, size: 14),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Directory List
                    Expanded(
                      child: availableEmployees.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Iconsax.user, size: 36, color: AppColors.textColorHint.withValues(alpha: 0.2)),
                                  const SizedBox(height: 8),
                                  const AppText(
                                    'No unassigned staff members.', 
                                    fontSize: 11, 
                                    color: AppColors.textColorHint,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              physics: const BouncingScrollPhysics(),
                              itemCount: availableEmployees.length,
                              separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.borderColor),
                              itemBuilder: (context, index) {
                                final emp = availableEmployees[index];
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: CircleAvatar(
                                    radius: 18,
                                    backgroundImage: NetworkImage(emp.avatarUrl),
                                  ),
                                  title: AppText(emp.name, fontSize: 12, fontWeight: FontWeight.bold),
                                  subtitle: AppText(emp.role, fontSize: 10, color: AppColors.textColorHint),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.green, size: 20),
                                    onPressed: () {
                                      setDialogState(() {
                                        rotation.assignedEmployees.add(emp);
                                      });
                                      onStaffAssigned();
                                      Get.back();
                                      Get.snackbar(
                                        'Employee Assigned',
                                        'Assigned ${emp.name} to ${rotation.title}.',
                                        snackPosition: SnackPosition.BOTTOM,
                                        backgroundColor: Colors.green,
                                        colorText: Colors.white,
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const AppText('Close', fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorSecondary),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCreateRotationSheet(BuildContext context) {
    final titleController = TextEditingController(text: 'Rotation - May 2025 - Week ${_rotationsList.length + 1}');
    final dateController = TextEditingController(text: '26 May - 01 Jun 2025');
    
    // Manage multi-select shifts locally
    final Map<String, bool> selectedShifts = {
      'Morning Shift': true,
      'Evening Shift': true,
      'Night Shift': false,
      'General Shift': false,
    };

    // Preselected initial employees from directory to assign by default
    final List<RotationEmployee> initialSelection = [
      _companyDirectory[0], // Rahul
      _companyDirectory[4], // Priya
      _companyDirectory[5], // Rajesh
    ];

    String selectedStatus = 'Upcoming';
    String selectedCycle = 'Weekly';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.slate200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const AppText('Schedule Shift Rotation', fontSize: 16, fontWeight: FontWeight.bold),
                    const SizedBox(height: 20),

                    // Title
                    const AppText('Rotation Schedule Name', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textColorSecondary),
                    const SizedBox(height: 8),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Dates
                    const AppText('Rotation Date Range', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textColorSecondary),
                    const SizedBox(height: 8),
                    TextField(
                      controller: dateController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Iconsax.calendar, size: 18),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Cycles & Status Dropdowns
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const AppText('Frequency Cycle', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textColorSecondary),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                value: selectedCycle,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                items: ['Weekly', 'Bi-weekly', 'Monthly']
                                    .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13))))
                                    .toList(),
                                onChanged: (val) {
                                  if (val != null) setSheetState(() => selectedCycle = val);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const AppText('Initial Status', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textColorSecondary),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                value: selectedStatus,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                items: ['Upcoming', 'Active']
                                    .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13))))
                                    .toList(),
                                onChanged: (val) {
                                  if (val != null) setSheetState(() => selectedStatus = val);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Select Shifts Multi-Select (Chips Row)
                    const AppText('Shifts Included', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textColorSecondary),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: selectedShifts.keys.map((shiftName) {
                        final isSelected = selectedShifts[shiftName]!;
                        return ChoiceChip(
                          label: AppText(
                            shiftName, 
                            fontSize: 11, 
                            fontWeight: FontWeight.bold, 
                            color: isSelected ? Colors.white : AppColors.textColorSecondary,
                          ),
                          selected: isSelected,
                          selectedColor: AppColors.primaryColor,
                          backgroundColor: AppColors.slate100,
                          checkmarkColor: Colors.white,
                          onSelected: (val) {
                            setSheetState(() {
                              selectedShifts[shiftName] = val;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Preselected Employees Assigned Counter
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const AppText('Auto-Assigned Staff', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textColorSecondary),
                        AppText('${initialSelection.length} Employees', fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const AppText('Default staff members will be added initially. You can manage and assign more staff inside the schedule details panel.', fontSize: 11, color: AppColors.textColorHint),
                    const SizedBox(height: 24),

                    // Submit Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: AppColors.primaryColor),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () => Get.back(),
                            child: const AppText('Cancel', fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: AppColors.primaryColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            onPressed: () {
                              final int checkedCount = selectedShifts.values.where((b) => b).length;
                              if (titleController.text.trim().isEmpty) {
                                Get.snackbar('Error', 'Please enter a schedule name');
                                return;
                              }
                              _addRotation(
                                titleController.text.trim(),
                                dateController.text.trim(),
                                checkedCount == 0 ? 1 : checkedCount,
                                List.from(initialSelection), // Clone initial list
                                selectedStatus,
                              );
                              Get.back();
                            },
                            child: const AppText('Create Rotation', fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
