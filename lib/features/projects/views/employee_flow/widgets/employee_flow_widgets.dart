import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../models/employee_flow_models.dart';

/// Clean design theme matching the reference mockups
class EmployeeFlowTheme {
  // Brand Colors - Using App's Primary Color (Deep Purple 0xFF3B206A)
  static const Color primaryBlue = Color(0xFF3B206A); // App Primary
  static const Color primaryDark = Color(0xFF261042); // App Primary Dark
  static const Color primaryLight = Color(0xFFF5F0FB); // Soft Primary Tint
  static const Color surfaceSlate = Color(0xFFF8FAFC); // Clean page background
  static const Color cardBorder = Color(0xFFE2E8F0); // Light subtle border
  static const Color cardBg = Colors.white;

  // Text Colors
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textHint = Color(0xFF94A3B8);

  // Status & Alert Colors
  static const Color successBg = Color(0xFFDCFCE7);
  static const Color successText = Color(0xFF16A34A);
  static const Color successGreen = Color(0xFF10B981);

  static const Color infoBg = Color(0xFFF5F0FB); // Primary tint
  static const Color infoText = Color(0xFF3B206A); // Primary color

  static const Color warningBg = Color(0xFFFEF3C7);
  static const Color warningText = Color(0xFFD97706);
  static const Color warningOrange = Color(0xFFF59E0B);

  static const Color dangerBg = Color(0xFFFEE2E2);
  static const Color dangerText = Color(0xFFDC2626);
  static const Color dangerRed = Color(0xFFEF4444);

  static const Color purpleBg = Color(0xFFF3E8FF);
  static const Color purpleText = Color(0xFF9333EA);
}

/// Custom Status Badge matching the mockups
class EmployeeFlowStatusBadge extends StatelessWidget {
  final String status;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const EmployeeFlowStatusBadge({
    super.key,
    required this.status,
    this.fontSize = 11,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;

    final s = status.toLowerCase();
    if (s == 'active' || s == 'completed' || s == 'done') {
      bg = EmployeeFlowTheme.successBg;
      text = EmployeeFlowTheme.successText;
    } else if (s == 'in progress') {
      bg = EmployeeFlowTheme.infoBg;
      text = EmployeeFlowTheme.infoText;
    } else if (s == 'pending' || s == 'on hold' || s == 'requested') {
      bg = EmployeeFlowTheme.warningBg;
      text = EmployeeFlowTheme.warningText;
    } else if (s == 'overdue' || s == 'exceeded') {
      bg = EmployeeFlowTheme.dangerBg;
      text = EmployeeFlowTheme.dangerText;
    } else {
      bg = const Color(0xFFF1F5F9);
      text = const Color(0xFF475569);
    }

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: text,
        ),
      ),
    );
  }
}

/// Progress bar that turns RED when time is exceeded
class EmployeeFlowProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final bool isExceeded;
  final Color? activeColor;
  final double height;
  final Color backgroundColor;

  const EmployeeFlowProgressBar({
    super.key,
    required this.progress,
    this.isExceeded = false,
    this.activeColor,
    this.height = 7,
    this.backgroundColor = const Color(0xFFE2E8F0),
  });

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);
    final fill = isExceeded
        ? EmployeeFlowTheme.dangerRed
        : (activeColor ?? EmployeeFlowTheme.primaryBlue);

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: clamped,
        child: Container(
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(height / 2),
            boxShadow: isExceeded
                ? [
                    BoxShadow(
                      color: EmployeeFlowTheme.dangerRed.withValues(alpha: 0.4),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    )
                  ]
                : null,
          ),
        ),
      ),
    );
  }
}

/// Clean Card wrapper with border and soft shadow
class EmployeeFlowCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Color borderColor;
  final double borderRadius;

  const EmployeeFlowCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.onTap,
    this.backgroundColor = Colors.white,
    this.borderColor = EmployeeFlowTheme.cardBorder,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onTap,
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Live Bottom Navigation Bar matching the screenshots (Home, Tasks, Projects, Time Log)
class EmployeeBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const EmployeeBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: EmployeeFlowTheme.cardBorder, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: Iconsax.home_2,
                activeIcon: Iconsax.home_25,
                label: 'Home',
              ),
              _buildNavItem(
                index: 1,
                icon: Iconsax.task_square,
                activeIcon: Iconsax.task_square5,
                label: 'Tasks',
              ),
              _buildNavItem(
                index: 2,
                icon: Iconsax.folder_open,
                activeIcon: Iconsax.folder_25,
                label: 'Projects',
              ),
              _buildNavItem(
                index: 3,
                icon: Iconsax.clock,
                activeIcon: Iconsax.clock5,
                label: 'Time Log',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isSelected = selectedIndex == index;
    final color = isSelected ? EmployeeFlowTheme.primaryBlue : EmployeeFlowTheme.textHint;

    return InkWell(
      onTap: () => onTabSelected(index),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 22,
              color: color,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Floating banner displayed when an active task timer is running
class EmployeeActiveTimerBanner extends StatelessWidget {
  final EmployeeFlowTask task;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onStop;
  final VoidCallback onTap;

  const EmployeeActiveTimerBanner({
    super.key,
    required this.task,
    required this.onPause,
    required this.onResume,
    required this.onStop,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isOvertime = task.isTimeExceeded;
    final bgGradient = isOvertime
        ? const LinearGradient(
            colors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
          )
        : const LinearGradient(
            colors: [Color(0xFF261042), Color(0xFF3B206A)],
          );

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: bgGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (isOvertime ? Colors.red : Colors.blue).withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Pulsing dot or pause icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                task.isPaused ? Icons.pause_rounded : Icons.timer_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            // Title and time counter
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    task.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        task.formattedSpentTime,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isOvertime
                            ? '• OVERTIME (+${task.overtimeHours.toStringAsFixed(1)}h)'
                            : '• ${task.remainingHours.toStringAsFixed(1)}h left',
                        style: TextStyle(
                          color: isOvertime
                              ? const Color(0xFFFFD1D1)
                              : Colors.white.withValues(alpha: 0.85),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Controls: Pause/Resume & Stop
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    task.isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                  onPressed: task.isPaused ? onResume : onPause,
                  tooltip: task.isPaused ? 'Resume' : 'Pause (Break)',
                ),
                IconButton(
                  icon: const Icon(
                    Icons.stop_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                  onPressed: onStop,
                  tooltip: 'Stop & Complete',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
