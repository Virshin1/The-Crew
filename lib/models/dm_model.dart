class DmConversationModel {
  final String partnerId;
  final String displayName;
  final String username;
  final String? avatarUrl;
  final String status;
  final String? customStatus;
  final String lastMessage;
  final String lastMessageTime;
  final int unreadCount;

  const DmConversationModel({
    required this.partnerId,
    required this.displayName,
    required this.username,
    this.avatarUrl,
    this.status = 'online',
    this.customStatus,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
  });

  bool get isOnline => status != 'offline';

  factory DmConversationModel.fromJson(Map<String, dynamic> json) {
    return DmConversationModel(
      partnerId: json['partner_id'] as String? ?? json['id'] as String? ?? '',
      displayName: json['display_name'] as String? ?? json['username'] as String? ?? 'Crew Friend',
      username: json['username'] as String? ?? 'friend',
      avatarUrl: json['avatar_url'] as String?,
      status: json['status'] as String? ?? 'online',
      customStatus: json['custom_status'] as String?,
      lastMessage: json['last_message'] as String? ?? '',
      lastMessageTime: json['last_message_time'] as String? ?? 'Just now',
      unreadCount: json['unread_count'] as int? ?? 0,
    );
  }
}

class DmMessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final bool isRead;
  final String createdAt;
  final String? senderName;
  final String? senderAvatar;

  const DmMessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    this.isRead = false,
    required this.createdAt,
    this.senderName,
    this.senderAvatar,
  });

  String get timeDisplay {
    try {
      final dt = DateTime.parse(createdAt);
      final hour = dt.hour.toString().padLeft(2, '0');
      final min = dt.minute.toString().padLeft(2, '0');
      return '$hour:$min';
    } catch (_) {
      return createdAt;
    }
  }

  factory DmMessageModel.fromJson(Map<String, dynamic> json) {
    return DmMessageModel(
      id: json['id'] as String? ?? '',
      senderId: json['sender_id'] as String? ?? '',
      receiverId: json['receiver_id'] as String? ?? '',
      content: json['content'] as String? ?? '',
      isRead: json['is_read'] == 1 || json['is_read'] == true,
      createdAt: json['created_at'] as String? ?? 'Just now',
      senderName: json['sender_name'] as String?,
      senderAvatar: json['sender_avatar'] as String?,
    );
  }
}
