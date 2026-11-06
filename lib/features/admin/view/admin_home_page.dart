import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/async_view.dart';
import '../../../shared/flash.dart';
import '../../../shared/format.dart';
import '../../../shared/ui/empty_state.dart';
import '../../../shared/ui/status_chip.dart';
import '../../app_lock/view/app_lock_settings.dart';
import '../../staff/viewmodel/staff_session_viewmodel.dart';
import '../model/admin_models.dart';
import '../viewmodel/admin_viewmodels.dart';

/// A platform-adminisztrátor felülete (View): áttekintés, vállalkozások, foglalások, visszajelzések.
class AdminHomePage extends ConsumerStatefulWidget {
  const AdminHomePage({super.key});

  @override
  ConsumerState<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends ConsumerState<AdminHomePage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    listenFlash(ref, context, adminActionsProvider.select((s) => s.flash));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminTitle),
        actions: [
          const SettingsButton(),
          IconButton(
            tooltip: l10n.signOut,
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(staffSessionProvider.notifier).signOut(),
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: const [_Overview(), _Businesses(), _Appointments(), _Feedback()]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard),
            label: l10n.adminOverview,
          ),
          NavigationDestination(
            icon: const Icon(Icons.storefront_outlined),
            selectedIcon: const Icon(Icons.storefront),
            label: l10n.adminBusinesses,
          ),
          NavigationDestination(
            icon: const Icon(Icons.event_note_outlined),
            selectedIcon: const Icon(Icons.event_note),
            label: l10n.adminAppointments,
          ),
          NavigationDestination(icon: const Icon(Icons.forum_outlined), selectedIcon: const Icon(Icons.forum), label: l10n.adminFeedback),
        ],
      ),
    );
  }
}

class _Overview extends ConsumerWidget {
  const _Overview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return AsyncView<AdminDashboard>(
      value: ref.watch(adminDashboardProvider),
      onRetry: () => ref.invalidate(adminDashboardProvider),
      builder: (context, d) {
        Widget tile(IconData icon, String text) => Card(
          child: ListTile(
            leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
            title: Text(text),
          ),
        );

        return RefreshIndicator(
          onRefresh: () => ref.refresh(adminDashboardProvider.future),
          child: ListView(
            padding: const EdgeInsets.all(AppDimens.pagePadding),
            children: [
              tile(Icons.people_outline, l10n.adminUsers(d.users)),
              tile(Icons.storefront_outlined, l10n.adminBusinessCount(d.businesses)),
              tile(Icons.event_note_outlined, l10n.adminAppointmentCount(d.appointments)),
              tile(Icons.today_outlined, '${l10n.adminToday(d.appointmentsToday)} · ${l10n.adminThisMonth(d.appointmentsThisMonth)}'),
              tile(Icons.workspace_premium_outlined, l10n.adminActiveSubscriptions(d.activeSubscriptions)),
              tile(Icons.layers_outlined, l10n.adminPlans(d.freePlan, d.basicPlan, d.professionalPlan)),
            ],
          ),
        );
      },
    );
  }
}

class _Businesses extends ConsumerStatefulWidget {
  const _Businesses();

  @override
  ConsumerState<_Businesses> createState() => _BusinessesState();
}

