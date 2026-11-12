/*
    GCE - Mapa (PBO separado)

    IFA3 (WW2_Core_c_IF_Gui_c) cambia los colores del mapa: árboles y arbustos en verde fosforito
    y bosques en verde muy claro, y con zoom el mapa se llena de puntos que no dejan ver nada.
    Este parche, cargado después de IFA3, devuelve los colores del Arma 3 normal.

    Para ajustarlo a tu gusto cambia los valores {rojo, verde, azul, opacidad} (de 0 a 1).
    Opacidad más baja = puntos más discretos.
*/

class CfgPatches
{
    class GCE_mapa
    {
        name = "GCE - Colores del mapa";
        author = "GCE";
        units[] = {};
        weapons[] = {};
        requiredVersion = 2.20;
        requiredAddons[] = {"A3_Ui_F", "WW2_Core_c_IF_Gui_c"};
        version = 0.1;
    };
};

class RscMapControl
{
    colorForest[] = {0.624, 0.78, 0.388, 0.5};

    class Tree
    {
        color[] = {0.45, 0.64, 0.33, 0.4};
    };
    class SmallTree
    {
        color[] = {0.45, 0.64, 0.33, 0.4};
    };
    class Bush
    {
        color[] = {0.45, 0.64, 0.33, 0.4};
    };
};
