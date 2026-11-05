import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../shared/async_view.dart';
import '../../shared/format.dart';
import 'appointment_sheet.dart';
import 'staff_auth.dart';
import 'staff_login_page.dart';
import 'staff_models.dart';
import 'staff_repository.dart';

/// A munkatársi felület: belépés nélkül a belépő oldal; belépve három fül (Ma, Naptár, Szabadság).
class StaffHomePage extends ConsumerStatefulWidget {
  const StaffHomePage({super.key});

  @override
  ConsumerState<StaffHomePage> createState() => _StaffHomePageState();
}

class _StaffHomePageState extends ConsumerState<StaffHomePage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = ref.watch(staffAuthProvider);

    if (auth.isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final user = auth.value;
    if (user == null) return const StaffLoginPage();

    if (!user.isStaff) {
      return Scaffold(
        appBar: AppBar(actions: [_SignOutButton()]),
        body: Center(
          child: Padding(padding: const EdgeInsets.all(24), child: Text(l10n.staffNoProfile, textAlign: TextAlign.center)),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(user.businessName ?? l10n.appTitle),
        actions: [_SignOutButton()],
      ),
      body: IndexedStack(index: _index, children: const [_TodayTab(), _CalendarTab(), _LeavesTab()]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.today_outlined), label: l10n.staffToday),
          NavigationDestination(icon: const Icon(Icons.calendar_month_outlined), label: l10n.staffCalendar),
          NavigationDestination(icon: const Icon(Icons.beach_access_outlined), label: l10n.staffLeaves),
        ],
      ),
    );
  }
}

class _SignOutButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) => IconButton(
        tooltip: AppLocalizations.of(context).signOut,
        icon: const Icon(Icons.logout),
        onPressed: () => ref.read(staffAuthProvider.notifier).signOut(),
      );
}

// ─── Ma ──────────────────────────────────────────────────────

class _TodayTab extends ConsumerWidget {
  const _TodayTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return AsyncView<PortalDashboard>(
      value: ref.watch(portalDashboardProvider),
      onRetry: () => ref.invalidate(portalDashboardProvider),
      builder: (context, data) => RefreshIndicator(
        onRefresh: () => ref.refresh(portalDashboardProvider.future),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(data.staffName, style: Theme.of(context).textTheme.titleLarge),
            Text(l10n.todayCount(data.todayCount)),
            const SizedBox(height: 16),
            _ClockCard(clock: data.clock),
            const SizedBox(height: 24),
            Text(l10n.upcomingAppointments, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (data.upcoming.isEmpty) Text(l10n.noAppointments),
            for (final a in data.upcoming) AppointmentTile(appointment: a),
          ],
        ),
      ),
    );
  }
}

class _ClockCard extends ConsumerStatefulWidget {
  const _ClockCard({required this.clock});

  final ClockState clock;

  @override
  ConsumerState<_ClockCard> createState() => _ClockCardState();
}

class _ClockCardState extends ConsumerState<_ClockCard> {
  bool _busy = false;

  Future<void> _toggle() async {
    final messenger = ScaffoldMessenger.of(context);
    final repo = ref.read(staffRepositoryProvider);
    setState(() => _busy = true);
    try {
      if (widget.clock.isClockedIn) {
        final minutes = await _askBreakMinutes();
        if (minutes == null) return;
        await repo.clockOut(breakMinutes: minutes);
      } else {
        await repo.clockIn();
      }
    } catch (e) {
      if (mounted) messenger.showSnackBar(SnackBar(content: Text(errorText(context, e))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Kicsekkolás előtt: mennyi szünetet tartott (perc). Mégse = null.
  Future<int?> _askBreakMinutes() {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: '0');
    return showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clockOut),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: l10n.breakMinutes),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.no)),
          FilledButton(
            onPressed: () => Navigator.pop(context, (int.tryParse(controller.text) ?? 0).clamp(0, 720)),
            child: Text(l10n.clockOut),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final clock = widget.clock;

    return Card(
      child: ListTile(
        leading: Icon(clock.isClockedIn ? Icons.timer : Icons.timer_outlined),
        title: Text(clock.isClockedIn ? l10n.clockedInSince(formatDateTime(context, clock.openSince!)) : l10n.clockIn),
        trailing: FilledButton(
          onPressed: _busy ? null : _toggle,
          child: Text(clock.isClockedIn ? l10n.clockOut : l10n.clockIn),
        ),
      ),
    );
  }
}

/// Egy foglalás a listában; koppintásra megnyílik a kezelő lap.
class AppointmentTile extends StatelessWidget {
  const AppointmentTile({super.key, required this.appointment});

  final PortalAppointment appointment;

