import 'dart:io';
import 'package:flutter/material.dart';
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
  File? _croppedFile;
  bool _isProcessing = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _autoCrop();
  }

  Future<void> _autoCrop() async {
    try {
      final bytes = await File(widget.imagePath).readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) {
        setState(() {
          _isProcessing = false;
          _error = 'Invalid image';
        });
        return;
      }

      final width = decoded.width;
      final height = decoded.height;
      final cropWidth = (width * 0.8).toInt();
      final cropHeight = (height * 0.8).toInt();
      final left = (width - cropWidth) ~/ 2;
      final top = (height - cropHeight) ~/ 2;

      final cropped = img.copyCrop(
        decoded,
        x: left,
        y: top,
        width: cropWidth,
        height: cropHeight,
      );
      final outputPath = '${Directory.systemTemp.path}/auto_crop_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final encoded = img.encodeJpg(cropped, quality: 95);
      await File(outputPath).writeAsBytes(encoded);

      setState(() {
        _croppedFile = File(outputPath);
        _isProcessing = false;
      });
    } catch (e) {
      debugPrint('Crop error: $e');
      setState(() {
        _isProcessing = false;
        _error = 'Auto-crop failed: $e';
      });
    }
  }

  void _onDone() {
    if (_croppedFile != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => EditorScreen(imageFile: _croppedFile!),
        ),
      );
    } else {
      Fluttertoast.showToast(msg: 'Image not ready');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview'),
        actions: [
          TextButton(
            onPressed: _isProcessing ? null : _onDone,
            child: const Text('Done', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Center(
        child: _isProcessing
            ? const CircularProgressIndicator()
            : _croppedFile != null
                ? Image.file(_croppedFile!, fit: BoxFit.contain)
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditorScreen(imageFile: File(widget.imagePath)),
                            ),
                          );
                        },
                        child: const Text('Use Original Image'),
                      ),
                    ],
                  ),
      ),
    );
  }
}
