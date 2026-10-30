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

class WiFiSetupScreen extends ConsumerStatefulWidget {
  const WiFiSetupScreen({super.key});

  @override
  ConsumerState<WiFiSetupScreen> createState() => _WiFiSetupScreenState();
}

class _WiFiSetupScreenState extends ConsumerState<WiFiSetupScreen> {
  bool _showManualForm = false;
  bool _connecting = false;
  bool _obscurePassword = true;
  final _ssidCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _ssidCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _connectTo(Printer printer) async {
    setState(() => _connecting = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _connecting = false);
    if (mounted) {
      context.push(AppRoutes.setupSuccess, extra: {
        'id': printer.id,
        'model': printer.model,
        'manufacturer': printer.manufacturer,
        'connectionType': 'wifi',
        'ipAddress': printer.ipAddress,
        'hasScanner': printer.hasScanner,
        'hasAdf': printer.hasAdf,
        'hasDuplex': printer.hasDuplex,
        'hasColorPrinting': printer.hasColorPrinting,
        'supportedPaperSizes': printer.supportedPaperSizes,
      });
    }
  }

  Future<void> _rescan() async {
    ref.read(printerProvider.notifier).clearDiscovered();
    await ref.read(printerProvider.notifier).startWifiScan();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(printerProvider);

    return Scaffold(
      appBar: GlassAppBar(
        title: 'Wi-Fi Setup',
        actions: [
          TextButton(
            onPressed: state.isScanning ? null : _rescan,
            child: const Text('Rescan'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          // Status banner
          if (state.isScanning)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: DesignTokens.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Text('Searching for printers on your network…',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),

          // Found printers
          if (state.discovered.isNotEmpty) ...[
            Text('Printers on your network',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...state.discovered.map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GlassCard(
                    onTap: _connecting ? null : () => _connectTo(p),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: DesignTokens.accent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.print_rounded,
                              size: 22, color: DesignTokens.accent),
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
                                      ?.copyWith(fontWeight: FontWeight.w600)),
                              Text(
                                p.ipAddress ?? p.model,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        if (_connecting)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else
                          FilledButton(
                            onPressed: () => _connectTo(p),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text('Connect'),
                          ),
                      ],
                    ),
                  ),
                )),
            const SizedBox(height: 16),
          ],

          // Manual / not on network section
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.router_rounded),
                  title: const Text('Printer not on my network yet'),
                  subtitle: const Text('Connect a new printer to Wi-Fi'),
                  trailing: AnimatedRotation(
                    turns: _showManualForm ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.expand_more_rounded),
                  ),
                  onTap: () =>
                      setState(() => _showManualForm = !_showManualForm),
                ),
                if (_showManualForm) ...[
                  const Divider(),
                  Text(
                    '1. Put your printer in Wi-Fi setup mode (hold the Wi-Fi button until it blinks).\n'
                    '2. Enter your home Wi-Fi network name and password below.\n'
                    '3. Tap Connect — the app will send the credentials to your printer.',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey, height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _ssidCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Wi-Fi Network Name (SSID)',
                      prefixIcon: Icon(Icons.wifi_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _passCtrl,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 5GHz warning
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: DesignTokens.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: DesignTokens.warning.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            color: DesignTokens.warning, size: 18),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Most printers only support 2.4 GHz Wi-Fi. If connection fails, try a 2.4 GHz network.',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  GlassPrimaryButton(
                    label: 'Connect',
                    icon: Icons.wifi_rounded,
                    loading: _connecting,
                    onPressed: _connecting ? null : () {
                      // Simulate connecting via manual setup
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Sending Wi-Fi credentials to printer…')),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),

          if (state.discovered.isEmpty && !state.isScanning)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.wifi_find_rounded,
                        size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    Text('No printers found on this network',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.grey)),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Scan again'),
                      onPressed: _rescan,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
