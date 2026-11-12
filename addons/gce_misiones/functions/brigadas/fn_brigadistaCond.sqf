/* GCE_fnc_brigadistaCond: acción de reclutar brigadista (junto a Petros, tras la llegada de las Brigadas) */
missionNamespace getVariable ["GCE_brigadas", false]
&& {side group player == teamPlayer}
&& {!isNil "petros"} && {alive petros} && {player distance petros < 6}
&& {leader group player == player}
