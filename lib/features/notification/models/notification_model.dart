class NotificationModel {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final String type; // 'success', 'warning', 'info', 'general'
  bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.type,
    this.isRead = false,
  });
}
