import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Lebegő, lekerekített alsó navigációs sáv: a tartalom fölött „úszik", lágy árnyékkal – a Material NavigationBar köré építve.
class FloatingNavigationBar extends StatelessWidget {
  const FloatingNavigationBar({super.key, required this.selectedIndex, required this.onDestinationSelected, required this.destinations});

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<Widget> destinations;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Material(
          color: theme.colorScheme.surface,
          elevation: dark ? 0 : 10,
          shadowColor: const Color(0x332563EB),
          surfaceTintColor: Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimens.radiusLarge),
          clipBehavior: Clip.antiAlias,
          child: NavigationBarTheme(
            data: NavigationBarTheme.of(context).copyWith(
              labelPadding: const EdgeInsets.only(top: 2),
              labelTextStyle: WidgetStateProperty.resolveWith(
                (states) => theme.textTheme.labelSmall?.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  height: 1.1,
                  color: states.contains(WidgetState.selected) ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                ),
              ),
                theme.textTheme.labelSmall?.copyWith(fontSize: 11, fontWeight: FontWeight.w600, height: 1.1),
              ),
              indicatorShape: const StadiumBorder(),
            ),
            child: NavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              destinations: destinations,
              backgroundColor: Colors.transparent,
              height: 72,
              // Sok fül (vállalkozói felület: 5) esetén csak a kiválasztott fül felirata látszik, hogy minden elférjen.
              labelBehavior: destinations.length > 4
                  ? NavigationDestinationLabelBehavior.onlyShowSelected
                  : NavigationDestinationLabelBehavior.alwaysShow,
            ),
          ),
        ),
      ),
    );
  }
}
