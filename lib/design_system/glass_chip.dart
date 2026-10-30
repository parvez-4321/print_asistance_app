import 'package:flutter/material.dart';
import '../core/theme/design_tokens.dart';
import 'glass_surface.dart';

// ─── Glass Chip ──────────────────────────────────────────────────────────────

class GlassChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color? selectedColor;

  const GlassChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.icon,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final accent = selectedColor ?? DesignTokens.accent;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: DesignTokens.durationFast,
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.s16,
          vertical: DesignTokens.s8,
        ),
        decoration: BoxDecoration(
          color: selected
              ? accent.withOpacity(0.2)
              : Theme.of(context).brightness == Brightness.dark
                  ? DesignTokens.darkGlassSurface
                  : DesignTokens.lightGlassSurface,
          borderRadius: BorderRadius.circular(DesignTokens.radiusChip),
          border: Border.all(
            color: selected ? accent : (Theme.of(context).brightness == Brightness.dark
                ? DesignTokens.darkGlassEdge
                : DesignTokens.lightGlassEdge),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: selected ? accent : null),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? accent : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

