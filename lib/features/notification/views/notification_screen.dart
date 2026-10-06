import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../routes/app_routes.dart';
import '../controllers/notification_controller.dart';
import '../models/notification_model.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Locate or put the controller
    final controller = Get.isRegistered<NotificationController>()
        ? Get.find<NotificationController>()
        : Get.put(NotificationController());

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Obx(() {
          final isSelection = controller.isSelectionMode.value;
          final unread = controller.unreadCount;

          if (isSelection) {
            final count = controller.selectedIds.length;
            final isAllSelected = count == controller.notifications.length && count > 0;
            return AppBar(
              backgroundColor: AppColors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.close, color: AppColors.textColorPrimary, size: 22),
                onPressed: () => controller.clearSelection(),
              ),
              title: AppText(
                '$count Selected',
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textColorPrimary,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (isAllSelected) {
                      controller.clearSelection();
                    } else {
                      controller.selectAll();
                    }
                  },
                  child: AppText(
                    isAllSelected ? 'Deselect All' : 'Select All',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryColor,
                  ),
                ),
                IconButton(
                  icon: const Icon(Iconsax.trash, color: AppColors.errorColor, size: 20),
                  tooltip: 'Delete Selected',
                  onPressed: () => _showDeleteSelectedConfirmDialog(context, controller),
                ),
                const SizedBox(width: 8),
              ],
            );
          }

          return AppBar(
            backgroundColor: AppColors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textColorPrimary, size: 18),
              onPressed: () => Get.back(),
            ),
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppText(
                  'Notifications',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textColorPrimary,
                ),
                if (unread > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: AppText(
                      '$unread',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ],
            ),
            centerTitle: false,
            actions: [
              if (controller.notifications.isNotEmpty)
                IconButton(
                  icon: const Icon(Iconsax.trash, color: AppColors.errorColor, size: 20),
                  tooltip: 'Clear All',
                  onPressed: () => _showClearAllConfirmDialog(context, controller),
                ),
              const SizedBox(width: 8),
            ],
          );
        }),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value && controller.notifications.isEmpty) {
            return const _LoadingNotificationShimmer();
          }

          if (controller.errorMessage.isNotEmpty && controller.notifications.isEmpty) {
            return _ErrorNotificationPlaceholder(
              message: controller.errorMessage.value,
              onRetry: () => controller.fetchNotifications(),
            );
          }

          final list = controller.notifications;
          if (list.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => controller.fetchNotifications(isRefresh: true),
              color: AppColors.primaryColor,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: const _EmptyNotificationPlaceholder(),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => controller.fetchNotifications(isRefresh: true),
            color: AppColors.primaryColor,
            child: Column(
              children: [
                if (controller.unreadCount > 0)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AppText(
                          '${controller.unreadCount} unread',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textColorSecondary,
                        ),
                        InkWell(
                          borderRadius: BorderRadius.circular(6),
                          onTap: controller.isMarkingAllAsRead.value
                              ? null
                              : () => controller.markAllAsRead(),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.done_all_rounded, size: 15, color: AppColors.primaryColor),
                                const SizedBox(width: 4),
                                AppText(
                                  controller.isMarkingAllAsRead.value ? 'Marking...' : 'Read all',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: list.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = list[index];
                      return _NotificationCard(item: item, controller: controller);
                    },
                  ),
                ),
              ],
            ),
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
        content: const AppText(
          'Are you sure you want to delete all notifications?',
          fontSize: 13,
          color: AppColors.textColorSecondary,
        ),
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

  void _showDeleteSelectedConfirmDialog(BuildContext context, NotificationController controller) {
    final count = controller.selectedIds.length;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: AppText('Delete $count Notifications?', fontSize: 16, fontWeight: FontWeight.w700),
        content: AppText(
          'Are you sure you want to delete the $count selected notification(s)?',
          fontSize: 13,
          color: AppColors.textColorSecondary,
        ),
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
              Navigator.pop(context);
              controller.deleteSelected();
            },
            child: const AppText('Delete', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.white),
          ),
        ],
      ),
    );
  }
}

