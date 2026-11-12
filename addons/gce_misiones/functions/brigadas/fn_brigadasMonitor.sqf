/*
    GCE_fnc_brigadasMonitor  (servidor, spawn)

    Las Brigadas Internacionales llegan en dos oleadas según avanza la guerra (nivel de guerra 3 y 6):
      - aviso a todos, +6 de recursos humanos en cada llegada,
      - desde la primera llegada se puede reclutar BRIGADISTAS junto a Petros.
    Al cargar una partida ya avanzada se activan sin aviso.
*/
waitUntil { sleep 5; !isNil "tierWar" && {!isNil "petros"} && {!isNil "A3A_faction_reb"} };

private _llegadas = [[3, "¡Han llegado las Brigadas Internacionales! Voluntarios de medio mundo vienen a luchar con nosotros. Ya podéis reclutar brigadistas junto a Petros."],
                     [6, "Llega una nueva oleada de brigadistas: más voluntarios para el frente."]];
private _hechas = { (_x select 0) <= tierWar } count _llegadas;   // partida cargada: no repetir avisos
GCE_brigadas = _hechas > 0;
publicVariable "GCE_brigadas";

while { _hechas < count _llegadas } do {
    sleep 60;
    (_llegadas select _hechas) params ["_nivel", "_texto"];
    if (tierWar >= _nivel) then {
        _hechas = _hechas + 1;
        GCE_brigadas = true;
        publicVariable "GCE_brigadas";
        [_texto, "Brigadas Internacionales"] call GCE_fnc_comms;
        [6, 0] call A3A_fnc_resourcesFIA;
    };
};
