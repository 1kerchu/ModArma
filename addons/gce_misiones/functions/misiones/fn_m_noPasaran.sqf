/*
    ¡No pasarán!  — defender un pueblo NUESTRO de varias oleadas enemigas.

    Fases:
      1. Al empezar: zona de defensa en el mapa y barricadas de sacos terreros en las entradas
         (las han levantado los vecinos).
      2. Espera a que llegue un jugador (máx. 10 min) y da 90 s para prepararse.
      3. Se unen 5 voluntarios del pueblo, armados.
      4. Oleadas (3-5): llegan en camiones por carretera, desembarcan a ~380 m y asaltan.
         - 1.ª oleada: milicia, por el eje de su base.
         - Oleadas pares: por un FLANCO.
         - Última: tropa regular por el eje + grupo por el flanco + blindado (si la guerra está avanzada).
         - Un grupo que pierde el 60 % de sus hombres se retira.
      5. Resultado y recompensa según cómo haya ido:
         voluntarios vivos, civiles muertos, y si el enemigo llegó a entrar en el centro.

    Fallo: el pueblo cambia de manos, o la zona se queda 90 s sin defensores con enemigos dentro.
*/
params ["_datos", "_nombre"];
_datos params ["_ciudad"];
private _c = getMarkerPos _ciudad;
private _nom = [_ciudad] call A3A_fnc_localizar;
([_c] call GCE_fnc_enemyBase) params ["_lado", "_basePos"];
private _f = [_lado] call GCE_fnc_faction;
private _R = 200;                       // radio de la zona de defensa
private _eje = _c getDir _basePos;      // dirección por la que viene el ataque principal

// ---------- utilidades ----------
private _rumbo = {
    params ["_d"];
    _d = (_d + 360) mod 360;
    ["el norte", "el noreste", "el este", "el sureste", "el sur", "el suroeste", "el oeste", "el noroeste"]
        select ((round (_d / 45)) mod 8)
};
// punto en carretera (si la hay) a una distancia y rumbo desde el centro
private _entrada = {
    params ["_d", "_dist"];
    private _p = _c getPos [_dist, _d];
    private _r = _p nearRoads 200;
    if (_r isEqualTo []) then {
        [_p, 0, 150, 4, 0, 0.4, 0, [], [_p, _p]] call BIS_fnc_findSafePos
    } else {
        getPosATL ([_r, _p] call BIS_fnc_nearestPosition)
    }
};
private _hintEstado = {
    params ["_texto"];
    [petros, "hint", _texto, "¡No pasarán!"] remoteExec ["A3A_fnc_commsMP", 0];
};

// ---------- 1. zona y barricadas ----------
private _mZona = createMarker ["GCE_np_zona", _c];
_mZona setMarkerShape "ELLIPSE";
_mZona setMarkerSize [_R, _R];
_mZona setMarkerColor "ColorBlue";
_mZona setMarkerBrush "FDiagonal";
_mZona setMarkerAlpha 0.5;
private _mTexto = createMarker ["GCE_np_texto", _c];
_mTexto setMarkerType "mil_flag";
_mTexto setMarkerColor "ColorBlue";
_mTexto setMarkerText "¡No pasarán!";

private _barricadas = [];
{
    private _d = _x;
    private _p = [_d, 260] call _entrada;
    {
        _x params ["_tipo", "_dist", "_ang"];
        private _o = createVehicle [_tipo, _p getPos [_dist, _d + _ang], [], 0, "CAN_COLLIDE"];
        _o setDir _d;
        _o setVectorUp (surfaceNormal (getPos _o));
        _barricadas pushBack _o;
    } forEach [
        ["Land_BagFence_Long_F", 0, 0],
        ["Land_BagFence_Long_F", 3.5, 90],
        ["Land_BagFence_Long_F", 3.5, -90],
        ["Land_BagFence_Round_F", 6.5, 90]
    ];
} forEach [_eje, _eje + 90, _eje - 90];

