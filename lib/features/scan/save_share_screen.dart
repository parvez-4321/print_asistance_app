import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/design_tokens.dart';
import '../../design_system/glass_app_bar.dart';
import '../../design_system/glass_button.dart';
import '../../design_system/glass_card.dart';
import '../../design_system/glass_chip.dart';
import '../../providers/print_provider.dart';
import '../../models/scan_item.dart';

class SaveShareScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? scanData;
  const SaveShareScreen({super.key, this.scanData});

  @override
  ConsumerState<SaveShareScreen> createState() => _SaveShareScreenState();
}

class _SaveShareScreenState extends ConsumerState<SaveShareScreen> {
  late TextEditingController _nameCtrl;
  ScanFormat _format = ScanFormat.pdf;
  double _jpegQuality = 0.85;
  String _destination = 'Library';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final defaultName = widget.scanData?['name'] as String? ??
        'Scan_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    _nameCtrl = TextEditingController(text: defaultName);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final item = ScanItem(
      id: const Uuid().v4(),
      name: _nameCtrl.text.trim(),
      filePath: 'simulated_path/${_nameCtrl.text}.${_format.name}',
      format: _format,
      pageCount: widget.scanData?['pageCount'] as int? ?? 1,
      createdAt: DateTime.now(),
    );

    if (_destination == 'Library') {
      await ref.read(scanProvider.notifier).saveScanToLibrary(item);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Saved to library'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        context.go(AppRoutes.library);
      }
    } else if (_destination == 'Share') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Share sheet would open here')),
      );
      setState(() => _saving = false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved to device')),
      );
      if (mounted) context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlassAppBar(title: 'Save & Share'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('File Name',
                      style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.description_outlined),
                      hintText: 'Scan name',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Format
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Format', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      GlassChip(
                        label: 'PDF',
                        icon: Icons.picture_as_pdf_rounded,
                        selected: _format == ScanFormat.pdf,
                        onTap: () => setState(() => _format = ScanFormat.pdf),
                      ),
                      const SizedBox(width: 8),
                      GlassChip(
                        label: 'JPEG',
                        icon: Icons.image_rounded,
                        selected: _format == ScanFormat.jpeg,
                        onTap: () => setState(() => _format = ScanFormat.jpeg),
                      ),
                      const SizedBox(width: 8),
                      GlassChip(
                        label: 'PNG',
                        icon: Icons.image_outlined,
                        selected: _format == ScanFormat.png,
                        onTap: () => setState(() => _format = ScanFormat.png),
                      ),
                    ],
                  ),
                  if (_format == ScanFormat.jpeg) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Quality: ${(_jpegQuality * 100).round()}%',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Slider(
                      value: _jpegQuality,
                      min: 0.3,
                      max: 1.0,
                      divisions: 14,
                      onChanged: (v) => setState(() => _jpegQuality = v),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Destinations
            Text('Save to', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 2.4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [
                _DestCard(
                  icon: Icons.folder_special_rounded,
                  label: 'Library',
                  selected: _destination == 'Library',
                  onTap: () => setState(() => _destination = 'Library'),
                ),
                _DestCard(
                  icon: Icons.smartphone_rounded,
                  label: 'Device Files',
                  selected: _destination == 'Files',
                  onTap: () => setState(() => _destination = 'Files'),
                ),
                _DestCard(
                  icon: Icons.share_rounded,
                  label: 'Share',
                  selected: _destination == 'Share',
                  onTap: () => setState(() => _destination = 'Share'),
                ),
                _DestCard(
                  icon: Icons.cloud_upload_rounded,
                  label: 'Cloud',
                  selected: false,
                  comingSoon: true,
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 28),

            GlassPrimaryButton(
              label: 'Save',
              icon: Icons.save_rounded,
              loading: _saving,
              onPressed: _saving ? null : _save,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                shape: const StadiumBorder(),
              ),
              icon: const Icon(Icons.print_rounded),
              label: const Text('Print This Scan'),
              onPressed: () => context.push(AppRoutes.print),
            ),
          ],
        ),
      ),
    );
  }
}

class _DestCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final bool comingSoon;
  final VoidCallback onTap;

  const _DestCard({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.comingSoon = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: selected
              ? DesignTokens.accent.withOpacity(0.12)
              : (Theme.of(context).brightness == Brightness.dark
                  ? DesignTokens.darkGlassSurface
                  : DesignTokens.lightGlassSurface),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? DesignTokens.accent : Colors.grey.withOpacity(0.25),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: selected
                    ? DesignTokens.accent
                    : (comingSoon ? Colors.grey : null),
                size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.w400,
                    color: selected
                        ? DesignTokens.accent
                        : (comingSoon ? Colors.grey : null)),
              ),
            ),
            if (comingSoon)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('Soon',
                    style: TextStyle(fontSize: 9, color: Colors.grey)),
              ),
            if (selected)
              const Icon(Icons.check_circle_rounded,
                  color: DesignTokens.accent, size: 18),
          ],
        ),
      ),
    );
  }
}

