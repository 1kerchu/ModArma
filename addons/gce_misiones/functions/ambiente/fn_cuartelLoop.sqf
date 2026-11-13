/*
    GCE_fnc_cuartelLoop  (servidor, spawn)

    Decorado de época junto al cuartel (cerca de Petros, sin tapar los objetos de Antistasi):
    mesa de mando con mapa y sillas, mástil con nuestra bandera, sacos terreros, sacos de víveres,
    leña y una valla con un cartel de nuestro bando. Si el cuartel se mueve, el decorado se mueve.
    Solo con facciones rebeldes GCE. Desactivar: GCE_cuartelDecorado = false.
*/
waitUntil { sleep 10; !isNil "petros" && {!isNull petros} && {!isNil "A3A_faction_reb"} };
if (isNil "GCE_cuartelDecorado") then { GCE_cuartelDecorado = true };
private _bandera = A3A_faction_reb get "flagTexture";
if ((toLower _bandera find "\gce\") == -1) exitWith {};
private _cartel = "\GCE\addons\gce_misiones\data\carteles\" +
    (if ((toLower _bandera find "gce_cnt") != -1) then { "cnt_armas" } else { "rep_no_pasaran" }) + ".jpg";

private _objetos = [];
private _centro = [];
while { true } do {
    if (GCE_cuartelDecorado && {!isNull petros} && {alive petros}) then {
        if (_centro isEqualTo [] || {(getPos petros) distance2D _centro > 60}) then {
            { deleteVehicle _x } forEach _objetos;
            _objetos = [];
            // sitio libre a 10-18 m de Petros
            private _a = [getPos petros, 10, 18, 7, 0, 0.2, 0, [], [[], []]] call BIS_fnc_findSafePos;
            if (_a isNotEqualTo []) then {
                _centro = getPos petros;
                private _dir = _a getDir petros;
                private _poner = {
                    params ["_tipo", "_dist", "_ang", ["_giro", 0]];
                    if (!isClass (configFile >> "CfgVehicles" >> _tipo)) exitWith { objNull };
                    private _o = createVehicle [_tipo, _a getPos [_dist, _dir + _ang], [], 0, "CAN_COLLIDE"];
                    _o setDir (_dir + _ang + _giro);
                    _o setVectorUp (surfaceNormal (getPos _o));
                    _o allowDamage false;
                    _objetos pushBack _o;
                    _o
                };
                // mesa de mando con mapa y sillas
                private _mesa = ["Land_WoodenTable_large_F", 0, 0, 90] call _poner;
                if (!isNull _mesa && {isClass (configFile >> "CfgVehicles" >> "Land_Map_altis_F")}) then {
                    private _mapa = createVehicle ["Land_Map_altis_F", getPos _mesa, [], 0, "CAN_COLLIDE"];
                    _mapa attachTo [_mesa, [0, 0, 0.42]];
                    _mapa setVectorDirAndUp [[0, 0, -1], [0, 1, 0]];
                    _objetos pushBack _mapa;
                };
                ["Land_CampingChair_V2_F", 1.4, 90, 180] call _poner;
                ["Land_CampingChair_V2_F", 1.4, -90, 0] call _poner;
                // bandera
                private _mastil = ["Flag_White_F", 4, 180] call _poner;
                if (!isNull _mastil) then { _mastil setFlagTexture _bandera };
                // parapeto de sacos terreros detrás
                ["Land_BagFence_Long_F", 4, 0] call _poner;
                ["Land_BagFence_Long_F", 4.5, 40, 40] call _poner;
                ["Land_BagFence_Long_F", 4.5, -40, -40] call _poner;
                // víveres y leña
                ["Land_Sacks_heap_F", 4, 110] call _poner;
                ["Land_Sacks_goods_F", 4.5, 135] call _poner;
                ["Land_WoodPile_F", 4, -110] call _poner;
                // cartel
                private _valla = ["Land_Billboard_F", 8, -150, 180] call _poner;
                if (!isNull _valla) then { _valla setObjectTextureGlobal [0, _cartel] };
            };
        };
    };
    sleep 30;
};
