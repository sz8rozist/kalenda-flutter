import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/ui/floating_nav_bar.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/async_view.dart';
import '../../../shared/format.dart';
import '../../../shared/ui/empty_state.dart';
import '../../../shared/week_header.dart';
import '../../app_lock/view/app_lock_settings.dart';
import '../../staff/model/staff_models.dart';
import '../../staff/view/staff_home_page.dart' show AppointmentTile;
import '../../staff/viewmodel/staff_session_viewmodel.dart';
import '../model/owner_models.dart';
import 'owner_invoices_tab.dart';
import 'owner_reports_tab.dart';
import '../viewmodel/owner_viewmodels.dart';

/// A vállalkozói felület (View): áttekintés, naptár, ügyfelek. Az adatokat a ViewModel-ek adják.
class OwnerHomePage extends ConsumerWidget {
  const OwnerHomePage({super.key, required this.user, required this.businessId});

  final StaffUser user;
  final int businessId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final index = ref.watch(ownerTabProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(user.businessName ?? l10n.appTitle),
        actions: [
          IconButton(tooltip: l10n.ownerMore, icon: const Icon(Icons.apps_rounded), onPressed: () => context.push('/owner/more')),
          const SettingsButton(),
          IconButton(
            tooltip: l10n.signOut,
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(staffSessionProvider.notifier).signOut(),
          ),
        ],
      ),
      floatingActionButton: index >= 2
          ? null
          : FloatingActionButton.extended(
              onPressed: () => context.push('/owner/new-booking'),
              icon: const Icon(Icons.add),
              label: Text(l10n.ownerNewBooking),
            ),
      body: IndexedStack(
        index: index,
        children: [
          _OverviewTab(businessId: businessId),
          _CalendarTab(businessId: businessId),
          _CustomersTab(businessId: businessId),
          OwnerInvoicesTab(businessId: businessId),
          OwnerReportsTab(businessId: businessId),
        ],
      ),
      bottomNavigationBar: FloatingNavigationBar(
        selectedIndex: index,
        onDestinationSelected: ref.read(ownerTabProvider.notifier).select,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard),
            label: l10n.ownerOverview,
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_month_outlined),
            selectedIcon: const Icon(Icons.calendar_month),
            label: l10n.staffCalendar,
          ),
          NavigationDestination(icon: const Icon(Icons.people_outline), selectedIcon: const Icon(Icons.people), label: l10n.ownerCustomers),
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon: const Icon(Icons.receipt_long),
            label: l10n.ownerInvoices,
          ),
          NavigationDestination(
            icon: const Icon(Icons.insights_outlined),
            selectedIcon: const Icon(Icons.insights),
            label: l10n.ownerReports,
          ),
        ],
      ),
    );
  }
}

// ─── Áttekintés ──────────────────────────────────────────────

class _OverviewTab extends ConsumerWidget {
  const _OverviewTab({required this.businessId});

  final int businessId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return AsyncView<OwnerDashboard>(
      value: ref.watch(ownerDashboardProvider(businessId)),
      onRetry: () => ref.invalidate(ownerDashboardProvider(businessId)),
      builder: (context, data) {
        final change = data.weekRevenue.changePercent;

        return RefreshIndicator(
          onRefresh: () => ref.refresh(ownerDashboardProvider(businessId).future),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatDate(context, DateTime.now()),
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                    Text(l10n.ownerOverview, style: theme.textTheme.headlineMedium),
                  ],
                ),
              ),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 10,
                  children: [
                    Expanded(
                      child: _KpiCard(
                        label: l10n.todaysBookings,
                        value: '${data.appointmentsToday}',
                        note: data.today.where((a) => a.status == 'pending').isEmpty
                            ? null
                            : l10n.kpiPendingApproval(data.today.where((a) => a.status == 'pending').length),
                        noteColor: AppColors.warning,
                      ),
                    ),
                    Expanded(
                      child: _KpiCard(
                        label: l10n.weekRevenueTitle,
                        value: formatHuf(context, data.weekRevenue.total),
                        note: change == null
                            ? l10n.weekRevenueSoFar(formatHuf(context, data.weekRevenue.toDateTotal))
                            : l10n.weekRevenueChange(change.toStringAsFixed(0)),
                        noteColor: change == null ? null : (change >= 0 ? AppColors.success : AppColors.danger),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              if (data.receivables.outstandingCount > 0 || data.receivables.overdueCount > 0)
                _KpiCard(
                  label: l10n.receivablesTitle,
                  value: formatHuf(context, data.receivables.outstandingHuf),
                  note: data.receivables.overdueCount > 0
                      ? l10n.receivablesOverdue(formatHuf(context, data.receivables.overdueHuf), data.receivables.overdueCount)
                      : l10n.kpiOpenInvoices(data.receivables.outstandingCount),
                  noteColor: data.receivables.overdueCount > 0 ? AppColors.warning : null,
                ),
              if (data.lowStockCount > 0)
                Card(
                  child: ListTile(leading: const Icon(Icons.inventory_2_outlined), title: Text(l10n.lowStock(data.lowStockCount))),
                ),
              const SizedBox(height: 16),
              Text('${l10n.todaysBookings} (${data.appointmentsToday})', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              if (data.today.isEmpty) EmptyNote(l10n.noAppointments, icon: Icons.event_available_outlined),
              for (final a in data.today) AppointmentTile(appointment: a, businessId: businessId),
            ],
          ),
        );
      },
    );
  }
}

