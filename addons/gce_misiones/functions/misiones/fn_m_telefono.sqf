/*
    Cortar la línea telefónica — sabotaje con sigilo.

    - De una base enemiga sale una línea telefónica hacia nuestro lado: 4 postes junto a la carretera,
      entre 400 y 850 m de la base, marcados en el mapa. La recorre una patrulla.
    - Cuando un jugador llega cerca de la línea empieza la cuenta: 12 minutos para tirar 3 de los 4 postes
      (carga explosiva junto al poste, o derribarlo como sea).
    - Sigilo: si el enemigo detecta a un rebelde cerca de la línea, da la ALARMA y manda un grupo
      de reacción desde la base. Hacerlo sin alarma da un premio extra.
    - Efecto real: la base queda incomunicada; el enemigo pierde recursos de DEFENSA (refuerza peor)
      y algo de ATAQUE.
*/
params ["_datos", "_nombre"];
_datos params ["_marcador"];
private _base = getMarkerPos _marcador;
private _nom = [_marcador] call A3A_fnc_localizar;
private _lado = sidesX getVariable [_marcador, Occupants];
private _hq = getMarkerPos respawnTeamPlayer;

// ---------- trazado de la línea: hacia nuestro lado, pegada a la carretera ----------
private _dirLinea = (_base getDir _hq) + (random 40 - 20);
private _postes = [];
private _marcadores = [];
{
    private _p = _base getPos [_x, _dirLinea];
    private _r = _p nearRoads 80;
    if (_r isNotEqualTo []) then {
        private _carretera = [_r, _p] call BIS_fnc_nearestPosition;
        // el poste va en el arcén, a 6 m de la carretera
        _p = (getPosATL _carretera) getPos [6, (_carretera getDir _base) + 90];
    };
    private _poste = createVehicle ["Land_PowerPoleWooden_F", _p, [], 0, "CAN_COLLIDE"];
    _poste setDir _dirLinea;
    _postes pushBack _poste;
    private _m = createMarker [format ["GCE_poste_%1", _forEachIndex], _p];
    _m setMarkerType "mil_dot";
    _m setMarkerColor "ColorRed";
    _m setMarkerText format ["Poste %1", _forEachIndex + 1];
    _marcadores pushBack _m;
} forEach [400, 550, 700, 850];

private _centro = _postes select 1;
private _caidos = {
    { !alive _x || {damage _x >= 0.9} || {(vectorUp _x) select 2 < 0.7} } count _postes
};

// ---------- patrulla ----------
private _grupos = [];
private _g = [(getPos _centro) getPos [30, random 360], _lado, "militia"] call GCE_fnc_spawnSquad;
[_g, getPos _centro, 300] call CBA_fnc_taskPatrol;
_grupos pushBack _g;

private _tid = [format ["Cortar la línea telefónica de %1", _nom],
    format ["%1 se comunica con el resto del frente por una línea telefónica (4 postes marcados en el mapa). Cuando llegues tendrás 12 minutos para tirar al menos 3 postes. Hazlo sin que te vean: si dan la alarma, mandarán un grupo desde la base. Sin teléfono, tardarán en pedir refuerzos.", _nom],
    getPos _centro, "destroy"] call GCE_fnc_taskCreate;
[format ["Hay que dejar incomunicado %1: cortad su línea de teléfono sin que os vean.", _nom], "Línea telefónica"] call GCE_fnc_comms;

// ---------- llegada (máx. 30 min) ----------
private _llegaron = [getPos _centro, 900, 1800] call GCE_fnc_waitArrival;
if (!_llegaron) exitWith {
    [_tid, "FAILED"] call GCE_fnc_endMission;
    ["Nadie ha ido a cortar la línea.", "Línea telefónica"] call GCE_fnc_comms;
    { deleteMarker _x } forEach _marcadores;
    [_grupos + _postes] spawn GCE_fnc_cleanup;
};
["Estáis junto a la línea: 12 minutos. Sin hacer ruido.", "Línea telefónica"] call GCE_fnc_comms;

// ---------- sabotaje ----------
private _alarma = false;
private _limite = time + 720;
private _cargasVistas = createHashMap;      // cargas junto a cada poste
waitUntil {
    sleep 2;
    // cargas junto a un poste: cuando estallan, el poste cae
    {
        private _poste = _x;
        private _k = str _forEachIndex;
        private _cargas = [getPos _poste, 6] call GCE_fnc_rebelCharges;
        if (_cargas isNotEqualTo []) then { _cargasVistas set [_k, true] };
        if ((_cargasVistas getOrDefault [_k, false]) && {_cargas isEqualTo []} && {alive _poste}) then {
            _poste setDamage 1;
            _cargasVistas set [_k, false];
        };
    } forEach _postes;
    { if (!alive _x || {damage _x >= 0.9}) then { (_marcadores select _forEachIndex) setMarkerColor "ColorGrey" } } forEach _postes;

    // alarma: el enemigo ha visto a un rebelde cerca de la línea
    if (!_alarma) then {
        private _rebeldes = (allUnits select { side group _x == teamPlayer && {alive _x} }) inAreaArray [getPos _centro, 600, 600];
        private _vistos = _rebeldes findIf {
            private _r = _x;
            (allGroups select { side _x == _lado && {(leader _x) distance2D _r < 600} }) findIf { (leader _x) knowsAbout _r > 1.5 } != -1
        };
        if (_vistos != -1) then {
            _alarma = true;
            ["¡Os han visto! Han dado la alarma: viene un grupo desde la base.", "Línea telefónica"] call GCE_fnc_comms;
            _grupos pushBack ([_base getPos [50, _dirLinea], _lado, "squad", getPos _centro, "SAD"] call GCE_fnc_spawnSquad);
        };
    };
    (call _caidos) >= 3 || {time > _limite}
};

{ deleteMarker _x } forEach _marcadores;
private _n = call _caidos;
if (_n >= 3) then {
    [-250, _lado, "defence"] call A3A_fnc_addEnemyResources;
    [-100, _lado, "attack"] call A3A_fnc_addEnemyResources;
    [_tid, "SUCCEEDED"] call GCE_fnc_endMission;
    private _dinero = if (_alarma) then { 300 } else { 500 };
    [format ["Línea cortada: %1 está incomunicado.%2", _nom,
        ["", " ¡Y sin que se enterasen!"] select (!_alarma)], "Línea telefónica"] call GCE_fnc_comms;
    [_dinero, 0, "", 0, [8, 12] select (!_alarma)] call GCE_fnc_reward;
} else {
    [_tid, "FAILED"] call GCE_fnc_endMission;
    [format ["Solo habéis tirado %1 postes: ya están reparando la línea.", _n], "Línea telefónica"] call GCE_fnc_comms;
};
[_grupos + _postes] spawn GCE_fnc_cleanup;
