import os, shutil

app = "bar_wegielstwo_board"
bundle = "/root/bar_wegielstwo_board/build/linux/x64/release/bundle"
appdir = f"/root/{app}.AppDir"

if os.path.exists(appdir):
    shutil.rmtree(appdir)

os.makedirs(f"{appdir}/usr/bin", exist_ok=True)
os.makedirs(f"{appdir}/usr/share/applications", exist_ok=True)
os.makedirs(f"{appdir}/usr/share/icons/hicolor/256x256/apps", exist_ok=True)

for item in os.listdir(bundle):
    src = os.path.join(bundle, item)
    dst = os.path.join(appdir, "usr/bin", item)
    if os.path.isdir(src):
        shutil.copytree(src, dst, dirs_exist_ok=True)
    else:
        shutil.copy2(src, dst)

desktop = "[Desktop Entry]\nName=Bar Wegielstwo Board\nExec=bar_wegielstwo_board\nIcon=bar_wegielstwo_board\nType=Application\nCategories=Utility;\nTerminal=false\n"

with open(f"{appdir}/usr/share/applications/{app}.desktop", "w") as f:
    f.write(desktop)
with open(f"{appdir}/{app}.desktop", "w") as f:
    f.write(desktop)

os.symlink("usr/bin/bar_wegielstwo_board", f"{appdir}/AppRun")

icon_src = f"{bundle}/data/flutter_assets/assets/images/BarWegielstwo.png"
icon_dst = f"{appdir}/usr/share/icons/hicolor/256x256/apps/{app}.png"
shutil.copy2(icon_src, icon_dst)
shutil.copy2(icon_src, f"{appdir}/{app}.png")

print("AppDir created successfully")