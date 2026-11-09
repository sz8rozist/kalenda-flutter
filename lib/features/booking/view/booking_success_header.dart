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
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
        decoration: BoxDecoration(color: AppColors.brand, borderRadius: BorderRadius.circular(AppDimens.radiusLarge)),
        child: Column(
          children: [
            ScaleTransition(
              scale: CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
              child: Container(
                width: 68,
                height: 68,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded, size: 38, color: AppColors.brand),
              ),
            ),
            const SizedBox(height: 16),
            FadeTransition(
              opacity: CurvedAnimation(parent: _controller, curve: const Interval(0.4, 1)),
              child: Column(
                children: [
                  Text(
                    l10n.bookingDoneTitle,
                    style: theme.textTheme.headlineMedium?.copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.bookingDoneText,
                    style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.blueSoft),
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
