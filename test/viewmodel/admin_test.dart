import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kalenda_mobile/core/api/api_client.dart';
import 'package:kalenda_mobile/features/admin/data/admin_repository.dart';
import 'package:kalenda_mobile/features/admin/model/admin_models.dart';
import 'package:kalenda_mobile/features/admin/viewmodel/admin_viewmodels.dart';

class _FakeAdmin extends AdminRepository {
  _FakeAdmin() : super(ApiClient(readCustomerToken: () async => null, readStaffToken: () async => null, onUnauthorized: (_) {}));

  final calls = <String>[];

  @override
  Future<bool> toggleBusiness(int id) async {
    calls.add('toggle:$id');
    return false;
  }

  @override
  Future<void> answerFeedback(int id, {required String status, String? response}) async => calls.add('answer:$id:$status:$response');

  @override
  Future<List<AdminAppointment>> appointments({String? status}) async {
    calls.add('appointments:$status');
    return const [];
  }
}

void main() {
  late _FakeAdmin repository;
  late ProviderContainer container;

  setUp(() {
    repository = _FakeAdmin();
    container = ProviderContainer(overrides: [adminRepositoryProvider.overrideWithValue(repository)]);
    addTearDown(container.dispose);
  });

  test('a vállalkozás kapcsolása és a visszajelzés megválaszolása a repository-ig jut', () async {
    final actions = container.read(adminActionsProvider.notifier);

    await actions.toggleBusiness(5);
    await actions.answerFeedback(9, status: 'resolved', response: 'Javítottuk');

    expect(repository.calls, ['toggle:5', 'answer:9:resolved:Javítottuk']);
  });

  test('a foglalás-lista az állapot-szűrővel kéri a szervert', () async {
    container.read(adminAppointmentStatusProvider.notifier).select('cancelled');

    await container.read(adminAppointmentsProvider.future);

    expect(repository.calls, ['appointments:cancelled']);
  });

  test('az admin modellek a válaszból épülnek', () {
    final dashboard = AdminDashboard.fromJson({'total_users': 10, 'total_businesses': 3, 'free_plan': 1, 'basic_plan': 1, 'professional_plan': 1, 'appointments_today': 4});
    final business = AdminBusiness.fromJson({
      'id': 1,
      'name': 'Szalon',
      'is_active': false,
      'plan': 'basic',
      'owner': {'name': 'Anna', 'email': 'anna@example.com'},
      'appointments_count': 12,
    });
    final feedback = AdminFeedback.fromJson({
      'id': 2,
      'type': 'feature',
      'subject': 'Ötlet',
      'message': 'Legyen sötét mód',
      'status': 'new',
      'user': {'name': 'Béla'},
    });

    expect(dashboard.users, 10);
    expect(dashboard.appointmentsToday, 4);
    expect(business.isActive, isFalse);
    expect(business.ownerEmail, 'anna@example.com');
    expect(feedback.userName, 'Béla');
    expect(feedback.status, 'new');
  });
}
