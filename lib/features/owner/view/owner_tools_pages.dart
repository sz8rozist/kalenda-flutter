import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/async_view.dart';
import '../../../shared/flash.dart';
import '../../../shared/format.dart';
import '../../../shared/ui/app_alerts.dart';
import '../../../shared/ui/empty_state.dart';
import '../../../shared/ui/status_chip.dart';
import '../../staff/viewmodel/staff_session_viewmodel.dart';
import '../model/owner_tools_models.dart';
import '../viewmodel/owner_tools_viewmodels.dart';

/// Közös keret: a vállalkozás azonosítóját a munkamenetből veszi, nélküle hibaüzenetet mutat.
class _BusinessScaffold extends ConsumerWidget {
  const _BusinessScaffold({required this.title, required this.builder, this.floatingActionButton});

  final String title;
  final Widget Function(BuildContext context, int businessId) builder;
  final Widget Function(int businessId)? floatingActionButton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessId = ref.watch(staffSessionProvider).value?.businessId;
    listenFlash(ref, context, ownerToolsActionsProvider.select((s) => s.flash));

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      floatingActionButton: businessId == null ? null : floatingActionButton?.call(businessId),
      body: businessId == null ? Center(child: Text(AppLocalizations.of(context).ownerNoBusiness)) : builder(context, businessId),
    );
  }
}

// ─── Költségek ─────────────────────────────────────────────────

