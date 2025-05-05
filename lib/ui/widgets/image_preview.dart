import 'dart:io';
import 'package:flutter/material.dart';

class ImagePreview extends StatelessWidget {
  final File? imageFile;

  const ImagePreview({super.key, this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: imageFile != null
          ? Image.file(imageFile!, fit: BoxFit.contain)
          : const Center(child: Text('이미지를 선택해주세요')),
    );
  }
}
