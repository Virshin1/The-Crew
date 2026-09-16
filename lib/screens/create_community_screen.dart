import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/server_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_logo.dart';

class CreateCommunityScreen extends StatefulWidget {
  const CreateCommunityScreen({super.key});

  @override
  State<CreateCommunityScreen> createState() => _CreateCommunityScreenState();
}

class _CreateCommunityScreenState extends State<CreateCommunityScreen> {
  final TextEditingController _nameController = TextEditingController(text: 'Quantum Matrix');
  final TextEditingController _descController = TextEditingController(
      text: 'A high-speed cyber hub for gaming, builds, and sound synthesis.');
  bool _isPublic = true;
  String _selectedCategory = 'Gaming';
  bool _isLoading = false;

  final List<String> _categories = [
    'Gaming',
    'Music',
    'Tech',
    'Creative',
    'Social',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.error,
          content: Text('Please provide a community name.'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final serverProvider = context.read<ServerProvider>();
    final success = await serverProvider.createServer(
      name: name,
      description: _descController.text.trim(),
      category: _selectedCategory,
      isPublic: _isPublic,
      iconColor: _selectedCategory == 'Gaming'
          ? '#9D4EDD'
          : (_selectedCategory == 'Music' ? '#00F0FF' : '#FF007F'),
    );

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.accentMint,
            content: Text('Community "$name" created successfully!', style: const TextStyle(color: Colors.black)),
          ),
        );
        context.go('/servers');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text(serverProvider.errorMessage ?? 'Failed to create community.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withValues(alpha: 0.9),
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.onSurfaceVariant),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/discover');
            }
          },
        ),
        title: Row(
          children: [
            const AppLogo(size: 28, borderRadius: 8),
            const SizedBox(width: 8),
            Text('Create Community',
                style: AppTextStyles.headlineSm.copyWith(color: AppColors.textPrimary)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Community icon upload
            Center(
              child: Column(
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.accentMint.withValues(alpha: 0.6), width: 2),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt_outlined, size: 28, color: AppColors.accentMint),
                        SizedBox(height: 4),
                        Text('Icon', style: TextStyle(fontSize: 11, color: AppColors.accentMint)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Community Icon',
                      style: AppTextStyles.labelMd.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Community name
            _buildLabel('Community Name'),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: TextField(
                controller: _nameController,
                style: AppTextStyles.bodyMd.copyWith(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'e.g. Neon Arcade Lounge',
                  hintStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.outline),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  fillColor: Colors.transparent,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Description
            _buildLabel('Description'),
            const SizedBox(height: 6),
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: TextField(
                controller: _descController,
                maxLines: 5,
                style: AppTextStyles.bodyMd.copyWith(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'What\'s your community about?',
                  hintStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.outline),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  fillColor: Colors.transparent,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Category
            _buildLabel('Category'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.surfaceContainerHigh : AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: isSelected ? AppColors.accentMint : AppColors.borderSubtle,
                      ),
                    ),
                    child: Text(cat,
                        style: AppTextStyles.labelMd.copyWith(
                          color: isSelected ? AppColors.accentMint : AppColors.textSecondary,
                        )),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            // Privacy toggle
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Public Community',
                          style: AppTextStyles.headlineSm.copyWith(color: AppColors.textPrimary, fontSize: 14)),
                      Text('Anyone can discover and join from Discovery Hub',
                          style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted)),
                    ],
                  ),
                  Switch(
                    value: _isPublic,
                    onChanged: (v) => setState(() => _isPublic = v),
                    activeThumbColor: AppColors.accentMint,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Default channel templates
            _buildLabel('Default Channels (Auto-Created)'),
            const SizedBox(height: 8),
            _channelTemplate(Icons.tag, '#welcome', 'Welcome rules & introductions', true),
            _channelTemplate(Icons.tag, '#lounge', 'General conversation', true),
            _channelTemplate(Icons.tag, '#media-share', 'Gaming clips, music & art', true),
            _channelTemplate(Icons.volume_up, 'Lounge Voice', 'Spatial audio voice stage', true),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.borderSubtle)),
          ),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleCreate,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryContainer,
                foregroundColor: AppColors.surfaceBase,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Create Community',
                            style: AppTextStyles.headlineSm.copyWith(color: AppColors.surfaceBase)),
                        const SizedBox(width: 6),
                        const Icon(Icons.rocket_launch, size: 18, color: AppColors.surfaceBase),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text,
        style: AppTextStyles.labelMd.copyWith(color: AppColors.onSurface));
  }

  Widget _channelTemplate(IconData icon, String name, String desc, bool enabled) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.headlineSm.copyWith(color: AppColors.textPrimary, fontSize: 14)),
                Text(desc, style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted)),
              ],
            ),
          ),
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: enabled ? AppColors.accentMint : AppColors.surfaceContainerHighest,
            ),
            child: enabled ? const Icon(Icons.check, size: 14, color: Colors.black) : null,
          ),
        ],
      ),
    );
  }
}
