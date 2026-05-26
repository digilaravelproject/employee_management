import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'app_text.dart';

class AppFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool showIcon;

  const AppFilterChip({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.showIcon = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : AppColors.slate200,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColors.primaryColor.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText(
              label,
              style: AppTextStyle.caption,
              color: isSelected ? AppColors.white : AppColors.textColorSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
            if (showIcon) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: isSelected ? AppColors.white : AppColors.textColorSecondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
