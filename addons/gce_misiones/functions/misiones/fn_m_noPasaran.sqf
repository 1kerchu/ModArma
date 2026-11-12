/*
    ¡No pasarán!  — defender un pueblo NUESTRO de varias oleadas enemigas.
    Fallo: el pueblo cambia de manos o se queda 90 s sin defensores con enemigos dentro.
*/
params ["_datos", "_nombre"];
_datos params ["_ciudad"];
private _c = getMarkerPos _ciudad;
private _nom = [_ciudad] call A3A_fnc_localizar;
([_c] call GCE_fnc_enemyBase) params ["_lado", "_basePos"];
private _f = [_lado] call GCE_fnc_faction;

private _tid = [format ["¡No pasarán! — %1", _nom],
    format ["%1 prepara un ataque sobre %2. Ve al pueblo: atacarán 90 segundos después de que llegues (como mucho en 10 minutos). Aguanta todas las oleadas sin abandonarlo.", _f get "name", _nom],
    _c, "defend"] call GCE_fnc_taskCreate;
[format ["¡%1 va a por %2! Todos a las barricadas.", _f get "name", _nom], "¡No pasarán!"] call GCE_fnc_comms;
if ([_c, 500, 600] call GCE_fnc_waitArrival) then {
    ["Ya estáis en posición. Atacan en 90 segundos.", "¡No pasarán!"] call GCE_fnc_comms;
    sleep 90;
};

private _oleadas = 3 + floor (tierWar / 4);
private _grupos = [];
private _fallo = false;
private _sinDefensa = 0;

private _vigilar = {
    if (([_c, 250] call GCE_fnc_rebelsNear) == 0 && {([_c, 250] call GCE_fnc_enemiesNear) > 0}) then {
        _sinDefensa = _sinDefensa + 5;
    } else { _sinDefensa = 0 };
    if (_sinDefensa >= 90 || {(sidesX getVariable [_ciudad, sideUnknown]) != teamPlayer}) then { _fallo = true };
};

for "_i" from 1 to _oleadas do {
    private _pos = [_c, _basePos, 900] call GCE_fnc_spawnPos;
    _grupos pushBack ([_pos, _lado, ["militia", "squad"] select (_i > 1), _c, "SAD"] call GCE_fnc_spawnSquad);
    if (_i == _oleadas && {tierWar >= 5}) then {
        private _v = [_pos, _lado, _f get "vehiclesLightArmed", _c] call GCE_fnc_spawnVehicle;
        if (!isNull _v) then { _grupos pushBack _v };
    };
    [format ["Oleada %1 de %2 en camino.", _i, _oleadas], "¡No pasarán!"] call GCE_fnc_comms;
    private _t = time + 150;
    waitUntil { sleep 5; call _vigilar; _fallo || {time > _t} };
    if (_fallo) exitWith {};
};

if (!_fallo) then {
    private _t = time + 360;
    waitUntil { sleep 5; call _vigilar; _fallo || {time > _t} || {([_grupos, _c, 800] call GCE_fnc_aliveInGroups) == 0} };
};

if (_fallo) then {
    [_tid, "FAILED"] call GCE_fnc_endMission;
    [format ["%1 ha caído.", _nom], "¡No pasarán!"] call GCE_fnc_comms;
    [0, -10, _ciudad] call A3A_fnc_citySupportChange;
} else {
    [_tid, "SUCCEEDED"] call GCE_fnc_endMission;
    [format ["¡No han pasado! %1 sigue en pie.", _nom], "¡No pasarán!"] call GCE_fnc_comms;
    [300 + 100 * _oleadas, 2, _ciudad, 15, 10] call GCE_fnc_reward;
    { private _w = _x addWaypoint [_basePos, 50]; _x setCurrentWaypoint _w } forEach (_grupos select { !isNull _x });
};
[_grupos] spawn GCE_fnc_cleanup;
