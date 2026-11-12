/*
    GCE_fnc_comms  [texto, titulo]  (servidor)
    Aviso a todos los rebeldes: hint + mensaje de Petros por radio.
*/
params ["_texto", ["_titulo", "Guerra Civil"]];
[petros, "hint", _texto, _titulo] remoteExec ["A3A_fnc_commsMP", 0];
[petros, "sideChat", _texto] remoteExec ["A3A_fnc_commsMP", 0];
