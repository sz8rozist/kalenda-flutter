import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kalenda_mobile/core/api/api_client.dart';
import 'package:kalenda_mobile/core/viewmodel/action_state.dart';
import 'package:kalenda_mobile/features/owner/data/owner_repository.dart';
import 'package:kalenda_mobile/features/owner/model/customer_detail.dart';
import 'package:kalenda_mobile/features/owner/model/owner_models.dart';
import 'package:kalenda_mobile/features/owner/viewmodel/owner_manage_viewmodels.dart';

/// Hívásokat rögzítő repository: a ViewModel-ek a rögzített hívásokból ellenőrizhetők, hálózat nélkül.
class _RecordingOwnerRepository extends OwnerRepository {
  _RecordingOwnerRepository() : super(ApiClient(readCustomerToken: () async => null, readStaffToken: () async => null, onUnauthorized: (_) {}));

  final calls = <String>[];
  bool failNext = false;

  void _record(String call) {
    if (failNext) {
      failNext = false;
      throw StateError('boom');
    }
    calls.add(call);
  }

  @override
  Future<void> createService(int businessId, OwnerService service) async => _record('createService:${service.name}');

  @override
  Future<void> saveService(int businessId, OwnerService service) async => _record('saveService:${service.id}');

  @override
  Future<void> deleteService(int businessId, int serviceId) async => _record('deleteService:$serviceId');

  @override
  Future<OwnerStaff> createStaff(int businessId, OwnerStaff staff) async {
    _record('createStaff:${staff.name}');
    return OwnerStaff(id: 42, name: staff.name, isActive: true, hasAccount: false, upcomingCount: 0);
  }

  @override
  Future<void> saveStaff(int businessId, OwnerStaff staff) async => _record('saveStaff:${staff.id}');

  @override
  Future<void> setStaffServices(int businessId, int staffId, List<int> serviceIds) async => _record('services:$staffId:$serviceIds');

  @override
  Future<int> redeemLoyalty(int businessId, int customerId) async {
    _record('redeem:$customerId');
    return 1500;
  }
}

void main() {
  late _RecordingOwnerRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = _RecordingOwnerRepository();
    container = ProviderContainer(overrides: [ownerRepositoryProvider.overrideWithValue(repository)]);
    addTearDown(container.dispose);
  });

  OwnerService service({int id = 0}) => OwnerService(id: id, name: 'Hajvágás', durationMinutes: 30, isActive: true);

  test('az új szolgáltatás létrehozásnak (id = 0), a meglévő mentésnek megy', () async {
    final viewModel = container.read(serviceEditProvider.notifier);

    expect(await viewModel.save(1, service()), isTrue);
    expect(await viewModel.save(1, service(id: 7)), isTrue);

    expect(repository.calls, ['createService:Hajvágás', 'saveService:7']);
    expect(container.read(serviceEditProvider).flash?.kind, FlashKind.saved);
  });

  test('a mentés hibája hibaüzenetként jelenik meg, a művelet sikertelen', () async {
    repository.failNext = true;

    final ok = await container.read(serviceEditProvider.notifier).save(1, service());

    expect(ok, isFalse);
    expect(container.read(serviceEditProvider).flash?.kind, FlashKind.error);
  });

  test('új munkatársnál a létrehozás után a kapott azonosítóhoz rendeli a szolgáltatásokat', () async {
    final staff = OwnerStaff(id: 0, name: 'Kata', isActive: true, hasAccount: false, upcomingCount: 0);

    await container.read(staffEditProvider.notifier).save(1, staff, [3, 4]);

    expect(repository.calls, ['createStaff:Kata', 'services:42:[3, 4]']);
  });

  test('meglévő munkatársnál mentés, majd a szolgáltatások beállítása történik', () async {
    final staff = OwnerStaff(id: 9, name: 'Béla', isActive: true, hasAccount: true, upcomingCount: 0);

    await container.read(staffEditProvider.notifier).save(1, staff, const []);

    expect(repository.calls, ['saveStaff:9', 'services:9:[]']);
  });

  test('a jutalom beváltása megjegyzi a kapott kedvezményt', () async {
    final viewModel = container.read(customerActionsProvider.notifier);

    expect(await viewModel.redeem((businessId: 1, customerId: 5)), isTrue);

    expect(viewModel.lastRedeemedDiscountHuf, 1500);
  });

  test('a szolgáltatás mentési törzse az előleg típusa szerint viszi a százalékot', () {
    final percentage = OwnerService(id: 1, name: 'A', durationMinutes: 30, isActive: true, depositType: 'percentage', depositPercentage: 20);
    final none = OwnerService(id: 1, name: 'A', durationMinutes: 30, isActive: true, depositType: 'none', depositPercentage: 20);

    expect(percentage.toSaveJson()['deposit_percentage'], 20);
    expect(none.toSaveJson()['deposit_percentage'], isNull);
  });

  test('az ügyfél-részletek a válaszból épülnek, hiányzó részekkel is', () {
    final full = CustomerDetail.fromJson({
      'customer': {'id': 5, 'name': 'Éva', 'email': 'eva@example.com'},
      'stats': {'total': 4, 'completed': 3, 'no_show': 1, 'cancelled': 0, 'total_spent_huf': 24000},
      'profile': {'deposit_exempt': true, 'internal_note': 'Törzsvendég'},
      'no_show_protection': {'flagged': true},
      'loyalty': {
        'balance': 120,
        'reward_points': 100,
        'reward_value_huf': 2000,
        'transactions': [
          {'points': 20, 'reason': 'booking', 'created_at': '2026-11-01T10:00:00Z'},
        ],
      },
    });

    expect(full.name, 'Éva');
    expect(full.totalSpentHuf, 24000);
    expect(full.depositExempt, isTrue);
    expect(full.noShowFlagged, isTrue);
    expect(full.canRedeem, isTrue);
    expect(full.loyaltyTransactions.single.points, 20);

    final empty = CustomerDetail.fromJson(const {});
    expect(empty.canRedeem, isFalse);
    expect(empty.loyaltyTransactions, isEmpty);
  });
}
