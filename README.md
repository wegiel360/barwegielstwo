# Bar Węgielstwo — Flutter Apps + Flask Backend

System zamówień restauracji z 4 osobnymi aplikacjami Flutter.

## Struktura projektu

```
BarWegielstwoFlutterDart/
├── bar_wegielstwo_order/          # App 1 — Kiosk zamówień (klient)
├── bar_wegielstwo_board/          # App 2 — Tablica zamówień (display)
├── bar_wegielstwo_admin/          # App 3 — Panel zarządzania (admin)
├── bar_wegielstwo_pro/            # App 4 — Launcher Pro (3 zakładki: Zamów, Tablica, Zarządzaj)
├── build_all.ps1                  # Skrypt budujący Windows + Android + installer
├── build_linux.sh                 # Skrypt budujący Linux AppImage (Linux host wymagany)
├── installer/
│   └── bar_wegielstwo_pro.iss     # Inno Setup script (instalator Windows)
│
├── BarWegielstwOLD/               # Oryginalny projekt Flask (archiwum)
└── README.md
```

## Aplikacje

| App | Opis | Android | Windows |
|-----|------|---------|---------|
| `bar_wegielstwo_order` | Kiosk zamawiania | `app-release.apk` (47MB) | `bar_wegielstwo_order.exe` |
| `bar_wegielstwo_board` | Tablica zamówień na żywo | `app-release.apk` (47MB) | `bar_wegielstwo_board.exe` |
| `bar_wegielstwo_admin` | Panel zarządzania | `app-release.apk` (48MB) | `bar_wegielstwo_admin.exe` |
| `bar_wegielstwo_pro` | Launcher (Zamów/Tablica/Zarządzaj) | `app-release.apk` (44MB) | `bar_wegielstwo_pro.exe` |

Pro app uruchamia pozostałe 3 jako osobne procesy (`Process.start`). Exe muszą być w podkatalogach `order/`, `board/`, `admin/`.

## Backend Flask

Endpoint: `https://wegiel.pythonanywhere.com`

Aplikacje używają HTTP REST do backendu Flask. Zmień adres w `lib/config/constants.dart` → `ApiConfig.baseUrl`.

### API Endpoints

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

## Budowanie

### Wymagania
- Flutter SDK (`C:\tools\flutter\bin\flutter.bat`)
- Windows: MSVC 2022 (Build Tools)
- Android: Android SDK
- Linux: Linux host (cross-compilation nie działa z Windows)

### Windows
```powershell
.\build_all.ps1           # Buduje wszystko (Windows + Android + installer)
# Lub pojedynczo:
cd bar_wegielstwo_order; flutter build windows --release
```

### Android (fat APK)
```powershell
cd bar_wegielstwo_order; flutter build apk --release
```

### Linux AppImage
```bash
# Wymaga Linux host z Flutter + linuxdeploy + appimagetool
./build_linux.sh
```

### Instalator Windows (Inno Setup)
```powershell
# Wymaga Inno Setup 6: https://jrsoftware.org/isdownload.php
& "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" "/DRootDir=." "bar_wegielstwo_pro\installer\bar_wegielstwo_pro.iss"
```

## Pro app — Launcher

- 3 zakładki: Zamów, Tablica, Zarządzaj
- Każda zakładka uruchamia odpowiednią aplikację przez `Process.start()`
- Exe muszą być w podkatalogach względem Pro app
- `_launchApp` używa `Directory.current.path + '\$app\bar_wegielstwo_$app.exe'`

## Known Issues

- `audioplayers_windows` + MSVC 2022: wymaga `add_compile_definitions(_SILENCE_EXPERIMENTAL_COROUTINE_DEPRECATION_WARNINGS)` w `windows/CMakeLists.txt`
- Firebase nie wspiera Windows/Linux — desktop używa HTTP do Flask

## Assets

Każda apka: `assets/sounds/` (4x MP3), `assets/images/BarWegielstwo.png`
