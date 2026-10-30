import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/design_tokens.dart';
import '../core/router/app_router.dart';
import 'glass_tab_bar.dart';

/// Root shell that hosts the bottom glass tab bar and the routed child.
class MainShell extends ConsumerStatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 0;

  static const _tabs = [
    _TabItem(icon: Icons.home_rounded,     label: 'Home',     path: AppRoutes.home),
    _TabItem(icon: Icons.print_rounded,    label: 'Print',    path: AppRoutes.print),
    _TabItem(icon: Icons.document_scanner_rounded, label: 'Scan', path: AppRoutes.scan),
    _TabItem(icon: Icons.print_disabled_rounded,  label: 'Printers', path: AppRoutes.printers),
    _TabItem(icon: Icons.settings_rounded, label: 'Settings', path: AppRoutes.settings),
  ];

  void _onTabTap(int index) {
    setState(() => _currentIndex = index);
    context.go(_tabs[index].path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      extendBody: true,
      bottomNavigationBar: GlassTabBar(
        currentIndex: _currentIndex,
        onTap: _onTabTap,
        items: _tabs
            .map((t) => GlassTabItem(icon: t.icon, label: t.label))
            .toList(),
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final String label;
  final String path;
  const _TabItem({required this.icon, required this.label, required this.path});
}

