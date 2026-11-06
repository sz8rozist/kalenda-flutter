import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/async_view.dart';
import '../../../shared/flash.dart';
import '../../../shared/format.dart';
import '../../staff/viewmodel/staff_session_viewmodel.dart';
import '../model/owner_models.dart';
import '../viewmodel/owner_leave_viewmodels.dart';

/// A munkatársak szabadság-igényei (View): a vállalkozó jóváhagyja vagy elutasítja őket.
class OwnerLeavesPage extends ConsumerWidget {
  const OwnerLeavesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    listenFlash(ref, context, leaveDecisionProvider.select((s) => s.flash));
    final businessId = ref.watch(staffSessionProvider).value?.businessId;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.ownerLeaves)),
      body: businessId == null
          ? Center(child: Text(l10n.ownerNoBusiness))
          : AsyncView<List<OwnerLeaveRequest>>(
              value: ref.watch(ownerLeaveRequestsProvider(businessId)),
              onRetry: () => ref.invalidate(ownerLeaveRequestsProvider(businessId)),
              builder: (context, requests) => RefreshIndicator(
                onRefresh: () => ref.refresh(ownerLeaveRequestsProvider(businessId).future),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (requests.isEmpty) Text(l10n.noPendingLeaves),
                    for (final r in requests) _RequestCard(request: r, businessId: businessId),
                  ],
                ),
              ),
            ),
    );
  }
}

class _RequestCard extends ConsumerWidget {
  const _RequestCard({required this.request, required this.businessId});

  final OwnerLeaveRequest request;
  final int businessId;

  /// Az elutasítás indoka (nem kötelező): a párbeszéd a View dolga. Mégse = null.
  Future<String?> _askNote(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.rejectLeave),
        content: TextField(controller: controller, decoration: InputDecoration(labelText: l10n.rejectNote)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.no)),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: Text(l10n.rejectLeave)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final busy = ref.watch(leaveDecisionProvider.select((s) => s.busy));
    final decisions = ref.read(leaveDecisionProvider.notifier);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(request.staffName, style: Theme.of(context).textTheme.titleMedium),
            Text('${formatDate(context, request.dateFrom)} – ${formatDate(context, request.dateTo)}'),
            if (request.reason != null && request.reason!.isNotEmpty) Text(request.reason!),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: 8,
              children: [
                TextButton(
                  onPressed: busy
                      ? null
                      : () async {
                          final note = await _askNote(context);
                          if (note != null) await decisions.reject(businessId, request.id, note: note);
                        },
                  child: Text(l10n.rejectLeave),
                ),
                FilledButton(
                  onPressed: busy ? null : () => decisions.approve(businessId, request.id),
                  child: Text(l10n.approveLeave),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
