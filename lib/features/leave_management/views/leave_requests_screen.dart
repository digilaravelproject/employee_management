import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import 'leave_approval_screen.dart';

class LeaveRequestsScreen extends StatefulWidget {
  const LeaveRequestsScreen({super.key});

  @override
  State<LeaveRequestsScreen> createState() => _LeaveRequestsScreenState();
}

class _LeaveRequestsScreenState extends State<LeaveRequestsScreen> {
  String _selectedFilter = 'All';

  final List<Map<String, dynamic>> _filters = [
    {'label': 'All', 'count': 32, 'color': AppColors.primaryColor},
    {'label': 'Pending', 'count': 12, 'color': Colors.orange},
    {'label': 'Approved', 'count': 16, 'color': Colors.green},
    {'label': 'Rejected', 'count': 4, 'color': Colors.red},
  ];

  final List<Map<String, dynamic>> _requests = [
    {
      'name': 'Rahul Sharma',
      'designation': 'UI/UX Designer',
      'image': 'assets/images/user1.png',
      'type': 'Casual Leave',
      'status': 'Pending',
      'dates': '20 May - 22 May 2025',
      'duration': '3 Days',
      'appliedOn': '18 May 2025',
    },
    {
      'name': 'Neha Singh',
      'designation': 'HR Executive',
      'image': 'assets/images/user2.png',
      'type': 'Sick Leave',
      'status': 'Pending',
      'dates': '19 May 2025',
      'duration': '1 Day',
      'appliedOn': '17 May 2025',
    },
    {
      'name': 'Amit Kumar',
      'designation': 'Marketing Executive',
      'image': 'assets/images/user3.png',
      'type': 'Paid Leave',
      'status': 'Pending',
      'dates': '23 May - 26 May 2025',
      'duration': '4 Days',
      'appliedOn': '19 May 2025',
    },
    {
      'name': 'Vikram Joshi',
      'designation': 'Backend Developer',
      'image': 'assets/images/user4.png',
      'type': 'Casual Leave',
      'status': 'Approved',
      'dates': '27 May - 28 May 2025',
      'duration': '2 Days',
      'appliedOn': '20 May 2025',
    },
    {
      'name': 'Sneha Patel',
      'designation': 'Frontend Developer',
      'image': 'assets/images/user5.png',
      'type': 'Sick Leave',
      'status': 'Rejected',
      'dates': '21 May - 23 May 2025',
      'duration': '3 Days',
      'appliedOn': '18 May 2025',
    },
  ];

  @override
  Widget build(BuildContext context) {
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
          IconButton(
            icon: const Icon(Iconsax.filter, color: AppColors.textColorPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: _filters.map((filter) {
                final isSelected = _selectedFilter == filter['label'];
                return GestureDetector(
                  onTap: () => setState(() => _selectedFilter = filter['label'] as String),
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
          
          const SizedBox(height: 16),
          
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              // padding: const EdgeInsets.symmetric(horizontal: 12),
              // decoration: BoxDecoration(
              //   color: Colors.white,
              //   borderRadius: BorderRadius.circular(12),
              //   border: Border.all(color: AppColors.borderColor),
              // ),
              child: TextFormField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Iconsax.search_normal, color: AppColors.textColorSecondary, size: 20),
                  hintText: 'Search by name, type or date...',
                  hintStyle: TextStyle(color: AppColors.textColorHint, fontSize: 13),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          
        //  const SizedBox(height: 16),
          
          // List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _requests.length,
              itemBuilder: (context, index) {
                final req = _requests[index];
                
                // Filtering logic
                if (_selectedFilter != 'All' && req['status'] != _selectedFilter) {
                  return const SizedBox.shrink();
                }
                
                return _buildRequestCard(req);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> req) {
    Color statusColor;
    if (req['status'] == 'Approved') statusColor = Colors.green;
    else if (req['status'] == 'Rejected') statusColor = Colors.red;
    else statusColor = Colors.orange;

    return GestureDetector(
      onTap: () => Get.to(() => LeaveApprovalScreen(requestData: req)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.slate200,
                  child: const Icon(Icons.person, color: AppColors.slate400),
                  // backgroundImage: AssetImage(req['image']),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(req['name'], fontSize: 14, fontWeight: FontWeight.bold),
                      AppText(req['designation'], fontSize: 12, color: AppColors.textColorSecondary),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: AppText(req['type'], fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Iconsax.calendar_1, color: AppColors.textColorSecondary, size: 16),
                    const SizedBox(width: 8),
                    AppText(req['dates'], fontSize: 12, fontWeight: FontWeight.w600),
                    const SizedBox(width: 12),
                    AppText(req['duration'], fontSize: 12, color: AppColors.textColorSecondary),
                  ],
                ),
                AppText(req['status'], fontSize: 12, fontWeight: FontWeight.bold, color: statusColor),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.borderColor, height: 1),
            const SizedBox(height: 12),
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
