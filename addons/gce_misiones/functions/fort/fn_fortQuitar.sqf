/* GCE_fnc_fortQuitar  [objeto, jugador]  (servidor): desmonta y devuelve la mitad del precio */
params ["_o", "_jugador"];
if (isNull _o || {!(_o getVariable ["GCE_fort", false])}) exitWith {};
private _item = ([] call GCE_fnc_fortCatalogo) select { (_x select 0) == typeOf _o };
private _vuelta = if (_item isEqualTo []) then { 0 } else { floor (((_item select 0) select 2) / 2) };
deleteVehicle _o;
GCE_fortificaciones = (missionNamespace getVariable ["GCE_fortificaciones", []]) select { !isNull _x };
if (_vuelta > 0) then {
    if (_jugador == theBoss) then { [0, _vuelta] spawn A3A_fnc_resourcesFIA } else { [_vuelta, _jugador] call A3A_fnc_addMoneyPlayer };
};
