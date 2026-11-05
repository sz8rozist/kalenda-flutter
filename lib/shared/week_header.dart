import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'format.dart';

/// A heti naptár fejléce: az előző / következő hét gombjai és a hét időszaka (View-komponens, állapot nélkül).
class WeekHeader extends StatelessWidget {
  const WeekHeader({super.key, required this.weekStart, required this.onShift});

  final DateTime weekStart;
  final void Function(int weeks) onShift;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final weekEnd = weekStart.add(const Duration(days: 6));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(tooltip: l10n.previousWeek, icon: const Icon(Icons.chevron_left), onPressed: () => onShift(-1)),
        Text('${formatDate(context, weekStart)} – ${formatDate(context, weekEnd)}'),
        IconButton(tooltip: l10n.nextWeek, icon: const Icon(Icons.chevron_right), onPressed: () => onShift(1)),
      ],
    );
  }
}
