import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _progressAnimation = Tween<double>(begin: 0.12, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOutCubic),
    )..addListener(() {
        setState(() {});
      });
    _progressController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  void _showAuthOptionsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: AppColors.borderSubtle),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 32,
              spreadRadius: 4,
            ),
          ],
        ),
        child: SafeArea(
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
              const AppLogo(size: 56, borderRadius: 14, hasGlow: true),
              const SizedBox(height: 12),
              Text(
                'Enter The Crew',
                style: AppTextStyles.headlineMd.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 6),
              Text(
                'Sign in to your account or register a new one to join.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              // Create Account
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    context.go('/create-account');
                  },
                  icon: const Icon(Icons.person_add_outlined, size: 20),
                  label: const Text('Create Account'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentMint,
                    foregroundColor: const Color(0xFF0A0A0B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: AppTextStyles.labelLg.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Log In
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    context.go('/login');
                  },
                  icon: const Icon(Icons.login, size: 20, color: Colors.white),
                  label: const Text('Log In'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.borderSubtle),
                    backgroundColor: AppColors.surfaceContainerHigh,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: AppTextStyles.labelLg.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Welcome Tour
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.go('/welcome');
                },
                child: Text(
                  'Explore Welcome Overview →',
                  style: AppTextStyles.labelSm.copyWith(color: AppColors.accentMint),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progressVal = _progressAnimation.value;
    final percentInt = (progressVal * 100).toInt().clamp(0, 100);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0B),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: (constraints.maxHeight - 32).clamp(0.0, double.infinity),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top header: Network indicator + Latency
                    _buildTopHeader(),

                    // Centered Hero Card
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: _buildHeroCard(context, progressVal, percentInt),
                    ),

                    // Bottom Footer
                    _buildFooter(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF131315),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFF27272A)),
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
              const SizedBox(width: 8),
              Text(
                'NETWORK V2.4',
                style: AppTextStyles.labelSm.copyWith(
                  color: const Color(0xFFA2D5C6),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'LATENCY ',
              style: AppTextStyles.labelSm.copyWith(
                color: const Color(0xFF71717A),
                letterSpacing: 1,
                fontSize: 11,
              ),
            ),
            Text(
              '18ms',
              style: AppTextStyles.labelSm.copyWith(
                color: const Color(0xFFF6F6F6),
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroCard(BuildContext context, double progressVal, int percentInt) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 400),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF131315),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFF27272A)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 36,
            spreadRadius: 4,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // SPATIAL CHAT & COMMUNITY Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF18181B),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFF27272A)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.bolt, size: 14, color: AppColors.accentMint),
                const SizedBox(width: 4),
                Text(
                  'SPATIAL CHAT & COMMUNITY',
                  style: AppTextStyles.labelSm.copyWith(
                    color: const Color(0xFFA1A1AA),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // App Logo with glowing styling
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 104,
                height: 104,
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0A0B),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF27272A), width: 1.5),
                ),
                padding: const EdgeInsets.all(4),
                child: const AppLogo(
                  size: 96,
                  borderRadius: 20,
                  hasGlow: true,
                ),
              ),
              Positioned(
                bottom: -2,
                right: -2,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A0A0B),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF131315), width: 2),
                  ),
                  child: Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppColors.accentMint,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // App Title
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'The Crew',
                style: AppTextStyles.headlineLg.copyWith(
                  color: const Color(0xFFF6F6F6),
                  fontWeight: FontWeight.w800,
                  fontSize: 30,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.accentMint,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Tagline
          Text(
            'Where gaming, soundscapes, and aesthetic spaces connect.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMd.copyWith(
              color: const Color(0xFFA1A1AA),
              height: 1.45,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 24),

          // Progress indicator
          Container(
            padding: const EdgeInsets.only(top: 16),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFF27272A), width: 1),
              ),
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    height: 6,
                    color: const Color(0xFF18181B),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: double.infinity,
                        color: Colors.transparent,
                        child: FractionallySizedBox(
                          widthFactor: progressVal,
                          alignment: Alignment.centerLeft,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.accentMint,
                              borderRadius: BorderRadius.circular(999),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accentMint.withValues(alpha: 0.6),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'SYNCING NODES',
                      style: AppTextStyles.labelSm.copyWith(
                        color: const Color(0xFF71717A),
                        letterSpacing: 1.2,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      '$percentInt%',
                      style: AppTextStyles.labelSm.copyWith(
                        color: const Color(0xFFA2D5C6),
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Action buttons: Direct to Login or Create Account
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                final auth = context.read<AuthProvider>();
                if (auth.isAuthenticated) {
                  context.go('/servers');
                } else {
                  _showAuthOptionsModal(context);
                }
              },
              icon: const Icon(Icons.login, size: 20),
              label: const Text('Get Started / Log In'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentMint,
                foregroundColor: const Color(0xFF0A0A0B),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: AppTextStyles.labelLg.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.go('/login'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFF27272A)),
                    backgroundColor: const Color(0xFF18181B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text('Log In', style: AppTextStyles.labelSm.copyWith(color: Colors.white)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.go('/create-account'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accentMint,
                    side: BorderSide(color: AppColors.accentMint.withValues(alpha: 0.3)),
                    backgroundColor: const Color(0xFF18181B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text('Sign Up', style: AppTextStyles.labelSm.copyWith(color: AppColors.accentMint)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: Color(0xFFA2D5C6),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'Encrypted Audio',
                  style: AppTextStyles.labelSm.copyWith(
                    color: const Color(0xFF71717A),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const Text('•', style: TextStyle(color: Color(0xFF71717A), fontSize: 11)),
            Text(
              'Ultra Low-Latency',
              style: AppTextStyles.labelSm.copyWith(
                color: const Color(0xFF71717A),
                fontSize: 11,
              ),
            ),
            const Text('•', style: TextStyle(color: Color(0xFF71717A), fontSize: 11)),
            Text(
              'Zero Ads',
              style: AppTextStyles.labelSm.copyWith(
                color: const Color(0xFF71717A),
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          '© 2026 The Crew Network Protocol. All systems operational.',
          textAlign: TextAlign.center,
          style: AppTextStyles.labelSm.copyWith(
            color: const Color(0xFF52525B),
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
