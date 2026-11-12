/*
    GCE - Guerra Civil Española para Antistasi Ultimate
    Bando: REBELDES (jugadores) -> República (milicias CNT-FAI / UGT / POUM, Ejército Popular, Brigadas Internacionales)
    Requiere: IFA3 AIO + Northern Fronts
    Basado en NFtS_Reb_FIN_Temperate.sqf de Antistasi Ultimate (licencia MIT).

    Todo lo que hay aquí es lo que los jugadores pueden COMPRAR o tienen DESDE EL INICIO.
    Los precios de cada vehículo están en GCE_Reb_Vehicle_Attributes.sqf (rebCost).
*/

///////////////////////////
//   Rebel Information   //
///////////////////////////

["name", "Ejército Popular de la República"] call _fnc_saveToTemplate;

// Tricolor republicana (tools/make_flags.py)
["flag", "Flag_FIA_F"] call _fnc_saveToTemplate;
["flagTexture", "\GCE\addons\gce_main\data\flags\gce_republica_co.paa"] call _fnc_saveToTemplate;
["flagMarkerType", "GCE_flag_Republica"] call _fnc_saveToTemplate;

// Vehículos de Northern Fronts: si está cargado el PBO gce_vehiculos se usan sus copias
// (mismo vehículo, con nombre en español y foto en el menú de compra).
private _v = {
    params ["_gce", "_orig"];
    if (isClass (configFile >> "CfgVehicles" >> _gce)) then { _gce } else { _orig }
};

// --- Tienda de vehículos ---
["vehiclesBasic", [["GCE_R75","NORTH_SOV_R75"] call _v]] call _fnc_saveToTemplate;    // "quad" -> moto con sidecar
["vehiclesLightUnarmed", ["LIB_GazM1","LIB_GazM1_dirty"]] call _fnc_saveToTemplate;  // "off-road" -> coche de los años 30
["vehiclesLightArmed", ["LIB_Kfz1_MG42_sernyt"]] call _fnc_saveToTemplate;           // coche con ametralladora
// Camiones: el Opel Blitz es el más rápido (85 km/h, 13 plazas); Ford V8 (75, 14) y ZIS-5 (60, 14) más baratos
["vehiclesTruck", ["LIB_OpelBlitz_Tent_Y_Camo", ["GCE_Ford_V8","NORTH_FIN_FordV8"] call _v, "LIB_Zis5v"]] call _fnc_saveToTemplate;
["vehiclesAT", [["GCE_BA6","NORTH_SOV_BA6"] call _v, ["GCE_BA10","NORTH_FIN_BA10"] call _v]] call _fnc_saveToTemplate;   // blindados soviéticos BA-6/BA-10
["vehiclesAA", ["LIB_Zis5v_61K"]] call _fnc_saveToTemplate;

["vehiclesBoat", ["LIB_LCVP"]] call _fnc_saveToTemplate;

private _rebPlanes = ["LIB_P39"];
if (isClass (configFile >> "CfgPatches" >> "sab_sw_i16")) then {
    _rebPlanes = ["sab_sw_i16"];                                                      // Polikarpov I-16 "Mosca"
};
["vehiclesPlane", _rebPlanes] call _fnc_saveToTemplate;

// --- Vehículos civiles que se pueden robar/comprar ---
["vehiclesCivCar", ["LIB_GazM1","LIB_GazM1_dirty"]] call _fnc_saveToTemplate;
["vehiclesCivTruck", ["LIB_Zis5v", ["GCE_Ford_V8","NORTH_FIN_FordV8"] call _v]] call _fnc_saveToTemplate;
["vehiclesCivHeli", []] call _fnc_saveToTemplate;
["vehiclesCivBoat", [["GCE_Lancha","NORTH_FIN_Syoksyvene"] call _v]] call _fnc_saveToTemplate;
["vehiclesCivSupply", ["LIB_Zis5v"]] call _fnc_saveToTemplate;

// --- Estáticas ---
["staticMGs", [["GCE_Maxim","NORTH_FIN_Maxim"] call _v]] call _fnc_saveToTemplate;                          // Maxim
["staticAT", [["GCE_Canon_45","NORTH_FIN_45PSTK37"] call _v]] call _fnc_saveToTemplate;                        // cañón soviético de 45 mm
["staticAA", [["GCE_Maxim_Quad","NORTH_SOV_Maxim_Quad"] call _v]] call _fnc_saveToTemplate;
["staticMortars", [["GCE_Mortero_50","NORTH_SOV_50rm38"] call _v]] call _fnc_saveToTemplate;
["staticMortarMagHE", "NORTH_10Shell_50mm_MortarHEshell_50krh38"] call _fnc_saveToTemplate;
["staticMortarMagSmoke", "NORTH_10Shell_50mm_MortarSmokeShell_50krh38"] call _fnc_saveToTemplate;

["mineAT", "LIB_TMI_42_MINE_mag"] call _fnc_saveToTemplate;
["mineAPERS", "LIB_shumine_42_MINE_mag"] call _fnc_saveToTemplate;

