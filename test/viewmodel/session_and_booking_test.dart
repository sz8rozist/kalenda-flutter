import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kalenda_mobile/core/api/api_exception.dart';
import 'package:kalenda_mobile/core/auth/social_sign_in_gateway.dart';
import 'package:kalenda_mobile/core/auth/token_store.dart';
import 'package:kalenda_mobile/core/providers.dart';
import 'package:kalenda_mobile/core/push/push_service.dart';
import 'package:kalenda_mobile/features/auth/data/customer_auth_repository.dart';
import 'package:kalenda_mobile/features/auth/viewmodel/customer_session_viewmodel.dart';
import 'package:kalenda_mobile/features/auth/viewmodel/login_viewmodel.dart';
import 'package:kalenda_mobile/features/booking/data/booking_repository.dart';
import 'package:kalenda_mobile/features/booking/model/booking_models.dart';
import 'package:kalenda_mobile/features/booking/model/booking_request.dart';
import 'package:kalenda_mobile/features/booking/viewmodel/booking_form_viewmodel.dart';
import 'package:kalenda_mobile/features/booking/viewmodel/business_viewmodels.dart';

import '../support/fake_repositories.dart';
import '../support/fake_services.dart';
import '../support/fakes.dart';

PublicBusiness _business({bool campaigns = false}) => PublicBusiness.fromJson({
      'name': 'Szalon',
      'slug': 'szalon',
      'has_campaigns': campaigns,
      'services': [
        {'id': 1, 'name': 'Hajvágás', 'duration_minutes': 30},
      ],
      'staff': [
        {
          'id': 7,
          'name': 'Anna',
          'service_ids': [1]
        },
      ],
    });

