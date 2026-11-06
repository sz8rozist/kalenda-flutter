import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kalenda_mobile/core/api/api_client.dart';
import 'package:kalenda_mobile/core/auth/token_store.dart';
import 'package:kalenda_mobile/core/providers.dart';
import 'package:kalenda_mobile/features/staff/data/staff_account_repository.dart';
import 'package:kalenda_mobile/features/staff/data/staff_repositories.dart';
import 'package:kalenda_mobile/features/staff/model/staff_models.dart';
import 'package:kalenda_mobile/features/staff/viewmodel/staff_account_viewmodels.dart';
import 'package:kalenda_mobile/features/staff/viewmodel/staff_session_viewmodel.dart';

import '../support/fakes.dart';

ApiClient _api() => ApiClient(readCustomerToken: () async => null, readStaffToken: () async => null, onUnauthorized: (_) {});

StaffUser _user({bool owner = false}) => StaffUser(name: 'Anna', email: 'anna@example.com', isStaff: false, isOwner: owner, businessId: owner ? 1 : null);

class _FakeAccountRepository extends StaffAccountRepository {
  _FakeAccountRepository() : super(_api());

  final calls = <String>[];

  @override
  Future<({String token, StaffUser user})> register({required String name, required String email, required String password}) async {
    calls.add('register:$email');
    return (token: 'tok-1', user: _user());
  }

  @override
  Future<void> forgotPassword(String email) async => calls.add('forgot:$email');

  @override
  Future<void> changePassword({required String current, required String password}) async => calls.add('password');

  @override
  Future<void> createBusiness({
    required String name,
    required bool isSolo,
    required List<({String name, int durationMinutes, int? priceHuf})> services,
    required List<({String name, String? email})> staff,
    String? phone,
    String? address,
    String? city,
  }) async => calls.add('business:$name:$isSolo:${services.length}:${staff.length}');
}

class _FakeAuthRepository extends StaffAuthRepository {
  _FakeAuthRepository() : super(_api());

  @override
  Future<StaffUser> me() async => _user(owner: true);
}

void main() {
  late _FakeAccountRepository account;
  late FakeTokenStore tokens;
  late ProviderContainer container;

  setUp(() {
    account = _FakeAccountRepository();
    tokens = FakeTokenStore();
    container = ProviderContainer(
      overrides: [
        staffAccountRepositoryProvider.overrideWithValue(account),
        staffAuthRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
        tokenStoreProvider.overrideWithValue(tokens),
      ],
    );
    addTearDown(container.dispose);
  });

  test('a regisztráció elmenti a tokent, és be is lépteti a felhasználót', () async {
    await container.read(staffSessionProvider.future);

    final ok = await container.read(staffAccountProvider.notifier).register(name: 'Anna', email: 'anna@example.com', password: 'Jelszo12345');

    expect(ok, isTrue);
    expect(account.calls, ['register:anna@example.com']);
    expect(await tokens.read(TokenKind.staff), 'tok-1');
    expect(container.read(staffSessionProvider).value?.email, 'anna@example.com');
  });

  test('a vállalkozás létrehozása után a felhasználó újratöltődik (tulajdonos lesz)', () async {
    container.read(staffSessionProvider.notifier).adopt(_user());

    final ok = await container
        .read(staffAccountProvider.notifier)
        .createBusiness(
          name: 'Próba Szalon',
          isSolo: false,
          services: [(name: 'Hajvágás', durationMinutes: 30, priceHuf: 5000)],
          staff: [(name: 'Kata', email: 'kata@example.com')],
        );

    expect(ok, isTrue);
    expect(account.calls, ['business:Próba Szalon:false:1:1']);
    expect(container.read(staffSessionProvider).value?.isOwner, isTrue);
  });

  test('az elfelejtett jelszó és a jelszócsere a repository-ig jut', () async {
    final viewModel = container.read(staffAccountProvider.notifier);

    await viewModel.forgotPassword('anna@example.com');
    await viewModel.changePassword(current: 'regi', password: 'Uj-jelszo-1');

    expect(account.calls, ['forgot:anna@example.com', 'password']);
  });

  test('az admin szerepkör a válaszból olvasódik ki', () {
    final admin = StaffUser.fromJson({
      'name': 'Admin',
      'email': 'a@x.hu',
      'roles': {'admin': true, 'staff': false, 'business_owner': false},
    });

    expect(admin.isAdmin, isTrue);
    expect(StaffUser.fromJson(<String, dynamic>{'roles': <String, dynamic>{}}).isAdmin, isFalse);
  });
}
