import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A kiválasztott fül sorszáma egy többfüles képernyőn.
class TabIndexViewModel extends Notifier<int> {
  @override
  int build() => 0;

  void select(int index) => state = index;
}

/// A naptár megjelenített hete (a hét hétfője). A heti nézetek közös állapota.
class WeekViewModel extends Notifier<DateTime> {
  @override
  DateTime build() => mondayOf(DateTime.now());

  void shift(int weeks) => state = state.add(Duration(days: 7 * weeks));

  static DateTime mondayOf(DateTime d) => DateTime(d.year, d.month, d.day).subtract(Duration(days: d.weekday - 1));
}

/// Egy kiválasztott nap (pl. áthelyezés dátumválasztója); a kulcs azonosítja, melyik választóhoz tartozik.
class SelectedDateViewModel extends Notifier<DateTime?> {
  SelectedDateViewModel(this.key);

  final String key;

  @override
  DateTime? build() => null;

  void select(DateTime? date) => state = date;
}

final selectedDateProvider = NotifierProvider.autoDispose.family<SelectedDateViewModel, DateTime?, String>(SelectedDateViewModel.new);
