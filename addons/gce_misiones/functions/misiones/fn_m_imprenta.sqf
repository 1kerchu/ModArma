/*
    La imprenta clandestina — llevar un camión de propaganda desde el cuartel hasta una ciudad
    y descargar (60 s parado en el centro). Hay una emboscada por el camino.
*/
params ["_datos", "_nombre"];
_datos params ["_ciudad"];
private _c = getMarkerPos _ciudad;
private _nom = [_ciudad] call A3A_fnc_localizar;
private _hq = getMarkerPos respawnTeamPlayer;

private _tipos = (A3A_faction_reb get "vehiclesCivTruck") + (A3A_faction_reb get "vehiclesTruck");
private _pos = [_hq, 15, 120, 8, 0, 0.3, 0] call BIS_fnc_findSafePos;
private _camion = createVehicle [selectRandom _tipos, _pos, [], 0, "NONE"];
if (!isNil "A3A_fnc_AIVEHinit") then { [_camion, teamPlayer] call A3A_fnc_AIVEHinit };

private _tid = [format ["La imprenta: periódicos para %1", _nom],
    format ["Hay un camión cargado de periódicos y octavillas junto al cuartel. Llévalo al centro de %1 y espera 60 segundos parado para repartirlos. Cuidado con las emboscadas.", _nom],
    _c, "truck"] call GCE_fnc_taskCreate;
["El camión de la imprenta está listo en el cuartel.", "La imprenta"] call GCE_fnc_comms;

private _grupos = [];
private _emboscada = false;
private _parado = 0;
private _limite = time + 2400;
waitUntil {
    sleep 3;
    if (!_emboscada && {alive _camion} && {_camion distance2D _c < 1200}) then {
        _emboscada = true;
        private _base = [_c] call GCE_fnc_enemyBase;
        if (_base isNotEqualTo []) then {
            private _punto = _c getPos [400, _c getDir _camion];
            _grupos pushBack ([_punto getPos [80, random 360], _base select 0, "militia", _punto, "SAD"] call GCE_fnc_spawnSquad);
        };
    };
    if (alive _camion && {_camion distance2D _c < 80} && {speed _camion < 3}) then { _parado = _parado + 3 } else { _parado = 0 };
    !alive _camion || {_parado >= 60} || {time > _limite}
};

if (alive _camion && {_parado >= 60}) then {
    [_tid, "SUCCEEDED"] call GCE_fnc_endMission;
    [format ["Los periódicos corren por %1.", _nom], "La imprenta"] call GCE_fnc_comms;
    [200, 0, _ciudad, 20, 8] call GCE_fnc_reward;
} else {
    [_tid, "FAILED"] call GCE_fnc_endMission;
    ["La propaganda no ha llegado.", "La imprenta"] call GCE_fnc_comms;
};
[_grupos] spawn GCE_fnc_cleanup;
