import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_review/in_app_review.dart';

import '../storage/local_prefs.dart';

/// Az áruházi értékelés kérése: a második sikeres foglalás után egyszer, a rendszer saját ablakával.
class ReviewPrompt {
  ReviewPrompt(this._ref);

  final Ref _ref;
  static const _countKey = 'bookings_done';
  static const _askedKey = 'review_asked';

  Future<void> afterBooking() async {
    try {
      final prefs = await _ref.read(localPrefsProvider.future);
      if (prefs == null || (prefs.getBool(_askedKey) ?? false)) return;
      final count = (prefs.getInt(_countKey) ?? 0) + 1;
      await prefs.setInt(_countKey, count);
      if (count < 2) return;
      final review = InAppReview.instance;
      if (await review.isAvailable()) {
        await prefs.setBool(_askedKey, true);
        await review.requestReview();
      }
    } catch (_) {
      // Az értékelés kérése soha nem zavarhatja a foglalást.
    }
  }
}

final reviewPromptProvider = Provider<ReviewPrompt>(ReviewPrompt.new);
