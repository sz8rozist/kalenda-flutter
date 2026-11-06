import '../../../core/files/image_picker_gateway.dart';
import 'dart:typed_data';
import '../model/misc_models.dart';
import '../model/finance_models.dart';
import '../model/register_models.dart';
import '../model/appointment_detail.dart';
import '../../../core/files/document_opener.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/viewmodel/action_state.dart';
import '../data/owner_tools_repository.dart';
import '../model/business_info.dart';
import '../model/owner_tools_models.dart';

final expensesProvider = FutureProvider.autoDispose.family<ExpenseListing, int>(
  (ref, businessId) => ref.watch(ownerToolsRepositoryProvider).expenses(businessId),
);

final reviewsProvider = FutureProvider.autoDispose.family<ReviewListing, int>(
  (ref, businessId) => ref.watch(ownerToolsRepositoryProvider).reviews(businessId),
);

final soldPassesProvider = FutureProvider.autoDispose.family<List<SoldPass>, int>(
  (ref, businessId) => ref.watch(ownerToolsRepositoryProvider).soldPasses(businessId),
);

final waitlistProvider = FutureProvider.autoDispose.family<List<WaitlistEntry>, int>(
  (ref, businessId) => ref.watch(ownerToolsRepositoryProvider).waitlist(businessId),
);

/// A tevékenység-napló keresőszövege (a lista ebből szűr).
class ActivitySearchViewModel extends Notifier<String> {
  @override
  String build() => '';

  void search(String text) => state = text;
}

final activitySearchProvider = NotifierProvider.autoDispose<ActivitySearchViewModel, String>(ActivitySearchViewModel.new);

final activityLogProvider = FutureProvider.autoDispose.family<List<ActivityEntry>, int>(
  (ref, businessId) => ref.watch(ownerToolsRepositoryProvider).activityLog(businessId, search: ref.watch(activitySearchProvider)),
);

/// A költségek, értékelés-beállítás és várólista műveletei.
class OwnerToolsActionsViewModel extends ActionNotifier {
  Future<bool> addExpense(
    int businessId, {
    required String category,
    required int amountHuf,
    required DateTime date,
    String? vendor,
    bool recurring = false,
  }) async {
    final ok = await perform(
      () => ref
          .read(ownerToolsRepositoryProvider)
          .createExpense(businessId, category: category, amountHuf: amountHuf, date: date, vendor: vendor, recurring: recurring),
      success: FlashKind.saved,
    );
    if (ok) ref.invalidate(expensesProvider(businessId));
    return ok;
  }

  Future<bool> deleteExpense(int businessId, int expenseId) async {
    final ok = await perform(() => ref.read(ownerToolsRepositoryProvider).deleteExpense(businessId, expenseId));
    if (ok) ref.invalidate(expensesProvider(businessId));
    return ok;
  }

  Future<bool> saveReviewSettings(int businessId, {required bool enabled, String? googleUrl}) async {
    final ok = await perform(
      () => ref.read(ownerToolsRepositoryProvider).saveReviewSettings(businessId, enabled: enabled, googleUrl: googleUrl),
      success: FlashKind.saved,
    );
    if (ok) ref.invalidate(reviewsProvider(businessId));
    return ok;
  }

  Future<bool> notifyWaitlist(int businessId, int entryId) async {
    final ok = await perform(() => ref.read(ownerToolsRepositoryProvider).notifyWaitlist(businessId, entryId), success: FlashKind.saved);
    if (ok) ref.invalidate(waitlistProvider(businessId));
    return ok;
  }

  Future<bool> removeWaitlist(int businessId, int entryId) async {
    final ok = await perform(() => ref.read(ownerToolsRepositoryProvider).removeWaitlist(businessId, entryId));
    if (ok) ref.invalidate(waitlistProvider(businessId));
    return ok;
  }
}

final ownerToolsActionsProvider = NotifierProvider.autoDispose<OwnerToolsActionsViewModel, ActionState>(OwnerToolsActionsViewModel.new);

