#!/usr/bin/env python3
"""
Genera las texturas de los uniformes de GCE (tela lisa con trama, desgaste y suciedad).

Uso:  python3 tools/make_uniforms.py
Salida: addons/gce_uniformes/data/*_co.paa, addons/gce_gorros/data/*_co.paa y art/uniformes/*.png

La textura es "tela continua", sin costuras dibujadas: así sirve para cualquier modelo sin
conocer su mapa UV. Los pliegues y volúmenes los sigue dando el material original del modelo.
Si quieres detalles (botones, bolsillos, parches), pinta encima del PNG respetando el UV del
modelo base y conviértelo con ImageToPAA.
"""
import os, random
from PIL import Image, ImageDraw, ImageFilter, ImageChops
from make_flags import write_paa, ROOT

OUT = os.path.join(ROOT, "addons", "gce_uniformes", "data")
ART = os.path.join(ROOT, "art", "uniformes")

TELAS = {
    # nombre              color base        variación
    "mono_azul":        ((52, 78, 120),   18),   # mono azul de mecánico (el típico miliciano)
    "mono_mahon":       ((38, 52, 78),    14),   # azul mahón oscuro
    "mono_negro":       ((34, 33, 34),    10),   # mono negro (CNT-FAI)
    "mono_caqui":       ((122, 108, 74),  16),   # caqui (Ejército Popular, 1937)
}

def tela(color, var, size=1024, seed=0):
    rnd = random.Random(seed)
    base = Image.new("RGB", (size, size), color)
    # ruido fino de fibra
    noise = Image.effect_noise((size, size), var).convert("RGB")
    noise = ImageChops.subtract(noise, Image.new("RGB", (size, size), (128,) * 3), 1, 0)
    img = ImageChops.add(base, noise.point(lambda v: v // 2))
    # trama de sarga (diagonal)
    trama = Image.new("L", (size, size), 0)
    d = ImageDraw.Draw(trama)
    for i in range(-size, size, 3):
        d.line([(i, 0), (i + size, size)], fill=14)
    img = ImageChops.subtract(img, Image.merge("RGB", [trama] * 3))
    # manchas de uso y suciedad
    manchas = Image.new("L", (size, size), 0)
    d = ImageDraw.Draw(manchas)
    for _ in range(60):
        x, y, r = rnd.randrange(size), rnd.randrange(size), rnd.randrange(20, 120)
        d.ellipse([x - r, y - r, x + r, y + r], fill=rnd.randrange(8, 22))
    manchas = manchas.filter(ImageFilter.GaussianBlur(40))
    tierra = Image.new("RGB", (size, size), (90, 75, 55))
    img = Image.composite(tierra, img, manchas)
    return img

# Gorros: boinas -> PBO gce_uniformes (base: boina vanilla); gorrillos -> PBO gce_gorros (base: pilotka de Northern Fronts).
OUT_GORROS = os.path.join(ROOT, "addons", "gce_gorros", "data")
GORROS = {
    "boina_roja":     ((150, 22, 28),  10),   # boina roja carlista (Requetés)
    "boina_negra":    ((28, 27, 28),    8),   # boina negra (milicianos, campesinos)
    "gorrillo_negro": ((30, 29, 30),   10),   # gorrillo cuartelero negro (CNT-FAI)
    "gorrillo_rojo":  ((140, 24, 28),  12),   # gorrillo rojo (milicias)
}

def main():
    os.makedirs(OUT_GORROS, exist_ok=True)
    for i, (name, (color, var)) in enumerate(GORROS.items()):
        img = tela(color, var, size=512, seed=100 + i)
        img.save(os.path.join(ART, name + ".png"))
        dest = OUT if name.startswith("boina") else OUT_GORROS   # boinas -> gce_uniformes (solo vanilla)
        os.makedirs(dest, exist_ok=True)
        write_paa(img, os.path.join(dest, name + "_co.paa"))
        print("ok", name)
    os.makedirs(OUT, exist_ok=True)
    os.makedirs(ART, exist_ok=True)
    for i, (name, (color, var)) in enumerate(TELAS.items()):
        img = tela(color, var, seed=i)
        img.save(os.path.join(ART, name + ".png"))
        write_paa(img, os.path.join(OUT, name + "_co.paa"))
        print("ok", name)

if __name__ == "__main__":
    main()
