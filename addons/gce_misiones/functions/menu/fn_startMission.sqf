/* GCE_fnc_startMission  [id, jugador]  (servidor): vuelve a comprobar y lanza la misión */
params ["_id", "_jugador"];
if (GCE_misionActiva != "") exitWith {
    [petros, "hint", format ["Ya hay una misión en marcha: %1", GCE_misionActiva], "Misiones"] remoteExec ["A3A_fnc_commsMP", owner _jugador];
};
private _entrada = ([] call GCE_fnc_availability) select { (_x select 0) == _id };
if (_entrada isEqualTo []) exitWith {};
(_entrada select 0) params ["_id", "_nombre", "_ok", "_motivo", "_datos"];
if (!_ok) exitWith {
    [petros, "hint", format ["%1: %2", _nombre, _motivo], "Misiones"] remoteExec ["A3A_fnc_commsMP", owner _jugador];
};
// tiempo de espera antes de poder repetir esta misión (minutos)
private _espera = createHashMapFromArray [
    ["noPasaran", 30], ["polvorin", 20], ["telefono", 15], ["finca", 20], ["imprenta", 20],
    ["refugio", 30], ["oro", 90], ["penal", 30]
];
if (isNil "GCE_esperas") then { GCE_esperas = createHashMap };
GCE_esperas set [_id, time + 60 * (_espera getOrDefault [_id, 20])];
GCE_misionActiva = _nombre;
publicVariable "GCE_misionActiva";
[_datos, _nombre] spawn (missionNamespace getVariable ("GCE_fnc_m_" + _id));
