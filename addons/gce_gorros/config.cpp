/*
    GCE - Gorrillos (PBO separado porque depende de Northern Fronts)

    Gorrillo cuartelero = retextura de la pilotka soviética de Northern Fronts
    (H_NORTH_SOV_Obr35_Pilotka). Si en tu versión de Northern Fronts esa gorra no
    admite cambiar la textura, este PBO es el único que falla.
    Texturas generadas con tools/make_uniforms.py
*/

class CfgPatches
{
    class GCE_gorros
    {
        name = "GCE - Gorrillos";
        author = "GCE";
        units[] = {};
        weapons[] = {"GCE_H_Gorrillo_Negro", "GCE_H_Gorrillo_Rojo"};
        requiredVersion = 2.20;
        requiredAddons[] = {"A3_Characters_F", "IFA3_Core", "NORTH_Main"};
        version = 0.1;
    };
};

class CfgWeapons
{
    class H_NORTH_SOV_Obr35_Pilotka;

    class GCE_H_Gorrillo_Negro : H_NORTH_SOV_Obr35_Pilotka
    {
        scope = 2;
        author = "GCE";
        displayName = "Gorrillo cuartelero (negro)";
        hiddenSelectionsTextures[] = {"\GCE\addons\gce_gorros\data\gorrillo_negro_co.paa"};
    };
    class GCE_H_Gorrillo_Rojo : H_NORTH_SOV_Obr35_Pilotka
    {
        scope = 2;
        author = "GCE";
        displayName = "Gorrillo cuartelero (rojo)";
        hiddenSelectionsTextures[] = {"\GCE\addons\gce_gorros\data\gorrillo_rojo_co.paa"};
    };
};
