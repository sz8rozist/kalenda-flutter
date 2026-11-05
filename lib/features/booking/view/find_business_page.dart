import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../viewmodel/business_viewmodels.dart';

/// Vállalkozás megnyitása az azonosítója vagy a foglalási linkje alapján (View).
/// (Később: QR-kód beolvasás és univerzális link.)
class FindBusinessPage extends ConsumerStatefulWidget {
  const FindBusinessPage({super.key});

  @override
  ConsumerState<FindBusinessPage> createState() => _FindBusinessPageState();
}

class _FindBusinessPageState extends ConsumerState<FindBusinessPage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _open() {
    final slug = ref.read(findBusinessViewModelProvider.notifier).resolveSlug(_controller.text);
    if (slug != null) context.push('/b/$slug');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.findBusinessTitle)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(l10n.findBusinessIntro),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.go,
            onSubmitted: (_) => _open(),
            decoration: InputDecoration(labelText: l10n.businessSlug, border: const OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          FilledButton(onPressed: _open, child: Text(l10n.open)),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.qr_code_scanner),
            label: Text(l10n.scanQr),
            onPressed: () => context.push('/scan'),
          ),
        ],
      ),
    );
  }
}
