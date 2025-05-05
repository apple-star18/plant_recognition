import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:plant_recognition/services/permission_service.dart';

class CameraService {
  final _permissionService = PermissionService();

  Future<File?> captureImage() async {
    bool isGranted = await _permissionService.requestCameraPermission();
    if (!isGranted) return null;

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    return picked != null ? File(picked.path) : null;
  }
}
