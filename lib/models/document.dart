class ScannedDocument {
  final int? id;
  final String title;
  final String imagePath;
  final String pdfPath;
  final String extractedText;
  final DateTime createdAt;

  ScannedDocument({
    this.id,
    required this.title,
    required this.imagePath,
    required this.pdfPath,
    required this.extractedText,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'imagePath': imagePath,
    'pdfPath': pdfPath,
    'extractedText': extractedText,
    'createdAt': createdAt.toIso8601String(),
  };

  factory ScannedDocument.fromMap(Map<String, dynamic> map) => ScannedDocument(
    id: map['id'],
    title: map['title'],
    imagePath: map['imagePath'],
    pdfPath: map['pdfPath'],
    extractedText: map['extractedText'],
    createdAt: DateTime.parse(map['createdAt']),
  );
}
