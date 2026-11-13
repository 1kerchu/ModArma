/* GCE_fnc_sovMenu  (cliente): menú de compra de la ayuda soviética */
private _cat = [] call GCE_fnc_sovCatalogo;
if (_cat isEqualTo []) exitWith { ["Ayuda soviética", "No hay material disponible (¿falta Northern Fronts o IFA3?)."] call A3A_fnc_customHint };
private _quien = if (player == theBoss) then { "fondos de la facción" } else { "tu dinero" };
GCE_menuSov = [[format ["Ayuda soviética (pagas con %1)", _quien], false]];
{
    _x params ["_id", "_nombre", "_precio"];
    GCE_menuSov pushBack [format ["%1 — %2", _nombre, _precio], [_forEachIndex + 2], "", -5,
        [["expression", format ["['%1', player] remoteExec ['GCE_fnc_sovComprar', 2];", _id]]], "1", "1"];
} forEach _cat;
showCommandingMenu "#USER:GCE_menuSov";
