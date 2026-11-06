import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

/// Kép kiválasztása a galériából. Külön osztály, hogy tesztben cserélhető legyen.
class ImagePickerGateway {
  const ImagePickerGateway();

  /// A kiválasztott kép elérési útja, vagy `null`, ha a felhasználó mégse választott.
  Future<String?> pickFromGallery() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 2000, imageQuality: 85);
    return picked?.path;
  }
}

final imagePickerProvider = Provider<ImagePickerGateway>((ref) => const ImagePickerGateway());
