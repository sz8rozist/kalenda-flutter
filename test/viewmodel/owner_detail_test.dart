import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kalenda_mobile/core/api/api_client.dart';
import 'package:kalenda_mobile/core/files/document_opener.dart';
import 'package:kalenda_mobile/features/owner/data/owner_tools_repository.dart';
import 'package:kalenda_mobile/features/owner/model/appointment_detail.dart';
import 'package:kalenda_mobile/features/owner/model/business_info.dart';
import 'package:kalenda_mobile/features/owner/viewmodel/owner_tools_viewmodels.dart';

class _FakeRepository extends OwnerToolsRepository {
  _FakeRepository() : super(ApiClient(readCustomerToken: () async => null, readStaffToken: () async => null, onUnauthorized: (_) {}));

  final calls = <String>[];

  @override
  Future<void> changeAppointmentStatus(int businessId, int appointmentId, String status, {bool refund = false}) async =>
      calls.add('status:$appointmentId:$status:$refund');

  @override
  Future<void> issueAppointmentInvoice(int businessId, int appointmentId, {required String paymentMethod}) async =>
      calls.add('invoice:$appointmentId:$paymentMethod');

  @override
  Future<void> cancelDocument(int businessId, String type, int documentId, {String? reason}) async => calls.add('cancel:$type:$documentId:$reason');

  @override
  Future<Uint8List> documentPdf(int businessId, String type, int documentId) async => Uint8List.fromList([1, 2, 3]);

  @override
  Future<void> createStandaloneInvoice(
    int businessId, {
    required List<({String name, double qty, int unitPriceHuf})> items,
    String? customerName,
    String? customerEmail,
    int dueDays = 8,
    bool alreadyPaid = false,
    String? paymentMethod,
  }) async => calls.add('standalone:${items.length}:$dueDays:$alreadyPaid:$paymentMethod');
}

class _FakeOpener extends DocumentOpener {
  _FakeOpener(this.result);

  final bool result;
  String? opened;

  @override
  Future<bool> open(Uint8List bytes, String fileName) async {
    opened = '$fileName:${bytes.length}';
    return result;
  }
}

void main() {
  const key = (businessId: 1, appointmentId: 9);

  late _FakeRepository repository;
  late _FakeOpener opener;
  late ProviderContainer container;

  setUp(() {
    repository = _FakeRepository();
    opener = _FakeOpener(true);
    container = ProviderContainer(
      overrides: [ownerToolsRepositoryProvider.overrideWithValue(repository), documentOpenerProvider.overrideWithValue(opener)],
    );
    addTearDown(container.dispose);
  });

  test('a lemondás a visszatérítés jelzésével megy a szerverre', () async {
    final viewModel = container.read(appointmentActionsProvider.notifier);

    await viewModel.setStatus(key, 'cancelled', refund: true);
    await viewModel.setStatus(key, 'completed');

    expect(repository.calls, ['status:9:cancelled:true', 'status:9:completed:false']);
  });

  test('a számla kiállítása a kiválasztott fizetési móddal megy', () async {
    await container.read(appointmentActionsProvider.notifier).issueInvoice(key, 'transfer');

    expect(repository.calls, ['invoice:9:transfer']);
  });

  test('a PDF letöltődik és megnyílik; ha nincs megjelenítő, jelzi', () async {
    final viewModel = container.read(documentActionsProvider.notifier);

    expect(await viewModel.openPdf(1, 'standalone', 4, 'SZ-2026-1'), isTrue);
    expect(opener.opened, 'SZ-2026-1.pdf:3');
    expect(viewModel.pdfNotOpened, isFalse);

    final noViewer = ProviderContainer(
      overrides: [ownerToolsRepositoryProvider.overrideWithValue(repository), documentOpenerProvider.overrideWithValue(_FakeOpener(false))],
    );
    addTearDown(noViewer.dispose);
    final other = noViewer.read(documentActionsProvider.notifier);
    await other.openPdf(1, 'standalone', 4, 'x');
    expect(other.pdfNotOpened, isTrue);
  });

  test('az önálló számla és a sztornó a típussal együtt jut el a szerverig', () async {
    final viewModel = container.read(documentActionsProvider.notifier);

    await viewModel.createStandaloneInvoice(1, items: [(name: 'Konzultáció', qty: 1, unitPriceHuf: 10000)], dueDays: 14);
    await viewModel.cancel(1, 'standalone', 4, 'Elírás');

    expect(repository.calls, ['standalone:1:14:false:null', 'cancel:standalone:4:Elírás']);
  });

  test('a foglalás-részletek összeállnak, az előlegszámla után végszámla jön', () {
    final detail = AppointmentDetail.fromJson({
      'appointment': {
        'id': 9,
        'starts_at': '2026-11-10T09:00:00Z',
        'ends_at': '2026-11-10T09:30:00Z',
        'status': 'confirmed',
        'service': {'id': 1, 'name': 'Hajvágás'},
        'staff': {'id': 2, 'name': 'Kata'},
        'customer': {'id': 5, 'name': 'Éva', 'email': 'eva@example.com'},
        'addons': [
          {'name': 'Mosás', 'price_huf': 1000},
        ],
        'invoices': [
          {'id': 1, 'kind': 'invoice', 'role': 'deposit', 'amount_huf': 3000, 'number': 'E-1'},
        ],
      },
      'payment': {
        'total_huf': 9000,
        'paid_huf': 3000,
        'due_huf': 6000,
        'payments': [
          {'method': 'online', 'amount_huf': 3000},
        ],
      },
      'invoicing': {'ready': true, 'remaining_huf': 6000, 'document_type': 'invoice'},
    });

    expect(detail.serviceName, 'Hajvágás');
    expect(detail.dueHuf, 6000);
    expect(detail.isLive, isTrue);
    expect(detail.hasDepositInvoice, isTrue);
    expect(detail.invoicingReady, isTrue);
    expect(detail.addons.single.priceHuf, 1000);
  });

  test('a csomag funkciói: ismeretlen kulcs engedélyezett, a hamis kulcs lezárt', () {
    final info = BusinessInfo.fromJson({
      'id': 1,
      'name': 'Szalon',
      'plan': 'basic',
      'plan_features': {'passes': false, 'reviews': true},
      'subscription': {'status': 'active', 'locked': false},
    });

    expect(info.hasFeature('passes'), isFalse);
    expect(info.hasFeature('reviews'), isTrue);
    expect(info.hasFeature('valami_uj'), isTrue);
    expect(info.hasFeature(null), isTrue);
  });
}
