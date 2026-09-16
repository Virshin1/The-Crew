import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/dm_model.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../providers/dm_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Full-screen dedicated direct messaging screen between two users.
class DmChatScreen extends StatefulWidget {
  final String partnerId;
  final UserModel? initialPartner;

  const DmChatScreen({
    super.key,
    required this.partnerId,
    this.initialPartner,
  });

  @override
  State<DmChatScreen> createState() => _DmChatScreenState();
}

class _DmChatScreenState extends State<DmChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DmProvider>().loadDmThread(widget.partnerId).then((_) {
        _scrollToBottom(animated: false);
      });
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final target = _scrollController.position.maxScrollExtent;
      if (animated) {
        _scrollController.animateTo(
          target,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(target);
      }
    });
  }

  Future<void> _handleSend(DmProvider dmProvider) async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    _textController.clear();
    final success = await dmProvider.sendDm(widget.partnerId, text);
    if (success) {
      _scrollToBottom(animated: true);
    }
  }

  void _showPartnerProfileModal(BuildContext context, UserModel? partner) {
    if (partner == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
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
              decoration: BoxDecoration(
                color: AppColors.borderSubtle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 36,
              backgroundColor: AppColors.surfaceContainerHigh,
              child: Text(
                partner.displayName.isNotEmpty ? partner.displayName[0].toUpperCase() : 'U',
                style: AppTextStyles.headlineLg.copyWith(color: AppColors.textPrimary, fontSize: 28),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              partner.displayName,
              style: AppTextStyles.headlineSm.copyWith(color: AppColors.textPrimary, fontSize: 20),
            ),
            Text(
              '@${partner.username}',
              style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: (partner.status != 'offline' ? AppColors.accentMint : AppColors.textMuted)
                    .withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: partner.status != 'offline' ? AppColors.accentMint : AppColors.textMuted,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    partner.customStatus ?? (partner.status != 'offline' ? 'Online' : 'Offline'),
                    style: AppTextStyles.labelSm.copyWith(
                      color: partner.status != 'offline' ? AppColors.accentMint : AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (partner.bio.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                partner.bio,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dmProvider = context.watch<DmProvider>();
    final authProvider = context.watch<AuthProvider>();
    final currentUserId = authProvider.currentUser?.id ?? '';
    final partner = dmProvider.currentPartner ?? widget.initialPartner;
    final messages = dmProvider.currentMessages;
    final isOnline = partner?.status != 'offline';

    return Scaffold(
      backgroundColor: AppColors.surface,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withValues(alpha: 0.95),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurfaceVariant),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/messages');
            }
          },
        ),
        titleSpacing: 0,
        title: InkWell(
          onTap: () => _showPartnerProfileModal(context, partner),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.surfaceContainerHigh,
                      child: Text(
                        (partner?.displayName.isNotEmpty == true)
                            ? partner!.displayName[0].toUpperCase()
                            : 'U',
                        style: AppTextStyles.headlineSm.copyWith(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Positioned(
                      right: -1,
                      bottom: -1,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: isOnline ? AppColors.accentMint : AppColors.textMuted,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.surface, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        partner?.displayName ?? 'Crew Friend',
                        style: AppTextStyles.labelMd.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        partner?.customStatus?.isNotEmpty == true
                            ? partner!.customStatus!
                            : (isOnline ? 'Online' : '@${partner?.username ?? "user"} • Offline'),
                        style: AppTextStyles.labelSm.copyWith(
                          color: isOnline ? AppColors.accentMint : AppColors.textMuted,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call_outlined, color: AppColors.onSurfaceVariant, size: 22),
            tooltip: 'Live Stage Call',
            onPressed: () => context.go('/servers/voice'),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline, color: AppColors.onSurfaceVariant, size: 22),
            tooltip: 'User Info',
            onPressed: () => _showPartnerProfileModal(context, partner),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Column(
        children: [
          const Divider(height: 1, color: AppColors.borderSubtle),
          Expanded(
            child: dmProvider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.accentMint,
                    ),
                  )
                : _buildMessageList(messages, currentUserId, partner),
          ),
          _buildChatInput(context, dmProvider, partner),
        ],
      ),
    );
  }

  Widget _buildMessageList(
    List<DmMessageModel> messages,
    String currentUserId,
    UserModel? partner,
  ) {
    if (messages.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.surfaceContainerHigh,
                child: Text(
                  (partner?.displayName.isNotEmpty == true)
                      ? partner!.displayName[0].toUpperCase()
                      : 'U',
                  style: AppTextStyles.headlineLg.copyWith(color: AppColors.textPrimary, fontSize: 28),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                partner?.displayName ?? 'Crew Friend',
                style: AppTextStyles.headlineSm.copyWith(color: AppColors.textPrimary, fontSize: 18),
              ),
              Text(
                '@${partner?.username ?? "friend"}',
                style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: 8),
              if (partner?.bio.isNotEmpty == true)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Text(
                    '"${partner!.bio}"',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                  ),
                ),
              const SizedBox(height: 12),
              Text(
                'This is the very beginning of your direct message history with ${partner?.displayName ?? "this user"}.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  _textController.text = '👋 Hey!';
                  _focusNode.requestFocus();
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.borderSubtle),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  foregroundColor: AppColors.accentMint,
                ),
                icon: const Text('👋', style: TextStyle(fontSize: 16)),
                label: const Text('Say Hello!'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final msg = messages[index];
        final isMe = msg.senderId == currentUserId;

        return _buildMessageBubble(msg, isMe, partner);
      },
    );
  }

  Widget _buildMessageBubble(DmMessageModel msg, bool isMe, UserModel? partner) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.surfaceContainerHigh,
              child: Text(
                (partner?.displayName.isNotEmpty == true)
                    ? partner!.displayName[0].toUpperCase()
                    : 'U',
                style: AppTextStyles.labelSm.copyWith(color: AppColors.textPrimary, fontSize: 11),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: GestureDetector(
              onLongPress: () {
                Clipboard.setData(ClipboardData(text: msg.content));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Message copied to clipboard'),
                    duration: Duration(seconds: 1),
                    backgroundColor: AppColors.surfaceContainerHighest,
                  ),
                );
              },
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.72,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isMe ? AppColors.primaryContainer : AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isMe ? 16 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 16),
                  ),
                  border: isMe ? null : Border.all(color: AppColors.borderSubtle),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      msg.content,
                      style: AppTextStyles.bodyMd.copyWith(
                        color: isMe ? AppColors.surfaceBase : Colors.white,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          msg.timeDisplay,
                          style: AppTextStyles.labelSm.copyWith(
                            color: isMe
                                ? AppColors.surfaceBase.withValues(alpha: 0.6)
                                : AppColors.textMuted,
                            fontSize: 10,
                          ),
                        ),
                        if (isMe) ...[
                          const SizedBox(width: 4),
                          Icon(
                            Icons.done_all,
                            size: 13,
                            color: AppColors.surfaceBase.withValues(alpha: 0.6),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatInput(BuildContext context, DmProvider dmProvider, UserModel? partner) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 2),
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(19),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: IconButton(
                icon: const Icon(Icons.add, size: 20, color: AppColors.textSecondary),
                padding: EdgeInsets.zero,
                tooltip: 'Quick message',
                onPressed: () {
                  _textController.text = '🎮 Join my squad!';
                  _focusNode.requestFocus();
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _textController,
                  focusNode: _focusNode,
                  maxLines: 4,
                  minLines: 1,
                  style: AppTextStyles.bodyMd.copyWith(color: Colors.white),
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (_) => _handleSend(dmProvider),
                  decoration: InputDecoration(
                    hintText: 'Message @${partner?.displayName ?? "friend"}...',
                    hintStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.textMuted),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    fillColor: Colors.transparent,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    isDense: true,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _textController,
              builder: (context, value, _) {
                final hasText = value.text.trim().isNotEmpty;
                return Container(
                  margin: const EdgeInsets.only(bottom: 2),
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: hasText ? AppColors.accentMint : AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(19),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_upward,
                      size: 20,
                      color: hasText ? Colors.black : AppColors.textMuted,
                    ),
                    padding: EdgeInsets.zero,
                    tooltip: 'Send',
                    onPressed: hasText ? () => _handleSend(dmProvider) : null,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
