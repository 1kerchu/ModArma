/* GCE_fnc_aereoCond: ¿se puede pedir apoyo aéreo? (aeródromo propio, sin espera, líder de grupo) */
side group player == teamPlayer
&& {leader group player == player}
&& {!isNil "airportsX"}
&& {(airportsX findIf { (sidesX getVariable [_x, sideUnknown]) == teamPlayer }) != -1}
