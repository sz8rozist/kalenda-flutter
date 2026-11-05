import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../l10n/app_localizations.dart';
import '../viewmodel/business_viewmodels.dart';

/// A vállalkozás foglalási QR-kódjának beolvasása (View): a kamera képét mutatja, az értelmezés a [ScanViewModel]-ben van.
class ScanQrPage extends ConsumerWidget {
  const ScanQrPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    // Az első érvényes kód után megnyílik a vállalkozás oldala (a beolvasó helyére).
    ref.listen(scanViewModelProvider, (_, slug) {
      if (slug != null) context.pushReplacement('/b/$slug');
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.scanQrTitle)),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              final value = capture.barcodes.isEmpty ? null : capture.barcodes.first.rawValue;
              ref.read(scanViewModelProvider.notifier).onCode(value);
            },
            errorBuilder: (context, error) => Center(
              child: Padding(padding: const EdgeInsets.all(24), child: Text(l10n.cameraUnavailable, textAlign: TextAlign.center)),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              color: Colors.black54,
              padding: const EdgeInsets.all(16),
              child: Text(l10n.scanQrHint, style: const TextStyle(color: Colors.white), textAlign: TextAlign.center),
            ),
          ),
        ],
      ),
    );
  }
}
