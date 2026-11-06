import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../viewmodel/connectivity_viewmodel.dart';

/// Az alkalmazás tetején megjelenő „nincs internet" sáv (View), ami a kapcsolat visszatértekor eltűnik.
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offline = !(ref.watch(onlineProvider).value ?? true);

    return Column(
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          child: offline
              ? Material(
                  color: AppColors.warning,
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.wifi_off_rounded, size: 16, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            AppLocalizations.of(context).offlineBanner,
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
        Expanded(
          // Ha a sáv látszik, a tartalom már nem nyúl a státuszsor alá.
          child: offline ? MediaQuery.removePadding(context: context, removeTop: true, child: child) : child,
        ),
      ],
    );
  }
}