/// A vállalkozás adatai és csomagja: ebből dől el, mely funkciók érhetők el a vállalkozói menüben.
final businessInfoProvider = FutureProvider.autoDispose.family<BusinessInfo, int>(
  (ref, businessId) => ref.watch(ownerToolsRepositoryProvider).businessInfo(businessId),
);

final subscriptionStateProvider = FutureProvider.autoDispose.family<SubscriptionState, int>(
  (ref, businessId) => ref.watch(ownerToolsRepositoryProvider).subscription(businessId),
);

typedef AppointmentKey = ({int businessId, int appointmentId});

/// Egy foglalás részletei a vállalkozónak.
final appointmentDetailProvider = FutureProvider.autoDispose.family<AppointmentDetail, AppointmentKey>(
  (ref, key) => ref.watch(ownerToolsRepositoryProvider).appointmentDetail(key.businessId, key.appointmentId),
);

/// A foglalás-oldal műveletei: állapotváltás, számla kiállítása, sztornó, PDF megnyitása.
class AppointmentActionsViewModel extends ActionNotifier {
  /// Jelzi a View-nak, hogy a PDF-et nem sikerült megnyitni (nincs hozzá alkalmazás az eszközön).
  bool pdfNotOpened = false;

  Future<bool> setStatus(AppointmentKey key, String status, {bool refund = false}) async {
    final ok = await perform(
      () => ref.read(ownerToolsRepositoryProvider).changeAppointmentStatus(key.businessId, key.appointmentId, status, refund: refund),
      success: FlashKind.saved,
    );
    if (ok) ref.invalidate(appointmentDetailProvider(key));
    return ok;
  }

  Future<bool> issueInvoice(AppointmentKey key, String paymentMethod) async {
    final ok = await perform(
      () => ref.read(ownerToolsRepositoryProvider).issueAppointmentInvoice(key.businessId, key.appointmentId, paymentMethod: paymentMethod),
      success: FlashKind.saved,
    );
    if (ok) ref.invalidate(appointmentDetailProvider(key));
    return ok;
  }

  Future<bool> cancelDocument(AppointmentKey key, int documentId, String? reason) async {
    final ok = await perform(
      () => ref.read(ownerToolsRepositoryProvider).cancelDocument(key.businessId, 'appointment', documentId, reason: reason),
      success: FlashKind.saved,
    );
    if (ok) ref.invalidate(appointmentDetailProvider(key));
    return ok;
  }

  Future<bool> openPdf(AppointmentKey key, AppointmentDocument document) async {
    pdfNotOpened = false;
    return perform(() async {
      final bytes = await ref.read(ownerToolsRepositoryProvider).documentPdf(key.businessId, 'appointment', document.id);
      final opened = await ref.read(documentOpenerProvider).open(bytes, '${document.number ?? 'bizonylat-${document.id}'}.pdf');
      pdfNotOpened = !opened;
    });
  }
}

final appointmentActionsProvider = NotifierProvider.autoDispose<AppointmentActionsViewModel, ActionState>(AppointmentActionsViewModel.new);

/// Bizonylatok (önálló számla, bérlet-számla…) PDF-je és sztornója típus szerint.
class DocumentActionsViewModel extends ActionNotifier {
  bool pdfNotOpened = false;

  Future<bool> openPdf(int businessId, String type, int id, String fileName) async {
    pdfNotOpened = false;
    return perform(() async {
      final bytes = await ref.read(ownerToolsRepositoryProvider).documentPdf(businessId, type, id);
      pdfNotOpened = !await ref.read(documentOpenerProvider).open(bytes, '$fileName.pdf');
    });
  }

  Future<bool> cancel(int businessId, String type, int id, String? reason, {void Function()? onDone}) async {
    final ok = await perform(
      () => ref.read(ownerToolsRepositoryProvider).cancelDocument(businessId, type, id, reason: reason),
      success: FlashKind.saved,
    );
    if (ok) onDone?.call();
    return ok;
  }

