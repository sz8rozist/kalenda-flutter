/// Térkép-hivatkozások a cím alapján. A Google Térkép-hivatkozás Androidon és iOS-en is megnyitja a telepített térképalkalmazást
/// (vagy a böngészőt), ezért külön platformágak nélkül is működik.
class MapLinks {
  MapLinks._();

  /// A cím megjelenítése a térképen.
  static Uri search(String address) => Uri.https('www.google.com', '/maps/search/', {'api': '1', 'query': address});

  /// Útvonaltervezés a címhez (az indulási pontot a térképalkalmazás a készülék helyéből veszi).
  static Uri directions(String address) => Uri.https('www.google.com', '/maps/dir/', {'api': '1', 'destination': address});
}
