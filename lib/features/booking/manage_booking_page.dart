import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../../shared/async_view.dart';
import '../../shared/format.dart';
import '../account/account_repository.dart';
import 'booking_models.dart';
import 'booking_repository.dart';

/// Egy foglalás megtekintése, áthelyezése és lemondása a foglalás-kezelő token alapján.
/// A `justBooked` a foglalás utáni visszaigazoló nézet.
class ManageBookingPage extends ConsumerWidget {
  const ManageBookingPage({super.key, required this.token, this.justBooked = false});

  final String token;
  final bool justBooked;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final booking = ref.watch(managedBookingProvider(token));

    return Scaffold(
      appBar: AppBar(title: Text(justBooked ? l10n.bookingDone : l10n.manageBooking)),
      body: AsyncView<ManagedBooking>(
        value: booking,
        onRetry: () => ref.invalidate(managedBookingProvider(token)),
        builder: (context, data) => RefreshIndicator(
          onRefresh: () => ref.refresh(managedBookingProvider(token).future),
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
              if (data.canModify)
                FilledButton.tonalIcon(
                  icon: const Icon(Icons.edit_calendar_outlined),
                  label: Text(l10n.reschedule),
                  onPressed: () => _reschedule(context, ref),
                ),
              if (data.canCancel)
                TextButton.icon(
                  icon: const Icon(Icons.cancel_outlined),
                  label: Text(l10n.cancelBooking),
                  style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
                  onPressed: () => _cancel(context, ref),
                ),
              if (justBooked)
                TextButton(onPressed: () => context.go('/'), child: Text(l10n.backToBookings)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _cancel(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
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
    if (confirmed != true) return;

    try {
      await ref.read(bookingRepositoryProvider).cancel(token);
      ref.invalidate(accountOverviewProvider);
      messenger.showSnackBar(SnackBar(content: Text(l10n.cancelled)));
    } catch (e) {
      if (context.mounted) messenger.showSnackBar(SnackBar(content: Text(errorText(context, e))));
    }
  }

  Future<void> _reschedule(BuildContext context, WidgetRef ref) async {
    final result = await showModalBottomSheet<({DateTime date, String time})>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _RescheduleSheet(token: token),
    );
    if (result == null || !context.mounted) return;

    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(bookingRepositoryProvider).reschedule(token, result.date, result.time);
      ref.invalidate(accountOverviewProvider);
      messenger.showSnackBar(SnackBar(content: Text(l10n.saved)));
    } catch (e) {
      if (context.mounted) messenger.showSnackBar(SnackBar(content: Text(errorText(context, e))));
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

class _RescheduleSheet extends ConsumerStatefulWidget {
  const _RescheduleSheet({required this.token});

  final String token;

  @override
  ConsumerState<_RescheduleSheet> createState() => _RescheduleSheetState();
}

class _RescheduleSheetState extends ConsumerState<_RescheduleSheet> {
  DateTime? _date;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.event),
              label: Text(_date == null ? l10n.pickDate : formatDate(context, _date!)),
            ),
            if (_date != null) ...[
              const SizedBox(height: 12),
              AsyncView<List<String>>(
                value: ref.watch(rescheduleSlotsProvider((token: widget.token, date: _date!))),
                onRetry: () => ref.invalidate(rescheduleSlotsProvider((token: widget.token, date: _date!))),
                builder: (context, slots) => slots.isEmpty
                    ? Text(l10n.noSlots)
                    : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final time in slots)
                            ActionChip(
                              label: Text(time),
                              onPressed: () => Navigator.pop(context, (date: _date!, time: time)),
                            ),
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
