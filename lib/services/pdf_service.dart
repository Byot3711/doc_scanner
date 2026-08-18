import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class PdfService {
  static Future<File> createPdf(String imagePath, String text) async {
    final pdf = pw.Document();

    final imageBytes = await File(imagePath).readAsBytes();
    final pdfImage = pw.MemoryImage(imageBytes);

    final page = pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) {
        return pw.Stack(
          children: [
            pw.Positioned.fill(
              child: pw.Image(pdfImage, fit: pw.BoxFit.cover),
            ),
            if (text.isNotEmpty)
              pw.Positioned(
                left: 20,
                top: 20,
                right: 20,
                bottom: 20,
                child: pw.Opacity(
                  opacity: 0.0,
                  child: pw.Text(
                    text,
                    style: pw.TextStyle(fontSize: 12, color: PdfColors.black),
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

  static Future<void> downloadPdf(File pdfFile) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final downloadsDir = Directory('${dir.path}/downloads');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }
      final fileName = 'document_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final destFile = File('${downloadsDir.path}/$fileName');
      await pdfFile.copy(destFile.path);
      await Share.shareXFiles([XFile(destFile.path)], text: 'Scanned document');
    } catch (e) {
      await Share.shareXFiles([XFile(pdfFile.path)], text: 'Scanned document');
    }
  }

  static Future<void> printPdf(File pdfFile) async {
    if (!await pdfFile.exists()) return;
    await Printing.layoutPdf(
      onLayout: (format) async => pdfFile.readAsBytes(),
    );
  }
}
