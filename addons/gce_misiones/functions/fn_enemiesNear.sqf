/* GCE_fnc_enemiesNear  [pos, radio] -> nº de enemigos vivos */
params ["_pos", "_r"];
count ((allUnits select { (side group _x) in [Occupants, Invaders] && {alive _x} }) inAreaArray [_pos, _r, _r])
