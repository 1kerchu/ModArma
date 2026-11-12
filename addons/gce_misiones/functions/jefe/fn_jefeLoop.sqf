/*
    GCE_fnc_jefeLoop  [jefe]   (donde el jefe es local: el cliente del jugador que lo manda)

    Cada 3 segundos el jefe:
      1. comparte con el grupo los enemigos que conoce (reveal),
      2. reparte los blancos:
           - quien lleva antitanque  -> el blindado/vehículo más cercano
           - ametralladoras          -> el enemigo con más compañeros alrededor (grupos)
           - el resto                -> el enemigo más cercano que tenga menos de 2 tiradores asignados
      3. avisa por radio de los vehículos nuevos que detecta.
    Respeta el modo de combate que pongas: si mandas "no disparar", solo apuntan.
    El movimiento lo sigues mandando tú.
*/
params ["_jefe"];
private _grp = group _jefe;
private _avisados = [];

while { alive _jefe && {_jefe getVariable ["GCE_esJefe", false]} && {group _jefe == _grp} } do {
    if (lifeState _jefe != "INCAPACITATED") then {
        private _enemigos = (_jefe targets [true, 700]) select {
            alive _x && {(side group _x) != civilian} && {(_jefe knowsAbout _x) > 1.5}
        };
        if (_enemigos isNotEqualTo []) then {
            private _miembros = (units _grp) select {
                alive _x && {!isPlayer _x} && {local _x} && {lifeState _x != "INCAPACITATED"} && {vehicle _x == _x}
            };
            { private _m = _x; { _m reveal [_x, 2.5] } forEach _enemigos } forEach _miembros;

            private _vehiculos = _enemigos select { !(_x isKindOf "CAManBase") };
            private _infanteria = _enemigos select { _x isKindOf "CAManBase" };
            private _cuenta = createHashMap;
            private _disparar = (combatMode _grp) in ["YELLOW", "RED"];

            {
                private _u = _x;
                private _blanco = objNull;
                private _anterior = _u getVariable ["GCE_blanco", objNull];
                private _tieneAT = (secondaryWeapon _u != "") && {(secondaryWeaponMagazine _u) isNotEqualTo []};
                private _esMG = ((primaryWeapon _u) call BIS_fnc_itemType) param [1, ""] == "MachineGun";

                switch (true) do {
                    case (_tieneAT && {_vehiculos isNotEqualTo []}): {
                        _blanco = [_vehiculos, _u] call BIS_fnc_nearestPosition;
                    };
                    case (_esMG && {_infanteria isNotEqualTo []}): {
                        private _mejor = -1;
                        {
                            private _e = _x;
                            private _n = { _x distance _e < 20 } count _infanteria;
                            if (_n > _mejor && {_u distance _e < 600}) then { _mejor = _n; _blanco = _e };
                        } forEach _infanteria;
                    };
                    default {
                        // mantiene el blanco anterior si sigue siendo válido (evita que cambien sin parar)
                        if (alive _anterior && {_anterior in _infanteria} && {_u distance _anterior < 500}) then {
                            _blanco = _anterior;
                        } else {
                            private _libres = _infanteria select { (_cuenta getOrDefault [netId _x, 0]) < 2 };
                            if (_libres isEqualTo []) then { _libres = _infanteria };
                            if (_libres isNotEqualTo []) then { _blanco = [_libres, _u] call BIS_fnc_nearestPosition };
                        };
                    };
                };

                if (!isNull _blanco) then {
                    _cuenta set [netId _blanco, (_cuenta getOrDefault [netId _blanco, 0]) + 1];
                    if (_blanco != _anterior) then {
                        _u setVariable ["GCE_blanco", _blanco];
                        _u doTarget _blanco;
                        if (_disparar) then { _u doFire _blanco };
                    };
                };
            } forEach _miembros;

            // Aviso de vehículos nuevos
            {
                if !(_x in _avisados) then {
                    _avisados pushBack _x;
                    private _hora = round (((player getRelDir _x) / 30)) mod 12;
                    if (_hora == 0) then { _hora = 12 };
                    _jefe groupChat format ["¡%1 enemigo a las %2, %3 metros!",
                        getText (configOf _x >> "displayName"), _hora, round (player distance _x)];
                };
            } forEach _vehiculos;
            _avisados = _avisados select { alive _x };
        };
    };
    sleep 3;
};

{ _x setVariable ["GCE_blanco", nil] } forEach units _grp;
if (!alive _jefe) then {
    ["Jefe de escuadra", "Tu jefe de escuadra ha caído. Puedes nombrar a otro."] call A3A_fnc_customHint;
};