  Future<bool> createStandaloneInvoice(
    int businessId, {
    required List<({String name, double qty, int unitPriceHuf})> items,
    String? customerName,
    String? customerEmail,
    int dueDays = 8,
    bool alreadyPaid = false,
    String? paymentMethod,
  }) => perform(
    () => ref
        .read(ownerToolsRepositoryProvider)
        .createStandaloneInvoice(
          businessId,
          items: items,
          customerName: customerName,
          customerEmail: customerEmail,
          dueDays: dueDays,
          alreadyPaid: alreadyPaid,
          paymentMethod: paymentMethod,
        ),
    success: FlashKind.saved,
  );
}

final documentActionsProvider = NotifierProvider.autoDispose<DocumentActionsViewModel, ActionState>(DocumentActionsViewModel.new);

/// A pénztárban éppen megnézett nap.
class RegisterDateViewModel extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  void select(DateTime date) => state = DateTime(date.year, date.month, date.day);

  void shift(int days) => state = state.add(Duration(days: days));
}

final registerDateProvider = NotifierProvider.autoDispose<RegisterDateViewModel, DateTime>(RegisterDateViewModel.new);

final registerDayProvider = FutureProvider.autoDispose.family<RegisterDay, int>(
  (ref, businessId) => ref.watch(ownerToolsRepositoryProvider).registerDay(businessId, ref.watch(registerDateProvider)),
);

/// A pénztár műveletei: tétel rögzítése/törlése, foglalás kifizetése, nap zárása és újranyitása.
class RegisterActionsViewModel extends ActionNotifier {
  Future<bool> record(
    int businessId, {
    required String kind,
    required String method,
    required int amountHuf,
    required DateTime date,
    String? description,
  }) async {
    final ok = await perform(
      () => ref
          .read(ownerToolsRepositoryProvider)
          .recordRegisterPayment(businessId, kind: kind, method: method, amountHuf: amountHuf, date: date, description: description),
      success: FlashKind.saved,
    );
    if (ok) ref.invalidate(registerDayProvider(businessId));
    return ok;
  }

  Future<bool> deletePayment(int businessId, int paymentId) async {
    final ok = await perform(() => ref.read(ownerToolsRepositoryProvider).deleteRegisterPayment(businessId, paymentId));
    if (ok) ref.invalidate(registerDayProvider(businessId));
    return ok;
  }

  Future<bool> payAppointment(int businessId, int appointmentId, String method) async {
    final ok = await perform(
      () => ref.read(ownerToolsRepositoryProvider).payAppointmentAtRegister(businessId, appointmentId, method: method),
      success: FlashKind.saved,
    );
    if (ok) ref.invalidate(registerDayProvider(businessId));
    return ok;
  }

  Future<bool> close(int businessId, DateTime date, {required int countedCashHuf, String? note}) async {
    final ok = await perform(
      () => ref.read(ownerToolsRepositoryProvider).closeRegister(businessId, date, countedCashHuf: countedCashHuf, note: note),
      success: FlashKind.saved,
    );
    if (ok) ref.invalidate(registerDayProvider(businessId));
    return ok;
  }

  Future<bool> reopen(int businessId, DateTime date) async {
    final ok = await perform(() => ref.read(ownerToolsRepositoryProvider).reopenRegister(businessId, date), success: FlashKind.saved);
    if (ok) ref.invalidate(registerDayProvider(businessId));
    return ok;
  }
}

final registerActionsProvider = NotifierProvider.autoDispose<RegisterActionsViewModel, ActionState>(RegisterActionsViewModel.new);

/// A kiválasztott kifizetés azonosítója (üres = a legutóbbi).
class SelectedPayoutViewModel extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? id) => state = id;
}

final selectedPayoutProvider = NotifierProvider.autoDispose<SelectedPayoutViewModel, String?>(SelectedPayoutViewModel.new);

final payoutsProvider = FutureProvider.autoDispose.family<PayoutsOverview, int>(
  (ref, businessId) => ref.watch(ownerToolsRepositoryProvider).payouts(businessId, payoutId: ref.watch(selectedPayoutProvider)),
);

