/*
    GCE_fnc_availability  -> [[id, nombre, disponible, motivo, datos], ...]   (servidor)

    Cada misión solo está disponible si tiene sentido ahora mismo.
    Si no lo está, "motivo" explica por qué y no se puede elegir.
*/
private _hq = getMarkerPos respawnTeamPlayer;
private _rango = if (isNil "distanceMission") then { 4000 } else { distanceMission };
private _km = (round (_rango / 100)) / 10;
private _res = [];

private _anadir = {
    params ["_id", "_nombre", "_candidatos", "_motivo"];
    if (_candidatos isEqualTo []) then {
        _res pushBack [_id, _nombre, false, _motivo, []];
    } else {
        _res pushBack [_id, _nombre, true, "", selectRandom _candidatos];
    };
};

private _esNuestro = { (sidesX getVariable [_this, sideUnknown]) == teamPlayer };
private _esEnemigo = { (sidesX getVariable [_this, sideUnknown]) in [Occupants, Invaders] };
private _enRango   = { (getMarkerPos _this) distance2D _hq < _rango };

// 1. ¡No pasarán!: solo en un pueblo NUESTRO, cerca, y con una base enemiga desde la que atacar.
private _c1 = citiesX select { (_x call _esNuestro) && {_x call _enRango} && {([getMarkerPos _x] call GCE_fnc_enemyBase) isNotEqualTo []} };
["noPasaran", "¡No pasarán! (defender un pueblo nuestro)", _c1 apply {[_x]},
    format ["no hay ningún pueblo nuestro a menos de %1 km", _km]] call _anadir;

// 2. Volar el polvorín: puesto, base o aeródromo enemigo en rango (a más de 800 m del cuartel).
private _bases = (outposts + milbases + airportsX) select {
    (_x call _esEnemigo) && {_x call _enRango} && {(getMarkerPos _x) distance2D _hq > 800}
};
["polvorin", "Volar el polvorín", _bases apply {[_x]},
    format ["no hay bases enemigas a menos de %1 km", _km]] call _anadir;

// 2b. Cortar la línea telefónica: igual, base enemiga en rango (la línea sale hacia nuestro lado).
["telefono", "Cortar la línea telefónica", _bases apply {[_x]},
    format ["no hay bases enemigas a menos de %1 km", _km]] call _anadir;

// 2c. Requisa de armas: pueblo ENEMIGO en rango (cuartel de su policía).
private _cReq = citiesX select { (_x call _esEnemigo) && {_x call _enRango} };
["requisa", "Requisa de armas (cuartel enemigo)", _cReq apply {[_x]},
    format ["no hay pueblos enemigos a menos de %1 km", _km]] call _anadir;

// 3. Colectivizar la finca: recurso o fábrica ENEMIGA cerca. Primero se conquista y luego se
//    defiende del contraataque mientras se colectiviza.
private _c3 = (resourcesX + factories) select { (_x call _esEnemigo) && {_x call _enRango} };
["finca", "Colectivizar la finca (tomarla y defenderla)", _c3 apply {[_x]},
    format ["no hay fincas, minas ni fábricas enemigas a menos de %1 km", _km]] call _anadir;

// 4. La imprenta: ciudad a más de 600 m del cuartel, en rango, donde nuestro apoyo sea bajo (< 80 %).
private _c4 = citiesX select {
    private _d = (getMarkerPos _x) distance2D _hq;
    _d > 600 && {_d < _rango} && {((A3A_townData getOrDefault [_x, [0,0,0,100]]) param [3, 100]) < 80}
};
["imprenta", "La imprenta clandestina (propaganda)", _c4 apply {[_x]},
    "no hay ciudades cercanas donde haga falta propaganda"] call _anadir;

// 5. Refugio antiaéreo: pueblo NUESTRO con una estática antiaérea nuestra a menos de 800 m,
//    y un enemigo con aeródromo y aviones.
private _aaTipos = (A3A_faction_reb get "staticAA") + (A3A_faction_occ get "staticAA") + (A3A_faction_inv get "staticAA");
private _aa = (missionNamespace getVariable ["staticsToSave", []]) select { alive _x && {typeOf _x in _aaTipos} };
private _aire = [_hq] call GCE_fnc_enemyAir;
if (_aa isEqualTo []) then {
    _res pushBack ["refugio", "Refugio antiaéreo", false, "necesitas una estática antiaérea propia", []];
} else {
    if (_aire isEqualTo []) then {
        _res pushBack ["refugio", "Refugio antiaéreo", false, "el enemigo no tiene aeródromo con aviones", []];
    } else {
        private _c5 = citiesX select {
            private _c = getMarkerPos _x;
            (_x call _esNuestro) && {_x call _enRango} && {(_aa findIf { _x distance2D _c < 800 }) != -1}
        };
        ["refugio", "Refugio antiaéreo", _c5 apply {[_x, _aire]},
            "ninguna estática antiaérea protege un pueblo nuestro (máx. 800 m)"] call _anadir;
    };
};

// 6. El oro: la costa tiene que estar a menos de GCE_oroDistanciaMax del cuartel y tener carretera.
private _max = missionNamespace getVariable ["GCE_oroDistanciaMax", 3000];
private _costas = [];
for "_a" from 0 to 345 step 15 do {
    for "_d" from 300 to _max step 150 do {
        if (surfaceIsWater (_hq getPos [_d, _a])) exitWith {
            private _orilla = _hq getPos [(_d - 150) max 150, _a];
            private _carreteras = _orilla nearRoads 300;
            if (_carreteras isNotEqualTo []) then {
                _costas pushBack [_d, getPosATL ([_carreteras, _orilla] call BIS_fnc_nearestPosition)];
            };
        };
    };
};
_costas sort true;   // la más cercana primero
["oro", "El oro de la República (escolta a la costa)", (_costas select [0, 1]) apply {[_x select 1]},
    format ["la costa está a más de %1 km del cuartel", (round (_max / 100)) / 10]] call _anadir;

// 7. Liberar el penal: puesto o base enemiga cerca.
private _c7 = (outposts + milbases) select { (_x call _esEnemigo) && {_x call _enRango} };
["penal", "Liberar el penal", _c7 apply {[_x]},
    format ["no hay puestos enemigos a menos de %1 km", _km]] call _anadir;

// Tiempo de espera: una misión recién hecha no se puede repetir enseguida
if (isNil "GCE_esperas") then { GCE_esperas = createHashMap };
{
    private _hasta = GCE_esperas getOrDefault [_x select 0, 0];
    if ((_x select 2) && {time < _hasta}) then {
        _x set [2, false];
        _x set [3, format ["disponible en %1 min", ceil ((_hasta - time) / 60)]];
    };
} forEach _res;

_res
