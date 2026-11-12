/*
    GCE_fnc_cleanup  [cosas]  (spawn)
    Borra grupos/objetos de una misión cuando no hay jugadores a menos de 1 km.
*/
params ["_cosas"];
sleep 60;
private _objs = [];
{
    if (_x isEqualType grpNull) then {
        { _objs pushBackUnique _x; if (vehicle _x != _x) then { _objs pushBackUnique (vehicle _x) } } forEach units _x;
    } else {
        _objs pushBackUnique _x;
    };
} forEach _cosas;

while { _objs isNotEqualTo [] } do {
    _objs = _objs select { !isNull _x };
    {
        private _o = _x;
        if ((allPlayers findIf { _x distance2D _o < 1000 }) == -1) then { deleteVehicle _o };
    } forEach _objs;
    sleep 30;
};
{ if (_x isEqualType grpNull && {!isNull _x}) then { deleteGroup _x } } forEach _cosas;
