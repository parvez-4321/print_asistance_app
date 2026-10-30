import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/design_tokens.dart';
import '../../design_system/glass_app_bar.dart';
import '../../design_system/glass_card.dart';
import '../../design_system/glass_surface.dart';
import '../../design_system/glass_card.dart' show GlassSegmentedControl;
import '../../providers/print_provider.dart';
import '../../models/print_job.dart';

class QueueScreen extends ConsumerStatefulWidget {
  const QueueScreen({super.key});

  @override
  ConsumerState<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends ConsumerState<QueueScreen> {
  bool _showQueue = true;

  @override
  Widget build(BuildContext context) {
    final printState = ref.watch(printProvider);
    final queue = printState.queue;
    final history = printState.history;

    return Scaffold(
      appBar: GlassAppBar(
        title: 'Queue & History',
        actions: [
          if (!_showQueue && history.isNotEmpty)
            TextButton(
              onPressed: () => ref.read(printProvider.notifier).clearHistory(),
              child: const Text('Clear', style: TextStyle(color: DesignTokens.error)),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: GlassSegmentedControl<bool>(
              value: _showQueue,
              items: const [(true, 'Queue'), (false, 'History')],
              onChanged: (v) => setState(() => _showQueue = v),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {},
              child: _showQueue
                  ? _buildQueueList(context, queue)
                  : _buildHistoryList(context, history),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueueList(BuildContext context, List<PrintJob> jobs) {
    if (jobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.print_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text('No active jobs',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.grey,
                    )),
            const SizedBox(height: 8),
            const Text('Print something to see it here',
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.push(AppRoutes.print),
              icon: const Icon(Icons.print_rounded),
              label: const Text('Print Now'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: jobs.length,
      itemBuilder: (ctx, i) => _JobCard(
        job: jobs[i],
        isActive: true,
        onCancel: () =>
            ref.read(printProvider.notifier).cancelJob(jobs[i].id),
      ),
    );
  }

  Widget _buildHistoryList(BuildContext context, List<PrintJob> jobs) {
    if (jobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_rounded, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text('No history yet',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.grey,
                    )),
            const SizedBox(height: 8),
            const Text('Completed jobs will appear here',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: jobs.length,
      itemBuilder: (ctx, i) => _JobCard(
        job: jobs[i],
        isActive: false,
        onReprint: () => context.push(AppRoutes.print),
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final PrintJob job;
  final bool isActive;
  final VoidCallback? onCancel;
  final VoidCallback? onReprint;

  const _JobCard({
    required this.job,
    required this.isActive,
    this.onCancel,
    this.onReprint,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(job.status);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _jobTypeColor(job.type).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_jobTypeIcon(job.type),
                      size: 20, color: _jobTypeColor(job.type)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.name,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        job.printerName,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    job.statusLabel,
                    style: TextStyle(
                        fontSize: 11,
                        color: statusColor,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),

            if (isActive && (job.progressFraction ?? 0) > 0) ...[
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: job.progressFraction,
                backgroundColor: DesignTokens.accent.withOpacity(0.1),
                valueColor: const AlwaysStoppedAnimation<Color>(
                    DesignTokens.accent),
                minHeight: 4,
                borderRadius: BorderRadius.circular(2),
              ),
              const SizedBox(height: 4),
              Text(
                'Page ${job.completedPages} of ${job.totalPages}',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey),
              ),
            ],

            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  DateFormat('MMM d · h:mm a').format(job.createdAt),
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey),
                ),
                if (job.totalPages > 0)
                  Text(
                    ' · ${job.totalPages} page${job.totalPages == 1 ? "" : "s"}',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey),
                  ),
                const Spacer(),
                if (isActive && onCancel != null)
                  TextButton(
                    style: TextButton.styleFrom(
                        foregroundColor: DesignTokens.error,
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                    onPressed: onCancel,
                    child: const Text('Cancel'),
                  ),
                if (!isActive && job.status == JobStatus.failed)
                  TextButton(
                    style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                    onPressed: onReprint,
                    child: const Text('Retry'),
                  ),
                if (!isActive && job.status == JobStatus.completed)
                  TextButton(
                    style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                    onPressed: onReprint,
                    child: const Text('Re-print'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(JobStatus s) {
    switch (s) {
      case JobStatus.completed:        return DesignTokens.success;
      case JobStatus.failed:           return DesignTokens.error;
      case JobStatus.canceled:         return Colors.grey;
      case JobStatus.printing:         return DesignTokens.accent;
      case JobStatus.waitingAtPrinter: return Colors.orange;
      case JobStatus.sending:          return DesignTokens.accent;
      case JobStatus.preparing:        return Colors.grey;
    }
  }

  IconData _jobTypeIcon(JobType t) {
    switch (t) {
      case JobType.print:  return Icons.print_rounded;
      case JobType.scan:   return Icons.document_scanner_rounded;
      case JobType.copy:   return Icons.copy_all_rounded;
    }
  }

  Color _jobTypeColor(JobType t) {
    switch (t) {
      case JobType.print:  return DesignTokens.accent;
      case JobType.scan:   return DesignTokens.success;
      case JobType.copy:   return DesignTokens.warning;
    }
  }
}

