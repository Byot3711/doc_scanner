import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      final text = await OcrService.recognizeText(_currentImage.path, language: 'eng+ron');
      if (text.startsWith('OCR failed')) {
        if (mounted) Fluttertoast.showToast(msg: 'OCR failed. Try again.');
      } else {
        _extractedText = text;
        if (mounted) Fluttertoast.showToast(msg: 'Text extracted successfully!');
      }
    } catch (e) {
      debugPrint('OCR error: $e');
      if (mounted) Fluttertoast.showToast(msg: 'OCR error: $e');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _generatePdf() async {
    if (_extractedText == null || _extractedText!.isEmpty) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('No Text Extracted'),
            content: const Text('Please run OCR first to extract text from the document.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
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
      if (mounted) Fluttertoast.showToast(msg: 'PDF generation failed: $e');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Scan'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.black,
              child: InteractiveViewer(
                child: Image.file(_currentImage, fit: BoxFit.contain),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _runOcr,
                  icon: _isProcessing
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.text_fields),
                  label: const Text('OCR Text'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _generatePdf,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Generate PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Colors.white,
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
