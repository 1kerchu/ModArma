/*
    GCE_fnc_enlaceMenu  (cliente)
    Menú del transporte de enlace: un camión de las milicias te lleva (a ti y a los soldados de tu
    grupo que estén a pie cerca) a otro pueblo nuestro o al cuartel.
*/
if (([getPos player, 300] call GCE_fnc_enemiesNear) > 0) exitWith {
    ["Transporte de enlace", "Hay enemigos cerca: ningún camión saldrá ahora."] call A3A_fnc_customHint;
};
private _destinos = [getPos player] call GCE_fnc_enlaceDestinos;
if (_destinos isEqualTo []) exitWith {
    ["Transporte de enlace", "No hay otros pueblos nuestros a los que ir."] call A3A_fnc_customHint;
};
private _quien = if (player == theBoss) then { "fondos de la facción" } else { "tu dinero" };
GCE_menuEnlace = [[format ["Transporte de enlace (pagas con %1)", _quien], false]];
{
    _x params ["_id", "_nombre", "_pos", "_precio"];
    GCE_menuEnlace pushBack [format ["%1 (%2 km) — %3", _nombre, round ((_pos distance2D player) / 100) / 10, _precio],
        [_forEachIndex + 2], "", -5,
        [["expression", format ["['%1', player] remoteExec ['GCE_fnc_enlaceViajar', 2];", _id]]], "1", "1"];
} forEach _destinos;
showCommandingMenu "#USER:GCE_menuEnlace";
