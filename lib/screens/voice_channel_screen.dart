import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/voice_participant_model.dart';
import '../providers/server_provider.dart';
import '../providers/voice_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_logo.dart';

class VoiceChannelScreen extends StatefulWidget {
  const VoiceChannelScreen({super.key});

  @override
  State<VoiceChannelScreen> createState() => _VoiceChannelScreenState();
}

class _VoiceChannelScreenState extends State<VoiceChannelScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final serverProvider = context.read<ServerProvider>();
      final voiceChannels = serverProvider.voiceChannels;
      final channelId = voiceChannels.isNotEmpty ? voiceChannels.first.id : 'c5';

      context.read<VoiceProvider>().joinVoice(channelId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final voice = context.watch<VoiceProvider>();
    final participants = voice.participants;

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
            Text('Live Stage', style: AppTextStyles.headlineSm.copyWith(color: AppColors.textPrimary)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.onSurfaceVariant),
            onPressed: () {
              if (voice.channelId != null) voice.loadParticipants(voice.channelId!);
            },
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
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Telemetry bar
                  _buildTelemetryBar(),
                  const SizedBox(height: 12),
                  // Stream preview
                  _buildStreamPreview(),
                  const SizedBox(height: 12),
                  // Member grid
                  if (participants.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Text('Connecting to voice node...',
                            style: AppTextStyles.bodyMd.copyWith(color: AppColors.textMuted)),
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: participants.length,
                      itemBuilder: (_, i) {
                        final m = participants[i];
                        return _memberTile(m);
                      },
                    ),
                ],
              ),
            ),
          ),
          // Call controls
          _buildCallControls(context, voice),
        ],
      ),
    );
  }

  Widget _buildTelemetryBar() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.borderMuted),
                ),
                child: const Icon(Icons.keyboard_arrow_down, size: 18, color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(color: AppColors.accentMint, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Text('Chill Beats & Gaming',
                          style: AppTextStyles.headlineSm.copyWith(color: const Color(0xFFF6F6F6), fontSize: 13)),
                    ],
                  ),
                  Text('RTC Node: Frankfurt • 18ms',
                      style: AppTextStyles.bodySm.copyWith(fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Text('384kbps Opus',
                style: AppTextStyles.labelSm.copyWith(color: AppColors.accentMint, fontSize: 10)),
          ),
        ],
      ),
    );
  }

  Widget _buildStreamPreview() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.stream, size: 36, color: AppColors.accentMint),
                const SizedBox(height: 8),
                Text('Kaelen is live streaming Sector 9',
                    style: AppTextStyles.labelMd.copyWith(color: AppColors.textPrimary)),
                Text('1080p 60fps • 0 latency',
                    style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted)),
              ],
            ),
          ),
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _memberTile(VoiceParticipantModel member) {
    final isSpeaking = member.isSpeaking;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSpeaking ? AppColors.accentMint : AppColors.borderSubtle,
          width: isSpeaking ? 2 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              if (isSpeaking)
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.accentMint.withValues(alpha: 0.5), width: 4),
                  ),
                ),
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.surfaceContainerHigh,
                child: Text(
                  member.displayName.isNotEmpty ? member.displayName[0].toUpperCase() : 'U',
                  style: AppTextStyles.headlineSm.copyWith(color: AppColors.textPrimary),
                ),
              ),
              if (member.isMuted)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: const Icon(Icons.mic_off, size: 12, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(member.displayName,
              style: AppTextStyles.headlineSm.copyWith(color: AppColors.textPrimary, fontSize: 14)),
          const SizedBox(height: 2),
          Text(
            isSpeaking ? 'Speaking...' : member.statusText,
            style: AppTextStyles.bodySm.copyWith(
              color: isSpeaking ? AppColors.accentMint : AppColors.textMuted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallControls(BuildContext context, VoiceProvider voice) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        border: const Border(top: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Mic mute
            _controlCircle(
              icon: voice.isMuted ? Icons.mic_off : Icons.mic,
              color: voice.isMuted ? Colors.red : AppColors.surfaceContainerHigh,
              iconColor: voice.isMuted ? Colors.white : AppColors.textPrimary,
              onTap: () => voice.toggleMute(),
            ),
            // Deafen
            _controlCircle(
              icon: voice.isDeafened ? Icons.headset_off : Icons.headphones,
              color: voice.isDeafened ? Colors.orange : AppColors.surfaceContainerHigh,
              iconColor: voice.isDeafened ? Colors.white : AppColors.textPrimary,
              onTap: () => voice.toggleDeafen(),
            ),
            // Test speaking toggle
            _controlCircle(
              icon: Icons.record_voice_over,
              color: voice.isSpeaking ? AppColors.accentMint : AppColors.surfaceContainerHigh,
              iconColor: voice.isSpeaking ? Colors.black : AppColors.textPrimary,
              onTap: () => voice.toggleSpeaking(),
            ),
            // End call
            _controlCircle(
              icon: Icons.call_end,
              color: Colors.red,
              iconColor: Colors.white,
              onTap: () async {
                await voice.leaveVoice();
                if (context.mounted) context.pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _controlCircle({
    required IconData icon,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 24, color: iconColor),
      ),
    );
  }
}
