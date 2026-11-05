import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/async_view.dart';
import '../../../shared/format.dart';
import '../../booking/model/booking_models.dart';
import '../../booking/viewmodel/business_viewmodels.dart';
import '../../staff/viewmodel/staff_session_viewmodel.dart';
import '../model/owner_models.dart';
import '../viewmodel/owner_booking_viewmodel.dart';

/// Foglalás felvitele a vállalkozó által (View). A szolgáltatások és a munkatársak a vállalkozás nyilvános adatlapjáról
/// jönnek; a választásokat és a beküldést az [OwnerBookingViewModel] kezeli.
class OwnerBookingPage extends ConsumerWidget {
  const OwnerBookingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(staffSessionProvider).value;
    final businessId = user?.businessId;
    final slug = user?.businessSlug;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.ownerNewBooking)),
      body: (businessId == null || slug == null)
          ? Center(child: Text(l10n.ownerNoBusiness))
          : AsyncView<PublicBusiness>(
              value: ref.watch(businessViewModelProvider(slug)),
              onRetry: () => ref.invalidate(businessViewModelProvider(slug)),
              builder: (context, business) => _Form(businessId: businessId, business: business),
            ),
    );
  }
}

class _Form extends ConsumerStatefulWidget {
  const _Form({required this.businessId, required this.business});

  final int businessId;
  final PublicBusiness business;

  @override
  ConsumerState<_Form> createState() => _FormState();
}

class _FormState extends ConsumerState<_Form> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _notes = TextEditingController();

  @override
  void dispose() {
    for (final c in [_name, _email, _phone, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final provider = ownerBookingProvider(widget.businessId);
    final picked = await showDatePicker(
      context: context,
      initialDate: ref.read(provider).date ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) ref.read(provider.notifier).pickDate(picked);
  }

  void _submit() {
    final state = ref.read(ownerBookingProvider(widget.businessId));
    // Új ügyfélnél a név kötelező; meglévőnél az ügyfél kiválasztása elég.
    if (state.customerId == null && !_formKey.currentState!.validate()) return;
    ref.read(ownerBookingProvider(widget.businessId).notifier).submit(OwnerBookingDetails(
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
    final provider = ownerBookingProvider(widget.businessId);
    final state = ref.watch(provider);
    final viewModel = ref.read(provider.notifier);

    // Sikeres felvitel: vissza a naptárhoz, jelzéssel.
    ref.listen(provider.select((s) => s.created), (_, created) {
      if (!created) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.saved)));
      context.pop();
    });

    final business = widget.business;
    final staff = state.serviceId == null ? const <PublicStaff>[] : business.staffFor(state.serviceId!);
    final customers = ref.watch(customerOptionsProvider(widget.businessId));
    final query = viewModel.slotQuery;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<int>(
            initialValue: state.serviceId,
            decoration: InputDecoration(labelText: l10n.serviceLabel, border: const OutlineInputBorder()),
            items: [for (final s in business.services) DropdownMenuItem(value: s.id, child: Text(s.name))],
            onChanged: viewModel.selectService,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            key: ValueKey('staff-${state.serviceId}'),
            initialValue: state.staffId,
            decoration: InputDecoration(labelText: l10n.staffLabel, border: const OutlineInputBorder()),
            items: [for (final s in staff) DropdownMenuItem(value: s.id, child: Text(s.name))],
            onChanged: viewModel.selectStaff,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _pickDate,
            icon: const Icon(Icons.event),
            label: Text(state.date == null ? l10n.pickDate : formatDate(context, state.date!)),
          ),
          if (query != null) ...[
            const SizedBox(height: 12),
            _Slots(query: query, selected: state.time, onSelected: viewModel.selectTime),
          ],
          const SizedBox(height: 24),
          Text(l10n.ownerCustomerLabel, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          customers.when(
            loading: () => const LinearProgressIndicator(),
            error: (_, _) => const SizedBox.shrink(),
            data: (options) => DropdownButtonFormField<int?>(
              initialValue: state.customerId,
              decoration: InputDecoration(border: const OutlineInputBorder(), hintText: l10n.newCustomerOption),
              items: [
                DropdownMenuItem<int?>(value: null, child: Text(l10n.newCustomerOption)),
                for (final c in options) DropdownMenuItem<int?>(value: c.id, child: Text(c.name)),
              ],
              onChanged: viewModel.selectCustomer,
            ),
          ),
          if (state.customerId == null) ...[
            const SizedBox(height: 12),
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(labelText: l10n.name, border: const OutlineInputBorder()),
              validator: (v) => (v == null || v.trim().isEmpty) ? l10n.required : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: l10n.email, border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: l10n.phone, border: const OutlineInputBorder()),
            ),
          ],
          const SizedBox(height: 12),
          TextFormField(
            controller: _notes,
            maxLines: 3,
            decoration: InputDecoration(labelText: l10n.notes, border: const OutlineInputBorder()),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.sendEmailLabel),
            value: state.sendEmail,
            onChanged: viewModel.setSendEmail,
          ),
          if (state.incomplete || state.error != null) ...[
            const SizedBox(height: 8),
            Text(
              state.incomplete ? l10n.required : errorText(context, state.error!),
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: state.busy ? null : _submit,
            child: state.busy
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(l10n.ownerCreateBooking),
          ),
        ],
      ),
    );
  }
}

/// A nap időpont-rácsa: a foglalt sávok le vannak tiltva.
class _Slots extends ConsumerWidget {
  const _Slots({required this.query, required this.selected, required this.onSelected});

  final OwnerSlotQuery query;
  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return AsyncView<List<TimeSlot>>(
      value: ref.watch(ownerSlotsProvider(query)),
      onRetry: () => ref.invalidate(ownerSlotsProvider(query)),
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
