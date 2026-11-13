/*
    GCE_fnc_fortCatalogo -> [[clase, nombre, precio], ...]
    Fortificaciones de época que se pueden construir. Solo las que existen en tu juego.
*/
[
    ["Land_BagFence_Long_F",            "Sacos terreros (largo)",        30],
    ["Land_BagFence_Short_F",           "Sacos terreros (corto)",        20],
    ["Land_BagFence_Round_F",           "Sacos terreros (en curva)",     30],
    ["Land_SandbagBarricade_01_F",      "Parapeto de sacos",             40],
    ["Land_SandbagBarricade_01_hole_F", "Parapeto con aspillera",        40],
    ["Land_BagBunker_Small_F",          "Nido de ametralladora",        150],
    ["Land_Barricade_01_4m_F",          "Barricada (4 m)",               30],
    ["Land_Barricade_01_10m_F",         "Barricada (10 m)",              50],
    ["Land_Razorwire_F",                "Alambrada",                     15],
    ["Land_CzechHedgehog_01_new_F",     "Erizo antitanque",              15]
] select { isClass (configFile >> "CfgVehicles" >> (_x select 0)) }
