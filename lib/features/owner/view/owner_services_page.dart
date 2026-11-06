import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/async_view.dart';
import '../../../shared/flash.dart';
import '../../../shared/format.dart';
import '../../staff/viewmodel/staff_session_viewmodel.dart';
import '../model/owner_models.dart';
import '../viewmodel/owner_service_viewmodels.dart';

/// A vállalkozás szolgáltatásainak gyors szerkesztése (View): aktív / inaktív váltó, koppintásra név, időtartam, ár.
class OwnerServicesPage extends ConsumerWidget {
  const OwnerServicesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    listenFlash(ref, context, serviceActionsProvider.select((s) => s.flash));
    final businessId = ref.watch(staffSessionProvider).value?.businessId;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.ownerServices)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/owner/services/new'),
        icon: const Icon(Icons.add),
        label: Text(l10n.newService),
      ),
      body: businessId == null
          ? Center(child: Text(l10n.ownerNoBusiness))
          : AsyncView<List<OwnerService>>(
              value: ref.watch(ownerServicesProvider(businessId)),
              onRetry: () => ref.invalidate(ownerServicesProvider(businessId)),
              builder: (context, services) => RefreshIndicator(
                onRefresh: () => ref.refresh(ownerServicesProvider(businessId).future),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
                  children: [
                    if (services.isEmpty) Text(l10n.nothingYet),
                    for (final s in services) _ServiceTile(service: s, businessId: businessId),
                  ],
                ),
              ),
            ),
    );
  }
}

class _ServiceTile extends ConsumerWidget {
  const _ServiceTile({required this.service, required this.businessId});

  final OwnerService service;
  final int businessId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final actions = ref.read(serviceActionsProvider.notifier);

    return Card(
      child: ListTile(
        title: Text(service.name),
        subtitle: Text(
          [
            l10n.minutes(service.durationMinutes),
            if (service.priceHuf != null) formatHuf(context, service.priceHuf!),
            if (service.isGroup) l10n.groupSessions,
            if (service.isRental) l10n.serviceRental,
          ].join(' · '),
        ),
        trailing: Switch(value: service.isActive, onChanged: (v) => actions.setActive(businessId, service.id, v)),
        onTap: () => context.push('/owner/services/${service.id}'),
      ),
    );
  }
}
