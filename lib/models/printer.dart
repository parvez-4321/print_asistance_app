import 'package:equatable/equatable.dart';

// ─── Enums ───────────────────────────────────────────────────────────────────

enum PrinterConnectionType { bluetooth, wifi, usb }
enum PrinterStatus { ready, printing, scanning, busy, sleeping, offline, attention }
enum PrinterTier { a, b, c, d }

// ─── Printer Model ───────────────────────────────────────────────────────────

class Printer extends Equatable {
  final String id;
  final String nickname;
  final String model;
  final String manufacturer;
  final PrinterConnectionType connectionType;
  final PrinterStatus status;
  final PrinterTier tier;
  final String? ipAddress;
  final String? macAddress;
  final String? bluetoothAddress;
  final int? ippPort;
  final String? location;
  final String? colorLabel;    // e.g. "Home", "Office"
  final bool isDefault;
  final bool hasScanner;
  final bool hasAdf;
  final bool hasDuplex;
  final bool hasColorPrinting;
  final List<String> supportedPaperSizes;
  final List<String> supportedColorModes;
  final String? firmwareVersion;
  final String? serialNumber;
  final DateTime? lastUsed;

  const Printer({
    required this.id,
    required this.nickname,
    required this.model,
    required this.manufacturer,
    required this.connectionType,
    this.status = PrinterStatus.offline,
    this.tier = PrinterTier.a,
    this.ipAddress,
    this.macAddress,
    this.bluetoothAddress,
    this.ippPort = 631,
    this.location,
    this.colorLabel,
    this.isDefault = false,
    this.hasScanner = false,
    this.hasAdf = false,
    this.hasDuplex = false,
    this.hasColorPrinting = true,
    this.supportedPaperSizes = const ['A4', 'Letter'],
    this.supportedColorModes = const ['Color', 'Grayscale', 'Black & White'],
    this.firmwareVersion,
    this.serialNumber,
    this.lastUsed,
  });

  Printer copyWith({
    String? id,
    String? nickname,
    String? model,
    String? manufacturer,
    PrinterConnectionType? connectionType,
    PrinterStatus? status,
    PrinterTier? tier,
    String? ipAddress,
    String? macAddress,
    String? bluetoothAddress,
    int? ippPort,
    String? location,
    String? colorLabel,
    bool? isDefault,
    bool? hasScanner,
    bool? hasAdf,
    bool? hasDuplex,
    bool? hasColorPrinting,
    List<String>? supportedPaperSizes,
    List<String>? supportedColorModes,
    String? firmwareVersion,
    String? serialNumber,
    DateTime? lastUsed,
  }) {
    return Printer(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      model: model ?? this.model,
      manufacturer: manufacturer ?? this.manufacturer,
      connectionType: connectionType ?? this.connectionType,
      status: status ?? this.status,
      tier: tier ?? this.tier,
      ipAddress: ipAddress ?? this.ipAddress,
      macAddress: macAddress ?? this.macAddress,
      bluetoothAddress: bluetoothAddress ?? this.bluetoothAddress,
      ippPort: ippPort ?? this.ippPort,
      location: location ?? this.location,
      colorLabel: colorLabel ?? this.colorLabel,
      isDefault: isDefault ?? this.isDefault,
      hasScanner: hasScanner ?? this.hasScanner,
      hasAdf: hasAdf ?? this.hasAdf,
      hasDuplex: hasDuplex ?? this.hasDuplex,
      hasColorPrinting: hasColorPrinting ?? this.hasColorPrinting,
      supportedPaperSizes: supportedPaperSizes ?? this.supportedPaperSizes,
      supportedColorModes: supportedColorModes ?? this.supportedColorModes,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
      serialNumber: serialNumber ?? this.serialNumber,
      lastUsed: lastUsed ?? this.lastUsed,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nickname': nickname,
    'model': model,
    'manufacturer': manufacturer,
    'connectionType': connectionType.name,
    'status': status.name,
    'tier': tier.name,
    'ipAddress': ipAddress,
    'macAddress': macAddress,
    'bluetoothAddress': bluetoothAddress,
    'ippPort': ippPort,
    'location': location,
    'colorLabel': colorLabel,
    'isDefault': isDefault,
    'hasScanner': hasScanner,
    'hasAdf': hasAdf,
    'hasDuplex': hasDuplex,
    'hasColorPrinting': hasColorPrinting,
    'supportedPaperSizes': supportedPaperSizes,
    'supportedColorModes': supportedColorModes,
    'firmwareVersion': firmwareVersion,
    'serialNumber': serialNumber,
    'lastUsed': lastUsed?.toIso8601String(),
  };

  factory Printer.fromJson(Map<String, dynamic> json) => Printer(
    id: json['id'] as String,
    nickname: json['nickname'] as String,
    model: json['model'] as String,
    manufacturer: json['manufacturer'] as String,
    connectionType: PrinterConnectionType.values.byName(json['connectionType'] as String),
    status: PrinterStatus.values.byName(json['status'] as String? ?? 'offline'),
    tier: PrinterTier.values.byName(json['tier'] as String? ?? 'a'),
    ipAddress: json['ipAddress'] as String?,
    macAddress: json['macAddress'] as String?,
    bluetoothAddress: json['bluetoothAddress'] as String?,
    ippPort: json['ippPort'] as int?,
    location: json['location'] as String?,
    colorLabel: json['colorLabel'] as String?,
    isDefault: json['isDefault'] as bool? ?? false,
    hasScanner: json['hasScanner'] as bool? ?? false,
    hasAdf: json['hasAdf'] as bool? ?? false,
    hasDuplex: json['hasDuplex'] as bool? ?? false,
    hasColorPrinting: json['hasColorPrinting'] as bool? ?? true,
    supportedPaperSizes: List<String>.from(json['supportedPaperSizes'] as List? ?? ['A4']),
    supportedColorModes: List<String>.from(json['supportedColorModes'] as List? ?? ['Color']),
    firmwareVersion: json['firmwareVersion'] as String?,
    serialNumber: json['serialNumber'] as String?,
    lastUsed: json['lastUsed'] != null ? DateTime.parse(json['lastUsed'] as String) : null,
  );

  @override
  List<Object?> get props => [id, nickname, model, connectionType, status];

  String get statusLabel {
    switch (status) {
      case PrinterStatus.ready:     return 'Ready';
      case PrinterStatus.printing:  return 'Printing…';
      case PrinterStatus.scanning:  return 'Scanning…';
      case PrinterStatus.busy:      return 'Busy';
      case PrinterStatus.sleeping:  return 'Sleeping';
      case PrinterStatus.offline:   return 'Offline';
      case PrinterStatus.attention: return 'Needs attention';
    }
  }
}

