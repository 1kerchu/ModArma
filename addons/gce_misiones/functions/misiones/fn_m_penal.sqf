/*
    Liberar el penal — rescatar presos de un puesto enemigo y traerlos al cuartel.
    Cada preso que llega al cuartel se une a las milicias (+1 de recursos humanos).
*/
params ["_datos", "_nombre"];
_datos params ["_marcador"];
private _c = getMarkerPos _marcador;
private _nom = [_marcador] call A3A_fnc_localizar;
private _lado = sidesX getVariable [_marcador, Occupants];
private _hq = getMarkerPos respawnTeamPlayer;

// Celda: edificio con posiciones cerca del puesto
private _casas = (nearestObjects [_c, ["House"], 120]) select { count ([_x] call BIS_fnc_buildingPositions) >= 4 };
private _posiciones = if (_casas isEqualTo []) then {
    [1, 2, 3, 4, 5, 6] apply { _c getPos [5 + random 10, random 360] }
} else {
    [selectRandom _casas] call BIS_fnc_buildingPositions
};

private _tid = [format ["Liberar el penal de %1", _nom],
    format ["En %1 tienen presos a compañeros nuestros. Libéralos (acción 'Liberar al preso') y tráelos al cuartel: se unirán a las milicias.", _nom],
    _c, "run"] call GCE_fnc_taskCreate;
[format ["Tienen presos a los nuestros en %1. ¡Vamos a sacarlos!", _nom], "Liberar el penal"] call GCE_fnc_comms;

private _grpPresos = createGroup teamPlayer;
private _presos = [];
private _n = (4 + round random 4) min (count _posiciones);
for "_i" from 0 to (_n - 1) do {
    private _u = [_grpPresos, A3A_faction_reb get "unitUnarmed", _posiciones select _i, [], 0, "NONE"] call A3A_fnc_createUnit;
    removeAllWeapons _u;
    removeAllAssignedItems _u;
    _u setCaptive true;
    _u disableAI "MOVE";
    _u disableAI "AUTOTARGET";
    _u setUnitPos "MIDDLE";
    [_u] remoteExec ["GCE_fnc_accionPreso", 0, _u];
    _presos pushBack _u;
};

// Guardia extra en la cárcel
private _guardia = [_c getPos [30, random 360], _lado, "medium"] call GCE_fnc_spawnSquad;
[_guardia, _c, 100] call CBA_fnc_taskDefend;

private _limite = time + 3600;
waitUntil {
    sleep 5;
    private _vivos = _presos select { alive _x };
    private _llegados = _vivos select { _x distance2D _hq < 60 };
    _vivos isEqualTo [] || {count _llegados == count _vivos} || {time > _limite}
};

private _rescatados = { alive _x && {_x distance2D _hq < 60} } count _presos;
if (_rescatados > 0) then {
    [_tid, "SUCCEEDED"] call GCE_fnc_endMission;
    [format ["%1 compañeros liberados se unen a las milicias.", _rescatados], "Liberar el penal"] call GCE_fnc_comms;
    [100 * _rescatados, _rescatados, "", 0, 5 * _rescatados] call GCE_fnc_reward;
} else {
    [_tid, "FAILED"] call GCE_fnc_endMission;
    ["No hemos podido sacar a nadie del penal.", "Liberar el penal"] call GCE_fnc_comms;
};
sleep 30;
{ if (alive _x && {_x distance2D _hq < 60}) then { deleteVehicle _x } } forEach _presos;
[[_guardia, _grpPresos]] spawn GCE_fnc_cleanup;
