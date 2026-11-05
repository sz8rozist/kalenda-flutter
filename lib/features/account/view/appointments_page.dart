import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/async_view.dart';
import '../../auth/viewmodel/customer_session_viewmodel.dart';
import '../model/account_models.dart';
import '../viewmodel/account_viewmodel.dart';

/// Az ügyfél foglalásai: közelgő és korábbi (View).
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
            icon: const Icon(Icons.logout),
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
            padding: const EdgeInsets.all(16),
            children: [
              _Section(title: l10n.upcoming, empty: l10n.noUpcoming, items: data.upcoming),
              const SizedBox(height: 24),
              _Section(title: l10n.past, empty: l10n.noPast, items: data.past),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.empty, required this.items});

  final String title;
  final String empty;
  final List<AccountAppointment> items;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final dateFormat = DateFormat.yMMMd(locale).add_Hm();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (items.isEmpty) Text(empty),
        for (final item in items)
          Card(
            child: ListTile(
              title: Text('${item.business} – ${item.service}'),
              subtitle: Text([dateFormat.format(item.startsAt), if (item.staff != null) item.staff!].join(' · ')),
              trailing: Text(item.status),
              onTap: item.manageToken == null ? null : () => context.push('/manage/${item.manageToken}'),
            ),
          ),
      ],
    );
  }
}
