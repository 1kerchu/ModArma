/*
    GCE_fnc_pueblosLoop  (servidor, spawn)

    En cada pueblo pone:
      - un mástil con la bandera de quien lo controla,
      - una valla con un cartel de propaganda del bando que lo controla:
          República -> "¡No pasarán!", "U.H.P.", "Todos al frente"
          CNT-FAI   -> "CNT·FAI ¡Obreros, a las armas!", "La tierra para quien la trabaja"
          sublevados-> "Bando: estado de guerra", "Aviso: toque de queda" (sin simbología)
    Cuando el pueblo cambia de manos, cambian la bandera y el cartel.
    Solo funciona si los rebeldes son una facción GCE. Desactivar: GCE_pueblosActivos = false.
*/
waitUntil { sleep 10; !isNil "citiesX" && {!isNil "sidesX"} && {!isNil "A3A_faction_reb"} && {!isNil "A3A_faction_occ"} && {!isNil "A3A_faction_inv"} };
if (isNil "GCE_pueblosActivos") then { GCE_pueblosActivos = true };
if ((toLower (A3A_faction_reb get "flagTexture") find "\gce\") == -1) exitWith {};   // facción no GCE

private _ruta = "\GCE\addons\gce_misiones\data\carteles\";
private _carteles = createHashMapFromArray [
    ["rep", ["rep_no_pasaran", "rep_uhp", "rep_frente"]],
    ["cnt", ["cnt_armas", "cnt_colectividad"]],
    ["nac", ["nac_bando", "nac_queda"]]
];
private _facDe = {
    params ["_lado"];
    switch (_lado) do {
        case teamPlayer: { A3A_faction_reb };
        case Invaders: { A3A_faction_inv };
        default { A3A_faction_occ };
    }
};
private _grupoDe = {
    params ["_f"];
    private _b = toLower (_f get "flagTexture");
    if ((_b find "gce_cnt") != -1) exitWith { "cnt" };
    if ((_b find "gce_republica") != -1) exitWith { "rep" };
    "nac"
};

GCE_pueblos = createHashMap;   // pueblo -> [mástil, valla, último dueño]
while { true } do {
    if (GCE_pueblosActivos) then {
        {
            private _pueblo = _x;
            private _lado = sidesX getVariable [_pueblo, sideUnknown];
            if (_lado in [teamPlayer, Occupants, Invaders]) then {
                private _d = GCE_pueblos getOrDefault [_pueblo, []];
                if (_d isEqualTo []) then {
                    private _c = getMarkerPos _pueblo;
                    private _pm = [_c, 5, 70, 3, 0, 0.3, 0, [], [[], []]] call BIS_fnc_findSafePos;
                    private _mastil = objNull;
                    if (_pm isNotEqualTo []) then {
                        _mastil = createVehicle ["Flag_White_F", _pm, [], 0, "CAN_COLLIDE"];
                    };
                    // valla junto a una carretera del pueblo, mirando a la carretera
                    private _valla = objNull;
                    private _rs = _c nearRoads 120;
                    if (_rs isNotEqualTo []) then {
                        private _rd = getPosATL (selectRandom _rs);
                        private _pv = [_rd, 7, 25, 6, 0, 0.25, 0, [], [[], []]] call BIS_fnc_findSafePos;
                        if (_pv isNotEqualTo []) then {
                            _valla = createVehicle ["Land_Billboard_F", _pv, [], 0, "CAN_COLLIDE"];
                            _valla setDir (_pv getDir _rd);
                            _valla setVectorUp [0, 0, 1];
                        };
                    };
                    _d = [_mastil, _valla, sideUnknown];
                    GCE_pueblos set [_pueblo, _d];
                };
                _d params ["_mastil", "_valla", "_ultimo"];
                if (_lado != _ultimo) then {
                    private _f = [_lado] call _facDe;
                    if (!isNull _mastil) then { _mastil setFlagTexture (_f get "flagTexture") };
                    if (!isNull _valla) then {
                        _valla setObjectTextureGlobal [0, _ruta + (selectRandom (_carteles get ([_f] call _grupoDe))) + ".jpg"];
                    };
                    _d set [2, _lado];
                };
            };
        } forEach citiesX;
    };
    sleep 60;
};
