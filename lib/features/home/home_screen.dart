import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/design_tokens.dart';
import '../../design_system/glass_card.dart';
import '../../design_system/glass_surface.dart';
import '../../providers/printer_provider.dart';
import '../../providers/print_provider.dart';
import '../../models/printer.dart';
import '../../models/print_job.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final printerState = ref.watch(printerProvider);
    final printState = ref.watch(printProvider);
    final selectedPrinter = ref.watch(selectedPrinterProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? DesignTokens.darkBackground : DesignTokens.lightBackground,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildHeader(context, selectedPrinter, isDark),
          ),
          if (selectedPrinter == null)
            SliverToBoxAdapter(child: _buildNoPrinterCard(context))
          else ...[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.15,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                delegate: SliverChildListDelegate(_buildActionCards(context)),
              ),
            ),
          ],
          SliverToBoxAdapter(
            child: _buildRecentSection(context, printState.history),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 100), // tab bar space
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Printer? printer, bool isDark) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greeting,
              style: Theme.of(context)
                  .textTheme
                  .displaySmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            if (printer != null) ...[
              const SizedBox(height: 16),
              _PrinterChip(printer: printer),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNoPrinterCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GlassCard(
        onTap: () => context.push(AppRoutes.addPrinter),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: DesignTokens.accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.print_rounded,
                  size: 52, color: DesignTokens.accent),
            ),
            const SizedBox(height: 16),
            Text('Set Up Your Printer',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Add a printer to start printing, scanning and copying.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => context.push(AppRoutes.addPrinter),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Printer'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActionCards(BuildContext context) {
    final actions = [
      _Action(Icons.description_rounded, 'Print\nDocument',
          const Color(0xFF0A84FF), AppRoutes.print),
      _Action(Icons.photo_library_rounded, 'Print\nPhoto',
          const Color(0xFFFF6B35), AppRoutes.print),
      _Action(Icons.document_scanner_rounded, 'Scan',
          const Color(0xFF30D158), AppRoutes.scan),
      _Action(Icons.copy_all_rounded, 'Copy',
          const Color(0xFFFF9F0A), AppRoutes.copy),
    ];
    return actions.map((a) => _ActionCard(action: a)).toList();
  }

  Widget _buildRecentSection(BuildContext context, List<PrintJob> history) {
    if (history.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent',
                  style: Theme.of(context).textTheme.headlineSmall),
              TextButton(
                onPressed: () => context.push(AppRoutes.queue),
                child: const Text('See all'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: history.take(6).length,
              itemBuilder: (ctx, i) {
                final job = history[i];
                return _RecentJobChip(job: job);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Action {
  final IconData icon;
  final String label;
  final Color color;
  final String route;
  const _Action(this.icon, this.label, this.color, this.route);
}

class _ActionCard extends StatelessWidget {
  final _Action action;
  const _ActionCard({required this.action});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: () => context.go(action.route),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: action.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(action.icon, color: action.color, size: 28),
          ),
          const Spacer(),
          Text(
            action.label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _PrinterChip extends ConsumerWidget {
  final Printer printer;
  const _PrinterChip({required this.printer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusColor = _statusColor(printer.status);
    return GestureDetector(
      onTap: () => context.push(AppRoutes.printers),
      child: GlassSurface(
        blur: DesignTokens.blurMedium,
        borderRadius: DesignTokens.radiusChip,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                  color: statusColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.print_rounded, size: 18),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                printer.nickname,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              printer.statusLabel,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: statusColor),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.expand_more_rounded, size: 16),
          ],
        ),
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
}

class _RecentJobChip extends StatelessWidget {
  final PrintJob job;
  const _RecentJobChip({required this.job});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 10),
      child: GlassCard(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Icon(
              job.type == JobType.scan
                  ? Icons.document_scanner_rounded
                  : Icons.print_rounded,
              size: 20,
              color: DesignTokens.accent,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    job.name,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    job.printerName,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