final missingDocumentsProvider = FutureProvider.autoDispose.family<List<MissingDocument>, int>(
  (ref, businessId) => ref.watch(ownerToolsRepositoryProvider).missingDocuments(businessId),
);

/// Kimaradt bizonylat újrapróbálása.
class MissingDocumentsActionsViewModel extends ActionNotifier {
  Future<bool> retry(int businessId, String key) async {
    final ok = await perform(() => ref.read(ownerToolsRepositoryProvider).retryMissingDocument(businessId, key), success: FlashKind.saved);
    if (ok) ref.invalidate(missingDocumentsProvider(businessId));
    return ok;
  }
}

final missingDocumentsActionsProvider = NotifierProvider.autoDispose<MissingDocumentsActionsViewModel, ActionState>(MissingDocumentsActionsViewModel.new);

final ownerLeavesProvider = FutureProvider.autoDispose.family<List<OwnerLeave>, int>(
  (ref, businessId) => ref.watch(ownerToolsRepositoryProvider).leaves(businessId),
);

final notificationsProvider = FutureProvider.autoDispose.family<NotificationListing, int>(
  (ref, businessId) => ref.watch(ownerToolsRepositoryProvider).notifications(businessId),
);

/// Exportok, költség-bizonylat, szabadság-felvétel és értesítések műveletei.
class OwnerMiscActionsViewModel extends ActionNotifier {
  OwnerToolsRepository get _repo => ref.read(ownerToolsRepositoryProvider);

  /// A legutóbbi letöltés után nem nyílt meg a fájl (nincs hozzá alkalmazás).
  bool fileNotOpened = false;

  /// A szabadság felvételekor érintett foglalások száma.
  int lastAffected = 0;

  Future<bool> _open(Future<DownloadedFile> Function() download) async {
    fileNotOpened = false;
    return perform(() async {
      final file = await download();
      fileNotOpened = !await ref.read(documentOpenerProvider).open(Uint8List.fromList(file.bytes), file.name);
    });
  }

  Future<bool> exportAccounting(int businessId, DateTime month) => _open(() => _repo.accountingDownload(businessId, month));

  Future<bool> exportExpenses(int businessId) => _open(() => _repo.expensesExport(businessId));

  Future<bool> exportTimesheet(int businessId, DateTime month) => _open(() => _repo.timesheetExport(businessId, month));

  Future<bool> openReceipt(int businessId, int expenseId) => _open(() => _repo.expenseReceipt(businessId, expenseId));

  Future<bool> uploadReceipt(int businessId, int expenseId) async {
    final path = await ref.read(imagePickerProvider).pickFromGallery();
    if (path == null) return false;
    final ok = await perform(() => _repo.uploadExpenseReceipt(businessId, expenseId, path), success: FlashKind.saved);
    if (ok) ref.invalidate(expensesProvider(businessId));
    return ok;
  }

  Future<bool> createLeave(int businessId, {int? staffId, required DateTime from, required DateTime to, String? reason, bool cancelAffected = false}) async {
    final ok = await perform(
      () async => lastAffected = await _repo.createLeave(businessId, staffId: staffId, from: from, to: to, reason: reason, cancelAffected: cancelAffected),
      success: FlashKind.saved,
    );
    if (ok) ref.invalidate(ownerLeavesProvider(businessId));
    return ok;
  }

  Future<bool> deleteLeave(int businessId, int id) async {
    final ok = await perform(() => _repo.deleteLeave(businessId, id));
    if (ok) ref.invalidate(ownerLeavesProvider(businessId));
    return ok;
  }

  Future<bool> readAllNotifications(int businessId) async {
    final ok = await perform(() => _repo.readAllNotifications(businessId));
    if (ok) ref.invalidate(notificationsProvider(businessId));
    return ok;
  }
}

final ownerMiscActionsProvider = NotifierProvider.autoDispose<OwnerMiscActionsViewModel, ActionState>(OwnerMiscActionsViewModel.new);
