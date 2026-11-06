import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../format.dart';

/// Állapot-jelvény: a szín jelzi az állapotot (foglalás, számla, szabadság), a felirat lokalizált.
class StatusChip extends StatelessWidget {
  const StatusChip(this.status, {super.key, this.label});

  final String status;

  /// Egyedi felirat (alapból az állapot lokalizált neve).
  final String? label;

  static Color colorOf(String status) => switch (status) {
    'confirmed' || 'approved' || 'paid' || 'completed' => AppColors.success,
    'pending' || 'unpaid' => AppColors.warning,
    'cancelled' || 'no_show' || 'rejected' || 'overdue' => AppColors.danger,
    _ => AppColors.neutral,
  };

  @override
  Widget build(BuildContext context) {
    final color = colorOf(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
      child: Text(
        label ?? statusLabel(context, status),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

/// Dátum-blokk a listákhoz: nap száma és a hónap rövidítése egy lekerekített négyzetben.
class DateBadge extends StatelessWidget {
  const DateBadge(this.date, {super.key});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final month = _month(locale, date);

    return Semantics(
      label: DateFormat.MMMd(locale).format(date),
      child: ExcludeSemantics(
        child: Container(
          width: 52,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(14)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${date.day}',
                style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w800),
              ),
              Text(month, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary)),
            ],
          ),
        ),
      ),
    );
  }

  static String _month(String locale, DateTime d) {
    const hu = ['jan', 'feb', 'már', 'ápr', 'máj', 'jún', 'júl', 'aug', 'szep', 'okt', 'nov', 'dec'];
    const en = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return (locale.startsWith('hu') ? hu : en)[d.month - 1];
  }
}
