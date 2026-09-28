import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/logger.dart';
import '../models/notification_model.dart';
import '../repositories/notification_repository.dart';
import '../repositories/notification_repository_interface.dart';

class NotificationController extends GetxController {
  final NotificationRepositoryInterface repository;

  NotificationController({NotificationRepositoryInterface? repository})
      : repository = repository ??
            (Get.isRegistered<NotificationRepositoryInterface>()
                ? Get.find<NotificationRepositoryInterface>()
                : NotificationRepository(
                    apiClient: Get.isRegistered<ApiClient>()
                        ? Get.find<ApiClient>()
                        : ApiClient(),
                  ));

  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt totalCount = 0.obs;
  final RxInt serverUnreadCount = 0.obs;

  // Single Notification Detail State
  final Rx<NotificationModel?> selectedNotification = Rx<NotificationModel?>(null);
  final RxBool isDetailLoading = false.obs;
  final RxString detailErrorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  /// Calculates real-time unread count from the active list
  int get unreadCount => notifications.where((n) => !n.isRead).length;

  /// Fetch notifications from backend API
  Future<void> fetchNotifications({bool isRefresh = false}) async {
    if (isRefresh) {
      isRefreshing.value = true;
    } else {
      isLoading.value = true;
    }
    errorMessage.value = '';

    try {
      final response = await repository.getNotifications();
      if (response.status) {
        notifications.assignAll(response.data);
        totalCount.value = response.total;
        serverUnreadCount.value = response.unreadCount;
      } else {
        errorMessage.value = response.message.isNotEmpty
            ? response.message
            : 'Failed to fetch notifications.';
      }
    } catch (e) {
      errorMessage.value = 'An error occurred: ${e.toString()}';
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  /// Fetch single notification detail by ID from backend API
  Future<NotificationModel?> fetchNotificationDetail(dynamic id) async {
    isDetailLoading.value = true;
    detailErrorMessage.value = '';

    try {
      final response = await repository.getNotificationDetail(id);
      if (response.status && response.data != null) {
        selectedNotification.value = response.data;
        // Also update the notification in the list if already loaded
        final index = notifications.indexWhere((n) => n.id.toString() == id.toString());
        if (index != -1) {
          notifications[index] = response.data!;
          notifications.refresh();
        }
        return response.data;
      } else {
        detailErrorMessage.value = response.message.isNotEmpty
            ? response.message
            : 'Failed to retrieve notification details.';
        return null;
      }
    } catch (e) {
      detailErrorMessage.value = 'An error occurred: ${e.toString()}';
      return null;
    } finally {
      isDetailLoading.value = false;
    }
  }

  final RxBool isMarkingAllAsRead = false.obs;

  /// Mark single notification as read
  Future<void> markAsRead(dynamic id) async {
    final index = notifications.indexWhere((n) => n.id.toString() == id.toString());
    if (index != -1 && !notifications[index].isRead) {
      notifications[index].isRead = true;
      notifications.refresh();
    }
    if (selectedNotification.value != null &&
        selectedNotification.value!.id.toString() == id.toString() &&
        !selectedNotification.value!.isRead) {
      selectedNotification.value = selectedNotification.value!.copyWith(isRead: true);
    }

    try {
      final response = await repository.markAsRead(id);
      if (response.isSuccess && response.json != null && response.json is Map<String, dynamic>) {
        final json = response.json!;
        if (json['data'] != null && json['data'] is Map<String, dynamic>) {
          final updated = NotificationModel.fromJson(json['data'] as Map<String, dynamic>);
          if (index != -1) {
            notifications[index] = updated;
            notifications.refresh();
          }
          if (selectedNotification.value?.id.toString() == id.toString()) {
            selectedNotification.value = updated;
          }
        }
      }
    } catch (e) {
      Logger.e('NotificationController => markAsRead error: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    if (notifications.isEmpty || notifications.every((n) => n.isRead)) {
      return;
    }
    isMarkingAllAsRead.value = true;
    for (var n in notifications) {
      n.isRead = true;
    }
    serverUnreadCount.value = 0;
    notifications.refresh();

    try {
      final response = await repository.markAllAsRead();
      if (response.isSuccess) {
        Get.snackbar(
          'Notifications',
          'All notifications marked as read.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF1E293B),
          colorText: const Color(0xFFF8FAFC),
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(12),
          borderRadius: 8,
          icon: const Icon(Icons.done_all_rounded, color: AppColors.successColor),
        );
      }
    } catch (e) {
      Logger.e('NotificationController => markAllAsRead error: $e');
    } finally {
      isMarkingAllAsRead.value = false;
    }
  }

  final RxBool isDeleting = false.obs;
  final RxSet<String> selectedIds = <String>{}.obs;
  final RxBool isSelectionMode = false.obs;

  /// Selection Mode Helpers
  void toggleSelection(dynamic id) {
    final strId = id.toString();
    if (selectedIds.contains(strId)) {
      selectedIds.remove(strId);
      if (selectedIds.isEmpty) {
        isSelectionMode.value = false;
      }
    } else {
      selectedIds.add(strId);
      isSelectionMode.value = true;
    }
  }

  void selectAll() {
    selectedIds.assignAll(notifications.map((n) => n.id.toString()));
    isSelectionMode.value = true;
  }

  void clearSelection() {
    selectedIds.clear();
    isSelectionMode.value = false;
  }

  /// Delete a single notification via DELETE /api/admin/notifications/{id}
  Future<bool> deleteNotification(dynamic id) async {
    isDeleting.value = true;
    final itemIndex = notifications.indexWhere((n) => n.id.toString() == id.toString());
    NotificationModel? removedItem;
    if (itemIndex != -1) {
      removedItem = notifications.removeAt(itemIndex);
      totalCount.value = (totalCount.value - 1).clamp(0, 999999);
      if (removedItem.isRead == false) {
        serverUnreadCount.value = (serverUnreadCount.value - 1).clamp(0, 999999);
      }
      notifications.refresh();
    }
    if (selectedNotification.value?.id.toString() == id.toString()) {
      selectedNotification.value = null;
    }

    try {
      final response = await repository.deleteNotification(id);
      if (response.isSuccess) {
        Get.snackbar(
          'Deleted',
          response.message.isNotEmpty ? response.message : 'Notification deleted successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF1E293B),
          colorText: const Color(0xFFF8FAFC),
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(12),
          borderRadius: 8,
          icon: const Icon(Icons.check_circle_outline, color: AppColors.successColor),
        );
        return true;
      } else {
        // Rollback
        if (removedItem != null && itemIndex != -1) {
          notifications.insert(itemIndex, removedItem);
          notifications.refresh();
        }
        Get.snackbar(
          'Error',
          response.message.isNotEmpty ? response.message : 'Failed to delete notification.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF1E293B),
          colorText: const Color(0xFFF8FAFC),
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(12),
          borderRadius: 8,
          icon: const Icon(Icons.error_outline, color: AppColors.errorColor),
        );
        return false;
      }
    } catch (e) {
      if (removedItem != null && itemIndex != -1) {
        notifications.insert(itemIndex, removedItem);
        notifications.refresh();
      }
      Logger.e('NotificationController => deleteNotification error: $e');
      return false;
    } finally {
      isDeleting.value = false;
    }
  }

  /// Delete selected multiple notifications
  Future<bool> deleteSelected() async {
    if (selectedIds.isEmpty) return false;

    // If all items are selected, call clearAll directly
    if (selectedIds.length >= notifications.length) {
      clearSelection();
      return await clearAll();
    }

    isDeleting.value = true;
    final idsToDelete = selectedIds.toList();
    final previousList = List<NotificationModel>.from(notifications);

    // Remove locally for immediate UI update
    notifications.removeWhere((n) => idsToDelete.contains(n.id.toString()));
    totalCount.value = notifications.length;
    notifications.refresh();
    clearSelection();

    try {
      final response = await repository.clearAllNotifications(ids: idsToDelete);
      if (response.isSuccess) {
        Get.snackbar(
          'Deleted',
          response.message.isNotEmpty ? response.message : '${idsToDelete.length} notifications deleted.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF1E293B),
          colorText: const Color(0xFFF8FAFC),
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(12),
          borderRadius: 8,
          icon: const Icon(Icons.check_circle_outline, color: AppColors.successColor),
        );
        return true;
      } else {
        // Rollback on failure
        notifications.assignAll(previousList);
        totalCount.value = notifications.length;
        Get.snackbar(
          'Error',
          response.message.isNotEmpty ? response.message : 'Failed to delete selected notifications.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF1E293B),
          colorText: const Color(0xFFF8FAFC),
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(12),
          borderRadius: 8,
          icon: const Icon(Icons.error_outline, color: AppColors.errorColor),
        );
        return false;
      }
    } catch (e) {
      notifications.assignAll(previousList);
      totalCount.value = notifications.length;
      Logger.e('NotificationController => deleteSelected error: $e');
      return false;
    } finally {
      isDeleting.value = false;
    }
  }

  /// Delete all notifications via DELETE /api/admin/notifications
  Future<bool> clearAll() async {
    if (notifications.isEmpty) return false;
    isDeleting.value = true;
    final previousList = List<NotificationModel>.from(notifications);
    notifications.clear();
    totalCount.value = 0;
    serverUnreadCount.value = 0;

    try {
      final response = await repository.clearAllNotifications();
      if (response.isSuccess) {
        Get.snackbar(
          'All Cleared',
          response.message.isNotEmpty ? response.message : 'All notifications have been cleared.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF1E293B),
          colorText: const Color(0xFFF8FAFC),
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(12),
          borderRadius: 8,
          icon: const Icon(Icons.check_circle_outline, color: AppColors.successColor),
        );
        return true;
      } else {
        // Rollback
        notifications.assignAll(previousList);
        totalCount.value = notifications.length;
        Get.snackbar(
          'Error',
          response.message.isNotEmpty ? response.message : 'Failed to clear all notifications.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF1E293B),
          colorText: const Color(0xFFF8FAFC),
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(12),
          borderRadius: 8,
          icon: const Icon(Icons.error_outline, color: AppColors.errorColor),
        );
        return false;
      }
    } catch (e) {
      notifications.assignAll(previousList);
      totalCount.value = notifications.length;
      Logger.e('NotificationController => clearAll error: $e');
      return false;
    } finally {
      isDeleting.value = false;
    }
  }
}
