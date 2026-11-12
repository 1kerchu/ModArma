/* GCE_fnc_showMenu  [lista, misionActiva]  (cliente): menú de comandos con las misiones */
params ["_lista", "_activa"];
if (_activa != "") exitWith {
    ["Misiones de la Guerra Civil", format ["Ya hay una misión en marcha: %1", _activa]] call A3A_fnc_customHint;
};
GCE_menuMisiones = [["Misiones de la Guerra Civil", false]];
private _texto = "";
{
    _x params ["_id", "_nombre", "_ok", "_motivo"];
    GCE_menuMisiones pushBack [
        _nombre, [_forEachIndex + 2], "", -5,
        [["expression", format ["['%1', player] remoteExec ['GCE_fnc_startMission', 2];", _id]]],
        "1", ["0", "1"] select _ok
    ];
    _texto = _texto + format ["<t color='%1'>%2</t>%3<br/>",
        ["#888888", "#FFFFFF"] select _ok, _nombre, ["<br/>   <t size='0.85' color='#C8102E'>" + _motivo + "</t>", ""] select _ok];
} forEach _lista;
["Misiones de la Guerra Civil", _texto] call A3A_fnc_customHint;
showCommandingMenu "#USER:GCE_menuMisiones";
