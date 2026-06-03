class ChatConversation {
  final String id;
  final String name;
  final String avatarUrl;
  final String designation;
  String lastMessage;
  DateTime lastMessageTime;
  int unreadCount;
  final bool isGroup;
  final bool isOnline;

  ChatConversation({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.designation,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.isGroup = false,
    this.isOnline = false,
  });

  ChatConversation copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    String? designation,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
    bool? isGroup,
    bool? isOnline,
  }) {
    return ChatConversation(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      designation: designation ?? this.designation,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      isGroup: isGroup ?? this.isGroup,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String senderAvatar;
  final String text;
  final DateTime timestamp;
  final bool isMe;
  final String? mediaType; // 'image', 'document', 'audio'
  final String? mediaUrl;
  final String? fileName;
  final String? fileSize;
  bool isDelivered;
  bool isRead;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderAvatar,
    required this.text,
    required this.timestamp,
    this.isMe = true,
    this.mediaType,
    this.mediaUrl,
    this.fileName,
    this.fileSize,
    this.isDelivered = true,
    this.isRead = true,
  });
}
