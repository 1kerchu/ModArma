/*
    GCE_fnc_jefeLoop  [jefe]   (donde el jefe es local: el cliente del jugador que lo manda)

    Cada 3 segundos el jefe:
      1. mira qué enemigos conoce el grupo (NO los "revela": así cada soldado sigue avisando
         por radio de lo que descubre, como en el juego normal),
      2. reparte los blancos entre los enemigos que cada soldado ya ve:
           - quien lleva antitanque  -> el vehículo enemigo más cercano
           - ametralladoras          -> el enemigo con más compañeros alrededor (grupos)
           - el resto                -> el enemigo más cercano con menos de 2 tiradores asignados
      3. da las órdenes por radio CON VOZ (las del menú de mando del juego: "3, 4, target that
         soldier, 200 meters, front" / "fire"). Las pronuncia el líder del grupo, porque Arma solo
         deja dar órdenes con voz al líder. Los avisos de "enemy soldier, 200 meters" los dan los
         propios soldados al descubrir enemigos.
    Respeta el modo de combate: si mandas "no disparar", solo apuntan. El movimiento lo mandas tú.
    Estado: [] call GCE_fnc_jefeEstado
*/
params ["_jefe"];
private _grp = group _jefe;

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
                        // se agrupan los soldados por blanco: una sola orden "3, 4, target that soldier"
                        private _o = _ordenes getOrDefault [_k, [_blanco, []]];
                        (_o select 1) pushBack _u;
                        _ordenes set [_k, _o];
                    };
                };
            } forEach _miembros;

            // Órdenes por radio CON VOZ, como las del menú de mando del juego:
            // "3, 4, target that soldier, 200 meters, front" + "fire" si el grupo puede disparar.
            // Las da el líder del grupo (Arma solo deja dar órdenes con voz al líder).
            // Como mucho 3 blancos por revisión para no saturar la radio; el resto, en la siguiente.
            private _n = 0;
            {
                if (_n < 3) then {
                    _y params ["_b", "_soldados"];
                    _soldados commandTarget _b;
                    if (_disparar) then { _soldados commandFire _b };
                    { _x setVariable ["GCE_blanco", _b] } forEach _soldados;
                    _n = _n + 1;
                };
            } forEach _ordenes;
        };
    };
    sleep 3;
};

{ _x setVariable ["GCE_blanco", nil] } forEach units _grp;
if (!alive _jefe) then {
    ["Jefe de escuadra", "Tu jefe de escuadra ha caído. Puedes nombrar a otro."] call A3A_fnc_customHint;
};
