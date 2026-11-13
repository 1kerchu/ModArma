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

    // Guardado en la partida de Antistasi (eventos oficiales para mods externos)
    ["A3A_event_serverGameSave", { [_this select 0] call GCE_fnc_datosGuardar }] call CBA_fnc_addEventHandler;
    ["A3A_event_serverGameLoad", { [_this select 0] call GCE_fnc_datosCargar }] call CBA_fnc_addEventHandler;

    [] spawn GCE_fnc_brigadasMonitor;
    [] spawn GCE_fnc_eventosLoop;
    [] spawn GCE_fnc_voluntariosLoop;
    [] spawn GCE_fnc_pueblosLoop;
    [] spawn GCE_fnc_cuartelLoop;
};

if (!hasInterface) exitWith {};

[] spawn {
    waitUntil { sleep 2; !isNull player && {!isNil "teamPlayer"} && {!isNil "A3A_faction_reb"} && {!isNil "petros"} };
    [] call GCE_fnc_addPlayerActions;
    [player] call GCE_fnc_darRadio;
    [] spawn GCE_fnc_fortZonaLoop;
    player addEventHandler ["Respawn", { [] spawn { sleep 1; [] call GCE_fnc_addPlayerActions; [player] call GCE_fnc_darRadio } }];
};
