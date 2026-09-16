import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/notification_model.dart';
import '../providers/notification_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_logo.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<String> _filters = ['All', 'Mentions', 'Reactions', 'System'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().fetchNotifications();
    });
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'mention':
        return Icons.alternate_email;
      case 'reaction':
        return Icons.favorite;
      case 'friend':
        return Icons.person_add;
      case 'voice':
        return Icons.volume_up;
      case 'server':
        return Icons.group_add;
      default:
        return Icons.campaign;
    }
  }

  Color _getColorForType(String type) {
    switch (type.toLowerCase()) {
      case 'mention':
        return AppColors.accentPurple;
      case 'reaction':
        return AppColors.accentPink;
      case 'friend':
        return AppColors.accentMint;
      case 'voice':
        return AppColors.textSecondary;
      case 'server':
        return AppColors.accentPurple;
      default:
        return const Color(0xFFFFD700);
    }
  }

  void _handleNotificationTap(BuildContext context, NotificationModel n) {
    final notifProvider = context.read<NotificationProvider>();
    if (!n.isRead) {
      notifProvider.markAsRead(n.id);
    }

    final type = n.type.toLowerCase();
    if (type == 'voice') {
      context.go('/servers/voice');
    } else if (type == 'friend' || type == 'message' || type == 'dm') {
      context.go('/messages');
    } else {
      context.go('/servers');
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifProvider = context.watch<NotificationProvider>();
    final notifs = notifProvider.notifications;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withValues(alpha: 0.9),
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const AppLogo(size: 32, borderRadius: 8),
            const SizedBox(width: 8),
            Text('Activity', style: AppTextStyles.headlineSm.copyWith(color: AppColors.textPrimary)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: AppColors.onSurfaceVariant),
            tooltip: 'Mark all as read',
            onPressed: () => notifProvider.markAllAsRead(),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => context.go('/profile'),
              child: const CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.surfaceContainerHigh,
                child: Icon(Icons.person, size: 18, color: AppColors.textSecondary),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter tabs
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: _filters.map((f) {
                final isActive = notifProvider.activeFilter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: GestureDetector(
                    onTap: () => notifProvider.fetchNotifications(filter: f),
                    child: _filterTab(f, isActive),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: notifProvider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primaryContainer),
                  )
                : notifs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.notifications_off_outlined, size: 48, color: AppColors.textMuted),
                            const SizedBox(height: 12),
                            Text('All caught up!',
                                style: AppTextStyles.headlineSm.copyWith(color: AppColors.textPrimary)),
                            const SizedBox(height: 4),
                            Text('No notifications to display right now.',
                                style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 100),
                        itemCount: notifs.length,
                        itemBuilder: (context, index) {
                          final n = notifs[index];
                          final icon = _getIconForType(n.type);
                          final color = _getColorForType(n.type);

                          return _notifTile(n, icon, color);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _filterTab(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? AppColors.surfaceContainerHigh : AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: isActive ? AppColors.accentMint.withValues(alpha: 0.8) : AppColors.borderMuted),
      ),
      child: Text(label,
          style: AppTextStyles.labelMd.copyWith(
              color: isActive ? AppColors.accentMint : AppColors.textSecondary,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal)),
    );
  }

  Widget _notifTile(NotificationModel n, IconData icon, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _handleNotificationTap(context, n),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: n.isRead ? Colors.transparent : AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: n.isRead ? AppColors.borderMuted : AppColors.accentPurple.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 20, color: iconColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(n.title,
                          style: AppTextStyles.headlineSm.copyWith(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: n.isRead ? FontWeight.normal : FontWeight.w600,
                          )),
                      const SizedBox(height: 2),
                      Text(n.body,
                          style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(n.timeDisplay, style: AppTextStyles.labelSm.copyWith(color: AppColors.textMuted)),
                    if (!n.isRead) ...[
                      const SizedBox(height: 6),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.accentMint,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
