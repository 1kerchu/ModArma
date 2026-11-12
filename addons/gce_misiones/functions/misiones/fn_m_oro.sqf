/*
    El oro de la República — escoltar el camión del oro del cuartel a la costa (máx. GCE_oroDistanciaMax).
    Dos emboscadas por el camino. Éxito: 30 s parado junto al barco.
*/
params ["_datos", "_nombre"];
_datos params ["_destino"];
private _hq = getMarkerPos respawnTeamPlayer;

private _tipos = (A3A_faction_reb get "vehiclesTruck") + (A3A_faction_reb get "vehiclesCivTruck");
private _pos = [_hq, 15, 120, 8, 0, 0.3, 0] call BIS_fnc_findSafePos;
private _camion = createVehicle [selectRandom _tipos, _pos, [], 0, "NONE"];
if (!isNil "A3A_fnc_AIVEHinit") then { [_camion, teamPlayer] call A3A_fnc_AIVEHinit };

// Barco esperando en el agua junto al punto de entrega
private _agua = [];
for "_a" from 0 to 345 step 30 do {
    if (_agua isEqualTo [] && {surfaceIsWater (_destino getPos [120, _a])}) then { _agua = _destino getPos [120, _a] };
};
private _barco = objNull;
private _barcos = A3A_faction_reb get "vehiclesBoat";
if (_agua isNotEqualTo [] && {_barcos isNotEqualTo []}) then {
    _barco = createVehicle [selectRandom _barcos, _agua, [], 0, "NONE"];
};

private _mrk = createMarker ["GCE_oro", _destino];
_mrk setMarkerType "mil_end";
_mrk setMarkerColor "ColorYellow";
_mrk setMarkerText "Entrega del oro";

private _tid = ["El oro de la República",
    "Las reservas de oro tienen que salir por mar. Escolta el camión desde el cuartel hasta la costa (marcador amarillo) y espera 30 segundos parado. Si el camión se pierde, el oro se pierde.",
    _destino, "truck"] call GCE_fnc_taskCreate;
["El camión del oro está listo en el cuartel. ¡Que no lo toquen!", "El oro"] call GCE_fnc_comms;

// Emboscadas al 40 % y al 75 % del camino
private _total = _hq distance2D _destino;
private _emboscadas = [];
if (_total > 800) then {
    { _emboscadas pushBack [_hq getPos [_total * _x, _hq getDir _destino], false] } forEach [0.4, 0.75];
};
private _grupos = [];
private _parado = 0;
private _limite = time + 1800;
waitUntil {
    sleep 3;
    {
        _x params ["_punto", "_hecha"];
        if (!_hecha && {alive _camion} && {_camion distance2D _punto < 700}) then {
            _x set [1, true];
            private _base = [_punto] call GCE_fnc_enemyBase;
            if (_base isNotEqualTo []) then {
                _grupos pushBack ([_punto getPos [180, (_hq getDir _destino) + 90], _base select 0, "squad", _punto, "SAD"] call GCE_fnc_spawnSquad);
            };
        };
    } forEach _emboscadas;
    if (alive _camion && {_camion distance2D _destino < 50} && {speed _camion < 3}) then { _parado = _parado + 3 } else { _parado = 0 };
    !alive _camion || {_parado >= 30} || {time > _limite}
};

if (alive _camion && {_parado >= 30}) then {
    [_tid, "SUCCEEDED"] call GCE_fnc_endMission;
    ["El oro ya está a bordo. ¡Buen trabajo!", "El oro"] call GCE_fnc_comms;
    [2500, 0, "", 0, 15] call GCE_fnc_reward;
} else {
    [_tid, "FAILED"] call GCE_fnc_endMission;
    ["Hemos perdido el oro.", "El oro"] call GCE_fnc_comms;
};
deleteMarker _mrk;
[_grupos + ([[_barco], []] select (isNull _barco))] spawn GCE_fnc_cleanup;
