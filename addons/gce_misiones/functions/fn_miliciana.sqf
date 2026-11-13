/*
    GCE_fnc_miliciana  [unidad]  (servidor)

    Si la unidad lleva un uniforme de miliciana (PBO gce_milicianas, mod ZEPHIK Females V2),
    le pone cara femenina del mod, nombre de mujer y la voz inglesa más aguda (no hay voces
    femeninas en Arma). Se llama al crear cada soldado rebelde o enemigo.
*/
params ["_u"];
if (isNull _u || {!alive _u} || {isPlayer _u}) exitWith {};
if ((uniform _u find "GCE_U_Miliciana") != 0) exitWith {};

if (isNil "GCE_carasFemeninas") then {
    GCE_carasFemeninas = [];
    {
        private _grupo = _x;
        {
            if ("ZEPHIK_Female_face_iden" in getArray (_x >> "identityTypes") && {getNumber (_x >> "disabled") == 0}) then {
                GCE_carasFemeninas pushBackUnique configName _x;
            };
        } forEach ("true" configClasses _grupo);
    } forEach ("true" configClasses (configFile >> "CfgFaces"));
};
if (GCE_carasFemeninas isEqualTo []) exitWith {};

[_u, createHashMapFromArray [
    ["face", selectRandom GCE_carasFemeninas],
    ["firstName", selectRandom ["Carmen", "Dolores", "Pilar", "Teresa", "Rosa", "Lucía", "Mercedes", "Josefa", "Manuela", "Antonia", "Concepción", "Amparo"]],
    ["lastName", selectRandom ["García", "López", "Martínez", "Sánchez", "Pérez", "Gómez", "Fernández", "Ruiz", "Díaz", "Moreno", "Navarro", "Romero"]],
    ["speaker", selectRandom ["Male01ENG", "Male02ENG", "Male03ENG", "Male04ENG", "Male05ENG", "Male06ENG"]],
    ["pitch", 1.25 + random 0.1]
]] call A3A_fnc_setIdentity;
_u setVariable ["GCE_miliciana", true, true];
