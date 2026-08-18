# Doc Scanner Pro

Aplicație Android (Flutter) pentru scanarea documentelor direct de pe telefon: captură foto sau import din galerie, extragere text prin OCR (Google ML Kit), export în PDF cu strat de text căutabil, istoric al documentelor scanate și interfață modernă, tip Microsoft Lens / Adobe Scan.

## Funcționalități

- **Scanare document** — captură cu cameră (preview live, flash) sau selectare imagine din galerie
- **OCR** — extragere text din imagine folosind Google ML Kit Text Recognition (rapid, on-device, fără fișiere de configurare descărcate manual)
- **Editare text** — text extras editabil, copiere rapidă în clipboard
- **Export PDF** — generare PDF cu imaginea documentului și textul extras suprapus (căutabil), descărcare/printare și trimitere (share) direct din aplicație
- **Istoric** — toate documentele scanate salvate local (SQLite), cu ecran de detalii pentru fiecare (imagine, text, acțiuni PDF)
- **Temă** — mod luminos/întunecat, design Material 3

## Stack tehnic

- [Flutter](https://flutter.dev/) / Dart
- [camera](https://pub.dev/packages/camera) — captură foto
- [image_picker](https://pub.dev/packages/image_picker) — selectare din galerie
- [google_mlkit_text_recognition](https://pub.dev/packages/google_mlkit_text_recognition) — OCR
- [pdf](https://pub.dev/packages/pdf) / [printing](https://pub.dev/packages/printing) — generare și export PDF
- [sqflite](https://pub.dev/packages/sqflite) — bază de date locală pentru istoric
- [provider](https://pub.dev/packages/provider) — gestionare temă
- [share_plus](https://pub.dev/packages/share_plus) — partajare fișiere

## Structură proiect

```
lib/
├── main.dart                       # entry point, temă, navigație principală
├── models/
│   └── scanned_document.dart       # model document scanat
├── services/
│   ├── database_service.dart       # persistență SQLite
│   ├── camera_service.dart         # control cameră
│   ├── ocr_service.dart            # recunoaștere text (ML Kit)
│   └── pdf_service.dart            # generare/printare PDF
├── screens/
│   ├── home_screen.dart            # ecran scanare (cameră + galerie)
│   ├── editor_screen.dart          # editare imagine, rulare OCR
│   ├── result_screen.dart          # rezultat OCR, salvare, share
│   ├── document_detail_screen.dart # detalii document salvat
│   ├── history_screen.dart         # istoric documente
│   └── settings_screen.dart        # setări (temă)
└── widgets/
    └── app_logo.dart                # logo aplicație
```

## Instalare (APK)

Cel mai recent APK compilat este disponibil în secțiunea [Releases](https://github.com/Byot3711/doc_scanner/releases). Descarcă `app-release.apk` pe telefon și permite instalarea din surse necunoscute ("Install unknown apps") pentru a-l rula.

## Build local

```bash
flutter pub get
flutter build apk --release
```

APK-ul rezultat se găsește în `build/app/outputs/flutter-apk/app-release.apk`.

## Autor

**Valentin Constantinescu**

Repo: [https://github.com/Byot3711/doc_scanner](https://github.com/Byot3711/doc_scanner)
