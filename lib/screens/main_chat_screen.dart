import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/message_model.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/server_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_logo.dart';
import '../services/navigation_service.dart';

class MainChatScreen extends StatefulWidget {
  const MainChatScreen({super.key});

  @override
  State<MainChatScreen> createState() => _MainChatScreenState();
}

class _MainChatScreenState extends State<MainChatScreen> {
  final TextEditingController _messageInputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _lastLoadedChannelId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initData();
    });
  }

  Future<void> _initData() async {
    final serverProvider = context.read<ServerProvider>();
    final chatProvider = context.read<ChatProvider>();

    if (serverProvider.joinedServers.isEmpty) {
      await serverProvider.fetchJoinedServers();
    }

    if (serverProvider.currentChannel != null) {
      _lastLoadedChannelId = serverProvider.currentChannel!.id;
      await chatProvider.loadChannel(serverProvider.currentChannel!.id);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageInputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleSendMessage() async {
    final text = _messageInputController.text.trim();
    if (text.isEmpty) return;

    final chat = context.read<ChatProvider>();
    _messageInputController.clear();
    final success = await chat.sendMessage(text);
    if (success) {
      _scrollToBottom();
    }
  }

  void _showReactionPicker(String messageId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('React to message',
                  style: AppTextStyles.labelMd.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: ['🔥', '💜', '🤯', '🚀', '👑', '🎮', '✨', '⚡'].map((emoji) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(ctx);
                      context.read<ChatProvider>().toggleReaction(messageId, emoji);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(emoji, style: const TextStyle(fontSize: 24)),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final serverProvider = context.watch<ServerProvider>();
    final chatProvider = context.watch<ChatProvider>();
    final authProvider = context.watch<AuthProvider>();

    // If channel changed, load new channel messages
    if (serverProvider.currentChannel != null &&
        serverProvider.currentChannel!.id != _lastLoadedChannelId) {
      _lastLoadedChannelId = serverProvider.currentChannel!.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        chatProvider.loadChannel(serverProvider.currentChannel!.id).then((_) {
          _scrollToBottom();
        });
      });
    }

    final currentChannelName = serverProvider.currentChannel?.name ?? 'lounge';

    final mediaQueryInsets = MediaQuery.of(context).viewInsets.bottom;
    final viewInsets = View.of(context).viewInsets.bottom / View.of(context).devicePixelRatio;
    final isKeyboardOpen = mediaQueryInsets > 0 || viewInsets > 0;
    final safeBottom = View.of(context).viewPadding.bottom / View.of(context).devicePixelRatio;

    return ValueListenableBuilder<bool>(
      valueListenable: NavigationService().isBottomNavVisible,
      builder: (context, isNavVisible, _) {
        final showBottomNav = isNavVisible && !isKeyboardOpen;
        final bottomInset = isKeyboardOpen
            ? 8.0
            : (showBottomNav ? (84.0 + safeBottom) : (10.0 + safeBottom));

        return Scaffold(
          backgroundColor: AppColors.surface,
          resizeToAvoidBottomInset: true,
          appBar: _buildAppBar(context, authProvider, isNavVisible),
          body: Row(
            children: [
              // Server Rail
              _buildServerRail(context, serverProvider, bottomInset: bottomInset),
              // Main content
              Expanded(
                child: Column(
                  children: [
                    _buildChannelSwitcher(context, serverProvider),
                    Expanded(
                      child: chatProvider.isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primaryContainer,
                              ),
                            )
                          : _buildChatFeed(chatProvider),
                    ),
                    _buildChatInput(currentChannelName),
                    SizedBox(height: bottomInset),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, AuthProvider auth, bool isNavVisible) {
    final user = auth.currentUser;

    return AppBar(
      backgroundColor: AppColors.surface.withValues(alpha: 0.9),
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          const AppLogo(size: 32, borderRadius: 8),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('THE CREW',
                  style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.textMuted, letterSpacing: 1.2)),
              Text('Servers Hub',
                  style: AppTextStyles.headlineSm
                      .copyWith(color: AppColors.textPrimary)),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            isNavVisible ? Icons.fullscreen : Icons.fullscreen_exit,
            color: isNavVisible ? AppColors.onSurfaceVariant : AppColors.accentMint,
          ),
          tooltip: isNavVisible ? 'Hide Bottom Menu' : 'Show Bottom Menu',
          onPressed: () => NavigationService().toggleBottomNav(),
        ),
        IconButton(
          icon: const Icon(Icons.search, color: AppColors.onSurfaceVariant),
          onPressed: () => context.go('/discover'),
        ),
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: AppColors.onSurfaceVariant),
              onPressed: () => context.go('/activity'),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primaryFixed,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => context.go('/profile'),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.surfaceContainerHigh,
              child: Text(
                user != null && user.displayName.isNotEmpty
                    ? user.displayName[0].toUpperCase()
                    : 'K',
                style: AppTextStyles.labelSm.copyWith(color: AppColors.primaryContainer),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServerRail(BuildContext context, ServerProvider serverProvider,
      {required double bottomInset}) {
    final servers = serverProvider.joinedServers;

    return Container(
      width: 58,
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(right: BorderSide(color: AppColors.borderMuted)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          const AppLogo(size: 40, borderRadius: 12),
          Container(
            width: 24,
            height: 1,
            color: AppColors.borderSubtle,
            margin: const EdgeInsets.symmetric(vertical: 6),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(top: 2, bottom: bottomInset),
              itemCount: servers.length + 1,
              itemBuilder: (context, index) {
                if (index == servers.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Center(
                      child: GestureDetector(
                        onTap: () => context.go('/discover/create'),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.borderSubtle),
                          ),
                          child: const Icon(Icons.add,
                              size: 20, color: AppColors.onSurfaceVariant),
                        ),
                      ),
                    ),
                  );
                }

                final s = servers[index];
                final isActive = serverProvider.currentServer?.id == s.id;
                final color = _parseColor(s.iconColor);

                return GestureDetector(
                  onTap: () async {
                    await serverProvider.selectServer(s);
                    if (serverProvider.currentChannel != null &&
                        context.mounted) {
                      context
                          .read<ChatProvider>()
                          .loadChannel(serverProvider.currentChannel!.id);
                    }
                  },
                  child: _serverIcon(
                    s.name.length >= 2
                        ? s.name.substring(0, 2).toUpperCase()
                        : s.name.toUpperCase(),
                    isActive: isActive,
                    imageColor: color,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String hex) {
    try {
      final buffer = StringBuffer();
      if (hex.length == 6 || hex.length == 7) buffer.write('ff');
      buffer.write(hex.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return AppColors.accentPurple;
    }
  }

  Widget _serverIcon(String initials,
      {bool isActive = false, Color? imageColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SizedBox(
        height: 44,
        width: 58,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 3.5,
                height: isActive ? 24 : 0,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.horizontal(right: Radius.circular(3)),
                ),
              ),
            ),
            Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: imageColor ?? AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(isActive ? 14 : 21),
                  border: Border.all(
                    color: isActive
                        ? AppColors.accentMint.withValues(alpha: 0.8)
                        : AppColors.borderSubtle,
                    width: isActive ? 1.5 : 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: AppTextStyles.labelSm.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChannelSwitcher(BuildContext context, ServerProvider serverProvider) {
    final currentServer = serverProvider.currentServer;
    final channels = serverProvider.textChannels;
    final activeChannel = serverProvider.currentChannel;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLow,
        border: Border(bottom: BorderSide(color: AppColors.borderMuted)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(currentServer?.name ?? 'Neon Arcade',
                      style: AppTextStyles.headlineSm
                          .copyWith(color: AppColors.textPrimary)),
                  const SizedBox(width: 4),
                  const Icon(Icons.expand_more, size: 18, color: AppColors.textMuted),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Text(currentServer?.level ?? 'LVL 3',
                        style: AppTextStyles.labelSm
                            .copyWith(fontSize: 10, color: AppColors.textSecondary)),
                  ),
                ],
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.go('/discover'),
                    child: _miniButton(Icons.explore_outlined),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => context.go('/servers/members'),
                    child: _miniButton(Icons.group_outlined),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Channel pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Text('CHANNELS',
                      style: AppTextStyles.labelSm.copyWith(
                          fontSize: 10,
                          color: AppColors.textMuted,
                          letterSpacing: 1.1)),
                ),
                ...channels.map((c) {
                  final isActive = activeChannel?.id == c.id;
                  return GestureDetector(
                    onTap: () {
                      serverProvider.selectChannel(c);
                      context.read<ChatProvider>().loadChannel(c.id);
                    },
                    child: _channelChip(c.name, isActive),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Voice stage preview
          GestureDetector(
            onTap: () => context.go('/servers/voice'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.volume_up, size: 14, color: AppColors.accentMint),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Chill Beats [Voice Stage] • Tap to join',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySm.copyWith(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _stackedAvatar('K'),
                      _stackedAvatar('N'),
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHighest,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Center(
                          child: Text('+4',
                              style: AppTextStyles.labelSm
                                  .copyWith(fontSize: 9, color: AppColors.textSecondary)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniButton(IconData icon) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Icon(icon, size: 18, color: AppColors.textSecondary),
    );
  }

  Widget _channelChip(String name, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.surfaceContainerHigh
            : AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? AppColors.accentMint.withValues(alpha: 0.6) : AppColors.borderSubtle,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.tag, size: 14,
              color: isActive ? AppColors.accentMint : AppColors.textMuted),
          const SizedBox(width: 4),
          Text(name,
              style: AppTextStyles.labelMd.copyWith(
                color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              )),
          if (isActive) ...[
            const SizedBox(width: 6),
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: AppColors.primaryFixed,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _stackedAvatar(String initial) {
    return Transform.translate(
      offset: const Offset(-4, 0),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.surfaceContainer, width: 2),
        ),
        child: Center(
          child: Text(initial,
              style: AppTextStyles.labelSm.copyWith(color: AppColors.textSecondary, fontSize: 11)),
        ),
      ),
    );
  }

  Widget _buildChatFeed(ChatProvider chatProvider) {
    final messages = chatProvider.messages;

    if (messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.forum_outlined, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text('Welcome to the channel!',
                style: AppTextStyles.headlineSm.copyWith(color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            Text('This is the start of this channel. Say hello to your crew!',
                style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(12),
      itemCount: messages.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Text('LIVE CHAT FEED',
                    style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.textMuted, letterSpacing: 1)),
              ),
            ),
          );
        }

        final msg = messages[index - 1];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildMessageItem(msg),
        );
      },
    );
  }

  Widget _buildMessageItem(MessageModel msg) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Center(
                child: Text(
                  msg.displayName.isNotEmpty ? msg.displayName[0].toUpperCase() : 'U',
                  style: AppTextStyles.headlineSm.copyWith(color: AppColors.textPrimary),
                ),
              ),
            ),
            Positioned(
              bottom: -2,
              right: -2,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: msg.status == 'online' ? AppColors.accentMint : AppColors.surfaceVariant,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppColors.surfaceContainerLowest, width: 2),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name row
              Row(
                children: [
                  Text(msg.displayName,
                      style: AppTextStyles.headlineSm
                          .copyWith(color: AppColors.textPrimary)),
                  if (msg.senderRole != null) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Text(msg.senderRole!,
                          style: AppTextStyles.labelSm.copyWith(
                              fontSize: 10,
                              color: msg.senderRole == 'OWNER' || msg.senderRole == 'ADMIN'
                                  ? AppColors.accentMint
                                  : AppColors.accentPurple)),
                    ),
                  ],
                  const SizedBox(width: 6),
                  Text(msg.createdAt.length > 16 ? msg.createdAt.substring(11, 16) : msg.createdAt,
                      style: AppTextStyles.bodySm
                          .copyWith(fontSize: 11, color: AppColors.textMuted)),
                ],
              ),
              const SizedBox(height: 4),
              // Message bubble
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (msg.content != null && msg.content!.isNotEmpty)
                      Text(msg.content!,
                          style: AppTextStyles.bodyMd
                              .copyWith(color: AppColors.onSurface)),
                    if (msg.hasMedia) ...[
                      const SizedBox(height: 8),
                      _buildMediaPreview(msg.mediaTitle ?? 'Media attachment', msg.mediaDuration ?? '01:14'),
                    ],
                  ],
                ),
              ),
              // Reactions
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  ...msg.reactions.map((r) => GestureDetector(
                        onTap: () => context.read<ChatProvider>().toggleReaction(msg.id, r.emoji),
                        child: _reactionPill(r.emoji, r.count),
                      )),
                  GestureDetector(
                    onTap: () => _showReactionPicker(msg.id),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: const Icon(Icons.add_reaction_outlined,
                          size: 14, color: AppColors.textMuted),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _reactionPill(String emoji, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text('$count',
              style: AppTextStyles.labelSm.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildMediaPreview(String title, String duration) {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Stack(
        children: [
          Center(
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer.withValues(alpha: 0.95),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: const Icon(Icons.play_arrow, size: 24, color: AppColors.textPrimary),
            ),
          ),
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Text(title,
                  style: AppTextStyles.labelSm
                      .copyWith(color: AppColors.textSecondary)),
            ),
          ),
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Text(duration,
                  style: AppTextStyles.labelSm
                      .copyWith(color: AppColors.textSecondary)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatInput(String channelName) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Container(
        padding: const EdgeInsets.only(left: 6, right: 6, top: 4, bottom: 4),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.borderSubtle),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: const Icon(Icons.add, size: 18, color: AppColors.textSecondary),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _messageInputController,
                style: AppTextStyles.bodyMd.copyWith(color: Colors.white),
                onSubmitted: (_) => _handleSendMessage(),
                decoration: InputDecoration(
                  hintText: 'Message #$channelName...',
                  hintStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.textMuted),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  fillColor: Colors.transparent,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.sentiment_satisfied_outlined, size: 20, color: AppColors.textMuted),
              onPressed: () {
                _messageInputController.text += '🔥';
              },
            ),
            GestureDetector(
              onTap: _handleSendMessage,
              child: Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: AppColors.primaryFixed,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_upward,
                    size: 18, color: AppColors.surfaceContainerLowest),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

