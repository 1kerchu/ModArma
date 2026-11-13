/*
    GCE_fnc_aereoPedir  (cliente)
    Abre el mapa: con un clic eliges dónde atacará el avión.
*/
private _hasta = missionNamespace getVariable ["GCE_aereoHasta", 0];
if (serverTime < _hasta) exitWith {
    ["Apoyo aéreo", format ["Los aviones están repostando: disponible en %1 min.", ceil ((_hasta - serverTime) / 60)]] call A3A_fnc_customHint;
};
["Apoyo aéreo", "Haz clic en el mapa donde quieres el ataque (cuesta 600). Cierra el mapa para cancelar."] call A3A_fnc_customHint;
openMap true;
GCE_aereoEH = addMissionEventHandler ["MapSingleClick", {
    params ["_unidades", "_pos"];
    removeMissionEventHandler ["MapSingleClick", GCE_aereoEH];
    GCE_aereoEH = nil;
    openMap false;
    [_pos, player] remoteExec ["GCE_fnc_aereoAtaque", 2];
}];
[] spawn {
    waitUntil { sleep 0.5; !visibleMap };
    if (!isNil "GCE_aereoEH") then { removeMissionEventHandler ["MapSingleClick", GCE_aereoEH]; GCE_aereoEH = nil };
};
