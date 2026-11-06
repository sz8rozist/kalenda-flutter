import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kalenda_mobile/core/api/api_client.dart';
import 'package:kalenda_mobile/features/owner/data/operations_repository.dart';
import 'package:kalenda_mobile/features/owner/model/operations_models.dart';
import 'package:kalenda_mobile/features/owner/viewmodel/operations_viewmodels.dart';

class _FakeOperations extends OperationsRepository {
  _FakeOperations() : super(ApiClient(readCustomerToken: () async => null, readStaffToken: () async => null, onUnauthorized: (_) {}));

  final calls = <String>[];

  @override
  Future<void> createGroupSession(
    int businessId, {
    required int serviceId,
    required int staffId,
    required DateTime date,
    required String time,
    required int capacity,
    int? priceHuf,
    String? notes,
    int repeatWeeks = 0,
  }) async => calls.add('group:$serviceId:$staffId:$time:$capacity:$repeatWeeks');

  @override
  Future<void> addBreak(int businessId, {required int staffId, required int dayOfWeek, required String start, required String end, String? label}) async =>
      calls.add('break:$staffId:$dayOfWeek:$start-$end');

  @override
  Future<void> closeMonth(int businessId, DateTime month) async => calls.add('close:${monthKey(month)}');

  @override
  Future<void> addTimeEntry(int businessId, {required int staffId, required DateTime clockIn, required DateTime clockOut, int breakMinutes = 0, String? note}) async =>
      calls.add('entry:$staffId:${clockOut.difference(clockIn).inMinutes}:$breakMinutes');
}

void main() {
  late _FakeOperations repository;
  late ProviderContainer container;

  setUp(() {
    repository = _FakeOperations();
    container = ProviderContainer(overrides: [operationsRepositoryProvider.overrideWithValue(repository)]);
    addTearDown(container.dispose);
  });

  test('az alkalom, a szünet, a műszak és a hónap-zárás a megadott adatokkal megy a szerverre', () async {
    final actions = container.read(operationsActionsProvider.notifier);

    await actions.createGroupSession(1, serviceId: 2, staffId: 3, date: DateTime(2026, 11, 10), time: '18:00', capacity: 12, repeatWeeks: 4);
    await actions.addBreak(1, staffId: 3, dayOfWeek: 1, start: '12:00', end: '12:30');
    await actions.addTimeEntry(1, staffId: 3, clockIn: DateTime(2026, 11, 6, 9), clockOut: DateTime(2026, 11, 6, 17), breakMinutes: 30);
    await actions.closeMonth(1, DateTime(2026, 10));

    expect(repository.calls, ['group:2:3:18:00:12:4', 'break:3:1:12:00-12:30', 'entry:3:480:30', 'close:2026-10']);
  });

  test('a munkaidő hónapja léptethető, és évhatáron is helyes', () {
    final month = container.read(timesheetMonthProvider.notifier);
    final start = container.read(timesheetMonthProvider);

    month.shift(-13);

    final shifted = container.read(timesheetMonthProvider);
    expect(shifted.year * 12 + shifted.month, start.year * 12 + start.month - 13);
  });

  test('a csoportos alkalom és a munkaidő a válaszból épül', () {
    final session = GroupSessionItem.fromJson({
      'id': 1,
      'starts_at': '2026-11-10T17:00:00Z',
      'capacity': 10,
      'booked': 4,
      'places_left': 6,
      'status': 'scheduled',
      'service': {'name': 'Jóga'},
      'attendees': [
        {'customer_name': 'Éva', 'status': 'confirmed'},
      ],
    });
    final month = TimesheetMonth.fromJson({
      'month': '2026-11',
      'entries': {
        'content': [
          {'id': 1, 'staff': {'name': 'Kata'}, 'worked_minutes': 450, 'break_minutes': 30},
        ],
      },
      'summary': {
        'rows': [
          {'staff_id': 3, 'name': 'Kata', 'worked_minutes': 450, 'estimated_pay_huf': 90000},
        ],
        'totals': {'worked_minutes': 450, 'estimated_pay_huf': 90000, 'stale_open_count': 1},
        'closed_at': '2026-12-01T08:00:00Z',
      },
      'staff_options': [
        {'id': 3, 'name': 'Kata'},
      ],
    });

    expect(session.placesLeft, 6);
    expect(session.isCancelled, isFalse);
    expect(session.attendees.single.name, 'Éva');
    expect(month.isClosed, isTrue);
    expect(month.rows.single.estimatedPayHuf, 90000);
    expect(month.entries.single.workedMinutes, 450);
    expect(month.staffOptions.single.name, 'Kata');
    expect(month.staleOpenCount, 1);
  });
}
