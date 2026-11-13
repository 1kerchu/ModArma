/*
    GCE_fnc_enlaceDestinos  [pos] -> [[id, nombre, posDestino, precio], ...]   (cualquier máquina)
    Destinos del transporte de enlace: el cuartel y los pueblos nuestros (no el sitio donde estás).
    Precio: 50 + 15 por kilómetro. Como mucho los 9 más cercanos.
*/
params ["_desde"];
private _lista = [];
private _hq = getMarkerPos respawnTeamPlayer;
if (_hq distance2D _desde > 300) then { _lista pushBack ["HQ", "Cuartel", _hq] };
{
    private _p = getMarkerPos _x;
    if ((sidesX getVariable [_x, sideUnknown]) == teamPlayer && {_p distance2D _desde > 300}) then {
        _lista pushBack [_x, [_x] call A3A_fnc_localizar, _p];
    };
} forEach citiesX;
_lista = _lista apply { _x + [50 + 15 * round (((_x select 2) distance2D _desde) / 1000)] };
_lista = [_lista, [], { (_x select 2) distance2D _desde }, "ASCEND"] call BIS_fnc_sortBy;
_lista select [0, 9]
