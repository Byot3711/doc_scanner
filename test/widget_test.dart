// Basic smoke test for Doc Scanner Pro.

import 'package:flutter_test/flutter_test.dart';

import 'package:doc_scanner_pro/main.dart';

void main() {
  testWidgets('App builds without throwing', (WidgetTester tester) async {
    await tester.pumpWidget(const DocScannerProApp());
    await tester.pump();
  });
}
