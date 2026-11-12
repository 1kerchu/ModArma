/*
    GCE_fnc_enemyAir  [pos] -> [lado, tiposDeAvion, posAerodromo] o []
    Bando enemigo con aeródromo y aviones de ataque (para el bombardeo del refugio).
*/
params ["_pos"];
private _aero = airportsX select { (sidesX getVariable [_x, sideUnknown]) in [Occupants, Invaders] };
_aero = _aero select {
    private _f = [sidesX getVariable [_x, sideUnknown]] call GCE_fnc_faction;
    ((_f get "vehiclesPlanesCAS") + (_f get "vehiclesPlanesAA")) isNotEqualTo []
};
if (_aero isEqualTo []) exitWith { [] };
private _a = [_aero, _pos] call BIS_fnc_nearestPosition;
private _lado = sidesX getVariable [_a, Occupants];
private _f = [_lado] call GCE_fnc_faction;
private _tipos = _f get "vehiclesPlanesCAS";
if (_tipos isEqualTo []) then { _tipos = _f get "vehiclesPlanesAA" };
[_lado, _tipos, getMarkerPos _a]
