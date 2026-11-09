import 'package:flutter/material.dart';

/// Az alsó navigációs sáv a design szerint: fehér, felül 1 px-es vonallal, a kijelölt fül halványkék tablettában.
/// (A név a korábbi lebegő változatból maradt; a témát a [NavigationBarThemeData] adja.)
class FloatingNavigationBar extends StatelessWidget {
  const FloatingNavigationBar({super.key, required this.selectedIndex, required this.onDestinationSelected, required this.destinations});

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<Widget> destinations;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: destinations,
        // Sok fül (vállalkozói felület: 5) esetén csak a kiválasztott fül felirata látszik, hogy minden elférjen.
        labelBehavior: destinations.length > 4
            ? NavigationDestinationLabelBehavior.onlyShowSelected
            : NavigationDestinationLabelBehavior.alwaysShow,
      ),
    );
  }
}
