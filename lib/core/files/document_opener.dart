import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

/// Letöltött fájl (pl. számla PDF) megnyitása az eszköz saját megjelenítőjével. Külön osztály, hogy tesztben cserélhető legyen.
class DocumentOpener {
  const DocumentOpener();

  /// Elmenti a fájlt az ideiglenes mappába, és megnyitja. Hamis, ha nincs hozzá alkalmazás.
  Future<bool> open(Uint8List bytes, String fileName) async {
    final dir = await getTemporaryDirectory();
    final safe = fileName.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    final file = File('${dir.path}/$safe');
    await file.writeAsBytes(bytes, flush: true);
    final result = await OpenFilex.open(file.path);
    return result.type == ResultType.done;
  }
}

final documentOpenerProvider = Provider<DocumentOpener>((ref) => const DocumentOpener());
