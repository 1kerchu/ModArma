/*
    Refugio antiaéreo — bombardeo sobre un pueblo NUESTRO protegido por una estática antiaérea.
    Hay que llevar a los civiles al refugio (acción "¡Sígueme al refugio!") y derribar aviones.
*/
params ["_datos", "_nombre"];
_datos params ["_ciudad", "_aire"];
_aire params ["_lado", "_aviones", "_aeroPos"];
private _c = getMarkerPos _ciudad;
private _nom = [_ciudad] call A3A_fnc_localizar;

// Refugio: el edificio grande más cercano al centro
private _casas = (nearestObjects [_c, ["House"], 200]) select { count ([_x] call BIS_fnc_buildingPositions) >= 4 };
private _ref = if (_casas isEqualTo []) then { _c } else { getPos (_casas select 0) };
private _mrk = createMarker ["GCE_refugio", _ref];
_mrk setMarkerType "mil_flag";
_mrk setMarkerColor "ColorBlue";
_mrk setMarkerText "Refugio";

private _tid = [format ["Refugio antiaéreo — %1", _nom],
    format ["La aviación enemiga va a bombardear %1. Lleva a los civiles al refugio marcado en el mapa (acción '¡Sígueme al refugio!') y derriba los aviones con la antiaérea. Llegan en 2 minutos.", _nom],
    _ref, "defend"] call GCE_fnc_taskCreate;
[format ["¡Aviación enemiga sobre %1 en 2 minutos! Todos al refugio.", _nom], "Refugio antiaéreo"] call GCE_fnc_comms;

// Civiles
private _tipoCiv = A3A_faction_civ get "unitMan";
if (_tipoCiv isEqualType []) then { _tipoCiv = selectRandom _tipoCiv };
private _grpCiv = createGroup civilian;
private _civs = [];
for "_i" from 1 to 10 do {
    private _p = _c getPos [40 + random 120, random 360];
    if (_p distance2D _ref < 50) then { _p = _ref getPos [70, random 360] };
    private _u = [_grpCiv, _tipoCiv, _p, [], 0, "NONE"] call A3A_fnc_createUnit;
    _u setBehaviour "CARELESS";
    _u allowFleeing 0;
    _u setVariable ["GCE_civRefugio", true, true];
    [_u] remoteExec ["GCE_fnc_accionCivil", 0, _u];
    _civs pushBack _u;
};

// Bucle de los civiles que siguen a un jugador
GCE_refugioActivo = true;
private _seguir = [_civs, _ref] spawn {
    params ["_civs", "_ref"];
    while { _civs findIf { alive _x && {!(_x getVariable ["GCE_aSalvo", false])} } != -1 && {!isNil "GCE_refugioActivo"} } do {
        {
            private _guia = _x getVariable ["GCE_sigue", objNull];
            if (alive _x && {!(_x getVariable ["GCE_aSalvo", false])} && {!isNull _guia}) then {
                if (_x distance2D _ref < 15) then {
                    _x setVariable ["GCE_aSalvo", true, true];
                    _x doMove _ref;
                    _x setUnitPos "DOWN";
                } else {
                    _x doMove (getPos _guia);
                };
            };
        } forEach _civs;
        sleep 3;
    };
};

sleep 120;

// Aviones
private _grupos = [];
private _nAviones = 2 + ([0, 1] select (tierWar >= 6));
for "_i" from 1 to _nAviones do {
    private _p = _c getPos [3500, (_c getDir _aeroPos) + (_i * 15)];
    _grupos pushBack ([_p, _lado, _aviones, _c, 400] call GCE_fnc_spawnVehicle);
};
private _vehs = _grupos apply { vehicle (leader _x) };
["¡Aviones a la vista!", "Refugio antiaéreo"] call GCE_fnc_comms;

// Bombardeo: bombas reales fuera del refugio mientras quede algún avión cerca
private _fin = time + 360;
waitUntil {
    sleep 15;
    if ((_vehs findIf { alive _x && {_x distance2D _c < 2500} }) != -1) then {
        for "_b" from 1 to 2 do {
            private _bp = _c getPos [random 180, random 360];
            if (_bp distance2D _ref > 45) then {
                private _bomba = createVehicle ["Bo_Mk82", [_bp select 0, _bp select 1, 80], [], 0, "CAN_COLLIDE"];
                _bomba setVelocity [0, 0, -80];
            };
        };
    };
    time > _fin || {(_vehs findIf { alive _x }) == -1}
};
GCE_refugioActivo = nil;

private _derribados = { !alive _x } count _vehs;
private _salvados = { alive _x && {_x getVariable ["GCE_aSalvo", false]} } count _civs;
{ private _w = _x addWaypoint [_aeroPos, 200]; _x setCurrentWaypoint _w } forEach (_grupos select { !isNull _x });

if (_salvados >= 5) then {
    [_tid, "SUCCEEDED"] call GCE_fnc_endMission;
    [format ["Se acabó el bombardeo. %1 civiles a salvo y %2 aviones derribados.", _salvados, _derribados], "Refugio antiaéreo"] call GCE_fnc_comms;
    [250 + 150 * _derribados, 0, _ciudad, 2 * _salvados, 10] call GCE_fnc_reward;
} else {
    [_tid, "FAILED"] call GCE_fnc_endMission;
    [format ["Solo %1 civiles llegaron al refugio.", _salvados], "Refugio antiaéreo"] call GCE_fnc_comms;
    [0, -10, _ciudad] call A3A_fnc_citySupportChange;
};
deleteMarker _mrk;
sleep 120;
{ _x setVariable ["GCE_sigue", nil, true] } forEach _civs;
[_grupos + [_grpCiv]] spawn GCE_fnc_cleanup;