private _tid = [format ["¡No pasarán! — %1", _nom],
    format ["%1 prepara un ataque sobre %2 desde %3. Los vecinos han levantado barricadas en las entradas. Ve al pueblo: atacarán 90 segundos después de que llegues (como mucho en 10 minutos). Defiende la zona marcada hasta romper todas las oleadas.",
        _f get "name", _nom, [_eje] call _rumbo],
    _c, "defend"] call GCE_fnc_taskCreate;
[format ["¡%1 va a por %2! Los vecinos ya levantan barricadas. ¡Todos allí!", _f get "name", _nom], "¡No pasarán!"] call GCE_fnc_comms;

// ---------- 2. llegada ----------
if ([_c, 500, 600] call GCE_fnc_waitArrival) then {
    [format ["En posición. El ataque principal vendrá desde %1. Atacan en 90 segundos.", [_eje] call _rumbo], "¡No pasarán!"] call GCE_fnc_comms;
    sleep 90;
};

// ---------- 3. voluntarios ----------
private _grpVol = createGroup teamPlayer;
private _uniformesCiv = A3A_faction_civ get "uniforms";
for "_i" from 1 to 5 do {
    private _u = [_grpVol, A3A_faction_reb get "unitRifle", _c getPos [random 40, random 360], [], 0, "NONE"] call A3A_fnc_createUnit;
    [_u] call A3A_fnc_FIAinit;
    if (_uniformesCiv isNotEqualTo []) then {
        private _cosas = uniformItems _u;
        _u forceAddUniform (selectRandom _uniformesCiv);
        { _u addItemToUniform _x } forEach _cosas;
    };
};
[_grpVol, _c, 100] call CBA_fnc_taskDefend;
["Cinco vecinos han cogido las escopetas y los fusiles viejos: luchan con vosotros.", "¡No pasarán!"] call GCE_fnc_comms;

// civiles muertos en el pueblo durante la defensa
GCE_npCentro = _c;
GCE_npCivMuertos = 0;
private _eh = addMissionEventHandler ["EntityKilled", {
    params ["_v"];
    if (!isNil "GCE_npCentro" && {_v isKindOf "CAManBase"} && {side group _v == civilian} && {_v distance2D GCE_npCentro < 400}) then {
        GCE_npCivMuertos = GCE_npCivMuertos + 1;
    };
}];

// ---------- 4. oleadas ----------
// devuelve [gruposInfanteria, gruposVehiculo]
private _lanzarOleada = {
    params ["_dir", "_tipo", ["_conCamion", true]];
    private _spawn = [_dir, 1300] call _entrada;
    private _bajada = [_dir, 380] call _entrada;
    private _inf = [_spawn, _lado, _tipo] call GCE_fnc_spawnSquad;
    private _infs = [_inf];
    private _vehs = [];

    private _tiposCamion = if (_tipo == "militia") then { _f get "vehiclesMilitiaTrucks" } else { _f get "vehiclesTrucks" };
    if (_tiposCamion isEqualTo []) then { _tiposCamion = _f get "vehiclesTrucks" };

    if (_conCamion && {_tiposCamion isNotEqualTo []}) then {
        private _r = [_spawn, _spawn getDir _c, selectRandom _tiposCamion, _lado] call BIS_fnc_spawnVehicle;
        _r params ["_veh", "_crew", "_gCamion"];
        _vehs pushBack _gCamion;
        { if ((_veh emptyPositions "cargo") > 0) then { _x assignAsCargo _veh; _x moveInCargo _veh } } forEach units _inf;
        // los que no caben van a pie en otro grupo
        private _aPie = (units _inf) select { vehicle _x == _x };
        if (_aPie isNotEqualTo []) then {
            private _g2 = createGroup _lado;
            _aPie joinSilent _g2;
            private _w2 = _g2 addWaypoint [_c, 40];
            _w2 setWaypointType "SAD";
            _g2 setCombatMode "RED";
            _infs pushBack _g2;
        };
        private _w = _gCamion addWaypoint [_bajada, 0];
        _w setWaypointType "MOVE";
        _gCamion setBehaviour "AWARE";
        _gCamion setSpeedMode "FULL";
        // desembarco: al llegar, si el camión sufre daños o se queda parado
        [_veh, _inf, _bajada, _c] spawn {
            params ["_veh", "_inf", "_bajada", "_c"];
            private _t = time + 300;
            waitUntil {
                sleep 2;
                !alive _veh || {_veh distance2D _bajada < 60} || {damage _veh > 0.4} || {!canMove _veh} || {time > _t}
                || {((units _inf) findIf { alive _x && {vehicle _x == _veh} }) == -1}
            };
            { unassignVehicle _x; if (vehicle _x == _veh) then { moveOut _x } } forEach units _inf;
            (units _inf) allowGetIn false;
            private _w = _inf addWaypoint [_c, 40];
            _w setWaypointType "SAD";
            _inf setCurrentWaypoint _w;
            _inf setBehaviour "AWARE";
            _inf setCombatMode "RED";
            _inf setSpeedMode "FULL";
        };
    } else {
        private _w = _inf addWaypoint [_c, 40];
        _w setWaypointType "SAD";
        _inf setCombatMode "RED";
        _inf setSpeedMode "FULL";
    };
    [_infs, _vehs]
};

