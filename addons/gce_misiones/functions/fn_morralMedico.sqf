/*
    GCE_fnc_morralMedico  [unidad]   (donde la unidad es local)
    Cambia la mochila del médico rebelde por el Morral de sanitario, conserva lo que llevaba
    y le añade un Medikit.
*/
params ["_u"];
if (!local _u || {!alive _u}) exitWith {};
if (!isClass (configFile >> "CfgVehicles" >> "GCE_B_Morral_Sanitario")) exitWith {};
if (backpack _u == "GCE_B_Morral_Sanitario") exitWith {};

private _cosas = backpackItems _u;
removeBackpack _u;
_u addBackpack "GCE_B_Morral_Sanitario";
clearAllItemsFromBackpack _u;
{ _u addItemToBackpack _x } forEach _cosas;
if (!A3A_hasACE && {!("Medikit" in items _u)}) then { _u addItemToBackpack "Medikit" };

// Antistasi guarda el equipo original del recluta: actualizarlo para que no lo pierda al rearmar
if (!isNil {_u getVariable "orgLoadout"}) then { _u setVariable ["orgLoadout", getUnitLoadout _u, true] };
