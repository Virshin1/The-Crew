import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Reusable App Logo widget displaying The Crew glowing neon icon.
class AppLogo extends StatelessWidget {
  static const String logoUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuA9SZdPnDtLwDbORph9uIC95zFp7hf0ljk6O8RQAKmT7RC59np_eryAYyn1P_DWDU_QHEs3io8aipvOd-fv9akNWfqZ06j9wRtHBTVw0_2O5Bw5EgWi-Ae7HxZXSTftCmDxCSiYpI1oz3Ewoi7BUHzc8KXoiP53I9laojgKGsKpPzTWGnz3l-ID5v_AklxeYoReAE_Ka1E2990tc48rgZlob6RMLa1nUxW1mjfiM2qEBh5D_Dh7Axjajw';

  final double size;
  final double borderRadius;
  final bool hasBorder;
  final bool hasGlow;

  const AppLogo({
    super.key,
    this.size = 36,
    this.borderRadius = 8,
    this.hasBorder = false,
    this.hasGlow = false,
  });

  @override
  Widget build(BuildContext context) {
    final imageWidget = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: logoUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (context, url) => Image.asset(
          'assets/app_logo.jpg',
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
        errorWidget: (context, url, error) => Image.asset(
          'assets/app_logo.jpg',
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      ),
    );

    if (hasGlow || hasBorder) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          border: hasBorder
              ? Border.all(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.5),
                  width: 1.5,
                )
              : null,
          boxShadow: hasGlow
              ? [
                  BoxShadow(
                    color: const Color(0xFFEC4899).withValues(alpha: 0.35),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}
