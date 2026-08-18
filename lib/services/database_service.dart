import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/scanned_document.dart';

class DatabaseService {
  DatabaseService._();
  static final instance = DatabaseService._();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'documents.db'),
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE documents(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            imagePath TEXT,
            pdfPath TEXT,
            extractedText TEXT,
            createdAt TEXT
          )
        ''');
      },
      version: 1,
    );
  }

  Future<int> insertDocument(ScannedDocument doc) async {
    final db = await database;
    return db.insert('documents', doc.toMap());
  }

  Future<List<ScannedDocument>> getDocuments() async {
    final db = await database;
    final maps = await db.query('documents', orderBy: 'createdAt DESC');
    return maps.map((map) => ScannedDocument.fromMap(map)).toList();
  }

  Future<int> updateDocument(ScannedDocument doc) async {
    final db = await database;
    return db.update('documents', doc.toMap(), where: 'id = ?', whereArgs: [doc.id]);
  }

  Future<int> deleteDocument(int id) async {
    final db = await database;
    return db.delete('documents', where: 'id = ?', whereArgs: [id]);
  }
}
