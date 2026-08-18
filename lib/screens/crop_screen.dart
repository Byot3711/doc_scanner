import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'editor_screen.dart';

class CropScreen extends StatefulWidget {
  final String imagePath;
  const CropScreen({super.key, required this.imagePath});

  @override
  State<CropScreen> createState() => _CropScreenState();
}

class _CropScreenState extends State<CropScreen> {
  Future<void> _cropImage() async {
    try {
      final cropped = await ImageCropper().cropImage(
        sourcePath: widget.imagePath,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Document',
            lockAspectRatio: false,
            hideBottomControls: false,
          ),
          IOSUiSettings(
            title: 'Crop',
          ),
        ],
      );

      if (cropped != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EditorScreen(imageFile: File(cropped.path)),
          ),
        );
      }
    } catch (e) {
      debugPrint('Crop error: $e');
      if (mounted) Fluttertoast.showToast(msg: 'Crop failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Document'),
        actions: [
          TextButton(
            onPressed: _cropImage,
            child: const Text('Done', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
      body: Center(
        child: Image.file(File(widget.imagePath), fit: BoxFit.contain),
      ),
    );
  }
}
