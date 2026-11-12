/*
    GCE_fnc_spawnPos  [centro, desde, distancia] -> pos
    Punto despejado a "distancia" del centro, en dirección a "desde" (la base enemiga).
*/
params ["_c", "_desde", ["_d", 800]];
private _p = _c getPos [_d, (_c getDir _desde) + (random 40 - 20)];
[_p, 0, 200, 4, 0, 0.4, 0, [], [_p, _p]] call BIS_fnc_findSafePos
