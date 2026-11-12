/*
    Evento: Desertores
    3-4 soldados enemigos (con su uniforme) se pasan a nuestro bando y corren hacia el cuartel.
    Les persigue un grupo enemigo. Los que llegan se unen a las milicias (+1 recursos humanos cada uno).
*/
params ["_base"];
_base params ["_lado", "_basePos"];
private _hq = getMarkerPos respawnTeamPlayer;
private _f = [_lado] call GCE_fnc_faction;

// salen entre el cuartel y la base enemiga, a ~800 m del cuartel
private _p = _hq getPos [(800 min ((_hq distance2D _basePos) * 0.6)), _hq getDir _basePos];
_p = [_p, 0, 150, 3, 0, 0.4, 0, [], [_p, _p]] call BIS_fnc_findSafePos;

private _grp = createGroup teamPlayer;
private _uniformes = _f getOrDefault ["uniforms", []];
for "_i" from 1 to (3 + round random 1) do {
    private _u = [_grp, A3A_faction_reb get "unitRifle", _p, [], 0, "NONE"] call A3A_fnc_createUnit;
    [_u] call A3A_fnc_FIAinit;
    _u setVariable ["GCE_desertor", true, true];
    if (_uniformes isNotEqualTo []) then {
        private _cosas = uniformItems _u;
        _u forceAddUniform (selectRandom _uniformes);
        { _u addItemToUniform _x } forEach _cosas;
    };
};
_grp setBehaviour "AWARE";
_grp setCombatMode "YELLOW";
_grp setSpeedMode "FULL";
private _w = _grp addWaypoint [_hq, 20];
_w setWaypointType "MOVE";

private _mrk = createMarker ["GCE_desertores", _p];
_mrk setMarkerType "mil_arrow2";
_mrk setMarkerColor "ColorGreen";
_mrk setMarkerText "Desertores";

private _tid = ["Desertores",
    format ["Un grupo de soldados de %1 ha desertado y corre hacia nuestro cuartel. Les persiguen: cúbrelos. Los que lleguen se unirán a las milicias.", _f get "name"],
    _p, "help"] call GCE_fnc_taskCreate;
[format ["¡Desertores de %1 vienen hacia el cuartel! Les persiguen, salid a cubrirlos.", _f get "name"], "Desertores"] call GCE_fnc_comms;

// perseguidores
sleep 60;
private _persig = [_p getPos [250, _p getDir _basePos], _lado, "militia"] call GCE_fnc_spawnSquad;
_persig setCombatMode "RED";
_persig setSpeedMode "FULL";

private _limite = time + 1200;
waitUntil {
    sleep 5;
    private _vivos = (units _grp) select { alive _x };
    if (_vivos isNotEqualTo []) then {
        _mrk setMarkerPos (getPos (_vivos select 0));
        // los perseguidores van a por ellos
        [_persig] call CBA_fnc_clearWaypoints;
        private _wp = _persig addWaypoint [getPos (_vivos select 0), 20];
        _wp setWaypointType "SAD";
    };
    _vivos isEqualTo [] || {(_vivos findIf { _x distance2D _hq > 60 }) == -1} || {time > _limite}
};

private _llegados = { alive _x && {_x distance2D _hq < 60} } count units _grp;
deleteMarker _mrk;
if (_llegados > 0) then {
    [_tid, "SUCCEEDED"] call BIS_fnc_taskSetState;
    [format ["%1 desertores han llegado al cuartel y se unen a las milicias.", _llegados], "Desertores"] call GCE_fnc_comms;
    [0, _llegados, "", 0, 3 * _llegados] call GCE_fnc_reward;
} else {
    [_tid, "FAILED"] call BIS_fnc_taskSetState;
    ["Ningún desertor ha llegado al cuartel.", "Desertores"] call GCE_fnc_comms;
};
GCE_eventoActivo = "";
[_tid] spawn { sleep 600; [_this select 0] call BIS_fnc_deleteTask };
sleep 30;
{ if (alive _x && {_x distance2D _hq < 60}) then { deleteVehicle _x } } forEach units _grp;
[[_grp, _persig]] spawn GCE_fnc_cleanup;
