/*
    GCE_fnc_fortColocar  [clase, precio]  (cliente)
    Muestra la fortificación "fantasma" 5 m delante del jugador. Acciones:
      Colocar aquí / Girar 45° / Cancelar.
*/
params ["_clase", "_precio"];
GCE_fortFantasma = createVehicleLocal [_clase, getPos player, [], 0, "CAN_COLLIDE"];
GCE_fortFantasma enableSimulation false;
GCE_fortFantasma allowDamage false;
GCE_fortGiro = 0;

GCE_fortEH = addMissionEventHandler ["EachFrame", {
    if (isNil "GCE_fortFantasma" || {isNull GCE_fortFantasma}) exitWith {};
    private _p = player getPos [5, getDir player];
    GCE_fortFantasma setPosATL [_p select 0, _p select 1, 0];
    GCE_fortFantasma setDir (getDir player + GCE_fortGiro);
    GCE_fortFantasma setVectorUp (surfaceNormal _p);
}];

private _fin = {
    removeMissionEventHandler ["EachFrame", GCE_fortEH];
    { player removeAction _x } forEach (player getVariable ["GCE_fortAcciones", []]);
    deleteVehicle GCE_fortFantasma;
    GCE_fortFantasma = nil;
};
GCE_fortFin = _fin;

private _ids = [];
_ids pushBack (player addAction [format ["<t color='#60FF60'>Colocar aquí (%1)</t>", _precio], {
    params ["", "", "", "_clase"];
    private _pos = getPosATL GCE_fortFantasma;
    private _dir = getDir GCE_fortFantasma;
    call GCE_fortFin;
    [_clase, _pos, _dir, player] remoteExec ["GCE_fnc_fortCrear", 2];
}, _clase, 10, true, true]);
_ids pushBack (player addAction ["<t color='#E8B04A'>Girar 45°</t>", { GCE_fortGiro = GCE_fortGiro + 45 }, nil, 9, false, true]);
_ids pushBack (player addAction ["<t color='#FF6060'>Cancelar</t>", { call GCE_fortFin }, nil, 8, false, true]);
player setVariable ["GCE_fortAcciones", _ids];

// si el jugador se aleja de la zona propia o muere, se cancela
[] spawn {
    waitUntil { sleep 1; isNil "GCE_fortFantasma" || {!alive player} || {!(missionNamespace getVariable ["GCE_fortPuedo", false])} };
    if (!isNil "GCE_fortFantasma") then { call GCE_fortFin };
};
