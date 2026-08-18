import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/camera_service.dart';
import 'crop_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  CameraController? _cameraController;
  bool _isCameraReady = false;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _requestCameraPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    CameraService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _setupCamera();
    }
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      await _setupCamera();
    } else {
      if (mounted) Fluttertoast.showToast(msg: 'Camera permission required');
    }
  }

  Future<void> _setupCamera() async {
    try {
      await CameraService.initialize();
      if (_cameraController != null) {
        await _cameraController!.dispose();
      }
      _cameraController = await CameraService.createController(
        resolution: ResolutionPreset.veryHigh,
      );
      if (_cameraController != null) {
        if (mounted) setState(() => _isCameraReady = true);
      }
    } catch (e) {
      debugPrint('Camera error: $e');
    }
  }

  Future<void> _capture() async {
    if (!_isCameraReady || _isCapturing) return;
    setState(() => _isCapturing = true);
    try {
      final imagePath = await CameraService.takePicture();
      if (imagePath != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CropScreen(imagePath: imagePath),
          ),
        );
      }
    } catch (e) {
      debugPrint('Capture error: $e');
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 100);
    if (pickedFile != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CropScreen(imagePath: pickedFile.path),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.document_scanner, color: Colors.white, size: 24),
            SizedBox(width: 8),
            Text('Doc Scanner Pro', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
          ],
        ),
        backgroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on, color: Colors.white),
            onPressed: () {
              if (_cameraController != null) {
                _cameraController!.setFlashMode(
                  _cameraController!.value.flashMode == FlashMode.off
                      ? FlashMode.torch
                      : FlashMode.off,
                );
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_isCameraReady && _cameraController != null)
            CameraPreview(_cameraController!)
          else
            const Center(child: CircularProgressIndicator()),

          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  height: MediaQuery.of(context).size.width * 1.1,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 1.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _pickFromGallery,
                  icon: const Icon(Icons.photo_library, size: 18),
                  label: const Text('Gallery', style: TextStyle(fontSize: 14)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
                const SizedBox(width: 24),
                FloatingActionButton(
                  heroTag: 'capture',
                  onPressed: _isCapturing ? null : _capture,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  child: _isCapturing
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                      : const DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
                            ],
                          ),
                          child: SizedBox(width: 56, height: 56),
                        ),
                ),
                const SizedBox(width: 76),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
