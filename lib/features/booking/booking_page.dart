import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/push/push_service.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/async_view.dart';
import '../../shared/format.dart';
import '../account/account_repository.dart';
import 'booking_models.dart';
import 'booking_repository.dart';

/// Egy szolgáltatás foglalása: munkatárs → kiegészítők → nap → időpont → adatok → megerősítés.
class BookingPage extends ConsumerWidget {
  const BookingPage({super.key, required this.slug, required this.serviceId});

  final String slug;
  final int serviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final business = ref.watch(businessProvider(slug));

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).bookingTitle)),
      body: AsyncView<PublicBusiness>(
        value: business,
        onRetry: () => ref.invalidate(businessProvider(slug)),
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

  int? _staffId;
  final Set<int> _addonIds = {};
  DateTime? _date;
  String? _time;
  bool _marketing = false;
  bool _busy = false;
  String? _error;

  PublicService? get _service => widget.business.service(widget.serviceId);

  @override
  void initState() {
    super.initState();
    final staff = widget.business.staffFor(widget.serviceId);
    if (staff.length == 1) _staffId = staff.first.id;
    _prefillFromAccount();
  }

  /// Belépett ügyfélnek az adatai előre kitöltve.
  Future<void> _prefillFromAccount() async {
    if (!(ref.read(authControllerProvider).value ?? false)) return;
    try {
      final overview = await ref.read(accountOverviewProvider.future);
      if (!mounted) return;
      if (_name.text.isEmpty) _name.text = overview.profile.name;
      if (_email.text.isEmpty) _email.text = overview.profile.email;
      if (_phone.text.isEmpty) _phone.text = overview.profile.phone ?? '';
    } catch (_) {
      // Az előtöltés nem kötelező.
    }
  }

  @override
  void dispose() {
    for (final c in [_name, _email, _phone, _notes, _passCode]) {
      c.dispose();
    }
    super.dispose();
  }

  void _resetSlot() {
    _time = null;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _date = picked;
        _resetSlot();
      });
    }
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;
    if (_staffId == null || _date == null || _time == null) {
      setState(() => _error = l10n.required);
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final result = await ref.read(bookingRepositoryProvider).book(
            widget.business.slug,
            serviceId: widget.serviceId,
            staffId: _staffId!,
            date: _date!,
            time: _time!,
            name: _name.text.trim(),
            email: _email.text.trim(),
            phone: _phone.text.trim(),
            notes: _notes.text.trim(),
            passCode: _passCode.text.trim(),
            marketingConsent: widget.business.hasCampaigns ? _marketing : null,
            addonIds: _addonIds.toList(),
          );
      ref.invalidate(accountOverviewProvider);
      // Az első foglalás után kérünk értesítés-engedélyt (nem indításkor).
      unawaited(ref.read(pushServiceProvider).enableAfterBooking());
      if (!mounted) return;
      if (result.requiresPayment && result.checkoutUrl != null) {
        // Előleg: a Stripe Checkout böngészőben nyílik, a fizetés után a foglalás-kezelő oldalra tér vissza.
        await launchUrl(Uri.parse(result.checkoutUrl!), mode: LaunchMode.externalApplication);
      }
      if (!mounted) return;
      context.go('/booked/${result.manageToken}');
    } catch (e) {
      if (mounted) setState(() => _error = errorText(context, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final service = _service;
    if (service == null) return Center(child: Text(l10n.genericError));

    final staff = widget.business.staffFor(widget.serviceId);
    final addons = widget.business.addonsByService[widget.serviceId] ?? const <PublicAddon>[];

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
            initialValue: _staffId,
            decoration: InputDecoration(labelText: l10n.staffLabel, border: const OutlineInputBorder()),
            items: [for (final s in staff) DropdownMenuItem(value: s.id, child: Text(s.name))],
            onChanged: (v) => setState(() {
              _staffId = v;
              _resetSlot();
            }),
            validator: (v) => v == null ? l10n.required : null,
          ),
          if (addons.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(l10n.addons, style: theme.textTheme.titleSmall),
            for (final addon in addons)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _addonIds.contains(addon.id),
                title: Text(addon.name),
                subtitle: Text('${formatHuf(context, addon.priceHuf)} · ${l10n.minutes(addon.durationMinutes)}'),
                onChanged: (v) => setState(() {
                  v == true ? _addonIds.add(addon.id) : _addonIds.remove(addon.id);
                  _resetSlot();
                }),
              ),
          ],
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _pickDate,
            icon: const Icon(Icons.event),
            label: Text(_date == null ? l10n.pickDate : formatDate(context, _date!)),
          ),
          if (_staffId != null && _date != null) ...[
            const SizedBox(height: 12),
            _SlotPicker(
              query: (
                slug: widget.business.slug,
                serviceId: widget.serviceId,
                staffId: _staffId!,
                date: _date!,
                addonIds: _addonIds.toList()..sort(),
              ),
              selected: _time,
              onSelected: (t) => setState(() => _time = t),
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
              value: _marketing,
              title: Text(l10n.marketingConsent),
              onChanged: (v) => setState(() => _marketing = v ?? false),
            ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _busy ? null : _submit,
            child: _busy
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
      value: ref.watch(slotsProvider(query)),
      onRetry: () => ref.invalidate(slotsProvider(query)),
      builder: (context, slots) {
        final free = slots.where((s) => s.available).toList();
        if (free.isEmpty) return Padding(padding: const EdgeInsets.all(8), child: Text(l10n.noSlots));

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
