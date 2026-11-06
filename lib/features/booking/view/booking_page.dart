import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/async_view.dart';
import '../../../shared/flash.dart';
import '../../../shared/format.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/ui/app_alerts.dart';
import '../../../shared/ui/app_image.dart';
import '../../../shared/ui/day_strip.dart';
import '../../../shared/ui/haptics.dart';
import '../../../shared/ui/step_section.dart';
import '../model/booking_models.dart';
import '../model/booking_request.dart';
import '../viewmodel/booking_form_viewmodel.dart';
import '../viewmodel/business_viewmodels.dart';

/// Egy szolgáltatás foglalása (View): munkatárs → kiegészítők → nap → időpont → adatok → megerősítés.
/// A választások és a beküldés a [BookingFormViewModel]-ben van; itt csak a szövegmezők és a megjelenítés.
class BookingPage extends ConsumerWidget {
  const BookingPage({super.key, required this.slug, required this.serviceId, this.rental = false, this.preferredStaff});

  final String slug;
  final int serviceId;

  /// Bérelhető szolgáltatás foglalása (az időtartam is választható).
  final bool rental;

  /// Újrafoglalásnál az előző szakember neve (előre kiválasztjuk, ha még dolgozik a szolgáltatásnál).
  final String? preferredStaff;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final business = ref.watch(businessViewModelProvider(slug));

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).bookingTitle)),
      body: AsyncView<PublicBusiness>(
        value: business,
        onRetry: () => ref.invalidate(businessViewModelProvider(slug)),
        builder: (context, data) => rental
            ? _RentalLoader(business: data, serviceId: serviceId)
            : _BookingForm(business: data, serviceId: serviceId, preferredStaff: preferredStaff),
      ),
    );
  }
}

class _BookingForm extends ConsumerStatefulWidget {
  const _BookingForm({required this.business, required this.serviceId, this.rental, this.preferredStaff});

  final PublicBusiness business;
  final int serviceId;

  final PublicRental? rental;
  final String? preferredStaff;

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

  @override
  void initState() {
    super.initState();
    final preferred = widget.preferredStaff;
    if (preferred != null) {
      Future.microtask(() {
        if (!mounted) return;
        final match = widget.business
            .staffFor(widget.serviceId)
            .where((s) => s.name.trim().toLowerCase() == preferred.trim().toLowerCase())
            .firstOrNull;
        final viewModel = ref.read(bookingFormViewModelProvider(_args).notifier);
        if (match != null && ref.read(bookingFormViewModelProvider(_args)).staffId == null) viewModel.selectStaff(match.id);
      });
    }
    final rental = widget.rental;
    if (rental != null) {
      Future.microtask(() {
        if (mounted) ref.read(bookingFormViewModelProvider(_args).notifier).ensureDuration(rental.minMinutes);
      });
    }
  }

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
    ref
        .read(bookingFormViewModelProvider(_args).notifier)
        .joinWaitlist(BookingDetails(name: _name.text.trim(), email: _email.text.trim(), phone: _phone.text.trim()));
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    ref
        .read(bookingFormViewModelProvider(_args).notifier)
        .submit(
          BookingDetails(
            name: _name.text.trim(),
            email: _email.text.trim(),
            phone: _phone.text.trim(),
            notes: _notes.text.trim(),
            passCode: _passCode.text.trim(),
          ),
        );
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

    final rental = widget.rental;
    final minutes = state.durationMinutes ?? rental?.minMinutes ?? 0;
    final service = rental == null
        ? widget.business.service(widget.serviceId)
        : PublicService(
            id: rental.id,
            name: rental.name,
            durationMinutes: minutes,
            priceHuf: rental.priceFor(minutes),
            requiresPayment: rental.requiresPayment,
            depositLabel: rental.depositLabel,
          );
    if (service == null) return Center(child: Text(l10n.genericError));

