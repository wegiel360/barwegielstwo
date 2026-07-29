# Bar Węgielstwo — Flutter Apps + Flask Backend

System zamówień restauracji z 2 aplikacjami Flutter + backend Flask z Firebase.

## Struktura projektu

```
BarWegielstwoFlutterDart/
├── bar_wegielstwo_order/          # App 1 — Kiosk zamówień (tylko Android)
├── bar_wegielstwo_board/          # App 2 — Tablica zamówień (Windows/Linux)
├── build_all.ps1                  # Skrypt budujący Windows (board) + Android (order)
├── build_linux.sh                 # Skrypt budujący Linux AppImage (board)
├── installer/
│   ├── bar_wegielstwo.iss         # Inno Setup script (instalator board na Windows)
│   ├── build_installer.ps1        # Skrypt budujący instalator
│   └── generate_icons.py          # Skrypt generujący ikony (ICO + Android mipmap)
├── BarWegielstwoPythonFlask/       # Backend Flask + strona WWW
│   ├── flask_app.py               # Główna aplikacja Flask
│   ├── firebase_db.py             # Warstwa danych (Firestore z fallbackiem JSON)
│   ├── zamow.html                 # Strona zamówienia w przeglądarce (/)
│   ├── manage.html                # Panel zarządzania (/manage)
│   ├── releases.html              # Strona pobierania (/releases)
│   ├── style.css, script.js       # Style i skrypty
│   └── static/                    # Obrazy, dźwięki
└── releases/                      # Skompilowane binaria do publikacji
    ├── android/order.apk
    └── windows/bar_wegielstwo_board.exe + instalator
```

## Aplikacje

| App | Opis | Platforma |
|-----|------|-----------|
| `bar_wegielstwo_order` | Kiosk zamawiania | Android |
| `bar_wegielstwo_board` | Tablica zamówień na żywo | Windows, Linux |

## Backend Flask

Endpoint: `https://wegiel.pythonanywhere.com`

### Strony WWW

| Ścieżka | Opis |
|---------|------|
| `/` | Zamów w przeglądarce (dawniej `/zamow`) |
| `/manage` | Panel zarządzania |
| `/releases` | Pobierz aplikację (Android/Windows/Przeglądarka) |
| `/bazadanych.json` | Pełna baza danych (JSON) |

### API Endpoints (dla aplikacji Flutter)

| Metoda | Endpoint | Opis |
|--------|----------|------|
| GET/POST | `/api/orders` | Lista / złóż zamówienie |
| PUT/DELETE | `/api/orders/<id>` | Zmień status / usuń |
| DELETE | `/api/orders/clear` | Wyczyść wszystkie |
| GET/POST | `/api/menu` | Lista / dodaj pozycję |
| PUT/DELETE | `/api/menu/<name>` | Aktualizuj / usuń |
| GET | `/api/portions` | Porcje |
| GET/POST | `/api/extras` | Lista / dodaj dodatek |
| PUT/DELETE | `/api/extras/<name>` | Aktualizuj / usuń |
| POST | `/api/dzwonek` | Dzwonek |
| GET/POST | `/api/message` | Wiadomość główna |
| GET/POST | `/api/danie-dnia` | Danie dnia |
| POST | `/api/cleanup` | Czyszczenie starych zamówień |

### Firebase

Backend automatycznie używa Firebase Firestore gdy znajdzie plik `firebase-service-account.json` w katalogu `BarWegielstwoPythonFlask/`. Bez niego działa na lokalnym `bazadanych.json`.

```bash
# Zainstaluj na PythonAnywhere
pip install firebase-admin
# Dodaj klucz serwisowy Firebase
# Ustaw zmienną środowiskową FIREBASE_SERVICE_ACCOUNT lub umieść plik w katalogu
```

## Budowanie

### Wymagania
- Flutter SDK (`C:\tools\flutter\bin\flutter.bat`)
- Windows: MSVC 2022 (Build Tools) + Inno Setup 7
- Android: Android SDK
- Linux: Linux host (cross-compilation nie działa z Windows)

### Windows (board)
```powershell
cd bar_wegielstwo_board; flutter build windows --release
```

### Android (order)
```powershell
cd bar_wegielstwo_order; flutter build apk --release
```

### Wszystko naraz
```powershell
.\build_all.ps1
```

### Linux AppImage (board)
```bash
# Wymaga Linux host z Flutter + linuxdeploy + appimagetool
./build_linux.sh
```

### Instalator Windows
```powershell
.\installer\build_installer.ps1
```

## Ikona aplikacji

Ikona (BarWegielstwo.png) używana jest jako:
- ICO dla Windows (app_icon.ico)
- Android mipmap (ic_launcher.png we wszystkich gęstościach)
- Logo w assets/images/

Generuj ikony:
```powershell
python installer\generate_icons.py
```

## Known Issues

- `audioplayers_windows` + MSVC 2022: wymagane `add_compile_definitions(_SILENCE_EXPERIMENTAL_COROUTINE_DEPRECATION_WARNINGS)` w `windows/CMakeLists.txt`
- Firebase Admin SDK wymaga Python 3.8+ na PythonAnywhere
- Linux AppImage można zbudować tylko na Linux host
