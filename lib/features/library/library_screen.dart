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
import '../../providers/print_provider.dart';
import '../../models/scan_item.dart';
import 'package:intl/intl.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  bool _isGrid = true;
  bool _searchOpen = false;
  String _query = '';
  String _folder = 'All';
  final Set<String> _selected = {};
  bool _multiSelect = false;

  static const _folders = ['All', 'Favorites', 'Recent'];

  List<ScanItem> _filtered(List<ScanItem> all) {
    var list = all;
    if (_folder == 'Favorites') list = list.where((i) => i.isFavorite).toList();
    if (_query.isNotEmpty) {
      list = list
          .where((i) => i.name.toLowerCase().contains(_query.toLowerCase()))
          .toList();
    }
    return list;
  }

  void _toggleSelect(String id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
        if (_selected.isEmpty) _multiSelect = false;
      } else {
        _selected.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context, ) {
    final scanState = ref.watch(scanProvider);
    final items = _filtered(scanState.library);
    final notifier = ref.read(scanProvider.notifier);

    return Scaffold(
      appBar: GlassAppBar(
        title: _multiSelect ? '${_selected.length} selected' : 'Library',
        actions: [
          if (_multiSelect) ...[
            IconButton(
              icon: const Icon(Icons.share_rounded),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: () {
                for (final id in _selected) {
                  notifier.removeFromLibrary(id);
                }
                setState(() {
                  _selected.clear();
                  _multiSelect = false;
                });
              },
            ),
          ] else ...[
            IconButton(
              icon: Icon(_searchOpen ? Icons.close_rounded : Icons.search_rounded),
              onPressed: () => setState(() {
                _searchOpen = !_searchOpen;
                if (!_searchOpen) _query = '';
              }),
            ),
            IconButton(
              icon: Icon(
                  _isGrid ? Icons.view_list_rounded : Icons.grid_view_rounded),
              onPressed: () => setState(() => _isGrid = !_isGrid),
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          // Search bar
          if (_searchOpen)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                autofocus: true,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: 'Search scans…',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () => setState(() => _query = ''),
                        )
                      : null,
                ),
              ),
            ),

          // Folder chips
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _folders.length,
              itemBuilder: (ctx, i) => Padding(
                padding: const EdgeInsets.only(right: 8, top: 8),
                child: GlassChip(
                  label: _folders[i],
                  selected: _folder == _folders[i],
                  onTap: () => setState(() => _folder = _folders[i]),
                ),
              ),
            ),
          ),

          // Content
          Expanded(
            child: items.isEmpty
                ? _buildEmpty(context)
                : RefreshIndicator(
                    onRefresh: () async {},
                    child: _isGrid
                        ? _buildGrid(context, items, notifier)
                        : _buildList(context, items, notifier),
                  ),
          ),
        ],
      ),
      floatingActionButton: _multiSelect
          ? null
          : FloatingActionButton.extended(
              onPressed: () => context.push(AppRoutes.scan),
              icon: const Icon(Icons.document_scanner_rounded),
              label: const Text('Scan'),
              backgroundColor: DesignTokens.accent,
              foregroundColor: Colors.white,
            ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.document_scanner_outlined,
              size: 72, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text('No scans yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.grey,
                  )),
          const SizedBox(height: 8),
          const Text('Scan something to get started',
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          GlassPrimaryButton(
            label: 'Scan Now',
            icon: Icons.document_scanner_rounded,
            width: 180,
            onPressed: () => context.push(AppRoutes.scan),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(
      BuildContext context, List<ScanItem> items, ScanNotifier notifier) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.75,
      ),
      itemCount: items.length,
      itemBuilder: (ctx, i) {
        final item = items[i];
        final isSelected = _selected.contains(item.id);
        return GestureDetector(
          onLongPress: () =>
              setState(() {
                _multiSelect = true;
                _toggleSelect(item.id);
              }),
          onTap: () {
            if (_multiSelect) {
              _toggleSelect(item.id);
            } else {
              _showItemDetail(context, item);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: isSelected
                  ? DesignTokens.accent.withOpacity(0.15)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: isSelected ? DesignTokens.accent : Colors.grey.shade200,
                  width: isSelected ? 2 : 1),
              boxShadow: [
                BoxShadow(
                    color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(11)),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        const Center(
                          child: Icon(Icons.description_rounded,
                              size: 40, color: Colors.black26),
                        ),
                        if (isSelected)
                          const Center(
                            child: Icon(Icons.check_circle_rounded,
                                color: DesignTokens.accent, size: 36),
                          ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => notifier.toggleFavorite(item.id),
                            child: Icon(
                              item.isFavorite
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              color: item.isFavorite
                                  ? Colors.amber
                                  : Colors.black26,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        DateFormat('MMM d').format(item.createdAt),
                        style: const TextStyle(
                            fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildList(
      BuildContext context, List<ScanItem> items, ScanNotifier notifier) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: items.length,
      itemBuilder: (ctx, i) {
        final item = items[i];
        return Dismissible(
          key: Key(item.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            color: DesignTokens.error,
            child: const Icon(Icons.delete_rounded, color: Colors.white),
          ),
          onDismissed: (_) => notifier.removeFromLibrary(item.id),
          child: GlassCard(
            onTap: () => _showItemDetail(context, item),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.description_rounded, color: Colors.black38),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name,
                          style: Theme.of(context).textTheme.titleSmall,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(
                        '${item.format.name.toUpperCase()} · ${item.pageCount} page${item.pageCount > 1 ? "s" : ""} · ${DateFormat('MMM d, y').format(item.createdAt)}',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    item.isFavorite
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: item.isFavorite ? Colors.amber : Colors.grey,
                  ),
                  onPressed: () => notifier.toggleFavorite(item.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showItemDetail(BuildContext context, ScanItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => GlassSurface(
        blur: DesignTokens.blurHigh,
        borderRadius: DesignTokens.radiusSheet,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white38,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(item.name, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              '${item.format.name.toUpperCase()} · ${item.pageCount} pages · ${DateFormat('MMMM d, y').format(item.createdAt)}',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.print_rounded),
                    label: const Text('Print'),
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.push(AppRoutes.print);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.share_rounded),
                    label: const Text('Share'),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                    foregroundColor: DesignTokens.error),
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text('Delete'),
                onPressed: () {
                  ref.read(scanProvider.notifier).removeFromLibrary(item.id);
                  Navigator.pop(ctx);
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

