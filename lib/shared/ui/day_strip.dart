import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import 'haptics.dart';

/// Vízszintes napválasztó a következő napokkal; a „Másik nap" a teljes naptárat nyitja.
class DayStrip extends StatelessWidget {
  const DayStrip({super.key, required this.selected, required this.onSelected, required this.onPickOther, this.days = 14});

  final DateTime? selected;
  final ValueChanged<DateTime> onSelected;
  final VoidCallback onPickOther;
  final int days;

  static bool _same(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final list = [for (var i = 0; i < days; i++) today.add(Duration(days: i))];
    final outsideStrip = selected != null && !list.any((d) => _same(d, selected!));

    return SizedBox(
      height: 76,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final day in list)
            _DayChip(
              day: day,
              selected: selected != null && _same(day, selected!),
              weekday: DateFormat.E(locale).format(day),
              onTap: () {
                Haptics.select();
                onSelected(day);
              },
            ),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 76),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                backgroundColor: outsideStrip ? theme.colorScheme.primary.withValues(alpha: 0.10) : null,
              ),
              onPressed: onPickOther,
              icon: const Icon(Icons.calendar_month_outlined),
              label: Text(outsideStrip ? DateFormat.MMMd(locale).format(selected!) : l10n.pickAnotherDate),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({required this.day, required this.selected, required this.weekday, required this.onTap});

  final DateTime day;
  final bool selected;
  final String weekday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final fg = selected ? scheme.onPrimary : scheme.onSurface;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Semantics(
        button: true,
        selected: selected,
        label: DateFormat.yMMMEd(Localizations.localeOf(context).toString()).format(day),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 56,
            decoration: BoxDecoration(
              color: selected ? scheme.primary : theme.cardTheme.color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: selected ? scheme.primary : theme.dividerColor),
            ),
            child: ExcludeSemantics(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(weekday, style: theme.textTheme.labelSmall?.copyWith(color: fg.withValues(alpha: 0.8))),
                  const SizedBox(height: 2),
                  Text(
                    '${day.day}',
                    style: theme.textTheme.titleMedium?.copyWith(color: fg, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
