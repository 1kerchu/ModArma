/*
    GCE_fnc_waitArrival  [pos, radio, maxSegundos]   (scheduled)
    Espera hasta que un JUGADOR rebelde llegue a la zona (o se acabe el tiempo máximo).
    Devuelve true si han llegado.
*/
params ["_pos", ["_r", 500], ["_max", 600]];
private _fin = time + _max;
waitUntil {
    sleep 5;
    ((allPlayers select { side group _x == teamPlayer && {alive _x} }) inAreaArray [_pos, _r, _r]) isNotEqualTo [] || {time > _fin}
};
((allPlayers select { side group _x == teamPlayer && {alive _x} }) inAreaArray [_pos, _r, _r]) isNotEqualTo []
