import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/booking_repository.dart';
import '../model/booking_request.dart';

/// Bérlet / utalvány vásárlásának állapota.
class PassPurchaseState {
  const PassPurchaseState({this.gift = false, this.busy = false, this.error, this.checkoutUrl});

  /// Ajándékba veszi (a címzett adatai is kellenek).
  final bool gift;
  final bool busy;
  final Object? error;

  /// Siker esetén a fizetési oldal címe (a View megnyitja a böngészőben).
  final String? checkoutUrl;

  PassPurchaseState copyWith({bool? gift, bool? busy, Object? error, bool clearError = false, String? checkoutUrl}) => PassPurchaseState(
        gift: gift ?? this.gift,
        busy: busy ?? this.busy,
        error: clearError ? null : (error ?? this.error),
        checkoutUrl: checkoutUrl ?? this.checkoutUrl,
      );
}

typedef PassPurchaseArgs = ({String slug, int passTypeId});

class PassPurchaseViewModel extends Notifier<PassPurchaseState> {
  PassPurchaseViewModel(this.args);

  final PassPurchaseArgs args;

  @override
  PassPurchaseState build() => const PassPurchaseState();

  void setGift(bool value) => state = state.copyWith(gift: value);

  /// A vásárló e-mail-címével (és ajándéknál a címzett adataival) elindítja a fizetést.
  Future<void> purchase({required String email, String? recipientName, String? recipientEmail, String? senderName, String? giftMessage}) async {
    state = state.copyWith(busy: true, clearError: true);
    try {
      final url = await ref.read(bookingRepositoryProvider).passCheckoutUrl(
            args.slug,
            PassPurchaseRequest(
              passTypeId: args.passTypeId,
              email: email,
              recipientName: state.gift ? recipientName : null,
              recipientEmail: state.gift ? recipientEmail : null,
              senderName: state.gift ? senderName : null,
              giftMessage: state.gift ? giftMessage : null,
            ),
          );
      if (ref.mounted) state = state.copyWith(busy: false, checkoutUrl: url);
    } catch (e) {
      if (ref.mounted) state = state.copyWith(busy: false, error: e);
    }
  }
}

final passPurchaseViewModelProvider =
    NotifierProvider.autoDispose.family<PassPurchaseViewModel, PassPurchaseState, PassPurchaseArgs>(PassPurchaseViewModel.new);
