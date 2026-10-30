import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/theme/design_tokens.dart';
import 'glass_surface.dart';

// ─── Data class ──────────────────────────────────────────────────────────────

class GlassTabItem {
  final IconData icon;
  final String label;
  const GlassTabItem({required this.icon, required this.label});
}

// ─── Glass Tab Bar ───────────────────────────────────────────────────────────

/// Floating capsule tab bar with a sliding glass highlight.
class GlassTabBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<GlassTabItem> items;

  const GlassTabBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  State<GlassTabBar> createState() => _GlassTabBarState();
}

class _GlassTabBarState extends State<GlassTabBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnim;
  late int _previousIndex;

  @override
  void initState() {
    super.initState();
    _previousIndex = widget.currentIndex;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void didUpdateWidget(GlassTabBar old) {
    super.didUpdateWidget(old);
    if (old.currentIndex != widget.currentIndex) {
      _previousIndex = old.currentIndex;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final count = widget.items.length;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: SizedBox(
          height: 64,
          child: GlassSurface(
            blur: DesignTokens.blurHigh,
            borderRadius: 32,
            child: AnimatedBuilder(
              animation: _slideAnim,
              builder: (context, _) {
                return LayoutBuilder(builder: (context, constraints) {
                  final itemWidth = constraints.maxWidth / count;
                  final fromX = _previousIndex * itemWidth;
                  final toX = widget.currentIndex * itemWidth;
                  final dx = fromX + (toX - fromX) * _slideAnim.value;

                  return Stack(
                    children: [
                      // Sliding glass highlight
                      Positioned(
                        left: dx + 4,
                        top: 4,
                        width: itemWidth - 8,
                        height: 56,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: DesignTokens.accent.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: DesignTokens.accent.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                        ),
                      ),

                      // Tab items
                      Row(
                        children: List.generate(count, (i) {
                          final selected = i == widget.currentIndex;
                          final item = widget.items[i];
                          return Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => widget.onTap(i),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    item.icon,
                                    size: 24,
                                    color: selected
                                        ? DesignTokens.accent
                                        : (isDark
                                            ? Colors.white54
                                            : Colors.black45),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.label,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: selected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                      color: selected
                                          ? DesignTokens.accent
                                          : (isDark
                                              ? Colors.white54
                                              : Colors.black45),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  );
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}