["breachingExplosivesAPC", [["LIB_Ladung_Big_MINE_mag", 1], ["LIB_Ladung_Small_MINE_mag", 1]]] call _fnc_saveToTemplate;
["breachingExplosivesTank", [["LIB_Ladung_Big_MINE_mag", 1], ["LIB_Ladung_Small_MINE_mag", 2]]] call _fnc_saveToTemplate;

#include "GCE_Reb_Vehicle_Attributes.sqf"

///////////////////////////
//  Rebel Starting Gear  //
///////////////////////////
// Milicianos de julio de 1936: fusiles viejos, revólveres, cócteles molotov y dinamita.

private _initialRebelEquipment = [
    "LIB_M9130", "LIB_5Rnd_762x54",                 // Mosin-Nagant ("mexicanski")
    "LIB_M1895", "LIB_7Rnd_762x38",                 // revólver Nagant
    "NORTH_molotov",
    ["LIB_Ladung_Small_MINE_mag", 10], ["LIB_Ladung_Big_MINE_mag", 3],   // dinamita de los mineros asturianos
    "LIB_Shg24",
    "V_LIB_SOV_RA_Belt", "V_LIB_SOV_RA_MosinBelt",
    "B_LIB_SOV_RA_GasBag",
    "LIB_Binocular_SU"
];

// Morral de sanitario (PBO gce_uniformes): cabe el Medikit para reanimar
if (isClass (configFile >> "CfgVehicles" >> "GCE_B_Morral_Sanitario")) then {_initialRebelEquipment append ["GCE_B_Morral_Sanitario"]};

if (A3A_hasTFAR && startWithLongRangeRadio) then {_initialRebelEquipment append ["B_LIB_SOV_RA_Radio"]};
if (A3A_hasTFARBeta && startWithLongRangeRadio) then {_initialRebelEquipment append ["B_LIB_SOV_RA_Radio"]};
["initialRebelEquipment", _initialRebelEquipment] call _fnc_saveToTemplate;

// Milicianos con ropa de calle + Ejército Popular con uniforme soviético de los años 30
private _rebUniforms = [
    "U_LIB_CIV_Citizen_1",
    "U_LIB_CIV_Citizen_3",
    "U_LIB_CIV_Citizen_5",
    "U_LIB_CIV_Citizen_7",
    "U_NORTH_SOV_Obr35_Uniform_Early_Private",
    "U_NORTH_SOV_Obr35_Uniform_Early_Private_2",
    "U_NORTH_SOV_Obr35_Uniform_Early_Private_3",
    "U_NORTH_SOV_Obr35_Uniform_Early_Private_4"
];

private _rebHeadgear = [
    "H_LIB_CIV_Worker_Cap_1",
    "H_LIB_CIV_Worker_Cap_2",
    "H_LIB_CIV_Villager_Cap_1",
    "H_NORTH_SOV_Obr35_Pilotka",
    "H_NORTH_SOV_Obr35_Pilotka_2",
    "H_NORTH_SOV_SSh36_Helmet"
];

// Monos de miliciano (PBO gce_uniformes). Solo se añaden si está cargado.
private _monos = ["GCE_U_Mono_Azul","GCE_U_Mono_Mahon","GCE_U_Mono_Negro","GCE_U_Mono_Caqui"]
    select { isClass (configFile >> "CfgWeapons" >> _x) };

if (isNil "_gceCNT") then {
    // República: algún mono caqui/azul entre el Ejército Popular
    _rebUniforms append (_monos select { _x in ["GCE_U_Mono_Caqui","GCE_U_Mono_Mahon"] });
} else {
    // CNT-FAI: el mono es el uniforme de la revolución. Sin uniformes soviéticos.
    _rebUniforms = _monos + _monos + [          // los monos salen el doble de veces
        "U_LIB_CIV_Citizen_1",
        "U_LIB_CIV_Citizen_2",
        "U_LIB_CIV_Citizen_3",
        "U_LIB_CIV_Citizen_4",
        "U_LIB_CIV_Citizen_5",
        "U_LIB_CIV_Citizen_6",
        "U_LIB_CIV_Citizen_7",
        "U_LIB_CIV_Citizen_8"
    ];
    // gorras de obrero y de campesino; casi ningún casco
    _rebHeadgear = [
        "H_LIB_CIV_Worker_Cap_1","H_LIB_CIV_Worker_Cap_2","H_LIB_CIV_Worker_Cap_3","H_LIB_CIV_Worker_Cap_4",
        "H_LIB_CIV_Villager_Cap_1","H_LIB_CIV_Villager_Cap_2","H_LIB_CIV_Villager_Cap_3","H_LIB_CIV_Villager_Cap_4",
        "H_NORTH_SOV_Obr35_Pilotka"     // gorrillo
    ];
};