class OwnerExpensesPage extends ConsumerWidget {
  const OwnerExpensesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return _BusinessScaffold(
      title: l10n.ownerExpenses,
      floatingActionButton: (businessId) => FloatingActionButton.extended(
        onPressed: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          showDragHandle: true,
          builder: (_) =>
              _ExpenseSheet(businessId: businessId, categories: ref.read(expensesProvider(businessId)).value?.categories ?? const []),
        ),
        icon: const Icon(Icons.add),
        label: Text(l10n.newExpense),
      ),
      builder: (context, businessId) => AsyncView<ExpenseListing>(
        value: ref.watch(expensesProvider(businessId)),
        onRetry: () => ref.invalidate(expensesProvider(businessId)),
        builder: (context, data) => RefreshIndicator(
          onRefresh: () => ref.refresh(expensesProvider(businessId).future),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
            children: [
              if (data.expenses.isEmpty)
                EmptyNote(l10n.nothingYet, icon: Icons.receipt_long_outlined)
              else ...[
                Text(l10n.expensesTotal(formatHuf(context, data.totalHuf)), style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
              ],
              for (final e in data.expenses)
                Dismissible(
                  key: ValueKey('expense-${e.id}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    margin: const EdgeInsets.only(bottom: AppDimens.gap),
                    decoration: BoxDecoration(color: AppColors.danger, borderRadius: BorderRadius.circular(AppDimens.radius)),
                    child: const Icon(Icons.delete_outline, color: Colors.white),
                  ),
                  confirmDismiss: (_) => showConfirmAlert(
                    context,
                    title: l10n.deleteExpenseTitle,
                    message: l10n.deleteExpenseText,
                    confirmLabel: l10n.actionDelete,
                    destructive: true,
                    icon: Icons.delete_outline,
                  ),
                  onDismissed: (_) => ref.read(ownerToolsActionsProvider.notifier).deleteExpense(businessId, e.id),
                  child: Card(
                    child: ListTile(
                      leading: Icon(e.isRecurring ? Icons.event_repeat_outlined : Icons.receipt_outlined),
                      title: Text(e.category),
                      subtitle: Text(
                        [
                          if (e.date != null) formatDate(context, e.date!),
                          if (e.vendor != null && e.vendor!.isNotEmpty) e.vendor!,
                        ].join(' · '),
                      ),
                      trailing: Text(formatHuf(context, e.amountHuf), style: Theme.of(context).textTheme.titleSmall),
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

class _ExpenseSheet extends ConsumerStatefulWidget {
  const _ExpenseSheet({required this.businessId, required this.categories});

  final int businessId;
  final List<String> categories;

  @override
  ConsumerState<_ExpenseSheet> createState() => _ExpenseSheetState();
}

class _ExpenseSheetState extends ConsumerState<_ExpenseSheet> {
  final _formKey = GlobalKey<FormState>();
  final _category = TextEditingController();
  final _amount = TextEditingController();
  final _vendor = TextEditingController();
  DateTime _date = DateTime.now();
  bool _recurring = false;

  @override
  void dispose() {
    for (final c in [_category, _amount, _vendor]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(DateTime.now().year - 2),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final navigator = Navigator.of(context);
    final ok = await ref
        .read(ownerToolsActionsProvider.notifier)
        .addExpense(
          widget.businessId,
          category: _category.text.trim(),
          amountHuf: int.parse(_amount.text.trim()),
          date: _date,
          vendor: _vendor.text,
          recurring: _recurring,
        );
    if (ok) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final busy = ref.watch(ownerToolsActionsProvider.select((s) => s.busy));

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _category,
                decoration: InputDecoration(labelText: l10n.expenseCategory),
                validator: (v) => (v == null || v.trim().isEmpty) ? l10n.required : null,
              ),
              if (widget.categories.isNotEmpty)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 8,
                    children: [
                      for (final c in widget.categories.take(6))
                        ActionChip(label: Text(c), onPressed: () => setState(() => _category.text = c)),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amount,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.expenseAmount),
                validator: (v) => (int.tryParse(v?.trim() ?? '') ?? 0) <= 0 ? l10n.required : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _vendor,
                decoration: InputDecoration(labelText: l10n.expenseVendor),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(onPressed: _pickDate, icon: const Icon(Icons.event), label: Text(formatDate(context, _date))),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.expenseRecurring),
                value: _recurring,
                onChanged: (v) => setState(() => _recurring = v),
              ),
              const SizedBox(height: 8),
              FilledButton(onPressed: busy ? null : _save, child: Text(l10n.save)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Értékelések ───────────────────────────────────────────────

class OwnerReviewsPage extends ConsumerWidget {
  const OwnerReviewsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return _BusinessScaffold(
      title: l10n.ownerReviews,
      builder: (context, businessId) => AsyncView<ReviewListing>(
        value: ref.watch(reviewsProvider(businessId)),
        onRetry: () => ref.invalidate(reviewsProvider(businessId)),
        builder: (context, data) => RefreshIndicator(
          onRefresh: () => ref.refresh(reviewsProvider(businessId).future),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: AppColors.warning),
                          const SizedBox(width: 8),
                          Text(l10n.reviewsSummary(data.average.toStringAsFixed(1), data.count), style: theme.textTheme.titleMedium),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _ReviewSettings(businessId: businessId, listing: data),
                    ],
                  ),
                ),
              ),
              if (data.reviews.isEmpty) EmptyNote(l10n.nothingYet, icon: Icons.star_outline_rounded),
              for (final r in data.reviews)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            for (var i = 1; i <= 5; i++)
                              Icon(i <= r.rating ? Icons.star_rounded : Icons.star_outline_rounded, size: 20, color: AppColors.warning),
                            const Spacer(),
                            if (r.submittedAt != null)
                              Text(
                                DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(r.submittedAt!),
                                style: theme.textTheme.bodySmall,
                              ),
                          ],
                        ),
                        if (r.feedback != null && r.feedback!.isNotEmpty) ...[const SizedBox(height: 8), Text(r.feedback!)],
                        const SizedBox(height: 6),
                        Text(
                          [
                            if (r.customerName != null) r.customerName!,
                            if (r.serviceName != null) r.serviceName!,
                            if (r.staffName != null) r.staffName!,
                          ].join(' · '),
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
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

class _ReviewSettings extends ConsumerStatefulWidget {
  const _ReviewSettings({required this.businessId, required this.listing});

  final int businessId;
  final ReviewListing listing;

  @override
  ConsumerState<_ReviewSettings> createState() => _ReviewSettingsState();
}

class _ReviewSettingsState extends ConsumerState<_ReviewSettings> {
  late final _url = TextEditingController(text: widget.listing.googleReviewUrl ?? '');
  late bool _enabled = widget.listing.enabled;

  @override
  void dispose() {
    _url.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final busy = ref.watch(ownerToolsActionsProvider.select((s) => s.busy));

    return Column(
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.reviewsEnabled),
          value: _enabled,
          onChanged: (v) => setState(() => _enabled = v),
        ),
        TextField(
          controller: _url,
          keyboardType: TextInputType.url,
          decoration: InputDecoration(labelText: l10n.googleReviewUrl),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(120, 44)),
            onPressed: busy
                ? null
                : () => ref
                      .read(ownerToolsActionsProvider.notifier)
                      .saveReviewSettings(widget.businessId, enabled: _enabled, googleUrl: _url.text),
            child: Text(l10n.save),
          ),
        ),
      ],
    );
  }
}

// ─── Bérletek és utalványok ────────────────────────────────────

class OwnerPassesPage extends ConsumerWidget {
  const OwnerPassesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return _BusinessScaffold(
      title: l10n.ownerPasses,
      builder: (context, businessId) => AsyncView<List<SoldPass>>(
        value: ref.watch(soldPassesProvider(businessId)),
        onRetry: () => ref.invalidate(soldPassesProvider(businessId)),
        builder: (context, passes) => RefreshIndicator(
          onRefresh: () => ref.refresh(soldPassesProvider(businessId).future),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (passes.isEmpty) EmptyNote(l10n.nothingYet, icon: Icons.confirmation_number_outlined),
              for (final p in passes)
                Card(
                  child: ListTile(
                    leading: Icon(p.kind == 'voucher' ? Icons.card_giftcard_rounded : Icons.confirmation_number_outlined),
                    title: Text(p.name),
                    subtitle: Text(
                      [
                        p.kind == 'voucher' ? l10n.passKindVoucher : l10n.passKindPass,
                        if (p.code != null) p.code!,
                        if (p.recipientName != null && p.recipientName!.isNotEmpty) l10n.passRecipient(p.recipientName!),
                        if (p.purchaserEmail != null) p.purchaserEmail!,
                        if (p.expiresAt != null) formatDate(context, p.expiresAt!),
                      ].join(' · '),
                    ),
                    isThreeLine: true,
                    trailing: Text(
                      p.sessionsRemaining != null
                          ? l10n.sessionsLeft(p.sessionsRemaining!)
                          : p.balanceHuf != null
                          ? formatHuf(context, p.balanceHuf!)
                          : '',
                      style: Theme.of(context).textTheme.labelMedium,
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

// ─── Várólista ─────────────────────────────────────────────────

class OwnerWaitlistPage extends ConsumerWidget {
  const OwnerWaitlistPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final actions = ref.read(ownerToolsActionsProvider.notifier);

    String statusLabelOf(String status) => switch (status) {
      'waiting' => l10n.waitlistWaiting,
      'notified' => l10n.waitlistNotified,
      'booked' => l10n.waitlistBooked,
      _ => l10n.waitlistExpired,
    };

    return _BusinessScaffold(
      title: l10n.ownerWaitlist,
      builder: (context, businessId) => AsyncView<List<WaitlistEntry>>(
        value: ref.watch(waitlistProvider(businessId)),
        onRetry: () => ref.invalidate(waitlistProvider(businessId)),
        builder: (context, entries) => RefreshIndicator(
          onRefresh: () => ref.refresh(waitlistProvider(businessId).future),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (entries.isEmpty) EmptyNote(l10n.nothingYet, icon: Icons.hourglass_empty_rounded),
              for (final e in entries)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text(e.customerName, style: Theme.of(context).textTheme.titleSmall)),
                            StatusChip(
                              e.status == 'waiting'
                                  ? 'pending'
                                  : e.status == 'booked'
                                  ? 'confirmed'
                                  : e.status == 'notified'
                                  ? 'approved'
                                  : 'cancelled',
                              label: statusLabelOf(e.status),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          [
                            if (e.serviceName != null) e.serviceName!,
                            if (e.staffName != null) e.staffName!,
                            if (e.preferredDate != null) formatDate(context, e.preferredDate!),
                            if (e.customerEmail != null) e.customerEmail!,
                          ].join(' · '),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (e.status == 'waiting' || e.status == 'notified')
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(onPressed: () => actions.removeWaitlist(businessId, e.id), child: Text(l10n.waitlistRemove)),
                              if (e.status == 'waiting')
                                FilledButton.tonal(
                                  style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
                                  onPressed: () => actions.notifyWaitlist(businessId, e.id),
                                  child: Text(l10n.waitlistNotify),
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

// ─── Tevékenység-napló ─────────────────────────────────────────

class OwnerActivityLogPage extends ConsumerStatefulWidget {
  const OwnerActivityLogPage({super.key});

  @override
  ConsumerState<OwnerActivityLogPage> createState() => _OwnerActivityLogPageState();
}

class _OwnerActivityLogPageState extends ConsumerState<OwnerActivityLogPage> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return _BusinessScaffold(
      title: l10n.ownerActivityLog,
      builder: (context, businessId) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _search,
              textInputAction: TextInputAction.search,
              onSubmitted: ref.read(activitySearchProvider.notifier).search,
              decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: l10n.activitySearch),
            ),
          ),
          Expanded(
            child: AsyncView<List<ActivityEntry>>(
              value: ref.watch(activityLogProvider(businessId)),
              onRetry: () => ref.invalidate(activityLogProvider(businessId)),
              builder: (context, entries) => RefreshIndicator(
                onRefresh: () => ref.refresh(activityLogProvider(businessId).future),
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    if (entries.isEmpty) EmptyNote(l10n.nothingYet, icon: Icons.history_rounded),
                    for (final e in entries)
                      Card(
                        child: ListTile(
                          dense: true,
                          title: Text([e.action, if (e.subjectLabel != null) e.subjectLabel!].join(' · ')),
                          subtitle: Text(
                            [
                              e.actorName,
                              if (e.subjectType != null) e.subjectType!,
                              if (e.createdAt != null) formatDateTime(context, e.createdAt!),
                            ].join(' · '),
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ),
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
