import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/design_tokens.dart';
import '../../design_system/glass_app_bar.dart';
import '../../design_system/glass_button.dart';
import '../../design_system/glass_card.dart';
import '../../design_system/glass_surface.dart';
import '../../providers/printer_provider.dart';
import '../../models/printer.dart';

class BluetoothScanScreen extends ConsumerStatefulWidget {
  const BluetoothScanScreen({super.key});

  @override
  ConsumerState<BluetoothScanScreen> createState() => _BluetoothScanScreenState();
}

class _BluetoothScanScreenState extends ConsumerState<BluetoothScanScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _radarCtrl;
  bool _connecting = false;
  String? _connectingId;

  @override
  void initState() {
    super.initState();
    _radarCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _radarCtrl.dispose();
    super.dispose();
  }

  Future<void> _connectTo(Printer printer) async {
    setState(() {
      _connecting = true;
      _connectingId = printer.id;
    });
    // Simulate connecting
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _connecting = false;
      _connectingId = null;
    });
    if (mounted) {
      context.push(AppRoutes.setupSuccess, extra: {
        'id': printer.id,
        'model': printer.model,
        'manufacturer': printer.manufacturer,
        'connectionType': 'bluetooth',
        'hasScanner': printer.hasScanner,
        'hasDuplex': printer.hasDuplex,
        'hasColorPrinting': printer.hasColorPrinting,
        'supportedPaperSizes': printer.supportedPaperSizes,
      });
    }
  }

  Future<void> _rescan() async {
    ref.read(printerProvider.notifier).clearDiscovered();
    await ref.read(printerProvider.notifier).startBluetoothScan();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(printerProvider);

    return Scaffold(
      appBar: GlassAppBar(
        title: 'Bluetooth Setup',
        actions: [
          TextButton(
            onPressed: state.isScanning ? null : _rescan,
            child: const Text('Rescan'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Radar animation
          SizedBox(
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Radar rings
                AnimatedBuilder(
                  animation: _radarCtrl,
                  builder: (ctx, _) {
                    return CustomPaint(
                      size: const Size(200, 200),
                      painter: _RadarPainter(
                        progress: _radarCtrl.value,
                        active: state.isScanning,
                      ),
                    );
                  },
                ),
                // Center icon
                GlassSurface(
                  blur: DesignTokens.blurHigh,
                  borderRadius: 32,
                  padding: const EdgeInsets.all(16),
                  tint: const Color(0xFF5856D6).withValues(alpha: 0.15),
                  child: const Icon(Icons.bluetooth_rounded,
                      size: 36, color: Color(0xFF5856D6)),
                ),
              ],
            ),
          ),

          // Status text
          Text(
            state.isScanning
                ? 'Scanning for Bluetooth printers…'
                : state.discovered.isEmpty
                    ? 'No printers found'
                    : '${state.discovered.length} printer${state.discovered.length > 1 ? "s" : ""} found',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 16),

          // Results list
          Expanded(
            child: state.discovered.isEmpty && !state.isScanning
                ? _buildNoneFound(context)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.discovered.length,
                    itemBuilder: (ctx, i) {
                      final p = state.discovered[i];
                      final isConnecting = _connectingId == p.id;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: GlassCard(
                          onTap: _connecting ? null : () => _connectTo(p),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF5856D6)
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.print_rounded,
                                    size: 22, color: Color(0xFF5856D6)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(p.nickname,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                                fontWeight: FontWeight.w600)),
                                    Text(
                                      p.model,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                              // Signal icon
                              const Icon(Icons.signal_cellular_alt_rounded,
                                  size: 18, color: DesignTokens.success),
                              const SizedBox(width: 8),
                              if (isConnecting)
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2),
                                )
                              else
                                const Icon(Icons.chevron_right_rounded,
                                    color: Colors.grey),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          if (state.isScanning)
            Padding(
              padding: const EdgeInsets.all(16),
              child: GlassSurface(
                blur: DesignTokens.blurMedium,
                borderRadius: 12,
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 12),
                    Text('Scanning for up to 30 seconds…',
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNoneFound(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: GlassCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bluetooth_disabled_rounded,
                size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text('No Bluetooth printers found',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            const Text(
              'Check that your printer is powered on and in pairing mode, then try rescanning.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 16),
            _buildChecklist(context),
            const SizedBox(height: 16),
            GlassPrimaryButton(
              label: 'Rescan',
              icon: Icons.refresh_rounded,
              onPressed: _rescan,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklist(BuildContext context) {
    final items = [
      'Printer is powered on',
      'Bluetooth is enabled on your phone',
      'Printer is in pairing / discoverable mode',
      'Phone is within 1–2 metres of the printer',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    const Icon(Icons.check_box_outline_blank_rounded,
                        size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(item,
                            style: const TextStyle(
                                fontSize: 13, color: Colors.grey))),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

class _RadarPainter extends CustomPainter {
  final double progress;
  final bool active;
  _RadarPainter({required this.progress, required this.active});

  @override
  void paint(Canvas canvas, Size size) {
    if (!active) return;
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;
    final paint = Paint()
      ..color = const Color(0xFF5856D6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (int i = 0; i < 3; i++) {
      final t = (progress + i / 3) % 1.0;
      final radius = t * maxRadius;
      final opacity = (1 - t) * 0.5;
      paint.color =
          const Color(0xFF5856D6).withValues(alpha: opacity);
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(_RadarPainter old) => true;
}
