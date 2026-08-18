import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  static Future<String> recognizeText(String imagePath, {String language = 'eng+ron'}) async {
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final input = InputImage.fromFilePath(imagePath);
      final result = await recognizer.processImage(input);
      return result.text;
    } catch (e) {
      return 'OCR failed: $e';
    } finally {
      await recognizer.close();
    }
  }
}
