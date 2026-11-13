/*
    GCE_fnc_sovCatalogo -> [[id, nombre, precio, armas [[clase, n]], cargadores [[clase, n]]], ...]
    Catálogo de la "ayuda soviética". Lo comprado va al arsenal del cuartel.
    Solo se ofrecen los lotes cuyas clases existen (Northern Fronts / IFA3 cargados).
*/
private _cat = [
    ["mosin",   "5 fusiles Mosin-Nagant",            400, [["LIB_M9130", 5]],              [["LIB_5Rnd_762x54", 40]]],
    ["svt",     "2 fusiles semiautomáticos SVT-38",  600, [["NORTH_SVT38", 2]],            [["NORTH_10rnd_SVT_mag", 16]]],
    ["ppd",     "2 subfusiles PPD-34",               500, [["NORTH_PPD34", 2]],            [["NORTH_34rnd_PPD_mag", 12]]],
    ["dp27",    "Ametralladora ligera DP-27",        700, [["NORTH_dp27", 1]],             [["NORTH_47rnd_dp27_mag", 8]]],
    ["fedorov", "Fusil automático Fedorov",          650, [["NORTH_Fedorov_Avtomat", 1]],  [["NORTH_25rnd_Fedorov_mag", 8]]],
    ["ptrd",    "Fusil antitanque PTRD",             800, [["LIB_PTRD", 1]],               [["LIB_1Rnd_145x114", 15]]],
    ["tt33",    "3 pistolas TT-33",                  250, [["NORTH_TT33", 3]],             [["NORTH_8Rnd_tt33_mag", 12]]],
    ["granadas","20 granadas RG-42",                 200, [],                              [["LIB_Rg42", 20]]]
];
_cat select {
    _x params ["", "", "", "_armas", "_cargs"];
    (_armas findIf { !isClass (configFile >> "CfgWeapons" >> (_x select 0)) }) == -1
    && {(_cargs findIf { !isClass (configFile >> "CfgMagazines" >> (_x select 0)) }) == -1}
}
