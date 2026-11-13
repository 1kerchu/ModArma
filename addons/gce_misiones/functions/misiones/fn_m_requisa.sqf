/*
    Requisa de armas — asaltar el cuartel de la Guardia Civil (o de la policía enemiga) de un pueblo
    enemigo y llevarse las armas de su armería.

    - En un edificio del centro hay una armería (cajas) vigilada por la policía y la milicia.
    - Cuando no quedan enemigos a menos de 60 m de la armería, usa "Requisar las armas" junto a las cajas.
    - Las armas y la munición van al arsenal del cuartel (son las mismas que llevan los guardias).
    Plazo: 45 minutos.
*/
params ["_datos", "_nombre"];
_datos params ["_ciudad"];
private _c = getMarkerPos _ciudad;
private _nom = [_ciudad] call A3A_fnc_localizar;
private _lado = sidesX getVariable [_ciudad, Occupants];
private _f = [_lado] call GCE_fnc_faction;

// armería: edificio grande cerca del centro
private _casas = (nearestObjects [_c, ["House"], 150]) select { count ([_x] call BIS_fnc_buildingPositions) >= 4 };
private _p = if (_casas isEqualTo []) then { [_c, 5, 60, 4, 0, 0.3, 0, [], [_c, _c]] call BIS_fnc_findSafePos } else { ([_casas select 0] call BIS_fnc_buildingPositions) select 0 };
private _cajaTipo = _f get "surrenderCrate";
if (isNil "_cajaTipo" || {!isClass (configFile >> "CfgVehicles" >> _cajaTipo)}) then { _cajaTipo = "Box_NATO_Ammo_F" };
private _caja = createVehicle [_cajaTipo, _p, [], 0, "CAN_COLLIDE"];
clearItemCargoGlobal _caja; clearMagazineCargoGlobal _caja; clearWeaponCargoGlobal _caja; clearBackpackCargoGlobal _caja;
_caja allowDamage false;

// guardias: policía + milicia
private _grupos = [];
private _policia = _f getOrDefault ["groupPoliceSquad", []];
private _g = if (_policia isNotEqualTo []) then { [_p getPos [15, random 360], _lado, _policia] call A3A_fnc_spawnGroup } else { [_p getPos [15, random 360], _lado, "militia"] call GCE_fnc_spawnSquad };
[_g, _p, 50] call CBA_fnc_taskDefend;
_grupos pushBack _g;
_g = [_p getPos [40, random 360], _lado, "militia"] call GCE_fnc_spawnSquad;
[_g, _p, 120] call CBA_fnc_taskPatrol;
_grupos pushBack _g;

// botín: las armas que llevan los guardias (x2) y su munición
private _armas = [];
private _cargadores = [];
{
    {
        private _u = _x;
        { if (_x != "") then { _armas pushBack ([_x] call BIS_fnc_baseWeapon) } } forEach [primaryWeapon _u, secondaryWeapon _u, handgunWeapon _u];
        _cargadores append ((magazines _u) select { !(_x in ["", "FakeMagazine"]) });
    } forEach units _x;
} forEach _grupos;
_armas = _armas + _armas;

private _mrk = createMarker ["GCE_requisa", _p];
_mrk setMarkerType "mil_box";
_mrk setMarkerColor "ColorRed";
_mrk setMarkerText "Armería";

private _tid = [format ["Requisa de armas en %1", _nom],
    format ["La policía de %1 guarda armas en su cuartel de %2 (marcado). Limpia la zona y usa 'Requisar las armas' junto a las cajas: irán al arsenal.", _f get "name", _nom],
    _p, "rifle"] call GCE_fnc_taskCreate;
[format ["En %1 hay una armería llena. ¡A por ella!", _nom], "Requisa de armas"] call GCE_fnc_comms;

_caja setVariable ["GCE_requisada", false, true];
[_caja] remoteExec ["GCE_fnc_accionRequisa", 0, _caja];

private _limite = time + 2700;
waitUntil { sleep 3; (_caja getVariable ["GCE_requisada", false]) || {time > _limite} };
deleteMarker _mrk;

if (_caja getVariable ["GCE_requisada", false]) then {
    { boxX addWeaponCargoGlobal [_x, 1] } forEach _armas;
    { boxX addMagazineCargoGlobal [_x, 2] } forEach _cargadores;
    deleteVehicle _caja;
    [_tid, "SUCCEEDED"] call GCE_fnc_endMission;
    [format ["Armas requisadas: %1 armas y %2 cargadores van al arsenal del cuartel.", count _armas, 2 * count _cargadores], "Requisa de armas"] call GCE_fnc_comms;
    [100, 0, _ciudad, 3, 8] call GCE_fnc_reward;
} else {
    [_tid, "FAILED"] call GCE_fnc_endMission;
    ["Se acabó el tiempo: han vaciado la armería.", "Requisa de armas"] call GCE_fnc_comms;
    deleteVehicle _caja;
};
[_grupos] spawn GCE_fnc_cleanup;
