import 'package:flutter_test/flutter_test.dart';
import 'package:kalenda_mobile/core/maps/map_links.dart';

void main() {
  test('a térkép- és útvonal-hivatkozás a címet kódolva viszi tovább', () {
    final search = MapLinks.search('Fő utca 1, Budapest');
    final directions = MapLinks.directions('Fő utca 1, Budapest');

    expect(search.host, 'www.google.com');
    expect(search.path, '/maps/search/');
    expect(search.queryParameters['query'], 'Fő utca 1, Budapest');
    expect(directions.path, '/maps/dir/');
    expect(directions.queryParameters['destination'], 'Fő utca 1, Budapest');
    expect(directions.queryParameters['api'], '1');
  });
}
