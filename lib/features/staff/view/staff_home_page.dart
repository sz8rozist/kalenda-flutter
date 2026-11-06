import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/ui/floating_nav_bar.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/async_view.dart';
import '../../../shared/flash.dart';
import '../../../shared/format.dart';
import '../../../shared/ui/empty_state.dart';
import '../../../shared/ui/status_chip.dart';
import '../../../shared/week_header.dart';
import '../../admin/view/admin_home_page.dart';
import '../../app_lock/view/app_lock_settings.dart';
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

    if (user.isAdmin) return const AdminHomePage();

    if (user.isOwner && user.businessId != null) {
      return OwnerHomePage(user: user, businessId: user.businessId!);
    }

    if (!user.isStaff) {
      return Scaffold(
        appBar: AppBar(actions: const [SettingsButton(), _SignOutButton()]),
        body: user.isOwner
            ? Center(child: Text(l10n.staffNoProfile, textAlign: TextAlign.center))
            : EmptyState(
                icon: Icons.storefront_outlined,
                title: l10n.setupCta,
                message: l10n.setupCtaText,
                actionLabel: l10n.setupCreate,
                onAction: () => context.push('/owner/setup'),
              ),
      );
    }

    final index = ref.watch(staffTabProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(user.businessName ?? l10n.appTitle),
        actions: [
          IconButton(tooltip: l10n.portalTimesheetTitle, icon: const Icon(Icons.timer_outlined), onPressed: () => context.push('/staff/timesheet')),
          IconButton(tooltip: l10n.portalProfileTitle, icon: const Icon(Icons.person_outline), onPressed: () => context.push('/staff/profile')),
          const SettingsButton(),
          const _SignOutButton(),
        ],
      ),
      body: IndexedStack(index: index, children: const [_TodayTab(), _CalendarTab(), _LeavesTab()]),
      bottomNavigationBar: FloatingNavigationBar(
        selectedIndex: index,
        onDestinationSelected: ref.read(staffTabProvider.notifier).select,
        destinations: [
          NavigationDestination(icon: const Icon(Icons.today_outlined), selectedIcon: const Icon(Icons.today), label: l10n.staffToday),
          NavigationDestination(
            icon: const Icon(Icons.calendar_month_outlined),
            selectedIcon: const Icon(Icons.calendar_month),
            label: l10n.staffCalendar,
          ),
          NavigationDestination(
            icon: const Icon(Icons.beach_access_outlined),
            selectedIcon: const Icon(Icons.beach_access),
            label: l10n.staffLeaves,
          ),
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
            if (data.upcoming.isEmpty) EmptyNote(l10n.noAppointments, icon: Icons.event_available_outlined),
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
        trailing: FilledButton(onPressed: busy ? null : toggle, child: Text(clock.isClockedIn ? l10n.clockOut : l10n.clockIn)),
      ),
    );
  }
}

/// Egy foglalás a listában (dátum-blokk, szolgáltatás, ügyfél, állapot-jelvény); koppintásra megnyílik a kezelő lap.
class AppointmentTile extends StatelessWidget {
  const AppointmentTile({super.key, required this.appointment, this.businessId});

  final PortalAppointment appointment;
  final int? businessId;

  @override
  Widget build(BuildContext context) {
    final a = appointment;
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: () => businessId == null ? showAppointmentSheet(context, a) : context.push('/owner/appointments/${a.id}'),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              DateBadge(a.startsAt),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.serviceName, style: theme.textTheme.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.schedule_rounded, size: 14, color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(formatTime(context, a.startsAt), style: theme.textTheme.bodySmall),
                        if (a.customerName != null) ...[
                          const SizedBox(width: 10),
                          Icon(Icons.person_outline_rounded, size: 14, color: theme.colorScheme.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(a.customerName!, style: theme.textTheme.bodySmall, overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusChip(a.status),
            ],
          ),
        ),
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
                children: [for (var i = 0; i < 7; i++) ..._day(context, range.from.add(Duration(days: i)), calendar)],
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

    final appointments = calendar.appointments.where((a) => sameDay(a.startsAt)).toList()..sort((a, b) => a.startsAt.compareTo(b.startsAt));
    final onLeave = calendar.leaves.any((l) => !day.isBefore(l.dateFrom) && !day.isAfter(l.dateTo));

    return [
      Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 4),
        child: Row(
          children: [
            Text(formatDate(context, day), style: Theme.of(context).textTheme.titleSmall),
            if (onLeave) ...[const SizedBox(width: 8), StatusChip('approved', label: l10n.leaveDay)],
          ],
        ),
      ),
      if (appointments.isEmpty)
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(l10n.noAppointments, style: Theme.of(context).textTheme.bodySmall),
        ),
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
        content: TextField(
          controller: reason,
          decoration: InputDecoration(labelText: l10n.leaveReason),
        ),
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
              if (leaves.isEmpty) EmptyNote(l10n.nothingYet, icon: Icons.beach_access_outlined),
              for (final leave in leaves)
                Card(
                  child: ListTile(
                    title: Text('${formatDate(context, leave.dateFrom)} – ${formatDate(context, leave.dateTo)}'),
                    subtitle: leave.reason == null ? null : Text(leave.reason!),
                    leading: StatusChip(leave.status),
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
