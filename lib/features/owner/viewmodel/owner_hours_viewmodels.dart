import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/viewmodel/action_state.dart';
import '../data/owner_repository.dart';
import '../model/owner_models.dart';

/// A heti nyitvatartás szerkesztője: a szerverről betöltött sorok, amelyeket a felhasználó helyben módosít, majd egyben
/// ment. A kulcs a vállalkozás azonosítója.
class HoursEditorViewModel extends AsyncNotifier<List<HourRow>> {
  HoursEditorViewModel(this.businessId);

  final int businessId;

  @override
  Future<List<HourRow>> build() async {
    final rows = await ref.watch(ownerRepositoryProvider).hours(businessId);
    return _ordered(rows);
  }

  /// Hétfővel kezdődő sorrend (a szerver a 0 = vasárnap számozást használja).
  static List<HourRow> _ordered(List<HourRow> rows) =>
      [...rows]..sort((a, b) => ((a.dayOfWeek + 6) % 7).compareTo((b.dayOfWeek + 6) % 7));

  void setClosed(int day, bool closed) => _edit(day, (r) => r.copyWith(isClosed: closed));

  void setOpenAt(int day, String time) => _edit(day, (r) => r.copyWith(openAt: time));

  void setCloseAt(int day, String time) => _edit(day, (r) => r.copyWith(closeAt: time));

  void _edit(int day, HourRow Function(HourRow row) change) {
    final rows = state.value;
    if (rows == null) return;
    state = AsyncData([for (final r in rows) r.dayOfWeek == day ? change(r) : r]);
  }

  /// A mentett állapot átvétele (a szerver válasza).
  void replace(List<HourRow> saved) => state = AsyncData(_ordered(saved));
}

final hoursEditorProvider =
    AsyncNotifierProvider.autoDispose.family<HoursEditorViewModel, List<HourRow>, int>(HoursEditorViewModel.new);

/// A nyitvatartás mentése.
class HoursActionsViewModel extends ActionNotifier {
  Future<void> save(int businessId) async {
    final rows = ref.read(hoursEditorProvider(businessId)).value;
    if (rows == null) return;

    await perform(() async {
      final saved = await ref.read(ownerRepositoryProvider).saveHours(businessId, rows);
      ref.read(hoursEditorProvider(businessId).notifier).replace(saved);
    }, success: FlashKind.saved);
  }
}

final hoursActionsProvider = NotifierProvider.autoDispose<HoursActionsViewModel, ActionState>(HoursActionsViewModel.new);
