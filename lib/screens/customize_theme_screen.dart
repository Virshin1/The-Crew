import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_logo.dart';

class CustomizeThemeScreen extends StatefulWidget {
  const CustomizeThemeScreen({super.key});

  @override
  State<CustomizeThemeScreen> createState() => _CustomizeThemeScreenState();
}

class _CustomizeThemeScreenState extends State<CustomizeThemeScreen> {
  int _selectedTheme = 0;
  int _selectedDensity = 1;
  double _glowIntensity = 85;

  static const _themes = [
    ('Mint Stealth', 'Signature lounge vibe', Color(0xFFCFFFE2), true),
    ('Cyber Emerald', 'Matrix slate & mint', Color(0xFF34D399), false),
    ('Midnight Tokyo', 'Deep indigo slate', Color(0xFF818CF8), true),
    ('Pure OLED', 'Pitch black & stark', Color(0xFF71717A), false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBase,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceBase,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurfaceVariant),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            const AppLogo(size: 28, borderRadius: 8),
            const SizedBox(width: 8),
            Text('Appearance', style: AppTextStyles.headlineSm.copyWith(color: AppColors.textPrimary)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surfaceBase,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            children: [
              // Header
              const AppLogo(size: 64, borderRadius: 16, hasGlow: true),
              const SizedBox(height: 12),
              Text('Customize Appearance',
                  style: AppTextStyles.headlineMd.copyWith(color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Text('Tailor colors, density, and glow effects to match your setup vibe.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 24),
              // Theme palette
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Theme Palette', style: AppTextStyles.labelMd.copyWith(color: AppColors.onSurface)),
                  Text('DYNAMIC GLOW', style: AppTextStyles.labelSm.copyWith(color: AppColors.textSecondary, letterSpacing: 1)),
                ],
              ),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 1.3),
                itemCount: 4,
                itemBuilder: (_, i) => _themeCard(i),
              ),
              const SizedBox(height: 20),
              // Density
              Text('Interface Density', style: AppTextStyles.labelMd.copyWith(color: AppColors.onSurface)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceBase,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Row(
                  children: List.generate(3, (i) {
                    final labels = ['Compact', 'Default', 'Spacious'];
                    final isActive = _selectedDensity == i;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedDensity = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 36,
                          decoration: BoxDecoration(
                            color: isActive ? AppColors.accentMint : Colors.transparent,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          alignment: Alignment.center,
                          child: Text(labels[i],
                              style: AppTextStyles.labelMd.copyWith(
                                color: isActive ? AppColors.surfaceBase : AppColors.textSecondary,
                                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                              )),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 20),
              // Glow slider
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0E0E10),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          const Icon(Icons.auto_awesome, size: 20, color: Colors.white),
                          const SizedBox(width: 6),
                          Text('Glow Effects Intensity',
                              style: AppTextStyles.labelMd.copyWith(color: AppColors.onSurface)),
                        ]),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF18181C),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: AppColors.borderSubtle),
                          ),
                          child: Text('${_glowIntensity.round()}%',
                              style: AppTextStyles.labelSm.copyWith(color: Colors.white)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: AppColors.accentMint,
                        inactiveTrackColor: AppColors.surfaceRaised,
                        thumbColor: AppColors.accentMint,
                        trackHeight: 6,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                      ),
                      child: Slider(
                        value: _glowIntensity,
                        min: 0,
                        max: 100,
                        onChanged: (v) => setState(() => _glowIntensity = v),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Subtle', style: AppTextStyles.labelSm.copyWith(color: AppColors.textSecondary)),
                        Text('Hyper-Glow', style: AppTextStyles.labelSm.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Apply button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => context.pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentMint,
                    foregroundColor: AppColors.surfaceBase,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    elevation: 0,
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('Apply Changes',
                        style: AppTextStyles.labelLg.copyWith(color: AppColors.surfaceBase, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 4),
                    Icon(Icons.bolt, size: 18, color: AppColors.surfaceBase),
                  ]),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => context.pop(),
                child: Text('Cancel',
                    style: AppTextStyles.labelMd.copyWith(color: AppColors.textMuted)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _themeCard(int index) {
    final theme = _themes[index];
    final isSelected = _selectedTheme == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTheme = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF18181C) : const Color(0xFF0E0E10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.accentMint : Colors.white.withValues(alpha: 0.05),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surfaceBase,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Center(
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: theme.$3),
                    ),
                  ),
                ),
                if (theme.$4)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.accentMint.withValues(alpha: 0.15)
                          : AppColors.surfaceBright,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                          color: isSelected
                              ? AppColors.accentMint.withValues(alpha: 0.3)
                              : Colors.white.withValues(alpha: 0.05)),
                    ),
                    child: Text('NEW',
                        style: AppTextStyles.labelSm.copyWith(
                            fontSize: 9,
                            color: isSelected ? AppColors.accentMint : AppColors.textSecondary)),
                  ),
              ],
            ),
            const Spacer(),
            Text(theme.$1, style: AppTextStyles.headlineSm.copyWith(color: AppColors.onSurface, fontSize: 14)),
            Text(theme.$2, style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary)),
            if (isSelected)
              Positioned(
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accentMint,
                    ),
                    child: const Icon(Icons.check, size: 14, color: AppColors.surfaceBase),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
