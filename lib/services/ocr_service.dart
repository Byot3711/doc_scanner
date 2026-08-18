import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  static Future<String> recognizeText(String imagePath, {String language = 'eng'}) async {
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final result = await textRecognizer.processImage(inputImage);
      return result.text;
    } catch (e) {
      return 'OCR failed: $e';
    } finally {
      await textRecognizer.close();
    }
  }
}
