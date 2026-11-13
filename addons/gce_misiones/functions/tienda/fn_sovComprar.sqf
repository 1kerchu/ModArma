/*
    GCE_fnc_sovComprar  [id, jugador]  (servidor)
    Cobra (fondos de la facción si es el comandante; si no, dinero del jugador) y mete el lote
    en el arsenal del cuartel (boxX).
*/
params ["_id", "_jugador"];
private _lote = ([] call GCE_fnc_sovCatalogo) select { (_x select 0) == _id };
if (_lote isEqualTo []) exitWith {};
(_lote select 0) params ["", "_nombre", "_precio", "_armas", "_cargs"];
private _aviso = { [petros, "hint", _this, "Ayuda soviética"] remoteExec ["A3A_fnc_commsMP", owner _jugador] };

private _esComandante = _jugador == theBoss;
private _dinero = if (_esComandante) then { server getVariable ["resourcesFIA", 0] } else { _jugador getVariable ["moneyX", 0] };
if (_dinero < _precio) exitWith { format ["Hace falta %1 de dinero.", _precio] call _aviso };
if (_esComandante) then { [0, -_precio] spawn A3A_fnc_resourcesFIA } else { [-_precio, _jugador] call A3A_fnc_addMoneyPlayer };

{ boxX addWeaponCargoGlobal _x } forEach _armas;
{ boxX addMagazineCargoGlobal _x } forEach _cargs;
format ["Llegado desde Odesa: %1. Está en el arsenal del cuartel.", _nombre] call _aviso;
