import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/navigation_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Floating pill-shaped bottom navigation bar matching The Crew design.
class BottomNavShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const BottomNavShell({super.key, required this.navigationShell});

  static const _items = [
    _NavItem(icon: Icons.dns_outlined, activeIcon: Icons.dns, label: 'Servers'),
    _NavItem(icon: Icons.forum_outlined, activeIcon: Icons.forum, label: 'Messages'),
    _NavItem(icon: Icons.explore_outlined, activeIcon: Icons.explore, label: 'Explore'),
    _NavItem(icon: Icons.local_fire_department_outlined, activeIcon: Icons.local_fire_department, label: 'Activity'),
    _NavItem(icon: Icons.account_circle_outlined, activeIcon: Icons.account_circle, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    // Check both MediaQuery and raw platform view insets for guaranteed keyboard detection
    final mediaQueryInsets = MediaQuery.of(context).viewInsets.bottom;
    final viewInsets = View.of(context).viewInsets.bottom / View.of(context).devicePixelRatio;
    final isKeyboardOpen = mediaQueryInsets > 0 || viewInsets > 0;

    return ValueListenableBuilder<bool>(
      valueListenable: NavigationService().isBottomNavVisible,
      builder: (context, isNavVisible, _) {
        final showBottomBar = isNavVisible && !isKeyboardOpen;

        return Scaffold(
          body: navigationShell,
          extendBody: true,
          bottomNavigationBar: !showBottomBar
              ? const SizedBox.shrink()
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Container(
                      height: 66,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(33),
                        border: Border.all(color: AppColors.borderSubtle, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(_items.length, (i) {
                          final item = _items[i];
                          final isActive = navigationShell.currentIndex == i;
                          return Expanded(
                            child: Center(
                              child: GestureDetector(
                                onTap: () => navigationShell.goBranch(i),
                                behavior: HitTestBehavior.opaque,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                  decoration: isActive
                                      ? BoxDecoration(
                                          color: AppColors.accentMint.withValues(alpha: 0.14),
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(
                                            color: AppColors.accentMint.withValues(alpha: 0.4),
                                            width: 1,
                                          ),
                                        )
                                      : null,
                                  child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isActive ? item.activeIcon : item.icon,
                                    size: 19,
                                    color: isActive
                                        ? AppColors.accentMint
                                        : AppColors.textMuted,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.label,
                                    style: AppTextStyles.labelSm.copyWith(
                                      fontSize: 10,
                                      height: 1.1,
                                      fontWeight: isActive
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                      color: isActive
                                          ? AppColors.accentMint
                                          : AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
        );
      },
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem(
      {required this.icon, required this.activeIcon, required this.label});
}
