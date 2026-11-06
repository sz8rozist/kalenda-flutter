import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/local_prefs.dart';
import '../model/saved_business.dart';

/// Kedvenc és legutóbb megnyitott vállalkozások (ViewModel): az eszköz tárolójából olvas és oda ír.
class SavedBusinessesViewModel extends AsyncNotifier<SavedBusinesses> {
  static const _favoritesKey = 'favorite_businesses';
  static const _recentKey = 'recent_businesses';
  static const maxRecent = 6;

  @override
  Future<SavedBusinesses> build() async {
    final prefs = await ref.watch(localPrefsProvider.future);
    if (prefs == null) return const SavedBusinesses();
    return SavedBusinesses(
      favorites: SavedBusiness.decodeList(prefs.getStringList(_favoritesKey)),
      recent: SavedBusiness.decodeList(prefs.getStringList(_recentKey)),
    );
  }

  /// A vállalkozás megnyitásakor: előre kerül a legutóbbiak között.
  Future<void> recordVisit(SavedBusiness business) async {
    final current = await future;
    final recent = [business, ...current.recent.where((b) => b.slug != business.slug)].take(maxRecent).toList();
    // A kedvenc adatait (név, logó) is frissen tartjuk.
    final favorites = [for (final f in current.favorites) f.slug == business.slug ? business : f];
    await _save(SavedBusinesses(favorites: favorites, recent: recent));
  }

  Future<void> toggleFavorite(SavedBusiness business) async {
    final current = await future;
    final favorites = current.isFavorite(business.slug)
        ? [
            for (final f in current.favorites)
              if (f.slug != business.slug) f,
          ]
        : [business, ...current.favorites];
    await _save(SavedBusinesses(favorites: favorites, recent: current.recent));
  }

  Future<void> _save(SavedBusinesses value) async {
    state = AsyncData(value);
    final prefs = await ref.read(localPrefsProvider.future);
    await prefs?.setStringList(_favoritesKey, SavedBusiness.encodeList(value.favorites));
    await prefs?.setStringList(_recentKey, SavedBusiness.encodeList(value.recent));
  }
}

final savedBusinessesProvider = AsyncNotifierProvider<SavedBusinessesViewModel, SavedBusinesses>(SavedBusinessesViewModel.new);
