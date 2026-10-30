import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/design_tokens.dart';
import '../../design_system/glass_app_bar.dart';
import '../../design_system/glass_card.dart';
import '../../design_system/glass_surface.dart';
import '../../providers/printer_provider.dart';
import '../../models/printer.dart';

class PrintHomeScreen extends ConsumerWidget {
  const PrintHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPrinter = ref.watch(selectedPrinterProvider);

    return Scaffold(
      appBar: GlassAppBar(
        title: 'Print',
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () => context.push(AppRoutes.queue),
          ),
        ],
      ),
      body: Column(
        children: [
          // Printer chip
          if (selectedPrinter != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: _PrinterSelector(printer: selectedPrinter),
            ),

          // Source grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.95,
              ),
              itemCount: _sources.length,
              itemBuilder: (ctx, i) {
                final s = _sources[i];
                return _SourceTile(
                  source: s,
                  onTap: () => _onSourceTap(context, s),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static const _sources = [
    _Source(Icons.picture_as_pdf_rounded, 'Documents', Color(0xFF0A84FF)),
    _Source(Icons.photo_library_rounded, 'Photos', Color(0xFFFF6B35)),
    _Source(Icons.folder_open_rounded, 'Files', Color(0xFFFF9F0A)),
    _Source(Icons.camera_alt_rounded, 'Camera', Color(0xFF30D158)),
    _Source(Icons.language_rounded, 'Web page', Color(0xFF5856D6),
        comingSoon: true),
    _Source(Icons.content_paste_rounded, 'Clipboard', Color(0xFF636366),
        comingSoon: true),
    _Source(Icons.cloud_rounded, 'Cloud', Color(0xFF32ADE6), comingSoon: true),
    _Source(Icons.grid_view_rounded, 'Templates', Color(0xFFFF2D55),
        comingSoon: true),
  ];

  Future<void> _onSourceTap(BuildContext context, _Source source) async {
    if (source.comingSoon) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${source.label} coming in a future update')),
      );
      return;
    }

    Map<String, dynamic>? data;

    if (source.label == 'Documents' || source.label == 'Files') {
      final result = await FilePicker.platform.pickFiles(
        type: source.label == 'Documents'
            ? FileType.custom
            : FileType.any,
        allowedExtensions:
            source.label == 'Documents' ? ['pdf', 'txt', 'doc', 'docx'] : null,
      );
      if (result != null && result.files.isNotEmpty) {
        data = {
          'filePath': result.files.first.path,
          'fileName': result.files.first.name,
          'fileSize': result.files.first.size,
          'type': 'document',
        };
      }
    } else if (source.label == 'Photos') {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        data = {
          'filePath': image.path,
          'fileName': image.name,
          'type': 'photo',
        };
      }
    } else if (source.label == 'Camera') {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        data = {
          'filePath': image.path,
          'fileName': image.name,
          'type': 'photo',
        };
      }
    }

    if (data != null && context.mounted) {
      context.push(AppRoutes.printPreview, extra: data);
    }
  }
}

class _Source {
  final IconData icon;
  final String label;
  final Color color;
  final bool comingSoon;
  const _Source(this.icon, this.label, this.color, {this.comingSoon = false});
}

class _SourceTile extends StatelessWidget {
  final _Source source;
  final VoidCallback onTap;
  const _SourceTile({required this.source, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: source.color.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(source.icon, color: source.color, size: 28),
                ),
                if (source.comingSoon)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('Soon',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              source.label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: source.comingSoon ? Colors.grey : null,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrinterSelector extends ConsumerWidget {
  final Printer printer;
  const _PrinterSelector({required this.printer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.printers),
      child: GlassSurface(
        blur: DesignTokens.blurMedium,
        borderRadius: DesignTokens.radiusChip,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.print_rounded, size: 16, color: DesignTokens.accent),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                printer.nickname,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.expand_more_rounded, size: 16),
          ],
        ),
      ),
    );
  }
}

