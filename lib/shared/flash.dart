import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderListenable;

import '../core/viewmodel/action_state.dart';
import '../l10n/app_localizations.dart';
import 'ui/app_alerts.dart';

/// A ViewModel visszajelzését mutatja: a siker / lemondás rövid toast, a hiba érthető alert-párbeszéd. A `build`-ben
/// hívandó, pl.: `listenFlash(ref, context, actionsProvider.select((s) => s.flash));`
void listenFlash(WidgetRef ref, BuildContext context, ProviderListenable<Flash?> source) {
  ref.listen<Flash?>(source, (previous, next) {
    if (next == null || identical(next, previous)) return;

    final l10n = AppLocalizations.of(context);
    switch (next.kind) {
      case FlashKind.saved:
        showToast(context, l10n.saved);
      case FlashKind.cancelled:
        showToast(context, l10n.cancelled, kind: AlertKind.info);
      case FlashKind.error:
        showErrorAlert(context, next.error ?? '');
    }
  });
}

/// Egy ViewModel hibáját (`state.error`) alert-párbeszédként mutatja – az űrlapoknál, ahol a hiba nem `Flash`.
/// Pl.: `listenError(ref, context, provider.select((s) => s.error));`
void listenError(WidgetRef ref, BuildContext context, ProviderListenable<Object?> source, {VoidCallback? onRetry}) {
  ref.listen<Object?>(source, (previous, next) {
    if (next == null || identical(next, previous)) return;
    showErrorAlert(context, next, onRetry: onRetry);
  });
}
