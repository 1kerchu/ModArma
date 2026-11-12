/* GCE_fnc_requestMenu  [jugador]  (servidor): calcula qué misiones se pueden hacer y las manda al jugador */
params ["_jugador"];
private _lista = [] call GCE_fnc_availability;
[_lista apply { [_x select 0, _x select 1, _x select 2, _x select 3] }, GCE_misionActiva]
    remoteExec ["GCE_fnc_showMenu", owner _jugador];
