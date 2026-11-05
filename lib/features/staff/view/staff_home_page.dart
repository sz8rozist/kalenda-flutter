import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/async_view.dart';
import '../../../shared/flash.dart';
import '../../../shared/format.dart';
import '../../../shared/week_header.dart';
import '../../owner/view/owner_home_page.dart';
import '../model/staff_models.dart';
import '../viewmodel/staff_session_viewmodel.dart';
import '../viewmodel/staff_viewmodels.dart';
import 'appointment_sheet.dart';
import 'staff_login_page.dart';

/// A munkatársi felület (View): belépés nélkül a belépő oldal; vállalkozónak a vállalkozói felület;
/// munkatársnak három fül (Ma, Naptár, Szabadság).
class StaffHomePage extends ConsumerWidget {
  const StaffHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(staffSessionProvider);

    if (session.isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final user = session.value;
    if (user == null) return const StaffLoginPage();

    if (user.isOwner && user.businessId != null) {
      return OwnerHomePage(user: user, businessId: user.businessId!);
    }

    if (!user.isStaff) {
      return Scaffold(
        appBar: AppBar(actions: const [_SignOutButton()]),
        body: Center(
          child: Padding(padding: const EdgeInsets.all(24), child: Text(l10n.staffNoProfile, textAlign: TextAlign.center)),
        ),
      );
    }

    final index = ref.watch(staffTabProvider);
    return Scaffold(
      appBar: AppBar(title: Text(user.businessName ?? l10n.appTitle), actions: const [_SignOutButton()]),
      body: IndexedStack(index: index, children: const [_TodayTab(), _CalendarTab(), _LeavesTab()]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: ref.read(staffTabProvider.notifier).select,
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
  const _SignOutButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) => IconButton(
        tooltip: AppLocalizations.of(context).signOut,
        icon: const Icon(Icons.logout),
        onPressed: () => ref.read(staffSessionProvider.notifier).signOut(),
      );
}

// ─── Ma ──────────────────────────────────────────────────────

class _TodayTab extends ConsumerWidget {
  const _TodayTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    listenFlash(ref, context, staffActionsProvider.select((s) => s.flash));

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

class _ClockCard extends ConsumerWidget {
  const _ClockCard({required this.clock});

  final ClockState clock;

  /// Kicsekkolás előtt: mennyi szünetet tartott (perc). Mégse = null. (A párbeszéd a View dolga.)
  Future<int?> _askBreakMinutes(BuildContext context) {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final busy = ref.watch(staffActionsProvider.select((s) => s.busy));
    final actions = ref.read(staffActionsProvider.notifier);

    Future<void> toggle() async {
      if (!clock.isClockedIn) return actions.clockIn();
      final minutes = await _askBreakMinutes(context);
      if (minutes != null) await actions.clockOut(breakMinutes: minutes);
    }

    return Card(
      child: ListTile(
        leading: Icon(clock.isClockedIn ? Icons.timer : Icons.timer_outlined),
        title: Text(clock.isClockedIn ? l10n.clockedInSince(formatDateTime(context, clock.openSince!)) : l10n.clockIn),
        trailing: FilledButton(
          onPressed: busy ? null : toggle,
          child: Text(clock.isClockedIn ? l10n.clockOut : l10n.clockIn),
        ),
      ),
    );
  }
}

/// Egy foglalás a listában; koppintásra megnyílik a kezelő lap.
class AppointmentTile extends StatelessWidget {
  const AppointmentTile({super.key, required this.appointment, this.businessId});

  final PortalAppointment appointment;
  final int? businessId;

  @override
  Widget build(BuildContext context) {
    final a = appointment;
    return Card(
      child: ListTile(
        title: Text('${formatTime(context, a.startsAt)} – ${a.serviceName}'),
        subtitle: Text([formatDate(context, a.startsAt), if (a.customerName != null) a.customerName!].join(' · ')),
        trailing: Text(statusLabel(context, a.status)),
        onTap: () => showAppointmentSheet(context, a, businessId: businessId),
      ),
    );
  }
}

// ─── Naptár ──────────────────────────────────────────────────

class _CalendarTab extends ConsumerWidget {
  const _CalendarTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekStart = ref.watch(staffWeekProvider);
    final range = (from: weekStart, to: weekStart.add(const Duration(days: 6)));

    return Column(
      children: [
        WeekHeader(weekStart: weekStart, onShift: ref.read(staffWeekProvider.notifier).shift),
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

  /// Az adatbekérés (időszak, indok) a View dolga; a beküldést a ViewModel végzi.
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
    if (confirmed == true) {
      await ref.read(staffActionsProvider.notifier).requestLeave(range.start, range.end, reason.text.trim());
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final actions = ref.read(staffActionsProvider.notifier);

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
                        ? TextButton(onPressed: () => actions.cancelLeave(leave.id), child: Text(l10n.withdraw))
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
