class ServerModel {
  final String id;
  final String name;
  final String? description;
  final String? iconUrl;
  final String iconColor;
  final String ownerId;
  final String category;
  final bool isPublic;
  final String level;
  final int memberCount;
  final int onlineCount;
  final String? myRole;

  const ServerModel({
    required this.id,
    required this.name,
    this.description,
    this.iconUrl,
    this.iconColor = '#9D4EDD',
    required this.ownerId,
    this.category = 'Gaming',
    this.isPublic = true,
    this.level = 'LVL 1',
    this.memberCount = 1,
    this.onlineCount = 1,
    this.myRole,
  });

  factory ServerModel.fromJson(Map<String, dynamic> json) {
    return ServerModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Community Server',
      description: json['description'] as String?,
      iconUrl: json['icon_url'] as String?,
      iconColor: json['icon_color'] as String? ?? '#9D4EDD',
      ownerId: json['owner_id'] as String? ?? '',
      category: json['category'] as String? ?? 'Gaming',
      isPublic: json['is_public'] == 1 || json['is_public'] == true,
      level: json['level'] as String? ?? 'LVL 1',
      memberCount: json['member_count'] as int? ?? 1,
      onlineCount: json['online_count'] as int? ?? 1,
      myRole: json['my_role'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon_url': iconUrl,
      'icon_color': iconColor,
      'owner_id': ownerId,
      'category': category,
      'is_public': isPublic ? 1 : 0,
      'level': level,
      'member_count': memberCount,
      'online_count': onlineCount,
      'my_role': myRole,
    };
  }
}

class ServerMemberModel {
  final String memberId;
  final String userId;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final String role;
  final String? activity;
  final String status;
  final String? customStatus;

  const ServerMemberModel({
    required this.memberId,
    required this.userId,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    this.role = 'MEMBER',
    this.activity,
    this.status = 'online',
    this.customStatus,
  });

  factory ServerMemberModel.fromJson(Map<String, dynamic> json) {
    return ServerMemberModel(
      memberId: json['member_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      username: json['username'] as String? ?? '',
      displayName: json['display_name'] as String? ?? json['username'] as String? ?? 'Crew Member',
      avatarUrl: json['avatar_url'] as String?,
      role: (json['role'] as String? ?? 'MEMBER').toUpperCase(),
      activity: json['activity'] as String?,
      status: json['status'] as String? ?? 'online',
      customStatus: json['custom_status'] as String?,
    );
  }

  bool get isOnline => status != 'offline';
}
