from PIL import Image
import os, sys

SRC = r"C:\Users\wegiel\Videos\BarWegielstwoFlutterDart\BarWegielstwoPythonFlask\static\BarWegielstwo.png"
APPS = ["bar_wegielstwo_order", "bar_wegielstwo_board", "bar_wegielstwo_admin"]
ROOT = r"C:\Users\wegiel\Videos\BarWegielstwoFlutterDart"

def make_ico(png_path, ico_path):
    img = Image.open(png_path).convert("RGBA")
    sizes = [(16,16), (32,32), (48,48), (64,64), (128,128), (256,256)]
    img.save(ico_path, format="ICO", sizes=sizes)
    print(f"  ICO: {ico_path}")

def make_mipmaps(png_path, mipmap_dir):
    sizes = {
        "mdpi": (48,48),
        "hdpi": (72,72),
        "xhdpi": (96,96),
        "xxhdpi": (144,144),
        "xxxhdpi": (192,192),
    }
    img = Image.open(png_path).convert("RGBA")
    for density, (w,h) in sizes.items():
        out_dir = os.path.join(mipmap_dir, f"mipmap-{density}")
        os.makedirs(out_dir, exist_ok=True)
        out_path = os.path.join(out_dir, "ic_launcher.png")
        resized = img.resize((w,h), Image.LANCZOS)
        # fill transparent background with dark color, then paste
        bg = Image.new("RGBA", (w,h), (42, 26, 22, 255))
        bg.paste(resized, (0,0), resized)
        bg.save(out_path)
        print(f"  Android {density}: {out_path}")

def main():
    for app in APPS:
        print(f"\n=== {app} ===")

        # Windows ICO
        ico_path = os.path.join(ROOT, app, "windows", "runner", "resources", "app_icon.ico")
        make_ico(SRC, ico_path)

        # Android mipmaps
        mipmap_base = os.path.join(ROOT, app, "android", "app", "src", "main", "res")
        make_mipmaps(SRC, mipmap_base)

        # Android adaptive icon foreground (for Android 8+)
        for density in ["mdpi", "hdpi", "xhdpi", "xxhdpi", "xxxhdpi"]:
            src_fg = os.path.join(mipmap_base, f"mipmap-{density}-foreground")
            if os.path.isdir(os.path.dirname(src_fg)):
                os.makedirs(src_fg, exist_ok=True)
                fg_path = os.path.join(src_fg, "ic_launcher_foreground.png")
                ico_img = Image.open(SRC).convert("RGBA")
                size_map = {"mdpi":108,"hdpi":162,"xhdpi":216,"xxhdpi":324,"xxxhdpi":432}
                s = size_map[density]
                resized = ico_img.resize((s,s), Image.LANCZOS)
                bg = Image.new("RGBA", (s,s), (42, 26, 22, 255))
                bg.paste(resized, (0,0), resized)
                bg.save(fg_path)
                print(f"  Android {density}-foreground: {fg_path}")

if __name__ == "__main__":
    main()
