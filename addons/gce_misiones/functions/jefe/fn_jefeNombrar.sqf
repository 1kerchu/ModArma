/*
    GCE_fnc_jefeNombrar  [soldado]  (cliente)
    Cuesta 100: del dinero de la facción si eres el comandante, si no del tuyo.
*/
params ["_u"];
private _coste = 100;
private _esComandante = player == theBoss;
private _dinero = if (_esComandante) then { server getVariable ["resourcesFIA", 0] } else { player getVariable ["moneyX", 0] };
if (_dinero < _coste) exitWith {
    ["Jefe de escuadra", format ["Necesitas %1 para ascenderlo.", _coste]] call A3A_fnc_customHint;
};
if (_esComandante) then {
    [0, -_coste] remoteExec ["A3A_fnc_resourcesFIA", 2];
} else {
    [-_coste, player] remoteExec ["A3A_fnc_addMoneyPlayer", 2];
};

_u setVariable ["GCE_esJefe", true, true];
_u setRank "SERGEANT";
_u setSkill ["commanding", 1];
_u setSkill ["spotDistance", (_u skill "spotDistance") max 0.8];
_u setSkill ["spotTime", (_u skill "spotTime") max 0.8];
_u groupChat "¡A la orden! Tú marcas el camino, yo reparto los blancos.";
["Jefe de escuadra", format ["%1 es ahora tu jefe de escuadra. Repartirá los objetivos entre el grupo; tú sigues mandando el movimiento.", name _u]] call A3A_fnc_customHint;
[_u] spawn GCE_fnc_jefeLoop;
