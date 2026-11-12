/*
    GCE_fnc_spawnSquad  [pos, lado, tipo, destino, tipoWaypoint] -> grupo   (entorno scheduled)
    tipo: "militia" | "medium" | "squad"
*/
params ["_pos", "_lado", ["_tipo", "squad"], ["_destino", []], ["_wp", "SAD"]];
private _f = [_lado] call GCE_fnc_faction;
private _tipos = switch (_tipo) do {
    case "militia": { selectRandom (_f get "groupsMilitiaSquads") };
    case "medium":  { selectRandom ([_f, "groupsTierMedium"] call SCRT_fnc_unit_flattenTier) };
    default         { selectRandom ([_f, "groupsTierSquads"] call SCRT_fnc_unit_flattenTier) };
};
private _grp = [_pos, _lado, _tipos] call A3A_fnc_spawnGroup;
if (_destino isNotEqualTo []) then {
    private _w = _grp addWaypoint [_destino, 30];
    _w setWaypointType _wp;
    _grp setBehaviour "AWARE";
    _grp setCombatMode "RED";
    _grp setSpeedMode "FULL";
};
_grp
