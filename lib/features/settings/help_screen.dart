import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/design_tokens.dart';
import '../../design_system/glass_app_bar.dart';
import '../../design_system/glass_card.dart';
import '../../design_system/glass_surface.dart';

class HelpScreen extends ConsumerStatefulWidget {
  const HelpScreen({super.key});

  @override
  ConsumerState<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends ConsumerState<HelpScreen> {
  String _query = '';
  int? _expandedIndex;

  static const _issues = [
    _Issue(
      title: 'Printer not found',
      icon: Icons.wifi_find_rounded,
      steps: [
        'Make sure your printer is powered on and not in sleep mode.',
        'Check that your phone and printer are on the same Wi-Fi network.',
        'Confirm the printer is not connected to a 5 GHz band — many printers only support 2.4 GHz.',
        'Restart the printer and wait 30 seconds.',
        'Tap "Rescan" in the Add Printer screen.',
        'If still not found, try adding the printer manually with its IP address.',
      ],
    ),
    _Issue(
      title: 'Print job failed',
      icon: Icons.print_disabled_rounded,
      steps: [
        'Check if the printer has paper loaded and is not showing errors on its screen.',
        'Ensure the printer is online — tap the status dot in the Printers tab.',
        'Try cancelling the failed job and printing again.',
        'Restart the printer if the issue persists.',
        'Make sure the file format is supported (PDF, JPEG, PNG are most compatible).',
      ],
    ),
    _Issue(
      title: 'Can\'t scan',
      icon: Icons.document_scanner_outlined,
      steps: [
        'Confirm your printer has a built-in scanner (check Printer Details).',
        'Make sure the scanner lid is closed and the glass is clean.',
        'Check that no other device is using the scanner at the same time.',
        'Try switching from "Printer scan" to "Phone scan" as a workaround.',
        'Restart the printer and try again.',
      ],
    ),
    _Issue(
      title: 'Bluetooth not working',
      icon: Icons.bluetooth_disabled_rounded,
      steps: [
        'Ensure Bluetooth is enabled on your phone.',
        'Grant Bluetooth permissions to PrintAssist in your phone\'s Settings app.',
        'Move your phone closer to the printer (within 1–2 metres).',
        'On Android 12+: grant the "Nearby devices" permission.',
        'Note: On iPhone, Bluetooth Classic is not available for third-party apps. Only BLE printers are supported.',
        'Try turning Bluetooth off and on again.',
      ],
    ),
    _Issue(
      title: 'Poor print quality',
      icon: Icons.tune_rounded,
      steps: [
        'Increase print quality to "High" or "Photo" in Print Settings.',
        'Make sure you are using the correct paper type setting.',
        'Run a nozzle check from Printer Details → Clean Head.',
        'Check ink levels — low ink can cause banding.',
        'If printing photos, use photo paper and select "Borderless".',
      ],
    ),
  ];

  static const _brands = [
    'HP', 'Canon', 'Epson', 'Brother', 'Samsung', 'Xerox',
    'Ricoh', 'Kyocera', 'Lexmark', 'Pantum',
  ];

  List<_Issue> get _filtered {
    if (_query.isEmpty) return _issues;
    return _issues
        .where((i) => i.title.toLowerCase().contains(_query.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlassAppBar(title: 'Help & Support'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          // Search
          TextField(
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: 'Search help topics…',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () => setState(() => _query = ''),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 24),

          // Popular issues
          Text('Common Issues',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          ..._filtered.asMap().entries.map((e) {
            final i = e.key;
            final issue = e.value;
            final expanded = _expandedIndex == i;
            return GlassCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(issue.icon, color: DesignTokens.accent),
                    title: Text(issue.title),
                    trailing: AnimatedRotation(
                      turns: expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(Icons.expand_more_rounded),
                    ),
                    onTap: () => setState(
                        () => _expandedIndex = expanded ? null : i),
                  ),
                  if (expanded)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: issue.steps.asMap().entries.map((step) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 22,
                                  height: 22,
                                  margin: const EdgeInsets.only(right: 10, top: 1),
                                  decoration: BoxDecoration(
                                    color: DesignTokens.accent.withOpacity(0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${step.key + 1}',
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: DesignTokens.accent,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(step.value,
                                      style: Theme.of(context).textTheme.bodyMedium),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            );
          }),
          const SizedBox(height: 24),

          // Brand guides
          Text('Brand Setup Guides',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _brands
                .map((b) => GestureDetector(
                      onTap: () => _showBrandGuide(context, b),
                      child: GlassSurface(
                        blur: DesignTokens.blurMedium,
                        borderRadius: 12,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.print_rounded,
                                size: 16, color: DesignTokens.accent),
                            const SizedBox(width: 6),
                            Text(b,
                                style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 28),

          // Contact support
          GlassCard(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.support_agent_rounded,
                      color: DesignTokens.accent),
                  title: Text('Contact Support'),
                  subtitle:
                      Text('We typically respond within 24 hours'),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    icon: const Icon(Icons.email_outlined),
                    label: const Text('Email Support'),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Opening email client…')),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showBrandGuide(BuildContext context, String brand) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => GlassSurface(
        blur: DesignTokens.blurHigh,
        borderRadius: DesignTokens.radiusSheet,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white38,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text('$brand Printer Setup',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            _GuideStep('1', 'Power on your $brand printer and make sure it is in setup mode.'),
            _GuideStep('2', 'Open PrintAssist and tap Add Printer.'),
            _GuideStep('3', 'Choose Wi-Fi setup if your printer supports Wi-Fi, or Bluetooth for direct connection.'),
            _GuideStep('4', 'Follow the on-screen steps to connect.'),
            _GuideStep('5', 'Print a test page to confirm everything is working.'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Got it'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _Issue {
  final String title;
  final IconData icon;
  final List<String> steps;
  const _Issue({required this.title, required this.icon, required this.steps});
}

class _GuideStep extends StatelessWidget {
  final String number;
  final String text;
  const _GuideStep(this.number, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(right: 10, top: 1),
            decoration: BoxDecoration(
              color: DesignTokens.accent.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                    fontSize: 12,
                    color: DesignTokens.accent,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

