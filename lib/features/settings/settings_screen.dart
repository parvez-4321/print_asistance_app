import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/design_tokens.dart';
import '../../design_system/glass_app_bar.dart';
import '../../design_system/glass_card.dart';
import '../../design_system/glass_surface.dart';
import '../../design_system/glass_card.dart' show GlassSegmentedControl;
import '../../providers/settings_provider.dart';
import 'package:flutter/material.dart' show ThemeMode;

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: GlassAppBar(title: 'Settings'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          // ─── PRINTERS ────────────────────────────────────────────────
          _SectionHeader('Printers'),
          GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.print_rounded),
                  title: const Text('My Printers'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push(AppRoutes.printers),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.straighten_rounded),
                  title: const Text('Default Paper Size'),
                  trailing: _DropdownValue(
                    value: settings.defaultPaperSize,
                    items: const ['A4', 'Letter', 'A5', 'Legal'],
                    onChanged: (v) => notifier.setDefaultPaperSize(v),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ─── DEFAULTS ────────────────────────────────────────────────
          _SectionHeader('Defaults'),
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Color Mode',
                    style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                GlassSegmentedControl<String>(
                  value: settings.defaultColorMode,
                  items: const [
                    ('Color', 'Color'),
                    ('Grayscale', 'Grayscale'),
                    ('Black & White', 'B&W'),
                  ],
                  onChanged: (v) {},
                ),
                const SizedBox(height: 16),
                Text('Units', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                GlassSegmentedControl<String>(
                  value: settings.units,
                  items: const [('mm', 'Millimetres'), ('inches', 'Inches')],
                  onChanged: (v) => notifier.setUnits(v),
                ),
                const SizedBox(height: 16),
                Text('Default Scan Format',
                    style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                GlassSegmentedControl<String>(
                  value: settings.defaultScanFormat,
                  items: const [
                    ('PDF', 'PDF'),
                    ('JPEG', 'JPEG'),
                    ('PNG', 'PNG'),
                  ],
                  onChanged: (v) {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ─── APPEARANCE ──────────────────────────────────────────────
          _SectionHeader('Appearance'),
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Theme', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                GlassSegmentedControl<ThemeMode>(
                  value: settings.themeMode,
                  items: const [
                    (ThemeMode.light, 'Light'),
                    (ThemeMode.dark, 'Dark'),
                    (ThemeMode.system, 'System'),
                  ],
                  onChanged: (v) => notifier.setThemeMode(v),
                ),
                const SizedBox(height: 16),
                Text('Glass Intensity',
                    style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 4),
                GlassSegmentedControl<double>(
                  value: settings.glassIntensity,
                  items: const [
                    (0.5, 'Low'),
                    (1.0, 'Medium'),
                    (1.5, 'High'),
                  ],
                  onChanged: (v) => notifier.setGlassIntensity(v),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Reduce Effects'),
                  subtitle: const Text(
                      'Disable glass blur for better performance on older devices'),
                  value: settings.reduceEffects,
                  onChanged: (v) => notifier.setReduceEffects(v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ─── NOTIFICATIONS ───────────────────────────────────────────
          _SectionHeader('Notifications'),
          GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Job finished'),
                  value: settings.notifications,
                  onChanged: (v) => notifier.setNotifications(v),
                ),
                const Divider(height: 1, indent: 16),
                SwitchListTile(
                  title: const Text('Job failed'),
                  value: settings.notifications,
                  onChanged: (v) => notifier.setNotifications(v),
                ),
                const Divider(height: 1, indent: 16),
                SwitchListTile(
                  title: const Text('Printer needs attention'),
                  value: settings.notifications,
                  onChanged: (v) => notifier.setNotifications(v),
                ),
                const Divider(height: 1, indent: 16),
                SwitchListTile(
                  title: const Text('Low ink / toner'),
                  subtitle: const Text('Alert at 20% remaining'),
                  value: settings.notifications,
                  onChanged: (v) => notifier.setNotifications(v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ─── HELP ─────────────────────────────────────────────────────
          _SectionHeader('Help & Support'),
          GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.help_outline_rounded),
                  title: const Text('Help Center'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push(AppRoutes.help),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.bug_report_outlined),
                  title: const Text('Send Diagnostic Log'),
                  subtitle: const Text('Sent with your consent only'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _showDiagnosticConsent(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ─── ABOUT ───────────────────────────────────────────────────
          _SectionHeader('About'),
          GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline_rounded),
                  title: const Text('Version'),
                  trailing: const Text('1.0.0', style: TextStyle(color: Colors.grey)),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.article_outlined),
                  title: const Text('Licenses'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => showLicensePage(
                    context: context,
                    applicationName: 'PrintAssist',
                    applicationVersion: '1.0.0',
                  ),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {},
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: const Text('Terms of Service'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDiagnosticConsent(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Send Diagnostic Log'),
        content: const Text(
          'This will send a log of recent app activity (no documents or personal files) to our support team to help diagnose issues. The log will be reviewed and deleted after 30 days.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Diagnostic log sent. Thank you!')),
              );
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 0, 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.grey,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}

class _DropdownValue extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;
  const _DropdownValue(
      {required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: value,
      underline: const SizedBox.shrink(),
      isDense: true,
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
      items: items
          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
          .toList(),
    );
  }
}

