class UserModel {
  final String id;
  final String username;
  final String displayName;
  final String email;
  final String? avatarUrl;
  final String bio;
  final String status;
  final String? customStatus;
  final String? interests;

  const UserModel({
    required this.id,
    required this.username,
    required this.displayName,
    required this.email,
    this.avatarUrl,
    this.bio = 'Ready to squad up.',
    this.status = 'online',
    this.customStatus,
    this.interests,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      username: json['username'] as String? ?? '',
      displayName: json['display_name'] as String? ?? json['username'] as String? ?? 'Crew Member',
      email: json['email'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String? ?? 'Ready to squad up.',
      status: json['status'] as String? ?? 'online',
      customStatus: json['custom_status'] as String?,
      interests: json['interests'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'display_name': displayName,
      'email': email,
      'avatar_url': avatarUrl,
      'bio': bio,
      'status': status,
      'custom_status': customStatus,
      'interests': interests,
    };
  }

  UserModel copyWith({
    String? id,
    String? username,
    String? displayName,
    String? email,
    String? avatarUrl,
    String? bio,
    String? status,
    String? customStatus,
    String? interests,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      status: status ?? this.status,
      customStatus: customStatus ?? this.customStatus,
      interests: interests ?? this.interests,
    );
  }
}
