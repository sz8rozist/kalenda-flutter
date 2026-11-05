import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../../shared/async_view.dart';
import '../../shared/format.dart';
import 'staff_models.dart';
import 'staff_repository.dart';

/// Egy foglalás részletei és a kezelése (státuszváltás, áthelyezés) alulról felcsúszó lapon.
Future<void> showAppointmentSheet(BuildContext context, PortalAppointment appointment) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => AppointmentSheet(appointment: appointment),
  );
}

class AppointmentSheet extends ConsumerStatefulWidget {
  const AppointmentSheet({super.key, required this.appointment});

  final PortalAppointment appointment;

  @override
  ConsumerState<AppointmentSheet> createState() => _AppointmentSheetState();
}

class _AppointmentSheetState extends ConsumerState<AppointmentSheet> {
  bool _busy = false;
  bool _rescheduling = false;
  DateTime? _date;

  PortalAppointment get a => widget.appointment;

  Future<void> _run(Future<void> Function() action) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final saved = AppLocalizations.of(context).saved;
    setState(() => _busy = true);
    try {
      await action();
      navigator.pop();
      messenger.showSnackBar(SnackBar(content: Text(saved)));
    } catch (e) {
      if (mounted) messenger.showSnackBar(SnackBar(content: Text(errorText(context, e))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? (a.startsAt.isAfter(now) ? a.startsAt : now),
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final repo = ref.read(staffRepositoryProvider);
    final live = a.status == 'pending' || a.status == 'confirmed';

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
                        onPressed: _busy ? null : () => _run(() => repo.setStatus(a.id, 'confirmed')),
                        child: Text(l10n.actionConfirm),
                      ),
                    FilledButton.tonal(
                      onPressed: _busy ? null : () => _run(() => repo.setStatus(a.id, 'completed')),
                      child: Text(l10n.actionComplete),
                    ),
                    OutlinedButton(
                      onPressed: _busy ? null : () => _run(() => repo.setStatus(a.id, 'no_show')),
                      child: Text(l10n.actionNoShow),
                    ),
                    OutlinedButton(
                      onPressed: _busy ? null : () => setState(() => _rescheduling = !_rescheduling),
                      child: Text(l10n.reschedule),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
                      onPressed: _busy ? null : () => _run(() => repo.setStatus(a.id, 'cancelled')),
                      child: Text(l10n.actionCancel),
                    ),
                  ],
                ),
              ],
              if (_rescheduling) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.event),
                  label: Text(_date == null ? l10n.pickDate : formatDate(context, _date!)),
                ),
                if (_date != null)
                  AsyncView<List<String>>(
                    value: ref.watch(portalRescheduleSlotsProvider((appointmentId: a.id, date: _date!))),
                    onRetry: () => ref.invalidate(portalRescheduleSlotsProvider((appointmentId: a.id, date: _date!))),
                    builder: (context, slots) => slots.isEmpty
                        ? Padding(padding: const EdgeInsets.only(top: 8), child: Text(l10n.noSlots))
                        : Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Wrap(spacing: 8, runSpacing: 8, children: [
                              for (final time in slots)
                                ActionChip(
                                  label: Text(time),
                                  onPressed: _busy ? null : () => _run(() => repo.reschedule(a.id, _date!, time)),
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
