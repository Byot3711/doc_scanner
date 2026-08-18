import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../models/scanned_document.dart';
import '../services/database_service.dart';

class ResultScreen extends StatefulWidget {
  final File imageFile;
  final String extractedText;
  final File pdfFile;

  const ResultScreen({
    super.key,
    required this.imageFile,
    required this.extractedText,
    required this.pdfFile,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late final TextEditingController _textController;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.extractedText);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _saveDocument() async {
    if (_saved) return;
    final title = 'Scan_${DateTime.now().millisecondsSinceEpoch}';
    final appDir = await getApplicationDocumentsDirectory();
    final savedImage = File('${appDir.path}/images/$title.jpg');
    await savedImage.parent.create(recursive: true);
    await widget.imageFile.copy(savedImage.path);

    final savedPdf = File('${appDir.path}/pdfs/$title.pdf');
    await savedPdf.parent.create(recursive: true);
    await widget.pdfFile.copy(savedPdf.path);

    final doc = ScannedDocument(
      title: title,
      imagePath: savedImage.path,
      pdfPath: savedPdf.path,
      extractedText: _textController.text,
      createdAt: DateTime.now(),
    );
    await DatabaseService.instance.insertDocument(doc);
    setState(() => _saved = true);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Document saved!')),
      );
    }
  }

  Future<void> _sharePdf() async {
    await Share.shareXFiles([XFile(widget.pdfFile.path)], text: 'Scanned document');
  }

  Future<void> _copyText() async {
    await Clipboard.setData(ClipboardData(text: _textController.text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Text copied')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Result'),
        actions: [
          IconButton(icon: const Icon(Icons.share), onPressed: _sharePdf),
          IconButton(icon: const Icon(Icons.save), onPressed: _saveDocument),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              clipBehavior: Clip.antiAlias,
              child: Image.file(widget.imageFile, fit: BoxFit.cover, height: 200),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Extracted Text', style: TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(icon: const Icon(Icons.copy), onPressed: _copyText),
              ],
            ),
            TextField(
              controller: _textController,
              maxLines: 10,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'No text extracted',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _saved ? null : _saveDocument,
              icon: const Icon(Icons.save_alt),
              label: Text(_saved ? 'Saved' : 'Save to History'),
            ),
          ],
        ),
      ),
    );
  }
}
