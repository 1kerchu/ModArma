#!/usr/bin/env python3
"""
Genera las banderas del mod GCE en .png (para editar) y .paa (para Arma 3).

Uso:  python3 tools/make_flags.py
Requiere: Pillow  (pip install pillow)

Salida:
  addons/gce_main/data/flags/<nombre>_co.paa     bandera del mástil (512x256, DXT1)
  addons/gce_main/data/markers/<nombre>_co.paa   icono del mapa      (256x256, DXT5 con transparencia)
  art/flags/*.png                                 versiones PNG para retocar

Si prefieres dibujarlas tú: edita los PNG de art/ y conviértelos con ImageToPAA
(Arma 3 Tools), manteniendo el mismo nombre de archivo.
"""
import os, struct
from PIL import Image, ImageDraw

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT_FLAGS = os.path.join(ROOT, "addons", "gce_main", "data", "flags")
OUT_MARK = os.path.join(ROOT, "addons", "gce_main", "data", "markers")
OUT_ART = os.path.join(ROOT, "art", "flags")

# ---------------------------------------------------------------- colores
ROJO_ESP = (170, 21, 27)
AMARILLO = (241, 191, 0)
ROJO_REP = (200, 16, 30)
MORADO = (108, 44, 128)
NEGRO = (20, 20, 20)
ROJO_CNT = (190, 20, 25)

