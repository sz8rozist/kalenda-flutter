import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kalenda_mobile/core/api/api_client.dart';
import 'package:kalenda_mobile/core/api/api_exception.dart';
import 'package:kalenda_mobile/features/booking/data/booking_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Hálózat-szimuláció: a kérések vagy JSON-nal válaszolnak, vagy „nincs hálózat" hibával.
class _Adapter implements HttpClientAdapter {
  bool online = true;
  int status = 200;
  final requests = <String>[];

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    requests.add(options.path);
    if (!online) throw DioException(requestOptions: options, type: DioExceptionType.connectionError);
    final slug = options.path.split('/').last;
    return ResponseBody.fromString(
      jsonEncode({'id': 1, 'name': 'Szalon $slug', 'slug': slug, 'services': [], 'staff': []}),
      status,
      headers: {Headers.contentTypeHeader: ['application/json']},
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late _Adapter adapter;
  late BookingRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    adapter = _Adapter();
    final api = ApiClient(readCustomerToken: () async => null, readStaffToken: () async => null);
    api.dio.httpClientAdapter = adapter;
    final prefs = await SharedPreferences.getInstance();
    repository = BookingRepository(api, () async => prefs);
  });

  test('hálózat nélkül az utoljára látott vállalkozás-oldal jelenik meg', () async {
    final online = await repository.business('szalon');
    expect(online.name, 'Szalon szalon');

    adapter.online = false;
    final offline = await repository.business('szalon');

    expect(offline.name, 'Szalon szalon');
  });

  test('ha még nem láttuk az oldalt, a hálózati hiba megmarad', () async {
    adapter.online = false;

    expect(() => repository.business('ismeretlen'), throwsA(isA<ApiException>().having((e) => e.isNetwork, 'isNetwork', isTrue)));
  });

  test('a szerver hibájánál (nem hálózati) nem a régi adatot adja vissza', () async {
    await repository.business('szalon');
    adapter.status = 404;

    expect(() => repository.business('szalon'), throwsA(isA<ApiException>()));
  });

  test('legfeljebb tíz vállalkozást tart meg, a legrégebbit törli', () async {
    for (var i = 0; i < 12; i++) {
      await repository.business('v$i');
    }
    adapter.online = false;

    expect((await repository.business('v11')).name, 'Szalon v11');
    expect((await repository.business('v2')).name, 'Szalon v2');
    expect(() => repository.business('v0'), throwsA(isA<ApiException>()));
  });
}
