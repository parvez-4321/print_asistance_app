import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/print_job.dart';
import '../models/scan_item.dart';

// ─── Print Provider ───────────────────────────────────────────────────────────

class PrintState {
  final List<PrintJob> jobs;
  final PrintJob? activeJob;

  const PrintState({this.jobs = const [], this.activeJob});

  PrintState copyWith({List<PrintJob>? jobs, PrintJob? activeJob}) {
    return PrintState(jobs: jobs ?? this.jobs, activeJob: activeJob ?? this.activeJob);
  }

  List<PrintJob> get queue =>
      jobs.where((j) => j.isActive).toList();

  List<PrintJob> get history =>
      jobs.where((j) => !j.isActive).toList();
}

class PrintNotifier extends StateNotifier<PrintState> {
  final _uuid = const Uuid();

  PrintNotifier() : super(const PrintState());

  Future<PrintJob> startJob({
    required String printerId,
    required String printerName,
    required String name,
    required String filePath,
    required int totalPages,
    JobType type = JobType.print,
  }) async {
    final job = PrintJob(
      id: _uuid.v4(),
      printerId: printerId,
      printerName: printerName,
      name: name,
      type: type,
      status: JobStatus.preparing,
      totalPages: totalPages,
      createdAt: DateTime.now(),
      filePath: filePath,
      progressFraction: 0,
    );
    state = state.copyWith(
      jobs: [job, ...state.jobs],
      activeJob: job,
    );

    // Simulate sending
    await _simulatePrint(job.id);
    return job;
  }

  Future<void> _simulatePrint(String jobId) async {
    await _updateJob(jobId, status: JobStatus.sending, progress: 0.1);
    await Future.delayed(const Duration(milliseconds: 800));
    await _updateJob(jobId, status: JobStatus.waitingAtPrinter, progress: 0.3);
    await Future.delayed(const Duration(milliseconds: 600));
    await _updateJob(jobId, status: JobStatus.printing, progress: 0.5);
    await Future.delayed(const Duration(milliseconds: 1200));
    await _updateJob(jobId, status: JobStatus.printing, progress: 0.8);
    await Future.delayed(const Duration(milliseconds: 800));
    await _updateJob(
      jobId,
      status: JobStatus.completed,
      progress: 1.0,
      completedAt: DateTime.now(),
    );
  }

  Future<void> _updateJob(
    String jobId, {
    JobStatus? status,
    double? progress,
    DateTime? completedAt,
    String? errorMessage,
  }) async {
    final updated = state.jobs.map((j) {
      if (j.id != jobId) return j;
      return j.copyWith(
        status: status,
        progressFraction: progress,
        completedAt: completedAt,
        errorMessage: errorMessage,
        completedPages: progress != null
            ? (j.totalPages * progress).round()
            : null,
      );
    }).toList();
    state = state.copyWith(jobs: updated);
  }

  void cancelJob(String jobId) {
    _updateJob(jobId, status: JobStatus.canceled);
  }

  void clearHistory() {
    final activeOnly = state.jobs.where((j) => j.isActive).toList();
    state = state.copyWith(jobs: activeOnly);
  }
}

final printProvider = StateNotifierProvider<PrintNotifier, PrintState>(
  (ref) => PrintNotifier(),
);

// ─── Scan Provider ─────────────────────────────────────────────────────────────

class ScanState {
  final List<ScanItem> library;
  final ScanSettings settings;
  final bool isScanning;
  final double progress;
  final String? currentScanPath;

  const ScanState({
    this.library = const [],
    this.settings = const ScanSettings(),
    this.isScanning = false,
    this.progress = 0,
    this.currentScanPath,
  });

  ScanState copyWith({
    List<ScanItem>? library,
    ScanSettings? settings,
    bool? isScanning,
    double? progress,
    String? currentScanPath,
  }) {
    return ScanState(
      library: library ?? this.library,
      settings: settings ?? this.settings,
      isScanning: isScanning ?? this.isScanning,
      progress: progress ?? this.progress,
      currentScanPath: currentScanPath ?? this.currentScanPath,
    );
  }
}

class ScanNotifier extends StateNotifier<ScanState> {
  final _uuid = const Uuid();

  ScanNotifier() : super(const ScanState());

  void updateSettings(ScanSettings settings) {
    state = state.copyWith(settings: settings);
  }

  Future<String?> startScan() async {
    state = state.copyWith(isScanning: true, progress: 0);
    // Simulate scan progress
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 300));
      state = state.copyWith(progress: i / 10.0);
    }
    state = state.copyWith(isScanning: false, progress: 1.0);
    return 'simulated_scan_path.pdf';
  }

  Future<void> saveScanToLibrary(ScanItem item) async {
    state = state.copyWith(library: [item, ...state.library]);
  }

  void removeFromLibrary(String id) {
    state = state.copyWith(
      library: state.library.where((i) => i.id != id).toList(),
    );
  }

  void toggleFavorite(String id) {
    final updated = state.library.map((i) {
      if (i.id != id) return i;
      return i.copyWith(isFavorite: !i.isFavorite);
    }).toList();
    state = state.copyWith(library: updated);
  }
}

final scanProvider = StateNotifierProvider<ScanNotifier, ScanState>(
  (ref) => ScanNotifier(),
);

