import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/design_tokens.dart';
import '../../design_system/glass_surface.dart';
import '../../design_system/glass_button.dart';
import '../../providers/print_provider.dart';
import '../../models/print_job.dart';

class PrintProgressScreen extends ConsumerWidget {
  const PrintProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final printState = ref.watch(printProvider);
    final job = printState.activeJob;

    if (job == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.print_rounded, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('No active print job'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.home),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Status card
              GlassSurface(
                blur: DesignTokens.blurHigh,
                borderRadius: DesignTokens.radiusCard,
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    _buildStatusIcon(context, job),
                    const SizedBox(height: 24),
                    Text(
                      job.name,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      job.printerName,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    _buildStatusContent(context, ref, job),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon(BuildContext context, PrintJob job) {
    if (job.status == JobStatus.completed) {
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 600),
        curve: Curves.elasticOut,
        builder: (_, v, __) => Transform.scale(
          scale: v,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: DesignTokens.success.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded,
                size: 54, color: DesignTokens.success),
          ),
        ),
      );
    }

    if (job.status == JobStatus.failed || job.status == JobStatus.canceled) {
      return Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: DesignTokens.error.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.error_outline_rounded,
            size: 54, color: DesignTokens.error),
      );
    }

    // Active printing
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: job.progressFraction,
            strokeWidth: 6,
            backgroundColor: DesignTokens.accent.withOpacity(0.15),
            valueColor:
                const AlwaysStoppedAnimation<Color>(DesignTokens.accent),
          ),
          Icon(Icons.print_rounded, size: 36, color: DesignTokens.accent),
        ],
      ),
    );
  }

  Widget _buildStatusContent(
      BuildContext context, WidgetRef ref, PrintJob job) {
    switch (job.status) {
      case JobStatus.completed:
        return Column(
          children: [
            Text(
              'Printed successfully!',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: DesignTokens.success),
            ),
            const SizedBox(height: 8),
            Text(
              '${job.totalPages} ${job.totalPages == 1 ? "page" : "pages"}',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 28),
            GlassPrimaryButton(
              label: 'Done',
              onPressed: () => context.go(AppRoutes.home),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.go(AppRoutes.print),
              child: const Text('Print another'),
            ),
          ],
        );

      case JobStatus.failed:
        return Column(
          children: [
            Text(
              job.errorMessage ?? 'The print job failed.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: DesignTokens.error),
            ),
            const SizedBox(height: 24),
            GlassPrimaryButton(
              label: 'Retry',
              icon: Icons.refresh_rounded,
              color: DesignTokens.error,
              onPressed: () => context.go(AppRoutes.print),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Cancel'),
            ),
          ],
        );

      case JobStatus.canceled:
        return Column(
          children: [
            const Text('Print job was canceled.'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Go Home'),
            ),
          ],
        );

      default:
        // Active states
        return Column(
          children: [
            Text(
              job.statusLabel,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: DesignTokens.accent),
            ),
            if (job.totalPages > 0) ...[
              const SizedBox(height: 6),
              Text(
                'Page ${job.completedPages} of ${job.totalPages}',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey),
              ),
            ],
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: job.progressFraction,
              backgroundColor: DesignTokens.accent.withOpacity(0.15),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(DesignTokens.accent),
              minHeight: 4,
              borderRadius: BorderRadius.circular(2),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: DesignTokens.error,
                side: BorderSide(color: DesignTokens.error.withOpacity(0.5)),
              ),
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('Cancel'),
              onPressed: () {
                ref.read(printProvider.notifier).cancelJob(job.id);
              },
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Run in background'),
            ),
          ],
        );
    }
  }
}

