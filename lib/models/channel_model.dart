class ChannelModel {
  final String id;
  final String serverId;
  final String name;
  final String type; // 'text' or 'voice'
  final String? topic;
  final int position;

  const ChannelModel({
    required this.id,
    required this.serverId,
    required this.name,
    this.type = 'text',
    this.topic,
    this.position = 0,
  });

  bool get isVoice => type == 'voice';
  bool get isText => type == 'text';

  factory ChannelModel.fromJson(Map<String, dynamic> json) {
    return ChannelModel(
      id: json['id'] as String? ?? '',
      serverId: json['server_id'] as String? ?? '',
      name: json['name'] as String? ?? 'general',
      type: json['type'] as String? ?? 'text',
      topic: json['topic'] as String?,
      position: json['position'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'server_id': serverId,
      'name': name,
      'type': type,
      'topic': topic,
      'position': position,
    };
  }
}