  @override
  Widget build(BuildContext context) {
    final a = appointment;
    return Card(
      child: ListTile(
        title: Text('${formatTime(context, a.startsAt)} – ${a.serviceName}'),
        subtitle: Text([formatDate(context, a.startsAt), if (a.customerName != null) a.customerName!].join(' · ')),
        trailing: Text(statusLabel(context, a.status)),
        onTap: () => showAppointmentSheet(context, a),
      ),
    );
  }
}

// ─── Naptár ──────────────────────────────────────────────────

class _CalendarTab extends ConsumerStatefulWidget {
  const _CalendarTab();

  @override
  ConsumerState<_CalendarTab> createState() => _CalendarTabState();
}

class _CalendarTabState extends ConsumerState<_CalendarTab> {
  late DateTime _weekStart = _mondayOf(DateTime.now());

  static DateTime _mondayOf(DateTime d) => DateTime(d.year, d.month, d.day).subtract(Duration(days: d.weekday - 1));

  void _shift(int weeks) => setState(() => _weekStart = _weekStart.add(Duration(days: 7 * weeks)));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final range = (from: _weekStart, to: _weekStart.add(const Duration(days: 6)));

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(tooltip: l10n.previousWeek, icon: const Icon(Icons.chevron_left), onPressed: () => _shift(-1)),
            Text('${formatDate(context, range.from)} – ${formatDate(context, range.to)}'),
            IconButton(tooltip: l10n.nextWeek, icon: const Icon(Icons.chevron_right), onPressed: () => _shift(1)),
          ],
        ),
        Expanded(
          child: AsyncView<PortalCalendar>(
            value: ref.watch(portalCalendarProvider(range)),
            onRetry: () => ref.invalidate(portalCalendarProvider(range)),
            builder: (context, calendar) => RefreshIndicator(
              onRefresh: () => ref.refresh(portalCalendarProvider(range).future),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  for (var i = 0; i < 7; i++) ..._day(context, range.from.add(Duration(days: i)), calendar),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _day(BuildContext context, DateTime day, PortalCalendar calendar) {
    final l10n = AppLocalizations.of(context);
    bool sameDay(DateTime d) => d.year == day.year && d.month == day.month && d.day == day.day;

    final appointments = calendar.appointments.where((a) => sameDay(a.startsAt)).toList()
      ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
    final onLeave = calendar.leaves.any((l) => !day.isBefore(l.dateFrom) && !day.isAfter(l.dateTo));

    return [
      Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 4),
        child: Row(children: [
          Text(formatDate(context, day), style: Theme.of(context).textTheme.titleSmall),
          if (onLeave) ...[const SizedBox(width: 8), Chip(label: Text(l10n.leaveDay), visualDensity: VisualDensity.compact)],
        ]),
      ),
      if (appointments.isEmpty) Text(l10n.noAppointments, style: Theme.of(context).textTheme.bodySmall),
      for (final a in appointments) AppointmentTile(appointment: a),
    ];
  }
}

// ─── Szabadság ───────────────────────────────────────────────

class _LeavesTab extends ConsumerWidget {
  const _LeavesTab();

  Future<void> _request(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      helpText: l10n.pickDates,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (range == null || !context.mounted) return;

    final reason = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.newLeave),
        content: TextField(controller: reason, decoration: InputDecoration(labelText: l10n.leaveReason)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.no)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.save)),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(staffRepositoryProvider).requestLeave(range.start, range.end, reason.text.trim());
      messenger.showSnackBar(SnackBar(content: Text(l10n.saved)));
    } catch (e) {
      if (context.mounted) messenger.showSnackBar(SnackBar(content: Text(errorText(context, e))));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _request(context, ref),
        icon: const Icon(Icons.add),
        label: Text(l10n.newLeave),
      ),
      body: AsyncView<List<LeaveRequest>>(
        value: ref.watch(leaveRequestsProvider),
        onRetry: () => ref.invalidate(leaveRequestsProvider),
        builder: (context, leaves) => RefreshIndicator(
          onRefresh: () => ref.refresh(leaveRequestsProvider.future),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
            children: [
              if (leaves.isEmpty) Text(l10n.nothingYet),
              for (final leave in leaves)
                Card(
                  child: ListTile(
                    title: Text('${formatDate(context, leave.dateFrom)} – ${formatDate(context, leave.dateTo)}'),
                    subtitle: Text([statusLabel(context, leave.status), if (leave.reason != null) leave.reason!].join(' · ')),
                    trailing: leave.cancellable
                        ? TextButton(
                            onPressed: () => ref.read(staffRepositoryProvider).cancelLeave(leave.id),
                            child: Text(l10n.withdraw),
                          )
                        : null,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
