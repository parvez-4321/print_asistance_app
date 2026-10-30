import 'package:equatable/equatable.dart';

// ─── Enums ───────────────────────────────────────────────────────────────────

enum ColorMode { color, grayscale, blackAndWhite }
enum PrintQuality { draft, normal, high, photo }
enum DuplexMode { oneSided, longEdge, shortEdge }
enum PageScale { fitToPage, fitToPaper, fillPage, actual, custom }
enum PrintArea { printable, maximum, borderless, customMargins }
enum PageOrder { normal, reversed }

// ─── Print Settings Model ────────────────────────────────────────────────────

class PrintSettings extends Equatable {
  final int copies;
  final bool collate;
  final String pageRange;       // "all", "1-3,5", "odd", "even"
  final String orientation;     // "auto", "portrait", "landscape"
  final ColorMode colorMode;
  final PrintQuality quality;
  final String paperSize;
  final String paperType;
  final String paperSource;
  final PageScale scale;
  final double customScalePct;
  final PrintArea printArea;
  final DuplexMode duplexMode;
  final String jobName;
  final bool notifications;
  final Map<String, double>? customMargins;   // top, bottom, left, right in mm

  const PrintSettings({
    this.copies = 1,
    this.collate = true,
    this.pageRange = 'all',
    this.orientation = 'auto',
    this.colorMode = ColorMode.color,
    this.quality = PrintQuality.normal,
    this.paperSize = 'A4',
    this.paperType = 'Plain',
    this.paperSource = 'Auto',
    this.scale = PageScale.fitToPage,
    this.customScalePct = 100,
    this.printArea = PrintArea.printable,
    this.duplexMode = DuplexMode.oneSided,
    this.jobName = 'Print Job',
    this.notifications = true,
    this.customMargins,
  });

  PrintSettings copyWith({
    int? copies,
    bool? collate,
    String? pageRange,
    String? orientation,
    ColorMode? colorMode,
    PrintQuality? quality,
    String? paperSize,
    String? paperType,
    String? paperSource,
    PageScale? scale,
    double? customScalePct,
    PrintArea? printArea,
    DuplexMode? duplexMode,
    String? jobName,
    bool? notifications,
    Map<String, double>? customMargins,
  }) {
    return PrintSettings(
      copies: copies ?? this.copies,
      collate: collate ?? this.collate,
      pageRange: pageRange ?? this.pageRange,
      orientation: orientation ?? this.orientation,
      colorMode: colorMode ?? this.colorMode,
      quality: quality ?? this.quality,
      paperSize: paperSize ?? this.paperSize,
      paperType: paperType ?? this.paperType,
      paperSource: paperSource ?? this.paperSource,
      scale: scale ?? this.scale,
      customScalePct: customScalePct ?? this.customScalePct,
      printArea: printArea ?? this.printArea,
      duplexMode: duplexMode ?? this.duplexMode,
      jobName: jobName ?? this.jobName,
      notifications: notifications ?? this.notifications,
      customMargins: customMargins ?? this.customMargins,
    );
  }

  @override
  List<Object?> get props => [
    copies, collate, pageRange, orientation, colorMode, quality,
    paperSize, paperType, paperSource, scale, duplexMode,
  ];

  String get colorModeLabel {
    switch (colorMode) {
      case ColorMode.color:       return 'Color';
      case ColorMode.grayscale:   return 'Grayscale';
      case ColorMode.blackAndWhite: return 'Black & White';
    }
  }

  String get duplexModeLabel {
    switch (duplexMode) {
      case DuplexMode.oneSided:  return 'One-sided';
      case DuplexMode.longEdge:  return 'Both sides – Long edge';
      case DuplexMode.shortEdge: return 'Both sides – Short edge';
    }
  }
}

