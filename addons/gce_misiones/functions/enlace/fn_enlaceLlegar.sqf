/*
    GCE_fnc_enlaceLlegar  [pos, nombre]  (cliente)
    Fundido a negro, viaje y llegada. Te acompañan los soldados de tu grupo que estén a pie
    a menos de 50 m.
*/
params ["_pos", "_nombre"];
private _acompanan = (units group player) select {
    !isPlayer _x && {alive _x} && {local _x} && {vehicle _x == _x} && {_x distance2D player < 50} && {lifeState _x != "INCAPACITATED"}
};
titleText [format ["Un camión de las milicias os lleva a %1...", _nombre], "BLACK OUT", 1.5];
sleep 2;
private _llegada = [_pos, 10, 60, 3, 0, 0.3, 0, [], [_pos, _pos]] call BIS_fnc_findSafePos;
player setPosATL [_llegada select 0, _llegada select 1, 0];
{
    private _p = _llegada getPos [3 + random 6, random 360];
    _x setPosATL [_p select 0, _p select 1, 0];
    _x doFollow player;
} forEach _acompanan;
sleep 3;
titleText [format ["%1", _nombre], "BLACK IN", 2];
