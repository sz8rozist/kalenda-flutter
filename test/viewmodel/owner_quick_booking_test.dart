import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kalenda_mobile/core/api/api_client.dart';
import 'package:kalenda_mobile/features/booking/model/booking_models.dart' show TimeSlot;
import 'package:kalenda_mobile/features/owner/data/owner_repository.dart';
import 'package:kalenda_mobile/features/owner/viewmodel/owner_booking_viewmodel.dart';

class _FakeOwnerRepository extends OwnerRepository {
  _FakeOwnerRepository(this.firstFreeDayOffset) : super(ApiClient(readCustomerToken: () async => null, readStaffToken: () async => null));

  /// Hányadik naptól (a mai naphoz képest) van szabad időpont; null = soha.
  final int? firstFreeDayOffset;
  final asked = <DateTime>[];

  @override
  Future<List<TimeSlot>> availableSlots(int businessId, {required int serviceId, required int staffId, required DateTime date}) async {
    asked.add(date);
    final today = DateTime.now();
    final offset = DateTime(date.year, date.month, date.day).difference(DateTime(today.year, today.month, today.day)).inDays;
    final free = firstFreeDayOffset != null && offset >= firstFreeDayOffset!;
    return [TimeSlot(time: '09:00', available: false), TimeSlot(time: '10:30', available: free)];
  }
}

void main() {
  ProviderContainer containerWith(_FakeOwnerRepository repository) {
    final container = ProviderContainer(overrides: [ownerRepositoryProvider.overrideWithValue(repository)]);
    addTearDown(container.dispose);
    return container;
  }

  test('a mai nap alapból ki van választva', () {
    final container = containerWith(_FakeOwnerRepository(0));
    final today = DateTime.now();

    final date = container.read(ownerBookingProvider(1)).date!;

    expect((date.year, date.month, date.day), (today.year, today.month, today.day));
  });

  test('ha a szolgáltatást egyetlen munkatárs végzi, őt rögtön kiválasztja; többnél nem', () {
    final container = containerWith(_FakeOwnerRepository(0));
    final viewModel = container.read(ownerBookingProvider(1).notifier);

    viewModel.selectService(5, staffIds: const [9]);
    expect(container.read(ownerBookingProvider(1)).staffId, 9);

    viewModel.selectService(6, staffIds: const [9, 10]);
    expect(container.read(ownerBookingProvider(1)).staffId, isNull);
  });

  test('az első szabad időpont keresése megáll az első találatnál, és beállítja a napot és az időt', () async {
    final repository = _FakeOwnerRepository(3);
    final container = containerWith(repository);
    final viewModel = container.read(ownerBookingProvider(1).notifier);
    viewModel.selectService(5, staffIds: const [9]);

    final found = await viewModel.findFirstFreeSlot();

    final state = container.read(ownerBookingProvider(1));
    expect(found, isTrue);
    expect(state.time, '10:30');
    expect(repository.asked.length, 4, reason: '0., 1., 2. és 3. nap');
    expect(state.date!.difference(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)).inDays, 3);
  });

  test('ha két héten belül nincs szabad időpont, hamis; szolgáltatás nélkül kérdezni sem kezd', () async {
    final none = _FakeOwnerRepository(null);
    final container = containerWith(none);
    final viewModel = container.read(ownerBookingProvider(1).notifier);

    expect(await viewModel.findFirstFreeSlot(), isFalse);
    expect(none.asked, isEmpty);

    viewModel.selectService(5, staffIds: const [9]);
    expect(await viewModel.findFirstFreeSlot(), isFalse);
    expect(none.asked.length, 14);
  });
}
