from gi.repository import Nautilus, GObject
import mimetypes
import subprocess
import threading

IMAGE_MIME_PREFIX = "image/"

def is_image_file(file):
    mime_type, _ = mimetypes.guess_type(file.get_name())
    print(f"Debug: MIME type for {file.get_name()} is {mime_type}")
    return mime_type and mime_type.startswith(IMAGE_MIME_PREFIX)

class ImageToolsExtension(GObject.GObject, Nautilus.MenuProvider):
    def launch_swappy(self, menu, file: Nautilus.FileInfo) -> None:
        print(f"Debug: Launching Swappy for file {file.get_name()}")
        path = file.get_location().get_path()
        subprocess.Popen(["swappy", "-f", path])

    def run_tesseract(self, menu, file):
        path = file.get_location().get_path()
        langs = "chi_sim+chi_tra+jpn+kor+eng"
        result = subprocess.run(["tesseract", "-l", langs, path, "-"], stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)
        if result.returncode != 0:
            subprocess.Popen(["notify-send", "Tesseract OCR", f"OCR return with error：{result.stderr}"])
            return
        text = result.stdout
        if not text:
            subprocess.Popen(["notify-send", "Tesseract OCR", "No text found"])
            return

        p = subprocess.Popen(["wl-copy"], stdin=subprocess.PIPE)
        p.communicate(input=text)
        subprocess.Popen(["notify-send", "Tesseract OCR", "Text has been send to clipboard"])

    def setup_wallpaper(self, menu, file):
        path = file.get_location().get_path()
        subprocess.run(["wallpaper-switch", "-f", path], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

    def get_file_items(self, files: list[Nautilus.FileInfo],):
        print(f"Debug: Received {len(files)} files")
        if len(files) != 1 or not is_image_file(files[0]):
            return []

        item_swappy = Nautilus.MenuItem(
            name="ImageToolsExtension::OpenWithSwappy",
            label="Open with Swappy",
            tip="Open with Swappy"
        )
        item_swappy.connect('activate', self.launch_swappy, files[0])

        item_ocr = Nautilus.MenuItem(
            name="ImageToolsExtension::OCRWithTesseract",
            label="OCR via Tesseract",
            tip="OCR via Tesseract"
        )
        item_ocr.connect('activate', self.run_tesseract, files[0])

        item_setup_wallpaper = Nautilus.MenuItem(
            name="ImageToolsExtension::SetupWallpaper",
            label="Setup wallpaper via swaybg",
            tip="Setup wallpaper via swaybg"
        )
        item_setup_wallpaper.connect('activate', self.setup_wallpaper, files[0])

        return [item_swappy, item_ocr, item_setup_wallpaper]
