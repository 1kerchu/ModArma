/*
    GCE_fnc_datosGuardar  [saveData]  (servidor)
    Se llama cuando Antistasi guarda la partida (evento oficial para mods externos).
    Guarda: fortificaciones construidas, tiempos de espera de las misiones y del apoyo aéreo.
    (El jefe de escuadra no se guarda porque Antistasi no guarda los soldados de tu grupo.)
*/
params ["_saveData"];
private _d = createHashMap;
_d set ["version", 1];
_d set ["fortificaciones", ((missionNamespace getVariable ["GCE_fortificaciones", []]) select { !isNull _x }) apply {
    [typeOf _x, getPosATL _x, getDir _x]
}];
private _esperas = createHashMap;
{ if (_y > time) then { _esperas set [_x, _y - time] } } forEach (missionNamespace getVariable ["GCE_esperas", createHashMap]);
_d set ["esperas", _esperas];
_d set ["aereo", ((missionNamespace getVariable ["GCE_aereoHasta", 0]) - serverTime) max 0];
_saveData set ["GCE_datos", _d];
