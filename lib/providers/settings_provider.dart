import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── App Settings Model ───────────────────────────────────────────────────────

class AppSettings {
  final ThemeMode themeMode;
  final bool reduceEffects;
  final double glassIntensity;    // 0.5 = low, 1.0 = medium, 1.5 = high
  final String defaultPaperSize;
  final String defaultColorMode;
  final bool defaultDuplex;
  final String defaultScanFormat;
  final bool notifications;
  final bool onboardingComplete;
  final String units;             // "mm" or "inches"
  final String language;

  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.reduceEffects = false,
    this.glassIntensity = 1.0,
    this.defaultPaperSize = 'A4',
    this.defaultColorMode = 'Color',
    this.defaultDuplex = false,
    this.defaultScanFormat = 'PDF',
    this.notifications = true,
    this.onboardingComplete = false,
    this.units = 'mm',
    this.language = 'system',
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    bool? reduceEffects,
    double? glassIntensity,
    String? defaultPaperSize,
    String? defaultColorMode,
    bool? defaultDuplex,
    String? defaultScanFormat,
    bool? notifications,
    bool? onboardingComplete,
    String? units,
    String? language,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      reduceEffects: reduceEffects ?? this.reduceEffects,
      glassIntensity: glassIntensity ?? this.glassIntensity,
      defaultPaperSize: defaultPaperSize ?? this.defaultPaperSize,
      defaultColorMode: defaultColorMode ?? this.defaultColorMode,
      defaultDuplex: defaultDuplex ?? this.defaultDuplex,
      defaultScanFormat: defaultScanFormat ?? this.defaultScanFormat,
      notifications: notifications ?? this.notifications,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      units: units ?? this.units,
      language: language ?? this.language,
    );
  }
}

// ─── Settings Notifier ───────────────────────────────────────────────────────

class SettingsNotifier extends StateNotifier<AppSettings> {
  final SharedPreferences _prefs;

  SettingsNotifier(this._prefs) : super(const AppSettings()) {
    _load();
  }

  void _load() {
    state = AppSettings(
      themeMode: ThemeMode.values[_prefs.getInt('themeMode') ?? 0],
      reduceEffects: _prefs.getBool('reduceEffects') ?? false,
      glassIntensity: _prefs.getDouble('glassIntensity') ?? 1.0,
      defaultPaperSize: _prefs.getString('defaultPaperSize') ?? 'A4',
      defaultColorMode: _prefs.getString('defaultColorMode') ?? 'Color',
      defaultDuplex: _prefs.getBool('defaultDuplex') ?? false,
      defaultScanFormat: _prefs.getString('defaultScanFormat') ?? 'PDF',
      notifications: _prefs.getBool('notifications') ?? true,
      onboardingComplete: _prefs.getBool('onboardingComplete') ?? false,
      units: _prefs.getString('units') ?? 'mm',
      language: _prefs.getString('language') ?? 'system',
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _prefs.setInt('themeMode', mode.index);
  }

  Future<void> setReduceEffects(bool value) async {
    state = state.copyWith(reduceEffects: value);
    await _prefs.setBool('reduceEffects', value);
  }

  Future<void> setGlassIntensity(double value) async {
    state = state.copyWith(glassIntensity: value);
    await _prefs.setDouble('glassIntensity', value);
  }

  Future<void> setOnboardingComplete() async {
    state = state.copyWith(onboardingComplete: true);
    await _prefs.setBool('onboardingComplete', true);
  }

  Future<void> setNotifications(bool value) async {
    state = state.copyWith(notifications: value);
    await _prefs.setBool('notifications', value);
  }

  Future<void> setUnits(String units) async {
    state = state.copyWith(units: units);
    await _prefs.setString('units', units);
  }

  Future<void> setDefaultPaperSize(String size) async {
    state = state.copyWith(defaultPaperSize: size);
    await _prefs.setString('defaultPaperSize', size);
  }
}

// ─── Provider ────────────────────────────────────────────────────────────────

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  throw UnimplementedError('Override with actual SharedPreferences');
});

