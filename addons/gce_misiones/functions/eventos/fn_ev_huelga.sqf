/*
    Evento: Huelga
    Los obreros de una fábrica enemiga paran. En 3 minutos llega la policía a reprimirla.
    - Si en 15 minutos la policía ha caído (o hay rebeldes defendiendo la fábrica): la huelga triunfa,
      el enemigo pierde producción (recursos) y sube nuestro apoyo en el pueblo más cercano.
    - Si no: la huelga se reprime; el enemigo pierde algo de producción igualmente y el pueblo se indigna.
*/
params ["_datos"];
_datos params ["_fabrica"];
private _c = getMarkerPos _fabrica;
private _nom = [_fabrica] call A3A_fnc_localizar;
private _lado = sidesX getVariable [_fabrica, Occupants];
private _f = [_lado] call GCE_fnc_faction;
private _ciudad = [citiesX, _c] call BIS_fnc_nearestPosition;

// huelguistas
private _tipoCiv = A3A_faction_civ get "unitMan";
if (_tipoCiv isEqualType []) then { _tipoCiv = selectRandom _tipoCiv };
private _grpCiv = createGroup civilian;
for "_i" from 1 to 6 do {
    private _u = [_grpCiv, _tipoCiv, _c getPos [10 + random 15, random 360], [], 0, "NONE"] call A3A_fnc_createUnit;
    _u setBehaviour "CARELESS";
    _u disableAI "MOVE";
};

private _tid = [format ["Huelga en %1", _nom],
    format ["Los obreros de %1 se han declarado en huelga. %2 manda a la policía a reprimirla en 3 minutos. Defiende a los huelguistas: si la huelga triunfa, el enemigo perderá producción.", _nom, _f get "name"],
    _c, "defend"] call GCE_fnc_taskCreate;
[format ["¡Huelga en %1! Viene la policía a reventarla.", _nom], "Huelga"] call GCE_fnc_comms;

sleep 180;
private _base = [_c] call GCE_fnc_enemyBase;
private _desde = if (_base isEqualTo []) then { _c getPos [600, random 360] } else { _base select 1 };
private _tiposPolicia = _f getOrDefault ["groupPoliceSquad", []];
private _policia = if (_tiposPolicia isNotEqualTo []) then {
    [[_c, _desde, 500] call GCE_fnc_spawnPos, _lado, _tiposPolicia] call A3A_fnc_spawnGroup
} else {
    [[_c, _desde, 500] call GCE_fnc_spawnPos, _lado, "militia"] call GCE_fnc_spawnSquad
};
private _w = _policia addWaypoint [_c, 20];
_w setWaypointType "SAD";
["La policía llega a la fábrica.", "Huelga"] call GCE_fnc_comms;

private _limite = time + 720;
waitUntil { sleep 5; ({ alive _x } count units _policia) == 0 || {time > _limite} };

private _triunfa = ({ alive _x } count units _policia) == 0 || {([_c, 200] call GCE_fnc_rebelsNear) > 0 && {([_c, 200] call GCE_fnc_enemiesNear) == 0}};
if (_triunfa) then {
    [_tid, "SUCCEEDED"] call BIS_fnc_taskSetState;
    [format ["¡La huelga de %1 triunfa! La fábrica no producirá para el enemigo.", _nom], "Huelga"] call GCE_fnc_comms;
    [-150, _lado, "defence"] call A3A_fnc_addEnemyResources;
    [-100, _lado, "attack"] call A3A_fnc_addEnemyResources;
    [200, 1, _ciudad, 10, 6] call GCE_fnc_reward;
} else {
    [_tid, "FAILED"] call BIS_fnc_taskSetState;
    ["Han reprimido la huelga. El pueblo no lo olvidará.", "Huelga"] call GCE_fnc_comms;
    [-50, _lado, "defence"] call A3A_fnc_addEnemyResources;
    [0, 0, _ciudad, 3, 0] call GCE_fnc_reward;
};
GCE_eventoActivo = "";
[_tid] spawn { sleep 600; [_this select 0] call BIS_fnc_deleteTask };
[[_grpCiv, _policia]] spawn GCE_fnc_cleanup;
