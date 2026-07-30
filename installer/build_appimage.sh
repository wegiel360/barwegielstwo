#!/bin/bash
set -e
APP="bar_wegielstwo_board"
BUNDLE="$HOME/bar_wegielstwo_board/build/linux/x64/release/bundle"
APPDIR="$HOME/${APP}.AppDir"

echo "=== Preparing AppDir ==="
rm -rf "$APPDIR"
mkdir -p "$APPDIR/usr/bin"
mkdir -p "$APPDIR/usr/share/applications"
mkdir -p "$APPDIR/usr/share/icons/hicolor/256x256/apps"

cp -r "$BUNDLE"/* "$APPDIR/usr/bin/"

cat > "$APPDIR/usr/share/applications/${APP}.desktop" << 'EOF'
[Desktop Entry]
Name=Bar Wegielstwo Board
Exec=bar_wegielstwo_board
Icon=bar_wegielstwo_board
Type=Application
Categories=Utility;
Terminal=false
EOF

cp "$APPDIR/usr/share/applications/${APP}.desktop" "$APPDIR/"
ln -sf "usr/bin/${APP}" "$APPDIR/AppRun"

cp "$BUNDLE/data/flutter_assets/assets/images/BarWegielstwo.png" "$APPDIR/usr/share/icons/hicolor/256x256/apps/${APP}.png"
cp "$APPDIR/usr/share/icons/hicolor/256x256/apps/${APP}.png" "$APPDIR/${APP}.png"

echo "=== Building AppImage ==="
APPIMAGE_NAME="Bar_Wegielstwo_Board-x86_64.AppImage"

if [ ! -f /tmp/appimagetool ]; then
    echo "Downloading appimagetool..."
    wget -q "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage" -O /tmp/appimagetool
    chmod +x /tmp/appimagetool
fi

cd "$HOME"
/tmp/appimagetool "$APPDIR" 2>&1

if [ -f "$HOME/$APPIMAGE_NAME" ]; then
    OUTPUT_DIR="/mnt/c/Users/wegiel/Videos/BarWegielstwoFlutterDart/releases/linux"
    mkdir -p "$OUTPUT_DIR"
    cp "$HOME/$APPIMAGE_NAME" "$OUTPUT_DIR/"
    echo "=== AppImage ready: $OUTPUT_DIR/$APPIMAGE_NAME ==="
else
    echo "=== Trying mksquashfs fallback ==="
    OUTPUT_NAME="Bar_Wegielstwo_Board-x86_64.AppImage"
    mksquashfs "$APPDIR" "$HOME/$OUTPUT_NAME" -root-owned -noappend -comp gzip -b 1M
    cp "$HOME/$OUTPUT_NAME" "$OUTPUT_DIR/"
    echo "=== AppImage ready: $OUTPUT_DIR/$OUTPUT_NAME ==="
fi