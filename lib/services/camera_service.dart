import 'package:camera/camera.dart';

class CameraService {
  static CameraController? _controller;
  static List<CameraDescription>? cameras;

  static Future<void> initialize() async {
    cameras = await availableCameras();
  }

  static Future<CameraController?> createController({ResolutionPreset resolution = ResolutionPreset.veryHigh}) async {
    if (cameras == null || cameras!.isEmpty) return null;
    _controller = CameraController(
      cameras!.firstWhere((c) => c.lensDirection == CameraLensDirection.back,
          orElse: () => cameras!.first),
      resolution,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    await _controller!.initialize();
    return _controller;
  }

  static Future<String?> takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return null;
    final image = await _controller!.takePicture();
    return image.path;
  }

  static void dispose() {
    _controller?.dispose();
    _controller = null;
  }
}
