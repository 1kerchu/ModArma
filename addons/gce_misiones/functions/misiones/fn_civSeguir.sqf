/* GCE_fnc_civSeguir  [civil, jugador]  (servidor) */
params ["_civ", "_guia"];
_civ setVariable ["GCE_sigue", _guia, true];
_civ setUnitPos "UP";
_civ doMove (getPos _guia);
