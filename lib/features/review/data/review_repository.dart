import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/providers.dart';
import '../model/review_models.dart';

/// Az értékelő oldal (`/public/reviews/{token}`): a token a foglalás utáni levélből jön.
class ReviewRepository {
  ReviewRepository(this._api);

  final ApiClient _api;

  Future<ReviewInfo> info(String token) async {
    final response = await _api.call((d) => d.get('/public/reviews/$token'));
    return ReviewInfo.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ReviewInfo> submit(String token, {required int rating, String? feedback}) async {
    final response = await _api.call((d) => d.post('/public/reviews/$token', data: {
          'rating': rating,
          if (feedback != null && feedback.isNotEmpty) 'feedback': feedback,
        }));
    return ReviewInfo.fromJson(response.data as Map<String, dynamic>);
  }
}

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) => ReviewRepository(ref.watch(apiClientProvider)));
