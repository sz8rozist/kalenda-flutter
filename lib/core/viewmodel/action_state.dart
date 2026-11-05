import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Egy művelet visszajelzése a felhasználónak (snackbar). A szöveget a View állítja össze a nyelv szerint –
/// a ViewModel csak a fajtát (és hiba esetén a kivételt) adja.
enum FlashKind { saved, cancelled, error }

class Flash {
  const Flash(this.kind, [this.error]);

  const Flash.saved() : this(FlashKind.saved);

  final FlashKind kind;
  final Object? error;
}

/// A műveletet végző ViewModel állapota: folyamatban van-e, és mi a legutóbbi visszajelzés.
class ActionState {
  const ActionState({this.busy = false, this.flash});

  final bool busy;
  final Flash? flash;
}

/// A műveletet (mentés, törlés, váltás…) végző ViewModel őse. A leszármazott a [perform]-mal futtatja a
/// repository-hívást: a „busy" jelzést, a sikeres visszajelzést és a hibakezelést ez adja – a View-nak nincs dolga vele.
abstract class ActionNotifier extends Notifier<ActionState> {
  @override
  ActionState build() => const ActionState();

  /// Lefuttatja a műveletet. Igaz, ha sikerült; hibánál a [Flash] a hibát hordozza.
  Future<bool> perform(Future<void> Function() action, {FlashKind? success}) async {
    state = const ActionState(busy: true);
    try {
      await action();
      // A művelet közben a képernyő megszűnhetett (pl. fióktörlés után): ilyenkor nincs kinek visszajelezni.
      if (ref.mounted) state = ActionState(flash: success == null ? null : Flash(success));
      return true;
    } catch (e) {
      if (ref.mounted) state = ActionState(flash: Flash(FlashKind.error, e));
      return false;
    }
  }
}
