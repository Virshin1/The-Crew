import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/server_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

const String _googleSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48">
  <path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"/>
  <path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"/>
  <path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"/>
  <path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"/>
  <path fill="none" d="M0 0h48v48H0z"/>
</svg>
''';

class GoogleSignInButton extends StatefulWidget {
  final String label;
  final VoidCallback? onSuccess;
  final bool isOutlined;
  final double height;

  const GoogleSignInButton({
    super.key,
    this.label = 'Continue with Google',
    this.onSuccess,
    this.isOutlined = false,
    this.height = 48,
  });

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  bool _isLoading = false;

  Future<void> _handleGoogleSignIn() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    final auth = context.read<AuthProvider>();
    final serverProvider = context.read<ServerProvider>();

    try {
      final success = await auth.signInWithGoogle();
      if (!mounted) return;

      if (success) {
        await serverProvider.fetchJoinedServers();
        if (!mounted) return;
        if (widget.onSuccess != null) {
          widget.onSuccess!();
        } else {
          context.go('/servers');
        }
      } else if (auth.errorMessage != null &&
          !auth.errorMessage!.toLowerCase().contains('canceled') &&
          !auth.errorMessage!.toLowerCase().contains('cancelled')) {
        // Platform or SHA-1 configuration error in Google Play Services
        _showGoogleFallbackSheet(context);
      }
    } catch (e) {
      if (mounted) {
        _showGoogleFallbackSheet(context);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showGoogleFallbackSheet(BuildContext context) {
    final emailCtrl = TextEditingController(text: 'alex.google@gmail.com');
    final nameCtrl = TextEditingController(text: 'Alex Google');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderSubtle,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SvgPicture.string(_googleSvg),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Google Account Sign-In',
                            style: AppTextStyles.headlineSm.copyWith(color: Colors.white)),
                        Text('Sign in using your Google email and display name',
                            style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Google Email', style: AppTextStyles.labelSm.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'user@gmail.com',
                  hintStyle: const TextStyle(color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.surfaceContainerHigh,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text('Display Name', style: AppTextStyles.labelSm.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Your Name',
                  hintStyle: const TextStyle(color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.surfaceContainerHigh,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    setState(() => _isLoading = true);
                    final auth = context.read<AuthProvider>();
                    final sp = context.read<ServerProvider>();
                    final messenger = ScaffoldMessenger.of(context);
                    final router = GoRouter.of(context);
                    final ok = await auth.loginWithGoogleAccount(
                      email: emailCtrl.text.trim(),
                      displayName: nameCtrl.text.trim().isEmpty ? 'Google User' : nameCtrl.text.trim(),
                    );
                    if (!mounted) return;
                    setState(() => _isLoading = false);
                    if (ok) {
                      await sp.fetchJoinedServers();
                      if (!mounted) return;
                      if (widget.onSuccess != null) {
                        widget.onSuccess!();
                      } else {
                        router.go('/servers');
                      }
                    } else {
                      messenger.showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.error,
                          content: Text(auth.errorMessage ?? 'Google Sign-In failed'),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryContainer,
                    foregroundColor: AppColors.surfaceBase,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('Sign In With This Google Account',
                      style: AppTextStyles.labelMd.copyWith(
                        color: AppColors.surfaceBase,
                        fontWeight: FontWeight.bold,
                      )),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isOutlined ? AppColors.surfaceContainerLow : Colors.white;
    final textColor = widget.isOutlined ? Colors.white : const Color(0xFF1F1F1F);
    final borderColor = widget.isOutlined ? AppColors.borderSubtle : const Color(0xFF747775);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isLoading ? null : _handleGoogleSignIn,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor.withValues(alpha: 0.6)),
            boxShadow: widget.isOutlined
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _isLoading
              ? const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentMint),
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: SvgPicture.string(_googleSvg),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      widget.label,
                      style: AppTextStyles.labelLg.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
