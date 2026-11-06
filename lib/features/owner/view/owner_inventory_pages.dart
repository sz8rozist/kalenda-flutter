import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/async_view.dart';
import '../../../shared/flash.dart';
import '../../../shared/format.dart';
import '../../../shared/ui/app_alerts.dart';
import '../../../shared/ui/empty_state.dart';
import '../../../shared/ui/status_chip.dart';
import '../../staff/viewmodel/staff_session_viewmodel.dart';
import '../model/inventory_models.dart';
import '../viewmodel/inventory_viewmodels.dart';
import 'owner_appointment_page.dart' show paymentMethodLabel;

/// Közös keret: a vállalkozás azonosítóját a munkamenetből veszi, a műveletek visszajelzését figyeli.
class _Frame extends ConsumerWidget {
  const _Frame({required this.title, required this.builder, this.fab});

  final String title;
  final Widget Function(BuildContext context, int businessId) builder;
  final Widget Function(BuildContext context, int businessId)? fab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessId = ref.watch(staffSessionProvider).value?.businessId;
    listenFlash(ref, context, inventoryActionsProvider.select((s) => s.flash));

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      floatingActionButton: businessId == null ? null : fab?.call(context, businessId),
      body: businessId == null ? Center(child: Text(AppLocalizations.of(context).ownerNoBusiness)) : builder(context, businessId),
    );
  }
}

Future<void> _sheet(BuildContext context, WidgetBuilder builder) =>
    showModalBottomSheet<void>(context: context, isScrollControlled: true, showDragHandle: true, builder: builder);

int? _int(TextEditingController c) => int.tryParse(c.text.trim());

// ─── Termékek ──────────────────────────────────────────────────

class OwnerProductsPage extends ConsumerStatefulWidget {
  const OwnerProductsPage({super.key});

  @override
  ConsumerState<OwnerProductsPage> createState() => _OwnerProductsPageState();
}

