/* GCE_fnc_fortCrearObjeto  [clase, posATL, dir] -> objeto  (servidor; también al cargar la partida) */
params ["_clase", "_pos", "_dir"];
private _o = createVehicle [_clase, _pos, [], 0, "CAN_COLLIDE"];
_o setDir _dir;
_o setPosATL _pos;
_o setVectorUp (surfaceNormal _pos);
_o setVariable ["GCE_fort", true, true];
if (isNil "GCE_fortificaciones") then { GCE_fortificaciones = [] };
GCE_fortificaciones pushBack _o;
_o