private _oleadas = 3 + floor (tierWar / 4);
private _todos = [];          // [grupo, hombresIniciales, retirado, oleada, esInfanteria]
private _fallo = false;
private _sinDefensa = 0;
private _tiempoCentro = 0;
private _olaActual = 0;

private _vigilar = {
    // defensa de la zona
    if (([_c, _R] call GCE_fnc_rebelsNear) == 0 && {([_c, _R] call GCE_fnc_enemiesNear) > 0}) then {
        _sinDefensa = _sinDefensa + 5;
    } else { _sinDefensa = 0 };
    if (_sinDefensa >= 90 || {(sidesX getVariable [_ciudad, sideUnknown]) != teamPlayer}) then { _fallo = true };
    // ¿han entrado en el centro?
    if (([_c, 60] call GCE_fnc_enemiesNear) > 0) then { _tiempoCentro = _tiempoCentro + 5 };
    // moral: un grupo de infantería que pierde el 60 % se retira
    {
        _x params ["_g", "_ini", "_ret", "_ola", "_esInf"];
        if (_esInf && {!_ret} && {!isNull _g} && {_ini > 2}) then {
            private _vivos = { alive _x } count units _g;
            if (_vivos > 0 && {_vivos < _ini * 0.4}) then {
                _x set [2, true];
                [_g] call CBA_fnc_clearWaypoints;
                private _w = _g addWaypoint [_basePos, 50];
                _w setWaypointType "MOVE";
                _g setBehaviour "AWARE";
                _g setCombatMode "YELLOW";
                _g setSpeedMode "FULL";
                [format ["¡Un grupo de la oleada %1 se retira!", _ola], "¡No pasarán!"] call GCE_fnc_comms;
            };
        };
    } forEach _todos;
};
private _atacantes = {
    private _n = 0;
    { _x params ["_g", "", "_ret"]; if (!_ret && {!isNull _g}) then { _n = _n + ({ alive _x && {_x distance2D _c < 900} } count units _g) } } forEach _todos;
    _n
};

