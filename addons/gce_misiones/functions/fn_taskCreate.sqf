/* GCE_fnc_taskCreate  [titulo, descripcion, pos, icono] -> id de la tarea */
params ["_titulo", "_desc", "_pos", ["_icono", "attack"]];
if (isNil "GCE_contadorTareas") then { GCE_contadorTareas = 0 };
GCE_contadorTareas = GCE_contadorTareas + 1;
private _tid = "GCE_tarea_" + str GCE_contadorTareas;
[teamPlayer, _tid, [_desc, _titulo, ""], _pos, "CREATED", 0, true, _icono] call BIS_fnc_taskCreate;
_tid
