import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/design_tokens.dart';
import '../../design_system/glass_app_bar.dart';
import '../../design_system/glass_button.dart';
import '../../design_system/glass_card.dart';
import '../../design_system/glass_surface.dart';
import '../../design_system/glass_bottom_sheet.dart';
import '../../design_system/glass_chip.dart';
import '../../design_system/glass_card.dart' show GlassSegmentedControl;
import '../../providers/printer_provider.dart';
import '../../providers/print_provider.dart';
import '../../models/print_settings.dart';
import '../../models/printer.dart';
import 'package:uuid/uuid.dart';
import '../../models/print_job.dart';

class PrintPreviewScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? fileData;
  const PrintPreviewScreen({super.key, this.fileData});

  @override
  ConsumerState<PrintPreviewScreen> createState() => _PrintPreviewScreenState();
}

class _PrintPreviewScreenState extends ConsumerState<PrintPreviewScreen> {
  PrintSettings _settings = const PrintSettings();
  int _currentPage = 1;
  final _totalPages = 1;

  @override
  void initState() {
    super.initState();
    final fileName = widget.fileData?['fileName'] as String? ?? 'Document';
    _settings = _settings.copyWith(jobName: fileName);
  }

  Future<void> _print() async {
    final printer = ref.read(selectedPrinterProvider);
    if (printer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a printer first')),
      );
      return;
    }

    // Navigate to progress first
    context.push(AppRoutes.printProgress);

    // Start the job
    await ref.read(printProvider.notifier).startJob(
          printerId: printer.id,
          printerName: printer.nickname,
          name: _settings.jobName,
          filePath: widget.fileData?['filePath'] as String? ?? '',
          totalPages: _totalPages,
        );
  }

  void _openSettings() {
    showGlassBottomSheet(
      context: context,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      builder: (ctx, scrollCtrl) => _PrintSettingsPanel(
        settings: _settings,
        printer: ref.read(selectedPrinterProvider),
        onChanged: (s) => setState(() => _settings = s),
        scrollController: scrollCtrl,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filePath = widget.fileData?['filePath'] as String?;
    final fileName = widget.fileData?['fileName'] as String? ?? 'Document';
    final fileType = widget.fileData?['type'] as String? ?? 'document';

    return Scaffold(
      appBar: GlassAppBar(
        title: fileName,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            onPressed: _openSettings,
          ),
        ],
      ),
      body: Column(
        children: [
          // Page counter
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Page $_currentPage of $_totalPages',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ),

          // Preview
          Expanded(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: _buildPreview(context, filePath, fileType),
                ),
              ),
            ),
          ),

          // Thumbnail strip
          SizedBox(
            height: 72,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _totalPages,
              itemBuilder: (ctx, i) => _PageThumb(
                pageNum: i + 1,
                selected: i + 1 == _currentPage,
                onTap: () => setState(() => _currentPage = i + 1),
              ),
            ),
          ),

          // Bottom bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            child: Row(
              children: [
                // Settings handle
                GlassIconButton(
                  icon: Icons.tune_rounded,
                  onPressed: _openSettings,
                  tooltip: 'Print settings',
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GlassPrimaryButton(
                    label: 'Print',
                    icon: Icons.print_rounded,
                    onPressed: _print,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview(BuildContext context, String? filePath, String fileType) {
    if (filePath != null && fileType == 'photo') {
      final file = File(filePath);
      if (file.existsSync()) {
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(file, fit: BoxFit.contain),
          ),
        );
      }
    }

    // Default document placeholder
    return Container(
      width: 260,
      height: 360,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            fileType == 'photo'
                ? Icons.image_rounded
                : Icons.description_rounded,
            size: 64,
            color: DesignTokens.accent.withOpacity(0.6),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              widget.fileData?['fileName'] as String? ?? 'Document',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 14, color: Colors.black54),
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ready to print',
            style: TextStyle(
                fontSize: 12, color: DesignTokens.success),
          ),
        ],
      ),
    );
  }
}

class _PageThumb extends StatelessWidget {
  final int pageNum;
  final bool selected;
  final VoidCallback onTap;
  const _PageThumb(
      {required this.pageNum, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 64,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? DesignTokens.accent.withOpacity(0.15) : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: selected ? DesignTokens.accent : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Center(
          child: Text('$pageNum',
              style: TextStyle(
                  fontSize: 12,
                  color: selected ? DesignTokens.accent : Colors.black54,
                  fontWeight:
                      selected ? FontWeight.w700 : FontWeight.w400)),
        ),
      ),
    );
  }
}

// ─── Settings Panel ──────────────────────────────────────────────────────────

class _PrintSettingsPanel extends StatefulWidget {
  final PrintSettings settings;
  final Printer? printer;
  final ValueChanged<PrintSettings> onChanged;
  final ScrollController scrollController;

  const _PrintSettingsPanel({
    required this.settings,
    required this.printer,
    required this.onChanged,
    required this.scrollController,
  });

  @override
  State<_PrintSettingsPanel> createState() => _PrintSettingsPanelState();
}

