import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/async_view.dart';
import '../../../shared/format.dart';
import '../model/owner_models.dart';
import '../viewmodel/owner_report_viewmodels.dart';

/// Riportok (View): havi eredmény-összesítő és a cash flow előrejelzés.
class OwnerReportsTab extends ConsumerWidget {
  const OwnerReportsTab({super.key, required this.businessId});

  final int businessId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final month = ref.watch(reportMonthProvider);
    final months = ref.read(reportMonthProvider.notifier);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(accountingReportProvider(businessId));
        ref.invalidate(cashflowProvider(businessId));
        await ref.read(accountingReportProvider(businessId).future);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(tooltip: l10n.previousMonth, icon: const Icon(Icons.chevron_left), onPressed: () => months.shift(-1)),
              Text(DateFormat.yMMMM(locale).format(month), style: Theme.of(context).textTheme.titleMedium),
              IconButton(tooltip: l10n.nextMonth, icon: const Icon(Icons.chevron_right), onPressed: () => months.shift(1)),
            ],
          ),
          AsyncView<AccountingReport>(
            value: ref.watch(accountingReportProvider(businessId)),
            onRetry: () => ref.invalidate(accountingReportProvider(businessId)),
            builder: (context, report) => _MonthlyCard(report: report),
          ),
          const SizedBox(height: 24),
          Text(l10n.cashflowTitle, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          AsyncView<List<CashflowPeriod>>(
            value: ref.watch(cashflowProvider(businessId)),
            onRetry: () => ref.invalidate(cashflowProvider(businessId)),
            builder: (context, periods) => Column(
              children: [
                if (periods.isEmpty) Text(l10n.nothingYet),
                for (final p in periods) _CashflowTile(period: p),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line(this.label, this.amount, {this.bold = false, this.color});

  final String label;
  final int amount;
  final bool bold;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final style = bold ? Theme.of(context).textTheme.titleSmall?.copyWith(color: color) : TextStyle(color: color);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Flexible(child: Text(label, style: style)), Text(formatHuf(context, amount), style: style)],
      ),
    );
  }
}

class _MonthlyCard extends StatelessWidget {
  const _MonthlyCard({required this.report});

  final AccountingReport report;

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
            Text(l10n.reportRevenue, style: theme.textTheme.titleSmall),
            _Line(l10n.reportServices, report.servicesHuf),
            if (report.productsHuf > 0) _Line(l10n.reportProducts, report.productsHuf),
            if (report.passesSoldHuf > 0) _Line(l10n.reportPasses, report.passesSoldHuf),
            if (report.vouchersSoldHuf > 0) _Line(l10n.reportVouchers, report.vouchersSoldHuf),
            _Line(l10n.reportRevenueTotal, report.grossTotalHuf, bold: true),
            const Divider(height: 24),
            Text(l10n.reportExpenses, style: theme.textTheme.titleSmall),
            for (final e in report.expensesByCategory.entries) _Line(e.key, e.value),
            if (report.payrollEstimateHuf != null) _Line(l10n.reportPayroll, report.payrollEstimateHuf!),
            if (report.materialCostHuf > 0) _Line(l10n.reportMaterials, report.materialCostHuf),
            _Line(l10n.reportExpensesTotal, report.expensesTotalHuf, bold: true),
            const Divider(height: 24),
            _Line(
              l10n.reportResult,
              report.resultHuf,
              bold: true,
              color: report.resultHuf < 0 ? theme.colorScheme.error : null,
            ),
            const SizedBox(height: 8),
            _Line(l10n.reportReceivables, report.receivablesAtMonthEndHuf),
          ],
        ),
      ),
    );
  }
}

class _CashflowTile extends StatelessWidget {
  const _CashflowTile({required this.period});

  final CashflowPeriod period;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Card(
      child: ListTile(
        title: Text(period.partial ? '${period.label} (${l10n.cashflowPartial})' : period.label),
        subtitle: Text('${l10n.cashflowIn}: ${formatHuf(context, period.inflowHuf)}\n${l10n.cashflowOut}: ${formatHuf(context, period.outflowHuf)}'),
        isThreeLine: true,
        trailing: Text(
          formatHuf(context, period.netHuf),
          style: theme.textTheme.titleSmall?.copyWith(color: period.netHuf < 0 ? theme.colorScheme.error : null),
        ),
      ),
    );
  }
}
