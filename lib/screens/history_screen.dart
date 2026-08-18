import 'dart:io';
import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/scanned_document.dart';

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
    await DatabaseService.instance.deleteDocument(doc.id!);
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
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
            return const Center(child: Text('No scanned documents yet.'));
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
                  background: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete, color: Colors.white)),
                  onDismissed: (_) => _deleteDocument(doc),
                  child: ListTile(
                    leading: Image.file(File(doc.imagePath), width: 50, height: 70, fit: BoxFit.cover),
                    title: Text(doc.title),
                    subtitle: Text('${doc.extractedText.length} chars · ${_formatDate(doc.createdAt)}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.open_in_new),
                      onPressed: () {},
                    ),
                    onTap: () {},
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
