import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../shared/format.dart';

/// Vállalkozás megnyitása az azonosítója vagy a foglalási linkje alapján.
/// (Később: QR-kód beolvasás és univerzális link.)
class FindBusinessPage extends StatefulWidget {
  const FindBusinessPage({super.key});

  @override
  State<FindBusinessPage> createState() => _FindBusinessPageState();
}

class _FindBusinessPageState extends State<FindBusinessPage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _open() {
    final slug = slugFromInput(_controller.text);
    if (slug.isNotEmpty) context.push('/b/$slug');
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
        ],
      ),
    );
  }
}
