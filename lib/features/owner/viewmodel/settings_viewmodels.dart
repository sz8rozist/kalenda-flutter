import '../model/extras_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/files/image_picker_gateway.dart';
import '../../../core/viewmodel/action_state.dart';
import '../data/settings_repository.dart';
import '../model/settings_models.dart';
import 'owner_tools_viewmodels.dart';

final paymentSettingsProvider = FutureProvider.autoDispose.family<PaymentSettings, int>(
  (ref, businessId) => ref.watch(settingsRepositoryProvider).paymentSettings(businessId),
);

final invoicingSettingsProvider = FutureProvider.autoDispose.family<InvoicingSettings, int>(
  (ref, businessId) => ref.watch(settingsRepositoryProvider).invoicingSettings(businessId),
);

final calendarFeedsProvider = FutureProvider.autoDispose.family<CalendarFeeds, int>(
  (ref, businessId) => ref.watch(settingsRepositoryProvider).calendarFeeds(businessId),
);

final bookingPageProvider = FutureProvider.autoDispose.family<BookingPageSettings, int>(
  (ref, businessId) => ref.watch(settingsRepositoryProvider).bookingPage(businessId),
);

/// Be van-e kapcsolva a reggeli napi összefoglaló push.
final dailySummaryProvider = FutureProvider.autoDispose.family<bool, int>(
  (ref, businessId) => ref.watch(settingsRepositoryProvider).dailySummary(businessId),
);

/// A beállítások műveletei: minden szakasz mentése, Stripe-kapcsolat, naptár-hivatkozás újragenerálása, képek.
class SettingsActionsViewModel extends ActionNotifier {
  SettingsRepository get _repo => ref.read(settingsRepositoryProvider);

  /// A legutóbb kért Stripe-hivatkozás (a View megnyitja a böngészőben).
  String? stripeUrl;

  Future<bool> _run(int businessId, Future<void> Function() action, {FlashKind? success = FlashKind.saved}) async {
    final ok = await perform(action, success: success);
    if (ok) {
      ref.invalidate(businessInfoProvider(businessId));
      ref.invalidate(paymentSettingsProvider(businessId));
      ref.invalidate(invoicingSettingsProvider(businessId));
      ref.invalidate(calendarFeedsProvider(businessId));
      ref.invalidate(bookingPageProvider(businessId));
      ref.invalidate(dailySummaryProvider(businessId));
    }
    return ok;
  }

  Future<bool> setDailySummary(int businessId, bool enabled) => _run(businessId, () => _repo.setDailySummary(businessId, enabled));

  Future<bool> updateBusiness(
    int businessId, {
    required String name,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? description,
  }) => _run(
    businessId,
    () => _repo.updateBusiness(businessId, name: name, email: email, phone: phone, address: address, city: city, description: description),
  );

  Future<bool> setSolo(int businessId, bool solo) => _run(businessId, () => _repo.setSolo(businessId, solo));

  Future<bool> savePolicy(
    int businessId, {
    required int cancellationDeadlineHours,
    required bool allowCustomerReschedule,
    int? noShowThreshold,
    int? noShowDepositPercentage,
  }) => _run(
    businessId,
    () => _repo.savePolicy(
      businessId,
      cancellationDeadlineHours: cancellationDeadlineHours,
      allowCustomerReschedule: allowCustomerReschedule,
      noShowThreshold: noShowThreshold,
      noShowDepositPercentage: noShowDepositPercentage,
    ),
  );

  Future<bool> savePayments(
    int businessId, {
    required String depositType,
    required int depositPercentage,
    required int refundCutoffHours,
  }) => _run(
    businessId,
    () => _repo.savePaymentSettings(
      businessId,
      depositType: depositType,
      depositPercentage: depositPercentage,
      refundCutoffHours: refundCutoffHours,
    ),
  );

  Future<bool> setOnlinePayments(int businessId, bool enabled) => _run(businessId, () => _repo.setOnlinePayments(businessId, enabled));

  Future<bool> requestStripeUrl(int businessId, {required bool dashboard}) async {
    stripeUrl = null;
    return perform(() async {
      stripeUrl = dashboard ? await _repo.stripeDashboardUrl(businessId) : await _repo.stripeOnboardingUrl(businessId);
    });
  }

  Future<bool> syncStripe(int businessId) => _run(businessId, () => _repo.syncStripe(businessId));

  Future<bool> saveInvoicing(
    int businessId, {
    required bool enabled,
    required String provider,
    required String documentType,
    required String vat,
    required bool autoSend,
    String? apiKey,
    String? agentKey,
    int? blockId,
    int? receiptBlockId,
  }) => _run(
    businessId,
    () => _repo.saveInvoicingSettings(
      businessId,
      enabled: enabled,
      provider: provider,
      documentType: documentType,
      vat: vat,
      autoSend: autoSend,
      apiKey: apiKey,
      agentKey: agentKey,
      blockId: blockId,
      receiptBlockId: receiptBlockId,
    ),
  );

  Future<bool> regenerateFeed(int businessId, {int? staffId}) => _run(businessId, () => _repo.regenerateFeed(businessId, staffId: staffId));

