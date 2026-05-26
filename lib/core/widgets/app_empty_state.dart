import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'app_text.dart';
import 'app_button.dart';

class AppEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  const AppEmptyState({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.actionLabel,
    this.onActionPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with decorative background
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                ),
                Icon(
                  icon,
                  size: 48,
                  color: AppColors.primaryColor,
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Text Content
            AppText(
              title,
              style: AppTextStyle.heading,
              fontSize: 20,
              textAlign: TextAlign.center,
              color: AppColors.textColorPrimary,
            ),
            const SizedBox(height: 12),
            AppText(
              subtitle,
              style: AppTextStyle.body,
              fontSize: 15,
              textAlign: TextAlign.center,
              color: AppColors.textColorSecondary.withValues(alpha: 0.8),
            ),
            
            // Action Button
            if (actionLabel != null && onActionPressed != null) ...[
              const SizedBox(height: 32),
              AppButton(
                text: actionLabel!,
                onPressed: onActionPressed,
                width: 200,
                height: 48,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
