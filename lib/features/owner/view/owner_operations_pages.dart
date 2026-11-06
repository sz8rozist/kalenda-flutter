import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/async_view.dart';
import '../../../shared/flash.dart';
import '../../../shared/format.dart';
import '../../../shared/ui/app_alerts.dart';
import '../../../shared/ui/empty_state.dart';
import '../../../shared/ui/status_chip.dart';
import '../../staff/viewmodel/staff_session_viewmodel.dart';
import '../model/operations_models.dart';
import '../model/owner_models.dart';
import '../viewmodel/operations_viewmodels.dart';
import '../viewmodel/owner_service_viewmodels.dart';
import '../viewmodel/owner_staff_viewmodels.dart';

class _Frame extends ConsumerWidget {
  const _Frame({required this.title, required this.builder, this.fab});

  final String title;
  final Widget Function(BuildContext context, int businessId) builder;
  final Widget Function(BuildContext context, int businessId)? fab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessId = ref.watch(staffSessionProvider).value?.businessId;
    listenFlash(ref, context, operationsActionsProvider.select((s) => s.flash));

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      floatingActionButton: businessId == null ? null : fab?.call(context, businessId),
      body: businessId == null ? Center(child: Text(AppLocalizations.of(context).ownerNoBusiness)) : builder(context, businessId),
    );
  }
}

Future<void> _sheet(BuildContext context, WidgetBuilder builder) =>
    showModalBottomSheet<void>(context: context, isScrollControlled: true, showDragHandle: true, builder: builder);

int? _int(TextEditingController c) => int.tryParse(c.text.trim());

/// `ÓÓ:PP` alakú idő-e (és érvényes-e).
bool _validTime(String text) {
  final m = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(text.trim());
  if (m == null) return false;
  return int.parse(m.group(1)!) < 24 && int.parse(m.group(2)!) < 60;
}

String _normalizeTime(String text) {
  final m = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(text.trim())!;
  return '${m.group(1)!.padLeft(2, '0')}:${m.group(2)}';
}

String hoursText(int minutes) => '${minutes ~/ 60}:${(minutes % 60).toString().padLeft(2, '0')}';

String weekdayName(AppLocalizations l10n, int day) => switch (day % 7) {
  0 => l10n.weekdaySun,
  1 => l10n.weekdayMon,
  2 => l10n.weekdayTue,
  3 => l10n.weekdayWed,
  4 => l10n.weekdayThu,
  5 => l10n.weekdayFri,
  _ => l10n.weekdaySat,
};

// ─── Csoportos alkalmak ────────────────────────────────────────

class OwnerGroupSessionsPage extends ConsumerWidget {
  const OwnerGroupSessionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return _Frame(
      title: l10n.ownerGroupSessions,
      fab: (context, businessId) => FloatingActionButton.extended(
        onPressed: () => _sheet(context, (_) => _GroupSessionSheet(businessId: businessId)),
        icon: const Icon(Icons.add),
        label: Text(l10n.newGroupSession),
      ),
      builder: (context, businessId) => AsyncView<List<GroupSessionItem>>(
        value: ref.watch(groupSessionsProvider(businessId)),
        onRetry: () => ref.invalidate(groupSessionsProvider(businessId)),
        builder: (context, sessions) => RefreshIndicator(
          onRefresh: () => ref.refresh(groupSessionsProvider(businessId).future),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              if (sessions.isEmpty) EmptyNote(l10n.nothingYet, icon: Icons.groups_rounded),
              for (final s in sessions)
                Card(
                  child: ListTile(
                    leading: DateBadge(s.startsAt),
                    title: Text([?s.serviceName, formatTime(context, s.startsAt)].join(' · ')),
                    subtitle: Text([l10n.groupBooked(s.booked, s.capacity), ?s.staffName].join(' · ')),
                    trailing: s.isCancelled ? StatusChip('cancelled', label: l10n.groupCancelled) : const Icon(Icons.chevron_right_rounded),
                    onTap: () => _sheet(context, (_) => _GroupDetailSheet(businessId: businessId, session: s)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupSessionSheet extends ConsumerStatefulWidget {
  const _GroupSessionSheet({required this.businessId});

  final int businessId;

  @override
  ConsumerState<_GroupSessionSheet> createState() => _GroupSessionSheetState();
}

class _GroupSessionSheetState extends ConsumerState<_GroupSessionSheet> {
  final _time = TextEditingController(text: '18:00');
  final _capacity = TextEditingController(text: '10');
  final _price = TextEditingController();
  final _repeat = TextEditingController(text: '0');
  int? _serviceId;
  int? _staffId;
  DateTime _date = DateTime.now().add(const Duration(days: 1));

  @override
  void dispose() {
    for (final c in [_time, _capacity, _price, _repeat]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final capacity = _int(_capacity);
    if (_serviceId == null || _staffId == null || capacity == null || capacity < 1 || !_validTime(_time.text)) return;
    final navigator = Navigator.of(context);
    final ok = await ref
        .read(operationsActionsProvider.notifier)
        .createGroupSession(
          widget.businessId,
          serviceId: _serviceId!,
          staffId: _staffId!,
          date: _date,
          time: _normalizeTime(_time.text),
          capacity: capacity,
          priceHuf: _int(_price),
          repeatWeeks: _int(_repeat) ?? 0,
        );
    if (ok) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final busy = ref.watch(operationsActionsProvider.select((s) => s.busy));
    final services = [
      for (final s in ref.watch(ownerServicesProvider(widget.businessId)).value ?? const <OwnerService>[])
        if (s.isGroup) s,
    ];
    final staff = ref.watch(ownerStaffProvider(widget.businessId)).value ?? const <OwnerStaff>[];

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<int>(
              initialValue: _serviceId,
              decoration: InputDecoration(labelText: l10n.ownerServices),
              items: [for (final s in services) DropdownMenuItem(value: s.id, child: Text(s.name))],
              onChanged: (v) => setState(() => _serviceId = v),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: _staffId,
              decoration: InputDecoration(labelText: l10n.staffLabel),
              items: [for (final s in staff) DropdownMenuItem(value: s.id, child: Text(s.name))],
              onChanged: (v) => setState(() => _staffId = v),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.event),
              label: Text(formatDate(context, _date)),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) setState(() => _date = picked);
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _time,
                    decoration: InputDecoration(labelText: l10n.groupTime),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _capacity,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: l10n.groupCapacity),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _price,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: l10n.servicePriceHuf),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _repeat,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: l10n.groupRepeatWeeks),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: busy ? null : _save, child: Text(l10n.save)),
          ],
        ),
      ),
    );
  }
}

