import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/camera_service.dart';
import 'crop_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  CameraController? _cameraController;
  bool _isCameraReady = false;
  bool _isCapturing = false;
  bool _cameraError = false; // NEW

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
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _setupCamera() async {
    try {
      if (_cameraController != null) {
        await _cameraController!.dispose();
      }
      _cameraController = await CameraService.createController(
        resolution: ResolutionPreset.veryHigh,
      );
      if (_cameraController != null && mounted) {
        setState(() => _isCameraReady = true);
      } else {
        setState(() => _cameraError = true);
      }
    } catch (e) {
      debugPrint('Camera error: $e');
      if (mounted) {
        setState(() => _cameraError = true);
        Fluttertoast.showToast(msg: 'Camera error: $e');
      }
    }
  }

  Future<void> _capture() async {
    if (!_isCameraReady || _isCapturing) return;
    setState(() => _isCapturing = true);
    try {
      final imagePath = await CameraService.takePicture();
      if (imagePath != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => CropScreen(imagePath: imagePath),
          ),
        );
      }
    } catch (e) {
      debugPrint('Capture error: $e');
      if (mounted) Fluttertoast.showToast(msg: 'Capture failed');
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Document'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _cameraError
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Camera failed to start'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _cameraError = false;
                        _isCameraReady = false;
                      });
                      _setupCamera();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : Stack(
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
                      FloatingActionButton(
                        heroTag: 'capture',
                        onPressed: _isCapturing ? null : _capture,
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        child: _isCapturing
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                            : Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
                                  ],
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
