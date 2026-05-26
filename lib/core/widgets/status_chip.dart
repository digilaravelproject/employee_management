import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../theme/app_colors.dart';

enum ChipStatus { active, pending, completed, cancelled, onHold }

class StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const StatusChip({
    Key? key,
    required this.label,
    this.color = AppColors.primaryColor,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.24), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  factory StatusChip.success({required String label}) => StatusChip(label: label, color: AppColors.successColor, icon: Iconsax.tick_circle);
  factory StatusChip.error({required String label}) => StatusChip(label: label, color: AppColors.errorColor, icon: Iconsax.danger);
  factory StatusChip.warning({required String label}) => StatusChip(label: label, color: AppColors.warningColor, icon: Iconsax.warning_2);
  factory StatusChip.info({required String label}) => StatusChip(label: label, color: AppColors.infoColor, icon: Iconsax.info_circle);
}
