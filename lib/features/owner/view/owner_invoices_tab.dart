import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/async_view.dart';
import '../../../shared/flash.dart';
import '../../../shared/format.dart';
import '../../../shared/ui/app_alerts.dart';
import '../model/owner_models.dart';
import '../viewmodel/owner_invoice_viewmodels.dart';
import '../viewmodel/owner_tools_viewmodels.dart';

/// A vállalkozás számlái (View): szűrő (mind / nyitott / lejárt / kifizetett) és a számlán végezhető műveletek.
class OwnerInvoicesTab extends ConsumerWidget {
  const OwnerInvoicesTab({super.key, required this.businessId});

  final int businessId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    listenFlash(ref, context, invoiceActionsProvider.select((s) => s.flash));
    final filter = ref.watch(invoiceFilterProvider);
    final filters = ref.read(invoiceFilterProvider.notifier);

    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(12),
          child: Row(
            spacing: 8,
            children: [
              for (final (value, label) in [
                (null, l10n.invoiceAll),
                ('unpaid', l10n.invoiceUnpaid),
                ('overdue', l10n.invoiceOverdue),
                ('paid', l10n.invoicePaid),
              ])
                ChoiceChip(label: Text(label), selected: filter == value, onSelected: (_) => filters.select(value)),
              ActionChip(avatar: const Icon(Icons.add, size: 18), label: Text(l10n.newInvoice), onPressed: () => context.push('/owner/invoices/new')),
            ],
          ),
        ),
        Expanded(
          child: AsyncView<List<InvoiceItem>>(
            value: ref.watch(invoicesProvider(businessId)),
            onRetry: () => ref.invalidate(invoicesProvider(businessId)),
            builder: (context, invoices) => RefreshIndicator(
              onRefresh: () => ref.refresh(invoicesProvider(businessId).future),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  if (invoices.isEmpty) Text(l10n.nothingYet),
                  for (final invoice in invoices) _InvoiceTile(invoice: invoice, businessId: businessId),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InvoiceTile extends ConsumerWidget {
  const _InvoiceTile({required this.invoice, required this.businessId});

  final InvoiceItem invoice;
  final int businessId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final actions = ref.read(invoiceActionsProvider.notifier);
    final overdue = invoice.paymentState == 'overdue';

    final subtitle = [
      if (invoice.customerName != null) invoice.customerName!,
      if (invoice.isPaid && invoice.paidAt != null) l10n.paidOn(formatDate(context, invoice.paidAt!)),
      if (!invoice.isPaid && invoice.dueDate != null) l10n.dueOn(formatDate(context, invoice.dueDate!)),
      if (invoice.reminderCount > 0) l10n.remindersSent(invoice.reminderCount),
    ].join('\n');

    return Card(
      child: ListTile(
        isThreeLine: subtitle.contains('\n'),
        title: Text('${invoice.number} · ${formatHuf(context, invoice.totalHuf)}'),
        subtitle: Text(subtitle),
        trailing: invoice.cancelled
            ? Text(l10n.invoiceCancelled)
            : Text(
                invoice.isPaid ? l10n.invoicePaid : (overdue ? l10n.invoiceOverdue : l10n.invoiceUnpaid),
                style: TextStyle(color: overdue ? theme.colorScheme.error : null),
              ),
        onTap: invoice.cancelled
            ? null
            : () => showModalBottomSheet<void>(
                  context: context,
                  showDragHandle: true,
                  builder: (sheetContext) => SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!invoice.isPaid) ...[
                          for (final (method, label) in [
                            ('cash', l10n.payMethodCash),
                            ('card', l10n.payMethodCard),
                            ('transfer', l10n.payMethodTransfer),
                          ])
                            ListTile(
                              leading: const Icon(Icons.check_circle_outline),
                              title: Text(l10n.markPaidWith(label)),
                              onTap: () {
                                Navigator.pop(sheetContext);
                                actions.markPaid(businessId, invoice.id, method);
                              },
                            ),
                          ListTile(
                            leading: const Icon(Icons.mail_outline),
                            title: Text(l10n.sendReminder),
                            onTap: () {
                              Navigator.pop(sheetContext);
                              actions.remind(businessId, invoice.id);
                            },
                          ),
                        ] else
                          ListTile(
                            leading: const Icon(Icons.undo),
                            title: Text(l10n.markUnpaid),
                            onTap: () {
                              Navigator.pop(sheetContext);
                              actions.markUnpaid(businessId, invoice.id);
                            },
                          ),
                        ListTile(
                          leading: const Icon(Icons.picture_as_pdf_outlined),
                          title: Text(l10n.docOpenPdf),
                          onTap: () async {
                            Navigator.pop(sheetContext);
                            final viewModel = ref.read(documentActionsProvider.notifier);
                            final ok = await viewModel.openPdf(businessId, 'standalone', invoice.id, invoice.number);
                            if (ok && viewModel.pdfNotOpened && context.mounted) showToast(context, l10n.docPdfFailed, kind: AlertKind.warning);
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.block_outlined, color: theme.colorScheme.error),
                          title: Text(l10n.docCancel, style: TextStyle(color: theme.colorScheme.error)),
                          onTap: () async {
                            Navigator.pop(sheetContext);
                            final confirmed = await showConfirmAlert(
                              context,
                              title: l10n.docCancelTitle,
                              message: invoice.number,
                              confirmLabel: l10n.docCancel,
                              destructive: true,
                              icon: Icons.block_outlined,
                            );
                            if (!confirmed) return;
                            await ref
                                .read(documentActionsProvider.notifier)
                                .cancel(businessId, 'standalone', invoice.id, null, onDone: () => ref.invalidate(invoicesProvider(businessId)));
                          },
                        ),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }
}
