/* GCE_fnc_accionPreso  [preso]  (todos los clientes, JIP) */
params ["_u"];
if (!hasInterface || {isNull _u}) exitWith {};
_u addAction [
    "<t color='#E8B04A'>Liberar al preso</t>",
    { params ["_u", "_quien"]; [_u, _quien] remoteExec ["GCE_fnc_presoLiberar", 2] },
    nil, 6, true, true, "",
    "alive _target && {_this distance _target < 4} && {!(_target getVariable ['GCE_libre', false])}"
];
