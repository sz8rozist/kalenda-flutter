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

/// A „Vállalkozás keresése" képernyő logikája: a beírt szövegből (azonosító vagy link) a slug.
class FindBusinessViewModel extends Notifier<void> {
  @override
  void build() {}

  /// `https://…/foglalas/szalon` → `szalon`; sima azonosítót változatlanul ad. Üres bevitelre null.
  String? resolveSlug(String input) {
    final text = input.trim();
    final uri = Uri.tryParse(text);
    final slug = (uri != null && uri.hasScheme && uri.pathSegments.isNotEmpty)
        ? uri.pathSegments.where((s) => s.isNotEmpty).last
        : text.replaceAll('/', '');
    return slug.isEmpty ? null : slug;
  }
}

final findBusinessViewModelProvider = NotifierProvider.autoDispose<FindBusinessViewModel, void>(FindBusinessViewModel.new);
