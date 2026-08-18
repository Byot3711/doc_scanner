import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/ocr_service.dart';
import '../services/pdf_service.dart';
import 'result_screen.dart';

class EditorScreen extends StatefulWidget {
  final File imageFile;
  const EditorScreen({super.key, required this.imageFile});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late File _currentImage;
  bool _isProcessing = false;
  String? _extractedText;
  File? _pdfFile;

  @override
  void initState() {
    super.initState();
    _currentImage = widget.imageFile;
  }

  Future<void> _runOcr() async {
    setState(() => _isProcessing = true);
    try {
      final text = await OcrService.recognizeText(_currentImage.path);
      _extractedText = text;
      if (text.isNotEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Text extracted (${text.length} chars)')),
        );
      }
    } catch (e) {
      debugPrint('OCR error: $e');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _generatePdf() async {
    if (_extractedText == null || _extractedText!.isEmpty) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('No text'),
          content: const Text('Run OCR first to extract text.'),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
        ),
      );
      return;
    }
    setState(() => _isProcessing = true);
    try {
      _pdfFile = await PdfService.createSearchablePdf(_currentImage.path, _extractedText!);
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(
              imageFile: _currentImage,
              extractedText: _extractedText!,
              pdfFile: _pdfFile!,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('PDF error: $e');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Scan'),
      ),
      body: Column(
        children: [
          Expanded(
            child: InteractiveViewer(
              child: Image.file(_currentImage, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: _isProcessing ? null : _runOcr,
                icon: _isProcessing
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.text_fields),
                label: const Text('OCR'),
              ),
              ElevatedButton.icon(
                onPressed: _isProcessing ? null : _generatePdf,
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Generate PDF'),
              ),
            ],
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
