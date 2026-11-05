import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import 'format.dart';

/// Betöltés / hiba (újrapróbálással) / adat – a három állapot egy helyen.
class AsyncView<T> extends StatelessWidget {
  const AsyncView({super.key, required this.value, required this.builder, required this.onRetry});

  final AsyncValue<T> value;
  final Widget Function(BuildContext context, T data) builder;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(errorText(context, error), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              OutlinedButton(onPressed: onRetry, child: Text(AppLocalizations.of(context).retry)),
            ],
          ),
        ),
      ),
      data: (data) => builder(context, data),
    );
  }
}
