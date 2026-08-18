import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';
import '../services/database_service.dart';
import '../models/document.dart';
import 'document_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<ScannedDocument>> _docsFuture;

  @override
  void initState() {
    super.initState();
    _docsFuture = DatabaseService.instance.getDocuments();
  }

  Future<void> _refresh() async {
    setState(() {
      _docsFuture = DatabaseService.instance.getDocuments();
    });
  }

  Future<void> _deleteDocument(ScannedDocument doc) async {
    try {
      await File(doc.imagePath).delete();
      await File(doc.pdfPath).delete();
    } catch (e) {
      debugPrint('Error deleting files: $e');
    }
    await DatabaseService.instance.deleteDocument(doc.id!);
    _refresh();
    if (mounted) Fluttertoast.showToast(msg: 'Document deleted');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: FutureBuilder<List<ScannedDocument>>(
        future: _docsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final docs = snapshot.data ?? [];
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.history_toggle_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No scanned documents yet.', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go to Scan'),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final doc = docs[index];
                return Dismissible(
                  key: Key(doc.id.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) => _deleteDocument(doc),
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(doc.imagePath),
                          width: 60,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(doc.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(
                        '${doc.extractedText.length} chars · ${_formatDate(doc.createdAt)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DocumentDetailScreen(
                              imageFile: File(doc.imagePath),
                              extractedText: doc.extractedText,
                              pdfFile: File(doc.pdfPath),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }
}
