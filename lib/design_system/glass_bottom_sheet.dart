import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/theme/design_tokens.dart';
import 'glass_surface.dart';

// ─── Glass Bottom Sheet Helper ───────────────────────────────────────────────

Future<T?> showGlassBottomSheet<T>({
  required BuildContext context,
  required Widget Function(BuildContext, ScrollController) builder,
  bool isScrollControlled = true,
  double initialChildSize = 0.5,
  double minChildSize = 0.25,
  double maxChildSize = 0.95,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black38,
    useSafeArea: true,
    builder: (ctx) => _GlassBottomSheet(
      initialChildSize: initialChildSize,
      minChildSize: minChildSize,
      maxChildSize: maxChildSize,
      builder: builder,
    ),
  );
}

class _GlassBottomSheet extends StatelessWidget {
  final double initialChildSize;
  final double minChildSize;
  final double maxChildSize;
  final Widget Function(BuildContext, ScrollController) builder;

  const _GlassBottomSheet({
    required this.initialChildSize,
    required this.minChildSize,
    required this.maxChildSize,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: initialChildSize,
      minChildSize: minChildSize,
      maxChildSize: maxChildSize,
      snap: true,
      snapSizes: [minChildSize, initialChildSize, maxChildSize],
      builder: (ctx, scrollController) {
        return GlassSurface(
          blur: DesignTokens.blurHigh,
          borderRadius: DesignTokens.radiusSheet,
          child: Column(
            children: [
              // Drag handle
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white38,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              // Content
              Expanded(child: builder(ctx, scrollController)),
            ],
          ),
        );
      },
    );
  }
}

// ─── Glass Dialog ─────────────────────────────────────────────────────────────

Future<T?> showGlassDialog<T>({
  required BuildContext context,
  required String title,
  required String message,
  String confirmLabel = 'OK',
  String? cancelLabel,
  VoidCallback? onConfirm,
  bool isDestructive = false,
}) {
  return showDialog<T>(
    context: context,
    barrierColor: Colors.black38,
    builder: (ctx) => BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      child: AlertDialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: GlassSurface(
          blur: DesignTokens.blurHigh,
          padding: const EdgeInsets.all(DesignTokens.s24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(ctx).textTheme.headlineSmall,
              ),
              const SizedBox(height: DesignTokens.s12),
              Text(
                message,
                style: Theme.of(ctx).textTheme.bodyMedium,
              ),
              const SizedBox(height: DesignTokens.s24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (cancelLabel != null)
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(cancelLabel),
                    ),
                  const SizedBox(width: 8),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: isDestructive
                          ? DesignTokens.error
                          : DesignTokens.accent,
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      onConfirm?.call();
                    },
                    child: Text(confirmLabel),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