class _GroupDetailSheet extends ConsumerStatefulWidget {
  const _GroupDetailSheet({required this.businessId, required this.session});

  final int businessId;
  final GroupSessionItem session;

  @override
  ConsumerState<_GroupDetailSheet> createState() => _GroupDetailSheetState();
}

class _GroupDetailSheetState extends ConsumerState<_GroupDetailSheet> {
  final _name = TextEditingController();
  final _email = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    if (_name.text.trim().isEmpty || !_email.text.contains('@')) return;
    final navigator = Navigator.of(context);
    final ok = await ref
        .read(operationsActionsProvider.notifier)
        .addAttendee(widget.businessId, widget.session.id, name: _name.text.trim(), email: _email.text.trim());
    if (ok) navigator.pop();
  }

  Future<void> _cancel() async {
    final l10n = AppLocalizations.of(context);
    final navigator = Navigator.of(context);
    final confirmed = await showConfirmAlert(
      context,
      title: l10n.groupCancelTitle,
      message: l10n.groupCancelText,
      confirmLabel: l10n.yes,
      destructive: true,
      icon: Icons.event_busy_outlined,
    );
    if (!confirmed) return;
    final ok = await ref.read(operationsActionsProvider.notifier).cancelGroupSession(widget.businessId, widget.session.id);
    if (ok) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final s = widget.session;
    final busy = ref.watch(operationsActionsProvider.select((x) => x.busy));

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(s.serviceName ?? '', style: theme.textTheme.titleLarge),
            Text('${formatDateTime(context, s.startsAt)} · ${l10n.groupBooked(s.booked, s.capacity)}'),
            const SizedBox(height: 12),
            if (s.attendees.isEmpty) Text(l10n.groupNoAttendees),
            for (final a in s.attendees)
              ListTile(contentPadding: EdgeInsets.zero, dense: true, title: Text(a.name), subtitle: Text([?a.email, ?a.phone].join(' · '))),
            if (!s.isCancelled) ...[
              const Divider(height: 24),
              Text(l10n.groupAddAttendee, style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              TextField(
                controller: _name,
                decoration: InputDecoration(labelText: l10n.name),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: l10n.email),
              ),
              const SizedBox(height: 12),
              FilledButton(onPressed: busy || s.placesLeft <= 0 ? null : _add, child: Text(l10n.groupAddAttendee)),
              TextButton.icon(
                icon: const Icon(Icons.event_busy_outlined),
                label: Text(l10n.actionCancel),
                style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
                onPressed: busy ? null : _cancel,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Szünetek ──────────────────────────────────────────────────

class OwnerBreaksPage extends ConsumerWidget {
  const OwnerBreaksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final actions = ref.read(operationsActionsProvider.notifier);

    return _Frame(
      title: l10n.ownerBreaks,
      fab: (context, businessId) => FloatingActionButton.extended(
        onPressed: () => _sheet(context, (_) => _BreakSheet(businessId: businessId)),
        icon: const Icon(Icons.add),
        label: Text(l10n.newBreak),
      ),
      builder: (context, businessId) => AsyncView<List<StaffBreaks>>(
        value: ref.watch(breaksProvider(businessId)),
        onRetry: () => ref.invalidate(breaksProvider(businessId)),
        builder: (context, groups) => RefreshIndicator(
          onRefresh: () => ref.refresh(breaksProvider(businessId).future),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              if (groups.every((g) => g.breaks.isEmpty)) EmptyNote(l10n.breaksNone, icon: Icons.free_breakfast_outlined),
              for (final g in groups)
                if (g.breaks.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    child: Text(g.staffName, style: Theme.of(context).textTheme.titleMedium),
                  ),
                  for (final b in g.breaks)
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.free_breakfast_outlined),
                        title: Text('${weekdayName(l10n, b.dayOfWeek)} · ${b.startAt}–${b.endAt}'),
                        subtitle: b.label == null ? null : Text(b.label!),
                        trailing: IconButton(
                          tooltip: l10n.actionDelete,
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => actions.deleteBreak(businessId, b.id),
                        ),
                      ),
                    ),
                ],
            ],
          ),
        ),
      ),
    );
  }
}

