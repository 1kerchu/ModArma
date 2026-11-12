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
player setVariable ["GCE_acciones", _ids];
