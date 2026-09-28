import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/network/api_client.dart';
import '../../../../core/services/network/response_model.dart';
import '../../../../core/utils/logger.dart';
import '../models/notification_model.dart';
import 'notification_repository_interface.dart';

class NotificationRepository implements NotificationRepositoryInterface {
  final ApiClient apiClient;

  NotificationRepository({required this.apiClient});

  @override
  Future<NotificationListResponseModel> getNotifications() async {
    try {
      Logger.d('NotificationRepository => Fetching notifications from: ${AppConstants.adminNotificationsUrl}');
      final response = await apiClient.get(
        AppConstants.adminNotificationsUrl,
        handleError: false,
        showToaster: false,
      );

      Logger.d('NotificationRepository => Response statusCode: ${response.statusCode}, isSuccess: ${response.isSuccess}');

      if (response.json != null && response.json is Map<String, dynamic>) {
        return NotificationListResponseModel.fromJson(response.json!);
      } else if (response.body is Map<String, dynamic>) {
        return NotificationListResponseModel.fromJson(response.body as Map<String, dynamic>);
      } else if (response.body is List) {
        final list = (response.body as List)
            .map((item) => NotificationModel.fromJson(item as Map<String, dynamic>))
            .toList();
        return NotificationListResponseModel(
          status: response.isSuccess,
          message: response.message,
          total: list.length,
          unreadCount: list.where((n) => !n.isRead).length,
          data: list,
        );
      } else {
        return NotificationListResponseModel(
          status: response.isSuccess,
          message: response.message.isNotEmpty
              ? response.message
              : (response.isSuccess ? 'Notifications retrieved successfully.' : 'Failed to retrieve notifications.'),
          total: 0,
          unreadCount: 0,
          data: [],
        );
      }
    } catch (e, stackTrace) {
      Logger.e('NotificationRepository => Error fetching notifications: $e');
      Logger.e('NotificationRepository => StackTrace: $stackTrace');
      return NotificationListResponseModel(
        status: false,
        message: 'Something went wrong while fetching notifications: ${e.toString()}',
        total: 0,
        unreadCount: 0,
        data: [],
      );
    }
  }

  @override
  Future<NotificationDetailResponseModel> getNotificationDetail(dynamic id) async {
    try {
      final url = '${AppConstants.adminNotificationsUrl}/$id';
      Logger.d('NotificationRepository => Fetching notification detail from: $url');
      final response = await apiClient.get(
        url,
        handleError: false,
        showToaster: false,
      );

      Logger.d('NotificationRepository => Detail response statusCode: ${response.statusCode}, isSuccess: ${response.isSuccess}');

      if (response.json != null && response.json is Map<String, dynamic>) {
        return NotificationDetailResponseModel.fromJson(response.json!);
      } else if (response.body is Map<String, dynamic>) {
        return NotificationDetailResponseModel.fromJson(response.body as Map<String, dynamic>);
      } else {
        return NotificationDetailResponseModel(
          status: response.isSuccess,
          message: response.message.isNotEmpty
              ? response.message
              : (response.isSuccess ? 'Notification retrieved successfully.' : 'Failed to retrieve notification.'),
          data: null,
        );
      }
    } catch (e, stackTrace) {
      Logger.e('NotificationRepository => Error fetching notification detail: $e');
      Logger.e('NotificationRepository => StackTrace: $stackTrace');
      return NotificationDetailResponseModel(
        status: false,
        message: 'Something went wrong while fetching notification detail: ${e.toString()}',
        data: null,
      );
    }
  }

  @override
  Future<ResponseModel> markAsRead(dynamic id) async {
    try {
      final url = '${AppConstants.adminNotificationsUrl}/$id/read';
      Logger.d('NotificationRepository => Marking notification $id as read via PATCH: $url');
      final response = await apiClient.patch(
        url,
        handleError: false,
        showToaster: false,
      );
      return response;
    } catch (e) {
      Logger.e('NotificationRepository => Error marking notification as read: $e');
      return ResponseModel(
        isSuccess: false,
        message: e.toString(),
      );
    }
  }

  @override
  Future<ResponseModel> markAllAsRead() async {
    try {
      final url = '${AppConstants.adminNotificationsUrl}/read-all';
      Logger.d('NotificationRepository => Marking all notifications as read via PATCH: $url');
      final response = await apiClient.patch(
        url,
        handleError: false,
        showToaster: false,
      );
      return response;
    } catch (e) {
      Logger.e('NotificationRepository => Error marking all notifications as read: $e');
      return ResponseModel(
        isSuccess: false,
        message: e.toString(),
      );
    }
  }

  @override
  Future<ResponseModel> deleteNotification(dynamic id) async {
    try {
      final url = '${AppConstants.adminNotificationsUrl}/$id';
      Logger.d('NotificationRepository => Deleting notification via DELETE: $url');
      final response = await apiClient.delete(
        url,
        handleError: false,
        showToaster: false,
      );
      return response;
    } catch (e) {
      Logger.e('NotificationRepository => Error deleting notification: $e');
      return ResponseModel(
        isSuccess: false,
        message: e.toString(),
      );
    }
  }

  @override
  Future<ResponseModel> clearAllNotifications({List<dynamic>? ids}) async {
    try {
      final url = AppConstants.adminNotificationsUrl;
      Logger.d('NotificationRepository => Deleting notifications via DELETE: $url (ids: $ids)');
      final response = await apiClient.delete(
        url,
        data: (ids != null && ids.isNotEmpty) ? {'ids': ids} : null,
        handleError: false,
        showToaster: false,
      );
      return response;
    } catch (e) {
      Logger.e('NotificationRepository => Error deleting notifications: $e');
      return ResponseModel(
        isSuccess: false,
        message: e.toString(),
      );
    }
  }
}
