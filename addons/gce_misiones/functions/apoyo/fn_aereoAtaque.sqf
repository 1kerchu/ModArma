/*
    GCE_fnc_aereoAtaque  [pos, jugador]  (servidor)

    Un avión rebelde (I-16 "Mosca" si está Secret Weapons; si no, el avión de la tienda rebelde)
    despega del aeródromo propio más cercano, ataca durante 3 minutos lo que encuentre a 300 m
    del punto marcado y vuelve. Cuesta 600 (de la facción si lo pide el comandante; si no, del
    jugador) y después hay 15 minutos de espera.
*/
params ["_pos", "_jugador"];
private _coste = 600;
private _aviso = {
    params ["_t"];
    [petros, "hint", _t, "Apoyo aéreo"] remoteExec ["A3A_fnc_commsMP", owner _jugador];
};
if (serverTime < (missionNamespace getVariable ["GCE_aereoHasta", 0])) exitWith { ["Los aviones están repostando."] call _aviso };

private _aeros = airportsX select { (sidesX getVariable [_x, sideUnknown]) == teamPlayer };
if (_aeros isEqualTo []) exitWith { ["No tenemos ningún aeródromo."] call _aviso };
private _tipos = A3A_faction_reb get "vehiclesPlane";
if (_tipos isEqualTo []) exitWith { ["No hay aviones disponibles para nuestro bando."] call _aviso };

// pago
private _esComandante = _jugador == theBoss;
private _dinero = if (_esComandante) then { server getVariable ["resourcesFIA", 0] } else { _jugador getVariable ["moneyX", 0] };
if (_dinero < _coste) exitWith { [format ["Hace falta %1 de dinero.", _coste]] call _aviso };
if (_esComandante) then { [0, -_coste] spawn A3A_fnc_resourcesFIA } else { [-_coste, _jugador] call A3A_fnc_addMoneyPlayer };

GCE_aereoHasta = serverTime + 15 * 60;
publicVariable "GCE_aereoHasta";

private _aero = getMarkerPos ([_aeros, _pos] call BIS_fnc_nearestPosition);
private _salida = _aero getPos [300, _aero getDir _pos];
private _r = [[_salida select 0, _salida select 1, 300], _aero getDir _pos, selectRandom _tipos, teamPlayer] call BIS_fnc_spawnVehicle;
_r params ["_avion", "_crew", "_grp"];
_grp setBehaviour "COMBAT";
_grp setCombatMode "RED";

// el piloto conoce a los enemigos de la zona
{ (driver _avion) reveal [_x, 4]; _grp reveal [_x, 4] } forEach ((allUnits + vehicles) select {
    (side group _x) in [Occupants, Invaders] && {alive _x} && {_x distance2D _pos < 300}
});
private _w = _grp addWaypoint [_pos, 0];
_w setWaypointType "SAD";

private _mrk = createMarker [format ["GCE_aereo_%1", round serverTime], _pos];
_mrk setMarkerType "mil_destroy";
_mrk setMarkerColor "ColorGreen";
_mrk setMarkerText "Ataque aéreo";
[format ["Un %1 despega hacia la zona marcada. Atacará durante 3 minutos.", getText (configOf _avion >> "displayName")], "Apoyo aéreo"] call GCE_fnc_comms;

private _fin = time + 180 + ((_salida distance2D _pos) / 80);
waitUntil { sleep 5; !alive _avion || {time > _fin} };
deleteMarker _mrk;

if (alive _avion) then {
    [_grp] call CBA_fnc_clearWaypoints;
    private _w2 = _grp addWaypoint [_aero getPos [2500, _pos getDir _aero], 0];
    _w2 setWaypointType "MOVE";
    ["El avión vuelve a la base.", "Apoyo aéreo"] call GCE_fnc_comms;
    sleep 90;
    { deleteVehicle _x } forEach (crew _avion);
    deleteVehicle _avion;
} else {
    ["Han derribado nuestro avión.", "Apoyo aéreo"] call GCE_fnc_comms;
};
deleteGroup _grp;
