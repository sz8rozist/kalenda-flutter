import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/async_view.dart';
import '../../../shared/flash.dart';
import '../../../shared/format.dart';
import '../model/booking_models.dart';
import '../viewmodel/business_viewmodels.dart';
import '../viewmodel/pass_purchase_viewmodel.dart';

/// Bérlet / ajándékutalvány vásárlása (View). A fizetés a Stripe oldalán, a böngészőben történik; utána a megvásárolt
/// bérlet a „Fiókom" fülön jelenik meg (a vásárlás e-mail-címével belépve).
class PassPurchasePage extends ConsumerWidget {
  const PassPurchasePage({super.key, required this.slug, required this.passTypeId});

  final String slug;
  final int passTypeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).passPurchaseTitle)),
      body: AsyncView<PublicBusiness>(
        value: ref.watch(businessViewModelProvider(slug)),
        onRetry: () => ref.invalidate(businessViewModelProvider(slug)),
        builder: (context, business) {
          final type = business.passTypes.where((t) => t.id == passTypeId).firstOrNull;
          if (type == null) return Center(child: Text(AppLocalizations.of(context).genericError));
          return _Form(slug: slug, type: type);
        },
      ),
    );
  }
}

class _Form extends ConsumerStatefulWidget {
  const _Form({required this.slug, required this.type});

  final String slug;
  final PassType type;

  @override
  ConsumerState<_Form> createState() => _FormState();
}

class _FormState extends ConsumerState<_Form> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _recipientName = TextEditingController();
  final _recipientEmail = TextEditingController();
  final _senderName = TextEditingController();
  final _message = TextEditingController();

  PassPurchaseArgs get _args => (slug: widget.slug, passTypeId: widget.type.id);

  @override
  void dispose() {
    for (final c in [_email, _recipientName, _recipientEmail, _senderName, _message]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final t = widget.type;
    final provider = passPurchaseViewModelProvider(_args);
    final state = ref.watch(provider);
    final viewModel = ref.read(provider.notifier);
    listenError(ref, context, provider.select((s) => s.error));

    // A fizetési oldal megnyitása a böngészőben.
    ref.listen(provider.select((s) => s.checkoutUrl), (_, url) {
      if (url != null) launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    });

    final details = [
      if (t.serviceName != null) t.serviceName!,
      if (t.sessionsCount != null) l10n.sessionsCountLabel(t.sessionsCount!),
      if (t.valueHuf != null) l10n.valueLabel(formatHuf(context, t.valueHuf!)),
      l10n.validityDaysLabel(t.validityDays),
    ].join(' · ');

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(t.name, style: theme.textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(details),
          const SizedBox(height: 4),
          Text(formatHuf(context, t.priceHuf), style: theme.textTheme.titleMedium),
          const SizedBox(height: 24),
          TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            decoration: InputDecoration(labelText: l10n.passBuyerEmail, border: const OutlineInputBorder()),
            validator: (v) {
              final text = v?.trim() ?? '';
              if (text.isEmpty) return l10n.required;
              return text.contains('@') ? null : l10n.invalidEmail;
            },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.passGift),
            value: state.gift,
            onChanged: viewModel.setGift,
          ),
          if (state.gift) ...[
            TextFormField(
              controller: _recipientName,
              decoration: InputDecoration(labelText: l10n.recipientName, border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _recipientEmail,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: l10n.recipientEmail, border: const OutlineInputBorder()),
              validator: (v) => (v == null || !v.contains('@')) ? l10n.invalidEmail : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _senderName,
              decoration: InputDecoration(labelText: l10n.senderName, border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _message,
              maxLines: 3,
              decoration: InputDecoration(labelText: l10n.giftMessage, border: const OutlineInputBorder()),
            ),
          ],
          if (state.checkoutUrl != null) ...[
            const SizedBox(height: 12),
            Text(l10n.passAfterPayment),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: state.busy
                ? null
                : () {
                    if (!_formKey.currentState!.validate()) return;
                    viewModel.purchase(
                      email: _email.text.trim(),
                      recipientName: _recipientName.text.trim(),
                      recipientEmail: _recipientEmail.text.trim(),
                      senderName: _senderName.text.trim(),
                      giftMessage: _message.text.trim(),
                    );
                  },
            child: Text(l10n.passBuy),
          ),
        ],
      ),
    );
  }
}
