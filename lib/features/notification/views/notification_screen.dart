import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/notification_controller.dart';
import '../models/notification_model.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Put or find the controller
    final controller = Get.put(NotificationController());

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textColorPrimary, size: 18),
          onPressed: () => Get.back(),
        ),
        title: const AppText(
          'Notifications',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textColorPrimary,
        ),
        centerTitle: false,
        actions: [
          Obx(() {
            if (controller.notifications.isEmpty) return const SizedBox.shrink();
            return IconButton(
              icon: const Icon(Iconsax.trash, color: AppColors.errorColor, size: 20),
              tooltip: 'Clear All',
              onPressed: () => _showClearAllConfirmDialog(context, controller),
            );
          }),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          final list = controller.notifications;
          if (list.isEmpty) {
            return const _EmptyNotificationPlaceholder();
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = list[index];
              return _NotificationCard(item: item, controller: controller);
            },
          );
        }),
      ),
    );
  }

  void _showClearAllConfirmDialog(BuildContext context, NotificationController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const AppText('Clear All Notifications', fontSize: 16, fontWeight: FontWeight.w700),
        content: const AppText('Are you sure you want to delete all notifications?', fontSize: 13, color: AppColors.textColorSecondary),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const AppText('Cancel', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textColorSecondary),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            onPressed: () {
              controller.clearAll();
              Navigator.pop(context);
            },
            child: const AppText('Clear All', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.white),
          ),
        ],
      ),
    );
  }
}

// ── EMPTY NOTIFICATION PLACEHOLDER ───────────────────────────────────────────
class _EmptyNotificationPlaceholder extends StatelessWidget {
  const _EmptyNotificationPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.slate100,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconsax.notification_bing,
              color: AppColors.textColorHint,
              size: 48,
            ),
          ),
          const SizedBox(height: 20),
          const AppText(
            'All caught up!',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textColorPrimary,
          ),
          const SizedBox(height: 6),
          const AppText(
            'You do not have any new notifications.',
            fontSize: 12,
            color: AppColors.textColorSecondary,
          ),
        ],
      ),
    );
  }
}

// ── NOTIFICATION CARD ────────────────────────────────────────────────────────
class _NotificationCard extends StatelessWidget {
  final NotificationModel item;
  final NotificationController controller;

  const _NotificationCard({
    required this.item,
    required this.controller,
  });

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) {
      return diff.inMinutes <= 1 ? 'Just now' : '${diff.inMinutes} mins ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} hours ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return DateFormat('dd MMM, hh:mm a').format(dt);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Style configurations based on type
    Color accentColor;
    Color bgLightColor;
    IconData visualIcon;

    switch (item.type) {
      case 'success':
        accentColor = AppColors.successColor;
        bgLightColor = const Color(0xFFEAFAF1);
        visualIcon = Iconsax.tick_circle;
        break;
      case 'warning':
        accentColor = AppColors.warningColor;
        bgLightColor = const Color(0xFFFEF9EC);
        visualIcon = Iconsax.warning_2;
        break;
      case 'info':
        accentColor = AppColors.primaryColor;
        bgLightColor = const Color(0xFFEFF6FF);
        visualIcon = Iconsax.info_circle;
        break;
      default:
        accentColor = AppColors.textColorHint;
        bgLightColor = AppColors.slate100;
        visualIcon = Iconsax.notification;
    }

    return GestureDetector(
      onLongPress: () {
        // Trigger haptic feedback to signal long press success
        HapticFeedback.mediumImpact();
        // Show high-fidelity delete confirm dialog
        _showDeleteConfirmDialog(context);
      },
      onTap: () {
        if (!item.isRead) {
          controller.markAsRead(item.id);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: item.isRead ? AppColors.borderColor : AppColors.primaryColor.withValues(alpha: 0.15),
            width: item.isRead ? 1 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.01),
              blurRadius: 6,
              offset: const Offset(0, 2),
            )
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Custom Status Icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: bgLightColor,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(visualIcon, color: accentColor, size: 18),
            ),
            const SizedBox(width: 12),

            // Middle Title, description, and time
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: AppText(
                          item.title,
                          fontSize: 13,
                          fontWeight: item.isRead ? FontWeight.w600 : FontWeight.w700,
                          color: AppColors.textColorPrimary,
                        ),
                      ),
                      // Small blue dot for unread status
                      if (!item.isRead)
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  AppText(
                    item.description,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textColorSecondary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Iconsax.clock, size: 10, color: AppColors.textColorHint),
                      const SizedBox(width: 4),
                      AppText(
                        _formatTime(item.timestamp),
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textColorHint,
                      ),
                      const SizedBox(width: 8),
                      // Help label
                      const AppText(
                        '• Long-press to delete',
                        fontSize: 9,
                        color: AppColors.textColorHint,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const AppText('Delete Notification?', fontSize: 16, fontWeight: FontWeight.w700),
        content: const AppText(
          'Are you sure you want to remove this notification?',
          fontSize: 13,
          color: AppColors.textColorSecondary,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const AppText(
              'Cancel',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textColorSecondary,
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            onPressed: () {
              controller.deleteNotification(item.id);
              Navigator.pop(context);
            },
            child: const AppText(
              'Delete',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}
