/*
    GCE - Guerra Civil Española
    Facciones para Antistasi Ultimate (1936-1939)

    Dependencias (todas gratuitas en el Workshop):
      - Antistasi Ultimate - Mod
      - IFA3 AIO Lite
      - Northern Fronts
    Opcionales (si están cargados se usan automáticamente):
      - WW2 Armored Cars / WW2 Tanks (FA_WW2_*)
      - Flying Legends (sab_flyinglegends), Secret Weapons (sab_sw_i16)
*/

class CfgPatches
{
    class GCE_main
    {
        name = "GCE - Guerra Civil Española";
        author = "GCE";
        units[] = {};
        weapons[] = {};
        requiredVersion = 2.20;
        requiredAddons[] = {"A3A_core", "IFA3_Core", "NORTH_Main"};
        version = 0.1;
        A3A_compatibility[] = {12, 4};   // versión de Antistasi Ultimate para la que está hecho
    };
};

class A3A
{
    class Templates
    {
        class GCE_Base
        {
            requiredAddons[] = {"GCE_main", "IFA3_Core", "NORTH_Main"};
            basepath = "\GCE\addons\gce_main\Templates";
            logo = "";
            priority = 30;            // aparecen los primeros en la lista
            maps[] = {"altis"};      // y aún más arriba en Altis
            equipFlags[] = {"lowTech"};
        };

        class GCE_Nacionales : GCE_Base
        {
            side = "Occ";
            name = "GCE Ejército Nacional";
            flagTexture = "\A3\Data_F\Flags\Flag_red_CO.paa";
            file = "GCE_AI_Nacionales";
            description = "Bando sublevado (1936-1939): Ejército de África, Regulares, Falange y Requetés.";
        };

        class GCE_Condor : GCE_Base
        {
            side = "Inv";
            name = "GCE Legión Cóndor";
            flagTexture = "ww2\core_t\if_decals_t\german\flag_ger_co.paa";
            file = "GCE_AI_Condor";
            description = "Intervención extranjera: Legión Cóndor alemana y CTV italiano. Mucha aviación.";
        };

        class GCE_Republica : GCE_Base
        {
            side = "Reb";
            name = "GCE República";
            flagTexture = "\A3\Data_F\Flags\Flag_red_CO.paa";
            file = "GCE_Reb_Republica";
            description = "Milicias obreras, Ejército Popular y Brigadas Internacionales.";
        };

        class GCE_Civiles : GCE_Base
        {
            side = "Civ";
            name = "GCE Civiles 1936";
            flagTexture = "\A3\Data_F\Flags\Flag_red_CO.paa";
            file = "GCE_CIV";
            description = "Población civil española de los años 30.";
        };
    };
};
