import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/printer.dart';

// ─── Shared Preferences provider ─────────────────────────────────────────────

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize with ProviderScope override');
});

// ─── Printer State ────────────────────────────────────────────────────────────

class PrinterState {
  final List<Printer> printers;
  final String? selectedPrinterId;
  final bool isScanning;          // BT/Wi-Fi scanning
  final List<Printer> discovered; // printers found in current scan

  const PrinterState({
    this.printers = const [],
    this.selectedPrinterId,
    this.isScanning = false,
    this.discovered = const [],
  });

  PrinterState copyWith({
    List<Printer>? printers,
    String? selectedPrinterId,
    bool? isScanning,
    List<Printer>? discovered,
  }) {
    return PrinterState(
      printers: printers ?? this.printers,
      selectedPrinterId: selectedPrinterId ?? this.selectedPrinterId,
      isScanning: isScanning ?? this.isScanning,
      discovered: discovered ?? this.discovered,
    );
  }

  Printer? get selectedPrinter =>
      printers.where((p) => p.id == selectedPrinterId).firstOrNull;

  Printer? get defaultPrinter =>
      printers.where((p) => p.isDefault).firstOrNull;
}

// ─── Printer Notifier ────────────────────────────────────────────────────────

class PrinterNotifier extends StateNotifier<PrinterState> {
  static const _kPrintersKey = 'saved_printers';
  static const _kSelectedKey = 'selected_printer_id';
  final SharedPreferences _prefs;
  final _uuid = const Uuid();

  PrinterNotifier(this._prefs) : super(const PrinterState()) {
    _load();
  }

  void _load() {
    final raw = _prefs.getString(_kPrintersKey);
    final selId = _prefs.getString(_kSelectedKey);
    if (raw != null) {
      final list = (jsonDecode(raw) as List)
          .map((e) => Printer.fromJson(e as Map<String, dynamic>))
          .toList();
      state = state.copyWith(printers: list, selectedPrinterId: selId);
    }
  }

  Future<void> _save() async {
    final json = jsonEncode(state.printers.map((p) => p.toJson()).toList());
    await _prefs.setString(_kPrintersKey, json);
    if (state.selectedPrinterId != null) {
      await _prefs.setString(_kSelectedKey, state.selectedPrinterId!);
    }
  }

  Future<void> addPrinter(Printer printer) async {
    final withId = printer.id.isEmpty
        ? printer.copyWith(id: _uuid.v4())
        : printer;
    final updated = [...state.printers, withId];
    state = state.copyWith(
      printers: updated,
      selectedPrinterId: state.selectedPrinterId ?? withId.id,
    );
    await _save();
  }

  Future<void> updatePrinter(Printer printer) async {
    final updated = state.printers.map((p) => p.id == printer.id ? printer : p).toList();
    state = state.copyWith(printers: updated);
    await _save();
  }

  Future<void> removePrinter(String id) async {
    final updated = state.printers.where((p) => p.id != id).toList();
    final newSelected = state.selectedPrinterId == id
        ? updated.firstOrNull?.id
        : state.selectedPrinterId;
    state = state.copyWith(printers: updated, selectedPrinterId: newSelected);
    await _save();
  }

  Future<void> setDefault(String id) async {
    final updated = state.printers.map((p) => p.copyWith(isDefault: p.id == id)).toList();
    state = state.copyWith(printers: updated);
    await _save();
  }

  void selectPrinter(String id) {
    state = state.copyWith(selectedPrinterId: id);
    _prefs.setString(_kSelectedKey, id);
  }

  void setScanning(bool scanning) {
    state = state.copyWith(isScanning: scanning);
  }

  void setDiscovered(List<Printer> discovered) {
    state = state.copyWith(discovered: discovered);
  }

  void addDiscovered(Printer printer) {
    final list = [...state.discovered, printer];
    state = state.copyWith(discovered: list);
  }

  void clearDiscovered() {
    state = state.copyWith(discovered: []);
  }

  Future<void> startBluetoothScan() async {
    state = state.copyWith(isScanning: true, discovered: []);
    // In a real app: invoke flutter_blue_plus scan here
    // Simulate finding some printers after a delay
    await Future.delayed(const Duration(seconds: 2));
    final fakeList = [
      Printer(
        id: 'bt-demo-1',
        nickname: 'HP DeskJet 4155',
        model: 'DeskJet 4155e',
        manufacturer: 'HP',
        connectionType: PrinterConnectionType.bluetooth,
        status: PrinterStatus.ready,
        hasScanner: true,
        hasDuplex: true,
        hasColorPrinting: true,
        supportedPaperSizes: const ['A4', 'Letter', '4x6', '5x7'],
      ),
      Printer(
        id: 'bt-demo-2',
        nickname: 'Epson XP-4200',
        model: 'XP-4200',
        manufacturer: 'Epson',
        connectionType: PrinterConnectionType.bluetooth,
        status: PrinterStatus.sleeping,
        hasScanner: true,
        hasColorPrinting: true,
        supportedPaperSizes: const ['A4', 'Letter', '4x6'],
      ),
    ];
    state = state.copyWith(isScanning: false, discovered: fakeList);
  }

  Future<void> startWifiScan() async {
    state = state.copyWith(isScanning: true, discovered: []);
    await Future.delayed(const Duration(seconds: 3));
    final fakeList = [
      Printer(
        id: 'wifi-demo-1',
        nickname: 'Canon PIXMA G7020',
        model: 'PIXMA G7020',
        manufacturer: 'Canon',
        connectionType: PrinterConnectionType.wifi,
        status: PrinterStatus.ready,
        ipAddress: '192.168.1.101',
        hasScanner: true,
        hasAdf: true,
        hasDuplex: true,
        hasColorPrinting: true,
        supportedPaperSizes: const ['A4', 'A5', 'Letter', 'Legal', '4x6'],
      ),
      Printer(
        id: 'wifi-demo-2',
        nickname: 'Brother MFC-J995DW',
        model: 'MFC-J995DW',
        manufacturer: 'Brother',
        connectionType: PrinterConnectionType.wifi,
        status: PrinterStatus.ready,
        ipAddress: '192.168.1.102',
        hasScanner: true,
        hasAdf: true,
        hasDuplex: true,
        hasColorPrinting: true,
        supportedPaperSizes: const ['A4', 'Letter', 'Legal', '4x6', '5x7'],
      ),
    ];
    state = state.copyWith(isScanning: false, discovered: fakeList);
  }
}

// ─── Provider ────────────────────────────────────────────────────────────────

final printerProvider =
    StateNotifierProvider<PrinterNotifier, PrinterState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return PrinterNotifier(prefs);
});

final selectedPrinterProvider = Provider<Printer?>((ref) {
  final state = ref.watch(printerProvider);
  return state.selectedPrinter ?? state.defaultPrinter ?? state.printers.firstOrNull;
});

