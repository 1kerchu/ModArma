#!/usr/bin/env python3
"""
Genera addons/gce_misiones/functions/fn_verificar.sqf: comprueba DENTRO DEL JUEGO que existen todas
las clases (vehículos, armas, uniformes, voces...) y archivos (.paa/.jpg) que usa el mod.

Uso:  python3 tools/gen_verificar.py      (vuelve a ejecutarlo cuando cambies los templates)
En el juego (consola de depuración):  [] call GCE_fnc_verificar
"""
import os, re, glob

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "addons", "gce_misiones", "functions", "fn_verificar.sqf")

PREFIJOS = ("LIB_", "NORTH_", "GCE_", "U_", "H_", "V_", "B_", "G_", "Land_", "Flag_", "Box_",
            "Male0", "GreekHead", "sab_", "FA_", "Bo_", "R_", "test_", "A3U_", "C_man", "flag_", "a3a_flag")
OPCIONALES = ("sab_", "FA_", "TFAR_", "ACE_")       # mods opcionales: si faltan no es un error
IGNORAR = {"GCE_misionActiva", "GCE_menuMisiones", "GCE_acciones", "GCE_esJefe", "GCE_blanco",
           "GCE_sigue", "GCE_aSalvo", "GCE_libre", "GCE_civRefugio", "GCE_refugioActivo",
           "GCE_oroDistanciaMax", "GCE_esperas", "GCE_contadorTareas", "GCE_npCentro",
           "GCE_npCivMuertos", "GCE_carga", "GCE_brigadas", "GCE_brigadista", "GCE_eventoActivo",
           "GCE_eventosIntervalo", "GCE_eventosActivos", "GCE_desertor"}

clases, rutas = set(), set()
archivos = glob.glob(os.path.join(ROOT, "addons", "**", "*.sqf"), recursive=True) + \
           glob.glob(os.path.join(ROOT, "addons", "**", "config.cpp"), recursive=True)
for f in archivos:
    if f.endswith("fn_verificar.sqf"):
        continue
    s = open(f, encoding="utf-8").read()
    s = re.sub(r"/\*.*?\*/", "", s, flags=re.S)
    s = re.sub(r"//[^\n]*", "", s)
    for tok in re.findall(r'"([^"\n]+)"', s):
        if re.search(r"\.(paa|jpg)$", tok, re.I):
            rutas.add(tok.replace("\\\\", "\\"))
        elif re.fullmatch(r"[A-Za-z][A-Za-z0-9_]+", tok) and tok.startswith(PREFIJOS) and tok not in IGNORAR \
                and not tok.startswith(("GCE_fnc_", "GCE_tarea", "GCE_np_", "GCE_poste", "GCE_flag_",
                                        "GCE_AI_", "GCE_Reb_", "GCE_CIV", "GCE_oro", "GCE_polvorin",
                                        "GCE_refugio", "GCE_brig", "GCE_desert", "GCE_huelga")):
            clases.add(tok)
    # clases de CfgVehicles/CfgWeapons declaradas como base en los config.cpp
    if f.endswith("config.cpp"):
        for base in re.findall(r"class (\w+)\s*;", s):
            if base not in ("UniformItem",):
                clases.add(base)

marcadores = sorted(c for c in clases if c.startswith(("flag_", "a3a_flag", "LIB_faction")))
clases = sorted(c for c in clases if c not in marcadores)
rutas = sorted(rutas)

def arr(lst):
    return "[\n    " + ",\n    ".join('"%s"' % x for x in lst) + "\n]"

