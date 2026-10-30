import 'package:flutter/material.dart';
import '../core/theme/design_tokens.dart';
import 'glass_surface.dart';

// ─── Glass Card ──────────────────────────────────────────────────────────────

class GlassCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? tint;

  const GlassCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.padding,
    this.borderRadius = DesignTokens.radiusCard,
    this.tint,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: GlassSurface(
        borderRadius: borderRadius,
        tint: tint,
        padding: padding ?? const EdgeInsets.all(DesignTokens.s16),
        child: child,
      ),
    );
  }
}

// ─── Glass Segmented Control ─────────────────────────────────────────────────

class GlassSegmentedControl<T> extends StatelessWidget {
  final T value;
  final List<(T, String)> items;
  final ValueChanged<T> onChanged;

  const GlassSegmentedControl({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GlassSurface(
      blur: DesignTokens.blurLow,
      padding: const EdgeInsets.all(3),
      borderRadius: DesignTokens.radiusChip,
      child: Row(
        children: items.map((item) {
          final selected = item.$1 == value;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(item.$1),
              child: AnimatedContainer(
                duration: DesignTokens.durationFast,
                height: 36,
                decoration: BoxDecoration(
                  color: selected
                      ? DesignTokens.accent.withOpacity(0.9)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusChip),
                ),
                child: Center(
                  child: Text(
                    item.$2,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      color: selected
                          ? Colors.white
                          : (isDark ? Colors.white70 : Colors.black54),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

