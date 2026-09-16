import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/server_model.dart';
import '../providers/server_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_logo.dart';

class CommunityDiscoveryScreen extends StatefulWidget {
  const CommunityDiscoveryScreen({super.key});

  @override
  State<CommunityDiscoveryScreen> createState() => _CommunityDiscoveryScreenState();
}

class _CommunityDiscoveryScreenState extends State<CommunityDiscoveryScreen> {
  String _selectedCategory = 'Featured';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'Featured',
    'Gaming',
    'Anime & Art',
    'Music',
    'Tech',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServerProvider>().fetchDiscoveryServers(category: _selectedCategory);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onCategorySelected(String category) {
    setState(() => _selectedCategory = category);
    context.read<ServerProvider>().fetchDiscoveryServers(
      category: category,
      search: _searchController.text.trim(),
    );
  }

  void _onSearch(String query) {
    context.read<ServerProvider>().fetchDiscoveryServers(
      category: _selectedCategory,
      search: query.trim(),
    );
  }

  Future<void> _handleJoinServer(ServerModel server) async {
    final serverProvider = context.read<ServerProvider>();
    final isAlreadyMember = serverProvider.joinedServers.any((s) => s.id == server.id);

    if (isAlreadyMember) {
      await serverProvider.selectServer(server);
      if (mounted) context.go('/servers');
      return;
    }

    final success = await serverProvider.joinServer(server.id);
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.accentMint,
            content: Text('Joined ${server.name}! Welcome to the crew.', style: const TextStyle(color: Colors.black)),
          ),
        );
        await serverProvider.selectServer(server);
        if (mounted) context.go('/servers');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.error,
            content: Text('Failed to join server.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final serverProvider = context.watch<ServerProvider>();
    final servers = serverProvider.discoveryServers;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withValues(alpha: 0.9),
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const AppLogo(size: 32, borderRadius: 8),
            const SizedBox(width: 8),
            Text('Discovery', style: AppTextStyles.headlineSm.copyWith(color: AppColors.textPrimary)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.onSurfaceVariant),
            onPressed: () => context.go('/discover/create'),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
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
                        onSubmitted: _onSearch,
                        decoration: InputDecoration(
                          hintText: 'Find servers, hubs & soundscapes...',
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
            // Category chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _categories.map((cat) {
                    final isActive = _selectedCategory == cat;
                    return GestureDetector(
                      onTap: () => _onCategorySelected(cat),
                      child: _categoryChip(cat, isActive),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Trending header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.trending_up, size: 18, color: AppColors.textPrimary),
                      const SizedBox(width: 6),
                      Text('Trending Communities',
                          style: AppTextStyles.headlineSm.copyWith(color: AppColors.textPrimary)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Text('${servers.length} HUBS',
                        style: AppTextStyles.labelSm.copyWith(color: AppColors.textSecondary)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Community cards
            if (serverProvider.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(color: AppColors.primaryContainer),
                ),
              )
            else if (servers.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Text('No communities found in this category.',
                      style: AppTextStyles.bodyMd.copyWith(color: AppColors.textMuted)),
                ),
              )
            else
              ...servers.map((server) {
                final isJoined = serverProvider.joinedServers.any((s) => s.id == server.id);
                return _communityCard(
                  server: server,
                  isJoined: isJoined,
                  onJoin: () => _handleJoinServer(server),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _categoryChip(String label, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? AppColors.surfaceContainerHigh : AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isActive ? AppColors.accentMint.withValues(alpha: 0.8) : AppColors.borderMuted,
        ),
      ),
      child: Text(label,
          style: AppTextStyles.labelMd.copyWith(
            color: isActive ? AppColors.accentMint : AppColors.textSecondary,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          )),
    );
  }

  Widget _communityCard({
    required ServerModel server,
    required bool isJoined,
    required VoidCallback onJoin,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover image banner placeholder
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(Icons.hub_outlined, size: 40, color: AppColors.textMuted.withValues(alpha: 0.5)),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceBase.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Text(server.level,
                        style: AppTextStyles.labelSm.copyWith(color: AppColors.textPrimary)),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text(server.name,
                              style: AppTextStyles.headlineSm.copyWith(color: AppColors.textPrimary)),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward, size: 14, color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: onJoin,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isJoined ? AppColors.surfaceContainerHighest : AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Text(
                          isJoined ? 'Joined' : 'Join',
                          style: AppTextStyles.labelMd.copyWith(
                            color: isJoined ? AppColors.textSecondary : Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('${server.onlineCount} Online • ${server.memberCount} Members',
                    style: AppTextStyles.labelSm.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                if (server.description != null && server.description!.isNotEmpty)
                  Text(server.description!,
                      style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: [server.category, 'Discord-Clone'].map((t) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(t,
                        style: AppTextStyles.labelSm.copyWith(color: AppColors.textMuted)),
                  )).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
