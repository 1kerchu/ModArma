/*
    GCE_fnc_brigadistaReclutar  (cliente)
    Recluta un brigadista internacional: mejor entrenado que un miliciano.
    Cuesta 1 de recursos humanos (de la facción) y 250 de tu dinero, como los reclutas de Antistasi.
    Máximo 4 brigadistas por grupo.
*/
private _coste = 250;
private _titulo = "Brigadas Internacionales";
if ((server getVariable ["hr", 0]) < 1) exitWith { [_titulo, "No quedan recursos humanos."] call A3A_fnc_customHint };
if ((player getVariable ["moneyX", 0]) < _coste) exitWith { [_titulo, format ["Necesitas %1 de dinero.", _coste]] call A3A_fnc_customHint };
if (count units group player >= 10) exitWith { [_titulo, "Tu grupo está completo."] call A3A_fnc_customHint };
if (({ _x getVariable ["GCE_brigadista", false] && {alive _x} } count units group player) >= 4) exitWith {
    [_titulo, "Ya tienes 4 brigadistas en el grupo."] call A3A_fnc_customHint;
};

private _u = [group player, A3A_faction_reb get "unitRifle", position player, [], 0, "NONE"] call A3A_fnc_createUnit;
[-1, 0] remoteExec ["A3A_fnc_resourcesFIA", 2];
[-_coste] call A3A_fnc_resourcesPlayer;
_u setVariable ["GCE_brigadista", true, true];

[_u] spawn {
    params ["_u"];
    [_u] call A3A_fnc_FIAinit;
    // voluntarios extranjeros: nombre internacional y voz inglesa
    [_u, createHashMapFromArray [
        ["firstName", selectRandom ["John", "Pierre", "Hans", "Giovanni", "Jan", "Patrick", "Milan", "Lars", "Sam", "André", "Karl", "Tom"]],
        ["lastName", selectRandom ["Walker", "Dubois", "Becker", "Rossi", "Kowalski", "Murphy", "Novak", "Larsen", "Cohen", "Martin", "Weber", "Brown"]],
        ["face", face _u],
        ["speaker", selectRandom ["Male01ENGB", "Male02ENGB", "Male03ENGB", "Male04ENGB", "Male05ENGB"]]
    ]] call A3A_fnc_setIdentity;
    // uniforme y casco del Ejército Popular, si existen
    private _uni = ["U_NORTH_SOV_Obr35_Uniform_Early_Private", "U_NORTH_SOV_Obr35_Uniform_Early_Private_2"] select { isClass (configFile >> "CfgWeapons" >> _x) };
    if (_uni isNotEqualTo []) then {
        private _cosas = uniformItems _u;
        _u forceAddUniform (selectRandom _uni);
        { _u addItemToUniform _x } forEach _cosas;
    };
    if (isClass (configFile >> "CfgWeapons" >> "H_NORTH_SOV_SSh36_Helmet")) then { _u addHeadgear "H_NORTH_SOV_SSh36_Helmet" };
    // mejor entrenados
    {
        _u setSkill [_x, ((_u skill _x) + 0.25) min 1];
    } forEach ["aimingAccuracy", "aimingShake", "aimingSpeed", "spotDistance", "spotTime", "reloadSpeed"];
    _u setSkill ["courage", 1];
    _u disableAI "AUTOCOMBAT";
    if (!isNil {_u getVariable "orgLoadout"}) then { _u setVariable ["orgLoadout", getUnitLoadout _u, true] };
};
["Brigadas Internacionales", "Un brigadista se une a tu grupo."] call A3A_fnc_customHint;
