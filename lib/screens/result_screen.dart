import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import '../models/document.dart';
import '../services/database_service.dart';
import '../services/pdf_service.dart';
import 'document_detail_screen.dart';

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
    final title = 'Scan_${DateTime.now().toString().replaceAll(':', '-').substring(0, 19)}';
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
    if (mounted) Fluttertoast.showToast(msg: 'Saved to history!');
  }

  Future<void> _copyText() async {
    await Clipboard.setData(ClipboardData(text: _textController.text));
    if (mounted) Fluttertoast.showToast(msg: 'Text copied');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Result'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => PdfService.downloadPdf(widget.pdfFile),
            tooltip: 'Download',
          ),
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () {
              if (widget.pdfFile.existsSync()) {
                PdfService.printPdf(widget.pdfFile);
              } else {
                Fluttertoast.showToast(msg: 'PDF not found');
              }
            },
            tooltip: 'Print',
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveDocument,
            tooltip: 'Save',
          ),
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
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('Extracted Text', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 20),
                          onPressed: _copyText,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_textController.text.isEmpty)
                      const Text(
                        'No text extracted from this document.',
                        style: TextStyle(color: Colors.grey),
                      )
                    else
                      Text(
                        _textController.text,
                        style: const TextStyle(fontSize: 14, height: 1.5),
                        maxLines: 10,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _textController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                        hintText: 'Edit text...',
                        contentPadding: EdgeInsets.all(8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _saved ? null : _saveDocument,
              icon: const Icon(Icons.save_alt),
              label: Text(_saved ? 'Saved ✓' : 'Save to History'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _saved ? Colors.grey : Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DocumentDetailScreen(
                      imageFile: widget.imageFile,
                      extractedText: _textController.text,
                      pdfFile: widget.pdfFile,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.open_in_new),
              label: const Text('Full Document View'),
            ),
          ],
        ),
      ),
    );
  }
}
