import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/async_view.dart';
import '../../../shared/flash.dart';
import '../../../shared/format.dart';
import '../model/booking_models.dart';
import '../model/booking_request.dart';
import '../viewmodel/business_viewmodels.dart';
import '../viewmodel/group_session_viewmodels.dart';

/// Jelentkezés egy csoportos alkalomra (View): az alkalom adatai és a jelentkezési űrlap.
class GroupBookingPage extends ConsumerWidget {
  const GroupBookingPage({super.key, required this.slug, required this.sessionId});

  final String slug;
  final int sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).groupSessionTitle)),
      body: AsyncView<List<GroupSession>>(
        value: ref.watch(groupSessionsViewModelProvider(slug)),
        onRetry: () => ref.invalidate(groupSessionsViewModelProvider(slug)),
        builder: (context, sessions) {
          final session = sessions.where((s) => s.id == sessionId).firstOrNull;
          if (session == null) return Center(child: Text(AppLocalizations.of(context).genericError));
          return _Form(slug: slug, session: session);
        },
      ),
    );
  }
}

class _Form extends ConsumerStatefulWidget {
  const _Form({required this.slug, required this.session});

  final String slug;
  final GroupSession session;

  @override
  ConsumerState<_Form> createState() => _FormState();
}

class _FormState extends ConsumerState<_Form> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _notes = TextEditingController();

  GroupBookingArgs get _args => (slug: widget.slug, sessionId: widget.session.id);

  @override
  void dispose() {
    for (final c in [_name, _email, _phone, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    ref.read(groupBookingViewModelProvider(_args).notifier).submit(BookingDetails(
          name: _name.text.trim(),
          email: _email.text.trim(),
          phone: _phone.text.trim(),
          notes: _notes.text.trim(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final s = widget.session;
    final provider = groupBookingViewModelProvider(_args);
    final state = ref.watch(provider);
    listenError(ref, context, provider.select((s) => s.error));
    final hasCampaigns = ref.watch(businessViewModelProvider(widget.slug)).value?.hasCampaigns ?? false;

    ref.listen(provider.select((x) => x.manageToken), (_, token) {
      if (token != null) context.go('/booked/$token');
    });

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(s.serviceName, style: theme.textTheme.titleLarge),
          const SizedBox(height: 4),
          Text('${formatDateTime(context, s.startsAt)} – ${formatTime(context, s.endsAt)}'),
          if (s.staffName != null) Text(s.staffName!),
          Text([
            l10n.placesLeft(s.placesLeft),
            if (s.priceHuf != null) formatHuf(context, s.priceHuf!),
          ].join(' · ')),
          if (s.requiresPayment && s.depositLabel != null) Text(s.depositLabel!, style: theme.textTheme.bodySmall),
          if (s.notes != null && s.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(s.notes!, style: theme.textTheme.bodySmall),
          ],
          const SizedBox(height: 24),
          Text(l10n.yourDetails, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          TextFormField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            autofillHints: const [AutofillHints.name],
            decoration: InputDecoration(labelText: l10n.name, border: const OutlineInputBorder()),
            validator: (v) => (v == null || v.trim().isEmpty) ? l10n.required : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            decoration: InputDecoration(labelText: l10n.email, border: const OutlineInputBorder()),
            validator: (v) {
              final text = v?.trim() ?? '';
              if (text.isEmpty) return l10n.required;
              return text.contains('@') ? null : l10n.invalidEmail;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(labelText: l10n.phone, border: const OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _notes,
            maxLines: 3,
            decoration: InputDecoration(labelText: l10n.notes, border: const OutlineInputBorder()),
          ),
          if (hasCampaigns)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: state.marketing,
              title: Text(l10n.marketingConsent),
              onChanged: (v) => ref.read(provider.notifier).setMarketing(v ?? false),
            ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: (state.busy || s.full) ? null : _submit,
            child: state.busy
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(s.full ? l10n.sessionFull : l10n.joinSession),
          ),
        ],
      ),
    );
  }
}
