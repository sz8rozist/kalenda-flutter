import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/async_view.dart';
import '../../../shared/format.dart';
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
          IconButton(
            tooltip: l10n.ownerServices,
            icon: const Icon(Icons.content_cut),
            onPressed: () => context.push('/owner/services'),
          ),
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
      body: IndexedStack(index: index, children: [
        _OverviewTab(businessId: businessId),
        _CalendarTab(businessId: businessId),
        _CustomersTab(businessId: businessId),
        OwnerInvoicesTab(businessId: businessId),
        OwnerReportsTab(businessId: businessId),
      ]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: ref.read(ownerTabProvider.notifier).select,
        destinations: [
          NavigationDestination(icon: const Icon(Icons.dashboard_outlined), label: l10n.ownerOverview),
          NavigationDestination(icon: const Icon(Icons.calendar_month_outlined), label: l10n.staffCalendar),
          NavigationDestination(icon: const Icon(Icons.people_outline), label: l10n.ownerCustomers),
          NavigationDestination(icon: const Icon(Icons.receipt_long_outlined), label: l10n.ownerInvoices),
          NavigationDestination(icon: const Icon(Icons.insights_outlined), label: l10n.ownerReports),
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
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(l10n.weekRevenueTitle, style: theme.textTheme.titleSmall),
                    const SizedBox(height: 4),
                    Text(formatHuf(context, data.weekRevenue.total), style: theme.textTheme.headlineSmall),
                    Text(l10n.weekRevenueSoFar(formatHuf(context, data.weekRevenue.toDateTotal))),
                    if (change != null) Text(l10n.weekRevenueChange(change.toStringAsFixed(0))),
                  ]),
                ),
              ),
              if (data.receivables.outstandingCount > 0 || data.receivables.overdueCount > 0)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(l10n.receivablesTitle, style: theme.textTheme.titleSmall),
                      Text(l10n.receivablesOutstanding(formatHuf(context, data.receivables.outstandingHuf), data.receivables.outstandingCount)),
                      if (data.receivables.overdueCount > 0)
                        Text(l10n.receivablesOverdue(formatHuf(context, data.receivables.overdueHuf), data.receivables.overdueCount),
                            style: TextStyle(color: theme.colorScheme.error)),
                    ]),
                  ),
                ),
              if (data.lowStockCount > 0)
                Card(child: ListTile(leading: const Icon(Icons.inventory_2_outlined), title: Text(l10n.lowStock(data.lowStockCount)))),
              const SizedBox(height: 16),
              Text('${l10n.todaysBookings} (${data.appointmentsToday})', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              if (data.today.isEmpty) Text(l10n.noAppointments),
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
                children: [
                  for (var i = 0; i < 7; i++) ..._day(context, query.range.from.add(Duration(days: i)), calendar),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _day(BuildContext context, DateTime day, OwnerCalendar calendar) {
    bool sameDay(DateTime d) => d.year == day.year && d.month == day.month && d.day == day.day;
    final appointments = calendar.appointments.where((a) => sameDay(a.startsAt)).toList()
      ..sort((a, b) => a.startsAt.compareTo(b.startsAt));

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
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: l10n.searchCustomers,
              border: const OutlineInputBorder(),
            ),
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
                  if (customers.isEmpty) Text(l10n.nothingYet),
                  for (final c in customers)
                    Card(
                      child: ListTile(
                        title: Text(c.name),
                        subtitle: Text([
                          l10n.customerStats(c.totalCount, formatHuf(context, c.totalSpentHuf), c.noShowCount),
                          if (c.email != null && c.email!.isNotEmpty) c.email!,
                        ].join('\n')),
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