void main() {
  group('ügyfél-munkamenet és belépés', () {
    late FakeCustomerAuthRepository repository;
    late FakeTokenStore store;

    ProviderContainer container({String? token}) {
      repository = FakeCustomerAuthRepository();
      store = FakeTokenStore(customer: token);
      final c = ProviderContainer.test(overrides: [
        customerAuthRepositoryProvider.overrideWithValue(repository),
        tokenStoreProvider.overrideWithValue(store),
        pushServiceProvider.overrideWith(NoPush.new),
      ]);
      c.listen(customerSessionProvider, (_, _) {});
      return c;
    }

    test('token nélkül nincs belépve, tokennel be van', () async {
      expect(await container().read(customerSessionProvider.future), isFalse);
      expect(await container(token: 'x').read(customerSessionProvider.future), isTrue);
    });

    test('a kóddal belépés elmenti a tokent, és belépettre vált', () async {
      final c = container();
      await c.read(customerSessionProvider.future);

      await c.read(customerSessionProvider.notifier).signIn('KOD');

      expect(repository.lastCode, 'KOD');
      expect(c.read(customerSessionProvider).value, isTrue);
      expect(await store.read(TokenKind.customer), 'kalenda_tok');
    });

    test('a beillesztett link kódja jut a szerverre', () async {
      final c = container();
      await c.read(customerSessionProvider.future);

      await c.read(loginViewModelProvider.notifier).signIn('https://kalenda.example/fiokom/belepes/AbC123');

      expect(repository.lastCode, 'AbC123');
      expect(c.read(customerSessionProvider).value, isTrue);
    });

    test('hibás kódnál a belépés hibát jelez, és nem lép be', () async {
      final c = container();
      await c.read(customerSessionProvider.future);
      c.listen(loginViewModelProvider, (_, _) {});
      repository.failWith = ApiException(statusCode: 422, message: 'lejárt');

      await c.read(loginViewModelProvider.notifier).signIn('ROSSZ');

      expect(c.read(loginViewModelProvider).error, isA<ApiException>());
      expect(c.read(customerSessionProvider).value, isFalse);
    });

    test('Google- és Apple-belépés: az id-token (és az Apple-név) megy a szerverre', () async {
      final c = container();
      await c.read(customerSessionProvider.future);
      final session = c.read(customerSessionProvider.notifier);

      await session.signInWithGoogle(const SocialCredential(idToken: 'google-id'));
      expect(repository.lastGoogleIdToken, 'google-id');

      await session.signOut();
      await session.signInWithApple(const SocialCredential(idToken: 'apple-id', name: 'Kovács Anna'));
      expect(repository.lastAppleName, 'Kovács Anna');
      expect(c.read(customerSessionProvider).value, isTrue);
    });

    test('kijelentkezés: törli a tokent, hálózati hibánál is', () async {
      final c = container(token: 'x');
      await c.read(customerSessionProvider.future);

      await c.read(customerSessionProvider.notifier).signOut();

      expect(repository.loggedOut, isTrue);
      expect(c.read(customerSessionProvider).value, isFalse);
      expect(await store.read(TokenKind.customer), isNull);
    });

    test('fióktörlés: sikernél kilép, hibánál (közelgő foglalás) belépve marad', () async {
      final c = container(token: 'x');
      await c.read(customerSessionProvider.future);
      final session = c.read(customerSessionProvider.notifier);

      repository.failWith = ApiException(statusCode: 422, message: 'Előbb mondd le a közelgő foglalásaidat.');
      await expectLater(session.deleteAccount(), throwsA(isA<ApiException>()));
      expect(c.read(customerSessionProvider).value, isTrue);

      repository.failWith = null;
      await session.deleteAccount();
      expect(repository.accountDeleted, isTrue);
      expect(c.read(customerSessionProvider).value, isFalse);
    });
  });

  group('foglalási űrlap', () {
    late FakeBookingRepository repository;
    late NoPush push;

    ProviderContainer container({bool campaigns = false, int? staffCount}) {
      repository = FakeBookingRepository(_business(campaigns: campaigns));
      final c = ProviderContainer.test(overrides: [
        bookingRepositoryProvider.overrideWithValue(repository),
        tokenStoreProvider.overrideWithValue(FakeTokenStore()),
        pushServiceProvider.overrideWith((ref) => push = NoPush(ref)),
      ]);
      return c;
    }

    const args = (slug: 'szalon', serviceId: 1);
    const details = BookingDetails(name: 'Kiss Péter', email: 'peter@example.com', phone: '+36301234567');

    test('egyetlen munkatársnál automatikusan őt választja', () async {
      final c = container();
      await c.read(businessViewModelProvider('szalon').future);
      c.listen(bookingFormViewModelProvider(args), (_, _) {});

      expect(c.read(bookingFormViewModelProvider(args)).staffId, 7);
    });

    test('hiányzó nap / időpont esetén nem küld, hanem jelzi', () async {
      final c = container();
      c.listen(bookingFormViewModelProvider(args), (_, _) {});

      await c.read(bookingFormViewModelProvider(args).notifier).submit(details);

      expect(c.read(bookingFormViewModelProvider(args)).incomplete, isTrue);
      expect(repository.lastBooking, isNull);
    });

    test('sikeres foglalás: a kérés összeáll, outcome lesz, push-engedélyt kér', () async {
      final c = container();
      await c.read(businessViewModelProvider('szalon').future);
      c.listen(bookingFormViewModelProvider(args), (_, _) {});
      final form = c.read(bookingFormViewModelProvider(args).notifier);

      form.pickDate(DateTime(2026, 11, 10, 15));
      form.toggleAddon(5, true); // a kiegészítő-váltás törli az időpontot, ezért az időpont-választás utána jön
      form.selectTime('10:00');
      await form.submit(details);

      final state = c.read(bookingFormViewModelProvider(args));
      expect(state.outcome?.manageToken, 'manage-token');
      expect(state.busy, isFalse);
      expect(repository.lastBooking!.serviceId, 1);
      expect(repository.lastBooking!.staffId, 7);
      expect(repository.lastBooking!.time, '10:00');
      expect(repository.lastBooking!.addonIds, [5]);
      expect(repository.lastBooking!.name, 'Kiss Péter');
      expect(push.enableAfterBookingCalls, 1);
    });

    test('a hírlevél-hozzájárulás csak kampányos vállalkozásnál megy a szerverre', () async {
      final without = container();
      await without.read(businessViewModelProvider('szalon').future);
      without.listen(bookingFormViewModelProvider(args), (_, _) {});
      final a = without.read(bookingFormViewModelProvider(args).notifier);
      a.pickDate(DateTime(2026, 11, 10));
      a.selectTime('10:00');
      a.setMarketing(true);
      await a.submit(details);
      expect(repository.lastBooking!.marketingConsent, isNull);

      final with_ = container(campaigns: true);
      await with_.read(businessViewModelProvider('szalon').future);
      with_.listen(bookingFormViewModelProvider(args), (_, _) {});
      final b = with_.read(bookingFormViewModelProvider(args).notifier);
      b.pickDate(DateTime(2026, 11, 10));
      b.selectTime('10:00');
      b.setMarketing(true);
      await b.submit(details);
      expect(repository.lastBooking!.marketingConsent, isTrue);
    });

    test('szerverhiba: a hiba megjelenik, nincs outcome', () async {
      final c = container();
      await c.read(businessViewModelProvider('szalon').future);
      c.listen(bookingFormViewModelProvider(args), (_, _) {});
      repository.bookFails = ApiException(statusCode: 422, message: 'Ez az időpont már foglalt.');
      final form = c.read(bookingFormViewModelProvider(args).notifier);
      form.pickDate(DateTime(2026, 11, 10));
      form.selectTime('10:00');

      await form.submit(details);

      final state = c.read(bookingFormViewModelProvider(args));
      expect(state.outcome, isNull);
      expect(state.error, isA<ApiException>());
      expect(state.busy, isFalse);
    });

    test('a kiegészítő- vagy dátumváltás törli a kiválasztott időpontot', () async {
      final c = container();
      c.listen(bookingFormViewModelProvider(args), (_, _) {});
      final form = c.read(bookingFormViewModelProvider(args).notifier);
      form.pickDate(DateTime(2026, 11, 10));
      form.selectTime('10:00');

      form.toggleAddon(5, true);
      expect(c.read(bookingFormViewModelProvider(args)).time, isNull);

      form.selectTime('11:00');
      form.pickDate(DateTime(2026, 11, 11));
      expect(c.read(bookingFormViewModelProvider(args)).time, isNull);
    });

    test('várólista: a nappal és az adatokkal iratkozik fel', () async {
      final c = container();
      await c.read(businessViewModelProvider('szalon').future);
      c.listen(bookingFormViewModelProvider(args), (_, _) {});
      final form = c.read(bookingFormViewModelProvider(args).notifier);
      form.pickDate(DateTime(2026, 11, 10));

      await form.joinWaitlist(details);

      expect(repository.lastWaitlist!.email, 'peter@example.com');
      expect(repository.lastWaitlist!.staffId, 7);
      expect(repository.lastWaitlist!.preferredDate, DateTime(2026, 11, 10));
      expect(c.read(bookingFormViewModelProvider(args)).waitlistMessage, 'Feliratkoztál.');
    });
  });
}
