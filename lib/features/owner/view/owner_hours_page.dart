import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/async_view.dart';
import '../../../shared/flash.dart';
import '../../staff/viewmodel/staff_session_viewmodel.dart';
import '../model/owner_models.dart';
import '../viewmodel/owner_hours_viewmodels.dart';

/// A vállalkozás heti nyitvatartásának szerkesztése (View): naponként nyitva / zárva és a nyitás-zárás ideje.
class OwnerHoursPage extends ConsumerWidget {
  const OwnerHoursPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    listenFlash(ref, context, hoursActionsProvider.select((s) => s.flash));
    final businessId = ref.watch(staffSessionProvider).value?.businessId;
    final busy = ref.watch(hoursActionsProvider.select((s) => s.busy));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.ownerHours)),
      body: businessId == null
          ? Center(child: Text(l10n.ownerNoBusiness))
          : AsyncView<List<HourRow>>(
              value: ref.watch(hoursEditorProvider(businessId)),
              onRetry: () => ref.invalidate(hoursEditorProvider(businessId)),
              builder: (context, rows) => ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  for (final row in rows) _DayRow(row: row, businessId: businessId),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: busy ? null : () => ref.read(hoursActionsProvider.notifier).save(businessId),
                    child: Text(l10n.save),
                  ),
                ],
              ),
            ),
    );
  }
}

class _DayRow extends ConsumerWidget {
  const _DayRow({required this.row, required this.businessId});

  final HourRow row;
  final int businessId;

  /// A nap neve a nyelv szerint (a 2024. január 7. vasárnap).
  String _dayName(BuildContext context) =>
      DateFormat.EEEE(Localizations.localeOf(context).toString()).format(DateTime(2024, 1, 7 + row.dayOfWeek));

  Future<String?> _pickTime(BuildContext context, String current) async {
    final parts = current.split(':');
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: int.tryParse(parts[0]) ?? 9, minute: int.tryParse(parts[1]) ?? 0),
      builder: (context, child) => MediaQuery(data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true), child: child!),
    );
    if (picked == null) return null;
    return '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final editor = ref.read(hoursEditorProvider(businessId).notifier);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(child: Text(_dayName(context), style: Theme.of(context).textTheme.titleSmall)),
            if (row.isClosed)
              Text(l10n.closedDay)
            else ...[
              OutlinedButton(
                onPressed: () async {
                  final time = await _pickTime(context, row.openAt);
                  if (time != null) editor.setOpenAt(row.dayOfWeek, time);
                },
                child: Text(row.openAt),
              ),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: Text('–')),
              OutlinedButton(
                onPressed: () async {
                  final time = await _pickTime(context, row.closeAt);
                  if (time != null) editor.setCloseAt(row.dayOfWeek, time);
                },
                child: Text(row.closeAt),
              ),
            ],
            Switch(value: !row.isClosed, onChanged: (open) => editor.setClosed(row.dayOfWeek, !open)),
          ],
        ),
      ),
    );
  }
}
