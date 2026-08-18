import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/camera_service.dart';
import '../services/edge_detection_service.dart';
import 'editor_screen.dart';

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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera permission denied')),
        );
      }
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
        if (mounted) {
          setState(() => _isCameraReady = true);
        }
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
        final croppedFile = await EdgeDetectionService.autoCrop(imagePath);
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EditorScreen(imageFile: croppedFile),
            ),
          );
        }
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
      final croppedFile = await EdgeDetectionService.autoCrop(pickedFile.path);
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EditorScreen(imageFile: croppedFile),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doc Scanner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
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
                  height: MediaQuery.of(context).size.width * 1.2,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white54, width: 2),
                    borderRadius: BorderRadius.circular(16),
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
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  heroTag: 'gallery',
                  onPressed: _pickFromGallery,
                  child: const Icon(Icons.photo_library),
                ),
                FloatingActionButton.large(
                  heroTag: 'capture',
                  onPressed: _isCapturing ? null : _capture,
                  child: _isCapturing
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Icon(Icons.camera, size: 40),
                ),
              ],
            ),
          ).animate().fadeIn().slideY(begin: 0.2),
        ],
      ),
    );
  }
}
