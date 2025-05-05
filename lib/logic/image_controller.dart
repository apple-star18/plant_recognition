import 'dart:io';
import 'package:flutter/cupertino.dart';

import '../services/camera_service.dart';
import '../services/gallery_service.dart';
import '../services/upload_service.dart';

class ImageController {
  final ValueNotifier<File?> imageFile = ValueNotifier(null);

  Future<File?> captureFromCamera() async {
    final cameraSerice = CameraService();
    final file = await cameraSerice.captureImage();
    imageFile.value = file;
    return file;
  }

  Future<File?> pickFromGallery() async {
    final file = await GalleryService.pickImage();
    imageFile.value = file;
    return file;
  }

  Future<Map<String, dynamic>?> uploadImage() async {
    final file = imageFile.value;
    if (file == null) return null;

    final response = await UploadService.upload(file);
    return response;
  }
}