// Gorros propios (PBO gce_uniformes / gce_gorros), solo si están cargados
private _gorros = ["GCE_H_Boina_Negra","GCE_H_Gorrillo_Negro","GCE_H_Gorrillo_Rojo"]
    select { isClass (configFile >> "CfgWeapons" >> _x) };
if (isNil "_gceCNT") then {
    _rebHeadgear append (_gorros select { _x != "GCE_H_Gorrillo_Negro" });
} else {
    // CNT-FAI: gorrillo negro y rojo, boina negra (salen el doble que las gorras de obrero)
    _rebHeadgear append (_gorros + _gorros);
};

private _dlcUniforms = [];

["uniforms", _rebUniforms + _dlcUniforms] call _fnc_saveToTemplate;
["headgear", _rebHeadgear] call _fnc_saveToTemplate;

/////////////////////
///  Identities   ///
/////////////////////

["faces", ["GreekHead_A3_01","GreekHead_A3_02","GreekHead_A3_03","GreekHead_A3_04","GreekHead_A3_05",
"GreekHead_A3_06","GreekHead_A3_07","GreekHead_A3_08","GreekHead_A3_09"]] call _fnc_saveToTemplate;
["voices", ["Male01GRE","Male02GRE","Male03GRE","Male04GRE","Male05GRE","Male06GRE"]] call _fnc_saveToTemplate;

//////////////////////////
//       Loadouts       //
//////////////////////////

private _loadoutData = call _fnc_createLoadoutData;
_loadoutData set ["maps", ["ItemMap"]];
_loadoutData set ["watches", ["LIB_GER_ItemWatch"]];
_loadoutData set ["compasses", ["LIB_GER_ItemCompass_deg"]];
_loadoutData set ["binoculars", ["LIB_Binocular_SU"]];

_loadoutData set ["uniforms", _rebUniforms];
_loadoutData set ["helmets", _rebHeadgear];

_loadoutData set ["glasses", ["G_LIB_Dienst_Brille", "G_LIB_Dienst_Brille2"]];
_loadoutData set ["goggles", ["G_LIB_Dust_Goggles"]];
_loadoutData set ["facemask", ["G_LIB_Headwrap", "G_LIB_Scarf2_B", "G_LIB_Scarf2_G", "G_LIB_Scarf_B", "G_LIB_Scarf_G"]];

_loadoutData set ["items_medical_basic", ["BASIC"] call A3A_fnc_itemset_medicalSupplies];
_loadoutData set ["items_medical_standard", ["STANDARD"] call A3A_fnc_itemset_medicalSupplies];
_loadoutData set ["items_medical_medic", ["MEDIC"] call A3A_fnc_itemset_medicalSupplies];
_loadoutData set ["items_miscEssentials", [] call A3A_fnc_itemset_miscEssentials];

////////////////////////
//  Rebel Unit Types  //
///////////////////////

private _squadLeaderTemplate = {
    ["uniforms"] call _fnc_setUniform;
    ["helmets"] call _fnc_setHelmet;
    [selectRandomWeighted [[], 1.25, "glasses", 1, "goggles", 0.75, "facemask", 1]] call _fnc_setFacewear;

    ["items_medical_standard"] call _fnc_addItemSet;
    ["items_miscEssentials"] call _fnc_addItemSet;

    ["maps"] call _fnc_addMap;
    ["watches"] call _fnc_addWatch;
    ["compasses"] call _fnc_addCompass;
    ["binoculars"] call _fnc_addBinoculars;
};

private _riflemanTemplate = {
    ["uniforms"] call _fnc_setUniform;
    ["helmets"] call _fnc_setHelmet;
    [selectRandomWeighted [[], 1.25, "glasses", 1, "goggles", 0.75, "facemask", 1]] call _fnc_setFacewear;
    
    ["items_medical_standard"] call _fnc_addItemSet;
    ["items_miscEssentials"] call _fnc_addItemSet;

    ["maps"] call _fnc_addMap;
    ["watches"] call _fnc_addWatch;
    ["compasses"] call _fnc_addCompass;
};

private _prefix = "militia";
private _unitTypes = [
    ["Petros", _squadLeaderTemplate],
    ["SquadLeader", _squadLeaderTemplate],
    ["Rifleman", _riflemanTemplate],
    ["staticCrew", _riflemanTemplate],
    ["Medic", _riflemanTemplate, [["medic", true]]],
    ["Engineer", _riflemanTemplate, [["engineer", true]]],
    ["ExplosivesExpert", _riflemanTemplate, [["explosiveSpecialist", true]]],
    ["Grenadier", _riflemanTemplate],
    ["LAT", _riflemanTemplate],
    ["AT", _riflemanTemplate],
    ["AA", _riflemanTemplate],
    ["MachineGunner", _riflemanTemplate],
    ["Marksman", _riflemanTemplate],
    ["Sniper", _riflemanTemplate],
    ["Unarmed", _riflemanTemplate]
];

[_prefix, _unitTypes, _loadoutData] call _fnc_generateAndSaveUnitsToTemplate;