class _BreakSheet extends ConsumerStatefulWidget {
  const _BreakSheet({required this.businessId});

  final int businessId;

  @override
  ConsumerState<_BreakSheet> createState() => _BreakSheetState();
}

class _BreakSheetState extends ConsumerState<_BreakSheet> {
  final _from = TextEditingController(text: '12:00');
  final _to = TextEditingController(text: '12:30');
  final _label = TextEditingController();
  int? _staffId;
  int _day = 1;

  @override
  void dispose() {
    for (final c in [_from, _to, _label]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_staffId == null || !_validTime(_from.text) || !_validTime(_to.text)) return;
    final navigator = Navigator.of(context);
    final ok = await ref
        .read(operationsActionsProvider.notifier)
        .addBreak(
          widget.businessId,
          staffId: _staffId!,
          dayOfWeek: _day,
          start: _normalizeTime(_from.text),
          end: _normalizeTime(_to.text),
          label: _label.text,
        );
    if (ok) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final busy = ref.watch(operationsActionsProvider.select((s) => s.busy));
    final staff = ref.watch(ownerStaffProvider(widget.businessId)).value ?? const <OwnerStaff>[];

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<int>(
              initialValue: _staffId,
              decoration: InputDecoration(labelText: l10n.staffLabel),
              items: [for (final s in staff) DropdownMenuItem(value: s.id, child: Text(s.name))],
              onChanged: (v) => setState(() => _staffId = v),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: _day,
              decoration: InputDecoration(labelText: l10n.breakDay),
              items: [
                for (final d in const [1, 2, 3, 4, 5, 6, 0]) DropdownMenuItem(value: d, child: Text(weekdayName(l10n, d))),
              ],
              onChanged: (v) => setState(() => _day = v ?? 1),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _from,
                    decoration: InputDecoration(labelText: l10n.breakFrom),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _to,
                    decoration: InputDecoration(labelText: l10n.breakTo),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _label,
              decoration: InputDecoration(labelText: l10n.breakLabel),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: busy ? null : _save, child: Text(l10n.save)),
          ],
        ),
      ),
    );
  }
}

// ─── Munkaidő ──────────────────────────────────────────────────

class OwnerTimesheetPage extends ConsumerWidget {
  const OwnerTimesheetPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final month = ref.watch(timesheetMonthProvider);
    final months = ref.read(timesheetMonthProvider.notifier);
    final actions = ref.read(operationsActionsProvider.notifier);

