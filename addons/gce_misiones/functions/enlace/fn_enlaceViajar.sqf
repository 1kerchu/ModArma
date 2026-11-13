/*
    GCE_fnc_enlaceViajar  [idDestino, jugador]  (servidor)
    Comprueba que el destino sigue siendo nuestro y sin enemigos, cobra y manda al jugador allí.
*/
params ["_id", "_jugador"];
private _aviso = { [petros, "hint", _this, "Transporte de enlace"] remoteExec ["A3A_fnc_commsMP", owner _jugador] };
private _dest = ([getPos _jugador] call GCE_fnc_enlaceDestinos) select { (_x select 0) == _id };
if (_dest isEqualTo []) exitWith { "Ese destino ya no está disponible." call _aviso };
(_dest select 0) params ["", "_nombre", "_pos", "_precio"];
if (([_pos, 300] call GCE_fnc_enemiesNear) > 0) exitWith { format ["Hay enemigos en %1: el camión no puede ir.", _nombre] call _aviso };
if (([getPos _jugador, 300] call GCE_fnc_enemiesNear) > 0) exitWith { "Hay enemigos cerca: ningún camión saldrá ahora." call _aviso };

private _esComandante = _jugador == theBoss;
private _dinero = if (_esComandante) then { server getVariable ["resourcesFIA", 0] } else { _jugador getVariable ["moneyX", 0] };
if (_dinero < _precio) exitWith { format ["Hace falta %1 de dinero.", _precio] call _aviso };
if (_esComandante) then { [0, -_precio] spawn A3A_fnc_resourcesFIA } else { [-_precio, _jugador] call A3A_fnc_addMoneyPlayer };

[_pos, _nombre] remoteExec ["GCE_fnc_enlaceLlegar", owner _jugador];
