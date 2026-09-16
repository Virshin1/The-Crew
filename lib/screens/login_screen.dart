import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/server_provider.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_logo.dart';
import '../widgets/google_sign_in_button.dart';
import '../widgets/server_config_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _loginController =
      TextEditingController(text: 'kaelen_vr');
  final TextEditingController _passwordController =
      TextEditingController(text: 'password123');
  bool _obscurePassword = true;
  bool _rememberDevice = true;

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final auth = context.read<AuthProvider>();
    final serverProvider = context.read<ServerProvider>();

    final success = await auth.login(
      login: _loginController.text.trim(),
      password: _passwordController.text,
    );

    if (mounted) {
      if (success) {
        await serverProvider.fetchJoinedServers();
        if (mounted) context.go('/servers');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text(auth.errorMessage ?? 'Login failed. Please check your credentials.'),
            action: SnackBarAction(
              label: 'Server IP',
              textColor: Colors.white,
              onPressed: () => ServerConfigDialog.show(context),
            ),
          ),
        );
      }
    }
  }

  Future<void> _handleQuickLogin(String username) async {
    final auth = context.read<AuthProvider>();
    final serverProvider = context.read<ServerProvider>();

    final success = await auth.quickLogin(username);
    if (mounted) {
      if (success) {
        await serverProvider.fetchJoinedServers();
        if (mounted) context.go('/servers');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text(auth.errorMessage ?? 'Quick demo login failed.'),
            action: SnackBarAction(
              label: 'Server IP',
              textColor: Colors.white,
              onPressed: () => ServerConfigDialog.show(context),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              children: [
                // Top bar with Back and Server connection pill
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppColors.onSurfaceVariant),
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/');
                        }
                      },
                    ),
                    InkWell(
                      onTap: () async {
                        await ServerConfigDialog.show(context);
                        setState(() {});
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: AppColors.accentMint,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              ApiService.host,
                              style: AppTextStyles.labelSm.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.tune, size: 12, color: AppColors.textMuted),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Logo
                const AppLogo(size: 64, borderRadius: 16, hasGlow: true),
                const SizedBox(height: 16),
                Text('Welcome back',
                    style: AppTextStyles.headlineLg.copyWith(color: Colors.white)),
                const SizedBox(height: 4),
                Text(
                  'Sign in to reconnect with your crew and channels',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMd.copyWith(color: AppColors.outlineVariant),
                ),
                const SizedBox(height: 24),
                // Form card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Email / Username
                      Text('Email or Username',
                          style: AppTextStyles.labelMd
                              .copyWith(color: AppColors.onSurfaceVariant)),
                      const SizedBox(height: 6),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            const Icon(Icons.alternate_email,
                                size: 18, color: AppColors.outline),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _loginController,
                                style: AppTextStyles.bodyMd
                                    .copyWith(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: 'name@domain.com or squad_handle',
                                  hintStyle: AppTextStyles.bodyMd
                                      .copyWith(color: AppColors.outline),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  filled: false,
                                  fillColor: Colors.transparent,
                                  contentPadding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Password
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Password',
                              style: AppTextStyles.labelMd
                                  .copyWith(color: AppColors.onSurfaceVariant)),
                          Text('Forgot password?',
                              style: AppTextStyles.labelSm
                                  .copyWith(color: AppColors.secondary)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            const Icon(Icons.lock_outline,
                                size: 18, color: AppColors.outline),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                style: AppTextStyles.bodyMd
                                    .copyWith(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: '••••••••••••',
                                  hintStyle: AppTextStyles.bodyMd
                                      .copyWith(color: AppColors.outline),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  filled: false,
                                  fillColor: Colors.transparent,
                                  contentPadding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                              child: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                size: 18,
                                color: AppColors.outline,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Remember device
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.security,
                                  size: 18, color: AppColors.outline),
                              const SizedBox(width: 8),
                              Text('Remember this device',
                                  style: AppTextStyles.labelMd
                                      .copyWith(color: AppColors.onSurfaceVariant)),
                            ],
                          ),
                          GestureDetector(
                            onTap: () =>
                                setState(() => _rememberDevice = !_rememberDevice),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 40,
                              height: 24,
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: _rememberDevice
                                    ? AppColors.secondary
                                    : AppColors.surfaceContainerHighest,
                              ),
                              child: AnimatedAlign(
                                duration: const Duration(milliseconds: 200),
                                alignment: _rememberDevice
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _rememberDevice
                                        ? const Color(0xFF00382E)
                                        : AppColors.outline,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Login CTA
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: auth.isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryContainer,
                            foregroundColor: AppColors.surfaceBase,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: auth.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Log In',
                                        style: AppTextStyles.headlineSm.copyWith(
                                          color: AppColors.surfaceBase,
                                          fontWeight: FontWeight.w600,
                                        )),
                                    const SizedBox(width: 6),
                                    Icon(Icons.arrow_forward,
                                        size: 18, color: AppColors.surfaceBase),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Quick Demo Login buttons
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Column(
                    children: [
                      Text('ONE-CLICK DEMO LOGIN',
                          style: AppTextStyles.labelSm.copyWith(
                            color: AppColors.textMuted,
                            letterSpacing: 1.2,
                          )),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _handleQuickLogin('kaelen_vr'),
                              child: _demoPill('👑 Kaelen (Owner)', AppColors.accentMint),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _handleQuickLogin('nyx_9'),
                              child: _demoPill('💜 Nyx (VIP)', AppColors.accentPurple),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Divider
                Row(
                  children: [
                    Expanded(child: Container(height: 1, color: AppColors.surfaceContainerHighest)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('OR CONTINUE WITH',
                          style: AppTextStyles.labelSm.copyWith(
                            color: AppColors.outline,
                            letterSpacing: 1.2,
                          )),
                    ),
                    Expanded(child: Container(height: 1, color: AppColors.surfaceContainerHighest)),
                  ],
                ),
                const SizedBox(height: 12),
                const GoogleSignInButton(
                  label: 'Continue with Google',
                ),
                const SizedBox(height: 10),
                // Social buttons
                Row(
                  children: [
                    Expanded(child: _socialButton(Icons.discord, 'Discord')),
                    const SizedBox(width: 8),
                    Expanded(child: _socialButton(Icons.account_circle_outlined, 'Passkey')),
                  ],
                ),
                const SizedBox(height: 24),
                // Create account link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('New to the network? ',
                        style: AppTextStyles.bodyMd
                            .copyWith(color: AppColors.onSurfaceVariant)),
                    GestureDetector(
                      onTap: () => context.go('/create-account'),
                      child: Text('Create account',
                          style: AppTextStyles.labelMd
                              .copyWith(color: AppColors.secondary)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Privacy Protocol',
                        style: AppTextStyles.labelSm
                            .copyWith(color: AppColors.outline)),
                    Text(' • ',
                        style: AppTextStyles.labelSm
                            .copyWith(color: AppColors.outline)),
                    Text('Terms of Operations',
                        style: AppTextStyles.labelSm
                            .copyWith(color: AppColors.outline)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _demoPill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Center(
        child: Text(label,
            style: AppTextStyles.labelSm.copyWith(color: color, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _socialButton(IconData icon, String label) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: AppColors.onSurface),
          const SizedBox(width: 8),
          Text(label,
              style: AppTextStyles.labelMd.copyWith(color: AppColors.onSurface)),
        ],
      ),
    );
  }
}
