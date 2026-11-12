#!/usr/bin/env python3
"""
Genera las fotos de vista previa (editorPreview) de los vehículos que no la traen
(los de Northern Fronts). Son fichas ilustradas: silueta + nombre.

Uso:  python3 tools/make_previews.py
Salida: addons/gce_vehiculos/data/previews/<clase>.jpg  (455x256, como las de Arma)

Para usar una captura de verdad: guarda un JPG de 455x256 con el mismo nombre y no ejecutes
este script (o quita esa entrada de VEHICULOS).
"""
import os
from PIL import Image, ImageDraw, ImageFont, ImageFilter

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "addons", "gce_vehiculos", "data", "previews")
W, H = 455, 256

# clase GCE: (nombre, subtítulo, silueta)
VEHICULOS = {
    "gce_ford_v8":      ("Ford V8",            "Camión · 14 plazas · 75 km/h", "camion"),
    "gce_r75":          ("Moto con sidecar",   "BMW R75 · 2 plazas",            "moto"),
    "gce_ba6":          ("BA-6",               "Blindado soviético · cañón 45 mm", "blindado"),
    "gce_ba10":         ("BA-10",              "Blindado soviético · cañón 45 mm", "blindado"),
    "gce_maxim":        ("Ametralladora Maxim", "Estática",                     "maxim"),
    "gce_45mm":         ("Cañón de 45 mm",     "Antitanque estático",           "canon"),
    "gce_maxim_quad":   ("Maxim cuádruple",    "Antiaérea estática",            "antiaerea"),
    "gce_mortero_50":   ("Mortero de 50 mm",   "Estático",                      "mortero"),
    "gce_lancha":       ("Lancha",             "Embarcación",                   "lancha"),
}

def fuente(tam):
    for f in ["/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
              "/usr/share/fonts/dejavu/DejaVuSans-Bold.ttf", "DejaVuSans-Bold.ttf"]:
        try:
            return ImageFont.truetype(f, tam)
        except OSError:
            pass
    return ImageFont.load_default()

def silueta(d, tipo, c):
    """Siluetas sencillas centradas en (0,0) a escala ~1 -> se dibujan transformadas."""
    def poly(pts):
        d.polygon([(x0 + x * s, y0 + y * s) for x, y in pts], fill=c)
    def rueda(x, y, r):
        d.ellipse([x0 + (x - r) * s, y0 + (y - r) * s, x0 + (x + r) * s, y0 + (y + r) * s], fill=c)
    def rect(a, b, cc, dd):
        d.rectangle([x0 + a * s, y0 + b * s, x0 + cc * s, y0 + dd * s], fill=c)
    x0, y0, s = W * 0.5, 150, 1.45
    if tipo == "camion":
        poly([(-80, 0), (-80, -35), (-40, -35), (-40, -20), (60, -20), (60, -40), (80, -40), (95, -20), (95, 5), (-80, 5)])
        rect(-75, -55, 20, -22)
        for x in (-55, 30, 65): rueda(x, 8, 12)
    elif tipo == "moto":
        poly([(-40, -10), (-10, -30), (25, -30), (40, -10), (10, -5)])
        poly([(-5, -30), (5, -55), (15, -55), (15, -30)])
        poly([(25, -12), (75, -12), (75, -2), (25, -2)])
        for x in (-35, 35, 70): rueda(x, 8, 13)
    elif tipo == "blindado":
        poly([(-85, 0), (-85, -30), (-60, -45), (50, -45), (80, -25), (95, -25), (95, 5), (-85, 5)])
        poly([(-30, -45), (-25, -65), (25, -65), (30, -45)])
        rect(25, -60, 85, -55)
        for x in (-55, 25, 60): rueda(x, 8, 13)
    elif tipo == "maxim":
        poly([(-60, -35), (40, -35), (40, -20), (-60, -20)])
        rect(40, -31, 85, -26)
        poly([(-20, -20), (-50, 15), (-40, 15), (-10, -20)])
        poly([(10, -20), (40, 15), (50, 15), (20, -20)])
        poly([(-35, -55), (5, -55), (5, -35), (-35, -35)])
    elif tipo == "canon":
        poly([(-30, -30), (30, -30), (30, 0), (-30, 0)])
        rect(20, -24, 100, -18)
        poly([(-30, -10), (-90, 15), (-80, 18), (-20, 0)])
        rueda(0, 5, 20)
        poly([(-35, -60), (-25, -60), (-25, -30), (-35, -30)])
    elif tipo == "antiaerea":
        for i in range(4):
            dx = (i % 2) * 14 - 7
            dy = (i // 2) * 14 - 7
            poly([(-10 + dx, -40 + dy), (50 + dx, -80 + dy), (55 + dx, -74 + dy), (-5 + dx, -34 + dy)])
        poly([(-40, -20), (40, -20), (40, 0), (-40, 0)])
        poly([(-50, 0), (50, 0), (60, 12), (-60, 12)])
    elif tipo == "mortero":
        poly([(-10, 0), (40, -75), (52, -68), (2, 6)])
        poly([(-40, 5), (20, 5), (20, 15), (-40, 15)])
        poly([(15, -35), (-15, 10), (-8, 12), (22, -30)])
    elif tipo == "lancha":
        poly([(-95, -15), (85, -15), (100, -30), (95, 0), (60, 15), (-85, 15)])
        poly([(-20, -15), (-10, -40), (30, -40), (35, -15)])

def ficha(nombre, sub, tipo):
    im = Image.new("RGB", (W, H), (40, 38, 34))
    d = ImageDraw.Draw(im)
    # degradado de fondo (papel viejo oscuro)
    for y in range(H):
        t = y / H
        d.line([(0, y), (W, y)], fill=(int(70 - 30 * t), int(64 - 28 * t), int(52 - 24 * t)))
    # franjas rojo-amarillo-morado arriba (identidad GCE)
    d.rectangle([0, 0, W, 5], fill=(200, 16, 30))
    d.rectangle([0, 5, W, 10], fill=(241, 191, 0))
    d.rectangle([0, 10, W, 15], fill=(108, 44, 128))
    # silueta con sombra
    capa = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    silueta(ImageDraw.Draw(capa), tipo, (0, 0, 0, 160))
    capa = capa.filter(ImageFilter.GaussianBlur(4))
    im.paste(capa, (4, 6), capa)
    silueta(d, tipo, (205, 196, 170))
    # textos
    d.rectangle([0, H - 62, W, H], fill=(20, 19, 17))
    d.text((14, H - 58), nombre, font=fuente(26), fill=(241, 230, 200))
    d.text((14, H - 26), sub, font=fuente(15), fill=(190, 180, 150))
    return im

def main():
    os.makedirs(OUT, exist_ok=True)
    for clase, (nombre, sub, tipo) in VEHICULOS.items():
        ficha(nombre, sub, tipo).save(os.path.join(OUT, clase + ".jpg"), quality=90)
        print("ok", clase)

if __name__ == "__main__":
    main()