    final staff = rental == null
        ? widget.business.staffFor(widget.serviceId)
        : [
            for (final r in rental.resources) PublicStaff(id: r.id, name: r.name, serviceIds: [rental.id], photoUrl: r.photoUrl),
          ];
    final addons = widget.business.addonsByService[widget.serviceId] ?? const <PublicAddon>[];
    final query = viewModel.slotQuery;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(AppDimens.pagePadding),
        children: [
          // A kiválasztott szolgáltatás összefoglalója.
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(gradient: AppColors.heroGradient, borderRadius: BorderRadius.circular(AppDimens.radius)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(service.name, style: theme.textTheme.titleLarge?.copyWith(color: Colors.white)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.schedule_rounded, size: 16, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(l10n.minutes(service.durationMinutes), style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                    if (service.priceHuf != null) ...[
                      const SizedBox(width: 14),
                      Text(
                        formatHuf(context, service.priceHuf!),
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ],
                ),
                if (service.requiresPayment && service.depositLabel != null) ...[
                  const SizedBox(height: 6),
                  Text(service.depositLabel!, style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70)),
                ],
              ],
            ),
          ),
          StepSection(
            number: 1,
            title: l10n.stepStaff,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (rental != null) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final d in rental.durations)
                        ChoiceChip(
                          label: Text(l10n.minutes(d)),
                          selected: minutes == d,
                          onSelected: (_) {
                            Haptics.select();
                            viewModel.setDuration(d);
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                _StaffPicker(staff: staff, selected: state.staffId, onSelected: viewModel.selectStaff),
                if (addons.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(l10n.addons, style: theme.textTheme.titleSmall),
                  for (final addon in addons)
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: state.addonIds.contains(addon.id),
                      title: Text(addon.name),
                      subtitle: Text('${formatHuf(context, addon.priceHuf)} · ${l10n.minutes(addon.durationMinutes)}'),
                      onChanged: (v) {
                        Haptics.select();
                        viewModel.toggleAddon(addon.id, v == true);
                      },
                    ),
                ],
              ],
            ),
          ),
          StepSection(
            number: 2,
            title: l10n.stepDateTime,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DayStrip(selected: state.date, onSelected: viewModel.pickDate, onPickOther: _pickDate),
                if (query != null) ...[
                  const SizedBox(height: 16),
                  _SlotPicker(query: query, selected: state.time, onSelected: viewModel.selectTime),
                  // Ha erre a napra minden időpont foglalt, és a vállalkozásnál van várólista: feliratkozás.
                  if (widget.business.hasWaitlist && (ref.watch(slotsViewModelProvider(query)).value?.every((s) => !s.available) ?? false))
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.notifications_active_outlined),
                        label: Text(l10n.joinWaitlist),
                        onPressed: state.busy ? null : _joinWaitlist,
                      ),
                    ),
                ],
              ],
            ),
          ),
          StepSection(
            number: 3,
            title: l10n.stepDetails,
            child: Column(
              children: [
                TextFormField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  autofillHints: const [AutofillHints.name],
                  decoration: InputDecoration(labelText: l10n.name, prefixIcon: const Icon(Icons.person_outline_rounded)),
                  validator: (v) => (v == null || v.trim().isEmpty) ? l10n.required : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  decoration: InputDecoration(labelText: l10n.email, prefixIcon: const Icon(Icons.mail_outline_rounded)),
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
                  decoration: InputDecoration(labelText: l10n.phone, prefixIcon: const Icon(Icons.phone_outlined)),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notes,
                  maxLines: 3,
                  decoration: InputDecoration(labelText: l10n.notes, prefixIcon: const Icon(Icons.notes_rounded)),
                ),
                if (widget.business.hasPasses) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passCode,
                    decoration: InputDecoration(labelText: l10n.passCode, prefixIcon: const Icon(Icons.confirmation_number_outlined)),
                  ),
                ],
                if (widget.business.hasCampaigns)
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: state.marketing,
                    title: Text(l10n.marketingConsent),
                    onChanged: (v) => viewModel.setMarketing(v ?? false),
                  ),
              ],
            ),
          ),
          FilledButton(
            onPressed: state.busy ? null : _submit,
            child: state.busy
                ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                : Text(service.requiresPayment ? l10n.payDeposit : l10n.confirmBooking),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// A szakember kiválasztása: vízszintes kártyák fotóval (vagy monogrammal).
class _StaffPicker extends StatelessWidget {
  const _StaffPicker({required this.staff, required this.selected, required this.onSelected});

  final List<PublicStaff> staff;
  final int? selected;
  final ValueChanged<int?> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 112,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: staff.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final s = staff[i];
          final isSelected = s.id == selected;
          return Semantics(
            button: true,
            selected: isSelected,
            label: s.name,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppDimens.radius),
              onTap: () {
                Haptics.select();
                onSelected(s.id);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 96,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.10) : theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(AppDimens.radius),
                  border: Border.all(color: isSelected ? theme.colorScheme.primary : theme.dividerColor, width: isSelected ? 2 : 1),
                ),
                child: ExcludeSemantics(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipOval(
                        child: SizedBox(
                          width: 48,
                          height: 48,
                          child: AppImage(
                            url: s.photoUrl,
                            fallback: ColoredBox(
                              color: theme.colorScheme.primary.withValues(alpha: 0.15),
                              child: Center(
                                child: Text(
                                  s.name.isEmpty ? '?' : s.name.characters.first.toUpperCase(),
                                  style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(s.name, style: theme.textTheme.labelMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
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
                onSelected: slot.available
                    ? (_) {
                        Haptics.select();
                        onSelected(slot.time);
                      }
                    : null,
              ),
          ],
        );
      },
    );
  }
}

/// Bérlés: betölti a vállalkozás bérelhető szolgáltatásait, és megnyitja az űrlapot a kiválasztottal.
class _RentalLoader extends ConsumerWidget {
  const _RentalLoader({required this.business, required this.serviceId});

  final PublicBusiness business;
  final int serviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AsyncView<List<PublicRental>>(
      value: ref.watch(rentalsProvider(business.slug)),
      onRetry: () => ref.invalidate(rentalsProvider(business.slug)),
      builder: (context, rentals) {
        final rental = rentals.where((r) => r.id == serviceId).firstOrNull;
        if (rental == null) return Center(child: Text(AppLocalizations.of(context).genericError));
        return _BookingForm(business: business, serviceId: serviceId, rental: rental);
      },
    );
  }
}
