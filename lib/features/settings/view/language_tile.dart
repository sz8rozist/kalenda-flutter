import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../viewmodel/locale_viewmodel.dart';

/// Nyelvválasztó (View-komponens): rendszer / magyar / English. A választás azonnal érvényes és megmarad.
class LanguageTile extends ConsumerWidget {
  const LanguageTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final selected = ref.watch(localeProvider)?.languageCode ?? 'system';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.language_rounded),
              const SizedBox(width: 12),
              Text(l10n.languageTitle, style: Theme.of(context).textTheme.titleSmall),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<String>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(value: 'system', label: Text(l10n.languageSystem)),
                const ButtonSegment(value: 'hu', label: Text('Magyar')),
                const ButtonSegment(value: 'en', label: Text('English')),
              ],
              selected: {selected},
              onSelectionChanged: (s) => ref.read(localeProvider.notifier).select(s.first == 'system' ? null : Locale(s.first)),
            ),
          ),
        ],
      ),
    );
  }
}
