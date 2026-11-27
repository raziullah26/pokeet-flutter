import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PokeetBackground extends StatelessWidget {
  final Widget child;
  const PokeetBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? PokeetColors.darkBg : PokeetColors.lightBg,
        gradient: isDark
            ? const RadialGradient(
                center: Alignment(-0.85, -0.85),
                radius: 1.2,
                colors: [Color(0xFF164A39), PokeetColors.darkBg],
              )
            : null,
      ),
      child: child,
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? borderColor;
  final Color? glowColor;
  final Gradient? tintGradient;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    this.radius = 28,
    this.borderColor,
    this.glowColor,
    this.tintGradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark
        ? PokeetColors.darkCard.withValues(alpha: 0.82)
        : PokeetColors.lightCard.withValues(alpha: 0.72);
    final rim = borderColor ??
        (isDark
            ? Colors.white.withValues(alpha: 0.20)
            : Colors.white.withValues(alpha: 0.85));

    final card = Container(
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: rim, width: 1.2),
        gradient: tintGradient ??
            LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      Colors.white.withValues(alpha: 0.12),
                      Colors.white.withValues(alpha: 0.03),
                      Colors.white.withValues(alpha: 0.07),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.72),
                      Colors.white.withValues(alpha: 0.28),
                      Colors.white.withValues(alpha: 0.52),
                    ],
            ),
        boxShadow: [
          BoxShadow(
            color: (glowColor ?? (isDark ? Colors.black : const Color(0xFF28325F)))
                .withValues(alpha: glowColor != null ? 0.24 : (isDark ? 0.26 : 0.14)),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );

    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: card,
      ),
    );
  }
}

class NeuIconBubble extends StatelessWidget {
  final Widget child;
  final Color tint;
  final double size;

  const NeuIconBubble({
    super.key,
    required this.child,
    required this.tint,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark
            ? Color.lerp(const Color(0xFF141416), tint, 0.22)
            : Color.lerp(Colors.white, tint, 0.30),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.10)
              : Colors.white.withValues(alpha: 0.90),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.40)
                : const Color(0xFF788296).withValues(alpha: 0.28),
            blurRadius: 8,
            offset: const Offset(2, 3),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}
