import 'package:flutter/material.dart';

import 'haptics.dart';

/// Színválasztó: előre megadott színek kerek jelölőkkel. A szín `#rrggbb` szöveg (ahogy az API várja).
class ColorChoice extends StatelessWidget {
  const ColorChoice({super.key, required this.value, required this.onChanged});

  static const palette = ['#3b82f6', '#6366f1', '#8b5cf6', '#ec4899', '#ef4444', '#f97316', '#eab308', '#22c55e', '#14b8a6', '#64748b'];

  final String value;
  final ValueChanged<String> onChanged;

  static Color parse(String hex) {
    final clean = hex.replaceFirst('#', '');
    final parsed = int.tryParse(clean, radix: 16);
    return parsed == null || clean.length != 6 ? const Color(0xFF3B82F6) : Color(0xFF000000 | parsed);
  }

  @override
  Widget build(BuildContext context) {
    final colors = palette.contains(value.toLowerCase()) ? palette : [value, ...palette];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final hex in colors)
          Semantics(
            button: true,
            selected: hex.toLowerCase() == value.toLowerCase(),
            label: hex,
            child: GestureDetector(
              onTap: () {
                Haptics.select();
                onChanged(hex);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: parse(hex),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: hex.toLowerCase() == value.toLowerCase() ? Theme.of(context).colorScheme.onSurface : Colors.transparent,
                    width: 3,
                  ),
                ),
                child: hex.toLowerCase() == value.toLowerCase() ? const Icon(Icons.check, size: 18, color: Colors.white) : null,
              ),
            ),
          ),
      ],
    );
  }
}
