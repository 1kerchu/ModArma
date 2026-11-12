/*
    GCE_fnc_enemyBase  [pos, distMax] -> [lado, posBase, marcador] o [] si no hay ninguna
    Base enemiga (aeródromo, base militar o puesto) más cercana a una posición.
*/
params ["_pos", ["_distMax", 7000]];
private _bases = (airportsX + milbases + outposts) select {
    (sidesX getVariable [_x, sideUnknown]) in [Occupants, Invaders]
    && {getMarkerPos _x distance2D _pos < _distMax}
};
if (_bases isEqualTo []) exitWith { [] };
private _b = [_bases, _pos] call BIS_fnc_nearestPosition;
[sidesX getVariable [_b, Occupants], getMarkerPos _b, _b]
