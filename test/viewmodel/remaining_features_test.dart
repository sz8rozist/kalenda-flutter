import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kalenda_mobile/core/api/api_client.dart';
import 'package:kalenda_mobile/core/files/document_opener.dart';
import 'package:kalenda_mobile/core/files/image_picker_gateway.dart';
import 'package:kalenda_mobile/features/account/model/account_models.dart';
import 'package:kalenda_mobile/features/booking/model/booking_models.dart';
import 'package:kalenda_mobile/features/booking/model/booking_request.dart';
import 'package:kalenda_mobile/features/owner/data/owner_tools_repository.dart';
import 'package:kalenda_mobile/features/owner/model/misc_models.dart';
import 'package:kalenda_mobile/features/owner/viewmodel/owner_tools_viewmodels.dart';

ApiClient _api() => ApiClient(readCustomerToken: () async => null, readStaffToken: () async => null, onUnauthorized: (_) {});

class _FakeTools extends OwnerToolsRepository {
  _FakeTools() : super(_api());

  final calls = <String>[];

  @override
  Future<DownloadedFile> accountingDownload(int businessId, DateTime month) async => const DownloadedFile(bytes: [1, 2], name: 'konyveles.zip');

  @override
  Future<DownloadedFile> expensesExport(int businessId) async => const DownloadedFile(bytes: [3], name: 'koltsegek.csv');

  @override
  Future<int> createLeave(int businessId, {int? staffId, required DateTime from, required DateTime to, String? reason, bool cancelAffected = false}) async {
    calls.add('leave:$staffId:$cancelAffected');
    return 3;
  }

  @override
  Future<void> uploadExpenseReceipt(int businessId, int expenseId, String filePath) async => calls.add('receipt:$expenseId:$filePath');
}

class _Opener extends DocumentOpener {
  _Opener(this.result);

  final bool result;
  final opened = <String>[];

  @override
  Future<bool> open(Uint8List bytes, String fileName) async {
    opened.add('$fileName:${bytes.length}');
    return result;
  }
}

class _Picker extends ImagePickerGateway {
  const _Picker();

  @override
  Future<String?> pickFromGallery() async => '/tmp/receipt.jpg';
}

void main() {
  test('az export letöltődik és a fájlnévvel megnyílik; megjegyzi, ha nincs megjelenítő', () async {
    final opener = _Opener(false);
    final container = ProviderContainer(
      overrides: [ownerToolsRepositoryProvider.overrideWithValue(_FakeTools()), documentOpenerProvider.overrideWithValue(opener)],
    );
    addTearDown(container.dispose);
    final actions = container.read(ownerMiscActionsProvider.notifier);

    expect(await actions.exportAccounting(1, DateTime(2026, 10)), isTrue);
    expect(await actions.exportExpenses(1), isTrue);

    expect(opener.opened, ['konyveles.zip:2', 'koltsegek.csv:1']);
    expect(actions.fileNotOpened, isTrue);
  });

  test('a szabadság felvétele megjegyzi az érintett foglalásokat; a bizonylat a kiválasztott képpel megy fel', () async {
    final tools = _FakeTools();
    final container = ProviderContainer(overrides: [ownerToolsRepositoryProvider.overrideWithValue(tools), imagePickerProvider.overrideWithValue(const _Picker())]);
    addTearDown(container.dispose);
    final actions = container.read(ownerMiscActionsProvider.notifier);

    await actions.createLeave(1, from: DateTime(2026, 12, 24), to: DateTime(2026, 12, 26), cancelAffected: true);
    await actions.uploadReceipt(1, 8);

    expect(actions.lastAffected, 3);
    expect(tools.calls, ['leave:null:true', 'receipt:8:/tmp/receipt.jpg']);
  });

  test('a letöltési fájlnév a Content-Disposition fejlécből jön, hiányában az alapértelmezett', () {
    expect(DownloadedFile.nameFrom('attachment; filename="munkaido-2026-11.csv"', 'x.csv'), 'munkaido-2026-11.csv');
    expect(DownloadedFile.nameFrom("attachment; filename*=UTF-8''k%C3%B6lts%C3%A9g.csv", 'x.csv'), 'költség.csv');
    expect(DownloadedFile.nameFrom(null, 'alap.csv'), 'alap.csv');
  });

  test('a bérlés időtartamai a határok és a lépésköz szerint állnak elő, az ár óradíj arányos', () {
    final rental = PublicRental(id: 1, name: 'Pálya', minMinutes: 60, maxMinutes: 180, stepMinutes: 30, pricePerHourHuf: 6000, resources: const []);

    expect(rental.durations, [60, 90, 120, 150, 180]);
    expect(rental.priceFor(90), 9000);
    expect(PublicRental(id: 2, name: 'x', minMinutes: 30, maxMinutes: 30, stepMinutes: 30, resources: const []).priceFor(30), isNull);
  });

  test('az időpont-lekérdezés egyenlősége figyelembe veszi a bérlés hosszát', () {
    SlotQuery query(int? minutes) => SlotQuery(slug: 's', serviceId: 1, staffId: 2, date: DateTime(2026, 11, 6, 15), addonIds: const [], durationMinutes: minutes);

    expect(query(60), query(60));
    expect(query(60) == query(90), isFalse);
    expect(query(null) == query(60), isFalse);
  });

  test('az ügyfél számlái és a bérelhető erőforrások a válaszból épülnek', () {
    final overview = AccountOverview.fromJson({
      'profile': {'name': 'Éva', 'email': 'eva@example.com'},
      'upcoming': [],
      'past': [],
      'invoices': [
        {'business': 'Szalon', 'number': 'SZ-1', 'amount_huf': 9000, 'payment_state': 'paid', 'download_url': '/api/v1/customer/documents/appointment/4'},
      ],
    });
    final rental = PublicRental.fromJson({
      'id': 5,
      'name': 'Tenisz',
      'min_minutes': 60,
      'max_minutes': 120,
      'step_minutes': 60,
      'price_per_hour_huf': 5000,
      'resources': [
        {'id': 9, 'name': '1-es pálya'},
      ],
    });

    expect(overview.invoices.single.number, 'SZ-1');
    expect(overview.invoices.single.downloadUrl, endsWith('/appointment/4'));
    expect(rental.resources.single.name, '1-es pálya');
    expect(OwnerLeave.fromJson(<String, dynamic>{'id': 1, 'date_from': '2026-12-24', 'date_to': '2026-12-26'}).affectedCount, 0);
    expect(NotificationListing.fromJson(<String, dynamic>{'notifications': [<String, dynamic>{'id': 1, 'message': 'Új foglalás', 'read_at': null}], 'unread_count': 1}).notifications.single.isRead, isFalse);
  });
}
