import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/async_view.dart';
import '../../../shared/flash.dart';
import '../../../shared/format.dart';
import '../../../shared/ui/app_alerts.dart';
import '../../../shared/ui/empty_state.dart';
import '../../staff/viewmodel/staff_session_viewmodel.dart';
import '../model/misc_models.dart';
import '../model/owner_models.dart';
import '../viewmodel/owner_staff_viewmodels.dart';
import '../viewmodel/owner_tools_viewmodels.dart';

/// Letöltés + megnyitás; ha az eszközön nincs a fájlhoz alkalmazás, figyelmeztet.
Future<void> exportAndOpen(BuildContext context, OwnerMiscActionsViewModel viewModel, Future<bool> Function() action) async {
  final l10n = AppLocalizations.of(context);
  final ok = await action();
  if (ok && viewModel.fileNotOpened && context.mounted) showToast(context, l10n.fileNotOpened, kind: AlertKind.warning);
}

/// A felvett szabadságok (zárva tartások) és az új felvétele (View).
class OwnerTimeOffPage extends ConsumerWidget {
  const OwnerTimeOffPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final businessId = ref.watch(staffSessionProvider).value?.businessId;
    listenFlash(ref, context, ownerMiscActionsProvider.select((s) => s.flash));
    final actions = ref.read(ownerMiscActionsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.ownerAddLeave)),
      floatingActionButton: businessId == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                showDragHandle: true,
                builder: (_) => _LeaveSheet(businessId: businessId),
              ),
              icon: const Icon(Icons.add),
              label: Text(l10n.ownerAddLeave),
            ),
      body: businessId == null
          ? Center(child: Text(l10n.ownerNoBusiness))
          : AsyncView<List<OwnerLeave>>(
              value: ref.watch(ownerLeavesProvider(businessId)),
              onRetry: () => ref.invalidate(ownerLeavesProvider(businessId)),
              builder: (context, leaves) => RefreshIndicator(
                onRefresh: () => ref.refresh(ownerLeavesProvider(businessId).future),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  children: [
                    if (leaves.isEmpty) EmptyNote(l10n.nothingYet, icon: Icons.beach_access_outlined),
                    for (final leave in leaves)
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.beach_access_outlined),
                          title: Text('${formatDate(context, leave.dateFrom)} – ${formatDate(context, leave.dateTo)}'),
                          subtitle: Text(
                            [
                              leave.staffName ?? l10n.leaveWholeBusiness,
                              ?leave.reason,
                              if (leave.affectedCount > 0) l10n.leaveAffected(leave.affectedCount),
                            ].join(' · '),
                          ),
                          trailing: IconButton(
                            tooltip: l10n.actionDelete,
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => actions.deleteLeave(businessId, leave.id),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _LeaveSheet extends ConsumerStatefulWidget {
  const _LeaveSheet({required this.businessId});

  final int businessId;

  @override
  ConsumerState<_LeaveSheet> createState() => _LeaveSheetState();
}

class _LeaveSheetState extends ConsumerState<_LeaveSheet> {
  final _reason = TextEditingController();
  int? _staffId;
  DateTime _from = DateTime.now();
  DateTime _to = DateTime.now();
  bool _cancelAffected = false;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _pickRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      initialDateRange: DateTimeRange(start: _from, end: _to),
    );
    if (picked != null) {
      setState(() {
        _from = picked.start;
        _to = picked.end;
      });
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final navigator = Navigator.of(context);
    final viewModel = ref.read(ownerMiscActionsProvider.notifier);
    final ok = await viewModel.createLeave(
      widget.businessId,
      staffId: _staffId,
      from: _from,
      to: _to,
      reason: _reason.text,
      cancelAffected: _cancelAffected,
    );
    if (!ok) return;
    if (viewModel.lastAffected > 0 && mounted) {
      showToast(context, l10n.leaveCreatedAffected(viewModel.lastAffected), kind: AlertKind.warning);
    }
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final busy = ref.watch(ownerMiscActionsProvider.select((s) => s.busy));
    final staff = ref.watch(ownerStaffProvider(widget.businessId)).value ?? const <OwnerStaff>[];

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<int?>(
              initialValue: _staffId,
              decoration: InputDecoration(labelText: l10n.staffLabel),
              items: [
                DropdownMenuItem<int?>(value: null, child: Text(l10n.leaveWholeBusiness)),
                for (final s in staff) DropdownMenuItem<int?>(value: s.id, child: Text(s.name)),
              ],
              onChanged: (v) => setState(() => _staffId = v),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.date_range_rounded),
              label: Text('${formatDate(context, _from)} – ${formatDate(context, _to)}'),
              onPressed: _pickRange,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _reason,
              decoration: InputDecoration(labelText: l10n.leaveReason),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.leaveCancelAffected),
              value: _cancelAffected,
              onChanged: (v) => setState(() => _cancelAffected = v),
            ),
            FilledButton(onPressed: busy ? null : _save, child: Text(l10n.save)),
          ],
        ),
      ),
    );
  }
}

/// A vállalkozó értesítései (View).
class OwnerNotificationsPage extends ConsumerWidget {
  const OwnerNotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final businessId = ref.watch(staffSessionProvider).value?.businessId;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.ownerNotifications),
        actions: [
          if (businessId != null)
            TextButton(
              onPressed: () => ref.read(ownerMiscActionsProvider.notifier).readAllNotifications(businessId),
              child: Text(l10n.markAllRead),
            ),
        ],
      ),
      body: businessId == null
          ? Center(child: Text(l10n.ownerNoBusiness))
          : AsyncView<NotificationListing>(
              value: ref.watch(notificationsProvider(businessId)),
              onRetry: () => ref.invalidate(notificationsProvider(businessId)),
              builder: (context, data) => RefreshIndicator(
                onRefresh: () => ref.refresh(notificationsProvider(businessId).future),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (data.notifications.isEmpty) EmptyNote(l10n.nothingYet, icon: Icons.notifications_none_rounded),
                    for (final n in data.notifications)
                      Card(
                        child: ListTile(
                          leading: Icon(
                            n.isRead ? Icons.notifications_none_rounded : Icons.notifications_active_rounded,
                            color: n.isRead ? null : Theme.of(context).colorScheme.primary,
                          ),
                          title: Text(n.message, style: TextStyle(fontWeight: n.isRead ? FontWeight.w400 : FontWeight.w700)),
                          subtitle: n.createdAt == null ? null : Text(formatDateTime(context, n.createdAt!)),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
