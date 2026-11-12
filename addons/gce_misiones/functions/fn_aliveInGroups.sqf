/* GCE_fnc_aliveInGroups  [grupos, pos, radio] -> nº de vivos de esos grupos dentro del radio */
params ["_grupos", "_pos", ["_r", 100000]];
private _n = 0;
{ _n = _n + ({ alive _x && {_x distance2D _pos < _r} } count units _x) } forEach _grupos;
_n
