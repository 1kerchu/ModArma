/*
    GCE_fnc_addPlayerActions
    Acciones en el menú de rueda del jugador (no dependen de que Petros cambie o se mueva el cuartel).
*/
{ player removeAction _x } forEach (player getVariable ["GCE_acciones", []]);

private _ids = [];
_ids pushBack (player addAction [
    "<t color='#E8B04A'>Misiones de la Guerra Civil</t>",
    { [player] remoteExec ["GCE_fnc_requestMenu", 2] },
    nil, 1.4, false, true, "",
    "side group _this == teamPlayer && {!isNil 'petros'} && {alive petros} && {_this distance petros < 6}"
]);
_ids pushBack (player addAction [
    "<t color='#C8102E'>Nombrar jefe de escuadra (100)</t>",
    { [cursorObject] call GCE_fnc_jefeNombrar },
    nil, 1.3, false, true, "",
    "call GCE_fnc_jefeCondNombrar"
]);
_ids pushBack (player addAction [
    "Retirar jefe de escuadra",
    { [cursorObject] call GCE_fnc_jefeRetirar },
    nil, 1.2, false, true, "",
    "call GCE_fnc_jefeCondRetirar"
]);
_ids pushBack (player addAction [
    "<t color='#C8102E'>Reclutar brigadista internacional (250)</t>",
    { [] spawn GCE_fnc_brigadistaReclutar },
    nil, 1.35, false, true, "",
    "call GCE_fnc_brigadistaCond"
]);
_ids pushBack (player addAction [
    "<t color='#4AA3E8'>Pedir apoyo aéreo (600)</t>",
    { [] spawn GCE_fnc_aereoPedir },
    nil, 0.5, false, true, "",
    "call GCE_fnc_aereoCond"
]);
_ids pushBack (player addAction [
    "<t color='#C8102E'>Ayuda soviética (comprar armas)</t>",
    { [] call GCE_fnc_sovMenu },
    nil, 1.33, false, true, "",
    "call GCE_fnc_sovCond"
]);
_ids pushBack (player addAction [
    "<t color='#C8B060'>Fortificaciones de época</t>",
    { [] call GCE_fnc_fortMenu },
    nil, 0.4, false, true, "",
    "missionNamespace getVariable ['GCE_fortPuedo', false] && {isNil 'GCE_fortFantasma'} && {vehicle player == player}"
]);
_ids pushBack (player addAction [
    "Desmontar fortificación (devuelve la mitad)",
    { [cursorObject, player] remoteExec ["GCE_fnc_fortQuitar", 2] },
    nil, 0.3, false, true, "",
    "!isNull cursorObject && {cursorObject getVariable ['GCE_fort', false]} && {player distance cursorObject < 6}"
]);
_ids pushBack (player addAction [
    "<t color='#E8B04A'>Transporte de enlace</t>",
    { [] call GCE_fnc_enlaceMenu },
    nil, 1.2, false, true, "",
    "missionNamespace getVariable ['GCE_enlacePuedo', false]"
]);
player setVariable ["GCE_acciones", _ids];

// Reactivar jefes de escuadra que se hayan quedado sin proceso (p. ej. al reaparecer)
{
    if (alive _x && {_x getVariable ["GCE_esJefe", false]} && {local _x}
        && {time - (_x getVariable ["GCE_jefeLatido", -1000]) > 10}) then {
        [_x] spawn GCE_fnc_jefeLoop;
    };
} forEach units group player;
