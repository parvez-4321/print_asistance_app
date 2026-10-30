import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/design_tokens.dart';
import '../../design_system/glass_app_bar.dart';
import '../../design_system/glass_button.dart';
import '../../design_system/glass_card.dart';
import '../../design_system/glass_surface.dart';
import '../../design_system/glass_bottom_sheet.dart';
import '../../providers/printer_provider.dart';
import '../../models/printer.dart';

class SetupSuccessScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? printerData;
  const SetupSuccessScreen({super.key, this.printerData});

  @override
  ConsumerState<SetupSuccessScreen> createState() => _SetupSuccessScreenState();
}

class _SetupSuccessScreenState extends ConsumerState<SetupSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleCtrl;
  late Animation<double> _scaleAnim;
  late TextEditingController _nameCtrl;
  bool _testPage = true;
  bool _setDefault = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final model = widget.printerData?['model'] as String? ?? 'My Printer';
    _nameCtrl = TextEditingController(text: model);
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scaleAnim = CurvedAnimation(
      parent: _scaleCtrl,
      curve: Curves.elasticOut,
    );
    Future.delayed(const Duration(milliseconds: 200), () => _scaleCtrl.forward());
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _done() async {
    setState(() => _saving = true);
    final data = widget.printerData ?? {};
    final printer = Printer(
      id: data['id'] as String? ?? const Uuid().v4(),
      nickname: _nameCtrl.text.trim().isEmpty
          ? (data['model'] as String? ?? 'My Printer')
          : _nameCtrl.text.trim(),
      model: data['model'] as String? ?? 'Unknown Model',
      manufacturer: data['manufacturer'] as String? ?? 'Unknown',
      connectionType: data['connectionType'] == 'bluetooth'
          ? PrinterConnectionType.bluetooth
          : PrinterConnectionType.wifi,
      status: PrinterStatus.ready,
      ipAddress: data['ipAddress'] as String?,
      hasScanner: data['hasScanner'] as bool? ?? false,
      hasAdf: data['hasAdf'] as bool? ?? false,
      hasDuplex: data['hasDuplex'] as bool? ?? false,
      hasColorPrinting: data['hasColorPrinting'] as bool? ?? true,
      supportedPaperSizes:
          List<String>.from(data['supportedPaperSizes'] as List? ?? ['A4', 'Letter']),
      isDefault: _setDefault,
      lastUsed: DateTime.now(),
    );

    await ref.read(printerProvider.notifier).addPrinter(printer);
    if (_setDefault) {
      await ref.read(printerProvider.notifier).setDefault(printer.id);
    }

    setState(() => _saving = false);
    if (mounted) context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlassAppBar(title: 'Setup Complete'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              // Animated success icon
              ScaleTransition(
                scale: _scaleAnim,
                child: GlassSurface(
                  blur: DesignTokens.blurHigh,
                  borderRadius: 60,
                  tint: DesignTokens.success.withOpacity(0.15),
                  padding: const EdgeInsets.all(28),
                  child: const Icon(Icons.check_circle_outline_rounded,
                      size: 80, color: DesignTokens.success),
                ),
              ),
              const SizedBox(height: 24),
              Text('Printer Connected!',
                  style: Theme.of(context)
                      .textTheme
                      .headlineLarge
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(
                'Your printer is ready to use.',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 36),

              // Name field
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Printer Name',
                        style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Office Printer',
                        prefixIcon: Icon(Icons.print_rounded),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Options
              GlassCard(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  children: [
                    SwitchListTile(
                      value: _testPage,
                      onChanged: (v) => setState(() => _testPage = v),
                      title: const Text('Print a test page'),
                      subtitle: const Text('Confirm the connection is working'),
                      secondary: const Icon(Icons.article_outlined),
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    SwitchListTile(
                      value: _setDefault,
                      onChanged: (v) => setState(() => _setDefault = v),
                      title: const Text('Set as default printer'),
                      subtitle: const Text('Use this printer for all jobs by default'),
                      secondary: const Icon(Icons.star_outline_rounded),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              GlassPrimaryButton(
                label: 'Done',
                icon: Icons.check_rounded,
                onPressed: _saving ? null : _done,
                loading: _saving,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

