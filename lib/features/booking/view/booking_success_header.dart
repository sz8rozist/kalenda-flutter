import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/review/review_prompt.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/ui/haptics.dart';

/// A sikeres foglalás fejléce (View): animált pipa, üdvözlő szöveg. Megjelenésekor rezeg egyet,
/// és (a második foglalástól egyszer) az áruházi értékelést is kéri.
class BookingSuccessHeader extends ConsumerStatefulWidget {
  const BookingSuccessHeader({super.key});

  @override
  ConsumerState<BookingSuccessHeader> createState() => _BookingSuccessHeaderState();
}

class _BookingSuccessHeaderState extends ConsumerState<BookingSuccessHeader> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))..forward();

  @override
  void initState() {
    super.initState();
    Haptics.success();
    // Kis késleltetéssel, hogy az animáció végigmenjen az értékelés-kérés előtt.
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) ref.read(reviewPromptProvider).afterBooking();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Semantics(
      liveRegion: true,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          children: [
            ScaleTransition(
              scale: CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.12), shape: BoxShape.circle),
                child: const Icon(Icons.check_circle_rounded, size: 56, color: AppColors.success),
              ),
            ),
            const SizedBox(height: 16),
            FadeTransition(
              opacity: CurvedAnimation(parent: _controller, curve: const Interval(0.4, 1)),
              child: Column(
                children: [
                  Text(l10n.bookingDoneTitle, style: theme.textTheme.headlineSmall, textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text(
                    l10n.bookingDoneText,
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    textAlign: TextAlign.center,
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
