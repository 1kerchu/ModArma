#!/usr/bin/env python3
"""
Genera los carteles de propaganda de los pueblos (1024x512, para vallas Land_Billboard_F).

Uso:  python3 tools/make_carteles.py
Salida: addons/gce_misiones/data/carteles/*.jpg  y  art/carteles/*.png

Grupos (los usa GCE_fnc_pueblosLoop según quién controla el pueblo):
  rep_*  República / Frente Popular
  cnt_*  CNT-FAI
  nac_*  bando sublevado (bandos y avisos oficiales, sin simbología)
"""
import os, random
from PIL import Image, ImageDraw, ImageFont, ImageFilter

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "addons", "gce_misiones", "data", "carteles")
ART = os.path.join(ROOT, "art", "carteles")
W, H = 1024, 512

def fuente(tam, serif=False):
    nombres = (["DejaVuSerif-Bold.ttf"] if serif else []) + ["DejaVuSans-Bold.ttf"]
    for n in nombres:
        for d in ["/usr/share/fonts/truetype/dejavu/", "/usr/share/fonts/dejavu/", ""]:
            try:
                return ImageFont.truetype(d + n, tam)
            except OSError:
                pass
    return ImageFont.load_default()

def envejecer(im, seed):
    rnd = random.Random(seed)
    papel = Image.new("RGB", im.size, (225, 210, 175))
    ruido = Image.effect_noise(im.size, 28).convert("RGB")
    im = Image.blend(im, papel, 0.12)
    im = Image.blend(im, ruido, 0.06)
    d = ImageDraw.Draw(im)
    # manchas suaves de humedad (difuminadas, casi transparentes)
    capa = Image.new("L", im.size, 0)
    dc = ImageDraw.Draw(capa)
    for _ in range(10):
        x, y, r = rnd.randrange(W), rnd.randrange(H), rnd.randrange(40, 140)
        dc.ellipse([x - r, y - r, x + r, y + r], fill=rnd.randrange(25, 55))
    capa = capa.filter(ImageFilter.GaussianBlur(35))
    im = Image.composite(Image.new("RGB", im.size, (150, 125, 85)), im, capa)
    # bordes gastados
    marco = Image.new("L", im.size, 0)
    ImageDraw.Draw(marco).rectangle([0, 0, W, H], outline=90, width=18)
    im = Image.composite(Image.new("RGB", im.size, (120, 100, 70)), im, marco.filter(ImageFilter.GaussianBlur(10)))
    return im.filter(ImageFilter.GaussianBlur(0.6))

def centrado(d, y, texto, f, color, sombra=None):
    # reduce la letra hasta que el texto quepa con margen
    tam, serif = f
    while True:
        fo = fuente(tam, serif)
        w = d.textlength(texto, font=fo)
        if w <= W - 90 or tam <= 20:
            break
        tam -= 4
    f = fo
    if sombra:
        d.text(((W - w) / 2 + 4, y + 4), texto, font=f, fill=sombra)
    d.text(((W - w) / 2, y), texto, font=f, fill=color)

def rep_no_pasaran():
    im = Image.new("RGB", (W, H), (178, 24, 30)); d = ImageDraw.Draw(im)
    d.rectangle([0, H - 70, W, H - 35], fill=(241, 191, 0)); d.rectangle([0, H - 35, W, H], fill=(108, 44, 128))
    centrado(d, 90, "¡NO PASARÁN!", (150, False), (250, 240, 220), (60, 0, 0))
    centrado(d, 290, "TODOS A LAS BARRICADAS", (54, False), (250, 240, 220))
    return im

def rep_uhp():
    im = Image.new("RGB", (W, H), (235, 220, 185)); d = ImageDraw.Draw(im)
    d.rectangle([0, 0, W, 60], fill=(178, 24, 30))
    centrado(d, 110, "U.H.P.", (200, False), (178, 24, 30), (90, 10, 10))
    centrado(d, 360, "¡UNÍOS, HERMANOS PROLETARIOS!", (52, False), (40, 30, 30))
    return im

def rep_frente():
    im = Image.new("RGB", (W, H), (40, 60, 90)); d = ImageDraw.Draw(im)
    d.polygon([(0, H), (W * 0.45, 0), (W * 0.62, 0), (W * 0.2, H)], fill=(178, 24, 30))
    centrado(d, 120, "TODOS AL FRENTE", (110, False), (250, 240, 220), (10, 10, 30))
    centrado(d, 290, "ALÍSTATE EN EL EJÉRCITO POPULAR", (46, False), (241, 191, 0))
    return im

def cnt_armas():
    im = Image.new("RGB", (W, H), (20, 20, 20)); d = ImageDraw.Draw(im)
    d.polygon([(0, 0), (W, 0), (0, H)], fill=(190, 20, 25))
    centrado(d, 70, "CNT · FAI", (150, False), (250, 240, 220), (0, 0, 0))
    centrado(d, 300, "¡OBREROS, A LAS ARMAS!", (66, False), (250, 240, 220), (0, 0, 0))
    return im

def cnt_colectividad():
    im = Image.new("RGB", (W, H), (190, 20, 25)); d = ImageDraw.Draw(im)
    d.rectangle([0, H // 2, W, H], fill=(20, 20, 20))
    centrado(d, 70, "LA TIERRA", (120, False), (250, 240, 220), (60, 0, 0))
    centrado(d, 300, "PARA QUIEN LA TRABAJA", (76, False), (250, 240, 220))
    return im

def nac_bando():
    im = Image.new("RGB", (W, H), (238, 230, 205)); d = ImageDraw.Draw(im)
    d.rectangle([20, 20, W - 20, H - 20], outline=(40, 30, 25), width=6)
    centrado(d, 50, "BANDO", (110, True), (40, 30, 25))
    centrado(d, 200, "SE DECLARA EL ESTADO DE GUERRA", (46, True), (40, 30, 25))
    centrado(d, 270, "EN TODO EL TERRITORIO DE ESTA PLAZA", (40, True), (40, 30, 25))
    centrado(d, 380, "LA AUTORIDAD MILITAR", (34, True), (90, 70, 60))
    return im

def nac_queda():
    im = Image.new("RGB", (W, H), (238, 230, 205)); d = ImageDraw.Draw(im)
    d.rectangle([20, 20, W - 20, H - 20], outline=(40, 30, 25), width=6)
    centrado(d, 60, "AVISO", (110, True), (40, 30, 25))
    centrado(d, 210, "TOQUE DE QUEDA A LAS 21 HORAS", (50, True), (40, 30, 25))
    centrado(d, 290, "PROHIBIDO EL USO DE ARMAS SIN PERMISO", (38, True), (40, 30, 25))
    centrado(d, 390, "LA COMANDANCIA", (34, True), (90, 70, 60))
    return im

CARTELES = {"rep_no_pasaran": rep_no_pasaran, "rep_uhp": rep_uhp, "rep_frente": rep_frente,
            "cnt_armas": cnt_armas, "cnt_colectividad": cnt_colectividad,
            "nac_bando": nac_bando, "nac_queda": nac_queda}

def main():
    os.makedirs(OUT, exist_ok=True); os.makedirs(ART, exist_ok=True)
    for i, (n, fn) in enumerate(CARTELES.items()):
        im = envejecer(fn(), i)
        im.save(os.path.join(ART, n + ".png"))
        im.save(os.path.join(OUT, n + ".jpg"), quality=88)
        print("ok", n)

if __name__ == "__main__":
    main()
