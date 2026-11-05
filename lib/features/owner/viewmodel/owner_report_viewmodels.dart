import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/owner_repository.dart';
import '../model/owner_models.dart';

/// A riport megjelenített hónapja (a hónap első napja).
class ReportMonthViewModel extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  void shift(int months) => state = DateTime(state.year, state.month + months);
}

final reportMonthProvider = NotifierProvider.autoDispose<ReportMonthViewModel, DateTime>(ReportMonthViewModel.new);

/// A kiválasztott hónap könyvelői összesítője; a kulcs a vállalkozás azonosítója.
class AccountingReportViewModel extends AsyncNotifier<AccountingReport> {
  AccountingReportViewModel(this.businessId);

  final int businessId;

  @override
  Future<AccountingReport> build() {
    final month = ref.watch(reportMonthProvider);
    return ref.watch(ownerRepositoryProvider).accountingReport(businessId, month);
  }
}

final accountingReportProvider =
    AsyncNotifierProvider.autoDispose.family<AccountingReportViewModel, AccountingReport, int>(AccountingReportViewModel.new);

/// A cash flow előrejelzés időszakai.
class CashflowViewModel extends AsyncNotifier<List<CashflowPeriod>> {
  CashflowViewModel(this.businessId);

  final int businessId;

  @override
  Future<List<CashflowPeriod>> build() => ref.watch(ownerRepositoryProvider).cashflow(businessId);
}

final cashflowProvider =
    AsyncNotifierProvider.autoDispose.family<CashflowViewModel, List<CashflowPeriod>, int>(CashflowViewModel.new);
