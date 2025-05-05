import 'dart:io';
import 'package:image_picker/image_picker.dart';

class GalleryService {
  static Future<File?> pickImage() async {
    final XFile? result = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (result != null) {
      return File(result.path); // ✅ XFile에서 직접 path 사용
    }

    return null;
  }

}
