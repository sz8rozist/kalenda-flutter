import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kalenda_mobile/core/api/api_client.dart';
import 'package:kalenda_mobile/core/files/image_picker_gateway.dart';
import 'package:kalenda_mobile/features/owner/data/settings_repository.dart';
import 'package:kalenda_mobile/features/owner/model/settings_models.dart';
import 'package:kalenda_mobile/features/owner/viewmodel/settings_viewmodels.dart';

class _FakeSettings extends SettingsRepository {
  _FakeSettings() : super(ApiClient(readCustomerToken: () async => null, readStaffToken: () async => null, onUnauthorized: (_) {}));

  final calls = <String>[];

  @override
  Future<void> savePolicy(
    int businessId, {
    required int cancellationDeadlineHours,
    required bool allowCustomerReschedule,
    int? noShowThreshold,
    int? noShowDepositPercentage,
  }) async => calls.add('policy:$cancellationDeadlineHours:$allowCustomerReschedule:$noShowThreshold');

  @override
  Future<void> savePaymentSettings(int businessId, {required String depositType, required int depositPercentage, required int refundCutoffHours}) async =>
      calls.add('payments:$depositType:$depositPercentage:$refundCutoffHours');

  @override
  Future<void> setSolo(int businessId, bool isSolo) async => calls.add('solo:$isSolo');

  @override
  Future<String> stripeOnboardingUrl(int businessId) async => 'https://connect.stripe.com/setup/x';

  @override
  Future<String> stripeDashboardUrl(int businessId) async => 'https://dashboard.stripe.com/x';

  @override
  Future<void> uploadImage(int businessId, String kind, String filePath) async => calls.add('upload:$kind:$filePath');

  @override
  Future<CalendarFeeds> regenerateFeed(int businessId, {int? staffId}) async {
    calls.add('feed:$staffId');
    return const CalendarFeeds(businessUrl: null, staff: []);
  }
}

class _FakePicker extends ImagePickerGateway {
  const _FakePicker(this.path);

  final String? path;

  @override
  Future<String?> pickFromGallery() async => path;
}

void main() {
  late _FakeSettings repository;

  ProviderContainer containerWith({String? picked}) {
    final container = ProviderContainer(
      overrides: [settingsRepositoryProvider.overrideWithValue(repository), imagePickerProvider.overrideWithValue(_FakePicker(picked))],
    );
    addTearDown(container.dispose);
    return container;
  }

  setUp(() => repository = _FakeSettings());

  test('a szabályzat, a fizetés és a mód mentése a megadott értékekkel megy', () async {
    final actions = containerWith().read(settingsActionsProvider.notifier);

    await actions.savePolicy(1, cancellationDeadlineHours: 24, allowCustomerReschedule: true, noShowThreshold: 2);
    await actions.savePayments(1, depositType: 'percentage', depositPercentage: 30, refundCutoffHours: 48);
    await actions.setSolo(1, true);

    expect(repository.calls, ['policy:24:true:2', 'payments:percentage:30:48', 'solo:true']);
  });

  test('a Stripe-hivatkozás a megfelelő végpontról jön (beállítás / irányítópult)', () async {
    final actions = containerWith().read(settingsActionsProvider.notifier);

    await actions.requestStripeUrl(1, dashboard: false);
    expect(actions.stripeUrl, 'https://connect.stripe.com/setup/x');

    await actions.requestStripeUrl(1, dashboard: true);
    expect(actions.stripeUrl, 'https://dashboard.stripe.com/x');
  });

  test('a kép feltöltése a kiválasztott fájllal megy; ha nincs kiválasztva, nem történik semmi', () async {
    final picked = containerWith(picked: '/tmp/logo.png').read(settingsActionsProvider.notifier);
    expect(await picked.uploadImage(1, 'logo'), isTrue);
    expect(repository.calls, ['upload:logo:/tmp/logo.png']);

    repository.calls.clear();
    final none = containerWith().read(settingsActionsProvider.notifier);
    expect(await none.uploadImage(1, 'logo'), isFalse);
    expect(repository.calls, isEmpty);
  });

  test('a naptár-hivatkozás újragenerálása a munkatárs azonosítójával megy', () async {
    await containerWith().read(settingsActionsProvider.notifier).regenerateFeed(1, staffId: 7);

    expect(repository.calls, ['feed:7']);
  });

  test('a fizetési és számlázási beállítások a válaszból épülnek, a kulcsok nem jönnek vissza', () {
    final payments = PaymentSettings.fromJson({
      'deposit_type': 'percentage',
      'deposit_percentage': 30,
      'refund_cutoff_hours': 24,
      'online_payments_available': true,
      'platform_fee_percent': 1.5,
      'stripe_connect': {'connected': true, 'charges_enabled': true},
    });
    final invoicing = InvoicingSettings.fromJson({'enabled': true, 'provider': 'szamlazz', 'has_api_key': true, 'vat': '27%', 'vat_codes': ['AAM', '27%']});
    final feeds = CalendarFeeds.fromJson({
      'business_feed_url': 'https://x/b.ics',
      'staff_feeds': [
        {'id': 3, 'name': 'Kata', 'url': 'https://x/s.ics'},
      ],
    });

    expect(payments.stripe.chargesEnabled, isTrue);
    expect(payments.platformFeePercent, 1.5);
    expect(invoicing.hasApiKey, isTrue);
    expect(invoicing.vatCodes, ['AAM', '27%']);
    expect(feeds.staff.single.name, 'Kata');
    expect(StripeStatus.fromJson(null).connected, isFalse);
  });
}
