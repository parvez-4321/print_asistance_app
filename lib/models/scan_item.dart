import 'package:equatable/equatable.dart';

enum ScanColorMode { color, grayscale, blackAndWhite }
enum ScanSource { glass, adf, phone }
enum ScanSides { oneSided, twoSidedLongEdge, twoSidedShortEdge }
enum ScanFormat { pdf, jpeg, png }
enum ScanFilter { original, document, grayscale, blackAndWhite, photo, whiteboard }

class ScanItem extends Equatable {
  final String id;
  final String name;
  final String filePath;
  final ScanFormat format;
  final int pageCount;
  final DateTime createdAt;
  final List<String> tags;
  final String? folderId;
  final bool isFavorite;
  final String? thumbnailPath;
  final String? ocrText;

  const ScanItem({
    required this.id,
    required this.name,
    required this.filePath,
    required this.format,
    required this.pageCount,
    required this.createdAt,
    this.tags = const [],
    this.folderId,
    this.isFavorite = false,
    this.thumbnailPath,
    this.ocrText,
  });

  ScanItem copyWith({
    String? id,
    String? name,
    String? filePath,
    ScanFormat? format,
    int? pageCount,
    DateTime? createdAt,
    List<String>? tags,
    String? folderId,
    bool? isFavorite,
    String? thumbnailPath,
    String? ocrText,
  }) {
    return ScanItem(
      id: id ?? this.id,
      name: name ?? this.name,
      filePath: filePath ?? this.filePath,
      format: format ?? this.format,
      pageCount: pageCount ?? this.pageCount,
      createdAt: createdAt ?? this.createdAt,
      tags: tags ?? this.tags,
      folderId: folderId ?? this.folderId,
      isFavorite: isFavorite ?? this.isFavorite,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      ocrText: ocrText ?? this.ocrText,
    );
  }

  @override
  List<Object?> get props => [id, name, filePath, format];
}

class ScanSettings extends Equatable {
  final ScanSource source;
  final ScanSides sides;
  final ScanColorMode colorMode;
  final int resolution;
  final String scanArea;    // "auto", "full", "custom", preset name
  final String orientation; // "auto", "portrait", "landscape"
  final bool autoCropDeskew;
  final bool multiPage;
  final ScanFilter filter;

  const ScanSettings({
    this.source = ScanSource.glass,
    this.sides = ScanSides.oneSided,
    this.colorMode = ScanColorMode.color,
    this.resolution = 300,
    this.scanArea = 'auto',
    this.orientation = 'auto',
    this.autoCropDeskew = true,
    this.multiPage = false,
    this.filter = ScanFilter.original,
  });

  ScanSettings copyWith({
    ScanSource? source,
    ScanSides? sides,
    ScanColorMode? colorMode,
    int? resolution,
    String? scanArea,
    String? orientation,
    bool? autoCropDeskew,
    bool? multiPage,
    ScanFilter? filter,
  }) {
    return ScanSettings(
      source: source ?? this.source,
      sides: sides ?? this.sides,
      colorMode: colorMode ?? this.colorMode,
      resolution: resolution ?? this.resolution,
      scanArea: scanArea ?? this.scanArea,
      orientation: orientation ?? this.orientation,
      autoCropDeskew: autoCropDeskew ?? this.autoCropDeskew,
      multiPage: multiPage ?? this.multiPage,
      filter: filter ?? this.filter,
    );
  }

  @override
  List<Object?> get props => [source, sides, colorMode, resolution, scanArea];
}

