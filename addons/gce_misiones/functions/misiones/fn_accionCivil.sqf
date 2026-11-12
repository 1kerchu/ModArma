/* GCE_fnc_accionCivil  [civil]  (todos los clientes, JIP) */
params ["_civ"];
if (!hasInterface || {isNull _civ}) exitWith {};
_civ addAction [
    "<t color='#4AA3E8'>¡Sígueme al refugio!</t>",
    { params ["_civ", "_quien"]; [_civ, _quien] remoteExec ["GCE_fnc_civSeguir", 2] },
    nil, 6, true, true, "",
    "alive _target && {_this distance _target < 5} && {!(_target getVariable ['GCE_aSalvo', false])}"
];
