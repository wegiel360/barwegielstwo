#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APPS=("bar_wegielstwo_order" "bar_wegielstwo_board" "bar_wegielstwo_admin" "bar_wegielstwo_pro")

echo "=== BUILD ALL: Linux AppImage ==="
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

# 1. Build all apps for Linux
echo "--- STEP 1: Linux Release Builds ---"
for app in "${APPS[@]}"; do
    echo "Building $app for Linux..."
    cd "$SCRIPT_DIR/$app"
    flutter clean
    flutter pub get
    flutter build linux --release
    echo "OK: $app Linux"
    cd "$SCRIPT_DIR"
done

# 2. Package each app as AppImage
echo ""
echo "--- STEP 2: Package AppImages ---"

for app in "${APPS[@]}"; do
    APPDIR="${app}.AppDir"
    BUILD_DIR="$SCRIPT_DIR/${app}/build/linux/x64/release/bundle"
    
    echo "Creating AppImage for $app..."
    rm -rf "$APPDIR"
    mkdir -p "$APPDIR/usr/bin"
    mkdir -p "$APPDIR/usr/share/applications"
    mkdir -p "$APPDIR/usr/share/icons/hicolor/256x256/apps"
    
    # Copy bundle
    cp -r "$BUILD_DIR"/* "$APPDIR/usr/bin/"
    
    # Create .desktop file
    cat > "$APPDIR/usr/share/applications/${app}.desktop" << EOF
[Desktop Entry]
Name=Bar Wegielstwo ${app##bar_wegielstwo_}
Exec=${app}
Icon=${app}
Type=Application
Categories=Utility;
Terminal=false
EOF
    
    # Copy .desktop to root of AppDir
    cp "$APPDIR/usr/share/applications/${app}.desktop" "$APPDIR/"
    
    # Create symlink for AppRun
    ln -sf "usr/bin/${app}" "$APPDIR/AppRun"
    
    # Run linuxdeploy to bundle libraries
    linuxdeploy --appdir "$APPDIR" --output appimage
    
    echo "OK: $app AppImage created"
done

echo ""
echo "=== BUILD COMPLETE ==="
echo "AppImages created in current directory"
