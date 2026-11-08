import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/async_view.dart';
import '../../../shared/flash.dart';
import '../../../shared/format.dart';
import '../../../shared/ui/app_alerts.dart';
import '../../../shared/ui/status_chip.dart';
import '../../staff/viewmodel/staff_session_viewmodel.dart';
import '../model/quote_models.dart';
import '../viewmodel/quote_viewmodels.dart';

String _statusLabel(AppLocalizations l10n, String status) => switch (status) {
  'draft' => l10n.quoteDraft,
  'sent' => l10n.quoteSent,
  'accepted' => l10n.quoteAccepted,
  'converted' => l10n.quoteConverted,
  _ => status,
};

/// Az ajánlatok listája (View): állapot-szűrő, és az ajánlaton végezhető műveletek (állapotváltás, számlává alakítás, törlés).
class OwnerQuotesPage extends ConsumerWidget {
  const OwnerQuotesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final businessId = ref.watch(staffSessionProvider).value?.businessId;
    listenFlash(ref, context, quoteActionsProvider.select((s) => s.flash));
    final filter = ref.watch(quoteFilterProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.ownerQuotes)),
      floatingActionButton: businessId == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => context.push('/owner/quotes/new'),
              icon: const Icon(Icons.add),
              label: Text(l10n.newQuote),
            ),
      body: businessId == null
          ? Center(child: Text(l10n.ownerNoBusiness))
          : Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    spacing: 8,
                    children: [
                      for (final value in const [null, 'draft', 'sent', 'accepted', 'converted'])
                        ChoiceChip(
                          label: Text(value == null ? l10n.invoiceAll : _statusLabel(l10n, value)),
                          selected: filter == value,
                          onSelected: (_) => ref.read(quoteFilterProvider.notifier).select(value),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: AsyncView<List<Quote>>(
                    value: ref.watch(quotesProvider(businessId)),
                    onRetry: () => ref.invalidate(quotesProvider(businessId)),
                    builder: (context, quotes) => RefreshIndicator(
                      onRefresh: () => ref.refresh(quotesProvider(businessId).future),
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                        children: [
                          if (quotes.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 48),
                              child: Column(
                                children: [
                                  Text(l10n.quoteEmpty, style: Theme.of(context).textTheme.titleMedium),
                                  const SizedBox(height: 4),
                                  Text(l10n.quoteEmptyHint, textAlign: TextAlign.center),
                                ],
                              ),
                            ),
                          for (final quote in quotes) _QuoteTile(quote: quote, businessId: businessId),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _QuoteTile extends ConsumerWidget {
  const _QuoteTile({required this.quote, required this.businessId});

  final Quote quote;
  final int businessId;

  Future<void> _convert(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showConfirmAlert(
      context,
      title: l10n.quoteConvert,
      message: l10n.quoteConvertConfirm,
      confirmLabel: l10n.quoteConvert,
      cancelLabel: l10n.dialogCancel,
      icon: Icons.receipt_long_outlined,
    );
    if (ok) await ref.read(quoteActionsProvider.notifier).convert(businessId, quote.id);
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showConfirmAlert(
      context,
      title: l10n.actionDelete,
      message: l10n.quoteDeleteConfirm,
      confirmLabel: l10n.actionDelete,
      cancelLabel: l10n.dialogCancel,
      destructive: true,
      icon: Icons.delete_outline_rounded,
    );
    if (ok) await ref.read(quoteActionsProvider.notifier).delete(businessId, quote.id);
  }

  void _menu(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final actions = ref.read(quoteActionsProvider.notifier);

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        Widget tile(IconData icon, String label, VoidCallback onTap) => ListTile(
          leading: Icon(icon),
          title: Text(label),
          onTap: () {
            Navigator.pop(sheetContext);
            onTap();
          },
        );

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (quote.isDraft) tile(Icons.send_outlined, l10n.quoteMarkSent, () => actions.setStatus(businessId, quote.id, 'sent')),
              if (quote.status == 'sent')
                tile(Icons.check_circle_outline, l10n.quoteMarkAccepted, () => actions.setStatus(businessId, quote.id, 'accepted')),
              if (quote.status == 'accepted') tile(Icons.receipt_long_outlined, l10n.quoteConvert, () => _convert(context, ref)),
              if (quote.isDraft) tile(Icons.edit_outlined, l10n.editQuote, () => context.push('/owner/quotes/edit', extra: quote)),
              if (!quote.isConverted) tile(Icons.delete_outline_rounded, l10n.actionDelete, () => _delete(context, ref)),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final summary = quote.items.map((i) => '${i.name} (${_qty(i.qty)})').join(', ');

    return Card(
      child: ListTile(
        isThreeLine: true,
        title: Text('${quote.customerName} · ${formatHuf(context, quote.totalHuf)}'),
        subtitle: Text(
          [summary, if (quote.validUntil != null) '${l10n.quoteValidUntil}: ${formatDate(context, quote.validUntil!)}'].join('\n'),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: StatusChip(quote.status, label: _statusLabel(l10n, quote.status)),
        onTap: quote.isConverted ? null : () => _menu(context, ref),
      ),
    );
  }
}

String _qty(double qty) => qty == qty.roundToDouble() ? qty.toInt().toString() : qty.toString();

class _ItemRow {
  _ItemRow({String name = '', String qty = '1', String price = ''})
    : name = TextEditingController(text: name),
      qty = TextEditingController(text: qty),
      price = TextEditingController(text: price);

  final TextEditingController name;
  final TextEditingController qty;
  final TextEditingController price;

  void dispose() {
    name.dispose();
    qty.dispose();
    price.dispose();
  }

  int get unitPrice => int.tryParse(price.text.trim()) ?? 0;
  double get quantity => double.tryParse(qty.text.trim().replaceAll(',', '.')) ?? 0;
  bool get valid => name.text.trim().isNotEmpty && quantity > 0;
}

/// Ajánlat létrehozása / szerkesztése (View): vevő, tételek, érvényesség. A [quote] megadásával szerkeszt.
class OwnerQuoteFormPage extends ConsumerStatefulWidget {
  const OwnerQuoteFormPage({super.key, this.quote});

  final Quote? quote;

  @override
  ConsumerState<OwnerQuoteFormPage> createState() => _OwnerQuoteFormPageState();
}

class _OwnerQuoteFormPageState extends ConsumerState<OwnerQuoteFormPage> {
  late final _customer = TextEditingController(text: widget.quote?.customerName ?? '');
  late final _email = TextEditingController(text: widget.quote?.customerEmail ?? '');
  late final List<_ItemRow> _items = [
    for (final i in widget.quote?.items ?? const <QuoteItem>[]) _ItemRow(name: i.name, qty: _qty(i.qty), price: i.unitPriceHuf.toString()),
    if (widget.quote == null || widget.quote!.items.isEmpty) _ItemRow(),
  ];
  late DateTime? _validUntil = widget.quote?.validUntil;

  @override
  void dispose() {
    _customer.dispose();
    _email.dispose();
    for (final i in _items) {
      i.dispose();
    }
    super.dispose();
  }

  int get _total => _items.fold(0, (sum, i) => sum + (i.quantity * i.unitPrice).round());

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _validUntil ?? now.add(const Duration(days: 14)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (picked != null) setState(() => _validUntil = picked);
  }

  Future<void> _save(int businessId) async {
    final l10n = AppLocalizations.of(context);
    final router = GoRouter.of(context);
    final valid = _items.where((i) => i.valid).toList();
    if (_customer.text.trim().isEmpty || valid.isEmpty) {
      showToast(context, valid.isEmpty ? l10n.invoiceNeedsItem : l10n.invoiceCustomerName, kind: AlertKind.warning);
      return;
    }
    final ok = await ref
        .read(quoteActionsProvider.notifier)
        .save(
          businessId,
          quoteId: widget.quote?.id,
          customerName: _customer.text,
          customerEmail: _email.text,
          items: [for (final i in valid) (name: i.name.text.trim(), qty: i.quantity, unitPriceHuf: i.unitPrice)],
          validUntil: _validUntil,
        );
    if (ok && router.canPop()) router.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final businessId = ref.watch(staffSessionProvider).value?.businessId;
    listenFlash(ref, context, quoteActionsProvider.select((s) => s.flash));
    final busy = ref.watch(quoteActionsProvider.select((s) => s.busy));

    return Scaffold(
      appBar: AppBar(title: Text(widget.quote == null ? l10n.newQuote : l10n.editQuote)),
      body: businessId == null
          ? Center(child: Text(l10n.ownerNoBusiness))
          : ListView(
              padding: const EdgeInsets.all(AppDimens.pagePadding),
              children: [
                TextField(
                  controller: _customer,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(labelText: l10n.invoiceCustomerName),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(labelText: l10n.email),
                ),
                const SizedBox(height: 24),
                Text(l10n.invoiceItemsTitle, style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                for (final (index, item) in _items.indexed)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          TextField(
                            controller: item.name,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(labelText: l10n.invoiceItemName),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              SizedBox(
                                width: 90,
                                child: TextField(
                                  controller: item.qty,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  onChanged: (_) => setState(() {}),
                                  decoration: InputDecoration(labelText: l10n.invoiceItemQty),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: item.price,
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) => setState(() {}),
                                  decoration: InputDecoration(labelText: l10n.invoiceItemPrice),
                                ),
                              ),
                              if (_items.length > 1)
                                IconButton(
                                  tooltip: l10n.actionDelete,
                                  icon: const Icon(Icons.close_rounded),
                                  onPressed: () => setState(() => _items.removeAt(index).dispose()),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                TextButton.icon(
                  onPressed: () => setState(() => _items.add(_ItemRow())),
                  icon: const Icon(Icons.add),
                  label: Text(l10n.invoiceAddItem),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(l10n.invoiceTotalLine(formatHuf(context, _total)), style: theme.textTheme.titleMedium),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event_outlined),
                  title: Text(l10n.quoteValidUntil),
                  subtitle: Text(_validUntil == null ? l10n.quoteNoDate : formatDate(context, _validUntil!)),
                  trailing: _validUntil == null
                      ? null
                      : IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => setState(() => _validUntil = null)),
                  onTap: _pickDate,
                ),
                const SizedBox(height: 16),
                FilledButton(onPressed: busy ? null : () => _save(businessId), child: Text(l10n.quoteSave)),
              ],
            ),
    );
  }
}
