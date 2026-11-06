import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/async_view.dart';
import '../../../shared/flash.dart';
import '../../../shared/format.dart';
import '../../../shared/ui/app_alerts.dart';
import '../model/booking_models.dart';
import '../model/booking_request.dart';
import '../viewmodel/booking_form_viewmodel.dart';
import '../viewmodel/business_viewmodels.dart';

/// Egy szolgáltatás foglalása (View): munkatárs → kiegészítők → nap → időpont → adatok → megerősítés.
/// A választások és a beküldés a [BookingFormViewModel]-ben van; itt csak a szövegmezők és a megjelenítés.
class BookingPage extends ConsumerWidget {
  const BookingPage({super.key, required this.slug, required this.serviceId});

  final String slug;
  final int serviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final business = ref.watch(businessViewModelProvider(slug));

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).bookingTitle)),
      body: AsyncView<PublicBusiness>(
        value: business,
        onRetry: () => ref.invalidate(businessViewModelProvider(slug)),
        builder: (context, data) => _BookingForm(business: data, serviceId: serviceId),
      ),
    );
  }
}

class _BookingForm extends ConsumerStatefulWidget {
  const _BookingForm({required this.business, required this.serviceId});

  final PublicBusiness business;
  final int serviceId;

  @override
  ConsumerState<_BookingForm> createState() => _BookingFormState();
}

