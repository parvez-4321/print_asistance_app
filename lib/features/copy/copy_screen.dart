import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/design_tokens.dart';
import '../../design_system/glass_app_bar.dart';
import '../../design_system/glass_button.dart';
import '../../design_system/glass_card.dart';
import '../../design_system/glass_chip.dart';
import '../../design_system/glass_surface.dart';
import '../../design_system/glass_card.dart' show GlassSegmentedControl;
import '../../providers/printer_provider.dart';
import '../../providers/print_provider.dart';
import '../../models/scan_item.dart';
import '../../models/printer.dart';
import '../../models/print_job.dart';

class CopyScreen extends ConsumerStatefulWidget {
  const CopyScreen({super.key});

  @override
  ConsumerState<CopyScreen> createState() => _CopyScreenState();
}

class _CopyScreenState extends ConsumerState<CopyScreen> {
  int _copies = 1;
  ScanColorMode _colorMode = ScanColorMode.color;
  ScanSource _source = ScanSource.glass;
  String _paperSize = 'A4';
  String _scale = 'Fit to page';
  bool _copying = false;

  Future<void> _startCopy() async {
    final printer = ref.read(selectedPrinterProvider);
    if (printer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a printer first')),
      );
      return;
    }
    if (!printer.hasScanner) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('This printer has no scanner. Cannot copy.')),
      );
      return;
    }

    setState(() => _copying = true);
    // Simulate scan then print
    await ref.read(scanProvider.notifier).startScan();
    await ref.read(printProvider.notifier).startJob(
          printerId: printer.id,
          printerName: printer.nickname,
          name: 'Copy job',
          filePath: 'copy_scan.pdf',
          totalPages: _copies,
          type: JobType.copy,
        );

    setState(() => _copying = false);
    if (mounted) context.push(AppRoutes.printProgress);
  }

  @override
  Widget build(BuildContext context) {
    final printer = ref.watch(selectedPrinterProvider);
    final hasScanner = printer?.hasScanner ?? false;

    return Scaffold(
      appBar: GlassAppBar(title: 'Copy'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Printer chip
            if (printer != null)
              GestureDetector(
                onTap: () => context.push(AppRoutes.printers),
                child: GlassSurface(
                  blur: DesignTokens.blurMedium,
                  borderRadius: DesignTokens.radiusChip,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.print_rounded,
                          size: 16, color: DesignTokens.accent),
                      const SizedBox(width: 6),
                      Text(printer.nickname,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 4),
                      const Icon(Icons.expand_more_rounded, size: 16),
                    ],
                  ),
                ),
              ),

            // No scanner warning
            if (!hasScanner)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: DesignTokens.warning.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: DesignTokens.warning.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: DesignTokens.warning),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'This printer has no scanner. Copying is not available.',
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // Copies
            GlassCard(
              child: Row(
                children: [
                  const Icon(Icons.copy_all_rounded,
                      color: DesignTokens.accent),
                  const SizedBox(width: 12),
                  Text('Copies',
                      style: Theme.of(context).textTheme.titleMedium),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed:
                        _copies > 1 ? () => setState(() => _copies--) : null,
                  ),
                  Text('$_copies',
                      style: Theme.of(context).textTheme.titleLarge),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: _copies < 99
                        ? () => setState(() => _copies++)
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Source
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Scan from',
                      style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  GlassSegmentedControl<ScanSource>(
                    value: _source,
                    items: const [
                      (ScanSource.glass, 'Glass'),
                      (ScanSource.adf, 'ADF'),
                    ],
                    onChanged: (v) => setState(() => _source = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Color mode
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Color mode',
                      style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  GlassSegmentedControl<ScanColorMode>(
                    value: _colorMode,
                    items: const [
                      (ScanColorMode.color, 'Color'),
                      (ScanColorMode.grayscale, 'Grayscale'),
                      (ScanColorMode.blackAndWhite, 'B&W'),
                    ],
                    onChanged: (v) => setState(() => _colorMode = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Paper size
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Paper size',
                      style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['A4', 'A5', 'Letter', 'Legal']
                        .map((s) => GlassChip(
                              label: s,
                              selected: _paperSize == s,
                              onTap: () => setState(() => _paperSize = s),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Scale
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Scale', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children:
                        ['Actual size', 'Fit to page', 'Enlarge', 'Reduce']
                            .map((s) => GlassChip(
                                  label: s,
                                  selected: _scale == s,
                                  onTap: () => setState(() => _scale = s),
                                ))
                            .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Copy button
            GlassPrimaryButton(
              label: _copying ? 'Copying…' : 'Copy',
              icon: Icons.copy_all_rounded,
              loading: _copying,
              onPressed: (!_copying && hasScanner) ? _startCopy : null,
              color: const Color(0xFFFF9F0A),
            ),
          ],
        ),
      ),
    );
  }
}

