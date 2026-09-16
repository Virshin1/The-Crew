class MessageReaction {
  final String emoji;
  final int count;
  final List<String> users;

  const MessageReaction({
    required this.emoji,
    required this.count,
    required this.users,
  });

  factory MessageReaction.fromJson(Map<String, dynamic> json) {
    return MessageReaction(
      emoji: json['emoji'] as String? ?? '🔥',
      count: json['count'] as int? ?? 1,
      users: (json['users'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class MessageModel {
  final String id;
  final String channelId;
  final String senderId;
  final String? content;
  final bool hasMedia;
  final String? mediaUrl;
  final String? mediaTitle;
  final String? mediaDuration;
  final String createdAt;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final String status;
  final String? senderRole;
  final List<MessageReaction> reactions;

  const MessageModel({
    required this.id,
    required this.channelId,
    required this.senderId,
    this.content,
    this.hasMedia = false,
    this.mediaUrl,
    this.mediaTitle,
    this.mediaDuration,
    required this.createdAt,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    this.status = 'online',
    this.senderRole,
    this.reactions = const [],
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String? ?? '',
      channelId: json['channel_id'] as String? ?? '',
      senderId: json['sender_id'] as String? ?? '',
      content: json['content'] as String?,
      hasMedia: json['has_media'] == true || json['has_media'] == 1,
      mediaUrl: json['media_url'] as String?,
      mediaTitle: json['media_title'] as String?,
      mediaDuration: json['media_duration'] as String?,
      createdAt: json['created_at'] as String? ?? 'Just now',
      username: json['username'] as String? ?? 'user',
      displayName: json['display_name'] as String? ?? json['username'] as String? ?? 'User',
      avatarUrl: json['avatar_url'] as String?,
      status: json['status'] as String? ?? 'online',
      senderRole: json['sender_role'] as String?,
      reactions: (json['reactions'] as List<dynamic>?)
              ?.map((r) => MessageReaction.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  MessageModel copyWith({
    List<MessageReaction>? reactions,
  }) {
    return MessageModel(
      id: id,
      channelId: channelId,
      senderId: senderId,
      content: content,
      hasMedia: hasMedia,
      mediaUrl: mediaUrl,
      mediaTitle: mediaTitle,
      mediaDuration: mediaDuration,
      createdAt: createdAt,
      username: username,
      displayName: displayName,
      avatarUrl: avatarUrl,
      status: status,
      senderRole: senderRole,
      reactions: reactions ?? this.reactions,
    );
  }
}
