import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderListenable;

import '../core/viewmodel/action_state.dart';
import '../l10n/app_localizations.dart';
import 'format.dart';

/// A ViewModel visszajelzését (mentve / lemondva / hiba) snackbarként mutatja. A `build`-ben hívandó, pl.:
/// `listenFlash(ref, context, actionsProvider.select((s) => s.flash));`
void listenFlash(WidgetRef ref, BuildContext context, ProviderListenable<Flash?> source) {
  ref.listen<Flash?>(source, (previous, next) {
    if (next == null || identical(next, previous)) return;

    final l10n = AppLocalizations.of(context);
    final text = switch (next.kind) {
      FlashKind.saved => l10n.saved,
      FlashKind.cancelled => l10n.cancelled,
      FlashKind.error => errorText(context, next.error ?? ''),
    };
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  });
}
