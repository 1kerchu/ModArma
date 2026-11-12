/*
    GCE_fnc_spawnVehicle  [pos, lado, tiposPosibles, destino, altura] -> grupo (grpNull si no hay tipos)
*/
params ["_pos", "_lado", ["_tipos", []], ["_destino", []], ["_altura", 0]];
if (_tipos isEqualTo []) exitWith { grpNull };
private _p = [_pos select 0, _pos select 1, _altura];
private _dir = if (_destino isEqualTo []) then { random 360 } else { _p getDir _destino };
private _r = [_p, _dir, selectRandom _tipos, _lado] call BIS_fnc_spawnVehicle;
private _grp = _r select 2;
if (_destino isNotEqualTo []) then {
    private _w = _grp addWaypoint [_destino, 50];
    _w setWaypointType "SAD";
    _grp setCombatMode "RED";
};
_grp
