# GCE – Guerra Civil Española para Antistasi Ultimate

Mod de **facciones** (templates) que ambienta Antistasi Ultimate en la Guerra Civil
Española (1936-1939). Todo es **gratuito**.

| Rol en Antistasi | Bando | Archivo |
|---|---|---|
| Ocupantes / Invasores | Ejército Nacional (Regulares, Falange, Requetés) | `GCE_AI_Nacionales.sqf` |
| Ocupantes (modo anarquista) | República: Ejército Popular, Guardia de Asalto, Brigadas Internacionales | `GCE_AI_Republica.sqf` |
| Invasores | Legión Cóndor + CTV | `GCE_AI_Condor.sqf` |
| Rebeldes (jugadores) | República (Ejército Popular, Brigadas Internacionales) | `GCE_Reb_Republica.sqf` |
| Rebeldes (alternativa) | Milicias CNT-FAI (mismo equipo, bandera rojinegra) | `GCE_Reb_CNT.sqf` |
| Civiles | Población española de los años 30 | `GCE_CIV.sqf` |

### Modos de juego
| Modo | Ocupantes | Invasores | Rebeldes |
|---|---|---|---|
| Clásico (preseleccionado) | GCE Ejército Nacional | GCE Legión Cóndor | GCE República |
| Anarquista | GCE República (gobierno) | GCE Ejército Nacional (invasor) | GCE Milicias CNT-FAI |

Puedes mezclarlos como quieras en la pestaña de facciones de Antistasi.

Mapa recomendado: **Altis** (los bandos GCE salen arriba de la lista en ese mapa).

## Mods necesarios (Steam Workshop, gratis)
1. CBA_A3
2. Antistasi Ultimate - Mod
3. IFA3 AIO
4. Northern Fronts

Opcionales (si están cargados, los templates los usan solos):
- WW2 Armored Cars / WW2 Tanks → Panzer II, Sd.Kfz 231…
- Flying Legends → Bf 109, Ju 52, Ju 86
- Secret Weapons → He 111, I-16 "Mosca" para la República

## Estructura
```
mod.cpp                          info que se ve en el launcher
addons/gce_main/
  $PBOPREFIX$                    GCE\addons\gce_main
  config.cpp                     registra los 4 bandos en Antistasi (class A3A >> Templates)
  Templates/
    GCE_AI_Nacionales.sqf        ocupantes
    GCE_AI_Condor.sqf            invasores
    GCE_Reb_Republica.sqf        rebeldes: tienda de vehículos y equipo inicial
    GCE_Reb_Vehicle_Attributes.sqf  PRECIOS de la tienda rebelde
    GCE_CIV.sqf                  civiles
    GCE_Vehicle_Attributes.sqf   coste de los vehículos enemigos
```

## Cómo cambiar vehículos, armas y precios
- **Tienda rebelde** (`GCE_Reb_Republica.sqf`): `vehiclesBasic` (el "quad"),
  `vehiclesLightUnarmed` (el "off-road"), `vehiclesTruck` (el camión), `vehiclesAT`,
  `staticMGs`… Pon cualquier classname de un mod cargado.
- **Precios**: `GCE_Reb_Vehicle_Attributes.sqf` → `["classname", ["rebCost", precio]]`.
- **Equipo inicial**: `_initialRebelEquipment` en `GCE_Reb_Republica.sqf`.
- **Armas enemigas**: bloque "GCE: armas de época" en los templates de IA.
- Para encontrar classnames: en el editor de Arma, clic derecho en un objeto → *Log → Copy classname*,
  o en el arsenal virtual con la consola de depuración.

## Banderas
Se generan con `python3 tools/make_flags.py` (necesita Pillow) y salen en:
- `addons/gce_main/data/flags/*_co.paa`: bandera del mástil y de la pantalla de selección.
- `addons/gce_main/data/markers/*_co.paa`: icono del mapa.
- `art/flags/*.png`: copias en PNG por si quieres retocarlas. Después conviértelas con ImageToPAA
  (Arma 3 Tools) usando el mismo nombre.

Para añadir otra bandera, crea una función de dibujo en `tools/make_flags.py` y añádela a `BANDERAS`.

## Compilar y publicar
1. Instala **Arma 3 Tools** (Steam → Biblioteca → Herramientas).
2. Con **Addon Builder**: origen `addons/gce_main`, destino `@GCE/addons`,
   y en opciones pon el prefijo `GCE\addons\gce_main`. Se genera `gce_main.pbo`.
3. Copia `mod.cpp` dentro de `@GCE/`.
4. Prueba: carga `@GCE` + las dependencias, entra en Antistasi Ultimate en Altis y elige los
   bandos "GCE …" en la pantalla de configuración.
5. Publica con **Arma 3 Publisher** marcando las dependencias del Workshop.

## Pendiente (siguientes fases)
- [x] Banderas propias (rojigualda, tricolor republicana, CNT-FAI) + marcadores de mapa.
- [ ] Retexturas de uniformes: monos de miliciano, boina roja de requeté, gorro isabelino.
- [ ] Material italiano del CTV (no hay en IFA3/Northern Fronts; buscar otro mod gratis o retexturas).
- [ ] Probar en partida y ajustar classnames que den error en el RPT.
- [ ] Bando "Rivales" (opcional).

Basado en templates de Antistasi Ultimate (MIT) – ver `THIRD_PARTY_NOTICES.md`.
