import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/api/api_exception.dart';
import '../../core/auth/auth_controller.dart';
import '../../l10n/app_localizations.dart';
import 'account_models.dart';
import 'account_repository.dart';

/// Az ügyfél foglalásai: közelgő és korábbi.
class AppointmentsPage extends ConsumerWidget {
  const AppointmentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final overview = ref.watch(accountOverviewProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myAppointments),
        actions: [
          IconButton(
            tooltip: l10n.signOut,
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      body: overview.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(error is ApiException && error.isNetwork ? l10n.networkError : l10n.genericError),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => ref.invalidate(accountOverviewProvider),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
        data: (data) => RefreshIndicator(
          onRefresh: () => ref.refresh(accountOverviewProvider.future),
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
            ),
          ),
      ],
    );
  }
}