for "_i" from 1 to _oleadas do {
    _olaActual = _i;
    private _esUltima = _i == _oleadas;
    private _flanco = _eje + (selectRandom [90, -90]) + (random 30 - 15);
    private _dir = if (_i > 1 && {_i mod 2 == 0}) then { _flanco } else { _eje + (random 20 - 10) };
    private _tipo = ["squad", "militia"] select (_i == 1);
    private _extra = "";

    ([_dir, _tipo] call _lanzarOleada) params ["_infs", "_vehs"];
    if (_esUltima) then {
        ([_flanco, "medium", false] call _lanzarOleada) params ["_infs2"];
        _infs append _infs2;
        _extra = format [" y por %1", [_flanco] call _rumbo];
        if (tierWar >= 4) then {
            private _blind = if (tierWar >= 7) then { (_f get "vehiclesLightTanks") + (_f get "vehiclesAPCs") } else { _f get "vehiclesLightArmed" };
            private _vg = [[_eje, 1300] call _entrada, _lado, _blind, _c] call GCE_fnc_spawnVehicle;
            if (!isNull _vg) then { _vehs pushBack _vg; _extra = _extra + ", con blindados" };
        };
    };
    { _todos pushBack [_x, count units _x, false, _i, true] } forEach _infs;
    { _todos pushBack [_x, count units _x, false, _i, false] } forEach _vehs;

    [format ["Oleada %1 de %2: vienen en camiones por %3%4.", _i, _oleadas, [_dir] call _rumbo, _extra], "¡No pasarán!"] call GCE_fnc_comms;

    private _t = time + 150;
    private _proxEstado = time + 60;
    waitUntil {
        sleep 5;
        call _vigilar;
        if (time > _proxEstado) then {
            _proxEstado = time + 60;
            [format ["Oleada %1 de %2<br/>Atacantes cerca: %3<br/>Enemigos dentro de la zona: %4<br/>Defensores en la zona: %5",
                _olaActual, _oleadas, call _atacantes, [_c, _R] call GCE_fnc_enemiesNear, [_c, _R] call GCE_fnc_rebelsNear]] call _hintEstado;
        };
        _fallo || {time > _t}
    };
    if (_fallo) exitWith {};
};

if (!_fallo) then {
    ["Es la última oleada. ¡Aguantad!", "¡No pasarán!"] call GCE_fnc_comms;
    private _t = time + 360;
    waitUntil { sleep 5; call _vigilar; _fallo || {time > _t} || {(call _atacantes) == 0} };
};

// ---------- 5. resultado ----------
removeMissionEventHandler ["EntityKilled", _eh];
GCE_npCentro = nil;
deleteMarker _mZona;
deleteMarker _mTexto;

private _voluntarios = { alive _x } count units _grpVol;
private _civMuertos = GCE_npCivMuertos;
private _entraron = _tiempoCentro >= 30;

if (_fallo) then {
    [_tid, "FAILED"] call GCE_fnc_endMission;
    [format ["%1 ha caído.", _nom], "¡No pasarán!"] call GCE_fnc_comms;
    [0, -10, _ciudad] call A3A_fnc_citySupportChange;
} else {
    [_tid, "SUCCEEDED"] call GCE_fnc_endMission;
    private _dinero = 300 + 100 * _oleadas + 50 * _voluntarios;
    if (_entraron) then { _dinero = round (_dinero * 0.6) };
    private _apoyo = ((15 - 3 * _civMuertos) max 0) - ([0, 5] select _entraron);
    private _hr = 1 + _voluntarios;
    [format ["¡No han pasado! %1 sigue en pie.<br/><br/>Voluntarios vivos: %2 (se unen a las milicias)<br/>Civiles muertos: %3<br/>%4<br/><br/>Recompensa: %5 de dinero, +%6 hombres, apoyo %7%8",
        _nom, _voluntarios, _civMuertos,
        ["El enemigo no llegó al centro.", "El enemigo llegó a entrar en el centro del pueblo."] select _entraron,
        _dinero, _hr, ["", "+"] select (_apoyo >= 0), _apoyo], "¡No pasarán!"] call GCE_fnc_comms;
    [_dinero, _hr, _ciudad, _apoyo, 10] call GCE_fnc_reward;
};

// los que quedan se retiran a su base
{
    _x params ["_g"];
    if (!isNull _g) then {
        [_g] call CBA_fnc_clearWaypoints;
        private _w = _g addWaypoint [_basePos, 50];
        _g setCurrentWaypoint _w;
    };
} forEach _todos;

[(_todos apply { _x select 0 }) + [_grpVol] + _barricadas] spawn GCE_fnc_cleanup;
