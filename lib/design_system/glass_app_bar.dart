import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/theme/design_tokens.dart';
import 'glass_surface.dart';

/// Glassmorphic app bar with scroll-responsive opacity.
class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;

  const GlassAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GlassSurface(
      blur: DesignTokens.blurMedium,
      borderRadius: 0,
      child: SafeArea(
        child: SizedBox(
          height: kToolbarHeight,
          child: Row(
            children: [
              if (leading != null) ...[
                const SizedBox(width: 4),
                leading!,
              ] else if (Navigator.canPop(context)) ...[
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ] else
                const SizedBox(width: 16),
              if (centerTitle) const Spacer(),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Spacer(),
              if (actions != null) ...actions!,
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}

