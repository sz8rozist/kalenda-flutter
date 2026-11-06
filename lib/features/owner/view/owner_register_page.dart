import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/async_view.dart';
import '../../../shared/flash.dart';
import '../../../shared/format.dart';
import '../../../shared/ui/app_alerts.dart';
import '../../../shared/ui/empty_state.dart';
import '../../staff/viewmodel/staff_session_viewmodel.dart';
import '../model/register_models.dart';
import '../viewmodel/owner_tools_viewmodels.dart';
import 'owner_appointment_page.dart' show paymentMethodLabel;

/// A napi pénztár (View): összesítő, tételek, kifizetetlen foglalások, tétel rögzítése, nap zárása.
class OwnerRegisterPage extends ConsumerWidget {
  const OwnerRegisterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final businessId = ref.watch(staffSessionProvider).value?.businessId;
    listenFlash(ref, context, registerActionsProvider.select((s) => s.flash));
    final date = ref.watch(registerDateProvider);
    final dates = ref.read(registerDateProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.ownerRegister)),
      floatingActionButton: businessId == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                showDragHandle: true,
                builder: (_) => _EntrySheet(businessId: businessId, date: date),
              ),
              icon: const Icon(Icons.add),
              label: Text(l10n.registerNewEntry),
            ),
      body: businessId == null
          ? Center(child: Text(l10n.ownerNoBusiness))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(icon: const Icon(Icons.chevron_left_rounded), onPressed: () => dates.shift(-1)),
                      TextButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: date,
                            firstDate: DateTime(DateTime.now().year - 2),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) dates.select(picked);
                        },
                        child: Text(formatDate(context, date)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right_rounded),
                        onPressed: DateUtils.isSameDay(date, DateTime.now()) ? null : () => dates.shift(1),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: AsyncView<RegisterDay>(
                    value: ref.watch(registerDayProvider(businessId)),
                    onRetry: () => ref.invalidate(registerDayProvider(businessId)),
                    builder: (context, day) => RefreshIndicator(
                      onRefresh: () => ref.refresh(registerDayProvider(businessId).future),
                      child: _DayView(businessId: businessId, day: day),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _DayView extends ConsumerWidget {
  const _DayView({required this.businessId, required this.day});

  final int businessId;
  final RegisterDay day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final actions = ref.read(registerActionsProvider.notifier);
    final busy = ref.watch(registerActionsProvider.select((s) => s.busy));

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(gradient: AppColors.heroGradient, borderRadius: BorderRadius.circular(AppDimens.radius)),
          child: DefaultTextStyle.merge(
            style: const TextStyle(color: Colors.white),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.registerIncome, style: theme.textTheme.titleSmall?.copyWith(color: Colors.white70)),
                Text(formatHuf(context, day.incomeTotal), style: theme.textTheme.headlineMedium?.copyWith(color: Colors.white)),
                const SizedBox(height: 10),
                Text('${l10n.registerOpening}: ${formatHuf(context, day.openingCash)}'),
                Text('${l10n.registerExpected}: ${formatHuf(context, day.expectedCash)}'),
                if (day.onlineTotal > 0) Text('${l10n.registerOnline}: ${formatHuf(context, day.onlineTotal)}'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (day.byMethod.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final e in day.byMethod.entries) Chip(label: Text('${paymentMethodLabel(l10n, e.key)}: ${formatHuf(context, e.value)}')),
            ],
          ),
        if (day.isClosed) ...[
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.lock_outline, color: AppColors.success),
              title: Text(l10n.registerClosed),
              subtitle: Text(
                '${formatHuf(context, day.closure!.countedHuf)} · ${l10n.registerDifference(formatHuf(context, day.closure!.differenceHuf))}',
              ),
              trailing: TextButton(onPressed: busy ? null : () => actions.reopen(businessId, day.date), child: Text(l10n.registerReopen)),
            ),
          ),
        ],
        if (day.unpaid.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(l10n.registerUnpaid, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final a in day.unpaid)
            Card(
              child: ListTile(
                title: Text([if (a.time != null) a.time!, if (a.service != null) a.service!].join(' · ')),
                subtitle: Text([if (a.customer != null) a.customer!, if (a.staff != null) a.staff!].join(' · ')),
                trailing: Text(formatHuf(context, a.dueHuf), style: theme.textTheme.titleSmall),
                onTap: day.isClosed
                    ? null
                    : () => showModalBottomSheet<void>(
                        context: context,
                        showDragHandle: true,
                        builder: (sheet) => SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for (final m in const ['cash', 'card', 'transfer', 'other'])
                                ListTile(
                                  leading: const Icon(Icons.payments_outlined),
                                  title: Text(l10n.registerPayWith(paymentMethodLabel(l10n, m))),
                                  onTap: () {
                                    Navigator.pop(sheet);
                                    actions.payAppointment(businessId, a.id, m);
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
              ),
            ),
        ],
        const SizedBox(height: 16),
        if (day.payments.isEmpty)
          EmptyNote(l10n.registerNoEntries, icon: Icons.point_of_sale_outlined)
        else
          for (final p in day.payments)
            Dismissible(
              key: ValueKey('payment-${p.id}'),
              direction: day.isClosed ? DismissDirection.none : DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                margin: const EdgeInsets.only(bottom: AppDimens.gap),
                decoration: BoxDecoration(color: AppColors.danger, borderRadius: BorderRadius.circular(AppDimens.radius)),
                child: const Icon(Icons.delete_outline, color: Colors.white),
              ),
              confirmDismiss: (_) => showConfirmAlert(
                context,
                title: l10n.registerDeleteTitle,
                message: formatHuf(context, p.amountHuf),
                confirmLabel: l10n.actionDelete,
                destructive: true,
                icon: Icons.delete_outline,
              ),
              onDismissed: (_) => actions.deletePayment(businessId, p.id),
              child: Card(
                child: ListTile(
                  leading: Icon(
                    p.isOut ? Icons.arrow_circle_up_outlined : Icons.arrow_circle_down_outlined,
                    color: p.isOut ? AppColors.danger : AppColors.success,
                  ),
                  title: Text(
                    [
                      switch (p.kind) {
                        'cash_in' => l10n.registerCashIn,
                        'cash_out' => l10n.registerCashOut,
                        _ => l10n.registerIncome,
                      },
                      if (p.description != null && p.description!.isNotEmpty) p.description!,
                    ].join(' · '),
                  ),
                  subtitle: Text(paymentMethodLabel(l10n, p.method)),
                  trailing: Text('${p.isOut ? '−' : ''}${formatHuf(context, p.amountHuf)}', style: theme.textTheme.titleSmall),
                ),
              ),
            ),
        if (!day.isClosed) ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.lock_outline),
            label: Text(l10n.registerClose),
            onPressed: busy ? null : () => _close(context, ref),
          ),
        ],
      ],
    );
  }

  Future<void> _close(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final counted = TextEditingController(text: '${day.expectedCash}');
    final note = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.registerClose),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: counted,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l10n.registerCounted),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: note,
              decoration: InputDecoration(labelText: l10n.notes),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.dialogCancel)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.registerClose)),
        ],
      ),
    );
    final amount = int.tryParse(counted.text.trim());
    final text = note.text;
    counted.dispose();
    note.dispose();
    if (confirmed == true && amount != null) {
      await ref.read(registerActionsProvider.notifier).close(businessId, day.date, countedCashHuf: amount, note: text);
    }
  }
}

