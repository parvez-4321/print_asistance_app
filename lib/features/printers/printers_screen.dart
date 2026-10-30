import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../design_system/glass_surface.dart';
import '../../design_system/glass_button.dart';
import '../../design_system/glass_card.dart';
import '../../design_system/glass_chip.dart';
import '../../design_system/glass_app_bar.dart';
import '../../core/theme/design_tokens.dart';
import '../../providers/printer_provider.dart';
import '../../models/printer.dart';
import '../../core/router/app_router.dart';

class PrintersScreen extends ConsumerWidget {
  const PrintersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final printerState = ref.watch(printerProvider);
    final printers = printerState.printers;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(
        title: 'My Printers',
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add printer',
            onPressed: () => context.push(AppRoutes.addPrinter),
          ),
        ],
      ),
      body: GlassSurface(
        child: printers.isEmpty
            ? _EmptyState(onAddPrinter: () => context.push(AppRoutes.addPrinter))
            : _PrinterList(printers: printers),
      ),
      floatingActionButton: printers.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => context.push(AppRoutes.addPrinter),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Printer'),
              backgroundColor: DesignTokens.accent,
              foregroundColor: Colors.white,
            )
          : null,
    );
  }
}

// ---------------------------------------------------------------------------
// Printer list
// ---------------------------------------------------------------------------

class _PrinterList extends ConsumerWidget {
  const _PrinterList({required this.printers});

  final List<Printer> printers;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + kToolbarHeight + DesignTokens.s16,
        left: DesignTokens.s16,
        right: DesignTokens.s16,
        bottom: 100, // space for FAB
      ),
      itemCount: printers.length,
      separatorBuilder: (_, __) => const SizedBox(height: DesignTokens.s12),
      itemBuilder: (context, index) {
        final printer = printers[index];
        return _PrinterCard(printer: printer);
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Printer card
// ---------------------------------------------------------------------------

class _PrinterCard extends ConsumerWidget {
  const _PrinterCard({required this.printer});

  final Printer printer;

  Color _statusColor(PrinterStatus status) {
    switch (status) {
      case PrinterStatus.ready:
        return DesignTokens.success;
      case PrinterStatus.printing:
      case PrinterStatus.attention:
        return DesignTokens.warning;
      case PrinterStatus.offline:
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(PrinterStatus status) {
    switch (status) {
      case PrinterStatus.ready:
        return 'Ready';
      case PrinterStatus.printing:
        return 'Printing';
      case PrinterStatus.attention:
        return 'Attention';
      case PrinterStatus.offline:
      default:
        return 'Offline';
    }
  }

  Future<bool?> _confirmDelete(BuildContext context, String nickname) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark
            ? DesignTokens.darkGlassSurface
            : DesignTokens.lightGlassSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusCard),
        ),
        title: const Text('Remove Printer'),
        content: Text(
          'Remove "$nickname" from your list?\nThis cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: DesignTokens.error),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subColor = isDark
        ? DesignTokens.darkOnSurfaceVariant
        : DesignTokens.lightOnSurfaceVariant;
    final notifier = ref.read(printerProvider.notifier);
    final statusColor = _statusColor(printer.status);

    return Dismissible(
      key: ValueKey(printer.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(context, printer.nickname),
      onDismissed: (_) => notifier.removePrinter(printer.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: DesignTokens.s24),
        decoration: BoxDecoration(
          color: DesignTokens.error.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(DesignTokens.radiusCard),
        ),
        child: const Icon(Icons.delete_rounded, color: DesignTokens.error, size: 28),
      ),
      child: GlassCard(
        onTap: () {
          ref.read(printerProvider.notifier).selectPrinter(printer.id);
          context.push(
            AppRoutes.printerDetail,
            extra: {'id': printer.id},
          );
        },
        onLongPress: () async {
          await notifier.setDefault(printer.id);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('"${printer.nickname}" set as default printer.'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status dot + printer icon
            Stack(
              alignment: Alignment.topRight,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: DesignTokens.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
                  ),
                  child: const Icon(
                    Icons.print_rounded,
                    size: 30,
                    color: DesignTokens.accent,
                  ),
                ),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      width: 2,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: DesignTokens.s16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          printer.nickname,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (printer.isDefault) ...[
                        const SizedBox(width: DesignTokens.s8),
                        const _DefaultBadge(),
                      ],
                    ],
                  ),
                  const SizedBox(height: DesignTokens.s4),
                  Text(
                    '${printer.manufacturer} ${printer.model}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: subColor,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: DesignTokens.s8),
                  Row(
                    children: [
                      GlassChip(
                        label: printer.connectionType ==
                                PrinterConnectionType.bluetooth
                            ? 'Bluetooth'
                            : 'Wi-Fi',
                        icon: printer.connectionType ==
                                PrinterConnectionType.bluetooth
                            ? Icons.bluetooth_rounded
                            : Icons.wifi_rounded,
                      ),
                      const SizedBox(width: DesignTokens.s8),
                      GlassChip(
                        label: _statusLabel(printer.status),
                        selected: true,
                        selectedColor: statusColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: DesignTokens.s8),
            Icon(
              Icons.chevron_right_rounded,
              color: subColor,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Default badge
// ---------------------------------------------------------------------------

class _DefaultBadge extends StatelessWidget {
  const _DefaultBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: DesignTokens.accent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
        border: Border.all(
          color: DesignTokens.accent.withValues(alpha: 0.4),
        ),
      ),
      child: const Text(
        'Default',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: DesignTokens.accent,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAddPrinter});

  final VoidCallback onAddPrinter;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subColor = isDark
        ? DesignTokens.darkOnSurfaceVariant
        : DesignTokens.lightOnSurfaceVariant;

    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: DesignTokens.s32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: DesignTokens.accent.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.print_disabled_rounded,
                  size: 72,
                  color: DesignTokens.accent.withValues(alpha: 0.45),
                ),
              ),
              const SizedBox(height: DesignTokens.s24),
              Text(
                'No printers yet',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: DesignTokens.s8),
              Text(
                'Set up your first printer and start printing from anywhere.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: subColor,
                      height: 1.5,
                    ),
              ),
              const SizedBox(height: DesignTokens.s32),
              GlassPrimaryButton(
                onPressed: onAddPrinter,
                label: 'Add Printer',
                icon: Icons.add_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
