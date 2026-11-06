import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kalenda_mobile/core/api/api_client.dart';
import 'package:kalenda_mobile/core/files/image_picker_gateway.dart';
import 'package:kalenda_mobile/features/owner/data/owner_tools_repository.dart';
import 'package:kalenda_mobile/features/owner/data/settings_repository.dart';
import 'package:kalenda_mobile/features/owner/model/extras_models.dart';
import 'package:kalenda_mobile/features/owner/model/finance_models.dart';
import 'package:kalenda_mobile/features/owner/viewmodel/owner_tools_viewmodels.dart';
import 'package:kalenda_mobile/features/owner/viewmodel/settings_viewmodels.dart';

ApiClient _api() => ApiClient(readCustomerToken: () async => null, readStaffToken: () async => null, onUnauthorized: (_) {});

class _FakeSettings extends SettingsRepository {
  _FakeSettings() : super(_api());

  final calls = <String>[];

  @override
  Future<void> saveAddon(int businessId, {int? id, required Addon addon}) async => calls.add('addon:$id:${addon.name}:${addon.serviceIds}');

  @override
  Future<void> saveStaffHours(int businessId, int staffId, List<StaffHour> hours) async => calls.add('hours:$staffId:${hours.length}');

  @override
  Future<void> saveServiceMaterials(int businessId, int serviceId, Map<int, double> materials) async => calls.add('materials:$serviceId:$materials');

  @override
  Future<void> uploadImage(int businessId, String kind, String filePath) async => calls.add('upload:$kind');
}

class _FakeTools extends OwnerToolsRepository {
  _FakeTools() : super(_api());

  final calls = <String>[];

  @override
  Future<void> retryMissingDocument(int businessId, String key) async => calls.add('retry:$key');
}

class _Picker extends ImagePickerGateway {
  const _Picker();

  @override
  Future<String?> pickFromGallery() async => '/tmp/x.jpg';
}

void main() {
  test('a kiegészítő, a munkaidő, az anyagok és a fotó a megfelelő végpontra kerülnek', () async {
    final settings = _FakeSettings();
    final container = ProviderContainer(overrides: [settingsRepositoryProvider.overrideWithValue(settings), imagePickerProvider.overrideWithValue(const _Picker())]);
    addTearDown(container.dispose);
    final actions = container.read(extrasActionsProvider.notifier);

    await actions.saveAddon(1, const Addon(id: 0, name: 'Mosás', priceHuf: 1000, durationMinutes: 10, isActive: true, serviceIds: [2, 3]));
    await actions.saveStaffHours((businessId: 1, staffId: 4), StaffHour.weekFrom(const []));
    await actions.saveMaterials(1, 2, {7: 0.5});
    await actions.uploadImage(1, 'staff/4/photo');

    expect(settings.calls, ['addon:null:Mosás:[2, 3]', 'hours:4:7', 'materials:2:{7: 0.5}', 'upload:staff/4/photo']);
  });

  test('a kimaradt bizonylat újrapróbálása a kulccsal megy', () async {
    final tools = _FakeTools();
    final container = ProviderContainer(overrides: [ownerToolsRepositoryProvider.overrideWithValue(tools)]);
    addTearDown(container.dispose);

    await container.read(missingDocumentsActionsProvider.notifier).retry(1, 'appointment:9');

    expect(tools.calls, ['retry:appointment:9']);
  });

  test('a heti munkaidő hét napból áll: hétvége szabadnap, a megadott nap megmarad', () {
    final week = StaffHour.weekFrom(const [StaffHour(dayOfWeek: 6, startAt: '08:00', endAt: '12:00', isDayOff: false)]);

    expect(week.length, 7);
    expect(week.first.dayOfWeek, 1);
    expect(week.last.dayOfWeek, 0);
    expect(week.firstWhere((h) => h.dayOfWeek == 0).isDayOff, isTrue);
    expect(week.firstWhere((h) => h.dayOfWeek == 6).startAt, '08:00');
    expect(week.firstWhere((h) => h.dayOfWeek == 2).isDayOff, isFalse);
    expect(const StaffHour(dayOfWeek: 1, startAt: '09:00', endAt: '17:00', isDayOff: true).toJson(), {'day_of_week': 1, 'is_day_off': true});
  });

  test('a kifizetések, a hiányzó bizonylat és a portál-munkaidő a válaszból épül', () {
    final payouts = PayoutsOverview.fromJson({
      'connected': true,
      'selected': 'po_1',
      'payouts': [
        {'id': 'po_1', 'amount_huf': 50000, 'status': 'paid'},
      ],
      'detail': {
        'lines': [
          {'type': 'charge', 'amount_huf': 10000, 'fee_huf': 300, 'net_huf': 9700},
        ],
        'totals': {'gross_huf': 10000, 'fee_huf': 300, 'net_huf': 9700},
      },
    });
    final missing = MissingDocument.fromJson({'key': 'appointment:9', 'amount_huf': 6000, 'customer': 'Éva'});
    final timesheet = PortalTimesheet.fromJson({
      'month': '2026-11',
      'planned_minutes': 480,
      'clocked_minutes': 450,
      'entries': [
        {'id': 1, 'worked_minutes': 450, 'break_minutes': 30},
      ],
      'time_clock': {'is_stale': true},
    });

    expect(payouts.payouts.single.amountHuf, 50000);
    expect(payouts.netHuf, 9700);
    expect(payouts.lines.single.feeHuf, 300);
    expect(missing.key, 'appointment:9');
    expect(timesheet.clockedMinutes, 450);
    expect(timesheet.isStale, isTrue);
    expect(timesheet.entries.single.workedMinutes, 450);
  });
}