# ---------------------------------------------------------------- diseños
def bandera_nacional(w, h):
    """Rojigualda 1:2:1 (la que adoptó el bando sublevado en agosto de 1936)."""
    im = Image.new("RGB", (w, h), AMARILLO)
    d = ImageDraw.Draw(im)
    d.rectangle([0, 0, w, h // 4 - 1], fill=ROJO_ESP)
    d.rectangle([0, h - h // 4, w, h], fill=ROJO_ESP)
    return im

def bandera_republica(w, h):
    """Tricolor de la Segunda República: rojo, amarillo y morado a partes iguales."""
    im = Image.new("RGB", (w, h), AMARILLO)
    d = ImageDraw.Draw(im)
    t = h // 3
    d.rectangle([0, 0, w, t - 1], fill=ROJO_REP)
    d.rectangle([0, h - t, w, h], fill=MORADO)
    return im

def bandera_cnt(w, h):
    """Rojinegra de la CNT-FAI, dividida en diagonal."""
    im = Image.new("RGB", (w, h), NEGRO)
    ImageDraw.Draw(im).polygon([(0, 0), (w, 0), (0, h)], fill=ROJO_CNT)
    return im

BANDERAS = {
    "gce_nacional": bandera_nacional,
    "gce_republica": bandera_republica,
    "gce_cnt": bandera_cnt,
}

def marcador(fn, size=256):
    """Icono de mapa: bandera 2:1 centrada sobre fondo transparente, con borde."""
    fw, fh = size - 16, (size - 16) // 2
    im = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    flag = fn(fw, fh).convert("RGBA")
    x, y = (size - fw) // 2, (size - fh) // 2
    ImageDraw.Draw(im).rectangle([x - 4, y - 4, x + fw + 3, y + fh + 3], fill=(0, 0, 0, 255))
    im.paste(flag, (x, y))
    return im

# ---------------------------------------------------------------- DXT
def rgb565(c):
    r, g, b = c[:3]
    return ((r >> 3) << 11) | ((g >> 2) << 5) | (b >> 3)

def unpack565(v):
    r, g, b = (v >> 11) & 31, (v >> 5) & 63, v & 31
    return ((r << 3) | (r >> 2), (g << 2) | (g >> 4), (b << 3) | (b >> 2))

def color_block(px):
    """Bloque de color DXT1 (modo 4 colores, siempre opaco)."""
    lum = lambda c: c[0] * 299 + c[1] * 587 + c[2] * 114
    c0, c1 = rgb565(max(px, key=lum)), rgb565(min(px, key=lum))
    if c0 < c1:
        c0, c1 = c1, c0
    if c0 == c1:
        return struct.pack("<HHI", c0, c1, 0)
    a, b = unpack565(c0), unpack565(c1)
    pal = [a, b, tuple((2 * a[i] + b[i]) // 3 for i in range(3)),
           tuple((a[i] + 2 * b[i]) // 3 for i in range(3))]
    idx = 0
    for n, p in enumerate(px):
        best = min(range(4), key=lambda k: sum((p[i] - pal[k][i]) ** 2 for i in range(3)))
        idx |= best << (2 * n)
    return struct.pack("<HHI", c0, c1, idx)

def alpha_block(alphas):
    """Bloque alfa DXT5 (modo 8 valores)."""
    a0, a1 = max(alphas), min(alphas)
    if a0 == a1:
        return bytes([a0, a1]) + bytes(6)
    pal = [a0, a1] + [((7 - i) * a0 + i * a1) // 7 for i in range(1, 7)]
    bits = 0
    for n, a in enumerate(alphas):
        best = min(range(8), key=lambda k: abs(a - pal[k]))
        bits |= best << (3 * n)
    return bytes([a0, a1]) + bits.to_bytes(6, "little")

def encode(im, dxt5):
    w, h = im.size
    data = im.convert("RGBA").load()
    out = bytearray()
    for by in range(0, h, 4):
        for bx in range(0, w, 4):
            px = [data[bx + x, by + y] for y in range(4) for x in range(4)]
            if dxt5:
                out += alpha_block([p[3] for p in px])
            out += color_block(px)
    return bytes(out)

def tagg(name, payload):
    return b"GGAT" + name[::-1].encode() + struct.pack("<I", len(payload)) + payload

def write_paa(im, path, dxt5=False):
    """PAA con mipmaps sin comprimir (igual que las capas pequeñas de los .paa oficiales)."""
    im = im.convert("RGBA")
    mips = []
    while True:
        mips.append(im)
        if im.size[0] <= 4 or im.size[1] <= 4:
            break
        im = im.resize((im.size[0] // 2, im.size[1] // 2), Image.LANCZOS)
    avg = mips[-1].resize((1, 1), Image.BOX).getpixel((0, 0))
    avg_bgra = bytes([avg[2], avg[1], avg[0], avg[3]])
    taggs = tagg("AVGC", avg_bgra) + tagg("MAXC", b"\xff\xff\xff\xff")
    if dxt5:
        taggs += tagg("FLAG", b"\x01\xff\xff\xff")   # tiene canal alfa
    header_len = 2 + len(taggs) + 12 + 64 + 2   # magic + taggs + OFFS + paleta
    body, offs = bytearray(), []
    for m in mips:
        offs.append(header_len + len(body))
        d = encode(m, dxt5)
        body += struct.pack("<HH", m.size[0], m.size[1]) + len(d).to_bytes(3, "little") + d
    body += bytes(6)                                  # fin de mipmaps
    offs_payload = b"".join(struct.pack("<I", o) for o in offs).ljust(64, b"\0")
    magic = b"\x05\xff" if dxt5 else b"\x01\xff"
    with open(path, "wb") as f:
        f.write(magic + taggs + tagg("OFFS", offs_payload) + b"\0\0" + body)

def main():
    for d in (OUT_FLAGS, OUT_MARK, OUT_ART):
        os.makedirs(d, exist_ok=True)
    for name, fn in BANDERAS.items():
        flag = fn(512, 256)
        mark = marcador(fn)
        flag.save(os.path.join(OUT_ART, name + ".png"))
        mark.save(os.path.join(OUT_ART, name + "_marker.png"))
        write_paa(flag, os.path.join(OUT_FLAGS, name + "_co.paa"))
        write_paa(mark, os.path.join(OUT_MARK, name + "_co.paa"), dxt5=True)
        print("ok", name)

if __name__ == "__main__":
    main()
