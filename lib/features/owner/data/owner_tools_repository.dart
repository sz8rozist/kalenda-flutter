import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/date_param.dart';
import '../../../core/providers.dart';
import '../model/owner_tools_models.dart';

/// A vállalkozói „egyéb" végpontok: költségek, értékelések, bérletek, várólista, tevékenység-napló.
class OwnerToolsRepository {
  OwnerToolsRepository(this._api);

  final ApiClient _api;

  // ─── Költségek ────────────────────────────────────────────────

  Future<ExpenseListing> expenses(int businessId) async {
    final response = await _api.call(
      (d) => d.get('/businesses/$businessId/expenses', queryParameters: {'size': 100, 'sort': 'expenseDate,desc'}),
    );
    return ExpenseListing.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> createExpense(
    int businessId, {
    required String category,
    required int amountHuf,
    required DateTime date,
    String? vendor,
    bool recurring = false,
  }) => _api.call(
    (d) => d.post(
      '/businesses/$businessId/expenses',
      data: {
        'category': category,
        'amount_huf': amountHuf,
        'expense_date': dateParam(date),
        'vendor': vendor == null || vendor.trim().isEmpty ? null : vendor.trim(),
        'is_recurring': recurring,
      },
    ),
  );

  Future<void> deleteExpense(int businessId, int expenseId) => _api.call((d) => d.delete('/businesses/$businessId/expenses/$expenseId'));

  // ─── Értékelések ──────────────────────────────────────────────

  Future<ReviewListing> reviews(int businessId) async {
    final response = await _api.call((d) => d.get('/businesses/$businessId/reviews', queryParameters: {'size': 50}));
    return ReviewListing.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> saveReviewSettings(int businessId, {required bool enabled, String? googleUrl}) => _api.call(
    (d) => d.put(
      '/businesses/$businessId/reviews/settings',
      data: {'reviews_enabled': enabled, 'google_review_url': googleUrl == null || googleUrl.trim().isEmpty ? null : googleUrl.trim()},
    ),
  );

  // ─── Bérletek és utalványok ───────────────────────────────────

  Future<List<SoldPass>> soldPasses(int businessId) async {
    final response = await _api.call((d) => d.get('/businesses/$businessId/passes', queryParameters: {'size': 50}));
    return [for (final e in pagedContent((response.data as Map<String, dynamic>)['passes'])) SoldPass.fromJson(e)];
  }

  // ─── Várólista ────────────────────────────────────────────────

  Future<List<WaitlistEntry>> waitlist(int businessId) async {
    final response = await _api.call((d) => d.get('/businesses/$businessId/waitlist', queryParameters: {'size': 50}));
    return [for (final e in pagedContent((response.data as Map<String, dynamic>)['entries'])) WaitlistEntry.fromJson(e)];
  }

  Future<void> notifyWaitlist(int businessId, int entryId) => _api.call((d) => d.post('/businesses/$businessId/waitlist/$entryId/notify'));

  Future<void> removeWaitlist(int businessId, int entryId) => _api.call((d) => d.delete('/businesses/$businessId/waitlist/$entryId'));

  // ─── Tevékenység-napló ────────────────────────────────────────

  Future<List<ActivityEntry>> activityLog(int businessId, {String? search}) async {
    final response = await _api.call(
      (d) => d.get(
        '/businesses/$businessId/activity-log',
        queryParameters: {'size': 50, if (search != null && search.trim().isNotEmpty) 'search': search.trim()},
      ),
    );
    return [for (final e in pagedContent((response.data as Map<String, dynamic>)['entries'])) ActivityEntry.fromJson(e)];
  }
}

final ownerToolsRepositoryProvider = Provider<OwnerToolsRepository>((ref) => OwnerToolsRepository(ref.watch(apiClientProvider)));
