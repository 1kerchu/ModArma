/* GCE_fnc_presoLiberar  [preso, jugador]  (servidor): el preso se une al grupo del jugador */
params ["_u", "_quien"];
if (_u getVariable ["GCE_libre", false]) exitWith {};
_u setVariable ["GCE_libre", true, true];
_u enableAI "MOVE";
_u setUnitPos "AUTO";
[_u] join (group _quien);