class _OwnerProductsPageState extends ConsumerState<OwnerProductsPage> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final filter = ref.watch(productFilterProvider);
    final filters = ref.read(productFilterProvider.notifier);

    return _Frame(
      title: l10n.ownerProducts,
      fab: (context, businessId) => FloatingActionButton.extended(
        onPressed: () => _sheet(context, (_) => _ProductSheet(businessId: businessId)),
        icon: const Icon(Icons.add),
        label: Text(l10n.newProduct),
      ),
      builder: (context, businessId) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _search,
              textInputAction: TextInputAction.search,
              onSubmitted: filters.search,
              decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: l10n.searchCustomers),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FilterChip(
                label: Text(l10n.productsLowOnly),
                selected: filter.lowStockOnly,
                onSelected: (_) => filters.toggleLowStock(),
              ),
            ),
          ),
          Expanded(
            child: AsyncView<List<Product>>(
              value: ref.watch(productsProvider(businessId)),
              onRetry: () => ref.invalidate(productsProvider(businessId)),
              builder: (context, products) => RefreshIndicator(
                onRefresh: () => ref.refresh(productsProvider(businessId).future),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                  children: [
                    if (products.isEmpty) EmptyNote(l10n.nothingYet, icon: Icons.inventory_2_outlined),
                    for (final p in products) _ProductTile(product: p, businessId: businessId),
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

class _ProductTile extends ConsumerWidget {
  const _ProductTile({required this.product, required this.businessId});

  final Product product;
  final int businessId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Card(
      child: ListTile(
        leading: Icon(Icons.inventory_2_outlined, color: product.isLowStock ? AppColors.warning : theme.colorScheme.primary),
        title: Text(product.name),
        subtitle: Text(
          [
            formatHuf(context, product.priceHuf),
            l10n.stockLabel(product.stockQuantity),
            if (product.isLowStock) l10n.productLowStock,
            if (!product.isActive) l10n.statusCancelled,
          ].join(' · '),
          style: TextStyle(color: product.isLowStock ? AppColors.warning : null),
        ),
        trailing: IconButton(
          tooltip: l10n.productSell,
          icon: const Icon(Icons.shopping_cart_checkout_rounded),
          onPressed: product.stockQuantity <= 0 ? null : () => _sheet(context, (_) => _SellSheet(product: product, businessId: businessId)),
        ),
        onTap: () => _sheet(context, (_) => _ProductSheet(businessId: businessId, product: product)),
      ),
    );
  }
}

class _ProductSheet extends ConsumerStatefulWidget {
  const _ProductSheet({required this.businessId, this.product});

  final int businessId;
  final Product? product;

  @override
  ConsumerState<_ProductSheet> createState() => _ProductSheetState();
}

class _ProductSheetState extends ConsumerState<_ProductSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.product?.name ?? '');
  late final _sku = TextEditingController(text: widget.product?.sku ?? '');
  late final _price = TextEditingController(text: widget.product?.priceHuf.toString() ?? '');
  late final _cost = TextEditingController(text: widget.product?.costPriceHuf?.toString() ?? '');
  late final _stock = TextEditingController(text: '${widget.product?.stockQuantity ?? 0}');
  late final _low = TextEditingController(text: widget.product?.lowStockThreshold?.toString() ?? '');
  late bool _active = widget.product?.isActive ?? true;

  @override
  void dispose() {
    for (final c in [_name, _sku, _price, _cost, _stock, _low]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final navigator = Navigator.of(context);
    final existing = widget.product;
    final ok = await ref
        .read(inventoryActionsProvider.notifier)
        .saveProduct(
          widget.businessId,
          Product(
            id: existing?.id ?? 0,
            name: _name.text.trim(),
            description: existing?.description,
            sku: _sku.text.trim(),
            priceHuf: _int(_price)!,
            costPriceHuf: _int(_cost),
            supplierId: existing?.supplierId,
            stockQuantity: _int(_stock) ?? 0,
            packageSize: existing?.packageSize,
            packageUnit: existing?.packageUnit,
            lowStockThreshold: _int(_low),
            isActive: _active,
            isLowStock: false,
          ),
        );
    if (ok) navigator.pop();
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final navigator = Navigator.of(context);
    final confirmed = await showConfirmAlert(
      context,
      title: l10n.deleteProductTitle,
      message: widget.product!.name,
      confirmLabel: l10n.actionDelete,
      destructive: true,
      icon: Icons.delete_outline,
    );
    if (!confirmed) return;
    final ok = await ref.read(inventoryActionsProvider.notifier).deleteProduct(widget.businessId, widget.product!.id);
    if (ok) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final busy = ref.watch(inventoryActionsProvider.select((s) => s.busy));
    String? required(String? v) => (v == null || v.trim().isEmpty) ? l10n.required : null;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _name,
                decoration: InputDecoration(labelText: l10n.name),
                validator: required,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _sku,
                decoration: InputDecoration(labelText: l10n.productSku),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _price,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: l10n.productPrice),
                      validator: (v) => _int(_price) == null ? l10n.required : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _cost,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: l10n.productCost),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _stock,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: l10n.productStock),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _low,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: l10n.productLowThreshold),
                    ),
                  ),
                ],
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.fieldActive),
                value: _active,
                onChanged: (v) => setState(() => _active = v),
              ),
              FilledButton(onPressed: busy ? null : _save, child: Text(l10n.save)),
              if (widget.product != null)
                TextButton.icon(
                  icon: const Icon(Icons.delete_outline),
                  label: Text(l10n.actionDelete),
                  style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
                  onPressed: busy ? null : _delete,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SellSheet extends ConsumerStatefulWidget {
  const _SellSheet({required this.product, required this.businessId});

  final Product product;
  final int businessId;

  @override
  ConsumerState<_SellSheet> createState() => _SellSheetState();
}

class _SellSheetState extends ConsumerState<_SellSheet> {
  final _quantity = TextEditingController(text: '1');
  final _customer = TextEditingController();
  String _method = 'cash';

  @override
  void dispose() {
    _quantity.dispose();
    _customer.dispose();
    super.dispose();
  }

  Future<void> _sell() async {
    final quantity = _int(_quantity);
    if (quantity == null || quantity <= 0 || quantity > widget.product.stockQuantity) return;
    final navigator = Navigator.of(context);
    final ok = await ref
        .read(inventoryActionsProvider.notifier)
        .sell(widget.businessId, productId: widget.product.id, quantity: quantity, customerName: _customer.text, paymentMethod: _method);
    if (ok) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final busy = ref.watch(inventoryActionsProvider.select((s) => s.busy));

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.product.name, style: Theme.of(context).textTheme.titleLarge),
            Text('${formatHuf(context, widget.product.priceHuf)} · ${l10n.stockLabel(widget.product.stockQuantity)}'),
            const SizedBox(height: 16),
            TextField(
              controller: _quantity,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l10n.sellQuantity),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _customer,
              decoration: InputDecoration(labelText: l10n.invoiceCustomerName),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _method,
              decoration: InputDecoration(labelText: l10n.payMethod),
              items: [
                for (final m in const ['cash', 'card', 'transfer', 'other'])
                  DropdownMenuItem(value: m, child: Text(paymentMethodLabel(l10n, m))),
              ],
              onChanged: (v) => setState(() => _method = v ?? 'cash'),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: busy ? null : _sell, child: Text(l10n.productSell)),
          ],
        ),
      ),
    );
  }
}

