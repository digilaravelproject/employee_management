import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Reusable UI components styled exactly according to the provided mockups
class AdminFlowTheme {
  // Brand Colors - Using App's Primary Color (Deep Purple 0xFF3B206A)
  static const Color primaryBlue = Color(0xFF3B206A); // App Primary Color
  static const Color primaryDark = Color(0xFF261042); // App Primary Dark
  static const Color primaryLight = Color(0xFFF5F0FB); // Soft Primary Tint
  static const Color surfaceSlate = Color(0xFFF8FAFC); // Clean page background
  static const Color cardBorder = Color(0xFFE2E8F0); // Subtle 1px border
  static const Color textDark = Color(0xFF0F172A); // Main headings
  static const Color textMuted = Color(0xFF64748B); // Subtitles / captions
  static const Color textHint = Color(0xFF94A3B8); // Placeholder text

  // Pill badge colors
  static const Color successBg = Color(0xFFDCFCE7);
  static const Color successText = Color(0xFF16A34A);

  static const Color infoBg = Color(0xFFF5F0FB); // Soft primary tint
  static const Color infoText = Color(0xFF3B206A); // App primary color

  static const Color warningBg = Color(0xFFFEF3C7);
  static const Color warningText = Color(0xFFD97706);

  static const Color dangerBg = Color(0xFFFEE2E2);
  static const Color dangerText = Color(0xFFDC2626);

  static const Color purpleBg = Color(0xFFF3E8FF);
  static const Color purpleText = Color(0xFF9333EA);
}

class AdminFlowStatusBadge extends StatelessWidget {
  final String status;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const AdminFlowStatusBadge({
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
    if (s == 'active' || s == 'working' || s == 'completed' || s == 'done') {
      bg = AdminFlowTheme.successBg;
      text = AdminFlowTheme.successText;
    } else if (s == 'in progress') {
      bg = AdminFlowTheme.infoBg;
      text = AdminFlowTheme.infoText;
    } else if (s == 'on hold' || s == 'on leave' || s == 'pending') {
      bg = AdminFlowTheme.warningBg;
      text = AdminFlowTheme.warningText;
    } else if (s == 'overdue' || s == 'high') {
      bg = AdminFlowTheme.dangerBg;
      text = AdminFlowTheme.dangerText;
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

class AdminFlowProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final Color? color;
  final double height;
  final Color backgroundColor;

  const AdminFlowProgressBar({
    super.key,
    required this.progress,
    this.color,
    this.height = 7,
    this.backgroundColor = const Color(0xFFE2E8F0),
  });

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);
    final fill = color ??
        (clamped >= 1.0
            ? AdminFlowTheme.successText
            : clamped > 0.5
                ? AdminFlowTheme.primaryBlue
                : const Color(0xFF3B82F6));

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          height: height,
          width: constraints.maxWidth,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(height / 2),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              height: height,
              width: constraints.maxWidth * clamped,
              decoration: BoxDecoration(
                color: fill,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
          ),
        );
      },
    );
  }
}

class AdminFlowCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color color;
  final double borderRadius;
  final Border? border;

  const AdminFlowCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.color = Colors.white,
    this.borderRadius = 16,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border ?? Border.all(color: AdminFlowTheme.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 8,
            offset: const Offset(0, 3),
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

class AdminFlowAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final Widget? leading;

  const AdminFlowAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.onBackPressed,
    this.actions,
    this.leading,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      scrolledUnderElevation: 0,
      leading: leading ??
          (showBackButton
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AdminFlowTheme.textDark, size: 18),
                  onPressed: onBackPressed ?? () => Get.back(),
                )
              : null),
      title: Text(
        title,
        style: const TextStyle(
          color: AdminFlowTheme.textDark,
          fontSize: 17,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
      actions: actions,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: AdminFlowTheme.cardBorder, height: 1),
      ),
    );
  }
}
