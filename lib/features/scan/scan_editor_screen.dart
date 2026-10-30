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
import '../../providers/printer_provider.dart';
import '../../providers/print_provider.dart';
import '../../models/scan_item.dart';
import '../../models/printer.dart';

class ScanEditorScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? scanData;
  const ScanEditorScreen({super.key, this.scanData});

  @override
  ConsumerState<ScanEditorScreen> createState() => _ScanEditorScreenState();
}

class _ScanEditorScreenState extends ConsumerState<ScanEditorScreen> {
  int _currentPage = 0;
  int _totalPages = 1;
  ScanFilter _filter = ScanFilter.original;
  bool _showFilterBar = false;
  double _rotation = 0.0;

  static const _filters = [
    (ScanFilter.original, 'Original'),
    (ScanFilter.document, 'Document'),
    (ScanFilter.grayscale, 'Grayscale'),
    (ScanFilter.blackAndWhite, 'B&W'),
    (ScanFilter.photo, 'Photo'),
    (ScanFilter.whiteboard, 'Whiteboard'),
  ];

  void _rotate() {
    setState(() => _rotation = (_rotation + 90) % 360);
  }

  void _save() {
    final data = {
      'filter': _filter.name,
      'rotation': _rotation,
      'pageCount': _totalPages,
      'name': widget.scanData?['name'] as String? ?? 'Scan ${DateTime.now().toLocal()}',
    };
    context.push(AppRoutes.saveShare, extra: data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  GlassIconButton(
                    icon: Icons.close_rounded,
                    onPressed: () => context.pop(),
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Page ${_currentPage + 1} of $_totalPages',
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  GlassIconButton(
                    icon: Icons.add_photo_alternate_outlined,
                    onPressed: () {
                      setState(() => _totalPages++);
                    },
                    color: Colors.white,
                    tooltip: 'Add page',
                  ),
                  const SizedBox(width: 8),
                  GlassIconButton(
                    icon: Icons.save_rounded,
                    onPressed: _save,
                    color: DesignTokens.accent,
                    tooltip: 'Save',
                  ),
                ],
              ),
            ),

            // Main page view
            Expanded(
              child: Center(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: AnimatedRotation(
                    turns: _rotation / 360,
                    duration: const Duration(milliseconds: 300),
                    child: _buildPagePreview(context),
                  ),
                ),
              ),
            ),

            // Filter bar (expandable)
            if (_showFilterBar)
              Container(
                height: 80,
                color: Colors.black54,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _filters.length,
                  itemBuilder: (ctx, i) {
                    final (filter, label) = _filters[i];
                    final selected = _filter == filter;
                    return GestureDetector(
                      onTap: () => setState(() {
                        _filter = filter;
                        _showFilterBar = false;
                      }),
                      child: Container(
                        width: 72,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selected ? DesignTokens.accent : Colors.white30,
                            width: selected ? 2 : 1,
                          ),
                          color: selected
                              ? DesignTokens.accent.withOpacity(0.2)
                              : Colors.white10,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.filter_rounded,
                                color: selected ? DesignTokens.accent : Colors.white70,
                                size: 20),
                            const SizedBox(height: 4),
                            Text(
                              label,
                              style: TextStyle(
                                  color: selected
                                      ? DesignTokens.accent
                                      : Colors.white70,
                                  fontSize: 10),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

            // Page thumbnail strip
            SizedBox(
              height: 68,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                itemCount: _totalPages,
                itemBuilder: (ctx, i) => GestureDetector(
                  onTap: () => setState(() => _currentPage = i),
                  child: Container(
                    width: 44,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: i == _currentPage
                            ? DesignTokens.accent
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Icon(Icons.description_rounded,
                          size: 20, color: Colors.black38),
                    ),
                  ),
                ),
              ),
            ),

            // Bottom toolbar
            GlassSurface(
              blur: DesignTokens.blurHigh,
              borderRadius: 0,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ToolBtn(Icons.crop_rounded, 'Crop', () {}),
                  _ToolBtn(Icons.rotate_90_degrees_ccw_rounded, 'Rotate', _rotate),
                  _ToolBtn(
                      Icons.filter_b_and_w_rounded,
                      'Filter',
                      () => setState(() => _showFilterBar = !_showFilterBar)),
                  _ToolBtn(Icons.tune_rounded, 'Adjust', () {}),
                  _ToolBtn(Icons.draw_rounded, 'Sign', () {}),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPagePreview(BuildContext context) {
    return Container(
      width: 240,
      height: 340,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _filterColor(_filter),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black54, blurRadius: 24, spreadRadius: 2),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description_outlined, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            'Page ${_currentPage + 1}',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            _filterLabel(_filter),
            style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Color _filterColor(ScanFilter f) {
    switch (f) {
      case ScanFilter.original:    return Colors.white;
      case ScanFilter.document:    return const Color(0xFFFAFAF0);
      case ScanFilter.grayscale:   return Colors.grey.shade100;
      case ScanFilter.blackAndWhite: return Colors.white;
      case ScanFilter.photo:       return Colors.white;
      case ScanFilter.whiteboard:  return Colors.white;
    }
  }

  String _filterLabel(ScanFilter f) {
    switch (f) {
      case ScanFilter.original:    return 'Original';
      case ScanFilter.document:    return 'Document filter';
      case ScanFilter.grayscale:   return 'Grayscale filter';
      case ScanFilter.blackAndWhite: return 'B&W filter';
      case ScanFilter.photo:       return 'Photo filter';
      case ScanFilter.whiteboard:  return 'Whiteboard filter';
    }
  }
}

class _ToolBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ToolBtn(this.icon, this.label, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }
}

