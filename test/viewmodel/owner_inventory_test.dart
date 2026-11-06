import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kalenda_mobile/core/api/api_client.dart';
import 'package:kalenda_mobile/features/owner/data/inventory_repository.dart';
import 'package:kalenda_mobile/features/owner/data/owner_tools_repository.dart';
import 'package:kalenda_mobile/features/owner/model/inventory_models.dart';
import 'package:kalenda_mobile/features/owner/model/register_models.dart';
import 'package:kalenda_mobile/features/owner/viewmodel/inventory_viewmodels.dart';
import 'package:kalenda_mobile/features/owner/viewmodel/owner_tools_viewmodels.dart';

ApiClient _api() => ApiClient(readCustomerToken: () async => null, readStaffToken: () async => null, onUnauthorized: (_) {});

class _FakeInventory extends InventoryRepository {
  _FakeInventory() : super(_api());

  final calls = <String>[];

  @override
  Future<void> saveProduct(int businessId, Product product) async => calls.add('saveProduct:${product.id}:${product.name}');

  @override
  Future<void> sellProduct(int businessId, {required int productId, required int quantity, String? customerName, String? paymentMethod}) async =>
      calls.add('sell:$productId:$quantity:$paymentMethod');

  @override
  Future<void> createOrder(
    int businessId, {
    required int supplierId,
    required List<({int? productId, String description, int quantity, int unitCostHuf})> lines,
    DateTime? expectedDate,
    String? note,
  }) async => calls.add('order:$supplierId:${lines.length}');

  @override
  Future<void> receiveOrder(int businessId, int orderId, Map<int, int> received) async => calls.add('receive:$orderId:$received');

  @override
  Future<List<Product>> products(int businessId, {String? search, bool lowStockOnly = false}) async {
    calls.add('products:$search:$lowStockOnly');
    return const [];
  }
}

class _FakeTools extends OwnerToolsRepository {
  _FakeTools() : super(_api());

  final calls = <String>[];

  @override
  Future<void> recordRegisterPayment(
    int businessId, {
    required String kind,
    required String method,
    required int amountHuf,
    required DateTime date,
    String? description,
  }) async => calls.add('record:$kind:$method:$amountHuf');

  @override
  Future<void> closeRegister(int businessId, DateTime date, {required int countedCashHuf, String? note}) async => calls.add('close:$countedCashHuf');
}

void main() {
  late _FakeInventory inventory;
  late _FakeTools tools;
  late ProviderContainer container;

  setUp(() {
    inventory = _FakeInventory();
    tools = _FakeTools();
    container = ProviderContainer(
      overrides: [inventoryRepositoryProvider.overrideWithValue(inventory), ownerToolsRepositoryProvider.overrideWithValue(tools)],
    );
    addTearDown(container.dispose);
  });

  test('a termék mentése és az eladás a repository-ig jut', () async {
    final actions = container.read(inventoryActionsProvider.notifier);

    await actions.saveProduct(
      1,
      const Product(id: 0, name: 'Sampon', priceHuf: 3000, stockQuantity: 5, isActive: true, isLowStock: false),
    );
    await actions.sell(1, productId: 7, quantity: 2, paymentMethod: 'card');

    expect(inventory.calls, ['saveProduct:0:Sampon', 'sell:7:2:card']);
  });

  test('a rendelés létrehozása és a bevételezés tételenként megy', () async {
    final actions = container.read(inventoryActionsProvider.notifier);

    await actions.createOrder(1, supplierId: 3, lines: [(productId: null, description: 'Festék', quantity: 4, unitCostHuf: 2500)]);
    await actions.receiveOrder(1, 11, {21: 4, 22: 0});

    expect(inventory.calls, ['order:3:1', 'receive:11:{21: 4, 22: 0}']);
  });

  test('a termék-lista a szűrőkkel kéri a szervert', () async {
    container.read(productFilterProvider.notifier)
      ..search('sam')
      ..toggleLowStock();

    await container.read(productsProvider(1).future);

    expect(inventory.calls, ['products:sam:true']);
  });

  test('a pénztár tétele és a nap zárása a megadott adatokkal megy', () async {
    final actions = container.read(registerActionsProvider.notifier);

    await actions.record(1, kind: 'income', method: 'cash', amountHuf: 4500, date: DateTime(2026, 11, 6));
    await actions.close(1, DateTime(2026, 11, 6), countedCashHuf: 12000);

    expect(tools.calls, ['record:income:cash:4500', 'close:12000']);
  });

  test('a pénztár-nap összesítője a válaszból épül, a zárt nap felismerhető', () {
    final day = RegisterDay.fromJson({
      'date': '2026-11-06',
      'is_today': true,
      'invoicing_ready': true,
      'summary': {
        'income_total': 20000,
        'online_total': 5000,
        'cash_in': 3000,
        'cash_out': 1000,
        'opening_cash': 10000,
        'expected_cash': 17000,
        'by_method': {'cash': 12000, 'card': 8000},
        'payments': [
          {'id': 1, 'kind': 'cash_out', 'method': 'cash', 'amount_huf': 1000, 'description': 'Bank'},
        ],
        'unpaid_appointments': [
          {'id': 5, 'time': '10:00', 'customer': 'Éva', 'due_huf': 6000},
        ],
        'closure': {'counted_cash_huf': 17000, 'expected_cash_huf': 17000, 'difference_huf': 0},
      },
    });

    expect(day.incomeTotal, 20000);
    expect(day.byMethod['card'], 8000);
    expect(day.payments.single.isOut, isTrue);
    expect(day.unpaid.single.dueHuf, 6000);
    expect(day.isClosed, isTrue);
    expect(RegisterDay.fromJson(const {}).isClosed, isFalse);
  });

  test('a beszerzési rendelés nyitott állapotai és a tételek', () {
    final order = PurchaseOrder.fromJson({
      'id': 1,
      'status': 'ordered',
      'total_huf': 10000,
      'supplier': {'name': 'Beszállító Kft.'},
      'items': [
        {'id': 3, 'description': 'Festék', 'quantity': 4, 'unit_cost_huf': 2500},
      ],
    });

    expect(order.isOpen, isTrue);
    expect(order.supplierName, 'Beszállító Kft.');
    expect(order.items.single.quantity, 4);
    expect(PurchaseOrder.fromJson(const {'id': 2, 'status': 'received'}).isOpen, isFalse);
  });
}
