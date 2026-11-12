/* GCE_fnc_rebelCharges  [pos, radio] -> cargas explosivas puestas por rebeldes dentro del radio */
params ["_pos", "_r"];
private _cargas = [];
{ _cargas append (getAllOwnedMines _x) } forEach (allUnits select { side group _x == teamPlayer });
_cargas select { _x distance2D _pos < _r }
