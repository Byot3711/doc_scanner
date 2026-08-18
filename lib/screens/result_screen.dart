import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../models/scanned_document.dart';
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
    if (mounted) {
      Fluttertoast.showToast(msg: 'Document saved to history!');
    }
  }

  Future<void> _sharePdf() async {
    await Share.shareXFiles([XFile(widget.pdfFile.path)], text: 'Scanned document');
  }

  Future<void> _copyText() async {
    await Clipboard.setData(ClipboardData(text: _textController.text));
    if (mounted) {
      Fluttertoast.showToast(msg: 'Text copied to clipboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Result'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => PdfService.printPdf(widget.pdfFile),
            tooltip: 'Download PDF',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _sharePdf,
            tooltip: 'Share PDF',
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveDocument,
            tooltip: 'Save to History',
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
              child: Image.file(widget.imageFile, fit: BoxFit.cover, height: 250),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Extracted Text', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: _copyText,
                  tooltip: 'Copy Text',
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _textController,
              maxLines: null,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'No text extracted',
                contentPadding: EdgeInsets.all(12),
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
              ),
            ),
            const SizedBox(height: 16),
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
              label: const Text('Open Full Document View'),
            ),
          ],
        ),
      ),
    );
  }
}
