import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Megosztás a rendszer saját megosztó-lapjával. Külön osztály, hogy tesztben cserélhető legyen.
class ShareGateway {
  const ShareGateway();

  /// PNG-kép megosztása (pl. a QR-plakát), opcionális kísérő szöveggel.
  Future<void> shareImage(Uint8List png, String fileName, {String? text}) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(png, flush: true);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'image/png')],
        text: text,
      ),
    );
  }

  Future<void> shareText(String text) => SharePlus.instance.share(ShareParams(text: text));
}

final shareGatewayProvider = Provider<ShareGateway>((ref) => const ShareGateway());
