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

    if (!mounted) return;
    Navigator.of(context).pop();

    if (result == null) {
      showUploadToast('No response from server.', false);
      return;
    }

    final status = result['status'];
    if (status == 'success') {
      final data = result['data'];
      if (data != null && data is Map<String, dynamic>) {
        _showPlantDetailsDialog(data);
      } else {
        showUploadToast('Upload succeeded, but data is missing.', false);
      }
    } else {
      final errorMessage = result['message'] ?? 'Upload failed.';
      showUploadToast(errorMessage, false);
    }
  }

  void showUploadToast(String message, bool isSuccess) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: isSuccess ? Colors.green : Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void _showPlantDetailsDialog(Map<String, dynamic> details) {
    final resultDetails = details['resultDetails'] ?? {};
    final commonNames = (resultDetails['common_names'] as List?)?.cast<String>() ?? [];
    final taxonomy = (resultDetails['taxonomy'] as Map?) ?? {};
    final description = resultDetails['description']?['value'] ?? 'No information';
    final url = resultDetails['url'] ?? 'No link';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🌿 Plant details information'),
        content: SingleChildScrollView(
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('📛 Normal Name', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(commonNames.join(', ')),
                  const SizedBox(height: 10),
                  Text('📖 Description', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(description),
                  const SizedBox(height: 10),
                  Text('🔬 Taxonomy', style: TextStyle(fontWeight: FontWeight.bold)),
                  ...taxonomy.entries.map((e) => Text('${e.key}: ${e.value}')),
                  const SizedBox(height: 10),
                  Text('🔗 Wiki link', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(url, style: const TextStyle(color: Colors.blue)),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
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
