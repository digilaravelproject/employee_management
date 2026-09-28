class NotificationListResponseModel {
  final bool status;
  final String message;
  final int total;
  final int unreadCount;
  final List<NotificationModel> data;

  NotificationListResponseModel({
    required this.status,
    required this.message,
    required this.total,
    required this.unreadCount,
    required this.data,
  });

  factory NotificationListResponseModel.fromJson(Map<String, dynamic> json) {
    List<NotificationModel> notificationsList = [];
    if (json['data'] != null && json['data'] is List) {
      notificationsList = (json['data'] as List)
          .map((item) => NotificationModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return NotificationListResponseModel(
      status: json['status'] == true || json['status'] == 1 || json['status'] == 'true',
      message: json['message']?.toString() ?? '',
      total: _parseInt(json['total']) ?? notificationsList.length,
      unreadCount: _parseInt(json['unread_count']) ??
          notificationsList.where((element) => !element.isRead).length,
      data: notificationsList,
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'total': total,
        'unread_count': unreadCount,
        'data': data.map((x) => x.toJson()).toList(),
      };

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}

class NotificationModel {
  final dynamic id;
  final String? type;
  final String title;
  final String message;
  final String? module;
  final String? action;
  final String? entityType;
  final dynamic entityId;
  final NotificationPayloadData? data;
  bool isRead;
  final DateTime? readAt;
  final DateTime? createdAt;
  final String? timeAgo;
  final NotificationActor? actor;

  NotificationModel({
    required this.id,
    this.type,
    required this.title,
    required this.message,
    this.module,
    this.action,
    this.entityType,
    this.entityId,
    this.data,
    this.isRead = false,
    this.readAt,
    this.createdAt,
    this.timeAgo,
    this.actor,
  });

  // Backward compatibility getters
  String get description => message;
  DateTime get timestamp => createdAt ?? DateTime.now();
  String get idStr => id?.toString() ?? '';

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    bool isReadValue = false;
    if (json['is_read'] != null) {
      final val = json['is_read'];
      isReadValue = val == true || val == 1 || val == '1' || val.toString().toLowerCase() == 'true';
    }

    DateTime? parsedCreatedAt;
    if (json['created_at'] != null) {
      parsedCreatedAt = DateTime.tryParse(json['created_at'].toString())?.toLocal();
    }

    DateTime? parsedReadAt;
    if (json['read_at'] != null) {
      parsedReadAt = DateTime.tryParse(json['read_at'].toString())?.toLocal();
    }

    return NotificationModel(
      id: json['id'] ?? '',
      type: json['type']?.toString(),
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? json['description']?.toString() ?? '',
      module: json['module']?.toString(),
      action: json['action']?.toString(),
      entityType: json['entity_type']?.toString(),
      entityId: json['entity_id'],
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? NotificationPayloadData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      isRead: isReadValue,
      readAt: parsedReadAt,
      createdAt: parsedCreatedAt,
      timeAgo: json['time_ago']?.toString(),
      actor: json['actor'] != null && json['actor'] is Map<String, dynamic>
          ? NotificationActor.fromJson(json['actor'] as Map<String, dynamic>)
          : null,
    );
  }

  NotificationModel copyWith({
    dynamic id,
    String? type,
    String? title,
    String? message,
    String? module,
    String? action,
    String? entityType,
    dynamic entityId,
    NotificationPayloadData? data,
    bool? isRead,
    DateTime? readAt,
    DateTime? createdAt,
    String? timeAgo,
    NotificationActor? actor,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      module: module ?? this.module,
      action: action ?? this.action,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
      timeAgo: timeAgo ?? this.timeAgo,
      actor: actor ?? this.actor,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'title': title,
        'message': message,
        'module': module,
        'action': action,
        'entity_type': entityType,
        'entity_id': entityId,
        'data': data?.toJson(),
        'is_read': isRead,
        'read_at': readAt?.toIso8601String(),
        'created_at': createdAt?.toIso8601String(),
        'time_ago': timeAgo,
        'actor': actor?.toJson(),
      };
}

class NotificationDetailResponseModel {
  final bool status;
  final String message;
  final NotificationModel? data;

  NotificationDetailResponseModel({
    required this.status,
    required this.message,
    this.data,
  });

  factory NotificationDetailResponseModel.fromJson(Map<String, dynamic> json) {
    NotificationModel? notification;
    if (json['data'] != null && json['data'] is Map<String, dynamic>) {
      notification = NotificationModel.fromJson(json['data'] as Map<String, dynamic>);
    }

    return NotificationDetailResponseModel(
      status: json['status'] == true || json['status'] == 1 || json['status'] == 'true',
      message: json['message']?.toString() ?? '',
      data: notification,
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'data': data?.toJson(),
      };
}

class NotificationPayloadData {
  final String? method;
  final String? path;
  final Map<String, dynamic>? raw;

  NotificationPayloadData({
    this.method,
    this.path,
    this.raw,
  });

  factory NotificationPayloadData.fromJson(Map<String, dynamic> json) {
    return NotificationPayloadData(
      method: json['method']?.toString(),
      path: json['path']?.toString(),
      raw: json,
    );
  }

  Map<String, dynamic> toJson() => {
        'method': method,
        'path': path,
        ...?raw,
      };
}

class NotificationActor {
  final dynamic id;
  final String? name;
  final String? avatar;

  NotificationActor({
    this.id,
    this.name,
    this.avatar,
  });

  factory NotificationActor.fromJson(Map<String, dynamic> json) {
    return NotificationActor(
      id: json['id'],
      name: json['name']?.toString(),
      avatar: json['avatar']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'avatar': avatar,
      };
}