// ── LOADING SHIMMER ─────────────────────────────────────────────────────────
class _LoadingNotificationShimmer extends StatelessWidget {
  const _LoadingNotificationShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.slate100,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 140,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.slate100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.slate100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 80,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.slate100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── ERROR PLACEHOLDER ───────────────────────────────────────────────────────
class _ErrorNotificationPlaceholder extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorNotificationPlaceholder({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.errorColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconsax.warning_2,
                color: AppColors.errorColor,
                size: 44,
              ),
            ),
            const SizedBox(height: 16),
            const AppText(
              'Failed to Load Notifications',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textColorPrimary,
            ),
            const SizedBox(height: 6),
            AppText(
              message,
              fontSize: 12,
              color: AppColors.textColorSecondary,
              textAlign: TextAlign.center,
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 16, color: Colors.white),
              label: const AppText('Retry', fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ],
        ),
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
            decoration: const BoxDecoration(
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
    // Style configurations based on module, action, and type
    Color accentColor = AppColors.primaryColor;
    Color bgLightColor = AppColors.primaryLight;
    IconData visualIcon = Iconsax.notification;

    final module = item.module?.toLowerCase() ?? '';
    final action = item.action?.toLowerCase() ?? '';
    final type = item.type?.toLowerCase() ?? '';

    if (module == 'employees' || module == 'employee') {
      accentColor = const Color(0xFF10B981); // Emerald green
      bgLightColor = const Color(0xFFE8F8F0);
      visualIcon = Iconsax.profile_2user;
    } else if (module == 'logout' || action == 'logout') {
      accentColor = const Color(0xFFF97316); // Orange
      bgLightColor = const Color(0xFFFFF4ED);
      visualIcon = Iconsax.logout;
    } else if (module == 'shifts' || module == 'shift') {
      accentColor = const Color(0xFF8B5CF6); // Purple
      bgLightColor = const Color(0xFFF5F3FF);
      visualIcon = Iconsax.clock;
    } else if (module == 'leaves' || module == 'leave') {
      accentColor = AppColors.primaryShade400; // Sky blue
      bgLightColor = const Color(0xFFF0F9FF);
      visualIcon = Iconsax.calendar;
    } else if (module == 'attendance') {
      accentColor = const Color(0xFF059669); // Green
      bgLightColor = const Color(0xFFECFDF5);
      visualIcon = Iconsax.finger_scan;
    } else
    if (type == 'success' || action == 'created' || action == 'approved') {
      accentColor = AppColors.successColor;
      bgLightColor = const Color(0xFFEAFAF1);
      visualIcon = Iconsax.tick_circle;
    } else
    if (type == 'warning' || action == 'deleted' || action == 'rejected') {
      accentColor = AppColors.warningColor;
      bgLightColor = const Color(0xFFFEF9EC);
      visualIcon = Iconsax.warning_2;
    } else if (type == 'info') {
      accentColor = AppColors.primaryColor;
      bgLightColor = AppColors.primaryLight;
      visualIcon = Iconsax.info_circle;
    }

    final timeDisplay = (item.timeAgo != null && item.timeAgo!.isNotEmpty)
        ? item.timeAgo!
        : _formatTime(item.timestamp);

    return Obx(() {
      final isSelectionMode = controller.isSelectionMode.value;
      final isSelected = controller.selectedIds.contains(item.id.toString());

      return GestureDetector(
        onLongPress: () {
          HapticFeedback.mediumImpact();
          if (isSelectionMode) {
            controller.toggleSelection(item.id);
          } else {
            _showActionBottomSheet(context);
          }
        },
        onTap: () {
          if (isSelectionMode) {
            controller.toggleSelection(item.id);
          } else {
            Get.toNamed(
              AppRoutes.notificationDetails,
              arguments: item,
            );
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryColor.withValues(alpha: 0.05)
                : AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryColor
                  : (item.isRead ? AppColors.borderColor : AppColors
                  .primaryColor.withValues(alpha: 0.3)),
              width: isSelected ? 1.5 : (item.isRead ? 1 : 1.5),
            ),
            boxShadow: [
              BoxShadow(
                color: item.isRead
                    ? AppColors.black.withValues(alpha: 0.02)
                    : AppColors.primaryColor.withValues(alpha: 0.05),
                blurRadius: item.isRead ? 6 : 8,
                offset: const Offset(0, 2),
              )
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selection Checkbox
              if (isSelectionMode) ...[
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 22,
                  height: 22,
                  margin: const EdgeInsets.only(top: 8, right: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryColor : Colors
                        .transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.primaryColor : AppColors
                          .slate300,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
              ],

              // Left Custom Status Icon
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: bgLightColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(visualIcon, color: accentColor, size: 19),
              ),
              const SizedBox(width: 12),

              // Middle Title, description, tags, and time
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title + Unread indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: AppText(
                            item.title,
                            fontSize: 13,
                            fontWeight: item.isRead
                                ? FontWeight.w600
                                : FontWeight.w700,
                            color: AppColors.textColorPrimary,
                          ),
                        ),
                        // Small blue dot for unread status
                        if (!item.isRead) ...[
                          const SizedBox(width: 6),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                        // Single delete button on card
                        if (!isSelectionMode) ...[
                          const SizedBox(width: 8),
                          InkWell(
                            borderRadius: BorderRadius.circular(4),
                            onTap: () => _showDeleteConfirmDialog(context),
                            child: const Padding(
                              padding: EdgeInsets.all(2),
                              child: Icon(Iconsax.trash, size: 14, color: AppColors.textColorHint),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Message / Description
                    AppText(
                      item.message.isNotEmpty ? item.message : item.description,
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textColorSecondary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Metadata Row: Module Badge + Actor + Time Ago
                    Row(
                      children: [
                        if (item.module != null && item.module!.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: bgLightColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: AppText(
                              item.module!.toUpperCase(),
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: accentColor,
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        if (item.actor?.name != null && item.actor!.name!
                            .isNotEmpty) ...[
                          Icon(Iconsax.user, size: 10,
                              color: AppColors.textColorHint),
                          const SizedBox(width: 2),
                          Flexible(
                            child: AppText(
                              item.actor!.name!,
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textColorHint,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        const Icon(Iconsax.clock, size: 10, color: AppColors
                            .textColorHint),
                        const SizedBox(width: 3),
                        AppText(
                          timeDisplay,
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
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
    });
  }

  void _showActionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.check_circle_outline, color: AppColors.primaryColor),
                title: const AppText('Select Multiple', fontSize: 14, fontWeight: FontWeight.w600),
                onTap: () {
                  Navigator.pop(context);
                  controller.toggleSelection(item.id);
                },
              ),
              ListTile(
                leading: const Icon(Iconsax.trash, color: AppColors.errorColor),
                title: const AppText('Delete Notification', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.errorColor),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmDialog(context);
                },
              ),
            ],
          ),
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
