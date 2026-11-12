/*
    GCE - Misiones y jugabilidad (PBO separado)

    - Misiones de la Guerra Civil: se piden a Petros (acción "Misiones de la Guerra Civil").
      Solo se pueden elegir las que tienen sentido en ese momento.
    - Jefe de escuadra: asciende a un recluta de tu grupo para que reparta los blancos.

    Funciona con cualquier facción de Antistasi Ultimate (no depende de gce_main).
*/

class CfgPatches
{
    class GCE_misiones
    {
        name = "GCE - Misiones y jugabilidad";
        author = "GCE";
        units[] = {};
        weapons[] = {};
        requiredVersion = 2.20;
        requiredAddons[] = {"A3A_core", "cba_main"};
        version = 0.1;
        A3A_compatibility[] = {12, 4};
    };
};

class CfgFunctions
{
    class GCE
    {
        tag = "GCE";
        class nucleo
        {
            file = "\GCE\addons\gce_misiones\functions";
            class init { postInit = 1; };
            class addPlayerActions {};
            class comms {};
            class faction {};
            class enemyBase {};
            class enemyAir {};
            class spawnPos {};
            class spawnSquad {};
            class spawnVehicle {};
            class rebelsNear {};
            class enemiesNear {};
            class aliveInGroups {};
            class reward {};
            class cleanup {};
            class taskCreate {};
            class endMission {};
        };
        class menu
        {
            file = "\GCE\addons\gce_misiones\functions\menu";
            class availability {};
            class requestMenu {};
            class showMenu {};
            class startMission {};
        };
        class misiones
        {
            file = "\GCE\addons\gce_misiones\functions\misiones";
            class m_noPasaran {};
            class m_puente {};
            class m_finca {};
            class m_imprenta {};
            class m_refugio {};
            class m_oro {};
            class m_penal {};
            class accionCivil {};
            class civSeguir {};
            class accionPreso {};
            class presoLiberar {};
        };
        class jefe
        {
            file = "\GCE\addons\gce_misiones\functions\jefe";
            class jefeCondNombrar {};
            class jefeCondRetirar {};
            class jefeNombrar {};
            class jefeRetirar {};
            class jefeLoop {};
        };
    };
};
