import 'dart:io';

import 'package:flutter/material.dart';

class ScreenshotPreview extends StatelessWidget {
  const ScreenshotPreview({super.key, required this.imageFile});

  final File? imageFile;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: AspectRatio(
        aspectRatio: 9 / 12,
        child: imageFile == null
            ? const Center(
                child: Text('Selected screenshot preview will appear here.'),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(imageFile!, fit: BoxFit.contain),
              ),
      ),
    );
  }
}
