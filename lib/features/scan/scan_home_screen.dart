import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../design_system/glass_surface.dart';
import '../../design_system/glass_button.dart';
import '../../design_system/glass_card.dart';
import '../../design_system/glass_chip.dart';
import '../../design_system/glass_app_bar.dart';
import '../../design_system/glass_card.dart' show GlassSegmentedControl;
import '../../core/theme/design_tokens.dart';
import '../../providers/printer_provider.dart';
import '../../providers/print_provider.dart';
import '../../models/scan_item.dart';
import '../../models/printer.dart';
import '../../core/router/app_router.dart';

class ScanHomeScreen extends ConsumerStatefulWidget {
  const ScanHomeScreen({super.key});

  @override
  ConsumerState<ScanHomeScreen> createState() => _ScanHomeScreenState();
}

class _ScanHomeScreenState extends ConsumerState<ScanHomeScreen> {
  bool _printerScan = true;
  String _itemType = 'Document';
  ScanColorMode _colorMode = ScanColorMode.color;
  int _resolution = 300;
  String _scanArea = 'auto';
  ScanFormat _format = ScanFormat.pdf;
  bool _autoCropDeskew = true;
  bool _multiPage = false;
  bool _settingsExpanded = false;

  static const _itemTypes = ['Document', 'Photo', 'ID Card', 'Receipt'];
  static const _resolutions = [150, 300, 600];
  static const _scanAreas = ['auto', 'full', 'custom'];

  ScanSettings get _currentSettings => ScanSettings(
        source: _printerScan ? ScanSource.glass : ScanSource.phone,
        colorMode: _colorMode,
        resolution: _resolution,
        scanArea: _scanArea,
        autoCropDeskew: _autoCropDeskew,
        multiPage: _multiPage,
      );

  String get _settingsSummary =>
      '$_resolution dpi · ${_currentSettings.scanArea} · ${_format.name.toUpperCase()} · ${_colorMode.name}';

  Future<void> _startScan() async {
    final printer = ref.read(selectedPrinterProvider);
    if (_printerScan && printer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a printer first')),
      );
      return;
    }
    if (_printerScan && !(printer?.hasScanner ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('This printer has no scanner. Switch to Phone scan.')),
      );
      return;
    }

    ref.read(scanProvider.notifier).updateSettings(_currentSettings);
    await ref.read(scanProvider.notifier).startScan();

    if (mounted) {
      context.push(AppRoutes.scanEditor, extra: {
        'name': '$_itemType scan',
        'format': _format.name,
        'pageCount': _multiPage ? 3 : 1,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final printer = ref.watch(selectedPrinterProvider);
    final scanState = ref.watch(scanProvider);
    final hasScanner = printer?.hasScanner ?? false;

    return Scaffold(
      appBar: GlassAppBar(
        title: 'Scan',
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_special_rounded),
            onPressed: () => context.push(AppRoutes.library),
          ),
        ],
      ),
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
            const SizedBox(height: 16),

            // Printer/Phone scan toggle
            GlassSegmentedControl<bool>(
              value: _printerScan,
              items: const [(true, 'Printer scan'), (false, 'Phone scan')],
              onChanged: (v) => setState(() => _printerScan = v),
            ),

            // No scanner banner
            if (_printerScan && !hasScanner && printer != null)
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: DesignTokens.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: DesignTokens.warning.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: DesignTokens.warning, size: 20),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'This printer has no scanner. Switching to Phone scan.',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _printerScan = false),
                      child: const Text('Switch'),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // Item type chips
            Text('I am scanning',
                style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _itemTypes
                    .map((t) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GlassChip(
                            label: t,
                            selected: _itemType == t,
                            onTap: () => setState(() => _itemType = t),
                          ),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Settings summary
            GestureDetector(
              onTap: () =>
                  setState(() => _settingsExpanded = !_settingsExpanded),
              child: GlassSurface(
                blur: DesignTokens.blurLow,
                borderRadius: 14,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    const Icon(Icons.tune_rounded,
                        size: 16, color: DesignTokens.accent),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_settingsSummary,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(fontWeight: FontWeight.w500)),
                    ),
                    AnimatedRotation(
                      turns: _settingsExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(Icons.expand_more_rounded, size: 18),
                    ),
                  ],
                ),
              ),
            ),

            // Expanded settings
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: _buildSettingsPanel(),
              crossFadeState: _settingsExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
            ),
            const SizedBox(height: 24),

            // Progress while scanning
            if (scanState.isScanning)
              GlassCard(
                child: Column(
                  children: [
                    LinearProgressIndicator(
                      value: scanState.progress,
                      backgroundColor: DesignTokens.accent.withOpacity(0.15),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          DesignTokens.accent),
                      minHeight: 4,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Scanning… ${(scanState.progress * 100).round()}%',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),

            // Scan button
            GlassPrimaryButton(
              label: scanState.isScanning ? 'Scanning…' : 'Scan',
              icon: Icons.document_scanner_rounded,
              loading: scanState.isScanning,
              onPressed: scanState.isScanning ? null : _startScan,
              color: DesignTokens.success,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsPanel() {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Color mode
          Text('Color', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 6),
          GlassSegmentedControl<ScanColorMode>(
            value: _colorMode,
            items: const [
              (ScanColorMode.color, 'Color'),
              (ScanColorMode.grayscale, 'Gray'),
              (ScanColorMode.blackAndWhite, 'B&W'),
            ],
            onChanged: (v) => setState(() => _colorMode = v),
          ),
          const SizedBox(height: 14),

          // Resolution
          Text('Resolution (dpi)',
              style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 6),
          Row(
            children: _resolutions
                .map((r) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GlassChip(
                        label: '$r dpi',
                        selected: _resolution == r,
                        onTap: () => setState(() => _resolution = r),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 14),

          // Scan area
          Text('Scan area', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 6),
          Row(
            children: [
              GlassChip(
                  label: 'Auto-detect',
                  selected: _scanArea == 'auto',
                  onTap: () => setState(() => _scanArea = 'auto')),
              const SizedBox(width: 8),
              GlassChip(
                  label: 'Full glass',
                  selected: _scanArea == 'full',
                  onTap: () => setState(() => _scanArea = 'full')),
            ],
          ),
          const SizedBox(height: 14),

          // Format
          Text('Output format',
              style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 6),
          Row(
            children: [
              GlassChip(
                  label: 'PDF',
                  selected: _format == ScanFormat.pdf,
                  onTap: () => setState(() => _format = ScanFormat.pdf)),
              const SizedBox(width: 8),
              GlassChip(
                  label: 'JPEG',
                  selected: _format == ScanFormat.jpeg,
                  onTap: () => setState(() => _format = ScanFormat.jpeg)),
              const SizedBox(width: 8),
              GlassChip(
                  label: 'PNG',
                  selected: _format == ScanFormat.png,
                  onTap: () => setState(() => _format = ScanFormat.png)),
            ],
          ),
          const SizedBox(height: 14),

          // Toggles
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Auto-crop & deskew'),
            value: _autoCropDeskew,
            onChanged: (v) => setState(() => _autoCropDeskew = v),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Multi-page scan'),
            subtitle: const Text('Scan multiple sheets into one file'),
            value: _multiPage,
            onChanged: (v) => setState(() => _multiPage = v),
          ),
        ],
      ),
    );
  }
}
