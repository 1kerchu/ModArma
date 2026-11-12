/* GCE_fnc_faction  [lado] -> hashmap de la facción enemiga */
params ["_lado"];
if (_lado == Invaders) then { A3A_faction_inv } else { A3A_faction_occ }
