import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

class PdfService {
  static Future<File> createSearchablePdf(String imagePath, String text) async {
    final pdf = pw.Document();
    final imageBytes = File(imagePath).readAsBytesSync();
    final pdfImage = pw.MemoryImage(imageBytes);

    final page = pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) {
        return pw.Stack(
          children: [
            pw.Positioned.fill(child: pw.Image(pdfImage, fit: pw.BoxFit.cover)),
            pw.Positioned.fill(
              child: pw.Opacity(
                opacity: 0.0,
                child: pw.Padding(
                  padding: const pw.EdgeInsets.all(20),
                  child: pw.Text(
                    text,
                    style: pw.TextStyle(fontSize: 10, color: PdfColors.black),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
    pdf.addPage(page);

    final outputPath = '${Directory.systemTemp.path}/scan_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File(outputPath);
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}
