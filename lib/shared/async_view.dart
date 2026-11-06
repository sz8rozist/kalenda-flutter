import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import 'ui/app_alerts.dart';
import 'ui/empty_state.dart';
import 'ui/skeleton.dart';

/// Betöltés (helyőrző-vázlat) / hiba (érthető üzenettel és újrapróbálással) / adat – a három állapot egy helyen.
class AsyncView<T> extends StatelessWidget {
  const AsyncView({super.key, required this.value, required this.builder, required this.onRetry, this.loading});

  final AsyncValue<T> value;
  final Widget Function(BuildContext context, T data) builder;
  final VoidCallback onRetry;

  /// Egyedi betöltés-nézet (alapból kártya-lista helyőrző).
  final Widget? loading;

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () => loading ?? const ListSkeleton(),
      error: (error, _) {
        final info = describeError(context, error);
        return EmptyState(
          icon: info.icon,
          tone: Theme.of(context).colorScheme.error,
          title: info.title,
          message: info.message,
          actionLabel: AppLocalizations.of(context).retry,
          onAction: onRetry,
        );
      },
      data: (data) => builder(context, data),
    );
  }
}
