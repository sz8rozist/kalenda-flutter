import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/ui/app_logo.dart';
import '../viewmodel/startup_viewmodel.dart';

/// Az app indulási képernyője (View): a natív splash-sel azonos háttér és logó, majd a felirat finoman beúszik,
/// az indítás végén az egész elhalványul. A tartalom végig él a háttérben (nem épül újra).
class SplashGate extends ConsumerStatefulWidget {
  const SplashGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends ConsumerState<SplashGate> with SingleTickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
  bool _gone = false;

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ready = ref.watch(startupProvider).hasValue;

    return Stack(
      children: [
        widget.child,
        if (!_gone)
          Positioned.fill(
            child: IgnorePointer(
              ignoring: ready,
              child: AnimatedOpacity(
                opacity: ready ? 0 : 1,
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOut,
                onEnd: () {
                  if (ready && mounted) setState(() => _gone = true);
                },
                child: _SplashContent(animation: _intro),
              ),
            ),
          ),
      ],
    );
  }
}

class _SplashContent extends StatelessWidget {
  const _SplashContent({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final background = dark ? const Color(0xFF06222F) : AppColors.tint;
    final fade = CurvedAnimation(parent: animation, curve: const Interval(0.35, 1, curve: Curves.easeOut));

    return Material(
      color: background,
      child: Stack(
        children: [
          Center(
            // A logó a natív splash-sel megegyező helyen és méretben marad: nincs ugrás az átmenetnél.
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.92, end: 1).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutBack)),
              child: const AppLogo(size: 144),
            ),
          ),
          Align(
            alignment: const Alignment(0, 0.62),
            child: FadeTransition(
              opacity: fade,
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(fade),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Kalenda',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: dark ? Colors.white : AppColors.navy),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.splashTagline,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: dark ? Colors.white70 : AppColors.navy.withValues(alpha: 0.7)),
                    ),
                    const SizedBox(height: 28),
                    const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
