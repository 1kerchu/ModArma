/*
    GCE_fnc_fortCrear  [clase, posATL, dir, jugador]  (servidor)
    Cobra (fondos de la facción si es el comandante; si no, el jugador) y construye.
    Máximo 200 fortificaciones GCE en el mapa. Se guardan en la partida.
*/
params ["_clase", "_pos", "_dir", "_jugador"];
private _aviso = { [petros, "hint", _this, "Fortificaciones"] remoteExec ["A3A_fnc_commsMP", owner _jugador] };
private _item = ([] call GCE_fnc_fortCatalogo) select { (_x select 0) == _clase };
if (_item isEqualTo []) exitWith {};
private _precio = (_item select 0) select 2;
if (isNil "GCE_fortificaciones") then { GCE_fortificaciones = [] };
GCE_fortificaciones = GCE_fortificaciones select { !isNull _x };
if (count GCE_fortificaciones >= 200) exitWith { "Ya hay 200 fortificaciones. Desmonta alguna." call _aviso };

private _esComandante = _jugador == theBoss;
private _dinero = if (_esComandante) then { server getVariable ["resourcesFIA", 0] } else { _jugador getVariable ["moneyX", 0] };
if (_dinero < _precio) exitWith { format ["Hace falta %1 de dinero.", _precio] call _aviso };
if (_esComandante) then { [0, -_precio] spawn A3A_fnc_resourcesFIA } else { [-_precio, _jugador] call A3A_fnc_addMoneyPlayer };

[_clase, _pos, _dir] call GCE_fnc_fortCrearObjeto;
