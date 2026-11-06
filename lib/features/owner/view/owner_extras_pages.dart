import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/async_view.dart';
import '../../../shared/flash.dart';
import '../../../shared/format.dart';
import '../../../shared/ui/app_alerts.dart';
import '../../../shared/ui/empty_state.dart';
import '../../staff/viewmodel/staff_session_viewmodel.dart';
import '../model/extras_models.dart';
import '../model/inventory_models.dart';
import '../model/owner_models.dart';
import '../viewmodel/inventory_viewmodels.dart';
import '../viewmodel/owner_service_viewmodels.dart';
import '../viewmodel/settings_viewmodels.dart';
import 'owner_operations_pages.dart' show hoursText, weekdayName;

int? _int(TextEditingController c) => int.tryParse(c.text.trim());

Future<void> _sheet(BuildContext context, WidgetBuilder builder) =>
    showModalBottomSheet<void>(context: context, isScrollControlled: true, showDragHandle: true, builder: builder);

// ─── Kiegészítők ───────────────────────────────────────────────

class OwnerAddonsPage extends ConsumerWidget {
  const OwnerAddonsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final businessId = ref.watch(staffSessionProvider).value?.businessId;
    listenFlash(ref, context, extrasActionsProvider.select((s) => s.flash));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.ownerAddons)),
      floatingActionButton: businessId == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _sheet(context, (_) => _AddonSheet(businessId: businessId)),
              icon: const Icon(Icons.add),
              label: Text(l10n.newAddon),
            ),
      body: businessId == null
          ? Center(child: Text(l10n.ownerNoBusiness))
          : AsyncView<List<Addon>>(
              value: ref.watch(addonsProvider(businessId)),
              onRetry: () => ref.invalidate(addonsProvider(businessId)),
              builder: (context, addons) => RefreshIndicator(
                onRefresh: () => ref.refresh(addonsProvider(businessId).future),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  children: [
                    if (addons.isEmpty) EmptyNote(l10n.nothingYet, icon: Icons.add_circle_outline),
                    for (final a in addons)
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.add_circle_outline),
                          title: Text(a.name),
                          subtitle: Text('${formatHuf(context, a.priceHuf)} · ${l10n.minutes(a.durationMinutes)}'),
                          trailing: a.isActive ? null : Text(l10n.passTypeInactive),
                          onTap: () => _sheet(context, (_) => _AddonSheet(businessId: businessId, addon: a)),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _AddonSheet extends ConsumerStatefulWidget {
  const _AddonSheet({required this.businessId, this.addon});

  final int businessId;
  final Addon? addon;

  @override
  ConsumerState<_AddonSheet> createState() => _AddonSheetState();
}

class _AddonSheetState extends ConsumerState<_AddonSheet> {
  late final _name = TextEditingController(text: widget.addon?.name ?? '');
  late final _price = TextEditingController(text: widget.addon?.priceHuf.toString() ?? '');
  late final _minutes = TextEditingController(text: '${widget.addon?.durationMinutes ?? 10}');
  late final Set<int> _services = {...?widget.addon?.serviceIds};
  late bool _active = widget.addon?.isActive ?? true;

  @override
  void dispose() {
    for (final c in [_name, _price, _minutes]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final price = _int(_price);
    final minutes = _int(_minutes);
    if (_name.text.trim().isEmpty || price == null || minutes == null || _services.isEmpty) return;
    final navigator = Navigator.of(context);
    final ok = await ref
        .read(extrasActionsProvider.notifier)
        .saveAddon(
          widget.businessId,
          Addon(
            id: widget.addon?.id ?? 0,
            name: _name.text.trim(),
            priceHuf: price,
            durationMinutes: minutes,
            isActive: _active,
            serviceIds: _services.toList(),
          ),
          id: widget.addon?.id,
        );
    if (ok) navigator.pop();
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final navigator = Navigator.of(context);
    final confirmed = await showConfirmAlert(
      context,
      title: l10n.addonDeleteTitle,
      message: widget.addon!.name,
      confirmLabel: l10n.actionDelete,
      destructive: true,
      icon: Icons.delete_outline,
    );
    if (!confirmed) return;
    final ok = await ref.read(extrasActionsProvider.notifier).deleteAddon(widget.businessId, widget.addon!.id);
    if (ok) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final busy = ref.watch(extrasActionsProvider.select((s) => s.busy));
    final services = ref.watch(ownerServicesProvider(widget.businessId)).value ?? const <OwnerService>[];

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _name,
              decoration: InputDecoration(labelText: l10n.name),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _price,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: l10n.addonPrice),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _minutes,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: l10n.addonMinutes),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(l10n.addonServices, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final s in services)
                  FilterChip(
                    label: Text(s.name),
                    selected: _services.contains(s.id),
                    onSelected: (on) => setState(() => on ? _services.add(s.id) : _services.remove(s.id)),
                  ),
              ],
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.fieldActive),
              value: _active,
              onChanged: (v) => setState(() => _active = v),
            ),
            FilledButton(onPressed: busy ? null : _save, child: Text(l10n.save)),
            if (widget.addon != null)
              Center(
                child: TextButton.icon(
                  icon: const Icon(Icons.delete_outline),
                  label: Text(l10n.actionDelete),
                  style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
                  onPressed: busy ? null : _delete,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Munkatárs: munkaidő ───────────────────────────────────────

Future<void> showStaffHoursSheet(BuildContext context, StaffKey key) => _sheet(context, (_) => _StaffHoursSheet(staffKey: key));

class _StaffHoursSheet extends ConsumerStatefulWidget {
  const _StaffHoursSheet({required this.staffKey});

  final StaffKey staffKey;

  @override
  ConsumerState<_StaffHoursSheet> createState() => _StaffHoursSheetState();
}

class _StaffHoursSheetState extends ConsumerState<_StaffHoursSheet> {
  List<StaffHour>? _hours;

  Future<void> _pick(int index, {required bool start}) async {
    final current = _hours![index];
    final parts = (start ? current.startAt : current.endAt).split(':');
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: int.tryParse(parts.first) ?? 9, minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0),
    );
    if (picked == null) return;
    final text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    setState(() => _hours![index] = start ? current.copyWith(startAt: text) : current.copyWith(endAt: text));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final busy = ref.watch(extrasActionsProvider.select((s) => s.busy));
    final loaded = ref.watch(staffHoursProvider(widget.staffKey));

    return SafeArea(
      child: loaded.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (_, _) => Center(
          child: TextButton(onPressed: () => ref.invalidate(staffHoursProvider(widget.staffKey)), child: Text(l10n.retry)),
        ),
        data: (data) {
          _hours ??= [...data];
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final (index, h) in _hours!.indexed)
                  Row(
                    children: [
                      SizedBox(width: 92, child: Text(weekdayName(l10n, h.dayOfWeek))),
                      Switch(
                        value: !h.isDayOff,
                        onChanged: (on) => setState(() => _hours![index] = h.copyWith(isDayOff: !on)),
                      ),
                      if (h.isDayOff)
                        Expanded(child: Text(l10n.dayOff, style: Theme.of(context).textTheme.bodySmall))
                      else ...[
                        TextButton(onPressed: () => _pick(index, start: true), child: Text(h.startAt)),
                        const Text('–'),
                        TextButton(onPressed: () => _pick(index, start: false), child: Text(h.endAt)),
                      ],
                    ],
                  ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: busy
                      ? null
                      : () async {
                          final navigator = Navigator.of(context);
                          if (await ref.read(extrasActionsProvider.notifier).saveStaffHours(widget.staffKey, _hours!)) navigator.pop();
                        },
                  child: Text(l10n.save),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Munkatárs: bér ────────────────────────────────────────────

Future<void> showStaffPaySheet(BuildContext context, StaffKey key) => _sheet(context, (_) => _StaffPaySheet(staffKey: key));

class _StaffPaySheet extends ConsumerStatefulWidget {
  const _StaffPaySheet({required this.staffKey});

  final StaffKey staffKey;

  @override
  ConsumerState<_StaffPaySheet> createState() => _StaffPaySheetState();
}

class _StaffPaySheetState extends ConsumerState<_StaffPaySheet> {
  TextEditingController? _rate;
  TextEditingController? _service;
  TextEditingController? _product;
  String _type = 'none';
  String _source = 'schedule';
  bool _loaded = false;

  @override
  void dispose() {
    _rate?.dispose();
    _service?.dispose();
    _product?.dispose();
    super.dispose();
  }

  void _load(StaffPay p) {
    if (_loaded) return;
    _loaded = true;
    _rate = TextEditingController(text: '${p.payRateHuf}');
    _service = TextEditingController(text: p.serviceCommission.toString());
    _product = TextEditingController(text: p.productCommission.toString());
    _type = p.payType;
    _source = p.hoursSource;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final busy = ref.watch(extrasActionsProvider.select((s) => s.busy));
    final loaded = ref.watch(staffPayProvider(widget.staffKey));

    return SafeArea(
      child: loaded.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (_, _) => Center(
          child: TextButton(onPressed: () => ref.invalidate(staffPayProvider(widget.staffKey)), child: Text(l10n.retry)),
        ),
        data: (pay) {
          _load(pay);
          const types = ['none', 'hourly', 'monthly'];
          const sources = ['schedule', 'clock', 'appointments'];
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: types.contains(_type) ? _type : 'none',
                  decoration: InputDecoration(labelText: l10n.payType),
                  items: [
                    DropdownMenuItem(value: 'none', child: Text(l10n.payTypeNone)),
                    DropdownMenuItem(value: 'hourly', child: Text(l10n.payTypeHourly)),
                    DropdownMenuItem(value: 'monthly', child: Text(l10n.payTypeMonthly)),
                  ],
                  onChanged: (v) => setState(() => _type = v ?? 'none'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _rate,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: l10n.payRate),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: sources.contains(_source) ? _source : 'schedule',
                  decoration: InputDecoration(labelText: l10n.payHoursSource),
                  items: [
                    DropdownMenuItem(value: 'schedule', child: Text(l10n.payHoursSchedule)),
                    DropdownMenuItem(value: 'clock', child: Text(l10n.payHoursClock)),
                    DropdownMenuItem(value: 'appointments', child: Text(l10n.payHoursAppointments)),
                  ],
                  onChanged: (v) => setState(() => _source = v ?? 'schedule'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _service,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(labelText: l10n.payServiceCommission),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _product,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(labelText: l10n.payProductCommission),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: busy
                      ? null
                      : () async {
                          final navigator = Navigator.of(context);
                          final ok = await ref
                              .read(extrasActionsProvider.notifier)
                              .saveStaffPay(
                                widget.staffKey,
                                payType: _type,
                                payRateHuf: _int(_rate!) ?? 0,
                                hoursSource: _source,
                                serviceCommission: double.tryParse(_service!.text.trim().replaceAll(',', '.')) ?? 0,
                                productCommission: double.tryParse(_product!.text.trim().replaceAll(',', '.')) ?? 0,
                              );
                          if (ok) navigator.pop();
                        },
                  child: Text(l10n.save),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Szolgáltatás: anyagfelhasználás ───────────────────────────

Future<void> showMaterialsSheet(BuildContext context, {required int businessId, required int serviceId}) =>
    _sheet(context, (_) => _MaterialsSheet(businessId: businessId, serviceId: serviceId));

class _MaterialsSheet extends ConsumerStatefulWidget {
  const _MaterialsSheet({required this.businessId, required this.serviceId});

  final int businessId;
  final int serviceId;

  @override
  ConsumerState<_MaterialsSheet> createState() => _MaterialsSheetState();
}

class _MaterialsSheetState extends ConsumerState<_MaterialsSheet> {
  final Map<int, TextEditingController> _quantities = {};

  @override
  void dispose() {
    for (final c in _quantities.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final busy = ref.watch(extrasActionsProvider.select((s) => s.busy));
    final products = ref.watch(productsProvider(widget.businessId));

    return SafeArea(
      child: products.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (_, _) => Center(
          child: TextButton(onPressed: () => ref.invalidate(productsProvider(widget.businessId)), child: Text(l10n.retry)),
        ),
        data: (List<Product> list) {
          if (list.isEmpty) return Padding(padding: const EdgeInsets.all(24), child: Text(l10n.nothingYet));
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final p in list)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Expanded(child: Text(p.name)),
                        SizedBox(
                          width: 130,
                          child: TextField(
                            controller: _quantities.putIfAbsent(p.id, TextEditingController.new),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(labelText: l10n.materialQuantity, isDense: true),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: busy
                      ? null
                      : () async {
                          final navigator = Navigator.of(context);
                          final materials = <int, double>{
                            for (final e in _quantities.entries)
                              if ((double.tryParse(e.value.text.trim().replaceAll(',', '.')) ?? 0) > 0)
                                e.key: double.parse(e.value.text.trim().replaceAll(',', '.')),
                          };
                          final ok = await ref.read(extrasActionsProvider.notifier).saveMaterials(widget.businessId, widget.serviceId, materials);
                          if (ok) navigator.pop();
                        },
                  child: Text(l10n.save),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Munkatársi portál: saját munkaidő és profil ───────────────

class PortalTimesheetPage extends ConsumerWidget {
  const PortalTimesheetPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final month = ref.watch(portalMonthProvider);
    final months = ref.read(portalMonthProvider.notifier);
    final locale = Localizations.localeOf(context).toString();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.portalTimesheetTitle)),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(icon: const Icon(Icons.chevron_left_rounded), onPressed: () => months.shift(-1)),
              Text(DateFormat.yMMMM(locale).format(month), style: theme.textTheme.titleMedium),
              IconButton(icon: const Icon(Icons.chevron_right_rounded), onPressed: () => months.shift(1)),
            ],
          ),
          Expanded(
            child: AsyncView<PortalTimesheet>(
              value: ref.watch(portalTimesheetProvider),
              onRetry: () => ref.invalidate(portalTimesheetProvider),
              builder: (context, data) => RefreshIndicator(
                onRefresh: () => ref.refresh(portalTimesheetProvider.future),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.portalClocked(hoursText(data.clockedMinutes)), style: theme.textTheme.titleMedium),
                            Text(l10n.portalPlanned(hoursText(data.plannedMinutes)), style: theme.textTheme.bodyMedium),
                            if (data.openSince != null)
                              Text(
                                l10n.timesheetOpenSince(formatDateTime(context, data.openSince!)),
                                style: theme.textTheme.bodySmall?.copyWith(color: data.isStale ? AppColors.warning : AppColors.success),
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (data.entries.isEmpty) EmptyNote(l10n.nothingYet, icon: Icons.schedule_rounded),
                    for (final e in data.entries)
                      Card(
                        child: ListTile(
                          dense: true,
                          title: Text(hoursText(e.workedMinutes)),
                          subtitle: Text(
                            [
                              if (e.clockIn != null) formatDateTime(context, e.clockIn!),
                              if (e.clockOut != null) formatTime(context, e.clockOut!),
                            ].join(' – '),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PortalProfilePage extends ConsumerWidget {
  const PortalProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    listenFlash(ref, context, extrasActionsProvider.select((s) => s.flash));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.portalProfileTitle)),
      body: AsyncView<PortalProfile>(
        value: ref.watch(portalProfileProvider),
        onRetry: () => ref.invalidate(portalProfileProvider),
        builder: (context, p) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListTile(leading: const Icon(Icons.person_outline), title: Text(p.name), subtitle: Text([p.email, ?p.phone].join('\n'))),
            if (p.bio != null && p.bio!.isNotEmpty) Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text(p.bio!)),
            const SizedBox(height: 16),
            Text(l10n.portalCalendarFeed, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                title: Text(p.calendarFeedUrl ?? '—', maxLines: 2, overflow: TextOverflow.ellipsis),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: l10n.calendarCopy,
                      icon: const Icon(Icons.copy_rounded),
                      onPressed: p.calendarFeedUrl == null
                          ? null
                          : () async {
                              await Clipboard.setData(ClipboardData(text: p.calendarFeedUrl!));
                              if (context.mounted) showToast(context, l10n.calendarCopied);
                            },
                    ),
                    IconButton(
                      tooltip: l10n.calendarRegenerate,
                      icon: const Icon(Icons.autorenew_rounded),
                      onPressed: () async {
                        final confirmed = await showConfirmAlert(
                          context,
                          title: l10n.calendarRegenerateTitle,
                          message: l10n.calendarRegenerateText,
                          confirmLabel: l10n.calendarRegenerate,
                          icon: Icons.autorenew_rounded,
                        );
                        if (confirmed) await ref.read(extrasActionsProvider.notifier).regenerateCalendarToken();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
