import 'dart:convert';

/// Egy vállalkozás, amit az ügyfél kedvencnek jelölt vagy nemrég megnyitott (csak az eszközön tárolva).
class SavedBusiness {
  const SavedBusiness({required this.slug, required this.name, this.logoUrl});

  final String slug;
  final String name;
  final String? logoUrl;

  Map<String, Object?> toJson() => {'slug': slug, 'name': name, 'logo': logoUrl};

  factory SavedBusiness.fromJson(Map<String, dynamic> j) =>
      SavedBusiness(slug: j['slug'] as String, name: j['name'] as String, logoUrl: j['logo'] as String?);

  static List<SavedBusiness> decodeList(List<String>? raw) {
    final result = <SavedBusiness>[];
    for (final item in raw ?? const <String>[]) {
      try {
        result.add(SavedBusiness.fromJson(jsonDecode(item) as Map<String, dynamic>));
      } catch (_) {
        // Sérült bejegyzés: kihagyjuk.
      }
    }
    return result;
  }

  static List<String> encodeList(List<SavedBusiness> items) => [for (final i in items) jsonEncode(i.toJson())];
}

/// A kedvencek és a legutóbb megnyitott vállalkozások.
class SavedBusinesses {
  const SavedBusinesses({this.favorites = const [], this.recent = const []});

  final List<SavedBusiness> favorites;
  final List<SavedBusiness> recent;

  bool isFavorite(String slug) => favorites.any((b) => b.slug == slug);

  /// A „Legutóbbiak" listában nem ismételjük meg a kedvenceket.
  List<SavedBusiness> get recentWithoutFavorites => [
    for (final b in recent)
      if (!isFavorite(b.slug)) b,
  ];
}
