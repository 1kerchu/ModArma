/*
    GCE_fnc_fortZonaLoop  (cliente, spawn)
    Cada 3 s comprueba si el jugador está en zona propia (a menos de 300 m del cuartel o de un
    lugar que controlamos) para mostrar la acción de fortificar.
*/
while { true } do {
    private _ok = false;
    if (!isNil "sidesX" && {!isNil "markersX"} && {side group player == teamPlayer}) then {
        private _p = getPos player;
        _ok = (getMarkerPos respawnTeamPlayer) distance2D _p < 300
            || {(markersX findIf { (sidesX getVariable [_x, sideUnknown]) == teamPlayer && {(getMarkerPos _x) distance2D _p < 300} }) != -1};
    };
    GCE_fortPuedo = _ok;
    sleep 3;
};
