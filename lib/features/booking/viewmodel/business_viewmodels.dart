import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/booking_repository.dart';
import '../model/booking_models.dart';
import '../model/booking_request.dart';

/// Egy vállalkozás nyilvános adatlapja (szolgáltatások, munkatársak, kiegészítők); a kulcs a slug.
class BusinessViewModel extends AsyncNotifier<PublicBusiness> {
  BusinessViewModel(this.slug);

  final String slug;

  @override
  Future<PublicBusiness> build() => ref.watch(bookingRepositoryProvider).business(slug);
}

final businessViewModelProvider =
    AsyncNotifierProvider.autoDispose.family<BusinessViewModel, PublicBusiness, String>(BusinessViewModel.new);

/// Egy nap időpont-rácsa a szolgáltatáshoz és a munkatárshoz.
class SlotsViewModel extends AsyncNotifier<List<TimeSlot>> {
  SlotsViewModel(this.query);

  final SlotQuery query;

  @override
  Future<List<TimeSlot>> build() => ref.watch(bookingRepositoryProvider).slots(query);
}

final slotsViewModelProvider =
    AsyncNotifierProvider.autoDispose.family<SlotsViewModel, List<TimeSlot>, SlotQuery>(SlotsViewModel.new);

/// A beírt vagy beolvasott szövegből (azonosító vagy foglalási link) a vállalkozás azonosítója (slug):
/// `https://…/booking/szalon` → `szalon`; sima azonosítót változatlanul ad. Üres bevitelre null.
String? slugFromBusinessLink(String input) {
  final text = input.trim();
  final uri = Uri.tryParse(text);
  final slug = (uri != null && uri.hasScheme && uri.pathSegments.isNotEmpty)
      ? uri.pathSegments.where((s) => s.isNotEmpty).last
      : text.replaceAll('/', '');
  return slug.isEmpty ? null : slug;
}

/// A „Vállalkozás keresése" képernyő logikája.
class FindBusinessViewModel extends Notifier<void> {
  @override
  void build() {}

  String? resolveSlug(String input) => slugFromBusinessLink(input);
}

/// QR-kód beolvasás: az első érvényes, foglalási oldalra mutató kód eredménye (a többit figyelmen kívül hagyja,
/// mert a kamera másodpercenként többször ugyanazt a kódot jelenti).
class ScanViewModel extends Notifier<String?> {
  @override
  String? build() => null;

  void onCode(String? raw) {
    if (state != null || raw == null) return;
    state = slugFromBusinessLink(raw);
  }
}

final scanViewModelProvider = NotifierProvider.autoDispose<ScanViewModel, String?>(ScanViewModel.new);

final findBusinessViewModelProvider = NotifierProvider.autoDispose<FindBusinessViewModel, void>(FindBusinessViewModel.new);

/// A vállalkozás bérelhető szolgáltatásai (a nyilvános oldalon külön szakasz).
final rentalsProvider = FutureProvider.autoDispose.family<List<PublicRental>, String>(
  (ref, slug) => ref.watch(bookingRepositoryProvider).rentals(slug),
);
