# Doc Scanner Pro

An Android app (Flutter) for scanning documents directly from your phone: photo capture or gallery import, text extraction via OCR (Google ML Kit), PDF export with a searchable text layer, scan history, and a modern interface in the style of Microsoft Lens / Adobe Scan.

## Features

- **Document scanning** — capture with the camera (live preview, flash) or pick an image from the gallery
- **OCR** — text extraction from the image using Google ML Kit Text Recognition (fast, on-device, no manually downloaded config files)
- **Text editing** — extracted text is editable, with quick copy to clipboard
- **PDF export** — generate a PDF with the document image and the extracted text overlaid (searchable); separate **Download PDF** and **Print PDF** actions, plus share directly from the app
- **History** — every scanned document is saved locally (SQLite), with a detail screen for each one (image, text, PDF actions)
- **Theme** — light/dark mode, Material 3 design

## Tech stack

- [Flutter](https://flutter.dev/) / Dart
- [camera](https://pub.dev/packages/camera) — photo capture
- [image_picker](https://pub.dev/packages/image_picker) — gallery selection
- [google_mlkit_text_recognition](https://pub.dev/packages/google_mlkit_text_recognition) — OCR
- [pdf](https://pub.dev/packages/pdf) / [printing](https://pub.dev/packages/printing) — PDF generation and export
- [sqflite](https://pub.dev/packages/sqflite) — local database for history
- [provider](https://pub.dev/packages/provider) — theme management
- [share_plus](https://pub.dev/packages/share_plus) — file sharing

## Project structure

```
lib/
├── main.dart                       # entry point, theme, main navigation
├── models/
│   └── document.dart               # scanned document model
├── services/
│   ├── database_service.dart       # SQLite persistence
│   ├── camera_service.dart         # camera control
│   ├── ocr_service.dart            # text recognition (ML Kit)
│   └── pdf_service.dart            # PDF generation/download/print
└── screens/
    ├── home_screen.dart            # scan screen (camera + gallery)
    ├── editor_screen.dart          # image editing, run OCR
    ├── result_screen.dart          # OCR result, save, share
    ├── document_detail_screen.dart # saved document details
    ├── history_screen.dart         # document history
    └── settings_screen.dart        # settings (theme, about)
```

## Install (APK)

The latest built APK is available in the [Releases](https://github.com/Byot3711/doc_scanner/releases) section. Download `app-release.apk` to your phone and allow installation from unknown sources ("Install unknown apps") to run it.

## Build locally

```bash
flutter pub get
flutter build apk --release
```

The resulting APK is located at `build/app/outputs/flutter-apk/app-release.apk`.

## Author

**Valentin Constantinescu**

Repo: [https://github.com/Byot3711/doc_scanner](https://github.com/Byot3711/doc_scanner)
