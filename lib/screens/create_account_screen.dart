import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/server_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_logo.dart';
import '../widgets/google_sign_in_button.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final TextEditingController _displayNameController =
      TextEditingController(text: 'Atlas Nova');
  final TextEditingController _usernameController =
      TextEditingController(text: 'atlas_void');
  final TextEditingController _emailController =
      TextEditingController(text: 'atlas@squad.network');
  final TextEditingController _passwordController =
      TextEditingController(text: 'password123');

  bool _obscurePassword = true;
  bool _termsAccepted = true;
  final Set<String> _selectedInterests = {'Gaming', 'Tech'};

  @override
  void dispose() {
    _displayNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateAccount() async {
    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.error,
          content: Text('Please accept the Terms of Protocol to continue.'),
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final serverProvider = context.read<ServerProvider>();

    final success = await auth.register(
      username: _usernameController.text.trim(),
      displayName: _displayNameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      interests: _selectedInterests.join(','),
    );

    if (mounted) {
      if (success) {
        await serverProvider.fetchJoinedServers();
        if (mounted) context.go('/servers');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text(auth.errorMessage ?? 'Account creation failed. Try a different username/email.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              children: [
                // Brand header
                _buildBrandHeader(),
                const SizedBox(height: 20),
                // Social quick entry
                Row(
                  children: [
                    const Expanded(
                      child: GoogleSignInButton(
                        label: 'Google',
                        isOutlined: true,
                        height: 44,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: _socialButton('Apple')),
                  ],
                ),
                const SizedBox(height: 20),
                // Divider
                _buildDivider(),
                const SizedBox(height: 20),
                // Form
                _buildDisplayNameField(),
                const SizedBox(height: 16),
                _buildUsernameField(),
                const SizedBox(height: 16),
                _buildEmailField(),
                const SizedBox(height: 16),
                _buildPasswordField(),
                const SizedBox(height: 16),
                _buildInterests(),
                const SizedBox(height: 12),
                _buildTermsCheckbox(),
                const SizedBox(height: 16),
                _buildCreateButton(),
                const SizedBox(height: 20),
                _buildLoginLink(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandHeader() {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            const AppLogo(size: 64, borderRadius: 16, hasGlow: true),
            Positioned(
              bottom: -4,
              right: -4,
              child: Container(
                width: 14,
                height: 14,
                decoration: const BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.accentMint,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text('SYSTEM READY',
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.accentMint,
                    letterSpacing: 1.5,
                  )),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text('Join The Crew',
            style: AppTextStyles.headlineLg.copyWith(color: Colors.white)),
        const SizedBox(height: 4),
        Text('One identity across voice, matrix and spatial hubs',
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
      ],
    );
  }

  Widget _socialButton(String label) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(label,
            style: AppTextStyles.labelMd.copyWith(color: Colors.white)),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: AppColors.surfaceContainerHighest)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('OR DIRECT ACCESS',
              style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.outline, letterSpacing: 1)),
        ),
        Expanded(child: Container(height: 1, color: AppColors.surfaceContainerHighest)),
      ],
    );
  }

  Widget _buildDisplayNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Display Name',
                style: AppTextStyles.labelMd.copyWith(color: AppColors.onSurface)),
            Text('Public title',
                style: AppTextStyles.bodySm.copyWith(color: AppColors.onSurfaceVariant)),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _displayNameController,
                  style: AppTextStyles.bodyMd.copyWith(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'e.g. Atlas Nova',
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
              const Icon(Icons.badge_outlined, size: 18, color: AppColors.outline),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUsernameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Username',
                style: AppTextStyles.labelMd.copyWith(color: AppColors.onSurface)),
            Row(
              children: [
                const Icon(Icons.verified, size: 14, color: AppColors.secondaryAuth),
                const SizedBox(width: 4),
                Text('available',
                    style: AppTextStyles.labelSm
                        .copyWith(color: AppColors.secondaryAuth)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Text('@',
                  style: AppTextStyles.labelMd
                      .copyWith(color: AppColors.secondaryAuth, fontWeight: FontWeight.bold)),
              const SizedBox(width: 4),
              Expanded(
                child: TextField(
                  controller: _usernameController,
                  style: AppTextStyles.bodyMd.copyWith(color: Colors.white),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    fillColor: Colors.transparent,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const Icon(Icons.check_circle, size: 18, color: AppColors.secondaryAuth),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Email Address',
            style: AppTextStyles.labelMd.copyWith(color: AppColors.onSurface)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _emailController,
                  style: AppTextStyles.bodyMd.copyWith(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'atlas@squad.network',
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
              const Icon(Icons.alternate_email, size: 18, color: AppColors.outline),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Password',
                style: AppTextStyles.labelMd.copyWith(color: AppColors.onSurface)),
            Text('Strong',
                style: AppTextStyles.labelSm
                    .copyWith(color: AppColors.secondaryAuth)),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: AppTextStyles.bodyMd.copyWith(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: '••••••••••••',
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
              GestureDetector(
                onTap: () => setState(() => _obscurePassword = !_obscurePassword),
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
        const SizedBox(height: 6),
        Row(
          children: List.generate(4, (i) {
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: i < 3
                      ? AppColors.primaryContainer
                      : AppColors.surfaceContainerHighest,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildInterests() {
    final interests = [
      ('Gaming', Icons.sports_esports),
      ('Music', Icons.headphones),
      ('Tech', Icons.terminal),
      ('Art & Design', Icons.draw),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Primary Interests',
                style: AppTextStyles.labelMd.copyWith(color: AppColors.onSurface)),
            Text('Select hubs',
                style: AppTextStyles.labelSm
                    .copyWith(color: AppColors.onSurfaceVariant)),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: interests.map((item) {
            final isActive = _selectedInterests.contains(item.$1);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isActive) {
                    _selectedInterests.remove(item.$1);
                  } else {
                    _selectedInterests.add(item.$1);
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.secondaryContainerAuth
                      : AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(item.$2,
                        size: 14,
                        color: isActive
                            ? AppColors.primaryContainer
                            : AppColors.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(item.$1,
                        style: AppTextStyles.labelSm.copyWith(
                          color: isActive
                              ? AppColors.primaryContainer
                              : AppColors.onSurfaceVariant,
                        )),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _termsAccepted = !_termsAccepted),
          child: Container(
            width: 16,
            height: 16,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: _termsAccepted
                  ? AppColors.primaryContainer
                  : AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(4),
            ),
            child: _termsAccepted
                ? const Icon(Icons.check, size: 12, color: Colors.black)
                : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: AppTextStyles.bodySm.copyWith(color: AppColors.onSurfaceVariant),
              children: [
                const TextSpan(text: 'I accept the '),
                TextSpan(
                    text: 'Terms of Protocol',
                    style: AppTextStyles.bodySm.copyWith(color: Colors.white)),
                const TextSpan(text: ' and verify review of the '),
                TextSpan(
                    text: 'Privacy Matrix',
                    style: AppTextStyles.bodySm.copyWith(color: Colors.white)),
                const TextSpan(text: '.'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCreateButton() {
    final auth = context.watch<AuthProvider>();

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: auth.isLoading ? null : _handleCreateAccount,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryContainer,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: auth.isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Create Account',
                      style: AppTextStyles.headlineSm
                          .copyWith(color: Colors.black)),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_forward, size: 18, color: Colors.black),
                ],
              ),
      ),
    );
  }


  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Already have a crew? ',
            style: AppTextStyles.bodySm.copyWith(color: AppColors.onSurfaceVariant)),
        GestureDetector(
          onTap: () => context.go('/login'),
          child: Row(
            children: [
              Text('Log In',
                  style: AppTextStyles.labelMd
                      .copyWith(color: AppColors.secondaryAuth)),
              const SizedBox(width: 2),
              const Icon(Icons.north_east, size: 14, color: AppColors.secondaryAuth),
            ],
          ),
        ),
      ],
    );
  }
}
