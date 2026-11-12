/* GCE_fnc_jefeCondRetirar */
private _u = cursorObject;
!isNull _u && {alive _u} && {_u getVariable ["GCE_esJefe", false]} && {group _u == group player} && {player distance _u < 5}