class _EntrySheet extends ConsumerStatefulWidget {
  const _EntrySheet({required this.businessId, required this.date});

  final int businessId;
  final DateTime date;

  @override
  ConsumerState<_EntrySheet> createState() => _EntrySheetState();
}

class _EntrySheetState extends ConsumerState<_EntrySheet> {
  final _amount = TextEditingController();
  final _description = TextEditingController();
  String _kind = 'income';
  String _method = 'cash';

  @override
  void dispose() {
    _amount.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amount = int.tryParse(_amount.text.trim());
    if (amount == null || amount <= 0) return;
    final navigator = Navigator.of(context);
    final ok = await ref
        .read(registerActionsProvider.notifier)
        .record(widget.businessId, kind: _kind, method: _method, amountHuf: amount, date: widget.date, description: _description.text);
    if (ok) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final busy = ref.watch(registerActionsProvider.select((s) => s.busy));

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SegmentedButton<String>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(value: 'income', label: Text(l10n.registerIncome)),
                ButtonSegment(value: 'cash_in', label: Text(l10n.registerCashIn)),
                ButtonSegment(value: 'cash_out', label: Text(l10n.registerCashOut)),
              ],
              selected: {_kind},
              onSelectionChanged: (s) => setState(() => _kind = s.first),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amount,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l10n.expenseAmount),
            ),
            if (_kind == 'income') ...[
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
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _description,
              decoration: InputDecoration(labelText: l10n.registerDescription),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: busy ? null : _save, child: Text(l10n.save)),
          ],
        ),
      ),
    );
  }
}
