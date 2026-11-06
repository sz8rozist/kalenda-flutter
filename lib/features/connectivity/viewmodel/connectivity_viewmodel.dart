import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Van-e hálózat az eszközön. Ha nem tudjuk megállapítani (hiba, teszt), online-nak vesszük.
final onlineProvider = StreamProvider<bool>((ref) async* {
  bool online(List<ConnectivityResult> r) => !(r.isNotEmpty && r.every((e) => e == ConnectivityResult.none));
  try {
    final connectivity = Connectivity();
    yield online(await connectivity.checkConnectivity());
    yield* connectivity.onConnectivityChanged.map(online);
  } catch (_) {
    yield true;
  }
});
