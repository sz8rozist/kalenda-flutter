import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/async_view.dart';
import '../../../shared/flash.dart';
import '../../../shared/format.dart';
import '../../../shared/ui/app_alerts.dart';
import '../../../shared/ui/status_chip.dart';
import '../../staff/viewmodel/staff_session_viewmodel.dart';
import '../model/appointment_detail.dart';
import '../viewmodel/owner_tools_viewmodels.dart';

String paymentMethodLabel(AppLocalizations l10n, String? method) => switch (method) {
  'online' => l10n.methodOnline,
  'card' => l10n.methodCard,
  'cash' => l10n.methodCash,
  'transfer' => l10n.methodTransfer,
  'voucher' => l10n.methodVoucher,
  _ => l10n.methodOther,
};

String documentLabel(AppLocalizations l10n, AppointmentDocument d) {
  if (d.kind == 'receipt') return d.role == 'deposit' ? l10n.docReceiptDeposit : l10n.docReceipt;
  return switch (d.role) {
    'deposit' => l10n.docInvoiceDeposit,
    'final' => l10n.docInvoiceFinal,
    _ => l10n.docInvoice,
  };
}

/// Egy foglalás részletei a vállalkozónak (View): ügyfél, fizetés, bizonylatok, állapotváltás, számla kiállítása.
class OwnerAppointmentPage extends ConsumerWidget {
  const OwnerAppointmentPage({super.key, required this.appointmentId});

  final int appointmentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final businessId = ref.watch(staffSessionProvider).value?.businessId;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appointmentDetailTitle)),
      body: businessId == null
          ? Center(child: Text(l10n.ownerNoBusiness))
          : _Body(key_: (businessId: businessId, appointmentId: appointmentId)),
    );
  }
}

class _Body extends ConsumerStatefulWidget {
  const _Body({required this.key_});

  final AppointmentKey key_;

  @override
  ConsumerState<_Body> createState() => _BodyState();
}

class _BodyState extends ConsumerState<_Body> {
  String _method = 'card';

  AppointmentKey get _key => widget.key_;

  Future<void> _changeStatus(AppointmentDetail d, String status) async {
    final l10n = AppLocalizations.of(context);
    var refund = false;
    if (status == 'cancelled') {
      final confirmed = await showConfirmAlert(
        context,
        title: l10n.cancelConfirmTitle,
        message: l10n.cancelConfirmText,
        confirmLabel: l10n.yes,
        destructive: true,
        icon: Icons.event_busy_outlined,
      );
      if (!confirmed || !mounted) return;
      // Befizetett összegnél külön kérdés: visszatérítsük-e.
      if (d.paidHuf > 0) {
        refund = await showConfirmAlert(
          context,
          title: l10n.refundAsk,
          message: formatHuf(context, d.paidHuf),
          confirmLabel: l10n.refundYes,
          cancelLabel: l10n.refundNo,
          icon: Icons.currency_exchange_rounded,
        );
      }
    }
    await ref.read(appointmentActionsProvider.notifier).setStatus(_key, status, refund: refund);
  }

