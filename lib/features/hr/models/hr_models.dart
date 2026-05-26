class CompanyPolicy {
  final String id;
  final String title;
  final String type; // HR Policies, Work Policies, Leave Policies
  final DateTime updatedDate;
  final String description;

  CompanyPolicy({
    required this.id,
    required this.title,
    required this.type,
    required this.updatedDate,
    required this.description,
  });

  CompanyPolicy copyWith({
    String? id,
    String? title,
    String? type,
    DateTime? updatedDate,
    String? description,
  }) {
    return CompanyPolicy(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      updatedDate: updatedDate ?? this.updatedDate,
      description: description ?? this.description,
    );
  }
}

class HrAnnouncement {
  final String id;
  final String title;
  final String type; // General, Holiday, Reminder, Urgent
  final DateTime publishDate;
  final String priority; // Low, Normal, High, Urgent
  final bool isPinned;
  final String content;

  HrAnnouncement({
    required this.id,
    required this.title,
    required this.type,
    required this.publishDate,
    required this.priority,
    this.isPinned = false,
    required this.content,
  });

  HrAnnouncement copyWith({
    String? id,
    String? title,
    String? type,
    DateTime? publishDate,
    String? priority,
    bool? isPinned,
    String? content,
  }) {
    return HrAnnouncement(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      publishDate: publishDate ?? this.publishDate,
      priority: priority ?? this.priority,
      isPinned: isPinned ?? this.isPinned,
      content: content ?? this.content,
    );
  }
}

class EngagementUpdate {
  final String id;
  final String title;
  final String category; // Team Outing, Work Anniversary, Employee of the Month, Wellness Webinar
  final String description;
  final String timeAgo;
  final String? imageAsset; // Mock local path or asset

  EngagementUpdate({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.timeAgo,
    this.imageAsset,
  });
}