    return _Frame(
      title: l10n.ownerTimesheet,
      fab: (context, businessId) => FloatingActionButton.extended(
        onPressed: () => _sheet(context, (_) => _EntrySheet(businessId: businessId)),
        icon: const Icon(Icons.add),
        label: Text(l10n.timesheetNewEntry),
      ),
      builder: (context, businessId) => Column(
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
            child: AsyncView<TimesheetMonth>(
              value: ref.watch(timesheetProvider(businessId)),
              onRetry: () => ref.invalidate(timesheetProvider(businessId)),
              builder: (context, data) => RefreshIndicator(
                onRefresh: () => ref.refresh(timesheetProvider(businessId).future),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(gradient: AppColors.heroGradient, borderRadius: BorderRadius.circular(AppDimens.radius)),
                      child: DefaultTextStyle.merge(
                        style: const TextStyle(color: Colors.white),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.timesheetWorked(hoursText(data.workedMinutes)),
                              style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
                            ),
                            Text(l10n.timesheetPay(formatHuf(context, data.estimatedPayHuf))),
                            if (data.staleOpenCount > 0) Text(l10n.timesheetStale(data.staleOpenCount)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (data.isClosed)
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.lock_outline, color: AppColors.success),
                          title: Text(l10n.timesheetClosed),
                          trailing: TextButton(onPressed: () => actions.reopenMonth(businessId, month), child: Text(l10n.timesheetReopen)),
                        ),
                      )
                    else
                      OutlinedButton.icon(
                        icon: const Icon(Icons.lock_outline),
                        label: Text(l10n.timesheetClose),
                        onPressed: () => actions.closeMonth(businessId, month),
                      ),
                    const SizedBox(height: 12),
                    for (final r in data.rows)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(r.name, style: theme.textTheme.titleSmall),
                              const SizedBox(height: 4),
                              Text(
                                [
                                  l10n.timesheetWorked(hoursText(r.workedMinutes)),
                                  if (r.plannedMinutes > 0) l10n.timesheetPlanned(hoursText(r.plannedMinutes)),
                                  if (r.overtimeMinutes > 0) l10n.timesheetOvertime(hoursText(r.overtimeMinutes)),
                                ].join(' · '),
                                style: theme.textTheme.bodySmall,
                              ),
                              Text(l10n.timesheetPay(formatHuf(context, r.estimatedPayHuf)), style: theme.textTheme.bodySmall),
                              if (r.openSince != null)
                                Text(
                                  l10n.timesheetOpenSince(formatDateTime(context, r.openSince!)),
                                  style: theme.textTheme.bodySmall?.copyWith(color: r.openIsStale ? AppColors.warning : AppColors.success),
                                ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(l10n.timesheetEntries, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    if (data.entries.isEmpty) EmptyNote(l10n.nothingYet, icon: Icons.schedule_rounded),
                    for (final e in data.entries)
                      Dismissible(
                        key: ValueKey('entry-${e.id}'),
                        direction: data.isClosed ? DismissDirection.none : DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          margin: const EdgeInsets.only(bottom: AppDimens.gap),
                          decoration: BoxDecoration(color: AppColors.danger, borderRadius: BorderRadius.circular(AppDimens.radius)),
                          child: const Icon(Icons.delete_outline, color: Colors.white),
                        ),
                        onDismissed: (_) => actions.deleteTimeEntry(businessId, e.id),
                        child: Card(
                          child: ListTile(
                            dense: true,
                            title: Text('${e.staffName} · ${hoursText(e.workedMinutes)}'),
                            subtitle: Text(
                              [
                                if (e.clockInAt != null) formatDateTime(context, e.clockInAt!),
                                if (e.clockOutAt != null) formatTime(context, e.clockOutAt!),
                              ].join(' – '),
                            ),
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

class _EntrySheet extends ConsumerStatefulWidget {
  const _EntrySheet({required this.businessId});

  final int businessId;

  @override
  ConsumerState<_EntrySheet> createState() => _EntrySheetState();
}

class _EntrySheetState extends ConsumerState<_EntrySheet> {
  final _break = TextEditingController(text: '0');
  int? _staffId;
  late DateTime _in = DateTime.now().copyWith(hour: 9, minute: 0, second: 0, millisecond: 0, microsecond: 0);
  late DateTime _out = _in.add(const Duration(hours: 8));

  @override
  void dispose() {
    _break.dispose();
    super.dispose();
  }

  Future<DateTime?> _pick(DateTime initial) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 400)),
      lastDate: DateTime.now(),
    );
    if (date == null || !mounted) return null;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(initial));
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _save() async {
    if (_staffId == null || !_out.isAfter(_in)) return;
    final navigator = Navigator.of(context);
    final ok = await ref
        .read(operationsActionsProvider.notifier)
        .addTimeEntry(widget.businessId, staffId: _staffId!, clockIn: _in, clockOut: _out, breakMinutes: _int(_break) ?? 0);
    if (ok) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final busy = ref.watch(operationsActionsProvider.select((s) => s.busy));
    final staff = ref.watch(ownerStaffProvider(widget.businessId)).value ?? const <OwnerStaff>[];

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<int>(
              initialValue: _staffId,
              decoration: InputDecoration(labelText: l10n.timesheetStaff),
              items: [for (final s in staff) DropdownMenuItem(value: s.id, child: Text(s.name))],
              onChanged: (v) => setState(() => _staffId = v),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.login_rounded),
              label: Text('${l10n.timesheetIn}: ${formatDateTime(context, _in)}'),
              onPressed: () async {
                final picked = await _pick(_in);
                if (picked != null) setState(() => _in = picked);
              },
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.logout_rounded),
              label: Text('${l10n.timesheetOut}: ${formatDateTime(context, _out)}'),
              onPressed: () async {
                final picked = await _pick(_out);
                if (picked != null) setState(() => _out = picked);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _break,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l10n.timesheetBreakMinutes),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: busy ? null : _save, child: Text(l10n.save)),
          ],
        ),
      ),
    );
  }
}
