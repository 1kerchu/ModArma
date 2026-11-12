/*
    GCE_fnc_eventosLoop  (servidor, spawn)

    Cada 25-45 minutos (GCE_eventosIntervalo) puede ocurrir un evento, solo si tiene sentido:
      - Bombardeo por sorpresa: lanza la misión "Refugio antiaéreo" (solo si se cumplen sus condiciones
        y no hay otra misión GCE en marcha).
      - Desertores: soldados enemigos se pasan a nuestro bando y huyen hacia el cuartel perseguidos.
        (Necesita una base enemiga a menos de 5 km del cuartel.)
      - Huelga: los obreros de una fábrica enemiga paran; llega la policía a reprimirla.
        (Necesita una fábrica enemiga en rango.)
    Para desactivarlos: GCE_eventosActivos = false (en el servidor).
*/
waitUntil { sleep 10; !isNil "tierWar" && {!isNil "petros"} && {!isNil "A3A_faction_reb"} && {!isNil "GCE_misionActiva"} };
if (isNil "GCE_eventosActivos") then { GCE_eventosActivos = true };
if (isNil "GCE_eventosIntervalo") then { GCE_eventosIntervalo = [25, 45] };   // minutos
GCE_eventoActivo = "";

while { true } do {
    GCE_eventosIntervalo params ["_min", "_max"];
    sleep (60 * (_min + random (_max - _min)));

    private _hayJugadores = (allPlayers findIf { side group _x == teamPlayer && {alive _x} }) != -1;
    if (GCE_eventosActivos && {_hayJugadores} && {GCE_eventoActivo == ""}) then {
        private _hq = getMarkerPos respawnTeamPlayer;
        private _rango = if (isNil "distanceMission") then { 4000 } else { distanceMission };
        private _posibles = [];

        // Bombardeo: mismas condiciones que la misión del refugio
        if (GCE_misionActiva == "") then {
            private _ref = ([] call GCE_fnc_availability) select { (_x select 0) == "refugio" && {_x select 2} };
            if (_ref isNotEqualTo []) then { _posibles pushBack ["bombardeo", (_ref select 0) select 4] };
        };
        // Desertores: base enemiga cerca del cuartel
        private _base = [_hq, 5000] call GCE_fnc_enemyBase;
        if (_base isNotEqualTo []) then { _posibles pushBack ["desertores", _base] };
        // Huelga: fábrica enemiga en rango
        private _fabricas = factories select {
            (sidesX getVariable [_x, sideUnknown]) in [Occupants, Invaders] && {(getMarkerPos _x) distance2D _hq < _rango}
        };
        if (_fabricas isNotEqualTo []) then { _posibles pushBack ["huelga", [selectRandom _fabricas]] };

        if (_posibles isNotEqualTo []) then {
            (selectRandom _posibles) params ["_tipo", "_datos"];
            switch (_tipo) do {
                case "bombardeo": {
                    ["¡Bombardeo por sorpresa! La aviación enemiga va a por uno de nuestros pueblos.", "Evento"] call GCE_fnc_comms;
                    GCE_misionActiva = "Refugio antiaéreo";
                    publicVariable "GCE_misionActiva";
                    [_datos, "Refugio antiaéreo"] spawn GCE_fnc_m_refugio;
                };
                case "desertores": { GCE_eventoActivo = "Desertores"; [_datos] spawn GCE_fnc_ev_desertores };
                case "huelga":     { GCE_eventoActivo = "Huelga";     [_datos] spawn GCE_fnc_ev_huelga };
            };
        };
    };
};