class _BusinessesState extends ConsumerState<_Businesses> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final actions = ref.read(adminActionsProvider.notifier);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _search,
            textInputAction: TextInputAction.search,
            onSubmitted: ref.read(adminSearchProvider.notifier).search,
            decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: l10n.searchCustomers),
          ),
        ),
        Expanded(
          child: AsyncView<List<AdminBusiness>>(
            value: ref.watch(adminBusinessesProvider),
            onRetry: () => ref.invalidate(adminBusinessesProvider),
            builder: (context, list) => RefreshIndicator(
              onRefresh: () => ref.refresh(adminBusinessesProvider.future),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  if (list.isEmpty) EmptyNote(l10n.nothingYet, icon: Icons.storefront_outlined),
                  for (final b in list)
                    Card(
                      child: ListTile(
                        title: Text(b.name),
                        subtitle: Text([?b.city, b.plan, ?b.ownerEmail, '${b.appointments} · ${b.staff}'].join(' · ')),
                        trailing: Switch(value: b.isActive, onChanged: (_) => actions.toggleBusiness(b.id)),
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

class _StatusChips extends StatelessWidget {
  const _StatusChips({required this.options, required this.selected, required this.onSelected});

  final List<(String, String)> options;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.all(12),
    child: Row(
      spacing: 8,
      children: [
        for (final (value, label) in options)
          ChoiceChip(label: Text(label), selected: selected == value, onSelected: (_) => onSelected(value)),
      ],
    ),
  );
}

class _Appointments extends ConsumerWidget {
  const _Appointments();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final status = ref.watch(adminAppointmentStatusProvider);

    return Column(
      children: [
        _StatusChips(
          options: [
            ('', l10n.adminAllStatuses),
            ('pending', l10n.statusPending),
            ('confirmed', l10n.statusConfirmed),
            ('completed', l10n.statusCompleted),
            ('cancelled', l10n.statusCancelled),
          ],
          selected: status,
          onSelected: ref.read(adminAppointmentStatusProvider.notifier).select,
        ),
        Expanded(
          child: AsyncView<List<AdminAppointment>>(
            value: ref.watch(adminAppointmentsProvider),
            onRetry: () => ref.invalidate(adminAppointmentsProvider),
            builder: (context, list) => RefreshIndicator(
              onRefresh: () => ref.refresh(adminAppointmentsProvider.future),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  if (list.isEmpty) EmptyNote(l10n.nothingYet, icon: Icons.event_note_outlined),
                  for (final a in list)
                    Card(
                      child: ListTile(
                        leading: a.startsAt == null ? null : DateBadge(a.startsAt!),
                        title: Text([?a.service, ?a.business].join(' · ')),
                        subtitle: Text([?a.customer, ?a.staff, if (a.startsAt != null) formatTime(context, a.startsAt!)].join(' · ')),
                        trailing: StatusChip(a.status),
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

class _Feedback extends ConsumerWidget {
  const _Feedback();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final status = ref.watch(adminFeedbackStatusProvider);

    String statusText(String s) => switch (s) {
      'in_progress' => l10n.feedbackStatusInProgress,
      'resolved' => l10n.feedbackStatusResolved,
      'rejected' => l10n.feedbackStatusRejected,
      _ => l10n.feedbackStatusNew,
    };

    return Column(
      children: [
        _StatusChips(
          options: [
            ('', l10n.adminAllStatuses),
            ('new', l10n.feedbackStatusNew),
            ('in_progress', l10n.feedbackStatusInProgress),
            ('resolved', l10n.feedbackStatusResolved),
            ('rejected', l10n.feedbackStatusRejected),
          ],
          selected: status,
          onSelected: ref.read(adminFeedbackStatusProvider.notifier).select,
        ),
        Expanded(
          child: AsyncView<List<AdminFeedback>>(
            value: ref.watch(adminFeedbackProvider),
            onRetry: () => ref.invalidate(adminFeedbackProvider),
            builder: (context, list) => RefreshIndicator(
              onRefresh: () => ref.refresh(adminFeedbackProvider.future),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  if (list.isEmpty) EmptyNote(l10n.nothingYet, icon: Icons.forum_outlined),
                  for (final f in list)
                    Card(
                      child: ListTile(
                        leading: Icon(
                          f.type == 'bug' ? Icons.bug_report_outlined : Icons.lightbulb_outline,
                          color: f.type == 'bug' ? AppColors.danger : AppColors.warning,
                        ),
                        title: Text(f.subject),
                        subtitle: Text([?f.userName, ?f.businessName, statusText(f.status)].join(' · ')),
                        onTap: () => showModalBottomSheet<void>(
                          context: context,
                          isScrollControlled: true,
                          showDragHandle: true,
                          builder: (_) => _FeedbackSheet(feedback: f),
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

class _FeedbackSheet extends ConsumerStatefulWidget {
  const _FeedbackSheet({required this.feedback});

  final AdminFeedback feedback;

  @override
  ConsumerState<_FeedbackSheet> createState() => _FeedbackSheetState();
}

class _FeedbackSheetState extends ConsumerState<_FeedbackSheet> {
  late final _answer = TextEditingController(text: widget.feedback.adminResponse ?? '');
  late String _status = widget.feedback.status;

  @override
  void dispose() {
    _answer.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final navigator = Navigator.of(context);
    final ok = await ref.read(adminActionsProvider.notifier).answerFeedback(widget.feedback.id, status: _status, response: _answer.text);
    if (ok) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final busy = ref.watch(adminActionsProvider.select((s) => s.busy));

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.feedback.subject, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(widget.feedback.message),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _status,
              decoration: InputDecoration(labelText: l10n.status),
              items: [
                DropdownMenuItem(value: 'new', child: Text(l10n.feedbackStatusNew)),
                DropdownMenuItem(value: 'in_progress', child: Text(l10n.feedbackStatusInProgress)),
                DropdownMenuItem(value: 'resolved', child: Text(l10n.feedbackStatusResolved)),
                DropdownMenuItem(value: 'rejected', child: Text(l10n.feedbackStatusRejected)),
              ],
              onChanged: (v) => setState(() => _status = v ?? _status),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _answer,
              maxLines: 4,
              decoration: InputDecoration(labelText: l10n.feedbackAnswer, hintText: l10n.feedbackAnswerPlaceholder),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: busy ? null : _save, child: Text(l10n.save)),
          ],
        ),
      ),
    );
  }
}
