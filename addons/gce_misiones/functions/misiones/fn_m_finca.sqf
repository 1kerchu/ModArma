/*
    Colectivizar la finca — en dos fases:
      1. Tomar una finca, mina o fábrica ENEMIGA (con la mecánica normal de Antistasi: bandera).
         Plazo: 60 minutos.
      2. En cuanto es nuestra, los trabajadores la colectivizan y el antiguo dueño contraataca:
         aguantar 10 minutos sin abandonarla.
*/
params ["_datos", "_nombre"];
_datos params ["_marcador"];
private _c = getMarkerPos _marcador;
private _nom = [_marcador] call A3A_fnc_localizar;
private _lado = sidesX getVariable [_marcador, Occupants];
private _ciudad = [citiesX, _c] call BIS_fnc_nearestPosition;

private _tid = [format ["Colectivizar %1", _nom],
    format ["Los trabajadores de %1 quieren colectivizarla, pero la controla el enemigo. Tómala (iza nuestra bandera) en menos de 60 minutos y defiéndela después del contraataque mientras se organiza la colectividad.", _nom],
    _c, "attack"] call GCE_fnc_taskCreate;
[format ["Los trabajadores de %1 esperan nuestra señal. ¡Hay que tomarla!", _nom], "Colectivizar la finca"] call GCE_fnc_comms;

// ---------- Fase 1: tomarla ----------
private _limite = time + 3600;
waitUntil { sleep 10; (sidesX getVariable [_marcador, sideUnknown]) == teamPlayer || {time > _limite} };

if ((sidesX getVariable [_marcador, sideUnknown]) != teamPlayer) exitWith {
    [_tid, "FAILED"] call GCE_fnc_endMission;
    ["No hemos llegado a tiempo: la colectividad tendrá que esperar.", "Colectivizar la finca"] call GCE_fnc_comms;
};

// ---------- Fase 2: colectivizar y aguantar el contraataque ----------
[format ["¡%1 es nuestra! Asamblea en marcha: aguantad 10 minutos, vienen a por ella.", _nom], "Colectivizar la finca"] call GCE_fnc_comms;
[_tid, _c] call BIS_fnc_taskSetDestination;
[_tid, ["La finca es nuestra. Los propietarios han llamado a sus pistoleros y a la milicia: protege la colectividad durante 10 minutos sin abandonarla.", format ["Colectivizar %1: defenderla", _nom], ""]] call BIS_fnc_taskSetDescription;

// El contraataque viene del antiguo dueño; si ya no tiene bases cerca, de la base enemiga más cercana
private _base = [_c] call GCE_fnc_enemyBase;
private _basePos = if (_base isEqualTo []) then { _c getPos [1500, random 360] } else { _base select 1 };
if (_base isNotEqualTo []) then { _lado = _base select 0 };

sleep 45;
private _grupos = [];
private _fallo = false;
private _sinDefensa = 0;
private _inicio = time;
private _oleadas = [[0, "militia"], [240, "militia"]];
if (tierWar >= 4) then { _oleadas pushBack [420, "squad"] };

waitUntil {
    sleep 5;
    {
        _x params ["_t", "_tipo"];
        if (time - _inicio >= _t) then {
            _grupos pushBack ([[_c, _basePos, 700] call GCE_fnc_spawnPos, _lado, _tipo, _c, "SAD"] call GCE_fnc_spawnSquad);
            _oleadas set [_forEachIndex, [1e9, ""]];
        };
    } forEach _oleadas;
    if (([_c, 200] call GCE_fnc_rebelsNear) == 0 && {([_c, 200] call GCE_fnc_enemiesNear) > 0}) then {
        _sinDefensa = _sinDefensa + 5;
    } else { _sinDefensa = 0 };
    if (_sinDefensa >= 90 || {(sidesX getVariable [_marcador, sideUnknown]) != teamPlayer}) then { _fallo = true };
    _fallo || {time - _inicio > 600}
};

if (_fallo) then {
    [_tid, "FAILED"] call GCE_fnc_endMission;
    ["Han disuelto la colectividad.", "Colectivizar la finca"] call GCE_fnc_comms;
} else {
    [_tid, "SUCCEEDED"] call GCE_fnc_endMission;
    ["¡La colectividad sigue adelante! Los jornaleros se unen a la causa.", "Colectivizar la finca"] call GCE_fnc_comms;
    [700, 2, _ciudad, 10, 8] call GCE_fnc_reward;
};
[_grupos] spawn GCE_fnc_cleanup;
