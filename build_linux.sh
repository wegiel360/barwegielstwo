#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== BUILD LINUX: Board AppImage ==="
echo ""

# Prerequisites:
# - Flutter SDK with Linux support enabled
# - appimagetool (https://github.com/AppImage/AppImageKit)
# - linuxdeploy (https://github.com/linuxdeploy/linuxdeploy)

REQUIRED_CMDS=("flutter" "appimagetool" "linuxdeploy")
for cmd in "${REQUIRED_CMDS[@]}"; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "WARNING: $cmd not found in PATH"
    fi
done

APP="bar_wegielstwo_board"

# 1. Build board for Linux
echo "--- STEP 1: Linux Release Build ---"
echo "Building $APP for Linux..."
cd "$SCRIPT_DIR/$APP"
flutter clean
flutter pub get
flutter build linux --release
echo "OK: $APP Linux"
cd "$SCRIPT_DIR"

# 2. Package as AppImage
echo ""
echo "--- STEP 2: Package AppImage ---"

APPDIR="${APP}.AppDir"
BUILD_DIR="$SCRIPT_DIR/${APP}/build/linux/x64/release/bundle"

echo "Creating AppImage for $APP..."
rm -rf "$APPDIR"
mkdir -p "$APPDIR/usr/bin"
mkdir -p "$APPDIR/usr/share/applications"
mkdir -p "$APPDIR/usr/share/icons/hicolor/256x256/apps"

cp -r "$BUILD_DIR"/* "$APPDIR/usr/bin/"

cat > "$APPDIR/usr/share/applications/${APP}.desktop" << EOF
[Desktop Entry]
Name=Bar Wegielstwo Board
Exec=${APP}
Icon=${APP}
Type=Application
Categories=Utility;
Terminal=false
EOF

cp "$APPDIR/usr/share/applications/${APP}.desktop" "$APPDIR/"
ln -sf "usr/bin/${APP}" "$APPDIR/AppRun"

linuxdeploy --appdir "$APPDIR" --output appimage

echo "OK: $APP AppImage created"

echo ""
echo "=== BUILD COMPLETE ==="