// ─── Naptár ──────────────────────────────────────────────────

class _CalendarTab extends ConsumerWidget {
  const _CalendarTab({required this.businessId});

  final int businessId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekStart = ref.watch(ownerWeekProvider);
    final query = (businessId: businessId, range: (from: weekStart, to: weekStart.add(const Duration(days: 6))));

    return Column(
      children: [
        WeekHeader(weekStart: weekStart, onShift: ref.read(ownerWeekProvider.notifier).shift),
        Expanded(
          child: AsyncView<OwnerCalendar>(
            value: ref.watch(ownerCalendarProvider(query)),
            onRetry: () => ref.invalidate(ownerCalendarProvider(query)),
            builder: (context, calendar) => RefreshIndicator(
              onRefresh: () => ref.refresh(ownerCalendarProvider(query).future),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [for (var i = 0; i < 7; i++) ..._day(context, query.range.from.add(Duration(days: i)), calendar)],
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _day(BuildContext context, DateTime day, OwnerCalendar calendar) {
    bool sameDay(DateTime d) => d.year == day.year && d.month == day.month && d.day == day.day;
    final appointments = calendar.appointments.where((a) => sameDay(a.startsAt)).toList()..sort((a, b) => a.startsAt.compareTo(b.startsAt));

    return [
      Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 4),
        child: Text(formatDate(context, day), style: Theme.of(context).textTheme.titleSmall),
      ),
      if (appointments.isEmpty) Text(AppLocalizations.of(context).noAppointments, style: Theme.of(context).textTheme.bodySmall),
      for (final a in appointments) AppointmentTile(appointment: a, businessId: businessId),
    ];
  }
}

// ─── Ügyfelek ────────────────────────────────────────────────

class _CustomersTab extends ConsumerStatefulWidget {
  const _CustomersTab({required this.businessId});

  final int businessId;

  @override
  ConsumerState<_CustomersTab> createState() => _CustomersTabState();
}

class _CustomersTabState extends ConsumerState<_CustomersTab> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final id = widget.businessId;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _search,
            textInputAction: TextInputAction.search,
            onSubmitted: ref.read(customerSearchProvider.notifier).search,
            decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: l10n.searchCustomers),
          ),
        ),
        Expanded(
          child: AsyncView<List<CustomerItem>>(
            value: ref.watch(ownerCustomersProvider(id)),
            onRetry: () => ref.invalidate(ownerCustomersProvider(id)),
            builder: (context, customers) => RefreshIndicator(
              onRefresh: () => ref.refresh(ownerCustomersProvider(id).future),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  if (customers.isEmpty) EmptyNote(l10n.nothingYet, icon: Icons.people_outline),
                  for (final c in customers)
                    Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                          child: Text(c.name.isEmpty ? '?' : c.name.characters.first.toUpperCase()),
                        ),
                        onTap: () => context.push('/owner/customers/${c.id}'),
                        title: Text(c.name),
                        subtitle: Text(
                          [
                            l10n.customerStats(c.totalCount, formatHuf(context, c.totalSpentHuf), c.noShowCount),
                            if (c.email != null && c.email!.isNotEmpty) c.email!,
                          ].join('\n'),
                        ),
                        isThreeLine: c.email != null && c.email!.isNotEmpty,
                        trailing: c.phone == null || c.phone!.isEmpty
                            ? null
                            : IconButton(
                                tooltip: l10n.call,
                                icon: const Icon(Icons.phone_outlined),
                                onPressed: () => launchUrl(Uri(scheme: 'tel', path: c.phone)),
                              ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Egy kulcsszám-kártya az áttekintésen (design: fehér, keretes; címke, nagy érték, színes megjegyzés).
class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.label, required this.value, this.note, this.noteColor});

  final String label;
  final String value;
  final String? note;
  final Color? noteColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelMedium?.copyWith(color: muted)),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, fontSize: 22),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (note != null)
            Text(
              note!,
              style: theme.textTheme.labelMedium?.copyWith(color: noteColor ?? muted, fontWeight: FontWeight.w600),
            ),
        ],
      ),
    );
  }
}
