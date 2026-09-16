import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../providers/dm_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_logo.dart';

class DmInboxScreen extends StatefulWidget {
  const DmInboxScreen({super.key});

  @override
  State<DmInboxScreen> createState() => _DmInboxScreenState();
}

class _DmInboxScreenState extends State<DmInboxScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DmProvider>().fetchConversations();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dmProvider = context.watch<DmProvider>();
    final conversations = dmProvider.conversations;
    final activeNow = dmProvider.activeNow;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withValues(alpha: 0.9),
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const AppLogo(size: 32, borderRadius: 8),
            const SizedBox(width: 8),
            Text('Messages', style: AppTextStyles.headlineSm.copyWith(color: AppColors.textPrimary)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.onSurfaceVariant),
            onPressed: () => dmProvider.fetchConversations(),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.surfaceContainerHigh,
              child: const Icon(Icons.person, size: 18, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, size: 20, color: AppColors.textMuted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: AppTextStyles.bodyMd.copyWith(color: Colors.white),
                      onChanged: (val) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Search messages...',
                        hintStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.textMuted),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        fillColor: Colors.transparent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Active Now
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('ACTIVE NOW', style: AppTextStyles.labelSm.copyWith(color: AppColors.textMuted, letterSpacing: 1.2)),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 72,
            child: activeNow.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Squad is currently offline', style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted)),
                  )
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: activeNow.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (_, i) {
                      final u = activeNow[i];
                      return _activeAvatar(u);
                    },
                  ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('DIRECT MESSAGES', style: AppTextStyles.labelSm.copyWith(color: AppColors.textMuted, letterSpacing: 1.2)),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: conversations.isEmpty
                ? Center(
                    child: Text('No messages yet', style: AppTextStyles.bodyMd.copyWith(color: AppColors.textMuted)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 100),
                    itemCount: conversations.length,
                    itemBuilder: (_, i) {
                      final c = conversations[i];
                      final query = _searchController.text.toLowerCase();
                      if (query.isNotEmpty &&
                          !c.displayName.toLowerCase().contains(query) &&
                          !c.lastMessage.toLowerCase().contains(query)) {
                        return const SizedBox.shrink();
                      }

                      return GestureDetector(
                        onTap: () => context.go('/messages/chat/${c.partnerId}'),
                        child: _dmTile(
                          c.displayName,
                          c.lastMessage,
                          c.lastMessageTime.length > 16 ? c.lastMessageTime.substring(11, 16) : c.lastMessageTime,
                          c.unreadCount > 0,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _activeAvatar(UserModel user) {
    return GestureDetector(
      onTap: () => context.go('/messages/chat/${user.id}'),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.surfaceContainerHigh,
                child: Text(
                  user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : 'U',
                  style: AppTextStyles.headlineSm.copyWith(color: AppColors.textPrimary),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.accentMint,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surface, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(user.displayName, style: AppTextStyles.labelSm.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _dmTile(String name, String message, String time, bool hasUnread) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: hasUnread ? AppColors.surfaceContainerLow : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.surfaceContainerHigh,
              child: Text(name.isNotEmpty ? name[0] : 'U', style: AppTextStyles.headlineSm.copyWith(color: AppColors.textPrimary)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(name, style: AppTextStyles.headlineSm.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w600,
                      )),
                      Text(time, style: AppTextStyles.labelSm.copyWith(color: AppColors.textMuted)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          message,
                          style: AppTextStyles.bodySm.copyWith(
                            color: hasUnread ? AppColors.onSurfaceVariant : AppColors.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hasUnread)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 8),
                          decoration: const BoxDecoration(color: AppColors.primaryFixed, shape: BoxShape.circle),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
