import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'skeleton.dart';

/// Hálózati kép gyorsítótárral, betöltés közben vázlattal, hibánál (vagy ha nincs URL) a megadott pótlóval.
class AppImage extends StatelessWidget {
  const AppImage({super.key, required this.url, required this.fallback, this.fit = BoxFit.cover});

  final String? url;
  final Widget fallback;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final url = this.url;
    if (url == null || url.isEmpty) return fallback;

    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      fadeInDuration: const Duration(milliseconds: 250),
      placeholder: (_, _) => const Shimmer(
        child: SkeletonBox(width: double.infinity, height: double.infinity, radius: 0),
      ),
      errorWidget: (_, _, _) => fallback,
    );
  }
}
