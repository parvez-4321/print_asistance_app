import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/design_tokens.dart';
import '../../design_system/glass_app_bar.dart';
import '../../design_system/glass_card.dart';
import '../../design_system/glass_button.dart';
import '../../design_system/glass_surface.dart';
import '../../design_system/glass_bottom_sheet.dart';
import '../../providers/printer_provider.dart';
import '../../models/printer.dart';

class PrinterDetailsScreen extends ConsumerWidget {
  final String printerId;
  const PrinterDetailsScreen({super.key, required this.printerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(printerProvider);
    final printer = state.printers.where((p) => p.id == printerId).firstOrNull;

    if (printer == null) {
      return const Scaffold(
        body: Center(child: Text('Printer not found')),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = _statusColor(printer.status);

    return Scaffold(
      appBar: GlassAppBar(
        title: printer.nickname,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _showRenameDialog(context, ref, printer),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
        children: [
          // Offline banner
          if (printer.status == PrinterStatus.offline)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.wifi_off_rounded, color: Colors.orange),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text('Printer is offline. Check that it is on and connected.'),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Reconnect'),
                  ),
                ],
              ),
            ),

          // Hero card
          GlassCard(
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: DesignTokens.accent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.print_rounded,
                          size: 36, color: DesignTokens.accent),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(printer.nickname,
                              style: Theme.of(context).textTheme.titleLarge),
                          Text(
                            '${printer.manufacturer} · ${printer.model}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: Colors.grey),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.only(right: 6),
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Text(printer.statusLabel,
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: statusColor,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (printer.isDefault)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: DesignTokens.accent.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('Default',
                            style: TextStyle(
                                fontSize: 12,
                                color: DesignTokens.accent,
                                fontWeight: FontWeight.w600)),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Quick actions
          Text('Quick Actions', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _QuickAction(
                    icon: Icons.article_outlined,
                    label: 'Test Page',
                    onTap: () {}),
                const SizedBox(width: 10),
                _QuickAction(
                    icon: Icons.cleaning_services_outlined,
                    label: 'Clean Head',
                    onTap: () {}),
                const SizedBox(width: 10),
                _QuickAction(
                    icon: Icons.tune_rounded,
                    label: 'Align',
                    onTap: () {}),
                const SizedBox(width: 10),
                _QuickAction(
                    icon: Icons.public_rounded,
                    label: 'Web Page',
                    onTap: () {}),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Ink levels
          Text('Supplies', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          GlassCard(
            child: Column(
              children: [
                _InkBar(label: 'Black', color: Colors.black87, percent: 0.72),
                const SizedBox(height: 12),
                _InkBar(label: 'Cyan', color: Colors.cyan, percent: 0.45),
                const SizedBox(height: 12),
                _InkBar(label: 'Magenta', color: Colors.pink, percent: 0.61),
                const SizedBox(height: 12),
                _InkBar(label: 'Yellow', color: Colors.amber, percent: 0.88),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Capabilities
          Text('Capabilities', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          GlassCard(
            child: Column(
              children: [
                _CapRow('Color printing', printer.hasColorPrinting),
                _CapRow('Two-sided printing', printer.hasDuplex),
                _CapRow('Scanner', printer.hasScanner),
                _CapRow('Auto document feeder', printer.hasAdf),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Paper sizes
          Text('Supported Paper Sizes',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: printer.supportedPaperSizes
                .map((s) => Chip(label: Text(s)))
                .toList(),
          ),
          const SizedBox(height: 20),

          // Network info
          if (printer.ipAddress != null || printer.macAddress != null) ...[
            Text('Network', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            GlassCard(
              child: Column(
                children: [
                  if (printer.ipAddress != null)
                    _InfoRow('IP Address', printer.ipAddress!),
                  if (printer.macAddress != null)
                    _InfoRow('MAC Address', printer.macAddress!),
                  if (printer.firmwareVersion != null)
                    _InfoRow('Firmware', printer.firmwareVersion!),
                  if (printer.serialNumber != null)
                    _InfoRow('Serial', printer.serialNumber!),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Forget printer
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: DesignTokens.error,
                side: BorderSide(color: DesignTokens.error.withOpacity(0.5)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.delete_outline_rounded),
              label: const Text('Forget This Printer'),
              onPressed: () => showGlassDialog(
                context: context,
                title: 'Forget Printer?',
                message:
                    'This will remove "${printer.nickname}" from your list. You can add it again at any time.',
                confirmLabel: 'Forget',
                cancelLabel: 'Cancel',
                isDestructive: true,
                onConfirm: () async {
                  await ref.read(printerProvider.notifier).removePrinter(printer.id);
                  if (context.mounted) context.pop();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(PrinterStatus s) {
    switch (s) {
      case PrinterStatus.ready:     return DesignTokens.success;
      case PrinterStatus.printing:  return DesignTokens.accent;
      case PrinterStatus.scanning:  return DesignTokens.accent;
      case PrinterStatus.sleeping:  return Colors.orange;
      case PrinterStatus.busy:      return Colors.orange;
      case PrinterStatus.attention: return DesignTokens.warning;
      case PrinterStatus.offline:   return Colors.grey;
    }
  }

  void _showRenameDialog(
      BuildContext context, WidgetRef ref, Printer printer) {
    final ctrl = TextEditingController(text: printer.nickname);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Printer'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Printer name'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              ref.read(printerProvider.notifier).updatePrinter(
                    printer.copyWith(nickname: ctrl.text.trim()),
                  );
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickAction(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: DesignTokens.accent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: DesignTokens.accent.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: DesignTokens.accent),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(
                    fontSize: 13,
                    color: DesignTokens.accent,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _InkBar extends StatelessWidget {
  final String label;
  final Color color;
  final double percent;
  const _InkBar(
      {required this.label, required this.color, required this.percent});

  @override
  Widget build(BuildContext context) {
    final pct = (percent * 100).round();
    return Row(
      children: [
        SizedBox(
          width: 64,
          child: Text(label,
              style: Theme.of(context).textTheme.bodySmall),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: color.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 10,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text('$pct%',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _CapRow extends StatelessWidget {
  final String label;
  final bool value;
  const _CapRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: Theme.of(context).textTheme.bodyMedium),
          ),
          Icon(
            value ? Icons.check_circle_rounded : Icons.cancel_outlined,
            color: value ? DesignTokens.success : Colors.grey,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey)),
          ),
          Expanded(
            child: Text(value,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

