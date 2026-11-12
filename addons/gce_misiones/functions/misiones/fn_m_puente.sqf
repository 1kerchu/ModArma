/*
    Volar el puente — poner una carga a menos de 20 m del puente y hacerla estallar.
    Lo vigila una patrulla enemiga.
*/
params ["_datos", "_nombre"];
_datos params ["_p"];
([_p] call GCE_fnc_enemyBase) params [["_lado", Occupants], ["_basePos", _p]];

private _tid = ["Volar el puente",
    "El enemigo mueve refuerzos por este puente. Coloca una carga explosiva a menos de 20 metros y hazla estallar. Está vigilado.",
    _p, "destroy"] call GCE_fnc_taskCreate;
["Hay que volar el puente que usan para mover tropas. Llevad dinamita.", "Volar el puente"] call GCE_fnc_comms;

private _grupos = [];
private _g = [_p getPos [40, random 360], _lado, "medium"] call GCE_fnc_spawnSquad;
[_g, _p, 80] call CBA_fnc_taskPatrol;
_grupos pushBack _g;
if (tierWar >= 5) then {
    _g = [_p getPos [60, random 360], _lado, "squad"] call GCE_fnc_spawnSquad;
    [_g, _p, 60] call CBA_fnc_taskDefend;
    _grupos pushBack _g;
};

private _armado = false;
private _exito = false;
private _limite = time + 2700;
waitUntil {
    sleep 2;
    private _cargas = allMines select { _x distance2D _p < 20 };
    if (_cargas isNotEqualTo []) then { _armado = true };
    if (_armado && {_cargas isEqualTo []}) then { _exito = true };
    _exito || {time > _limite}
};

if (_exito) then {
    GCE_puentesVolados pushBack _p;
    private _fuego = createVehicle ["test_EmptyObjectForFireBig", _p, [], 0, "CAN_COLLIDE"];
    [_tid, "SUCCEEDED"] call GCE_fnc_endMission;
    ["¡El puente ha volado! Tendrán que dar un buen rodeo.", "Volar el puente"] call GCE_fnc_comms;
    [600, 0, "", 0, 10] call GCE_fnc_reward;
    [_fuego] spawn { sleep 600; deleteVehicle (_this select 0) };
} else {
    [_tid, "FAILED"] call GCE_fnc_endMission;
    ["Se acabó el tiempo: el puente sigue en pie.", "Volar el puente"] call GCE_fnc_comms;
};
[_grupos] spawn GCE_fnc_cleanup;
