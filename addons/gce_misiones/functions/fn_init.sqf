/*
    GCE_fnc_init (postInit)
    Prepara variables del servidor y añade las acciones al jugador cuando Antistasi está listo.
*/
if (isServer) then {
    GCE_misionActiva = "";
    publicVariable "GCE_misionActiva";
    if (isNil "GCE_oroDistanciaMax") then { GCE_oroDistanciaMax = 3000 };   // metros hasta la costa

    // Médico rebelde: Antistasi lanza este evento después de equipar a cada recluta
    ["A3A_event_serverInitRebelUnit", {
        params ["_u"];
        if (!isNil "A3A_faction_reb" && {(_u getVariable ["unitType", ""]) isEqualTo (A3A_faction_reb get "unitMedic")}) then {
            [_u] remoteExec ["GCE_fnc_morralMedico", _u];
        };
        // todos los soldados rebeldes con radio (para oír y dar avisos por radio)
        [_u] remoteExec ["GCE_fnc_darRadio", _u];
    }] call CBA_fnc_addEventHandler;

    [] spawn GCE_fnc_brigadasMonitor;
    [] spawn GCE_fnc_eventosLoop;
};

if (!hasInterface) exitWith {};

[] spawn {
    waitUntil { sleep 2; !isNull player && {!isNil "teamPlayer"} && {!isNil "A3A_faction_reb"} && {!isNil "petros"} };
    [] call GCE_fnc_addPlayerActions;
    [player] call GCE_fnc_darRadio;
    player addEventHandler ["Respawn", { [] spawn { sleep 1; [] call GCE_fnc_addPlayerActions; [player] call GCE_fnc_darRadio } }];
};
