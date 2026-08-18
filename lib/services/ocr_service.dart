import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  static Future<String> recognizeText(String imagePath) async {
    try {
      final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final input = InputImage.fromFilePath(imagePath);
      final text = await recognizer.processImage(input);
      recognizer.close();
      return text.text;
    } catch (e) {
      return '';
    }
  }
}
