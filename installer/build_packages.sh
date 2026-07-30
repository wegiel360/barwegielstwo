#!/bin/bash

APP="bar_wegielstwo_board"
BUNDLE="$HOME/bar_wegielstwo_board/build/linux/x64/release/bundle"
VERSION="0.0.2.alpha"
OUTPUT_DIR="/mnt/c/Users/wegiel/Videos/BarWegielstwoFlutterDart/releases/linux"

mkdir -p "$OUTPUT_DIR"

# ========================
# Build .deb
# ========================
echo "=== Building .deb ==="
DEB_DIR="/tmp/${APP}-${VERSION}"
rm -rf "$DEB_DIR"
mkdir -p "$DEB_DIR/DEBIAN"
mkdir -p "$DEB_DIR/usr/bin"
mkdir -p "$DEB_DIR/usr/lib/${APP}"
mkdir -p "$DEB_DIR/usr/lib/${APP}/data"
mkdir -p "$DEB_DIR/usr/share/applications"
mkdir -p "$DEB_DIR/usr/share/icons/hicolor/256x256/apps"
mkdir -p "$DEB_DIR/usr/share/metainfo"

cat > "$DEB_DIR/DEBIAN/control" << EOF
Package: bar-wegielstwo-board
Version: ${VERSION}
Section: utilities
Priority: optional
Architecture: amd64
Depends: libgtk-3-0, libgstreamer1.0-0
Maintainer: Bar Wegielstwo <bar@wegiel.pl>
Description: Bar Wegielstwo live order board
 Live order board display for Bar Wegielstwo restaurant.
EOF

cp "$BUNDLE/bar_wegielstwo_board" "$DEB_DIR/usr/bin/"
chmod 755 "$DEB_DIR/usr/bin/bar_wegielstwo_board"
cp -r "$BUNDLE/lib/"* "$DEB_DIR/usr/lib/${APP}/"
cp -r "$BUNDLE/data/"* "$DEB_DIR/usr/lib/${APP}/data/"
cp "$DEB_DIR/usr/lib/${APP}/data/flutter_assets/assets/images/BarWegielstwo.png" "$DEB_DIR/usr/share/icons/hicolor/256x256/apps/${APP}.png"

cat > "$DEB_DIR/usr/share/applications/${APP}.desktop" << EOF
[Desktop Entry]
Name=Bar Wegielstwo Board
Exec=bar_wegielstwo_board
Icon=bar_wegielstwo_board
Type=Application
Categories=Utility;
Terminal=false
EOF

cat > "$DEB_DIR/usr/share/metainfo/${APP}.appdata.xml" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<component type="desktop">
  <id>bar-wegielstwo-board</id>
  <name>Bar Wegielstwo Board</name>
  <summary>Live order board display</summary>
  <description>Bar Wegielstwo restaurant order board.</description>
  <project_license>MIT</project_license>
</component>
EOF

chown -R root:root "$DEB_DIR"
dpkg-deb --build "$DEB_DIR" "$OUTPUT_DIR/${APP}_${VERSION}_amd64.deb"
echo "=== .deb done ==="

# ========================
# Build .rpm
# ========================
echo "=== Building .rpm ==="
RPM_BUILD_DIR="/tmp/rpmbuild"
rm -rf "$RPM_BUILD_DIR"
mkdir -p "$RPM_BUILD_DIR/BUILD"
mkdir -p "$RPM_BUILD_DIR/RPMS"
mkdir -p "$RPM_BUILD_DIR/SOURCES"
mkdir -p "$RPM_BUILD_DIR/SPECS"
mkdir -p "$RPM_BUILD_DIR/SRPMS"

TARBALL="/tmp/${APP}-${VERSION}.tar.gz"
rm -f "$TARBALL"

SRC_DIR="/tmp/${APP}-${VERSION}"
rm -rf "$SRC_DIR"
cp -r "$BUNDLE" "$SRC_DIR"
cd /tmp && tar czf "$TARBALL" -C . "${APP}-${VERSION}"
cp "$TARBALL" "$RPM_BUILD_DIR/SOURCES/"

SPEC="/tmp/rpmbuild/SPECS/${APP}.spec"
mkdir -p "$(dirname "$SPEC")"

cat > "$SPEC" << SPECEOF
Name:           bar-wegielstwo-board
Version:        ${VERSION}
Release:        1%{?dist}
Summary:        Bar Wegielstwo live order board

License:        MIT
URL:            https://github.com/wegiel360/barwegielstwo
Source0:        %{name}-%{version}.tar.gz

Requires:       gtk3
Requires:       gstreamer1
BuildArch:      x86_64

%description
Bar Wegielstwo restaurant order board display.

%prep
%setup -q -n ${APP}-${VERSION}

%install
mkdir -p %{buildroot}/usr/bin
mkdir -p %{buildroot}/usr/lib/%{name}
mkdir -p %{buildroot}/usr/share/applications
mkdir -p %{buildroot}/usr/share/icons/hicolor/256x256/apps
mkdir -p %{buildroot}/usr/share/metainfo

cp -r usr/bin/* %{buildroot}/usr/bin/
chmod 755 %{buildroot}/usr/bin/bar_wegielstwo_board
cp -r usr/lib/* %{buildroot}/usr/lib/%{name}/
cp usr/share/applications/*.desktop %{buildroot}/usr/share/applications/
cp usr/share/icons/hicolor/256x256/apps/*.png %{buildroot}/usr/share/icons/hicolor/256x256/apps/

%files
%defattr(-,root,root,-)
/usr/bin/bar_wegielstwo_board
/usr/lib/%{name}/*
/usr/share/applications/bar_wegielstwo_board.desktop
/usr/share/icons/hicolor/256x256/apps/bar_wegielstwo_board.png
/usr/share/metainfo/bar-wegielstwo-board.appdata.xml

%changelog
* $(date +"%a %b %d %Y") Bar Wegielstwo <bar@wegiel.pl> - ${VERSION}-1
- Initial release
SPECEOF

rpmbuild -bb "$SPEC" --define "_topdir $RPM_BUILD_DIR"
echo "=== .rpm done ==="

RPM_FILE=$(find "$RPM_BUILD_DIR/RPMS" -name "*.rpm" | head -1)
if [ -n "$RPM_FILE" ]; then
    cp "$RPM_FILE" "$OUTPUT_DIR/"
    echo "RPM copied to $OUTPUT_DIR/"
fi

echo "=== All packages built ==="
ls -la "$OUTPUT_DIR/"