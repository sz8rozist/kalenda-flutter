import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/viewmodel/simple_viewmodels.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/async_view.dart';
import '../../../shared/flash.dart';
import '../../../shared/format.dart';
import '../model/booking_models.dart';
import '../viewmodel/managed_booking_viewmodels.dart';

/// Egy foglalás megtekintése, áthelyezése és lemondása a foglalás-kezelő token alapján (View).
/// A `justBooked` a foglalás utáni visszaigazoló nézet.
class ManageBookingPage extends ConsumerWidget {
  const ManageBookingPage({super.key, required this.token, this.justBooked = false});

  final String token;
  final bool justBooked;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    listenFlash(ref, context, managedBookingActionsProvider(token).select((s) => s.flash));
    listenFlash(ref, context, paymentViewModelProvider(token).select((s) => s.flash));
    final paying = ref.watch(paymentViewModelProvider(token).select((s) => s.busy));
    final busy = ref.watch(managedBookingActionsProvider(token).select((s) => s.busy)) || paying;

    return Scaffold(
      appBar: AppBar(title: Text(justBooked ? l10n.bookingDone : l10n.manageBooking)),
      body: AsyncView<ManagedBooking>(
        value: ref.watch(managedBookingViewModelProvider(token)),
        onRetry: () => ref.invalidate(managedBookingViewModelProvider(token)),
        builder: (context, data) => RefreshIndicator(
          onRefresh: () => ref.refresh(managedBookingViewModelProvider(token).future),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (justBooked) ...[
                const Icon(Icons.check_circle_outline, size: 48),
                const SizedBox(height: 8),
                Text(l10n.bookingDoneText),
                const SizedBox(height: 16),
              ],
              _Details(booking: data),
              const SizedBox(height: 16),
              if (data.paymentRequired && data.paymentStatus == 'pending') ...[
                Text(l10n.paymentRequired),
                const SizedBox(height: 8),
                FilledButton.icon(
                  icon: const Icon(Icons.payment),
                  label: Text(l10n.payNow),
                  onPressed: busy ? null : () => ref.read(paymentViewModelProvider(token).notifier).pay(),
                ),
                const SizedBox(height: 8),
              ],
              if (data.canModify)
                FilledButton.tonalIcon(
                  icon: const Icon(Icons.edit_calendar_outlined),
                  label: Text(l10n.reschedule),
                  onPressed: busy ? null : () => _reschedule(context, ref),
                ),
              if (data.canCancel)
                TextButton.icon(
                  icon: const Icon(Icons.cancel_outlined),
                  label: Text(l10n.cancelBooking),
                  style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
                  onPressed: busy ? null : () => _confirmCancel(context, ref),
                ),
              if (justBooked) TextButton(onPressed: () => context.go('/'), child: Text(l10n.backToBookings)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmCancel(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.cancelConfirmTitle),
        content: Text(l10n.cancelConfirmText),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.no)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.yes)),
        ],
      ),
    );
    if (confirmed == true) await ref.read(managedBookingActionsProvider(token).notifier).cancel();
  }

  Future<void> _reschedule(BuildContext context, WidgetRef ref) async {
    final result = await showModalBottomSheet<({DateTime date, String time})>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _RescheduleSheet(token: token),
    );
    if (result != null) {
      await ref.read(managedBookingActionsProvider(token).notifier).reschedule(result.date, result.time);
    }
  }
}

class _Details extends StatelessWidget {
  const _Details({required this.booking});

  final ManagedBooking booking;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(booking.businessName, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(booking.serviceName, style: theme.textTheme.bodyLarge),
            if (booking.staffName != null) Text(booking.staffName!),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.schedule, size: 18),
              const SizedBox(width: 8),
              Text(formatDateTime(context, booking.startsAt)),
            ]),
            if (booking.address != null)
              Row(children: [
                const Icon(Icons.place_outlined, size: 18),
                const SizedBox(width: 8),
                Flexible(child: Text(booking.address!)),
              ]),
            if (booking.totalPriceHuf != null) ...[
              const SizedBox(height: 8),
              Text('${l10n.total}: ${formatHuf(context, booking.totalPriceHuf!)}'),
            ],
            const SizedBox(height: 8),
            Text('${l10n.status}: ${booking.status}'),
            if (booking.phone != null && booking.phone!.isNotEmpty)
              TextButton.icon(
                icon: const Icon(Icons.phone_outlined),
                label: Text(l10n.call),
                onPressed: () => launchUrl(Uri(scheme: 'tel', path: booking.phone)),
              ),
          ],
        ),
      ),
    );
  }
}

/// Az áthelyezés lapja: nap kiválasztása, majd egy szabad időpont. A kiválasztott nap a ViewModel-ben van.
class _RescheduleSheet extends ConsumerWidget {
  const _RescheduleSheet({required this.token});

  final String token;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final dateProvider = selectedDateProvider('reschedule:$token');
    final date = ref.watch(dateProvider);

    Future<void> pickDate() async {
      final now = DateTime.now();
      final picked = await showDatePicker(
        context: context,
        initialDate: date ?? now,
        firstDate: DateTime(now.year, now.month, now.day),
        lastDate: now.add(const Duration(days: 365)),
      );
      if (picked != null) ref.read(dateProvider.notifier).select(picked);
    }

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            OutlinedButton.icon(
              onPressed: pickDate,
              icon: const Icon(Icons.event),
              label: Text(date == null ? l10n.pickDate : formatDate(context, date)),
            ),
            if (date != null) ...[
              const SizedBox(height: 12),
              AsyncView<List<String>>(
                value: ref.watch(rescheduleSlotsViewModelProvider((token: token, date: date))),
                onRetry: () => ref.invalidate(rescheduleSlotsViewModelProvider((token: token, date: date))),
                builder: (context, slots) => slots.isEmpty
                    ? Text(l10n.noSlots)
                    : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final time in slots)
                            ActionChip(label: Text(time), onPressed: () => Navigator.pop(context, (date: date, time: time))),
                        ],
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
