/*
    GCE_fnc_init (postInit)
    Prepara variables del servidor y añade las acciones al jugador cuando Antistasi está listo.
*/
if (isServer) then {
    GCE_misionActiva = "";
    publicVariable "GCE_misionActiva";
    GCE_puentesVolados = [];
    if (isNil "GCE_oroDistanciaMax") then { GCE_oroDistanciaMax = 3000 };   // metros hasta la costa
};

if (!hasInterface) exitWith {};

[] spawn {
    waitUntil { sleep 2; !isNull player && {!isNil "teamPlayer"} && {!isNil "A3A_faction_reb"} && {!isNil "petros"} };
    [] call GCE_fnc_addPlayerActions;
    player addEventHandler ["Respawn", { [] spawn { sleep 1; [] call GCE_fnc_addPlayerActions } }];
};
