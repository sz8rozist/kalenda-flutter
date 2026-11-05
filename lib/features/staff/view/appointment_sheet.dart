import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/async_view.dart';
import '../../../shared/flash.dart';
import '../../../shared/format.dart';
import '../model/staff_models.dart';
import '../viewmodel/staff_viewmodels.dart';

/// Egy foglalás részletei és a kezelése (státuszváltás, áthelyezés) alulról felcsúszó lapon.
/// Vállalkozói módban a `businessId` meg van adva: a státuszváltás a vállalkozói végponton megy, áthelyezés nincs.
Future<void> showAppointmentSheet(BuildContext context, PortalAppointment appointment, {int? businessId}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => AppointmentSheet(appointment: appointment, businessId: businessId),
  );
}

/// A foglalás-lap (View): az állapot és a műveletek az [AppointmentSheetViewModel]-ben vannak.
class AppointmentSheet extends ConsumerWidget {
  const AppointmentSheet({super.key, required this.appointment, this.businessId});

  final PortalAppointment appointment;
  final int? businessId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final a = appointment;
    final provider = appointmentSheetProvider((appointmentId: a.id, businessId: businessId));
    final state = ref.watch(provider);
    final viewModel = ref.read(provider.notifier);
    final live = a.status == 'pending' || a.status == 'confirmed';

    listenFlash(ref, context, provider.select((s) => s.flash));
    ref.listen(provider.select((s) => s.done), (_, done) {
      if (done) Navigator.of(context).pop();
    });

    Future<void> pickDate() async {
      final now = DateTime.now();
      final picked = await showDatePicker(
        context: context,
        initialDate: state.date ?? (a.startsAt.isAfter(now) ? a.startsAt : now),
        firstDate: DateTime(now.year, now.month, now.day),
        lastDate: now.add(const Duration(days: 365)),
      );
      if (picked != null) viewModel.pickDate(picked);
    }

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(a.serviceName, style: theme.textTheme.titleLarge),
              const SizedBox(height: 4),
              Text('${formatDateTime(context, a.startsAt)} – ${formatTime(context, a.endsAt)} · ${statusLabel(context, a.status)}'),
              if (a.customerName != null) ...[
                const SizedBox(height: 12),
                Text(a.customerName!, style: theme.textTheme.titleMedium),
                if (a.customerPhone != null && a.customerPhone!.isNotEmpty)
                  TextButton.icon(
                    icon: const Icon(Icons.phone_outlined),
                    label: Text(a.customerPhone!),
                    onPressed: () => launchUrl(Uri(scheme: 'tel', path: a.customerPhone)),
                  ),
                if (a.customerEmail != null && a.customerEmail!.isNotEmpty) Text(a.customerEmail!),
              ],
              if (a.notes != null && a.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(a.notes!, style: theme.textTheme.bodySmall),
              ],
              if (a.totalPriceHuf != null) ...[
                const SizedBox(height: 8),
                Text('${l10n.total}: ${formatHuf(context, a.totalPriceHuf!)}'),
              ],
              if (a.canManage && live) ...[
                const Divider(height: 24),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (a.status == 'pending')
                      FilledButton(
                        onPressed: state.busy ? null : () => viewModel.setStatus('confirmed'),
                        child: Text(l10n.actionConfirm),
                      ),
                    FilledButton.tonal(
                      onPressed: state.busy ? null : () => viewModel.setStatus('completed'),
                      child: Text(l10n.actionComplete),
                    ),
                    OutlinedButton(
                      onPressed: state.busy ? null : () => viewModel.setStatus('no_show'),
                      child: Text(l10n.actionNoShow),
                    ),
                    if (businessId == null)
                      OutlinedButton(
                        onPressed: state.busy ? null : viewModel.toggleReschedule,
                        child: Text(l10n.reschedule),
                      ),
                    TextButton(
                      style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
                      onPressed: state.busy ? null : () => viewModel.setStatus('cancelled'),
                      child: Text(l10n.actionCancel),
                    ),
                  ],
                ),
              ],
              if (state.rescheduling) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: pickDate,
                  icon: const Icon(Icons.event),
                  label: Text(state.date == null ? l10n.pickDate : formatDate(context, state.date!)),
                ),
                if (state.date != null)
                  AsyncView<List<String>>(
                    value: ref.watch(portalRescheduleSlotsProvider((appointmentId: a.id, date: state.date!))),
                    onRetry: () => ref.invalidate(portalRescheduleSlotsProvider((appointmentId: a.id, date: state.date!))),
                    builder: (context, slots) => slots.isEmpty
                        ? Padding(padding: const EdgeInsets.only(top: 8), child: Text(l10n.noSlots))
                        : Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Wrap(spacing: 8, runSpacing: 8, children: [
                              for (final time in slots)
                                ActionChip(
                                  label: Text(time),
                                  onPressed: state.busy ? null : () => viewModel.reschedule(time),
                                ),
                            ]),
                          ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
