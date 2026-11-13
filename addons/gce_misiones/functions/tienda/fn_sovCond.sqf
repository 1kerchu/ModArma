/* GCE_fnc_sovCond: tienda de ayuda soviética (tras la llegada de las Brigadas, junto a Petros) */
missionNamespace getVariable ["GCE_brigadas", false]
&& {side group player == teamPlayer}
&& {!isNil "petros"} && {alive petros} && {player distance petros < 6}
