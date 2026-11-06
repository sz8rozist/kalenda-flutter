import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/ui/haptics.dart';
import '../viewmodel/onboarding_viewmodel.dart';

/// Első indításkor megjelenő háromlépéses bemutató (View). A tartalom mögött az app már betöltődik.
class OnboardingGate extends ConsumerWidget {
  const OnboardingGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final show = ref.watch(onboardingProvider).value ?? false;
    return Stack(
      children: [
        child,
        if (show) const Positioned.fill(child: _OnboardingPages()),
      ],
    );
  }
}

class _OnboardingPages extends ConsumerStatefulWidget {
  const _OnboardingPages();

  @override
  ConsumerState<_OnboardingPages> createState() => _OnboardingPagesState();
}

class _OnboardingPagesState extends ConsumerState<_OnboardingPages> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final pages = [
      (Icons.search_rounded, l10n.onboardingTitle1, l10n.onboardingText1),
      (Icons.event_available_rounded, l10n.onboardingTitle2, l10n.onboardingText2),
      (Icons.notifications_active_outlined, l10n.onboardingTitle3, l10n.onboardingText3),
    ];
    final last = _page == pages.length - 1;

    return Material(
      color: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(onPressed: ref.read(onboardingProvider.notifier).finish, child: Text(l10n.skip)),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) {
                  Haptics.select();
                  setState(() => _page = i);
                },
                children: [
                  for (final (icon, title, text) in pages)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 160,
                            height: 160,
                            decoration: const BoxDecoration(gradient: AppColors.heroGradient, shape: BoxShape.circle),
                            child: Icon(icon, size: 72, color: Colors.white),
                          ),
                          const SizedBox(height: 36),
                          Text(title, style: theme.textTheme.headlineSmall, textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          Text(
                            text,
                            style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < pages.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _page ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _page ? theme.colorScheme.primary : theme.colorScheme.primary.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(AppDimens.pagePadding),
              child: Column(
                children: [
                  FilledButton(
                    onPressed: () {
                      if (last) {
                        Haptics.success();
                        ref.read(onboardingProvider.notifier).finish();
                      } else {
                        _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                      }
                    },
                    child: Text(last ? l10n.getStarted : l10n.next),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
