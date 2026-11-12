/*
    GCE_fnc_darRadio  [unidad]   (donde la unidad es local)
    Le pone una radio (ItemRadio) si no lleva. Sin radio no se oyen los avisos del grupo.
    No hace nada si se usa TFAR o ACRE (tienen sus propias radios).
*/
params ["_u"];
if (!local _u || {!alive _u}) exitWith {};
if ((missionNamespace getVariable ["A3A_hasTFAR", false]) || {missionNamespace getVariable ["A3A_hasTFARBeta", false]}
    || {missionNamespace getVariable ["A3A_hasACRE", false]}) exitWith {};
if ("ItemRadio" in assignedItems _u) exitWith {};
_u linkItem "ItemRadio";
