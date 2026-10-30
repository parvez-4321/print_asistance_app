import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/design_tokens.dart';
import '../../design_system/glass_app_bar.dart';
import '../../design_system/glass_card.dart';
import '../../design_system/glass_surface.dart';
import '../../providers/printer_provider.dart';

class AddPrinterScreen extends ConsumerWidget {
  const AddPrinterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: GlassAppBar(title: 'Add Printer'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.s24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How is your printer connected?',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Choose a setup path to get started.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 32),

              // Bluetooth card
              _SetupCard(
                icon: Icons.bluetooth_rounded,
                iconColor: const Color(0xFF5856D6),
                title: 'Bluetooth',
                subtitle:
                    'For portable and thermal printers, or to configure a Wi-Fi printer wirelessly.',
                onTap: () {
                  ref.read(printerProvider.notifier).startBluetoothScan();
                  context.push(AppRoutes.btScan);
                },
              ),
              const SizedBox(height: 16),

              // Wi-Fi card
              _SetupCard(
                icon: Icons.wifi_rounded,
                iconColor: DesignTokens.accent,
                title: 'Wi-Fi',
                subtitle:
                    'Find a printer already on your network or connect a new one to Wi-Fi.',
                onTap: () {
                  ref.read(printerProvider.notifier).startWifiScan();
                  context.push(AppRoutes.wifiSetup);
                },
              ),
              const Spacer(),

              // Help link
              Center(
                child: TextButton.icon(
                  icon: const Icon(Icons.help_outline_rounded, size: 18),
                  label: const Text('Need help?'),
                  onPressed: () => context.push(AppRoutes.help),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SetupCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SetupCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right_rounded, color: Colors.grey),
        ],
      ),
    );
  }
}
