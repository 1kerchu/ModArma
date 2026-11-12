/*
    GCE - Uniformes (PBO separado: si algo falla aquí, las facciones siguen funcionando)

    Boinas basadas en H_Beret_blk (boina vanilla).
    Monos de miliciano basados en el mono de trabajo del Arma 3 base (gratis para todos):
      CfgWeapons  U_C_WorkerCoveralls   (objeto del inventario)
      CfgVehicles C_man_w_worker_F      (modelo que se ve puesto)
    Solo se cambia la textura (hiddenSelectionsTextures); el modelo es el original.
    Texturas generadas con tools/make_uniforms.py
*/

class CfgPatches
{
    class GCE_uniformes
    {
        name = "GCE - Uniformes";
        author = "GCE";
        units[] = {"GCE_Miliciano_Mono_Azul", "GCE_Miliciano_Mono_Mahon", "GCE_Miliciano_Mono_Negro", "GCE_Miliciano_Mono_Caqui"};
        weapons[] = {"GCE_H_Boina_Roja", "GCE_H_Boina_Negra", "GCE_U_Mono_Azul", "GCE_U_Mono_Mahon", "GCE_U_Mono_Negro", "GCE_U_Mono_Caqui"};
        requiredVersion = 2.20;
        requiredAddons[] = {"A3_Characters_F"};
        version = 0.1;
    };
};

class CfgVehicles
{
    class C_man_w_worker_F;
    class GCE_Miliciano_Mono_Azul : C_man_w_worker_F
    {
        scope = 1;
        author = "GCE";
        displayName = "Mono de miliciano (azul)";
        modelSides[] = {0, 1, 2, 3};       // lo puede llevar cualquier bando
        uniformClass = "GCE_U_Mono_Azul";
        hiddenSelectionsTextures[] = {"\GCE\addons\gce_uniformes\data\mono_azul_co.paa"};
    };
    class GCE_Miliciano_Mono_Mahon : C_man_w_worker_F
    {
        scope = 1;
        author = "GCE";
        displayName = "Mono de miliciano (azul mahón)";
        modelSides[] = {0, 1, 2, 3};       // lo puede llevar cualquier bando
        uniformClass = "GCE_U_Mono_Mahon";
        hiddenSelectionsTextures[] = {"\GCE\addons\gce_uniformes\data\mono_mahon_co.paa"};
    };
    class GCE_Miliciano_Mono_Negro : C_man_w_worker_F
    {
        scope = 1;
        author = "GCE";
        displayName = "Mono de miliciano (negro)";
        modelSides[] = {0, 1, 2, 3};       // lo puede llevar cualquier bando
        uniformClass = "GCE_U_Mono_Negro";
        hiddenSelectionsTextures[] = {"\GCE\addons\gce_uniformes\data\mono_negro_co.paa"};
    };
    class GCE_Miliciano_Mono_Caqui : C_man_w_worker_F
    {
        scope = 1;
        author = "GCE";
        displayName = "Mono de miliciano (caqui)";
        modelSides[] = {0, 1, 2, 3};       // lo puede llevar cualquier bando
        uniformClass = "GCE_U_Mono_Caqui";
        hiddenSelectionsTextures[] = {"\GCE\addons\gce_uniformes\data\mono_caqui_co.paa"};
    };
};

class CfgWeapons
{
    class UniformItem;
    class U_C_WorkerCoveralls;
    class H_Beret_blk;          // boina del Arma 3 base

    class GCE_H_Boina_Roja : H_Beret_blk
    {
        scope = 2;
        author = "GCE";
        displayName = "Boina roja (Requeté)";
        hiddenSelectionsTextures[] = {"\GCE\addons\gce_uniformes\data\boina_roja_co.paa"};
    };
    class GCE_H_Boina_Negra : H_Beret_blk
    {
        scope = 2;
        author = "GCE";
        displayName = "Boina negra";
        hiddenSelectionsTextures[] = {"\GCE\addons\gce_uniformes\data\boina_negra_co.paa"};
    };
    class GCE_U_Mono_Azul : U_C_WorkerCoveralls
    {
        scope = 2;
        author = "GCE";
        displayName = "Mono de miliciano (azul)";
        hiddenSelectionsTextures[] = {"\GCE\addons\gce_uniformes\data\mono_azul_co.paa"};
        class ItemInfo : UniformItem
        {
            uniformModel = "-";
            uniformClass = "GCE_Miliciano_Mono_Azul";
            containerClass = "Supply40";
            mass = 40;
        };
    };
    class GCE_U_Mono_Mahon : U_C_WorkerCoveralls
    {
        scope = 2;
        author = "GCE";
        displayName = "Mono de miliciano (azul mahón)";
        hiddenSelectionsTextures[] = {"\GCE\addons\gce_uniformes\data\mono_mahon_co.paa"};
        class ItemInfo : UniformItem
        {
            uniformModel = "-";
            uniformClass = "GCE_Miliciano_Mono_Mahon";
            containerClass = "Supply40";
            mass = 40;
        };
    };
    class GCE_U_Mono_Negro : U_C_WorkerCoveralls
    {
        scope = 2;
        author = "GCE";
        displayName = "Mono de miliciano (negro)";
        hiddenSelectionsTextures[] = {"\GCE\addons\gce_uniformes\data\mono_negro_co.paa"};
        class ItemInfo : UniformItem
        {
            uniformModel = "-";
            uniformClass = "GCE_Miliciano_Mono_Negro";
            containerClass = "Supply40";
            mass = 40;
        };
    };
    class GCE_U_Mono_Caqui : U_C_WorkerCoveralls
    {
        scope = 2;
        author = "GCE";
        displayName = "Mono de miliciano (caqui)";
        hiddenSelectionsTextures[] = {"\GCE\addons\gce_uniformes\data\mono_caqui_co.paa"};
        class ItemInfo : UniformItem
        {
            uniformModel = "-";
            uniformClass = "GCE_Miliciano_Mono_Caqui";
            containerClass = "Supply40";
            mass = 40;
        };
    };
};
