import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kalenda_mobile/features/favorites/model/saved_business.dart';
import 'package:kalenda_mobile/features/favorites/viewmodel/saved_businesses_viewmodel.dart';
import 'package:kalenda_mobile/features/onboarding/viewmodel/onboarding_viewmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const salon = SavedBusiness(slug: 'salon', name: 'Szalon');
  const studio = SavedBusiness(slug: 'studio', name: 'Stúdió', logoUrl: 'https://example.com/logo.png');

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('a megnyitott vállalkozás előre kerül, és legfeljebb hat marad', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final viewModel = container.read(savedBusinessesProvider.notifier);

    await container.read(savedBusinessesProvider.future);
    for (var i = 0; i < 8; i++) {
      await viewModel.recordVisit(SavedBusiness(slug: 's$i', name: 'S$i'));
    }
    await viewModel.recordVisit(const SavedBusiness(slug: 's3', name: 'S3'));

    final recent = container.read(savedBusinessesProvider).requireValue.recent;
    expect(recent.length, SavedBusinessesViewModel.maxRecent);
    expect(recent.first.slug, 's3');
    expect(recent.map((b) => b.slug).toSet().length, recent.length, reason: 'nincs duplikátum');
  });

  test('a kedvenc jelölése tartós, és újraindítás után is megvan', () async {
    final first = ProviderContainer();
    await first.read(savedBusinessesProvider.future);
    await first.read(savedBusinessesProvider.notifier).toggleFavorite(salon);
    await first.read(savedBusinessesProvider.notifier).toggleFavorite(studio);
    await first.read(savedBusinessesProvider.notifier).toggleFavorite(salon); // levétel
    first.dispose();

    final second = ProviderContainer();
    addTearDown(second.dispose);
    final saved = await second.read(savedBusinessesProvider.future);

    expect(saved.favorites.map((b) => b.slug), ['studio']);
    expect(saved.favorites.single.logoUrl, 'https://example.com/logo.png');
    expect(saved.isFavorite('salon'), isFalse);
  });

  test('a kedvenc nem ismétlődik a legutóbbiak között', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final viewModel = container.read(savedBusinessesProvider.notifier);

    await container.read(savedBusinessesProvider.future);
    await viewModel.recordVisit(salon);
    await viewModel.recordVisit(studio);
    await viewModel.toggleFavorite(salon);

    final saved = container.read(savedBusinessesProvider).requireValue;
    expect(saved.recentWithoutFavorites.map((b) => b.slug), ['studio']);
  });

  test('a bevezető az első indításkor látszik, a befejezés után soha többé', () async {
    final first = ProviderContainer();
    expect(await first.read(onboardingProvider.future), isTrue);
    await first.read(onboardingProvider.notifier).finish();
    expect(first.read(onboardingProvider).requireValue, isFalse);
    first.dispose();

    final second = ProviderContainer();
    addTearDown(second.dispose);
    expect(await second.read(onboardingProvider.future), isFalse);
  });
}