class _PrintSettingsPanelState extends State<_PrintSettingsPanel> {
  late PrintSettings _s;

  @override
  void initState() {
    super.initState();
    _s = widget.settings;
  }

  void _update(PrintSettings s) {
    setState(() => _s = s);
    widget.onChanged(s);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: widget.scrollController,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text('Print Settings',
              style: Theme.of(context).textTheme.headlineSmall),
        ),

        _SectionHeader('Basic'),
        _SettingRow(
          label: 'Copies',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: _s.copies > 1
                    ? () => _update(_s.copyWith(copies: _s.copies - 1))
                    : null,
              ),
              SizedBox(
                width: 36,
                child: Text(
                  '${_s.copies}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: _s.copies < 99
                    ? () => _update(_s.copyWith(copies: _s.copies + 1))
                    : null,
              ),
            ],
          ),
        ),
        _SettingRow(
          label: 'Pages',
          child: GlassSegmentedControl<String>(
            value: _s.pageRange,
            items: const [
              ('all', 'All'),
              ('current', 'Current'),
              ('custom', 'Custom'),
            ],
            onChanged: (v) => _update(_s.copyWith(pageRange: v)),
          ),
        ),

        _SectionHeader('Color & Quality'),
        _SettingRow(
          label: 'Color',
          child: GlassSegmentedControl<ColorMode>(
            value: _s.colorMode,
            items: const [
              (ColorMode.color, 'Color'),
              (ColorMode.grayscale, 'Gray'),
              (ColorMode.blackAndWhite, 'B&W'),
            ],
            onChanged: (v) => _update(_s.copyWith(colorMode: v)),
          ),
        ),
        _SettingRow(
          label: 'Quality',
          child: GlassSegmentedControl<PrintQuality>(
            value: _s.quality,
            items: const [
              (PrintQuality.draft, 'Draft'),
              (PrintQuality.normal, 'Normal'),
              (PrintQuality.high, 'High'),
              (PrintQuality.photo, 'Photo'),
            ],
            onChanged: (v) => _update(_s.copyWith(quality: v)),
          ),
        ),

        _SectionHeader('Paper'),
        _PaperSizeRow(
          selected: _s.paperSize,
          onChanged: (v) => _update(_s.copyWith(paperSize: v)),
        ),
        _SettingRow(
          label: 'Type',
          child: Wrap(
            spacing: 6,
            children: ['Plain', 'Photo', 'Cardstock', 'Labels']
                .map((t) => GlassChip(
                      label: t,
                      selected: _s.paperType == t,
                      onTap: () => _update(_s.copyWith(paperType: t)),
                    ))
                .toList(),
          ),
        ),

        _SectionHeader('Layout & Scale'),
        _SettingRow(
          label: 'Scale',
          child: GlassSegmentedControl<PageScale>(
            value: _s.scale,
            items: const [
              (PageScale.fitToPage, 'Fit'),
              (PageScale.fillPage, 'Fill'),
              (PageScale.actual, '100%'),
            ],
            onChanged: (v) => _update(_s.copyWith(scale: v)),
          ),
        ),

        _SectionHeader('Two-Sided'),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Print on both sides'),
          subtitle: Text(_s.duplexMode != DuplexMode.oneSided
              ? _s.duplexModeLabel
              : 'One-sided'),
          value: _s.duplexMode != DuplexMode.oneSided,
          onChanged: (v) => _update(
            _s.copyWith(
              duplexMode: v ? DuplexMode.longEdge : DuplexMode.oneSided,
            ),
          ),
        ),
        if (_s.duplexMode != DuplexMode.oneSided)
          _SettingRow(
            label: 'Binding',
            child: GlassSegmentedControl<DuplexMode>(
              value: _s.duplexMode,
              items: const [
                (DuplexMode.longEdge, 'Long edge'),
                (DuplexMode.shortEdge, 'Short edge'),
              ],
              onChanged: (v) => _update(_s.copyWith(duplexMode: v)),
            ),
          ),

        _SectionHeader('Job'),
        _SettingRow(
          label: 'Job name',
          child: SizedBox(
            width: 180,
            child: TextField(
              controller: TextEditingController(text: _s.jobName),
              onChanged: (v) => _update(_s.copyWith(jobName: v)),
              decoration: const InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                isDense: true,
              ),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Notify when done'),
          value: _s.notifications,
          onChanged: (v) => _update(_s.copyWith(notifications: v)),
        ),

        const SizedBox(height: 24),
        OutlinedButton(
          onPressed: () => setState(() => _s = const PrintSettings()),
          child: const Text('Restore Defaults'),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.grey,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final String label;
  final Widget child;
  const _SettingRow({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}

class _PaperSizeRow extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  const _PaperSizeRow({required this.selected, required this.onChanged});

  static const _sizes = ['A4', 'A5', 'Letter', 'Legal', '4x6', '5x7', '8x10'];

  @override
  Widget build(BuildContext context) {
    return _SettingRow(
      label: 'Paper size',
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _sizes
              .map((s) => Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: GlassChip(
                      label: s,
                      selected: selected == s,
                      onTap: () => onChanged(s),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

