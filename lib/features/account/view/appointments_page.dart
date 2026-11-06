import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/async_view.dart';
import '../../../shared/format.dart';
import '../../../shared/ui/empty_state.dart';
import '../../../shared/ui/status_chip.dart';
import '../../auth/viewmodel/customer_session_viewmodel.dart';
import '../model/account_models.dart';
import '../viewmodel/account_viewmodel.dart';

/// Az ügyfél foglalásai: közelgő és korábbi (View) – dátum-blokkal és állapot-jelvénnyel ellátott kártyák.
class AppointmentsPage extends ConsumerWidget {
  const AppointmentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myAppointments),
        actions: [
          IconButton(
            tooltip: l10n.signOut,
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => ref.read(customerSessionProvider.notifier).signOut(),
          ),
        ],
      ),
      body: AsyncView<AccountOverview>(
        value: ref.watch(accountViewModelProvider),
        onRetry: () => ref.invalidate(accountViewModelProvider),
        builder: (context, data) => RefreshIndicator(
          onRefresh: () => ref.refresh(accountViewModelProvider.future),
          child: ListView(
            padding: const EdgeInsets.all(AppDimens.pagePadding),
            children: [
              _Section(title: l10n.upcoming, empty: l10n.noUpcoming, items: data.upcoming),
              const SizedBox(height: 16),
              _Section(title: l10n.past, empty: l10n.noPast, items: data.past, muted: true),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.empty, required this.items, this.muted = false});

  final String title;
  final String empty;
  final List<AccountAppointment> items;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        if (items.isEmpty) EmptyNote(empty, icon: muted ? Icons.history_rounded : Icons.event_available_outlined),
        for (final item in items) _AppointmentCard(item: item, muted: muted),
      ],
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({required this.item, required this.muted});

  final AccountAppointment item;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final token = item.manageToken;

    return Opacity(
      opacity: muted ? 0.8 : 1,
      child: Card(
        child: InkWell(
          onTap: token == null ? null : () => context.push('/manage/$token'),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                DateBadge(item.startsAt),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.service, style: theme.textTheme.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(
                        item.business,
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(children: [
                        Icon(Icons.schedule_rounded, size: 14, color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(formatTime(context, item.startsAt), style: theme.textTheme.bodySmall),
                        if (item.staff != null) ...[
                          const SizedBox(width: 10),
                          Icon(Icons.person_outline_rounded, size: 14, color: theme.colorScheme.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Flexible(child: Text(item.staff!, style: theme.textTheme.bodySmall, overflow: TextOverflow.ellipsis)),
                        ],
                      ]),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                StatusChip(item.status),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
