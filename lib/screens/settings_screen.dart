import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_logo.dart';
import '../widgets/server_config_dialog.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    final displayName = user?.displayName ?? 'Kaelen';
    final username = user?.username ?? 'kaelen_vr';
    final isOnline = user?.status != 'offline';

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withValues(alpha: 0.9),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurfaceVariant),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            const AppLogo(size: 28, borderRadius: 8),
            const SizedBox(width: 8),
            Text('Settings', style: AppTextStyles.headlineSm.copyWith(color: AppColors.textPrimary)),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 100),
        children: [
          // Profile card
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.surfaceContainerHigh,
                  child: Text(
                    displayName.isNotEmpty ? displayName[0].toUpperCase() : 'K',
                    style: AppTextStyles.headlineLg.copyWith(color: AppColors.textPrimary),
                  ),
                ),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(displayName, style: AppTextStyles.headlineSm.copyWith(color: AppColors.textPrimary)),
                  Text('@$username', style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary)),
                  Row(children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isOnline ? AppColors.accentMint : AppColors.textMuted,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      user?.status.toUpperCase() ?? 'ONLINE',
                      style: AppTextStyles.labelSm.copyWith(
                        color: isOnline ? AppColors.accentMint : AppColors.textMuted,
                      ),
                    ),
                  ]),
                ]),
              ]),
            ),
          ),
          _sectionHeader('ACCOUNT'),
          _settingTile(Icons.person_outline, 'Edit Profile', 'Username, avatar, bio'),
          _settingTile(Icons.lock_outline, 'Password & Security', '2FA, recovery codes'),
          _settingTile(Icons.devices, 'Active Sessions', 'Connected to The Crew Backend'),
          _sectionHeader('APPEARANCE'),
          _settingTile(Icons.palette_outlined, 'Customize Theme', 'Colors, density, effects',
            onTap: () => context.go('/profile/theme')),
          _settingTile(Icons.text_fields, 'Chat Display', 'Font size, message layout'),
          _settingTile(Icons.dark_mode_outlined, 'Dark Mode', 'Obsidian Cyberpunk (Default)'),
          _sectionHeader('NOTIFICATIONS'),
          _toggleTile(Icons.notifications_outlined, 'Push Notifications', true),
          _toggleTile(Icons.email_outlined, 'Email Notifications', false),
          _toggleTile(Icons.volume_up_outlined, 'Sound Effects', true),
          _sectionHeader('PRIVACY & SAFETY'),
          _settingTile(Icons.shield_outlined, 'Privacy Settings', 'Who can message you'),
          _settingTile(Icons.block, 'Blocked Users', '0 users blocked'),
          _settingTile(Icons.visibility_outlined, 'Data & Privacy', 'Download, delete your data'),
          _sectionHeader('VOICE & VIDEO'),
          _settingTile(Icons.mic_outlined, 'Input Device', 'Default Microphone (WebRTC)'),
          _settingTile(Icons.headphones_outlined, 'Output Device', 'Default Speakers'),
          _settingTile(Icons.noise_aware_outlined, 'Noise Suppression', 'Krisp AI enabled'),
          _sectionHeader('SERVER & BACKEND'),
          _settingTile(
            Icons.dns_rounded,
            'Backend Host IP',
            'http://${ApiService.host} (Tap to change)',
            onTap: () => ServerConfigDialog.show(context),
          ),
          _sectionHeader('DANGER ZONE'),
          _dangerTile(
            Icons.logout,
            'Log Out',
            Colors.white,
            onTap: () async {
              await auth.logout();
              if (context.mounted) context.go('/welcome');
            },
          ),
          _dangerTile(
            Icons.delete_forever,
            'Delete Account',
            AppColors.error,
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: AppColors.surfaceContainer,
                  title: const Text('Delete Account?', style: TextStyle(color: Colors.white)),
                  content: const Text(
                    'Are you sure you want to delete your profile? This action is permanent.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await auth.logout();
                        if (context.mounted) context.go('/welcome');
                      },
                      child: const Text('Delete', style: TextStyle(color: AppColors.error)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(title, style: AppTextStyles.labelSm.copyWith(color: AppColors.textMuted, letterSpacing: 1.5)),
    );
  }

  Widget _settingTile(IconData icon, String title, String subtitle, {VoidCallback? onTap}) {
    return ListTile(
      leading: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 20, color: AppColors.textSecondary),
      ),
      title: Text(title, style: AppTextStyles.headlineSm.copyWith(color: AppColors.textPrimary, fontSize: 14)),
      subtitle: Text(subtitle, style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted)),
      trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.textMuted),
      onTap: onTap,
    );
  }

  Widget _toggleTile(IconData icon, String title, bool value) {
    return ListTile(
      leading: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 20, color: AppColors.textSecondary),
      ),
      title: Text(title, style: AppTextStyles.headlineSm.copyWith(color: AppColors.textPrimary, fontSize: 14)),
      trailing: Switch(
        value: value,
        onChanged: (_) {},
        activeThumbColor: AppColors.accentMint,
      ),
    );
  }

  Widget _dangerTile(IconData icon, String title, Color color, {VoidCallback? onTap}) {
    return ListTile(
      leading: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 20, color: color),
      ),
      title: Text(title, style: AppTextStyles.headlineSm.copyWith(color: color, fontSize: 14)),
      trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.textMuted),
      onTap: onTap,
    );
  }
}
