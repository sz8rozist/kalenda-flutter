import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/flash.dart';
import '../../../shared/format.dart';
import '../../../shared/ui/app_alerts.dart';
import '../../staff/viewmodel/staff_session_viewmodel.dart';
import '../viewmodel/owner_invoice_viewmodels.dart';
import '../viewmodel/owner_tools_viewmodels.dart';
import 'owner_appointment_page.dart' show paymentMethodLabel;

class _ItemRow {
  final name = TextEditingController();
  final qty = TextEditingController(text: '1');
  final price = TextEditingController();

  void dispose() {
    name.dispose();
    qty.dispose();
    price.dispose();
  }

  int get unitPrice => int.tryParse(price.text.trim()) ?? 0;
  double get quantity => double.tryParse(qty.text.trim().replaceAll(',', '.')) ?? 0;
  bool get valid => name.text.trim().isNotEmpty && quantity > 0 && unitPrice > 0;
}

/// Új önálló számla kiállítása (View): ügyfél, tételek, határidő vagy „már kifizetve".
class OwnerInvoiceFormPage extends ConsumerStatefulWidget {
  const OwnerInvoiceFormPage({super.key});

  @override
  ConsumerState<OwnerInvoiceFormPage> createState() => _OwnerInvoiceFormPageState();
}

class _OwnerInvoiceFormPageState extends ConsumerState<OwnerInvoiceFormPage> {
  final _customer = TextEditingController();
  final _email = TextEditingController();
  final _dueDays = TextEditingController(text: '8');
  final _items = [_ItemRow()];
  bool _paid = false;
  String _method = 'cash';

  @override
  void dispose() {
    _customer.dispose();
    _email.dispose();
    _dueDays.dispose();
    for (final i in _items) {
      i.dispose();
    }
    super.dispose();
  }

  int get _total => _items.fold(0, (sum, i) => sum + (i.quantity * i.unitPrice).round());

  Future<void> _save(int businessId) async {
    final l10n = AppLocalizations.of(context);
    final router = GoRouter.of(context);
    final valid = _items.where((i) => i.valid).toList();
    if (valid.isEmpty) {
      showToast(context, l10n.invoiceNeedsItem, kind: AlertKind.warning);
      return;
    }
    final ok = await ref
        .read(documentActionsProvider.notifier)
        .createStandaloneInvoice(
          businessId,
          items: [for (final i in valid) (name: i.name.text.trim(), qty: i.quantity, unitPriceHuf: i.unitPrice)],
          customerName: _customer.text,
          customerEmail: _email.text,
          dueDays: int.tryParse(_dueDays.text.trim()) ?? 8,
          alreadyPaid: _paid,
          paymentMethod: _method,
        );
    if (ok) {
      ref.invalidate(invoicesProvider(businessId));
      if (router.canPop()) router.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final businessId = ref.watch(staffSessionProvider).value?.businessId;
    listenFlash(ref, context, documentActionsProvider.select((s) => s.flash));
    final busy = ref.watch(documentActionsProvider.select((s) => s.busy));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.newInvoice)),
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
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.invoiceAlreadyPaid),
                  value: _paid,
                  onChanged: (v) => setState(() => _paid = v),
                ),
                if (_paid)
                  DropdownButtonFormField<String>(
                    initialValue: _method,
                    decoration: InputDecoration(labelText: l10n.payMethod),
                    items: [
                      for (final m in const ['cash', 'card', 'transfer', 'other'])
                        DropdownMenuItem(value: m, child: Text(paymentMethodLabel(l10n, m))),
                    ],
                    onChanged: (v) => setState(() => _method = v ?? 'cash'),
                  )
                else
                  TextField(
                    controller: _dueDays,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: l10n.invoiceDueDays),
                  ),
                const SizedBox(height: 24),
                FilledButton(onPressed: busy ? null : () => _save(businessId), child: Text(l10n.newInvoice)),
              ],
            ),
    );
  }
}
