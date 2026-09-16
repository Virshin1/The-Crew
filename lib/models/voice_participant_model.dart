class VoiceParticipantModel {
  final String channelId;
  final String userId;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final bool isSpeaking;
  final bool isMuted;
  final bool isStreaming;
  final String statusText;

  const VoiceParticipantModel({
    required this.channelId,
    required this.userId,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    this.isSpeaking = false,
    this.isMuted = false,
    this.isStreaming = false,
    this.statusText = 'Listening',
  });

  factory VoiceParticipantModel.fromJson(Map<String, dynamic> json) {
    return VoiceParticipantModel(
      channelId: json['channel_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      username: json['username'] as String? ?? '',
      displayName: json['display_name'] as String? ?? json['username'] as String? ?? 'User',
      avatarUrl: json['avatar_url'] as String?,
      isSpeaking: json['is_speaking'] == 1 || json['is_speaking'] == true,
      isMuted: json['is_muted'] == 1 || json['is_muted'] == true,
      isStreaming: json['is_streaming'] == 1 || json['is_streaming'] == true,
      statusText: json['status_text'] as String? ?? 'Listening',
    );
  }

  VoiceParticipantModel copyWith({
    bool? isSpeaking,
    bool? isMuted,
    bool? isStreaming,
    String? statusText,
  }) {
    return VoiceParticipantModel(
      channelId: channelId,
      userId: userId,
      username: username,
      displayName: displayName,
      avatarUrl: avatarUrl,
      isSpeaking: isSpeaking ?? this.isSpeaking,
      isMuted: isMuted ?? this.isMuted,
      isStreaming: isStreaming ?? this.isStreaming,
      statusText: statusText ?? this.statusText,
    );
  }
}
