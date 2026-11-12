/*
    GCE - Vehículos (PBO separado: depende de Northern Fronts)

    Los vehículos de Northern Fronts no traen foto de vista previa y en el menú de compra de
    Antistasi salen en blanco. Aquí se crean COPIAS de esos vehículos (mismo modelo y comportamiento)
    con nombre en español y foto propia. La tienda rebelde usa estas copias si este PBO está cargado.

    Fotos: tools/make_previews.py  ->  data/previews/*.jpg (455x256). Para usar capturas reales,
    sustituye el .jpg por uno con el mismo nombre.
*/

class CfgPatches
{
    class GCE_vehiculos
    {
        name = "GCE - Vehículos";
        author = "GCE";
        units[] = {"GCE_Ford_V8", "GCE_R75", "GCE_BA6", "GCE_BA10", "GCE_Maxim", "GCE_Canon_45", "GCE_Maxim_Quad", "GCE_Mortero_50", "GCE_Lancha"};
        weapons[] = {};
        requiredVersion = 2.20;
        requiredAddons[] = {"IFA3_Core", "NORTH_Main"};
        version = 0.1;
    };
};

class CfgVehicles
{
    class NORTH_FIN_FordV8;
    class NORTH_SOV_R75;
    class NORTH_SOV_BA6;
    class NORTH_FIN_BA10;
    class NORTH_FIN_Maxim;
    class NORTH_FIN_45PSTK37;
    class NORTH_SOV_Maxim_Quad;
    class NORTH_SOV_50rm38;
    class NORTH_FIN_Syoksyvene;

    class GCE_Ford_V8 : NORTH_FIN_FordV8
    {
        scope = 2;
        scopeCurator = 2;
        author = "GCE";
        displayName = "Camión Ford V8";
        editorPreview = "\GCE\addons\gce_vehiculos\data\previews\gce_ford_v8.jpg";
    };
    class GCE_R75 : NORTH_SOV_R75
    {
        scope = 2;
        scopeCurator = 2;
        author = "GCE";
        displayName = "Moto con sidecar R75";
        editorPreview = "\GCE\addons\gce_vehiculos\data\previews\gce_r75.jpg";
    };
    class GCE_BA6 : NORTH_SOV_BA6
    {
        scope = 2;
        scopeCurator = 2;
        author = "GCE";
        displayName = "Blindado BA-6";
        editorPreview = "\GCE\addons\gce_vehiculos\data\previews\gce_ba6.jpg";
    };
    class GCE_BA10 : NORTH_FIN_BA10
    {
        scope = 2;
        scopeCurator = 2;
        author = "GCE";
        displayName = "Blindado BA-10";
        editorPreview = "\GCE\addons\gce_vehiculos\data\previews\gce_ba10.jpg";
    };
    class GCE_Maxim : NORTH_FIN_Maxim
    {
        scope = 2;
        scopeCurator = 2;
        author = "GCE";
        displayName = "Ametralladora Maxim";
        editorPreview = "\GCE\addons\gce_vehiculos\data\previews\gce_maxim.jpg";
    };
    class GCE_Canon_45 : NORTH_FIN_45PSTK37
    {
        scope = 2;
        scopeCurator = 2;
        author = "GCE";
        displayName = "Cañón antitanque de 45 mm";
        editorPreview = "\GCE\addons\gce_vehiculos\data\previews\gce_45mm.jpg";
    };
    class GCE_Maxim_Quad : NORTH_SOV_Maxim_Quad
    {
        scope = 2;
        scopeCurator = 2;
        author = "GCE";
        displayName = "Maxim cuádruple (antiaérea)";
        editorPreview = "\GCE\addons\gce_vehiculos\data\previews\gce_maxim_quad.jpg";
    };
    class GCE_Mortero_50 : NORTH_SOV_50rm38
    {
        scope = 2;
        scopeCurator = 2;
        author = "GCE";
        displayName = "Mortero de 50 mm";
        editorPreview = "\GCE\addons\gce_vehiculos\data\previews\gce_mortero_50.jpg";
    };
    class GCE_Lancha : NORTH_FIN_Syoksyvene
    {
        scope = 2;
        scopeCurator = 2;
        author = "GCE";
        displayName = "Lancha";
        editorPreview = "\GCE\addons\gce_vehiculos\data\previews\gce_lancha.jpg";
    };
};
