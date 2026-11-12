/*
    Colectivizar la finca — en un recurso NUESTRO, aguantar 10 minutos contra la milicia de los terratenientes.
*/
params ["_datos", "_nombre"];
_datos params ["_marcador"];
private _c = getMarkerPos _marcador;
private _nom = [_marcador] call A3A_fnc_localizar;
([_c] call GCE_fnc_enemyBase) params ["_lado", "_basePos"];
private _ciudad = [citiesX, _c] call BIS_fnc_nearestPosition;

private _tid = [format ["Colectivizar %1", _nom],
    "Los trabajadores van a colectivizar la explotación. Los propietarios han llamado a sus pistoleros y a la milicia: protege la colectividad durante 10 minutos.",
    _c, "defend"] call GCE_fnc_taskCreate;
[format ["Asamblea en %1: ¡la tierra para quien la trabaja! Vienen a impedirlo.", _nom], "Colectivizar la finca"] call GCE_fnc_comms;
sleep 60;

private _grupos = [];
private _fallo = false;
private _sinDefensa = 0;
private _fin = time + 600;
private _oleadas = [[0, "militia"], [240, "militia"]];
if (tierWar >= 4) then { _oleadas pushBack [420, "squad"] };
private _inicio = time;

waitUntil {
    sleep 5;
    {
        _x params ["_t", "_tipo"];
        if (time - _inicio >= _t) then {
            _grupos pushBack ([[_c, _basePos, 700] call GCE_fnc_spawnPos, _lado, _tipo, _c, "SAD"] call GCE_fnc_spawnSquad);
            _oleadas set [_forEachIndex, [1e9, ""]];
        };
    } forEach _oleadas;
    if (([_c, 200] call GCE_fnc_rebelsNear) == 0 && {([_c, 200] call GCE_fnc_enemiesNear) > 0}) then {
        _sinDefensa = _sinDefensa + 5;
    } else { _sinDefensa = 0 };
    if (_sinDefensa >= 90 || {(sidesX getVariable [_marcador, sideUnknown]) != teamPlayer}) then { _fallo = true };
    _fallo || {time > _fin}
};

if (_fallo) then {
    [_tid, "FAILED"] call GCE_fnc_endMission;
    ["Han disuelto la colectividad.", "Colectivizar la finca"] call GCE_fnc_comms;
} else {
    [_tid, "SUCCEEDED"] call GCE_fnc_endMission;
    ["¡La colectividad sigue adelante! Los jornaleros se unen a la causa.", "Colectivizar la finca"] call GCE_fnc_comms;
    [700, 2, _ciudad, 10, 8] call GCE_fnc_reward;
};
[_grupos] spawn GCE_fnc_cleanup;