  Future<bool> saveBookingPage(
    int businessId, {
    String? description,
    String? extraInfo,
    required bool groupSessions,
    required bool rentals,
  }) => _run(
    businessId,
    () => _repo.saveBookingPage(businessId, description: description, extraInfo: extraInfo, groupSessions: groupSessions, rentals: rentals),
  );

  /// Kép kiválasztása és feltöltése (`logo` | `cover`). Hamis, ha a felhasználó nem választott képet vagy a feltöltés hibázott.
  Future<bool> uploadImage(int businessId, String kind) async {
    final path = await ref.read(imagePickerProvider).pickFromGallery();
    if (path == null) return false;
    return _run(businessId, () => _repo.uploadImage(businessId, kind, path));
  }

  Future<bool> deleteImage(int businessId, String kind) => _run(businessId, () => _repo.deleteImage(businessId, kind), success: null);
}

final settingsActionsProvider = NotifierProvider.autoDispose<SettingsActionsViewModel, ActionState>(SettingsActionsViewModel.new);

final addonsProvider = FutureProvider.autoDispose.family<List<Addon>, int>(
  (ref, businessId) => ref.watch(settingsRepositoryProvider).addons(businessId),
);

typedef StaffKey = ({int businessId, int staffId});

final staffHoursProvider = FutureProvider.autoDispose.family<List<StaffHour>, StaffKey>(
  (ref, key) => ref.watch(settingsRepositoryProvider).staffHours(key.businessId, key.staffId),
);

final staffPayProvider = FutureProvider.autoDispose.family<StaffPay, StaffKey>(
  (ref, key) => ref.watch(settingsRepositoryProvider).staffPay(key.businessId, key.staffId),
);

final portalProfileProvider = FutureProvider.autoDispose<PortalProfile>((ref) => ref.watch(settingsRepositoryProvider).portalProfile());

/// A munkatársi portál munkaidő-nyilvántartásának hónapja.
class PortalMonthViewModel extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  void shift(int months) => state = DateTime(state.year, state.month + months);
}

final portalMonthProvider = NotifierProvider.autoDispose<PortalMonthViewModel, DateTime>(PortalMonthViewModel.new);

final portalTimesheetProvider = FutureProvider.autoDispose<PortalTimesheet>(
  (ref) => ref.watch(settingsRepositoryProvider).portalTimesheet(ref.watch(portalMonthProvider)),
);

/// Kiegészítők, munkatárs munkaideje és bére, anyagfelhasználás, portál-profil műveletei.
class ExtrasActionsViewModel extends ActionNotifier {
  SettingsRepository get _repo => ref.read(settingsRepositoryProvider);

  Future<bool> saveAddon(int businessId, Addon addon, {int? id}) async {
    final ok = await perform(() => _repo.saveAddon(businessId, id: id, addon: addon), success: FlashKind.saved);
    if (ok) ref.invalidate(addonsProvider(businessId));
    return ok;
  }

  Future<bool> deleteAddon(int businessId, int id) async {
    final ok = await perform(() => _repo.deleteAddon(businessId, id));
    if (ok) ref.invalidate(addonsProvider(businessId));
    return ok;
  }

  Future<bool> saveStaffHours(StaffKey key, List<StaffHour> hours) async {
    final ok = await perform(() => _repo.saveStaffHours(key.businessId, key.staffId, hours), success: FlashKind.saved);
    if (ok) ref.invalidate(staffHoursProvider(key));
    return ok;
  }

  Future<bool> saveStaffPay(StaffKey key, {required String payType, required int payRateHuf, required String hoursSource, double serviceCommission = 0, double productCommission = 0}) async {
    final ok = await perform(
      () => _repo.saveStaffPay(key.businessId, key.staffId, payType: payType, payRateHuf: payRateHuf, hoursSource: hoursSource, serviceCommission: serviceCommission, productCommission: productCommission),
      success: FlashKind.saved,
    );
    if (ok) ref.invalidate(staffPayProvider(key));
    return ok;
  }

  Future<bool> saveMaterials(int businessId, int serviceId, Map<int, double> materials) =>
      perform(() => _repo.saveServiceMaterials(businessId, serviceId, materials), success: FlashKind.saved);

  /// Kép feltöltése egy munkatárshoz (`staff/{id}/photo`) vagy szolgáltatáshoz (`services/{id}/image`).
  Future<bool> uploadImage(int businessId, String kind) async {
    final path = await ref.read(imagePickerProvider).pickFromGallery();
    if (path == null) return false;
    return perform(() => _repo.uploadImage(businessId, kind, path), success: FlashKind.saved);
  }

  Future<bool> regenerateCalendarToken() async {
    final ok = await perform(() async => await _repo.regeneratePortalCalendarToken(), success: FlashKind.saved);
    if (ok) ref.invalidate(portalProfileProvider);
    return ok;
  }
}

final extrasActionsProvider = NotifierProvider.autoDispose<ExtrasActionsViewModel, ActionState>(ExtrasActionsViewModel.new);
