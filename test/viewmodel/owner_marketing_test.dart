import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kalenda_mobile/core/api/api_client.dart';
import 'package:kalenda_mobile/features/owner/data/marketing_repository.dart';
import 'package:kalenda_mobile/features/owner/model/marketing_models.dart';
import 'package:kalenda_mobile/features/owner/viewmodel/marketing_viewmodels.dart';

class _FakeMarketing extends MarketingRepository {
  _FakeMarketing() : super(ApiClient(readCustomerToken: () async => null, readStaffToken: () async => null, onUnauthorized: (_) {}));

  final calls = <String>[];

  @override
  Future<void> createPassType(
    int businessId, {
    required String kind,
    required String name,
    required int priceHuf,
    required int validityDays,
    int? sessionsCount,
    int? valueHuf,
    int? serviceId,
  }) async => calls.add('passType:$kind:$name:$priceHuf:$sessionsCount:$valueHuf');

  @override
  Future<void> saveLoyaltySettings(int businessId, LoyaltySettings s) async => calls.add('loyalty:${s.enabled}:${s.rewardPoints}');

  @override
  Future<void> saveCampaign(int businessId, {int? id, required String name, required String subject, required String body, required CampaignSegment segment}) async =>
      calls.add('campaign:$id:$name:${segment.type}:${segment.days}');

  @override
  Future<int> sendCampaign(int businessId, int id) async => 42;

  @override
  Future<String> sendTest(int businessId, int id) async => 'owner@example.com';
}

void main() {
  late _FakeMarketing repository;
  late ProviderContainer container;

  setUp(() {
    repository = _FakeMarketing();
    container = ProviderContainer(overrides: [marketingRepositoryProvider.overrideWithValue(repository)]);
    addTearDown(container.dispose);
  });

  test('a bérlet-típus, a hűség-beállítás és a kampány mentése a repository-ig jut', () async {
    final actions = container.read(marketingActionsProvider.notifier);

    await actions.createPassType(1, kind: 'pass', name: '10 alkalmas', priceHuf: 50000, validityDays: 365, sessionsCount: 10);
    await actions.saveLoyalty(1, const LoyaltySettings(enabled: true, pointsPer1000Huf: 1, rewardPoints: 100, rewardValueHuf: 2000));
    await actions.saveCampaign(1, name: 'Tavasz', subject: 'Gyere vissza', body: 'Szia!', segment: const CampaignSegment(type: 'inactive', days: 60));

    expect(repository.calls, ['passType:pass:10 alkalmas:50000:10:null', 'loyalty:true:100', 'campaign:null:Tavasz:inactive:60']);
  });

  test('a kiküldés megjegyzi a címzettek számát, a próbalevél a címet', () async {
    final actions = container.read(marketingActionsProvider.notifier);

    expect(await actions.send(1, 5), isTrue);
    expect(await actions.sendTest(1, 5), isTrue);

    expect(actions.lastRecipients, 42);
    expect(actions.lastTestSentTo, 'owner@example.com');
  });

  test('a célcsoport csak a releváns mezőket küldi', () {
    expect(const CampaignSegment().toJson(), {'type': 'all'});
    expect(const CampaignSegment(type: 'inactive', days: 90).toJson(), {'type': 'inactive', 'days': 90});
    expect(const CampaignSegment(type: 'service', serviceId: 4).toJson(), {'type': 'service', 'service_id': 4});
  });

  test('a modellek a válaszból épülnek, hiányzó mezőkkel is', () {
    final type = PassType.fromJson({
      'id': 1,
      'kind': 'voucher',
      'name': 'Utalvány',
      'price_huf': 15000,
      'value_huf': 15000,
      'validity_days': 365,
      'sold_count': 3,
      'service': {'id': 2, 'name': 'Masszázs'},
    });
    final campaign = Campaign.fromJson({'id': 2, 'status': 'sent', 'recipients_count': 12, 'segment': {'type': 'new', 'days': 30}});
    final listing = CampaignListing.fromJson({'campaigns': {'content': []}, 'consent_count': 7, 'daily_limit': 100});

    expect(type.isVoucher, isTrue);
    expect(type.serviceName, 'Masszázs');
    expect(campaign.isDraft, isFalse);
    expect(campaign.segment.days, 30);
    expect(listing.consentCount, 7);
    expect(LoyaltyOverview.fromJson(const {}).members, 0);
  });
}
