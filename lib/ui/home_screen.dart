import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../logic/image_controller.dart';
import 'widgets/image_preview.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImageController _controller = ImageController();
  File? imageFile;

  void _pickFromCamera() async {
    imageFile = await _controller.captureFromCamera();
  }

  void _pickFromGallery() async {
    imageFile = await _controller.pickFromGallery();
  }

  void _uploadToServer() async {
    final file = _controller.imageFile.value;
    if (file == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final result = await _controller.uploadImage();
    Navigator.of(context).pop();
    showUploadToast(result);

  }

  void showUploadToast(bool isSuccess) {
    Fluttertoast.showToast(
      msg: isSuccess
          ? "Upload successful!"
          : "Upload failed. Please try again.",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: isSuccess ? Colors.green : Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Image')),
      body: Column(
        children: [
          Expanded(
            child: ValueListenableBuilder<File?>(
              valueListenable: _controller.imageFile,
              builder: (context, file, _) {
                return file != null
                    ? ImagePreview(imageFile: file)
                    : const Center(child: Text("Select image"));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: _pickFromCamera,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Capture'),
                ),
                ElevatedButton.icon(
                  onPressed: _pickFromGallery,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                ),
                ElevatedButton.icon(
                  onPressed: _uploadToServer,
                  icon: const Icon(Icons.cloud_upload),
                  label: const Text('Upload'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
