/*
    GCE_fnc_jefeLoop  [jefe]   (donde el jefe es local: el cliente del jugador que lo manda)

    Cada 3 segundos el jefe:
      1. mira qué enemigos conoce el grupo (NO los "revela": así cada soldado sigue avisando
         por radio de lo que descubre, como en el juego normal),
      2. reparte los blancos entre los enemigos que cada soldado ya ve:
           - quien lleva antitanque  -> el vehículo enemigo más cercano
           - ametralladoras          -> el enemigo con más compañeros alrededor (grupos)
           - el resto                -> el enemigo más cercano con menos de 2 tiradores asignados
      3. da las órdenes por radio cuando cambia el reparto, y avisa de los vehículos nuevos.
    Respeta el modo de combate: si mandas "no disparar", solo apuntan. El movimiento lo mandas tú.
    Estado: [] call GCE_fnc_jefeEstado
*/
params ["_jefe"];
private _grp = group _jefe;
private _avisados = [];
private _ultimaRadio = 0;

private _apellido = { (name _this splitString " ") param [((count (name _this splitString " ")) - 1) max 0, name _this] };
private _rumbo = {
    params ["_obj"];
    private _hora = round ((player getRelDir _obj) / 30) mod 12;
    if (_hora == 0) then { _hora = 12 };
    _hora
};

while { alive _jefe && {_jefe getVariable ["GCE_esJefe", false]} && {group _jefe == _grp} } do {
    _jefe setVariable ["GCE_jefeLatido", time];
    if (lifeState _jefe != "INCAPACITATED") then {
        private _enemigos = (_jefe targets [true, 700]) select {
            alive _x && {(side group _x) != civilian} && {(_jefe knowsAbout _x) > 1.5}
        };
        _jefe setVariable ["GCE_jefeEnemigos", count _enemigos];

        if (_enemigos isNotEqualTo []) then {
            private _miembros = (units _grp) select {
                alive _x && {!isPlayer _x} && {local _x} && {lifeState _x != "INCAPACITATED"} && {vehicle _x == _x}
            };
            private _todosVeh = _enemigos select { !(_x isKindOf "CAManBase") };
            private _todosInf = _enemigos select { _x isKindOf "CAManBase" };
            private _cuenta = createHashMap;            // hashValue del blanco -> nº de tiradores
            private _disparar = (combatMode _grp) in ["YELLOW", "RED"];
            private _ordenes = createHashMap;           // hashValue del blanco -> [blanco, [nombres], tipo]

            {
                private _u = _x;
                // solo enemigos que este soldado ya ha visto (sin chivatazos: así sigue habiendo avisos por radio)
                private _vehiculos = _todosVeh select { (_u knowsAbout _x) > 1 };
                private _infanteria = _todosInf select { (_u knowsAbout _x) > 1 };
                private _blanco = objNull;
                private _tipo = "";
                private _anterior = _u getVariable ["GCE_blanco", objNull];
                private _tieneAT = (secondaryWeapon _u != "") && {(secondaryWeaponMagazine _u) isNotEqualTo []};
                private _esMG = (((primaryWeapon _u) call BIS_fnc_itemType) param [1, ""]) == "MachineGun";

                switch (true) do {
                    case (_tieneAT && {_vehiculos isNotEqualTo []}): {
                        _blanco = [_vehiculos, _u] call BIS_fnc_nearestPosition;
                        _tipo = getText (configOf _blanco >> "displayName");
                    };
                    case (_esMG && {_infanteria isNotEqualTo []}): {
                        private _mejor = -1;
                        {
                            private _e = _x;
                            private _n = { _x distance _e < 20 } count _todosInf;
                            if (_n > _mejor && {_u distance _e < 600}) then { _mejor = _n; _blanco = _e };
                        } forEach _infanteria;
                        _tipo = ["el enemigo", "el grupo enemigo"] select (_mejor > 1);
                    };
                    default {
                        if (alive _anterior && {_anterior in _infanteria} && {_u distance _anterior < 500}) then {
                            _blanco = _anterior;
                        } else {
                            private _libres = _infanteria select { (_cuenta getOrDefault [hashValue _x, 0]) < 2 };
                            if (_libres isEqualTo []) then { _libres = _infanteria };
                            if (_libres isNotEqualTo []) then { _blanco = [_libres, _u] call BIS_fnc_nearestPosition };
                        };
                        _tipo = "el enemigo";
                    };
                };

                if (!isNull _blanco) then {
                    private _k = hashValue _blanco;
                    _cuenta set [_k, (_cuenta getOrDefault [_k, 0]) + 1];
                    if (_blanco != _anterior) then {
                        _u setVariable ["GCE_blanco", _blanco];
                        _u doTarget _blanco;
                        if (_disparar) then { _u doFire _blanco };
                        // apuntar la orden para la radio
                        private _o = _ordenes getOrDefault [_k, [_blanco, [], _tipo]];
                        (_o select 1) pushBack (_u call _apellido);
                        _ordenes set [_k, _o];
                    };
                };
            } forEach _miembros;

            // Órdenes por radio (como mucho 2 mensajes cada 6 segundos)
            if (count _ordenes > 0 && {time > _ultimaRadio + 6}) then {
                _ultimaRadio = time;
                private _n = 0;
                {
                    if (_n < 2) then {
                        _y params ["_b", "_nombres", "_tipo"];
                        private _quien = if (count _nombres > 1) then {
                            ((_nombres select [0, count _nombres - 1]) joinString ", ") + " y " + (_nombres select (count _nombres - 1))
                        } else { _nombres select 0 };
                        _jefe groupChat format ["%1: ¡%2 a %3, a las %4, %5 metros!",
                            _quien, ["apuntad", "fuego"] select _disparar, _tipo, [_b] call _rumbo, round (player distance _b)];
                        _n = _n + 1;
                    };
                } forEach _ordenes;
            };

            // Aviso de vehículos nuevos
            {
                if !(_x in _avisados) then {
                    _avisados pushBack _x;
                    _jefe groupChat format ["¡%1 enemigo a las %2, %3 metros!",
                        getText (configOf _x >> "displayName"), [_x] call _rumbo, round (player distance _x)];
                };
            } forEach _todosVeh;
            _avisados = _avisados select { alive _x };
        };
    };
    sleep 3;
};

{ _x setVariable ["GCE_blanco", nil] } forEach units _grp;
if (!alive _jefe) then {
    ["Jefe de escuadra", "Tu jefe de escuadra ha caído. Puedes nombrar a otro."] call A3A_fnc_customHint;
};