// ─── Beszállítók ───────────────────────────────────────────────

class OwnerSuppliersPage extends ConsumerWidget {
  const OwnerSuppliersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return _Frame(
      title: l10n.ownerSuppliers,
      fab: (context, businessId) => FloatingActionButton.extended(
        onPressed: () => _sheet(context, (_) => _SupplierSheet(businessId: businessId)),
        icon: const Icon(Icons.add),
        label: Text(l10n.newSupplier),
      ),
      builder: (context, businessId) => AsyncView<List<Supplier>>(
        value: ref.watch(suppliersProvider(businessId)),
        onRetry: () => ref.invalidate(suppliersProvider(businessId)),
        builder: (context, suppliers) => RefreshIndicator(
          onRefresh: () => ref.refresh(suppliersProvider(businessId).future),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              if (suppliers.isEmpty) EmptyNote(l10n.nothingYet, icon: Icons.local_shipping_outlined),
              for (final s in suppliers)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.local_shipping_outlined),
                    title: Text(s.name),
                    subtitle: Text(
                      [if (s.contactName != null) s.contactName!, if (s.email != null) s.email!, if (s.phone != null) s.phone!].join(' · '),
                    ),
                    onTap: () => _sheet(context, (_) => _SupplierSheet(businessId: businessId, supplier: s)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SupplierSheet extends ConsumerStatefulWidget {
  const _SupplierSheet({required this.businessId, this.supplier});

  final int businessId;
  final Supplier? supplier;

  @override
  ConsumerState<_SupplierSheet> createState() => _SupplierSheetState();
}

class _SupplierSheetState extends ConsumerState<_SupplierSheet> {
  late final _name = TextEditingController(text: widget.supplier?.name ?? '');
  late final _contact = TextEditingController(text: widget.supplier?.contactName ?? '');
  late final _email = TextEditingController(text: widget.supplier?.email ?? '');
  late final _phone = TextEditingController(text: widget.supplier?.phone ?? '');
  late final _tax = TextEditingController(text: widget.supplier?.taxNumber ?? '');

  @override
  void dispose() {
    for (final c in [_name, _contact, _email, _phone, _tax]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) return;
    final navigator = Navigator.of(context);
    final ok = await ref
        .read(inventoryActionsProvider.notifier)
        .saveSupplier(
          widget.businessId,
          Supplier(
            id: widget.supplier?.id ?? 0,
            name: _name.text.trim(),
            contactName: _contact.text.trim(),
            email: _email.text.trim(),
            phone: _phone.text.trim(),
            taxNumber: _tax.text.trim(),
            note: widget.supplier?.note,
            isActive: true,
          ),
        );
    if (ok) navigator.pop();
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final navigator = Navigator.of(context);
    final confirmed = await showConfirmAlert(
      context,
      title: l10n.deleteSupplierTitle,
      message: widget.supplier!.name,
      confirmLabel: l10n.actionDelete,
      destructive: true,
      icon: Icons.delete_outline,
    );
    if (!confirmed) return;
    final ok = await ref.read(inventoryActionsProvider.notifier).deleteSupplier(widget.businessId, widget.supplier!.id);
    if (ok) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final busy = ref.watch(inventoryActionsProvider.select((s) => s.busy));

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _name,
              decoration: InputDecoration(labelText: l10n.name),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contact,
              decoration: InputDecoration(labelText: l10n.supplierContact),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: l10n.email),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: l10n.phone),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _tax,
              decoration: InputDecoration(labelText: l10n.supplierTax),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: busy ? null : _save, child: Text(l10n.save)),
            if (widget.supplier != null)
              TextButton.icon(
                icon: const Icon(Icons.delete_outline),
                label: Text(l10n.actionDelete),
                style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
                onPressed: busy ? null : _delete,
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Beszerzési rendelések ─────────────────────────────────────

class OwnerPurchasingPage extends ConsumerWidget {
  const OwnerPurchasingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final actions = ref.read(inventoryActionsProvider.notifier);

    String statusText(String s) => switch (s) {
      'ordered' => l10n.orderStatusOrdered,
      'received' => l10n.orderStatusReceived,
      'cancelled' => l10n.orderStatusCancelled,
      _ => l10n.orderStatusDraft,
    };
    String chipStatus(String s) => switch (s) {
      'received' => 'confirmed',
      'ordered' => 'approved',
      'cancelled' => 'cancelled',
      _ => 'pending',
    };

    return _Frame(
      title: l10n.ownerPurchasing,
      fab: (context, businessId) => FloatingActionButton.extended(
        onPressed: () async {
          final suppliers = await ref.read(suppliersProvider(businessId).future);
          if (!context.mounted) return;
          if (suppliers.isEmpty) {
            showToast(context, l10n.orderNeedsSupplier, kind: AlertKind.warning);
            return;
          }
          await _sheet(context, (_) => _OrderSheet(businessId: businessId, suppliers: suppliers));
        },
        icon: const Icon(Icons.add),
        label: Text(l10n.newOrder),
      ),
      builder: (context, businessId) => AsyncView<List<PurchaseOrder>>(
        value: ref.watch(purchaseOrdersProvider(businessId)),
        onRetry: () => ref.invalidate(purchaseOrdersProvider(businessId)),
        builder: (context, orders) => RefreshIndicator(
          onRefresh: () => ref.refresh(purchaseOrdersProvider(businessId).future),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              if (orders.isEmpty) EmptyNote(l10n.nothingYet, icon: Icons.local_shipping_outlined),
              for (final o in orders)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                [if (o.number != null) o.number!, if (o.supplierName != null) o.supplierName!].join(' · '),
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ),
                            StatusChip(chipStatus(o.status), label: statusText(o.status)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          [
                            formatHuf(context, o.totalHuf),
                            if (o.expectedDate != null && o.isOpen) l10n.orderExpected(formatDate(context, o.expectedDate!)),
                          ].join(' · '),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        for (final i in o.items) Text('${i.quantity} × ${i.description}', style: Theme.of(context).textTheme.bodySmall),
                        if (o.isOpen)
                          Wrap(
                            alignment: WrapAlignment.end,
                            spacing: 8,
                            children: [
                              TextButton(
                                style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
                                onPressed: () => actions.cancelOrder(businessId, o.id),
                                child: Text(l10n.orderCancel),
                              ),
                              if (o.status == 'draft')
                                OutlinedButton(onPressed: () => actions.markOrdered(businessId, o.id), child: Text(l10n.orderMarkOrdered)),
                              FilledButton(
                                style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
                                onPressed: () => _sheet(context, (_) => _ReceiveSheet(businessId: businessId, order: o)),
                                child: Text(l10n.orderReceive),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderLineRow {
  final description = TextEditingController();
  final quantity = TextEditingController(text: '1');
  final cost = TextEditingController();

  void dispose() {
    description.dispose();
    quantity.dispose();
    cost.dispose();
  }

  bool get valid =>
      description.text.trim().isNotEmpty && (int.tryParse(quantity.text.trim()) ?? 0) > 0 && (int.tryParse(cost.text.trim()) ?? -1) >= 0;
}

class _OrderSheet extends ConsumerStatefulWidget {
  const _OrderSheet({required this.businessId, required this.suppliers});

  final int businessId;
  final List<Supplier> suppliers;

  @override
  ConsumerState<_OrderSheet> createState() => _OrderSheetState();
}

class _OrderSheetState extends ConsumerState<_OrderSheet> {
  late int _supplierId = widget.suppliers.first.id;
  final _lines = [_OrderLineRow()];

  @override
  void dispose() {
    for (final l in _lines) {
      l.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final valid = _lines.where((l) => l.valid).toList();
    if (valid.isEmpty) {
      showToast(context, l10n.orderNeedsLine, kind: AlertKind.warning);
      return;
    }
    final navigator = Navigator.of(context);
    final ok = await ref
        .read(inventoryActionsProvider.notifier)
        .createOrder(
          widget.businessId,
          supplierId: _supplierId,
          lines: [
            for (final l in valid)
              (
                productId: null,
                description: l.description.text.trim(),
                quantity: int.parse(l.quantity.text.trim()),
                unitCostHuf: int.parse(l.cost.text.trim()),
              ),
          ],
        );
    if (ok) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final busy = ref.watch(inventoryActionsProvider.select((s) => s.busy));

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<int>(
              initialValue: _supplierId,
              decoration: InputDecoration(labelText: l10n.orderSupplier),
              items: [for (final s in widget.suppliers) DropdownMenuItem(value: s.id, child: Text(s.name))],
              onChanged: (v) => setState(() => _supplierId = v ?? _supplierId),
            ),
            const SizedBox(height: 12),
            for (final (index, line) in _lines.indexed)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: line.description,
                        decoration: InputDecoration(labelText: l10n.orderLineDescription),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 60,
                      child: TextField(
                        controller: line.quantity,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: l10n.orderLineQty),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: line.cost,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: l10n.orderLineCost),
                      ),
                    ),
                    if (_lines.length > 1)
                      IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => setState(() => _lines.removeAt(index).dispose())),
                  ],
                ),
              ),
            TextButton.icon(
              onPressed: () => setState(() => _lines.add(_OrderLineRow())),
              icon: const Icon(Icons.add),
              label: Text(l10n.orderAddLine),
            ),
            const SizedBox(height: 8),
            FilledButton(onPressed: busy ? null : _save, child: Text(l10n.save)),
          ],
        ),
      ),
    );
  }
}

class _ReceiveSheet extends ConsumerStatefulWidget {
  const _ReceiveSheet({required this.businessId, required this.order});

  final int businessId;
  final PurchaseOrder order;

  @override
  ConsumerState<_ReceiveSheet> createState() => _ReceiveSheetState();
}

class _ReceiveSheetState extends ConsumerState<_ReceiveSheet> {
  late final Map<int, TextEditingController> _qty = {
    for (final i in widget.order.items) i.id: TextEditingController(text: '${i.quantity}'),
  };

  @override
  void dispose() {
    for (final c in _qty.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final navigator = Navigator.of(context);
    final received = {for (final e in _qty.entries) e.key: (int.tryParse(e.value.text.trim()) ?? 0).clamp(0, 100000)};
    final ok = await ref.read(inventoryActionsProvider.notifier).receiveOrder(widget.businessId, widget.order.id, received);
    if (ok) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final busy = ref.watch(inventoryActionsProvider.select((s) => s.busy));

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final i in widget.order.items)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Expanded(child: Text('${i.description} (${i.quantity})')),
                    SizedBox(
                      width: 110,
                      child: TextField(
                        controller: _qty[i.id],
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: l10n.orderReceivedQty),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            FilledButton(onPressed: busy ? null : _save, child: Text(l10n.orderReceive)),
          ],
        ),
      ),
    );
  }
}
