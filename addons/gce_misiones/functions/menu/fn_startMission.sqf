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
GCE_misionActiva = _nombre;
publicVariable "GCE_misionActiva";
[_datos, _nombre] spawn (missionNamespace getVariable ("GCE_fnc_m_" + _id));
