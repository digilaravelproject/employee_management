import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/notification_controller.dart';
import '../models/notification_model.dart';

class NotificationDetailsScreen extends StatefulWidget {
  final NotificationModel? notification;
  final dynamic notificationId;

  const NotificationDetailsScreen({
    super.key,
    this.notification,
    this.notificationId,
  });

  @override
  State<NotificationDetailsScreen> createState() => _NotificationDetailsScreenState();
}

class _NotificationDetailsScreenState extends State<NotificationDetailsScreen> {
  late final NotificationController _controller;
  NotificationModel? _currentNotification;
  dynamic _resolvedId;

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<NotificationController>()
        ? Get.find<NotificationController>()
        : Get.put(NotificationController());

    _resolveInitialData();

    // Mark as read when notification opens and fetch latest details
    if (_resolvedId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.markAsRead(_resolvedId);
        _controller.fetchNotificationDetail(_resolvedId);
      });
    }
  }

  void _resolveInitialData() {
    if (widget.notification != null) {
      _currentNotification = widget.notification;
      _resolvedId = widget.notification!.id;
      _controller.selectedNotification.value = widget.notification;
    } else if (widget.notificationId != null) {
      _resolvedId = widget.notificationId;
    } else if (Get.arguments != null) {
      final args = Get.arguments;
      if (args is NotificationModel) {
        _currentNotification = args;
        _resolvedId = args.id;
        _controller.selectedNotification.value = args;
      } else if (args is Map<String, dynamic>) {
        if (args.containsKey('notification') && args['notification'] is NotificationModel) {
          _currentNotification = args['notification'] as NotificationModel;
          _resolvedId = _currentNotification!.id;
          _controller.selectedNotification.value = _currentNotification;
        } else if (args.containsKey('id')) {
          _resolvedId = args['id'];
        }
      } else {
        _resolvedId = args;
      }
    }
  }

  String _formatTimeDisplay(NotificationModel item) {
    if (item.timeAgo != null && item.timeAgo!.isNotEmpty) {
      if (item.createdAt != null) {
        final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(item.createdAt!);
        return '${item.timeAgo!} • $formattedDate';
      }
      return item.timeAgo!;
    }
    if (item.createdAt != null) {
      return DateFormat('dd MMM yyyy, hh:mm a').format(item.createdAt!);
    }
    return '';
  }

  void _showDeleteDialog(BuildContext context, dynamic id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const AppText(
          'Delete Notification?',
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.textColorPrimary,
        ),
        content: const AppText(
          'Are you sure you want to delete this notification?',
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
              Navigator.pop(context);
              _controller.deleteNotification(id);
              Get.back();
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

  @override
  Widget build(BuildContext context) {
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
          'Notification',
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppColors.textColorPrimary,
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.trash, color: AppColors.errorColor, size: 20),
            tooltip: 'Delete Notification',
            onPressed: () {
              final activeItem = _controller.selectedNotification.value ?? _currentNotification;
              if (activeItem != null) {
                _showDeleteDialog(context, activeItem.id);
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          final isLoading = _controller.isDetailLoading.value;
          final errorMsg = _controller.detailErrorMessage.value;
          final item = _controller.selectedNotification.value ?? _currentNotification;

          if (isLoading && item == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            );
          }

          if (errorMsg.isNotEmpty && item == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Iconsax.warning_2, color: AppColors.errorColor, size: 40),
                    const SizedBox(height: 12),
                    AppText(
                      errorMsg,
                      fontSize: 13,
                      color: AppColors.textColorSecondary,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        if (_resolvedId != null) {
                          _controller.fetchNotificationDetail(_resolvedId);
                        }
                      },
                      child: const AppText('Retry', fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ],
                ),
              ),
            );
          }

          if (item == null) {
            return const Center(
              child: AppText(
                'No notification details found.',
                fontSize: 14,
                color: AppColors.textColorSecondary,
              ),
            );
          }

          final timeText = _formatTimeDisplay(item);

          return RefreshIndicator(
            color: AppColors.primaryColor,
            onRefresh: () async {
              if (_resolvedId != null) {
                await _controller.fetchNotificationDetail(_resolvedId);
              }
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                // Clean Notification Card
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      AppText(
                        item.title,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textColorPrimary,
                      ),
                      const SizedBox(height: 8),

                      // Time
                      if (timeText.isNotEmpty) ...[
                        Row(
                          children: [
                            const Icon(
                              Iconsax.clock,
                              size: 14,
                              color: AppColors.textColorHint,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: AppText(
                                timeText,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textColorHint,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(height: 1, color: AppColors.borderColor),
                        const SizedBox(height: 16),
                      ],

                      // Message Content
                      SelectableText(
                        item.message.isNotEmpty ? item.message : 'No message provided.',
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textColorSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
