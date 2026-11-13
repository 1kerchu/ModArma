/* GCE_fnc_accionRequisa  [caja]  (todos los clientes, JIP) */
params ["_caja"];
if (!hasInterface || {isNull _caja}) exitWith {};
_caja addAction [
    "<t color='#E8B04A'>Requisar las armas</t>",
    {
        params ["_caja"];
        if (([getPos _caja, 60] call GCE_fnc_enemiesNear) > 0) exitWith {
            ["Requisa de armas", "Aún quedan enemigos cerca de la armería."] call A3A_fnc_customHint;
        };
        _caja setVariable ["GCE_requisada", true, true];
    },
    nil, 6, true, true, "",
    "_this distance _target < 4 && {!(_target getVariable ['GCE_requisada', false])}"
];
