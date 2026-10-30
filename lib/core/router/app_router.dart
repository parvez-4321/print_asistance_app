import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/onboarding/welcome_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/printers/printers_screen.dart';
import '../../features/printers/add_printer_screen.dart';
import '../../features/printers/bluetooth_scan_screen.dart';
import '../../features/printers/wifi_setup_screen.dart';
import '../../features/printers/setup_success_screen.dart';
import '../../features/printers/printer_details_screen.dart';
import '../../features/print/print_home_screen.dart';
import '../../features/print/print_preview_screen.dart';
import '../../features/print/print_progress_screen.dart';
import '../../features/scan/scan_home_screen.dart';
import '../../features/scan/scan_editor_screen.dart';
import '../../features/scan/save_share_screen.dart';
import '../../features/copy/copy_screen.dart';
import '../../features/library/library_screen.dart';
import '../../features/queue/queue_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/settings/help_screen.dart';
import '../../design_system/main_shell.dart';

// ─── Route names ─────────────────────────────────────────────────────────────
class AppRoutes {
  static const welcome       = '/welcome';
  static const home          = '/home';
  static const print         = '/print';
  static const printPreview  = '/print/preview';
  static const printProgress = '/print/progress';
  static const scan          = '/scan';
  static const scanEditor    = '/scan/editor';
  static const saveShare     = '/scan/save';
  static const copy          = '/copy';
  static const library       = '/library';
  static const queue         = '/queue';
  static const printers      = '/printers';
  static const addPrinter    = '/printers/add';
  static const btScan        = '/printers/bluetooth';
  static const wifiSetup     = '/printers/wifi';
  static const setupSuccess  = '/printers/success';
  static const printerDetail = '/printers/:id';
  static const settings      = '/settings';
  static const help          = '/settings/help';
}

// ─── Router provider ─────────────────────────────────────────────────────────
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.welcome,
    debugLogDiagnostics: false,
    routes: [
      // Welcome / Onboarding
      GoRoute(
        path: AppRoutes.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),

      // Shell with bottom nav bar
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.print,
            builder: (context, state) => const PrintHomeScreen(),
            routes: [
              GoRoute(
                path: 'preview',
                builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>?;
                  return PrintPreviewScreen(fileData: extra);
                },
              ),
              GoRoute(
                path: 'progress',
                builder: (context, state) => const PrintProgressScreen(),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.scan,
            builder: (context, state) => const ScanHomeScreen(),
            routes: [
              GoRoute(
                path: 'editor',
                builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>?;
                  return ScanEditorScreen(scanData: extra);
                },
              ),
              GoRoute(
                path: 'save',
                builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>?;
                  return SaveShareScreen(scanData: extra);
                },
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.copy,
            builder: (context, state) => const CopyScreen(),
          ),
          GoRoute(
            path: AppRoutes.library,
            builder: (context, state) => const LibraryScreen(),
          ),
          GoRoute(
            path: AppRoutes.queue,
            builder: (context, state) => const QueueScreen(),
          ),
          GoRoute(
            path: AppRoutes.printers,
            builder: (context, state) => const PrintersScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) => const AddPrinterScreen(),
              ),
              GoRoute(
                path: 'bluetooth',
                builder: (context, state) => const BluetoothScanScreen(),
              ),
              GoRoute(
                path: 'wifi',
                builder: (context, state) => const WiFiSetupScreen(),
              ),
              GoRoute(
                path: 'success',
                builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>?;
                  return SetupSuccessScreen(printerData: extra);
                },
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return PrinterDetailsScreen(printerId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.settings,
            builder: (context, state) => const SettingsScreen(),
            routes: [
              GoRoute(
                path: 'help',
                builder: (context, state) => const HelpScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

