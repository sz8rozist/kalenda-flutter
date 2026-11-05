import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/date_param.dart';
import '../../../core/viewmodel/simple_viewmodels.dart';
import '../data/owner_repository.dart';
import '../model/owner_models.dart';

/// Az áttekintés adatai (heti bevétel, kintlévőség, mai foglalások); a kulcs a vállalkozás azonosítója.
class OwnerDashboardViewModel extends AsyncNotifier<OwnerDashboard> {
  OwnerDashboardViewModel(this.businessId);

  final int businessId;

  @override
  Future<OwnerDashboard> build() => ref.watch(ownerRepositoryProvider).dashboard(businessId);
}

final ownerDashboardProvider =
    AsyncNotifierProvider.autoDispose.family<OwnerDashboardViewModel, OwnerDashboard, int>(OwnerDashboardViewModel.new);

typedef OwnerRange = ({int businessId, DateRange range});

/// A vállalkozás naptára egy tartományra.
class OwnerCalendarViewModel extends AsyncNotifier<OwnerCalendar> {
  OwnerCalendarViewModel(this.query);

  final OwnerRange query;

  @override
  Future<OwnerCalendar> build() => ref.watch(ownerRepositoryProvider).calendar(query.businessId, query.range);
}

final ownerCalendarProvider =
    AsyncNotifierProvider.autoDispose.family<OwnerCalendarViewModel, OwnerCalendar, OwnerRange>(OwnerCalendarViewModel.new);

/// Az ügyfél-lista keresőszövege.
class CustomerSearchViewModel extends Notifier<String> {
  @override
  String build() => '';

  void search(String text) => state = text.trim();
}

final customerSearchProvider = NotifierProvider.autoDispose<CustomerSearchViewModel, String>(CustomerSearchViewModel.new);

/// Az ügyfelek listája a keresés szerint (az első oldal).
class OwnerCustomersViewModel extends AsyncNotifier<List<CustomerItem>> {
  OwnerCustomersViewModel(this.businessId);

  final int businessId;

  @override
  Future<List<CustomerItem>> build() {
    final search = ref.watch(customerSearchProvider);
    return ref.watch(ownerRepositoryProvider).customers(businessId, search);
  }
}

final ownerCustomersProvider =
    AsyncNotifierProvider.autoDispose.family<OwnerCustomersViewModel, List<CustomerItem>, int>(OwnerCustomersViewModel.new);

final ownerWeekProvider = NotifierProvider.autoDispose<WeekViewModel, DateTime>(WeekViewModel.new);
final ownerTabProvider = NotifierProvider.autoDispose<TabIndexViewModel, int>(TabIndexViewModel.new);
