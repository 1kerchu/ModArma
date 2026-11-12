/*
    GCE_fnc_jefeEstado  (cliente, consola de depuración):  [] call GCE_fnc_jefeEstado
    Muestra si tu jefe de escuadra está activo y a quién ha mandado disparar cada uno.
*/
private _jefes = (units group player) select { alive _x && {_x getVariable ["GCE_esJefe", false]} };
private _txt = "";
if (_jefes isEqualTo []) then {
    _txt = "No tienes jefe de escuadra en tu grupo.";
} else {
    private _j = _jefes select 0;
    private _latido = time - (_j getVariable ["GCE_jefeLatido", -1000]);
    _txt = format ["Jefe: %1<br/>Activo: %2 (última revisión hace %3 s)<br/>Enemigos que conoce: %4<br/>Modo de combate del grupo: %5<br/><br/>",
        name _j, ["NO", "sí"] select (_latido < 10), round _latido, _j getVariable ["GCE_jefeEnemigos", 0], combatMode group player];
    {
        private _b = _x getVariable ["GCE_blanco", objNull];
        _txt = _txt + format ["%1 -> %2<br/>", name _x,
            [format ["%1 a %2 m", getText (configOf _b >> "displayName"), round (_x distance _b)], "sin blanco"] select (isNull _b || {!alive _b})];
    } forEach ((units group player) select { !isPlayer _x && {alive _x} });
    if (_latido >= 10) then {
        _txt = _txt + "<br/>El jefe no está activo: retíralo y vuelve a nombrarlo. Si sigue igual, mira el .rpt.";
    };
};
hint parseText _txt;
copyToClipboard ((_txt splitString "<>") select { _x != "br/" } joinString endl);
