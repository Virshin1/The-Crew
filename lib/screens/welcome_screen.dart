import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_logo.dart';
import '../widgets/google_sign_in_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 32),
              // Hero logo
              _buildHeroBadge(),
              const SizedBox(height: 24),
              // Nightclub Mode pill
              _buildNightclubPill(),
              const SizedBox(height: 12),
              // Headline
              Text(
                'Hang out with\nyour crew in style',
                textAlign: TextAlign.center,
                style: AppTextStyles.headlineXlMobile.copyWith(
                  color: const Color(0xFFF6F6F6),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Where gaming, art, and vibrant communities collide in crystal-clear voice and aesthetic chat spaces.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              // Feature tiles
              _buildFeatureTile(
                  Icons.surround_sound, 'Spatial Audio', 'Immersive 360° studio-grade lounge acoustics'),
              const SizedBox(height: 8),
              _buildFeatureTile(
                  Icons.videocam_outlined, '4K Streaming', 'Zero-latency gameplay & creator broadcasts'),
              const SizedBox(height: 8),
              _buildFeatureTile(
                  Icons.palette_outlined, 'Aesthetic Spaces', 'Curated glass rooms with reactive lighting'),
              const SizedBox(height: 16),
              // Social proof
              _buildSocialProof(),
              const SizedBox(height: 24),
              // CTAs
              _buildCreateAccountButton(context),
              const SizedBox(height: 12),
              _buildLoginButton(context),
              const SizedBox(height: 12),
              const GoogleSignInButton(
                label: 'Continue with Google',
                height: 54,
              ),
              const SizedBox(height: 24),
              // Terms
              _buildTerms(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroBadge() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: AppColors.surfaceBase,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          padding: const EdgeInsets.all(4),
          child: const AppLogo(size: 88, borderRadius: 16, hasGlow: true),
        ),
        Positioned(
          top: -4,
          right: -4,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: AppColors.accentMint,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.surfaceBase, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNightclubPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceBase,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.accentMint,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'NIGHTCLUB MODE LIVE',
            style: AppTextStyles.labelSm.copyWith(
              color: AppColors.accentMint,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '• 42k Tuning In',
            style: AppTextStyles.labelSm.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureTile(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF121214),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderMuted),
            ),
            child: Icon(icon, color: AppColors.textPrimary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.headlineSm
                        .copyWith(color: AppColors.textPrimary)),
                Text(subtitle,
                    style: AppTextStyles.bodySm
                        .copyWith(color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.borderSubtle,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialProof() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF121214),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Stacked avatars
          SizedBox(
            width: 72,
            height: 32,
            child: Stack(
              children: [
                _avatarCircle('DJ', 0),
                _avatarCircle('VR', 24),
                _avatarCircle('+8', 48),
              ],
            ),
          ),
          Row(
            children: [
              const Icon(Icons.graphic_eq, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text('Neon Synth Room Active',
                  style: AppTextStyles.bodySm.copyWith(color: AppColors.onSurface)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _avatarCircle(String text, double left) {
    return Positioned(
      left: left,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.borderSubtle),
        ),
        alignment: Alignment.center,
        child: Text(text,
            style: AppTextStyles.labelSm.copyWith(color: AppColors.textSecondary)),
      ),
    );
  }

  Widget _buildCreateAccountButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () => context.go('/create-account'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentMint,
          foregroundColor: AppColors.surfaceBase,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('CREATE ACCOUNT',
                style: AppTextStyles.labelLg.copyWith(
                  color: AppColors.surfaceBase,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                )),
            const SizedBox(width: 6),
            Icon(Icons.arrow_forward, size: 18, color: AppColors.surfaceBase),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: () => context.go('/login'),
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.surfaceBase,
          side: const BorderSide(color: AppColors.borderSubtle),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        child: Text('Log In',
            style: AppTextStyles.labelLg.copyWith(color: const Color(0xFFF6F6F6))),
      ),
    );
  }

  Widget _buildTerms() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
        children: [
          const TextSpan(text: 'By jumping in, you agree to our '),
          TextSpan(
            text: 'Terms of Service',
            style: AppTextStyles.labelMd.copyWith(color: AppColors.onSurface),
          ),
          const TextSpan(text: ' and '),
          TextSpan(
            text: 'Privacy Policy',
            style: AppTextStyles.labelMd.copyWith(color: AppColors.onSurface),
          ),
          const TextSpan(text: '.'),
        ],
      ),
    );
  }
}
