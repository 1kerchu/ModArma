/* GCE_fnc_rebelsNear  [pos, radio] -> nº de rebeldes vivos y conscientes */
params ["_pos", "_r"];
count ((allUnits select { side group _x == teamPlayer && {alive _x} && {lifeState _x != "INCAPACITATED"} }) inAreaArray [_pos, _r, _r])
