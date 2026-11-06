import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kalenda_mobile/core/api/api_client.dart';
import 'package:kalenda_mobile/core/viewmodel/action_state.dart';
import 'package:kalenda_mobile/features/owner/data/owner_tools_repository.dart';
import 'package:kalenda_mobile/features/owner/model/owner_tools_models.dart';
import 'package:kalenda_mobile/features/owner/viewmodel/owner_tools_viewmodels.dart';

class _RecordingToolsRepository extends OwnerToolsRepository {
  _RecordingToolsRepository() : super(ApiClient(readCustomerToken: () async => null, readStaffToken: () async => null, onUnauthorized: (_) {}));

  final calls = <String>[];

  @override
  Future<void> createExpense(
    int businessId, {
    required String category,
    required int amountHuf,
    required DateTime date,
    String? vendor,
    bool recurring = false,
  }) async => calls.add('expense:$category:$amountHuf:${recurring ? 'r' : '-'}');

  @override
  Future<void> notifyWaitlist(int businessId, int entryId) async => calls.add('notify:$entryId');

  @override
  Future<void> removeWaitlist(int businessId, int entryId) async => calls.add('remove:$entryId');

  @override
  Future<void> saveReviewSettings(int businessId, {required bool enabled, String? googleUrl}) async => calls.add('reviews:$enabled:$googleUrl');
}

void main() {
  test('a költségek listája a lapozott válaszból épül, az összeg kiszámolva', () {
    final listing = ExpenseListing.fromJson({
      'expenses': {
        'content': [
          {'id': 1, 'category': 'Bérleti díj', 'amount_huf': 120000, 'expense_date': '2026-11-01', 'is_recurring': true},
          {'id': 2, 'category': 'Anyag', 'amount_huf': 8500, 'expense_date': '2026-11-03', 'vendor': 'Bolt Kft.'},
        ],
      },
      'categories': ['Anyag', 'Bérleti díj'],
    });

    expect(listing.expenses.length, 2);
    expect(listing.totalHuf, 128500);
    expect(listing.expenses.first.isRecurring, isTrue);
    expect(listing.expenses.last.vendor, 'Bolt Kft.');
    expect(listing.categories, ['Anyag', 'Bérleti díj']);
  });

  test('az értékelés-lista a beállításokat és az összesítést is tartalmazza', () {
    final listing = ReviewListing.fromJson({
      'reviews': {
        'content': [
          {'id': 1, 'rating': 5, 'feedback': 'Szuper', 'customer_name': 'Éva'},
        ],
      },
      'settings': {'reviews_enabled': true, 'google_review_url': 'https://g.page/r/x'},
      'stats': {'count': 12, 'average': 4.6, 'requested': 30},
    });

    expect(listing.enabled, isTrue);
    expect(listing.count, 12);
    expect(listing.average, 4.6);
    expect(listing.reviews.single.rating, 5);
  });

  test('a hiányzó mezők nem törik el az elemzést', () {
    expect(SoldPass.fromJson(const {'id': 1}).kind, 'pass');
    expect(WaitlistEntry.fromJson(const {'id': 1}).status, 'waiting');
    expect(ActivityEntry.fromJson(const {'id': 1}).actorName, '');
    expect(pagedContent(null), isEmpty);
  });

  test('a várólista-műveletek és a költség-felvitel a repository-hoz jutnak', () async {
    final repository = _RecordingToolsRepository();
    final container = ProviderContainer(overrides: [ownerToolsRepositoryProvider.overrideWithValue(repository)]);
    addTearDown(container.dispose);
    final actions = container.read(ownerToolsActionsProvider.notifier);

    await actions.addExpense(1, category: 'Anyag', amountHuf: 5000, date: DateTime(2026, 11, 6), recurring: true);
    await actions.notifyWaitlist(1, 7);
    await actions.removeWaitlist(1, 8);
    await actions.saveReviewSettings(1, enabled: true, googleUrl: 'https://x');

    expect(repository.calls, ['expense:Anyag:5000:r', 'notify:7', 'remove:8', 'reviews:true:https://x']);
    expect(container.read(ownerToolsActionsProvider).flash?.kind, FlashKind.saved);
  });
}
