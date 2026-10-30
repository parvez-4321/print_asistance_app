import 'package:equatable/equatable.dart';

enum JobStatus {
  preparing,
  sending,
  waitingAtPrinter,
  printing,
  completed,
  failed,
  canceled,
}

enum JobType { print, scan, copy }

class PrintJob extends Equatable {
  final String id;
  final String printerId;
  final String printerName;
  final String name;
  final JobType type;
  final JobStatus status;
  final int totalPages;
  final int completedPages;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? errorMessage;
  final String? filePath;
  final double? progressFraction;

  const PrintJob({
    required this.id,
    required this.printerId,
    required this.printerName,
    required this.name,
    required this.type,
    this.status = JobStatus.preparing,
    this.totalPages = 0,
    this.completedPages = 0,
    required this.createdAt,
    this.completedAt,
    this.errorMessage,
    this.filePath,
    this.progressFraction,
  });

  PrintJob copyWith({
    String? id,
    String? printerId,
    String? printerName,
    String? name,
    JobType? type,
    JobStatus? status,
    int? totalPages,
    int? completedPages,
    DateTime? createdAt,
    DateTime? completedAt,
    String? errorMessage,
    String? filePath,
    double? progressFraction,
  }) {
    return PrintJob(
      id: id ?? this.id,
      printerId: printerId ?? this.printerId,
      printerName: printerName ?? this.printerName,
      name: name ?? this.name,
      type: type ?? this.type,
      status: status ?? this.status,
      totalPages: totalPages ?? this.totalPages,
      completedPages: completedPages ?? this.completedPages,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      errorMessage: errorMessage ?? this.errorMessage,
      filePath: filePath ?? this.filePath,
      progressFraction: progressFraction ?? this.progressFraction,
    );
  }

  String get statusLabel {
    switch (status) {
      case JobStatus.preparing:       return 'Preparing…';
      case JobStatus.sending:         return 'Sending…';
      case JobStatus.waitingAtPrinter:return 'Waiting at printer';
      case JobStatus.printing:        return 'Printing…';
      case JobStatus.completed:       return 'Completed';
      case JobStatus.failed:          return 'Failed';
      case JobStatus.canceled:        return 'Canceled';
    }
  }

  bool get isActive => [
    JobStatus.preparing,
    JobStatus.sending,
    JobStatus.waitingAtPrinter,
    JobStatus.printing,
  ].contains(status);

  @override
  List<Object?> get props => [id, status, completedPages];
}

