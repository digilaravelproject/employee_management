import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../theme/app_colors.dart';
import 'app_text.dart';

class AppStatusChip extends StatelessWidget {
  final String status;
  final double? fontSize;

  const AppStatusChip({
    Key? key,
    required this.status,
    this.fontSize,
  }) : super(key: key);

  static String formatStatus(String text) {
    if (text.isEmpty) return '';
    final cleaned = text.replaceAll('_', ' ').trim();
    return cleaned.split(' ').where((w) => w.isNotEmpty).map((w) {
      if (w.length == 1) return w.toUpperCase();
      return w[0].toUpperCase() + w.substring(1).toLowerCase();
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    final normalized = status.toLowerCase().replaceAll('_', ' ').trim();

    switch (normalized) {
      case 'confirmed':
      case 'active':
      case 'paid':
      case 'hot':
      case 'present':
      case 'completed':
      case 'approved':
      case 'done':
        color = Colors.green;
        icon = Iconsax.tick_circle;
        break;
      case 'pending':
      case 'waiting':
      case 'warm':
      case 'half day':
      case 'pending approval':
      case 'on hold':
        color = Colors.orange;
        icon = Icons.access_time_rounded;
        break;
      case 'cancelled':
      case 'rejected':
      case 'failed':
      case 'cold':
      case 'absent':
        color = Colors.red;
        icon = Icons.cancel_outlined;
        break;
      case 'quotation sent':
      case 'sent':
        color = AppColors.primaryColor;
        icon = Icons.send_rounded;
        break;
      case 'in progress':
      case 'started':
      case 'working':
        color = AppColors.primaryColor;
        icon = Icons.directions_run_rounded;
        break;
      case 'on leave':
      case 'leave':
        color = Colors.purple;
        icon = Icons.beach_access_rounded;
        break;
      case 'inactive':
        color = Colors.grey;
        icon = Iconsax.close_circle;
        break;
      default:
        color = AppColors.textColorSecondary;
        icon = Iconsax.info_circle;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          AppText(
            formatStatus(status),
            style: AppTextStyle.caption,
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: fontSize ?? 11,
          ),
        ],
      ),
    );
  }
}
