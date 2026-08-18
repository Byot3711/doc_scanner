import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image/image.dart' as img;
import 'package:fluttertoast/fluttertoast.dart';
import 'editor_screen.dart';

class CropScreen extends StatefulWidget {
  final String imagePath;
  const CropScreen({super.key, required this.imagePath});

  @override
  State<CropScreen> createState() => _CropScreenState();
}

class _CropScreenState extends State<CropScreen> {
  bool _isProcessing = false;

  Future<void> _autoCrop() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      final bytes = await File(widget.imagePath).readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) {
        if (mounted) Fluttertoast.showToast(msg: 'Could not read image');
        return;
      }

      final cropWidth = (decoded.width * 0.8).round();
      final cropHeight = (decoded.height * 0.8).round();
      final left = ((decoded.width - cropWidth) / 2).round();
      final top = ((decoded.height - cropHeight) / 2).round();

      final cropped = img.copyCrop(
        decoded,
        x: left,
        y: top,
        width: cropWidth,
        height: cropHeight,
      );

      final outputPath = '${Directory.systemTemp.path}/auto_crop_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(img.encodeJpg(cropped, quality: 90));

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EditorScreen(imageFile: outputFile),
          ),
        );
      }
    } catch (e) {
      debugPrint('Auto crop error: $e');
      if (mounted) Fluttertoast.showToast(msg: 'Auto crop failed');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EditorScreen(imageFile: resultFile),
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
            onPressed: _isProcessing ? null : _autoCrop,
            child: _isProcessing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue),
                  )
                : const Text('Auto', style: TextStyle(color: Colors.blue)),
          ),
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
