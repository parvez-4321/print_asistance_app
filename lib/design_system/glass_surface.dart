import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/theme/design_tokens.dart';

// ─── Glass Surface ─────────────────────────────────────────────────────────

/// A container that applies a frosted/glass effect using BackdropFilter.
/// Falls back to a tinted surface when [reduceEffects] is true.
class GlassSurface extends StatelessWidget {
  final Widget child;
  final double blur;
  final Color? tint;
  final Color? border;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool reduceEffects;
  final double? width;
  final double? height;

  const GlassSurface({
    super.key,
    required this.child,
    this.blur = DesignTokens.blurMedium,
    this.tint,
    this.border,
    this.borderRadius = DesignTokens.radiusCard,
    this.padding,
    this.reduceEffects = false,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveTint = tint ??
        (isDark ? DesignTokens.darkGlassSurface : DesignTokens.lightGlassSurface);
    final effectiveBorder = border ??
        (isDark ? DesignTokens.darkGlassEdge : DesignTokens.lightGlassEdge);

    final decoration = BoxDecoration(
      color: reduceEffects ? effectiveTint.withOpacity(0.9) : effectiveTint,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: effectiveBorder, width: 1),
    );

    if (reduceEffects) {
      return Container(
        width: width,
        height: height,
        decoration: decoration,
        padding: padding,
        child: child,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          decoration: decoration,
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

