import 'package:flutter/material.dart';

/// Villogó (shimmer) hatású helyőrző a betöltés alatt – a pörgő kör helyett a tartalom alakját mutatja.
class Shimmer extends StatefulWidget {
  const Shimmer({super.key, required this.child});

  final Widget child;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06);
    final highlight = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.14);

    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) => ShaderMask(
        blendMode: BlendMode.srcATop,
        shaderCallback: (bounds) => LinearGradient(
          colors: [base, highlight, base],
          stops: const [0.1, 0.5, 0.9],
          begin: Alignment(-1.5 + _controller.value * 3, -0.3),
          end: Alignment(-0.5 + _controller.value * 3, 0.3),
        ).createShader(bounds),
        child: child,
      ),
    );
  }
}

/// Egy szürke, lekerekített helyőrző-blokk.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({super.key, this.width, this.height = 16, this.radius = 8});

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(radius)),
      );
}

/// Kártya-lista alakú helyőrző: a legtöbb listás képernyő betöltés-állapota.
class ListSkeleton extends StatelessWidget {
  const ListSkeleton({super.key, this.items = 5});

  final int items;

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: ListView.builder(
        // shrinkWrap: a vázlat bárhová beágyazható (ListView-ba, Column-ba) anélkül, hogy a magassága határtalan lenne.
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        itemCount: items,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: const Row(
              children: [
                SkeletonBox(width: 48, height: 48, radius: 14),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(height: 14, width: 180),
                      SizedBox(height: 10),
                      SkeletonBox(height: 12, width: 120),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
