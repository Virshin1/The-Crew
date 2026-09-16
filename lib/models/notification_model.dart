class NotificationModel {
  final String id;
  final String userId;
  final String? actorId;
  final String type; // 'mention', 'reaction', 'friend', 'voice', 'system', 'server'
  final String title;
  final String body;
  final String timeDisplay;
  final bool isRead;
  final String? actorUsername;
  final String? actorDisplayName;
  final String? actorAvatar;

  const NotificationModel({
    required this.id,
    required this.userId,
    this.actorId,
    required this.type,
    required this.title,
    required this.body,
    this.timeDisplay = 'Just now',
    this.isRead = false,
    this.actorUsername,
    this.actorDisplayName,
    this.actorAvatar,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      actorId: json['actor_id'] as String?,
      type: json['type'] as String? ?? 'system',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      timeDisplay: json['time_display'] as String? ?? 'Just now',
      isRead: json['is_read'] == 1 || json['is_read'] == true,
      actorUsername: json['actor_username'] as String?,
      actorDisplayName: json['actor_display_name'] as String?,
      actorAvatar: json['actor_avatar'] as String?,
    );
  }
}
