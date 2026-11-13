/*
    GCE - Milicianas (PBO separado: solo si está cargado el mod "ZEPHIK Females V2")

    Uniformes femeninos de época: son los modelos femeninos de ZEPHIK (camiseta y vaqueros, y el
    uniforme de campaña) con nuestras texturas de mono (las del PBO gce_uniformes).
    En Arma el cuerpo lo decide el uniforme: una recluta con uno de estos uniformes es una miliciana.
    La cara femenina, el nombre y la voz (más aguda) se los pone gce_misiones al crearla.
*/

class CfgPatches
{
    class GCE_milicianas
    {
        name = "GCE - Milicianas";
        author = "GCE";
        units[] = {"GCE_Miliciana_Azul", "GCE_Miliciana_Mahon", "GCE_Miliciana_Negro", "GCE_Miliciana_Caqui"};
        weapons[] = {"GCE_U_Miliciana_Azul", "GCE_U_Miliciana_Mahon", "GCE_U_Miliciana_Negro", "GCE_U_Miliciana_Caqui"};
        requiredVersion = 2.20;
        requiredAddons[] = {"A3_Characters_F", "ZEPHIK_Female_Base", "GCE_uniformes"};
        version = 0.1;
    };
};

class CfgVehicles
{
    class ZEPHIK_Female_Civ_1;
    class ZEPHIK_Female_Civ_13;

    class GCE_Miliciana_Azul : ZEPHIK_Female_Civ_1
    {
        scope = 1;
        author = "GCE";
        displayName = "Mono de miliciana (azul)";
        modelSides[] = {0, 1, 2, 3};
        uniformClass = "GCE_U_Miliciana_Azul";
        hiddenSelectionsTextures[] = {"\GCE\addons\gce_uniformes\data\mono_azul_co.paa", "zephik_uniforms\tshirt_jeans_1\data\shoes1_co.paa"};
    };
    class GCE_Miliciana_Mahon : ZEPHIK_Female_Civ_1
    {
        scope = 1;
        author = "GCE";
        displayName = "Mono de miliciana (azul mahón)";
        modelSides[] = {0, 1, 2, 3};
        uniformClass = "GCE_U_Miliciana_Mahon";
        hiddenSelectionsTextures[] = {"\GCE\addons\gce_uniformes\data\mono_mahon_co.paa", "zephik_uniforms\tshirt_jeans_1\data\shoes1_co.paa"};
    };
    class GCE_Miliciana_Negro : ZEPHIK_Female_Civ_1
    {
        scope = 1;
        author = "GCE";
        displayName = "Mono de miliciana (negro)";
        modelSides[] = {0, 1, 2, 3};
        uniformClass = "GCE_U_Miliciana_Negro";
        hiddenSelectionsTextures[] = {"\GCE\addons\gce_uniformes\data\mono_negro_co.paa", "zephik_uniforms\tshirt_jeans_1\data\shoes1_co.paa"};
    };
    class GCE_Miliciana_Caqui : ZEPHIK_Female_Civ_13
    {
        scope = 1;
        author = "GCE";
        displayName = "Uniforme de miliciana (caqui)";
        modelSides[] = {0, 1, 2, 3};
        uniformClass = "GCE_U_Miliciana_Caqui";
        hiddenSelectionsTextures[] = {"\GCE\addons\gce_uniformes\data\mono_caqui_co.paa"};
    };
};

class CfgWeapons
{
    class UniformItem;
    class ZEPHIK_BLU_WOODLAND_1_U;
    class ZEPHIK_Civilian_Black_Tshirt_Jeans_U;

    class GCE_U_Miliciana_Azul : ZEPHIK_Civilian_Black_Tshirt_Jeans_U
    {
        scope = 2;
        author = "GCE";
        displayName = "Mono de miliciana (azul)";
        class ItemInfo : UniformItem
        {
            uniformModel = "-";
            uniformClass = "GCE_Miliciana_Azul";
            containerClass = "Supply40";
            mass = 40;
        };
    };
    class GCE_U_Miliciana_Mahon : ZEPHIK_Civilian_Black_Tshirt_Jeans_U
    {
        scope = 2;
        author = "GCE";
        displayName = "Mono de miliciana (azul mahón)";
        class ItemInfo : UniformItem
        {
            uniformModel = "-";
            uniformClass = "GCE_Miliciana_Mahon";
            containerClass = "Supply40";
            mass = 40;
        };
    };
    class GCE_U_Miliciana_Negro : ZEPHIK_Civilian_Black_Tshirt_Jeans_U
    {
        scope = 2;
        author = "GCE";
        displayName = "Mono de miliciana (negro)";
        class ItemInfo : UniformItem
        {
            uniformModel = "-";
            uniformClass = "GCE_Miliciana_Negro";
            containerClass = "Supply40";
            mass = 40;
        };
    };
    class GCE_U_Miliciana_Caqui : ZEPHIK_BLU_WOODLAND_1_U
    {
        scope = 2;
        author = "GCE";
        displayName = "Uniforme de miliciana (caqui)";
        class ItemInfo : UniformItem
        {
            uniformModel = "-";
            uniformClass = "GCE_Miliciana_Caqui";
            containerClass = "Supply40";
            mass = 40;
        };
    };
};
