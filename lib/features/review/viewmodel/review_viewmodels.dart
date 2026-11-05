import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/review_repository.dart';
import '../model/review_models.dart';

/// Az értékelendő foglalás adatai és (ha már értékelt) az eredmény; a kulcs a token.
class ReviewViewModel extends AsyncNotifier<ReviewInfo> {
  ReviewViewModel(this.token);

  final String token;

  @override
  Future<ReviewInfo> build() => ref.watch(reviewRepositoryProvider).info(token);
}

final reviewViewModelProvider = AsyncNotifierProvider.autoDispose.family<ReviewViewModel, ReviewInfo, String>(ReviewViewModel.new);

/// Az értékelő űrlap állapota: a csillagok és a beküldés.
class ReviewFormState {
  const ReviewFormState({this.rating = 0, this.busy = false, this.error});

  /// A kiválasztott csillagok száma (0 = még nincs).
  final int rating;
  final bool busy;
  final Object? error;
}

/// A kulcs: a token és az e-mailben szereplő csillag-link által előre kiválasztott értékelés (0 = nincs).
typedef ReviewArgs = ({String token, int initialRating});

class ReviewFormViewModel extends Notifier<ReviewFormState> {
  ReviewFormViewModel(this.args);

  final ReviewArgs args;

  @override
  ReviewFormState build() => ReviewFormState(rating: args.initialRating.clamp(0, 5));

  void setRating(int rating) => state = ReviewFormState(rating: rating);

  /// Beküldés; siker esetén az értékelő oldal adata frissül (már leadott állapot).
  Future<void> submit(String? feedback) async {
    if (state.rating < 1) return;
    state = ReviewFormState(rating: state.rating, busy: true);
    try {
      await ref.read(reviewRepositoryProvider).submit(args.token, rating: state.rating, feedback: feedback);
      ref.invalidate(reviewViewModelProvider(args.token));
      if (ref.mounted) state = ReviewFormState(rating: state.rating);
    } catch (e) {
      if (ref.mounted) state = ReviewFormState(rating: state.rating, error: e);
    }
  }
}

final reviewFormViewModelProvider =
    NotifierProvider.autoDispose.family<ReviewFormViewModel, ReviewFormState, ReviewArgs>(ReviewFormViewModel.new);