  Future<void> _cancelDocument(AppointmentDocument doc) async {
    final l10n = AppLocalizations.of(context);
    final reason = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.docCancelTitle),
        content: TextField(
          controller: reason,
          decoration: InputDecoration(labelText: l10n.docCancelReason),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.dialogCancel)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.docCancel)),
        ],
      ),
    );
    final text = reason.text.trim();
    reason.dispose();
    if (confirmed == true) await ref.read(appointmentActionsProvider.notifier).cancelDocument(_key, doc.id, text);
  }

  Future<void> _openPdf(AppointmentDocument doc) async {
    final l10n = AppLocalizations.of(context);
    final viewModel = ref.read(appointmentActionsProvider.notifier);
    final ok = await viewModel.openPdf(_key, doc);
    if (ok && viewModel.pdfNotOpened && mounted) showToast(context, l10n.docPdfFailed, kind: AlertKind.warning);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    listenFlash(ref, context, appointmentActionsProvider.select((s) => s.flash));
    final busy = ref.watch(appointmentActionsProvider.select((s) => s.busy));

    return AsyncView<AppointmentDetail>(
      value: ref.watch(appointmentDetailProvider(_key)),
      onRetry: () => ref.invalidate(appointmentDetailProvider(_key)),
      builder: (context, d) {
        final documentName = d.documentType == 'receipt'
            ? l10n.docReceipt
            : d.hasDepositInvoice
            ? l10n.docInvoiceFinal
            : l10n.docInvoice;

        return RefreshIndicator(
          onRefresh: () => ref.refresh(appointmentDetailProvider(_key).future),
          child: ListView(
            padding: const EdgeInsets.all(AppDimens.pagePadding),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DateBadge(d.startsAt),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(d.serviceName, style: theme.textTheme.titleLarge),
                        Text(
                          '${formatTime(context, d.startsAt)} – ${formatTime(context, d.endsAt)}${d.staffName == null ? '' : ' · ${d.staffName}'}',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  StatusChip(d.status),
                ],
              ),
              if (d.customerName != null) ...[
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.person_outline_rounded),
                    title: Text(d.customerName!),
                    subtitle: Text(
                      [if (d.customerEmail != null) d.customerEmail!, if (d.customerPhone != null) d.customerPhone!].join('\n'),
                    ),
                    isThreeLine: d.customerEmail != null && d.customerPhone != null,
                    trailing: d.customerPhone == null || d.customerPhone!.isEmpty
                        ? null
                        : IconButton(
                            tooltip: l10n.call,
                            icon: const Icon(Icons.phone_outlined),
                            onPressed: () => launchUrl(Uri(scheme: 'tel', path: d.customerPhone)),
                          ),
                    onTap: d.customerId == null ? null : () => context.push('/owner/customers/${d.customerId}'),
                  ),
                ),
              ],
              if (d.notes != null && d.notes!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(d.notes!, style: theme.textTheme.bodySmall),
                ),
              if (d.addons.isNotEmpty) ...[
                Text(l10n.bookingAddons, style: theme.textTheme.titleSmall),
                for (final a in d.addons)
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(a.name),
                    trailing: Text(formatHuf(context, a.priceHuf)),
                  ),
                const SizedBox(height: 8),
              ],
              Text(l10n.paymentsTitle, style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${l10n.total}: ${formatHuf(context, d.totalHuf)}', style: theme.textTheme.titleSmall),
                      Text(l10n.paidAmount(formatHuf(context, d.paidHuf))),
                      if (d.dueHuf > 0)
                        Text(l10n.dueAmount(formatHuf(context, d.dueHuf)), style: const TextStyle(color: AppColors.warning)),
                      if (d.coveredByPass) Text(l10n.coveredByPass),
                      for (final p in d.payments)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Row(
                            children: [
                              Expanded(child: Text(paymentMethodLabel(l10n, p.method), style: theme.textTheme.bodySmall)),
                              Text(formatHuf(context, p.amountHuf), style: theme.textTheme.bodySmall),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(l10n.documentsTitle, style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              for (final doc in d.invoices)
                Card(
                  child: Opacity(
                    opacity: doc.isCancelled ? 0.6 : 1,
                    child: ListTile(
                      title: Text(
                        [documentLabel(l10n, doc), if (doc.number != null) doc.number!].join(' · '),
                        style: TextStyle(decoration: doc.isCancelled ? TextDecoration.lineThrough : null),
                      ),
                      subtitle: Text(
                        [
                          if (doc.paymentMethod != null) paymentMethodLabel(l10n, doc.paymentMethod),
                          if (doc.isCancelled) l10n.docCancelled,
                        ].join(' · '),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(formatHuf(context, doc.amountHuf)),
                          PopupMenuButton<String>(
                            onSelected: (v) => v == 'pdf' ? _openPdf(doc) : _cancelDocument(doc),
                            itemBuilder: (_) => [
                              PopupMenuItem(value: 'pdf', child: Text(l10n.docOpenPdf)),
                              if (!doc.isCancelled) PopupMenuItem(value: 'cancel', child: Text(l10n.docCancel)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (d.invoicingReady && d.invoiceRemainingHuf > 0)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<String>(
                          initialValue: _method,
                          decoration: InputDecoration(labelText: l10n.payMethod),
                          items: [
                            for (final m in const ['card', 'cash', 'transfer', 'other', 'voucher'])
                              DropdownMenuItem(value: m, child: Text(paymentMethodLabel(l10n, m))),
                          ],
                          onChanged: (v) => setState(() => _method = v ?? 'card'),
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: busy ? null : () => ref.read(appointmentActionsProvider.notifier).issueInvoice(_key, _method),
                          child: Text('${l10n.issueDocument(documentName)} · ${formatHuf(context, d.invoiceRemainingHuf)}'),
                        ),
                      ],
                    ),
                  ),
                ),
              if (d.isLive) ...[
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (d.status == 'pending')
                      FilledButton(onPressed: busy ? null : () => _changeStatus(d, 'confirmed'), child: Text(l10n.actionConfirm)),
                    FilledButton.tonal(onPressed: busy ? null : () => _changeStatus(d, 'completed'), child: Text(l10n.actionComplete)),
                    OutlinedButton(onPressed: busy ? null : () => _changeStatus(d, 'no_show'), child: Text(l10n.actionNoShow)),
                    TextButton(
                      style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
                      onPressed: busy ? null : () => _changeStatus(d, 'cancelled'),
                      child: Text(l10n.actionCancel),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
