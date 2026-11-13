/*
    GCE_fnc_voluntariosLoop  (servidor, spawn)

    Cada 30 minutos, los pueblos NUESTROS donde el apoyo rebelde es alto (>= 75 %) mandan voluntarios:
    +1 de recursos humanos por cada pueblo así (máximo +3 cada vez). Aviso con los nombres.
    Ajustes (servidor): GCE_voluntariosMinApoyo (75), GCE_voluntariosIntervalo (30 min).
*/
waitUntil { sleep 10; !isNil "tierWar" && {!isNil "petros"} && {!isNil "A3A_townData"} };
if (isNil "GCE_voluntariosMinApoyo") then { GCE_voluntariosMinApoyo = 75 };
if (isNil "GCE_voluntariosIntervalo") then { GCE_voluntariosIntervalo = 30 };

while { true } do {
    sleep (60 * GCE_voluntariosIntervalo);
    private _pueblos = citiesX select {
        (sidesX getVariable [_x, sideUnknown]) == teamPlayer
        && {((A3A_townData getOrDefault [_x, [0, 0, 0, 0]]) param [3, 0]) >= GCE_voluntariosMinApoyo}
    };
    if (_pueblos isNotEqualTo [] && {(allPlayers findIf { side group _x == teamPlayer }) != -1}) then {
        private _n = (count _pueblos) min 3;
        [_n, 0] call A3A_fnc_resourcesFIA;
        private _nombres = (_pueblos select [0, 3]) apply { [_x] call A3A_fnc_localizar };
        [format ["Llegan voluntarios de %1: +%2 hombres para las milicias.", _nombres joinString ", ", _n], "Voluntarios"] call GCE_fnc_comms;
    };
};
