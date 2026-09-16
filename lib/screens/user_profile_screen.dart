import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/server_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_logo.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final serverProvider = context.watch<ServerProvider>();

    final displayName = user?.displayName ?? 'Kaelen';
    final username = user?.username ?? 'kaelen_vr';
    final bio = user?.bio ?? 'Midnight raider, synthwave enthusiast, and Sector 9 speedrunner. Building aesthetic spaces for the crew. 🎮✨🎵';
    final isOnline = user?.status != 'offline';

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          children: [
            // Gradient banner
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 160,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.accentPurple, AppColors.accentPink],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                Positioned(
                  top: 50,
                  left: 16,
                  child: const AppLogo(size: 36, borderRadius: 10, hasGlow: true),
                ),
                Positioned(
                  top: 50,
                  right: 16,
                  child: IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white),
                    onPressed: () => context.go('/profile/settings'),
                  ),
                ),
                // Avatar positioned over banner edge
                Positioned(
                  bottom: -40,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.surface, width: 4),
                        color: AppColors.surfaceContainerHigh,
                      ),
                      child: Center(
                        child: Text(
                          displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                          style: AppTextStyles.headlineXlMobile.copyWith(color: AppColors.textPrimary),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),
            // Name & handle
            Text(displayName, style: AppTextStyles.headlineLg.copyWith(color: AppColors.textPrimary)),
            const SizedBox(height: 2),
            Text('@$username', style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Text('Member of The Crew Network', style: AppTextStyles.labelSm.copyWith(color: AppColors.textMuted)),
            const SizedBox(height: 12),
            // Status indicator
            GestureDetector(
              onTap: () => _showStatusPicker(context, auth),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isOnline ? AppColors.accentMint : AppColors.textMuted,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      user?.status.toUpperCase() ?? 'ONLINE',
                      style: AppTextStyles.labelMd.copyWith(
                        color: isOnline ? AppColors.accentMint : AppColors.textMuted,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_drop_down, size: 16, color: AppColors.textMuted),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Bio
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderMuted),
                ),
                child: Text(
                  bio,
                  style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Role badges
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                alignment: WrapAlignment.center,
                children: [
                  _roleBadge('Verified', AppColors.accentMint),
                  _roleBadge('Crew Core', AppColors.accentPurple),
                  _roleBadge('Night Owl', const Color(0xFFFFD700)),
                  _roleBadge('Booster', AppColors.accentPink),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Action buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(children: [
                Expanded(
                  child: _actionButton(
                    Icons.edit_note,
                    'Edit Profile',
                    AppColors.accentPurple,
                    textColor: Colors.white,
                    onTap: () => _openEditProfileSheet(context, auth),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _actionButton(
                    Icons.chat_bubble_outline,
                    'DMs',
                    AppColors.surfaceContainerHigh,
                    onTap: () => context.go('/messages'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _actionButton(
                    Icons.tune,
                    'Settings',
                    AppColors.accentMint,
                    textColor: AppColors.surfaceBase,
                    onTap: () => context.go('/profile/settings'),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 24),
            // Mutual servers
            _sectionTile('Joined Servers', '${serverProvider.joinedServers.length}'),
            if (serverProvider.joinedServers.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text('No joined servers yet. Tap Explore to find communities!',
                        style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted)),
                  ),
                ),
              )
            else
              ...serverProvider.joinedServers.map((s) => _mutualItem(context, serverProvider, s)),
          ],
        ),
      ),
    );
  }

  void _showStatusPicker(BuildContext context, AuthProvider auth) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final statuses = [
          {'key': 'online', 'label': 'Online', 'desc': 'Visible to everyone', 'color': AppColors.accentMint},
          {'key': 'idle', 'label': 'Away / Idle', 'desc': 'Stepped away from the terminal', 'color': const Color(0xFFFFD700)},
          {'key': 'dnd', 'label': 'Do Not Disturb', 'desc': 'Mute all popups and notifications', 'color': AppColors.accentPink},
        ];

        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(color: AppColors.borderSubtle),
              left: BorderSide(color: AppColors.borderSubtle),
              right: BorderSide(color: AppColors.borderSubtle),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text('Set Status', style: AppTextStyles.headlineSm.copyWith(color: AppColors.textPrimary)),
                  const SizedBox(height: 12),
                  ...statuses.map((s) {
                    final isSelected = auth.currentUser?.status == s['key'];
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          auth.updateProfile(status: s['key'] as String);
                          Navigator.pop(ctx);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: s['color'] as Color,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(s['label'] as String,
                                        style: AppTextStyles.headlineSm.copyWith(
                                          color: AppColors.textPrimary,
                                          fontSize: 14,
                                        )),
                                    Text(s['desc'] as String,
                                        style: AppTextStyles.bodySm.copyWith(
                                          color: AppColors.textMuted,
                                          fontSize: 12,
                                        )),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check, color: AppColors.accentMint, size: 20),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _openEditProfileSheet(BuildContext context, AuthProvider auth) {
    final user = auth.currentUser;
    final nameController = TextEditingController(text: user?.displayName ?? '');
    final bioController = TextEditingController(text: user?.bio ?? '');
    final statusController = TextEditingController(text: user?.customStatus ?? '');

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return Container(
              height: MediaQuery.of(modalContext).size.height * 0.8,
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(modalContext).viewInsets.bottom + 20,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Edit Profile',
                            style: AppTextStyles.headlineSm.copyWith(color: AppColors.textPrimary, fontSize: 18)),
                        IconButton(
                          icon: const Icon(Icons.close, color: AppColors.textMuted),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const Divider(color: AppColors.borderSubtle),
                    const SizedBox(height: 12),
                    Text('DISPLAY NAME', style: AppTextStyles.labelSm.copyWith(color: AppColors.textMuted)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: nameController,
                      style: AppTextStyles.bodyMd.copyWith(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.surfaceContainerLow,
                        hintText: 'Enter your display name',
                        hintStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.textMuted),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.borderSubtle),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.borderSubtle),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.accentMint),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('CUSTOM STATUS', style: AppTextStyles.labelSm.copyWith(color: AppColors.textMuted)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: statusController,
                      style: AppTextStyles.bodyMd.copyWith(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.surfaceContainerLow,
                        hintText: 'e.g. Grinding Cyberpunk 2077',
                        hintStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.textMuted),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.borderSubtle),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.borderSubtle),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.accentMint),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('BIO', style: AppTextStyles.labelSm.copyWith(color: AppColors.textMuted)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: bioController,
                      maxLines: 3,
                      style: AppTextStyles.bodyMd.copyWith(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.surfaceContainerLow,
                        hintText: 'Tell the crew about yourself...',
                        hintStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.textMuted),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.borderSubtle),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.borderSubtle),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.accentMint),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentMint,
                          foregroundColor: AppColors.surfaceBase,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () async {
                          final success = await auth.updateProfile(
                            displayName: nameController.text.trim(),
                            bio: bioController.text.trim(),
                            customStatus: statusController.text.trim(),
                          );
                          if (ctx.mounted) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  success ? 'Profile updated successfully!' : 'Failed to update profile',
                                ),
                                backgroundColor: success ? AppColors.surfaceContainerHigh : Colors.red,
                              ),
                            );
                          }
                        },
                        child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  static Color _parseColor(String hex) {
    try {
      final buffer = StringBuffer();
      if (hex.length == 6 || hex.length == 7) buffer.write('ff');
      buffer.write(hex.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return AppColors.accentPurple;
    }
  }

  Widget _roleBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(label, style: AppTextStyles.labelSm.copyWith(color: color, fontWeight: FontWeight.w600)),
    );
  }

  Widget _actionButton(IconData icon, String label, Color bgColor, {Color? textColor, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: textColor ?? AppColors.textPrimary),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelMd.copyWith(
                  color: textColor ?? AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTile(String title, String count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.headlineSm.copyWith(color: AppColors.textPrimary, fontSize: 16)),
          Text(count, style: AppTextStyles.labelMd.copyWith(color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _mutualItem(BuildContext context, ServerProvider serverProvider, dynamic s) {
    final name = s.name as String;
    final sub = s.level as String;
    final color = _parseColor(s.iconColor as String);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            await serverProvider.selectServer(s);
            if (context.mounted) {
              context.go('/servers');
            }
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
                  child: Center(
                    child: Text(
                      name.length >= 2 ? name.substring(0, 2).toUpperCase() : name.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: AppTextStyles.headlineSm.copyWith(color: AppColors.textPrimary, fontSize: 14)),
                      Text(sub, style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