sqf = f'''/*
    GCE_fnc_verificar  (GENERADO por tools/gen_verificar.py, no editar a mano)

    Comprueba que existen en tu juego todas las clases y archivos que usa el mod GCE.
    Uso en la consola de depuración:   [] call GCE_fnc_verificar
    El informe sale en pantalla, en el log (.rpt) y se copia al portapapeles.
*/
private _clases = {arr(clases)};
private _marcadores = {arr(marcadores)};
private _rutas = {arr(rutas)};
private _opcionales = {arr(list(OPCIONALES))};

private _faltan = [];
private _faltanOpc = [];
{{
    private _c = _x;
    private _existe = isClass (configFile >> "CfgVehicles" >> _c)
        || {{isClass (configFile >> "CfgWeapons" >> _c)}}
        || {{isClass (configFile >> "CfgMagazines" >> _c)}}
        || {{isClass (configFile >> "CfgGlasses" >> _c)}}
        || {{isClass (configFile >> "CfgAmmo" >> _c)}}
        || {{isClass (configFile >> "CfgVoice" >> _c)}}
        || {{isClass (configFile >> "CfgFaces" >> "Man_A3" >> _c)}}
        || {{isClass (configFile >> "CfgPatches" >> _c)}};
    if (!_existe) then {{
        if ((_opcionales findIf {{ (_c find _x) == 0 }}) != -1) then {{ _faltanOpc pushBack _c }} else {{ _faltan pushBack _c }};
    }};
}} forEach _clases;
{{ if !(isClass (configFile >> "CfgMarkers" >> _x)) then {{ _faltan pushBack ("marcador " + _x) }} }} forEach _marcadores;
private _faltanRutas = _rutas select {{ !fileExists _x }};

// PBO del mod cargados
private _pbos = ["GCE_main", "GCE_uniformes", "GCE_gorros", "GCE_misiones", "GCE_vehiculos"];
private _pbosNo = _pbos select {{ !isClass (configFile >> "CfgPatches" >> _x) }};

// bases retexturizadas: ¿admiten cambiar la textura?
private _sel = [
    ["CfgVehicles", "C_man_w_worker_F"],
    ["CfgWeapons", "H_Beret_blk"],
    ["CfgWeapons", "H_NORTH_SOV_Obr35_Pilotka"]
] apply {{
    _x params ["_cfg", "_c"];
    format ["%1: %2", _c, getArray (configFile >> _cfg >> _c >> "hiddenSelections")]
}};

private _txt = format ["GCE - COMPROBACIÓN<br/>Clases revisadas: %1<br/>Archivos revisados: %2<br/><br/>", count _clases + count _marcadores, count _rutas];
_txt = _txt + (if (_pbosNo isEqualTo []) then {{ "PBO: los 5 cargados<br/>" }} else {{ format ["<t color='#FF6060'>PBO NO cargados: %1</t><br/>", _pbosNo] }});
_txt = _txt + (if (_faltan isEqualTo []) then {{ "<t color='#60FF60'>No falta ninguna clase.</t><br/>" }} else {{ format ["<t color='#FF6060'>FALTAN %1 clases:</t><br/>%2<br/>", count _faltan, _faltan joinString ", "] }});
_txt = _txt + (if (_faltanRutas isEqualTo []) then {{ "<t color='#60FF60'>No falta ningún archivo.</t><br/>" }} else {{ format ["<t color='#FF6060'>FALTAN %1 archivos:</t><br/>%2<br/>", count _faltanRutas, _faltanRutas joinString "<br/>"] }});
if (_faltanOpc isNotEqualTo []) then {{ _txt = _txt + format ["<br/>Mods opcionales no cargados (no pasa nada): %1<br/>", count _faltanOpc] }};
_txt = _txt + "<br/>Texturas cambiables (hiddenSelections):<br/>" + (_sel joinString "<br/>");

hint parseText _txt;
private _plano = (_txt splitString "<>") select {{ !(_x in ["br/", "/t"]) && {{(_x find "t color") != 0}} }};
private _informe = _plano joinString endl;
diag_log "===== GCE COMPROBACIÓN =====";
{{ diag_log _x }} forEach _plano;
copyToClipboard _informe;
_informe
'''
open(OUT, "w", encoding="utf-8").write(sqf)
print(f"ok: {len(clases)} clases, {len(marcadores)} marcadores, {len(rutas)} rutas -> {OUT}")
