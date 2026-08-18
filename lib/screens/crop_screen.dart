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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _cropImage());
  }

  Future<void> _cropImage() async {
    try {
      final cropped = await ImageCropper().cropImage(
        sourcePath: widget.imagePath,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Document',
            toolbarColor: Colors.black87,
            toolbarWidgetColor: Colors.white,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Crop',
          ),
        ],
      );

      if (mounted) {
        final resultFile = cropped != null ? File(cropped.path) : File(widget.imagePath);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => EditorScreen(imageFile: resultFile),
          ),
        );
      }
    } catch (e) {
      debugPrint('Crop error: $e');
      if (mounted) {
        Fluttertoast.showToast(msg: 'Crop failed, using original');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => EditorScreen(imageFile: File(widget.imagePath)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
