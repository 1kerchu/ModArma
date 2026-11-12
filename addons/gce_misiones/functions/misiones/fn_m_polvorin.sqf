/*
    Volar el polvorín — destruir el depósito de munición de una base enemiga.

    - Junto a la base aparece un polvorín: cajas de munición de la facción enemiga entre sacos terreros,
      vigilado por un grupo y una ametralladora estática.
    - Se destruye poniendo una carga a menos de 15 m y haciéndola estallar, o destruyendo la caja
      principal con lo que sea (granadas, antitanque...).
    - Explosión en cadena: ¡aléjate!
    - Efecto real: el enemigo pierde recursos de ATAQUE y de DEFENSA (sin munición atacan menos y
      refuerzan peor).
    Plazo: 45 minutos.
*/
params ["_datos", "_nombre"];
_datos params ["_marcador"];
private _base = getMarkerPos _marcador;
private _nom = [_marcador] call A3A_fnc_localizar;
private _lado = sidesX getVariable [_marcador, Occupants];
private _f = [_lado] call GCE_fnc_faction;

// ---------- el polvorín ----------
private _p = [_base, 25, 90, 8, 0, 0.25, 0, [], [_base getPos [40, random 360], _base]] call BIS_fnc_findSafePos;
private _dir = random 360;
private _objetos = [];
private _cajaTipo = _f get "surrenderCrate";
if (isNil "_cajaTipo" || {!isClass (configFile >> "CfgVehicles" >> _cajaTipo)}) then { _cajaTipo = "Box_NATO_AmmoOrd_F" };

// caja principal (la que hay que destruir) y cajas alrededor
private _nucleo = createVehicle [_cajaTipo, _p, [], 0, "CAN_COLLIDE"];
_nucleo setDir _dir;
clearItemCargoGlobal _nucleo; clearMagazineCargoGlobal _nucleo; clearWeaponCargoGlobal _nucleo; clearBackpackCargoGlobal _nucleo;
_objetos pushBack _nucleo;
{
    private _o = createVehicle [_cajaTipo, _p getPos [_x select 0, _dir + (_x select 1)], [], 0, "CAN_COLLIDE"];
    _o setDir (_dir + random 20);
    clearItemCargoGlobal _o; clearMagazineCargoGlobal _o; clearWeaponCargoGlobal _o; clearBackpackCargoGlobal _o;
    _objetos pushBack _o;
} forEach [[1.6, 0], [1.6, 90], [1.6, 180], [1.6, 270], [2.4, 45]];
// sacos terreros alrededor
{
    private _o = createVehicle ["Land_BagFence_Long_F", _p getPos [5, _dir + _x], [], 0, "CAN_COLLIDE"];
    _o setDir (_dir + _x);
    _o setVectorUp (surfaceNormal (getPos _o));
    _objetos pushBack _o;
} forEach [0, 90, 180];

private _mrk = createMarker ["GCE_polvorin", _p];
_mrk setMarkerType "mil_destroy";
_mrk setMarkerColor "ColorRed";
_mrk setMarkerText "Polvorín";

// ---------- guardia ----------
private _grupos = [];
private _g = [_p getPos [20, random 360], _lado, "medium"] call GCE_fnc_spawnSquad;
[_g, _p, 60] call CBA_fnc_taskDefend;
_grupos pushBack _g;
private _mgs = _f get "staticMGs";
if (_mgs isNotEqualTo []) then {
    private _r = [_p getPos [7, _dir + 45], _dir + 45, selectRandom _mgs, _lado] call BIS_fnc_spawnVehicle;
    _grupos pushBack (_r select 2);
};
if (tierWar >= 5) then {
    _g = [_p getPos [60, random 360], _lado, "squad"] call GCE_fnc_spawnSquad;
    [_g, _p, 150] call CBA_fnc_taskPatrol;
    _grupos pushBack _g;
};

private _tid = [format ["Volar el polvorín de %1", _nom],
    format ["%1 guarda la munición de %2 en un polvorín (marcado en el mapa). Pon una carga a menos de 15 metros y hazla estallar, o destruye las cajas como puedas. Cuidado: explotará en cadena, aléjate. Sin munición atacarán menos y defenderán peor.", _f get "name", _nom],
    _p, "destroy"] call GCE_fnc_taskCreate;
[format ["Han llenado de munición el polvorín de %1. ¡Hay que volarlo!", _nom], "Volar el polvorín"] call GCE_fnc_comms;

// ---------- esperar a la voladura ----------
private _armado = false;
private _exito = false;
private _limite = time + 2700;
waitUntil {
    sleep 2;
    private _cargas = [_p, 15] call GCE_fnc_rebelCharges;
    if (_cargas isNotEqualTo []) then { _armado = true };
    if (_armado && {_cargas isEqualTo []}) then { _exito = true };
    if (!alive _nucleo || {damage _nucleo > 0.9}) then { _exito = true };
    _exito || {time > _limite}
};

if (_exito) then {
    // explosión en cadena
    private _bomba = createVehicle ["Bo_Mk82", [_p select 0, _p select 1, 1], [], 0, "CAN_COLLIDE"];
    _bomba setVelocity [0, 0, -50];
    {
        if (!isNull _x && {_x != _nucleo}) then { _x setDamage 1 };
    } forEach _objetos;
    [_p] spawn {
        params ["_p"];
        for "_i" from 1 to 6 do {
            sleep (0.6 + random 1.5);
            private _e = createVehicle ["R_60mm_HE", (_p getPos [random 12, random 360]) vectorAdd [0, 0, 1], [], 0, "CAN_COLLIDE"];
            _e setVelocity [0, 0, -30];
        };
        private _fuego = createVehicle ["test_EmptyObjectForFireBig", _p, [], 0, "CAN_COLLIDE"];
        sleep 600;
        deleteVehicle _fuego;
    };
    deleteVehicle _nucleo;

    [-300, _lado, "attack"] call A3A_fnc_addEnemyResources;
    [-200, _lado, "defence"] call A3A_fnc_addEnemyResources;
    [_tid, "SUCCEEDED"] call GCE_fnc_endMission;
    [format ["¡El polvorín de %1 ha volado! Les va a faltar munición para atacarnos.", _nom], "Volar el polvorín"] call GCE_fnc_comms;
    [500, 0, "", 0, 10] call GCE_fnc_reward;
} else {
    [_tid, "FAILED"] call GCE_fnc_endMission;
    ["Se acabó el tiempo: han repartido la munición.", "Volar el polvorín"] call GCE_fnc_comms;
};
deleteMarker _mrk;
[_grupos + _objetos] spawn GCE_fnc_cleanup;
