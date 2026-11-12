/*
    GCE_fnc_reward  [dinero, hr, dondeApoyo, apoyo, puntos]   (servidor, scheduled)
    dondeApoyo: marcador de ciudad o posición ("" para no tocar el apoyo civil)
*/
params [["_dinero", 0], ["_hr", 0], ["_donde", ""], ["_apoyo", 0], ["_puntos", 5]];
if (_dinero != 0 || {_hr != 0}) then { [_hr, _dinero] call A3A_fnc_resourcesFIA };
if (_apoyo != 0 && {_donde isNotEqualTo ""}) then { [0, _apoyo, _donde] call A3A_fnc_citySupportChange };
{ [_puntos, _x] call A3A_fnc_addScorePlayer } forEach (call SCRT_fnc_misc_getRebelPlayers);
