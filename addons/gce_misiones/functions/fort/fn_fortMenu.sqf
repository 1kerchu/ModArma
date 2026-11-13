/* GCE_fnc_fortMenu  (cliente): menú de fortificaciones */
if (!isNil "GCE_fortFantasma") exitWith { ["Fortificaciones", "Termina antes de colocar la anterior."] call A3A_fnc_customHint };
private _cat = [] call GCE_fnc_fortCatalogo;
private _quien = if (player == theBoss) then { "fondos de la facción" } else { "tu dinero" };
GCE_menuFort = [[format ["Fortificaciones de época (pagas con %1)", _quien], false]];
{
    _x params ["_clase", "_nombre", "_precio"];
    GCE_menuFort pushBack [format ["%1 — %2", _nombre, _precio], [_forEachIndex + 2], "", -5,
        [["expression", format ["['%1', %2] spawn GCE_fnc_fortColocar;", _clase, _precio]]], "1", "1"];
} forEach _cat;
showCommandingMenu "#USER:GCE_menuFort";
