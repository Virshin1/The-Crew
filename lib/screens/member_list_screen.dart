import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/server_model.dart';
import '../providers/server_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_logo.dart';

class MemberListScreen extends StatefulWidget {
  const MemberListScreen({super.key});

  @override
  State<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final server = context.read<ServerProvider>().currentServer;
      if (server != null) {
        context.read<ServerProvider>().fetchMembers(server.id);
      }
    });
  }

  void _showMemberProfile(BuildContext context, ServerMemberModel member, Color? roleColor) {
    final currentUserId = context.read<AuthProvider>().currentUser?.id;
    final isSelf = currentUserId == member.userId;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.borderMuted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.surfaceContainerHigh,
                    child: Text(
                      member.displayName.isNotEmpty ? member.displayName[0].toUpperCase() : 'U',
                      style: AppTextStyles.headlineLg.copyWith(color: AppColors.textPrimary),
                    ),
                  ),
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: member.isOnline ? AppColors.accentMint : AppColors.textMuted,
                      border: Border.all(color: AppColors.surfaceContainer, width: 3),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                member.displayName,
                style: AppTextStyles.headlineSm.copyWith(color: AppColors.textPrimary, fontSize: 18),
              ),
              if (member.username.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  '@${member.username}',
                  style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
                ),
              ],
              const SizedBox(height: 10),
              // Role badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: (roleColor ?? AppColors.accentPurple).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: (roleColor ?? AppColors.accentPurple).withValues(alpha: 0.5)),
                ),
                child: Text(
                  member.role,
                  style: AppTextStyles.labelSm.copyWith(
                    color: roleColor ?? AppColors.accentPurple,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              if (member.customStatus != null || member.activity != null) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderMuted),
                  ),
                  child: Text(
                    member.customStatus ?? member.activity ?? '',
                    style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              if (!isSelf)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.forum_outlined, size: 20),
                    label: const Text('Direct Message', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      context.go('/messages/chat/${member.userId}');
                    },
                  ),
                ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final serverProvider = context.watch<ServerProvider>();
    final allMembers = serverProvider.members;
    final serverName = serverProvider.currentServer?.name ?? 'Neon Arcade';

    final owners = allMembers.where((m) => m.role == 'OWNER' && m.isOnline).toList();
    final admins = allMembers.where((m) => m.role == 'ADMIN' && m.isOnline).toList();
    final vips = allMembers.where((m) => m.role == 'VIP' && m.isOnline).toList();
    final regularMembers = allMembers
        .where((m) => m.role != 'OWNER' && m.role != 'ADMIN' && m.role != 'VIP' && m.isOnline)
        .toList();
    final offline = allMembers.where((m) => !m.isOnline).toList();

    final onlineCount = allMembers.where((m) => m.isOnline).length;

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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(serverName, style: AppTextStyles.labelSm.copyWith(color: AppColors.textMuted)),
                Text('Members', style: AppTextStyles.headlineSm.copyWith(color: AppColors.textPrimary)),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Text(
              '$onlineCount ONLINE',
              style: AppTextStyles.labelSm.copyWith(color: AppColors.accentMint, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 100),
        children: [
          if (owners.isNotEmpty)
            _roleSection('OWNER — ${owners.length}', owners, AppColors.accentMint),
          if (admins.isNotEmpty)
            _roleSection('ADMINS — ${admins.length}', admins, AppColors.accentMint),
          if (vips.isNotEmpty)
            _roleSection('VIP — ${vips.length}', vips, AppColors.accentPurple),
          if (regularMembers.isNotEmpty)
            _roleSection('MEMBERS — ${regularMembers.length}', regularMembers, null),
          if (offline.isNotEmpty)
            _roleSection('OFFLINE — ${offline.length}', offline, null),
        ],
      ),
    );
  }

  Widget _roleSection(String title, List<ServerMemberModel> members, Color? roleColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(title, style: AppTextStyles.labelSm.copyWith(color: AppColors.textMuted, letterSpacing: 1.5)),
        ),
        ...members.map((m) => _memberTile(m, roleColor)),
      ],
    );
  }

  Widget _memberTile(ServerMemberModel m, Color? roleColor) {
    final name = m.displayName;
    final role = m.role != 'MEMBER' ? m.role : null;
    final activity = m.customStatus ?? m.activity;
    final isOnline = m.isOnline;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showMemberProfile(context, m, roleColor),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.surfaceContainerHigh,
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'U',
                        style: AppTextStyles.headlineSm.copyWith(color: AppColors.textPrimary),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isOnline ? AppColors.accentMint : AppColors.textMuted,
                          border: Border.all(color: AppColors.surfaceContainerLow, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(name,
                              style: AppTextStyles.headlineSm.copyWith(
                                color: isOnline ? AppColors.textPrimary : AppColors.textMuted,
                                fontSize: 14,
                              )),
                          if (role != null) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: roleColor?.withValues(alpha: 0.4) ?? AppColors.borderSubtle,
                                ),
                              ),
                              child: Text(role,
                                  style: AppTextStyles.labelSm.copyWith(
                                    fontSize: 9,
                                    color: roleColor ?? AppColors.textSecondary,
                                    fontWeight: FontWeight.bold,
                                  )),
                            ),
                          ],
                        ],
                      ),
                      if (activity != null) ...[
                        const SizedBox(height: 2),
                        Text(activity,
                            style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted, fontSize: 12)),
                      ],
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
