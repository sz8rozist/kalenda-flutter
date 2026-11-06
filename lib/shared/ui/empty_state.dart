import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Üres / hiba állapot: nagy ikon lágy körrel, cím, magyarázat és opcionális gomb – a „nincs adat" ne legyen puszta szöveg.
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, this.message, this.actionLabel, this.onAction, this.tone});

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Az ikon színe (alapból a márka kékje).
  final Color? tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = tone ?? theme.colorScheme.primary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.10), shape: BoxShape.circle),
              child: Icon(icon, size: 44, color: color),
            ),
            const SizedBox(height: 20),
            Text(title, style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              FilledButton.tonal(onPressed: onAction, style: FilledButton.styleFrom(minimumSize: const Size(160, 48)), child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

/// Üres-állapot kártyaként, listák közé (pl. „nincs közelgő foglalás").
class EmptyNote extends StatelessWidget {
  const EmptyNote(this.text, {super.key, this.icon = Icons.inbox_outlined});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimens.radius),
        color: theme.colorScheme.primary.withValues(alpha: 0.05),
      ),
      child: Column(
        children: [
          Icon(icon, color: theme.colorScheme.primary.withValues(alpha: 0.7), size: 28),
          const SizedBox(height: 8),
          Text(text, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
