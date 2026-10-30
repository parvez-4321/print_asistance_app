import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/design_tokens.dart';
import '../../design_system/glass_button.dart';
import '../../design_system/glass_surface.dart';
import '../../providers/settings_provider.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});
  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen>
    with TickerProviderStateMixin {
  final _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _bgController;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  static const _pages = [
    _OnboardPage(
      icon: Icons.print_rounded,
      color: Color(0xFF0A84FF),
      title: 'Print Anything',
      subtitle: 'PDFs, photos, documents and web pages — sent wirelessly to any compatible printer.',
    ),
    _OnboardPage(
      icon: Icons.document_scanner_rounded,
      color: Color(0xFF30D158),
      title: 'Scan & Copy',
      subtitle: 'Turn paper into digital files in seconds. Use your printer\'s scanner or your phone camera.',
    ),
    _OnboardPage(
      icon: Icons.devices_rounded,
      color: Color(0xFFFF9F0A),
      title: 'Manage Printers',
      subtitle: 'Keep all your printers in one place — home, office, or portable — and switch in two taps.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _bgController.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _finish() async {
    await ref.read(settingsProvider.notifier).setOnboardingComplete();
    if (mounted) context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: AnimatedBuilder(
        animation: _bgController,
        builder: (context, _) {
          final t = _bgController.value;
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(const Color(0xFFE8F4FD), const Color(0xFFEDE7FF), t)!,
                  Color.lerp(const Color(0xFFF0F4FF), const Color(0xFFE8F0FF), t)!,
                  Color.lerp(const Color(0xFFEEF2FF), const Color(0xFFE0F2FE), t)!,
                ],
              ),
            ),
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SafeArea(
                child: Column(
                  children: [
                    // Skip
                    Align(
                      alignment: Alignment.topRight,
                      child: TextButton(
                        onPressed: _finish,
                        child: Text('Skip',
                            style: TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.w500)),
                      ),
                    ),

                    // Page view
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _pages.length,
                        onPageChanged: (i) => setState(() => _currentPage = i),
                        itemBuilder: (ctx, i) => _PageCard(page: _pages[i]),
                      ),
                    ),

                    // Dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_pages.length, (i) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: i == _currentPage ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: i == _currentPage
                                ? DesignTokens.accent
                                : Colors.black26,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 32),

                    // Action buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _currentPage < _pages.length - 1
                          ? GlassPrimaryButton(
                              label: 'Next',
                              icon: Icons.arrow_forward_rounded,
                              onPressed: () => _pageController.nextPage(
                                duration: const Duration(milliseconds: 350),
                                curve: Curves.easeInOut,
                              ),
                            )
                          : GlassPrimaryButton(
                              label: 'Get Started',
                              icon: Icons.check_rounded,
                              onPressed: _finish,
                            ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OnboardPage {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  const _OnboardPage(
      {required this.icon,
      required this.color,
      required this.title,
      required this.subtitle});
}

class _PageCard extends StatelessWidget {
  final _OnboardPage page;
  const _PageCard({required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon circle
          GlassSurface(
            blur: DesignTokens.blurHigh,
            borderRadius: 60,
            padding: const EdgeInsets.all(32),
            tint: page.color.withOpacity(0.15),
            child: Icon(page.icon, size: 72, color: page.color),
          ),
          const SizedBox(height: 48),
          Text(
            page.title,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            page.subtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.black54,
                  height: 1.5,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
