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
      final text = await OcrService.recognizeText(_currentImage.path);
      if (text.isEmpty) {
        if (mounted) Fluttertoast.showToast(msg: 'No text detected. Generating PDF with image only.');
      } else {
        _extractedText = text;
        if (mounted) Fluttertoast.showToast(msg: 'Text extracted!');
      }
    } catch (e) {
      debugPrint('OCR error: $e');
      if (mounted) Fluttertoast.showToast(msg: 'OCR error');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _generatePdf() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      if (!await _currentImage.exists()) {
        if (mounted) Fluttertoast.showToast(msg: 'Image file not found');
        return;
      }

      _pdfFile = await PdfService.createPdf(_currentImage.path, _extractedText ?? '');

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(
              imageFile: _currentImage,
              extractedText: _extractedText ?? '',
              pdfFile: _pdfFile!,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('PDF error: $e');
      if (mounted) Fluttertoast.showToast(msg: 'PDF failed: $e');
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
              child: Image.file(_currentImage, fit: BoxFit.contain),
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
            child: Column(
              children: [
                if (_extractedText != null && _extractedText!.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          '${_extractedText!.length} chars extracted',
                          style: const TextStyle(fontSize: 12, color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _runOcr,
                      icon: _isProcessing
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.text_fields, size: 18),
                      label: const Text('Extract Text'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _generatePdf,
                      icon: const Icon(Icons.picture_as_pdf, size: 18),
                      label: const Text('Create PDF'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