class _BookingFormState extends ConsumerState<_BookingForm> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _notes = TextEditingController();
  final _passCode = TextEditingController();

  BookingArgs get _args => (slug: widget.business.slug, serviceId: widget.serviceId);

  @override
  void dispose() {
    for (final c in [_name, _email, _phone, _notes, _passCode]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final viewModel = ref.read(bookingFormViewModelProvider(_args).notifier);
    final picked = await showDatePicker(
      context: context,
      initialDate: ref.read(bookingFormViewModelProvider(_args)).date ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) viewModel.pickDate(picked);
  }

  /// A várólistához a név és az e-mail kell (a mezők a lenti „Adataid" részben vannak).
  void _joinWaitlist() {
    if (!_formKey.currentState!.validate()) return;
    ref.read(bookingFormViewModelProvider(_args).notifier).joinWaitlist(BookingDetails(
          name: _name.text.trim(),
          email: _email.text.trim(),
          phone: _phone.text.trim(),
        ));
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    ref.read(bookingFormViewModelProvider(_args).notifier).submit(BookingDetails(
          name: _name.text.trim(),
          email: _email.text.trim(),
          phone: _phone.text.trim(),
          notes: _notes.text.trim(),
          passCode: _passCode.text.trim(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final provider = bookingFormViewModelProvider(_args);
    final state = ref.watch(provider);
    final viewModel = ref.read(provider.notifier);

    // Belépett ügyfél adatai: csak az üres mezőket töltjük elő.
    ref.listen(provider.select((s) => s.prefill), (_, profile) {
      if (profile == null) return;
      if (_name.text.isEmpty) _name.text = profile.name;
      if (_email.text.isEmpty) _email.text = profile.email;
      if (_phone.text.isEmpty) _phone.text = profile.phone ?? '';
    });

    // Várólistára feliratkozva: a szerver üzenetét mutatjuk.
    ref.listen(provider.select((s) => s.waitlistMessage), (_, message) {
      if (message == null) return;
      showToast(context, message.trim().isEmpty ? l10n.waitlistJoined : message);
    });

    // Hiányzó választás (munkatárs / nap / időpont) → figyelmeztetés; szerverhiba → alert.
    ref.listen(provider.select((s) => s.incomplete), (_, incomplete) {
      if (incomplete) showToast(context, l10n.bookingIncomplete, kind: AlertKind.warning);
    });
    listenError(ref, context, provider.select((s) => s.error));

    // Sikeres foglalás: a visszaigazoló képernyő (előlegnél itt indítható a fizetés).
    ref.listen(provider.select((s) => s.outcome), (_, outcome) {
      if (outcome != null) context.go('/booked/${outcome.manageToken}');
    });

    final service = widget.business.service(widget.serviceId);
    if (service == null) return Center(child: Text(l10n.genericError));

    final staff = widget.business.staffFor(widget.serviceId);
    final addons = widget.business.addonsByService[widget.serviceId] ?? const <PublicAddon>[];
    final query = viewModel.slotQuery;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(service.name, style: theme.textTheme.titleLarge),
          Text([
            l10n.minutes(service.durationMinutes),
            if (service.priceHuf != null) formatHuf(context, service.priceHuf!),
          ].join(' · ')),
          if (service.requiresPayment && service.depositLabel != null) ...[
            const SizedBox(height: 4),
            Text(service.depositLabel!, style: theme.textTheme.bodySmall),
          ],
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            initialValue: state.staffId,
            decoration: InputDecoration(labelText: l10n.staffLabel, border: const OutlineInputBorder()),
            items: [for (final s in staff) DropdownMenuItem(value: s.id, child: Text(s.name))],
            onChanged: viewModel.selectStaff,
            validator: (v) => v == null ? l10n.required : null,
          ),
          if (addons.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(l10n.addons, style: theme.textTheme.titleSmall),
            for (final addon in addons)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: state.addonIds.contains(addon.id),
                title: Text(addon.name),
                subtitle: Text('${formatHuf(context, addon.priceHuf)} · ${l10n.minutes(addon.durationMinutes)}'),
                onChanged: (v) => viewModel.toggleAddon(addon.id, v == true),
              ),
          ],
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _pickDate,
            icon: const Icon(Icons.event),
            label: Text(state.date == null ? l10n.pickDate : formatDate(context, state.date!)),
          ),
          if (query != null) ...[
            const SizedBox(height: 12),
            _SlotPicker(query: query, selected: state.time, onSelected: viewModel.selectTime),
            // Ha erre a napra minden időpont foglalt, és a vállalkozásnál van várólista: feliratkozás.
            if (widget.business.hasWaitlist &&
                (ref.watch(slotsViewModelProvider(query)).value?.every((s) => !s.available) ?? false))
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.notifications_active_outlined),
                  label: Text(l10n.joinWaitlist),
                  onPressed: state.busy ? null : _joinWaitlist,
                ),
              ),
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
            autofillHints: const [AutofillHints.telephoneNumber],
            decoration: InputDecoration(labelText: l10n.phone, border: const OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _notes,
            maxLines: 3,
            decoration: InputDecoration(labelText: l10n.notes, border: const OutlineInputBorder()),
          ),
          if (widget.business.hasPasses) ...[
            const SizedBox(height: 12),
            TextFormField(
              controller: _passCode,
              decoration: InputDecoration(labelText: l10n.passCode, border: const OutlineInputBorder()),
            ),
          ],
          if (widget.business.hasCampaigns)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: state.marketing,
              title: Text(l10n.marketingConsent),
              onChanged: (v) => viewModel.setMarketing(v ?? false),
            ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: state.busy ? null : _submit,
            child: state.busy
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(service.requiresPayment ? l10n.payDeposit : l10n.confirmBooking),
          ),
        ],
      ),
    );
  }
}

/// A nap időpont-rácsa: a foglalt sávok le vannak tiltva.
class _SlotPicker extends ConsumerWidget {
  const _SlotPicker({required this.query, required this.selected, required this.onSelected});

  final SlotQuery query;
  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return AsyncView<List<TimeSlot>>(
      value: ref.watch(slotsViewModelProvider(query)),
      onRetry: () => ref.invalidate(slotsViewModelProvider(query)),
      builder: (context, slots) {
        if (!slots.any((s) => s.available)) return Padding(padding: const EdgeInsets.all(8), child: Text(l10n.noSlots));

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final slot in slots)
              ChoiceChip(
                label: Text(slot.time),
                selected: selected == slot.time,
                onSelected: slot.available ? (_) => onSelected(slot.time) : null,
              ),
          ],
        );
      },
    );
  }
}
