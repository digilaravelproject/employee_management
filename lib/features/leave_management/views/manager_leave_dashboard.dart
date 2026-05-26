import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import 'leave_requests_screen.dart';
import 'team_leave_calendar_screen.dart';
import 'leave_reports_screen.dart';

class ManagerLeaveDashboard extends StatefulWidget {
  const ManagerLeaveDashboard({super.key});

  @override
  State<ManagerLeaveDashboard> createState() => _ManagerLeaveDashboardState();
}

class _ManagerLeaveDashboardState extends State<ManagerLeaveDashboard> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const LeaveRequestsScreen(),
    const TeamLeaveCalendarScreen(),
    const LeaveReportsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Iconsax.document_text, 'Requests'),
                _buildNavItem(1, Iconsax.calendar_1, 'Calendar'),
                _buildNavItem(2, Iconsax.chart_square, 'Reports'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.primaryColor : AppColors.textColorSecondary,
            size: 24,
          ),
          const SizedBox(height: 4),
          AppText(
            label,
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? AppColors.primaryColor : AppColors.textColorSecondary,
          ),
        ],
      ),
    );
  }
}
