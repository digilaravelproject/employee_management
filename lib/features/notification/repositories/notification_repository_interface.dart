import '../../../../core/services/network/response_model.dart';
import '../models/notification_model.dart';

abstract class NotificationRepositoryInterface {
  /// Fetch all notifications for the authenticated admin
  Future<NotificationListResponseModel> getNotifications();

  /// Fetch a single notification detail by ID
  Future<NotificationDetailResponseModel> getNotificationDetail(dynamic id);

  /// Mark a specific notification as read
  Future<ResponseModel> markAsRead(dynamic id);

  /// Mark all notifications as read
  Future<ResponseModel> markAllAsRead();

  /// Delete a notification by ID
  Future<ResponseModel> deleteNotification(dynamic id);

  /// Clear all / multiple notifications
  Future<ResponseModel> clearAllNotifications({List<dynamic>? ids});
}
