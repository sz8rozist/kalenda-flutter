import 'package:flutter/material.dart';

/// Egy űrlap-szakasz számozott fejléccel („1 Kivel és mit?"), hogy a hosszú foglalási űrlap lépésekre essen szét.
class StepSection extends StatelessWidget {
  const StepSection({super.key, required this.number, required this.title, required this.child});

  final int number;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 13,
                  backgroundColor: theme.colorScheme.primary,
                  child: Text(
                    '$number',
                    style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(width: 10),
                Text(title, style: theme.textTheme.titleMedium),
              ],
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
