import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/async_view.dart';
import '../../../shared/flash.dart';
import '../../staff/viewmodel/staff_session_viewmodel.dart';
import '../model/owner_models.dart';
import '../viewmodel/owner_staff_viewmodels.dart';

/// A vállalkozás munkatársai (View): aktív / inaktív váltó, koppintásra név és telefonszám szerkesztése.
class OwnerStaffPage extends ConsumerWidget {
  const OwnerStaffPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    listenFlash(ref, context, staffManageProvider.select((s) => s.flash));
    final businessId = ref.watch(staffSessionProvider).value?.businessId;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.ownerStaff)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/owner/staff/new'),
        icon: const Icon(Icons.add),
        label: Text(l10n.newStaff),
      ),
      body: businessId == null
          ? Center(child: Text(l10n.ownerNoBusiness))
          : AsyncView<List<OwnerStaff>>(
              value: ref.watch(ownerStaffProvider(businessId)),
              onRetry: () => ref.invalidate(ownerStaffProvider(businessId)),
              builder: (context, staff) => RefreshIndicator(
                onRefresh: () => ref.refresh(ownerStaffProvider(businessId).future),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
                  children: [
                    if (staff.isEmpty) Text(l10n.nothingYet),
                    for (final s in staff) _StaffTile(staff: s, businessId: businessId),
                  ],
                ),
              ),
            ),
    );
  }
}

class _StaffTile extends ConsumerWidget {
  const _StaffTile({required this.staff, required this.businessId});

  final OwnerStaff staff;
  final int businessId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: ListTile(
        title: Text(staff.name),
        subtitle: Text(
          [
            l10n.upcomingBookings(staff.upcomingCount),
            if (staff.hasAccount) l10n.staffHasAccount,
            if (staff.phone != null && staff.phone!.isNotEmpty) staff.phone!,
          ].join(' · '),
        ),
        trailing: Switch(
          value: staff.isActive,
          onChanged: (v) => ref.read(staffManageProvider.notifier).setActive(businessId, staff.id, v),
        ),
        onTap: () => context.push('/owner/staff/${staff.id}'),
      ),
    );
  }
}
