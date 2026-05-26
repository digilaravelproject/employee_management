import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/notification_model.dart';

class NotificationController extends GetxController {
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadMockNotifications();
  }

  void _loadMockNotifications() {
    notifications.assignAll([
      NotificationModel(
        id: '1',
        title: 'Leave Request Approved',
        description: 'Your sick leave request for 21 May has been approved by HR.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
        type: 'success',
      ),
      NotificationModel(
        id: '2',
        title: 'Late Check-In Alert',
        description: 'You checked in 15 minutes late today. Please update remarks.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        type: 'warning',
      ),
      NotificationModel(
        id: '3',
        title: 'New Shift Schedule',
        description: 'Your shift schedule for next week has been published by your manager.',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        type: 'info',
      ),
      NotificationModel(
        id: '4',
        title: 'Holiday Calendar Updated',
        description: 'A new restricted holiday has been added to the calendar.',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        type: 'general',
      ),
    ]);
  }

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  void markAsRead(String id) {
    final index = notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      notifications[index].isRead = true;
      notifications.refresh();
    }
  }

  void deleteNotification(String id) {
    notifications.removeWhere((n) => n.id == id);
    Get.snackbar(
      'Notification Deleted',
      'The notification has been removed.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF1E293B),
      colorText: const Color(0xFFF8FAFC),
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(12),
      borderRadius: 8,
    );
  }

  void clearAll() {
    notifications.clear();
    Get.snackbar(
      'All Cleared',
      'All notifications have been cleared.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF1E293B),
      colorText: const Color(0xFFF8FAFC),
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(12),
      borderRadius: 8,
    );
  }
}
