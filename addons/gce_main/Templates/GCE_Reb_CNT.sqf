/*
    GCE - Variante rebelde: Milicias CNT-FAI
    Mismo armamento y tienda que la República; cambia nombre, bandera y vestuario
    (monos de miliciano y gorras de obrero en lugar de uniforme soviético).
*/
private _gceCNT = true;     // activa el vestuario de las milicias (monos, gorras)
#include "GCE_Reb_Republica.sqf"

["name", "Milicias Confederales CNT-FAI"] call _fnc_saveToTemplate;
["flagTexture", "\GCE\addons\gce_main\data\flags\gce_cnt_co.paa"] call _fnc_saveToTemplate;
["flagMarkerType", "GCE_flag_CNT"] call _fnc_saveToTemplate;
