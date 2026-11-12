/* GCE_fnc_endMission  [idTarea, "SUCCEEDED"|"FAILED"]  (servidor) */
params ["_tid", "_estado"];
[_tid, _estado] call BIS_fnc_taskSetState;
GCE_misionActiva = "";
publicVariable "GCE_misionActiva";
[_tid] spawn { sleep 600; [_this select 0] call BIS_fnc_deleteTask };
