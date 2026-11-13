/* GCE_fnc_datosCargar  [saveData]  (servidor): restaura lo guardado por GCE_fnc_datosGuardar */
params ["_saveData"];
private _d = _saveData getOrDefault ["GCE_datos", createHashMap];
if (count _d == 0) exitWith {};
{ _x params ["_clase", "_pos", "_dir"]; [_clase, _pos, _dir] call GCE_fnc_fortCrearObjeto } forEach (_d getOrDefault ["fortificaciones", []]);
if (isNil "GCE_esperas") then { GCE_esperas = createHashMap };
{ GCE_esperas set [_x, time + _y] } forEach (_d getOrDefault ["esperas", createHashMap]);
private _aereo = _d getOrDefault ["aereo", 0];
if (_aereo > 0) then { GCE_aereoHasta = serverTime + _aereo; publicVariable "GCE_aereoHasta" };
diag_log format ["GCE: datos cargados (%1 fortificaciones)", count (_d getOrDefault ["fortificaciones", []])];
