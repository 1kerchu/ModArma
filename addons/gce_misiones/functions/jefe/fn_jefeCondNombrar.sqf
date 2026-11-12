/* GCE_fnc_jefeCondNombrar: ¿se puede ascender al soldado que estoy mirando? */
private _u = cursorObject;
!isNull _u
&& {_u isKindOf "CAManBase"}
&& {alive _u}
&& {!isPlayer _u}
&& {group _u == group player}
&& {leader group player == player}
&& {player distance _u < 5}
&& {lifeState _u != "INCAPACITATED"}
&& {({ alive _x && {_x getVariable ["GCE_esJefe", false]} } count units group player) == 0}
